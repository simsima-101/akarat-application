// lib/services/google_auth_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:firebase_auth/firebase_auth.dart';

import '../secure_storage.dart';
import '../utils/constants.dart' as ApiService; // read/write/delete

class GoogleAuthService {
  static const _tokenKey = 'auth_token'; // where we persist backend token

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final gsi.GoogleSignIn _google = gsi.GoogleSignIn.instance;

  /// Resolved API base (no trailing slash), e.g. https://qa.akarat.com/api
  String get _baseUrl => ApiService.baseUrl;


  /// Google-only sign-in:
  /// 1) open Google v7 sheet
  /// 2) sign into Firebase
  /// 3) POST { google_id_token: "<firebase id token>" } to /login-google
  /// 4) store backend token + user fields
  /// Returns backend token or null on cancel/failure.
  Future<String?> signInWithGoogleOnly() async {
    // 1) Init Google v7
    await _google.initialize();
    try {
      await _google.attemptLightweightAuthentication();
    } catch (_) {/* ignore */}
    if (!_google.supportsAuthenticate()) {
      debugPrint('This platform does not support GoogleSignIn.authenticate().');
      return null;
    }

    // 2) Show Google account sheet
    final gsi.GoogleSignInAccount? account = await _authenticateAccountOrNull();
    if (account == null) {
      debugPrint('Google sign-in canceled by user.');
      return null;
    }

    // 3) Get Google idToken for Firebase credential
    final gsi.GoogleSignInAuthentication gAuth = await account.authentication;
    final String? googleIdToken = gAuth.idToken;
    if (googleIdToken == null || googleIdToken.isEmpty) {
      debugPrint('Google idToken is null/empty.');
      return null;
    }

    // 4) Sign into Firebase using Google credential
    final OAuthCredential cred = GoogleAuthProvider.credential(idToken: googleIdToken);
    final UserCredential userCred = await _auth.signInWithCredential(cred);
    final User? fbUser = userCred.user;
    if (fbUser == null) {
      debugPrint('Firebase user is null after Google sign-in.');
      return null;
    }

    // 4.1) Seed local profile immediately from Google/Firebase
    await _seedLocalProfileFromGoogle(account, fbUser);

    // 4.2) Persist the exact API host we’re using now (so /me uses same host)
    await SecureStorage.write('api_host', _baseUrl);

    // 5) Get a Firebase ID token (JWT) to give to your backend
    String? firebaseIdToken = await fbUser.getIdToken(true);
    firebaseIdToken ??= (await fbUser.getIdTokenResult(true)).token ?? '';
    if (firebaseIdToken.isEmpty) {
      debugPrint('Failed to obtain Firebase ID token.');
      return null;
    }

    // 6) Exchange Firebase token for your backend token at /login-google
    final result = await _postToLoginGoogle(firebaseIdToken);
    if (result == null) return null;

    // 7) Persist backend token + backend’s user fields (overwrite seeds)
    await SecureStorage.write(_tokenKey, result.token);

    if (result.first.isNotEmpty) await SecureStorage.write('user_first_name', result.first);
    if (result.last.isNotEmpty)  await SecureStorage.write('user_last_name',  result.last);
    if (result.email.isNotEmpty) await SecureStorage.write('user_email',      result.email);

    final joined = [result.first, result.last].where((s) => s.isNotEmpty).join(' ');
    if (joined.isNotEmpty) await SecureStorage.write('user_name', joined);

    return result.token;
  }

  /// Sign out (Google + Firebase) and clear stored backend token.
  Future<void> signOut() async {
    try { await _google.signOut(); } catch (_) {}
    try { await _auth.signOut(); } catch (_) {}
    await SecureStorage.delete(_tokenKey);
  }

  /// Quick check if a backend token exists
  Future<bool> hasBackendToken() async {
    final t = await SecureStorage.read(_tokenKey);
    return (t != null && t.isNotEmpty);
  }

  // ----------------- Helpers -----------------

  /// v7 authenticate with cancel handling via events.
  Future<gsi.GoogleSignInAccount?> _authenticateAccountOrNull() async {
    final completer = Completer<gsi.GoogleSignInAccount?>();
    StreamSubscription? sub;
    try {
      sub = _google.authenticationEvents.listen((event) {
        if (event is gsi.GoogleSignInAuthenticationEventSignIn && !completer.isCompleted) {
          completer.complete(event.user);
        }
      });

      try {
        await _google.authenticate(); // opens Google UI
      } on gsi.GoogleSignInException catch (e) {
        if (e.code == gsi.GoogleSignInExceptionCode.canceled) {
          completer.complete(null);
        } else {
          rethrow;
        }
      }

      return await completer.future;
    } finally {
      await sub?.cancel();
    }
  }

  /// Seed first/last/email locally ASAP so UI can show real data before /me.
  Future<void> _seedLocalProfileFromGoogle(
      gsi.GoogleSignInAccount? account,
      User? fbUser,
      ) async {
    final gEmail  = (account?.email ?? fbUser?.email ?? '').trim();
    final display = (account?.displayName ?? fbUser?.displayName ?? '').trim();

    String first = '';
    String last  = '';
    if (display.isNotEmpty) {
      final parts = display.split(RegExp(r'\s+'));
      first = parts.isNotEmpty ? parts.first : '';
      last  = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    if (gEmail.isNotEmpty) await SecureStorage.write('user_email', gEmail);
    if (first.isNotEmpty)  await SecureStorage.write('user_first_name', first);
    if (last.isNotEmpty)   await SecureStorage.write('user_last_name',  last);

    final joined = [first, last].where((s) => s.isNotEmpty).join(' ');
    if (joined.isNotEmpty) await SecureStorage.write('user_name', joined);
  }

  /// POST to /login-google with { google_id_token }
  Future<({String token, String first, String last, String email})?> _postToLoginGoogle(
      String firebaseIdToken,
      ) async {
    final Uri uri = Uri.parse('$_baseUrl/login-google');
    final http.Response r = await http.post(
      uri,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'google_id_token': firebaseIdToken}),
    );

    debugPrint('[/login-google] -> ${r.statusCode} ${r.body}');
    if (r.statusCode >= 200 && r.statusCode < 300) {
      try {
        final m    = jsonDecode(r.body) as Map<String, dynamic>;
        final data = (m['data'] ?? const {}) as Map<String, dynamic>;
        final user = (data['user'] ?? const {}) as Map<String, dynamic>;

        final token    = (data['token'] ?? data['access_token'] ?? '').toString().trim();
        final email    = (user['email'] ?? '').toString().trim();
        final fullName = (user['name']  ?? '').toString().trim(); // <- backend sends this

        // try direct first_name / last_name first (if backend adds them later)
        String first = (user['first_name'] ?? '').toString().trim();
        String last  = (user['last_name']  ?? '').toString().trim();

        // ✅ if they are missing, derive from "name"
        if (fullName.isNotEmpty && first.isEmpty && last.isEmpty) {
          final parts = fullName.trim().split(RegExp(r'\s+'));
          if (parts.isNotEmpty) {
            first = parts.first;
            if (parts.length > 1) {
              last = parts.sublist(1).join(' ');
            }
          }
        }

        if (token.isEmpty) return null;

        // ⬅️ we still return token/first/last/email, just now they are filled
        return (token: token, first: first, last: last, email: email);
      } catch (e) {
        debugPrint('parse /login-google failed: $e');
        return null;
      }
    }


    // Diagnostics to help catch QA/PROD host mismatches etc.
    final ct = (r.headers['content-type'] ?? '').toLowerCase();
    if (ct.contains('text/html')) {
      debugPrint('⚠️ HTML returned — likely wrong API_BASE_URL host (QA vs PROD mix).');
    } else if (r.statusCode == 422) {
      debugPrint('422: backend expects "google_id_token" (len=${firebaseIdToken.length})');
    } else if (r.statusCode == 401) {
      debugPrint('401: Firebase token verification failed on backend (project mismatch / clock skew?)');
    }
    return null;
  }

  // (Unused helper kept for completeness)
  String? _extractToken(String raw) {
    try {
      final dynamic m = jsonDecode(raw);
      if (m is Map<String, dynamic>) {
        final t0 = (m['token'] ?? '').toString().trim();
        if (t0.isNotEmpty) return t0;

        final d = m['data'];
        if (d is Map<String, dynamic>) {
          final t1 = (d['token'] ?? '').toString().trim();
          if (t1.isNotEmpty) return t1;
          final t2 = (d['access_token'] ?? '').toString().trim();
          if (t2.isNotEmpty) return t2;
        }
      }
    } catch (_) {/* ignore */}
    return null;
  }
}
