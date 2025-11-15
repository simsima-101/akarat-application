import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:firebase_auth/firebase_auth.dart';

import '../secure_storage.dart';
import '../utils/constants.dart' as ApiService;
import '../services/auth_prefs.dart'; // 🔹 NEW: track login method (google)

/// iOS client ID from GoogleService-Info.plist (CLIENT_ID)
const String _IOS_CLIENT_ID =
    '370139668712-ema9n0o9vhq25nbqu771v5c71ehivolf.apps.googleusercontent.com';

class GoogleAuthService {
  static const _tokenKey = 'auth_token';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final gsi.GoogleSignIn _google = gsi.GoogleSignIn.instance;

  String get _baseUrl => ApiService.baseUrl;

  Future<String?> signInWithGoogleOnly() async {
    // v7 requires clientId at initialize on iOS
    await _google.initialize(clientId: _IOS_CLIENT_ID);

    try {
      await _google.attemptLightweightAuthentication();
    } catch (_) {/* ignore */}

    if (!_google.supportsAuthenticate()) {
      debugPrint('This platform does not support GoogleSignIn.authenticate().');
      return null;
    }

    // Open Google sheet and wait for sign-in event
    final gsi.GoogleSignInAccount? account = await _authenticateAccountOrNull();
    if (account == null) {
      debugPrint('Google sign-in canceled or no account returned.');
      return null;
    }

    // Get Google ID token -> Firebase sign-in
    final gsi.GoogleSignInAuthentication gAuth = await account.authentication;
    final String? googleIdToken = gAuth.idToken;
    if (googleIdToken == null || googleIdToken.isEmpty) {
      debugPrint('Google idToken is null/empty.');
      return null;
    }

    final OAuthCredential cred = GoogleAuthProvider.credential(idToken: googleIdToken);
    final UserCredential userCred = await _auth.signInWithCredential(cred);
    final User? fbUser = userCred.user;
    if (fbUser == null) return null;

    await _seedLocalProfileFromGoogle(account, fbUser);
    await SecureStorage.write('api_host', _baseUrl);

    // Exchange Firebase ID token with your backend
    String? firebaseIdToken = await fbUser.getIdToken(true);
    firebaseIdToken ??= (await fbUser.getIdTokenResult(true)).token ?? '';
    if (firebaseIdToken.isEmpty) return null;

    final result = await _postToLoginGoogle(firebaseIdToken);
    if (result == null) return null;

    await SecureStorage.write(_tokenKey, result.token);
    if (result.first.isNotEmpty) await SecureStorage.write('user_first_name', result.first);
    if (result.last.isNotEmpty)  await SecureStorage.write('user_last_name',  result.last);
    if (result.email.isNotEmpty) await SecureStorage.write('user_email',      result.email);

    final joined = [result.first, result.last].where((s) => s.isNotEmpty).join(' ');
    if (joined.isNotEmpty) await SecureStorage.write('user_name', joined);

    // 🔹 Mark Google login here too (for PI screen: hide Change Password)
    await AuthPrefs.setLoginMethod(LoginMethod.google);

    return result.token;
  }

  Future<void> signOut() async {
    try {
      await _google.signOut();
    } catch (_) {}
    try {
      await _auth.signOut();
    } catch (_) {}
    await SecureStorage.delete(_tokenKey);
    await AuthPrefs.clear(); // 🔹 clear login method on logout
  }

  Future<bool> hasBackendToken() async {
    final t = await SecureStorage.read(_tokenKey);
    return (t != null && t.isNotEmpty);
  }

  // ---------- helpers ----------

  Future<gsi.GoogleSignInAccount?> _authenticateAccountOrNull() async {
    final completer = Completer<gsi.GoogleSignInAccount?>();
    StreamSubscription? sub;
    try {
      sub = _google.authenticationEvents.listen((event) {
        debugPrint('GI event: $event');
        if (event is gsi.GoogleSignInAuthenticationEventSignIn &&
            !completer.isCompleted) {
          completer.complete(event.user);
        }
      });

      try {
        await _google.authenticate(); // opens Google UI
      } on gsi.GoogleSignInException catch (e) {
        if (e.code == gsi.GoogleSignInExceptionCode.canceled) {
          completer.complete(null);
        } else {
          completer.completeError(e);
        }
      }

      return await completer.future;
    } finally {
      await sub?.cancel();
    }
  }

  Future<void> _seedLocalProfileFromGoogle(
      gsi.GoogleSignInAccount? account,
      User? fbUser,
      ) async {
    final gEmail = (account?.email ?? fbUser?.email ?? '').trim();
    final display = (account?.displayName ?? fbUser?.displayName ?? '').trim();

    String first = '';
    String last = '';
    if (display.isNotEmpty) {
      final parts = display.split(RegExp(r'\s+'));
      first = parts.isNotEmpty ? parts.first : '';
      last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    if (gEmail.isNotEmpty) await SecureStorage.write('user_email', gEmail);
    if (first.isNotEmpty) await SecureStorage.write('user_first_name', first);
    if (last.isNotEmpty) await SecureStorage.write('user_last_name', last);

    final joined = [first, last].where((s) => s.isNotEmpty).join(' ');
    if (joined.isNotEmpty) await SecureStorage.write('user_name', joined);
  }

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
        final m = jsonDecode(r.body) as Map<String, dynamic>;
        final data = (m['data'] ?? const {}) as Map<String, dynamic>;
        final user = (data['user'] ?? const {}) as Map<String, dynamic>;

        final token = (data['token'] ?? data['access_token'] ?? '').toString().trim();
        final email = (user['email'] ?? '').toString().trim();
        final fullName = (user['name'] ?? '').toString().trim();

        String first = (user['first_name'] ?? '').toString().trim();
        String last = (user['last_name'] ?? '').toString().trim();

        if (fullName.isNotEmpty && first.isEmpty && last.isEmpty) {
          final parts = fullName.trim().split(RegExp(r'\s+'));
          if (parts.isNotEmpty) {
            first = parts.first;
            if (parts.length > 1) last = parts.sublist(1).join(' ');
          }
        }

        if (token.isEmpty) return null;
        return (token: token, first: first, last: last, email: email);
      } catch (e) {
        debugPrint('parse /login-google failed: $e');
        return null;
      }
    }

    final ct = (r.headers['content-type'] ?? '').toLowerCase();
    if (ct.contains('text/html')) {
      debugPrint(
          '⚠️ HTML returned — likely wrong API_BASE_URL host (QA vs PROD mix).');
    } else if (r.statusCode == 422) {
      debugPrint(
          '422: backend expects "google_id_token" (len=${firebaseIdToken.length})');
    } else if (r.statusCode == 401) {
      debugPrint(
          '401: Firebase token verification failed on backend (project mismatch / clock skew?)');
    }
    return null;
  }
}
