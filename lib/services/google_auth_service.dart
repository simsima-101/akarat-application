// lib/services/google_auth_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:firebase_auth/firebase_auth.dart';

import '../secure_storage.dart';
import '../services/api_service.dart';
import '../services/auth_prefs.dart';
import '../services/session.dart';

/// iOS Client ID from Google Cloud Console
const String _IOS_CLIENT_ID =
    '370139668712-ema9n0o9vhq25nbqu771v5c71ehivolf.apps.googleusercontent.com';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final gsi.GoogleSignIn _googleSignIn = gsi.GoogleSignIn.instance;

  /// Full Google Sign-In flow → Firebase → Backend → Save profile
  Future<String?> signInWithGoogle() async {
    try {
      // Initialize Google Sign-In (required on iOS)
      await _googleSignIn.initialize(clientId: _IOS_CLIENT_ID);

      // Try silent login first (re-use existing session)
      try {
        await _googleSignIn.attemptLightweightAuthentication();
      } catch (_) {
        // Ignore – silent login failed, will show UI next
      }

      if (!_googleSignIn.supportsAuthenticate()) {
        debugPrint('Google Sign-In not supported on this platform');
        return null;
      }

      // Full interactive sign-in
      final gsi.GoogleSignInAccount? googleAccount = await _authenticateWithGoogle();
      if (googleAccount == null) {
        debugPrint('Google sign-in was canceled');
        return null;
      }

      // Get Google ID token
      final gsi.GoogleSignInAuthentication googleAuth = await googleAccount.authentication;
      final String? googleIdToken = googleAuth.idToken;
      if (googleIdToken == null || googleIdToken.isEmpty) {
        debugPrint('Missing Google ID token');
        return null;
      }

      // Sign in to Firebase
      final credential = GoogleAuthProvider.credential(idToken: googleIdToken);
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        debugPrint('Firebase sign-in failed');
        return null;
      }

      // Get Firebase token to send to backend
      final firebaseIdToken = await firebaseUser.getIdToken();
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        debugPrint('Failed to get Firebase ID token');
        return null;
      }

      // Exchange with your backend
      final result = await _loginWithBackend(firebaseIdToken);
      if (result == null) {
        debugPrint('Backend rejected Google login');
        return null;
      }

      // Save full profile using real SecureStorage
      await _saveUserProfile(
        token: result.token,
        firstName: result.first,
        lastName: result.last,
        email: result.email,
        displayName: result.displayName,
      );

      // Mark login method
      await AuthPrefs.setLoginMethod(LoginMethod.google);

      // Update in-memory session
      Session().setAuth(
        token: result.token,
        userName: result.displayName,
        userEmail: result.email,
        firstName: result.first,
        lastName: result.last,
      );

      debugPrint('Google login successful: ${result.email}');
      return result.token;
    } catch (e, stack) {
      debugPrint('Google Sign-In failed: $e\n$stack');
      return null;
    }
  }

  /// Full logout: Google + Firebase + Local storage
  Future<void> signOut() async {
    // Sign out from Google
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    // Sign out from Firebase
    try {
      await _auth.signOut();
    } catch (_) {}

    // Clear local data (these return void → no await needed)
    Session().clear();
    SecureStorage.deleteAll();
    AuthPrefs.clear();
  }

  /// Check if user has valid backend token
  Future<bool> isSignedIn() async {
    final token = await SecureStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  // ─────────────────────────────────────────────────────────────
  // Private Helpers
  // ─────────────────────────────────────────────────────────────

  Future<gsi.GoogleSignInAccount?> _authenticateWithGoogle() async {
    final completer = Completer<gsi.GoogleSignInAccount?>();
    StreamSubscription? subscription;

    try {
      subscription = _googleSignIn.authenticationEvents.listen((event) {
        if (event is gsi.GoogleSignInAuthenticationEventSignIn && !completer.isCompleted) {
          completer.complete(event.user);
        }
      });

      await _googleSignIn.authenticate();
      return await completer.future.timeout(const Duration(seconds: 30));
    } on TimeoutException {
      completer.complete(null);
    } on gsi.GoogleSignInException catch (e) {
      if (e.code == gsi.GoogleSignInExceptionCode.canceled) {
        completer.complete(null);
      } else {
        completer.completeError(e);
      }
    } catch (e) {
      completer.completeError(e);
    } finally {
      await subscription?.cancel();
    }

    return completer.future;
  }

  Future<({
  String token,
  String first,
  String last,
  String email,
  String displayName,
  })?> _loginWithBackend(String firebaseIdToken) async {
    final uri = Uri.parse('${ApiService.baseUrl}/login-google');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'google_id_token': firebaseIdToken}),
      ).timeout(const Duration(seconds: 25));

      debugPrint('[/login-google] ${response.statusCode} ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>? ?? {};
        final user = data['user'] as Map<String, dynamic>? ?? {};

        final token = (data['token'] ?? data['access_token'] ?? '').toString().trim();
        if (token.isEmpty) return null;

        final email = (user['email'] ?? '').toString().trim();
        final fullName = (user['name'] ?? '').toString().trim();
        String first = (user['first_name'] ?? '').toString().trim();
        String last = (user['last_name'] ?? '').toString().trim();

        if (fullName.isNotEmpty && first.isEmpty && last.isEmpty) {
          final parts = fullName.split(RegExp(r'\s+'));
          first = parts.isNotEmpty ? parts.first : '';
          last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
        }

        final displayName = fullName.isNotEmpty ? fullName : '$first $last'.trim();

        return (
        token: token,
        first: first,
        last: last,
        email: email,
        displayName: displayName.isNotEmpty ? displayName : 'User',
        );
      }

      if (response.headers['content-type']?.contains('html') == true) {
        debugPrint('HTML response → Check API_BASE_URL (QA vs PROD mismatch?)');
      }
    } catch (e) {
      debugPrint('Backend request failed: $e');
    }

    return null;
  }

  Future<void> _saveUserProfile({
    required String token,
    required String firstName,
    required String lastName,
    required String email,
    required String displayName,
  }) async {
    await SecureStorage.saveToken(token);
    await SecureStorage.saveUserName(displayName);
    await SecureStorage.saveUserEmail(email);
    await SecureStorage.saveFirstName(firstName);
    await SecureStorage.saveLastName(lastName);
  }
}