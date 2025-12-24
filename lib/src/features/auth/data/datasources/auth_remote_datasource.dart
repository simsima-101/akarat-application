// lib/src/features/auth/data/datasources/auth_remote_datasource.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/utils/secure_storage.dart';
import '../../../../core/constants/constants.dart' as ApiService;
import '../../../../core/error/exceptions.dart';        // You will create this
        // You will create this
import '../../../../core/services/api_client.dart';      // Or api_service.dart if you keep it
    // Moved to core/utils
import '../../../../core/utils/session_manager.dart';   // Optional: in-memory session (if needed)
import '../../../../screen/login.dart';
       // Plain entity (create later)
import '../models/user_model.dart';                      // JSON-serializable model (create later)

/// iOS Client ID from Google Cloud Console (move to .env or constants later)
const String _iosClientId =
    '370139668712-ema9n0o9vhq25nbqu771v5c71ehivolf.apps.googleusercontent.com';

abstract class AuthRemoteDataSource {
  /// Email/password login – to be added from other services if exists
  // Future<UserModel> loginWithEmail({required String email, required String password});

  /// Google Sign-In full flow
  Future<UserModel> loginWithGoogle();

  /// Account deletion (permanent)
  Future<void> deleteAccount(BuildContext context);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client httpClient;               // Injected shared client
  final FirebaseAuth firebaseAuth;
  final gsi.GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.httpClient,
    FirebaseAuth? firebaseAuth,
    gsi.GoogleSignIn? googleSignIn,
  })  : firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        googleSignIn = googleSignIn ?? gsi.GoogleSignIn.instance;

  // ===================================================================
  // Google Sign-In
  // ===================================================================
  @override
  Future<UserModel> loginWithGoogle() async {
    try {
      // Initialize Google Sign-In (required on iOS)
      await googleSignIn.initialize(clientId: _iosClientId);

      // Try silent login first
      try {
        await googleSignIn.attemptLightweightAuthentication();
      } catch (_) {
        // Ignore – will show UI
      }

      if (!googleSignIn.supportsAuthenticate()) {
        throw ServerException(); // or custom AuthException
      }

      final gsi.GoogleSignInAccount? googleAccount = await _authenticateWithGoogle();
      if (googleAccount == null) {
        throw ServerException(); // User cancelled
      }

      final gsi.GoogleSignInAuthentication googleAuth =
      await googleAccount.authentication;
      final String? googleIdToken = googleAuth.idToken;

      if (googleIdToken == null || googleIdToken.isEmpty) {
        throw ServerException();
      }

      // Firebase authentication
      final credential = GoogleAuthProvider.credential(idToken: googleIdToken);
      final userCredential = await firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw ServerException();
      }

      final firebaseIdToken = await firebaseUser.getIdToken();
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw ServerException();
      }

      // Exchange with your backend
      final backendResult = await _loginWithBackend(firebaseIdToken);
      if (backendResult == null) {
        throw ServerException();
      }

      // Convert to domain model (you can adjust mapping as needed)
      final userModel = UserModel(
        token: backendResult.token,
        email: backendResult.email,
        firstName: backendResult.first,
        lastName: backendResult.last,
        displayName: backendResult.displayName,
        // add other fields if your UserModel has them
      );

      // Save locally – this should be done in the repository or local datasource,
      // but for backward compatibility we keep it here temporarily.
      // Later move to AuthLocalDataSource.
      await _saveUserProfileLocally(userModel);

      return userModel;
    } catch (e) {
      debugPrint('Google Sign-In failed: $e');
      rethrow; // Let repository handle and map to Failure
    }
  }

  // ===================================================================
  // Account Deletion
  // ===================================================================
  @override
  Future<void> deleteAccount(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final token = await SecureStorage.getToken();
      if (token == null || token.isEmpty) {
        messenger.showSnackBar(const SnackBar(content: Text('You are not logged in')));
        _navigateToLogin(context);
        throw AuthenticationException(); // custom if you create one
      }

      final base = ApiService.baseUrl; // keep or replace with injected base URL
      final endpoints = [
        '$base/delete',
        '$base/delete-account',
        '$base/account/delete',
        '$base/user/delete',
      ];

      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      };

      http.Response? response;

      for (final endpoint in endpoints) {
        final uri = Uri.parse(endpoint);

        try {
          // Try DELETE
          response = await httpClient.delete(uri, headers: headers).timeout(const Duration(seconds: 20));

          // If DELETE not allowed → try POST
          if (response.statusCode == 404 || response.statusCode == 405) {
            response = await httpClient.post(uri, headers: headers, body: jsonEncode({'confirm': true}));
          }

          if (response.statusCode case 200 || 201 || 202 || 204 || 205) {
            await _performFullLogout(context);
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Account deleted successfully'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        } catch (_) {
          continue; // try next endpoint
        }
      }

      final msg = _extractErrorMessage(response);
      messenger.showSnackBar(SnackBar(content: Text(msg)));
      throw ServerException();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Network error: $e')));
      rethrow;
    }
  }

  // ===================================================================
  // Private Helpers
  // ===================================================================

  Future<gsi.GoogleSignInAccount?> _authenticateWithGoogle() async {
    final completer = Completer<gsi.GoogleSignInAccount?>();
    StreamSubscription? subscription;

    try {
      subscription = googleSignIn.authenticationEvents.listen((event) {
        if (event is gsi.GoogleSignInAuthenticationEventSignIn && !completer.isCompleted) {
          completer.complete(event.user);
        }
      });

      await googleSignIn.authenticate();
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
      final response = await httpClient.post(
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
    } catch (e) {
      debugPrint('Backend request failed: $e');
    }

    return null;
  }

  Future<void> _saveUserProfileLocally(UserModel user) async {
    await SecureStorage.saveToken(user.token);
    await SecureStorage.saveUserName(user.displayName);
    await SecureStorage.saveUserEmail(user.email);
    await SecureStorage.saveFirstName(user.firstName);
    await SecureStorage.saveLastName(user.lastName);

    // Optional: update in-memory session
    SessionManager().setAuth(
      token: user.token,
      userName: user.displayName,
      userEmail: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
    );
  }

  String _extractErrorMessage(http.Response? response) {
    if (response == null) return 'No response from server';

    try {
      final json = jsonDecode(response.body);
      return json['message'] ?? json['error'] ?? 'Delete failed (${response.statusCode})';
    } catch (_) {
      return 'Server error (${response.statusCode})';
    }
  }

  Future<void> _performFullLogout(BuildContext context) async {
    SessionManager().clear();
    SecureStorage.deleteAll();
    _navigateToLogin(context);
  }

  void _navigateToLogin(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginDemo()), // Update to your login page
            (_) => false,
      );
    });
  }
}