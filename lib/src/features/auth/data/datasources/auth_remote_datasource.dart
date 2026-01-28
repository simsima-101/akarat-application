// lib/src/features/auth/data/datasources/auth_remote_datasource.dart

import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:http/http.dart' as http;

import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/secure_storage.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../screen/login.dart';
import '../models/user_model.dart';

// iOS Client ID from Google Cloud Console (move to .env later)
const String _iosClientId =
    '370139668712-ema9n0o9vhq25nbqu771v5c71ehivolf.apps.googleusercontent.com';

// Simple response wrapper (separate token from user data)
class LoginResponse {
  final UserModel user;
  final String token;
  final String id; // user ID from backend

  LoginResponse({
    required this.user,
    required this.token,
    required this.id,
  });
}

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithGoogle();
  // Future<void> deleteAccount(BuildContext context);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client httpClient;
  final FirebaseAuth firebaseAuth;
  final gsi.GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.httpClient,
    FirebaseAuth? firebaseAuth,
    gsi.GoogleSignIn? googleSignIn,
  })  : firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        googleSignIn = googleSignIn ?? gsi.GoogleSignIn.instance;

  @override
  Future<UserModel> loginWithGoogle() async {
    try {
      await googleSignIn.initialize(clientId: _iosClientId);

      try {
        await googleSignIn.attemptLightweightAuthentication();
      } catch (_) {}

      if (!googleSignIn.supportsAuthenticate()) {
        throw ServerException();
      }

      final gsi.GoogleSignInAccount? googleAccount =
          await _authenticateWithGoogle();
      if (googleAccount == null) {
        throw ServerException(); // User cancelled
      }

      final gsi.GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;
      final String? googleIdToken = googleAuth.idToken;

      if (googleIdToken == null || googleIdToken.isEmpty) {
        throw ServerException();
      }

      // Firebase Auth
      final credential = GoogleAuthProvider.credential(idToken: googleIdToken);
      final userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw ServerException();
      }

      final firebaseIdToken = await firebaseUser.getIdToken();
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw ServerException();
      }

      // Exchange with backend
      final backendResult = await _loginWithBackend(firebaseIdToken);
      if (backendResult == null) {
        throw ServerException();
      }

// Create UserModel from backendResult.user
      final userModel = UserModel(
        id: backendResult.id,
        email: backendResult.user.email,
        firstName: backendResult.user.firstName,
        lastName: backendResult.user.lastName,
        displayName: backendResult.user.displayName,
      );

// Save token separately (from root of LoginResponse)
      await SecureStorage.saveToken(backendResult.token);

// Save user profile data locally
      await _saveUserProfileLocally(userModel);

// Update in-memory session (use fields from userModel)
      await SessionManager().setAuth(
        token: backendResult.token,
        userName: userModel.displayName ?? 'User',
        userEmail: userModel.email,
        firstName: userModel.firstName ?? '',
        lastName: userModel.lastName ?? '',
      );

      return userModel;

      return userModel;
    } catch (e) {
      debugPrint('Google Sign-In failed: $e');
      rethrow;
    }
  }

  // Account deletion (unchanged - looks good)
  // @override
  // Future<void> deleteAccount(BuildContext context) async {
  //   final messenger = ScaffoldMessenger.of(context);
  //
  //   try {
  //     final token = await SecureStorage.getToken();
  //     if (token == null || token.isEmpty) {
  //       messenger.showSnackBar(const SnackBar(content: Text('You are not logged in')));
  //       _navigateToLogin(context);
  //       throw AuthenticationException();
  //     }
  //
  //     final base = ApiService.baseUrl;
  //     final endpoints = [
  //       '$base/delete',
  //       '$base/delete-account',
  //       '$base/account/delete',
  //       '$base/user/delete',
  //     ];
  //
  //     final headers = {
  //       'Authorization': 'Bearer $token',
  //       'Accept': 'application/json',
  //       'Content-Type': 'application/json',
  //       'X-Requested-With': 'XMLHttpRequest',
  //     };
  //
  //     http.Response? response;
  //
  //     for (final endpoint in endpoints) {
  //       final uri = Uri.parse(endpoint);
  //
  //       try {
  //         response = await httpClient.delete(uri, headers: headers).timeout(const Duration(seconds: 20));
  //
  //         if (response.statusCode == 404 || response.statusCode == 405) {
  //           response = await httpClient.post(uri, headers: headers, body: jsonEncode({'confirm': true}));
  //         }
  //
  //         if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 202 || response.statusCode == 204 || response.statusCode == 205) {
  //           await _performFullLogout(context);
  //           messenger.showSnackBar(
  //             const SnackBar(content: Text('Account deleted successfully'), backgroundColor: Colors.red),
  //           );
  //           return;
  //         }
  //       } catch (_) {
  //         continue;
  //       }
  //     }
  //
  //     final msg = _extractErrorMessage(response);
  //     messenger.showSnackBar(SnackBar(content: Text(msg)));
  //     throw ServerException();
  //   } catch (e) {
  //     messenger.showSnackBar(SnackBar(content: Text('Network error: $e')));
  //     rethrow;
  //   }
  // }

  // Private Helpers (updated _loginWithBackend to return id)

  Future<gsi.GoogleSignInAccount?> _authenticateWithGoogle() async {
    final completer = Completer<gsi.GoogleSignInAccount?>();
    StreamSubscription? subscription;

    try {
      subscription = googleSignIn.authenticationEvents.listen((event) {
        if (event is gsi.GoogleSignInAuthenticationEventSignIn &&
            !completer.isCompleted) {
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

  Future<LoginResponse?> _loginWithBackend(String firebaseIdToken) async {
    // final uri = Uri.parse('${ApiService.baseUrl}/login-google');

    try {
      // final response = await httpClient
      //     .post(
      //       uri,
      //       headers: {
      //         'Accept': 'application/json',
      //         'Content-Type': 'application/json'
      //       },
      //       body: jsonEncode({'google_id_token': firebaseIdToken}),
      //     )
      //     .timeout(const Duration(seconds: 25));

      final response = await ApiService.post(
        'login-google',
        body: {
          'google_id_token': firebaseIdToken,
        },
      ).timeout(const Duration(seconds: 25));

      debugPrint('[/login-google] ${response.statusCode} ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>? ?? {};
        final user = data['user'] as Map<String, dynamic>? ?? {};

        final token =
            (data['token'] ?? data['access_token'] ?? '').toString().trim();
        if (token.isEmpty) return null;

        final id = (user['id'] ?? user['user_id'] ?? '').toString().trim();
        final email = (user['email'] ?? '').toString().trim();
        final fullName = (user['name'] ?? '').toString().trim();
        String first = (user['first_name'] ?? '').toString().trim();
        String last = (user['last_name'] ?? '').toString().trim();

        if (fullName.isNotEmpty && first.isEmpty && last.isEmpty) {
          final parts = fullName.split(RegExp(r'\s+'));
          first = parts.isNotEmpty ? parts.first : '';
          last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
        }

        final displayName =
            fullName.isNotEmpty ? fullName : '$first $last'.trim();

        return LoginResponse(
          user: UserModel(
            id: id,
            email: email,
            firstName: first,
            lastName: last,
            displayName: displayName.isNotEmpty ? displayName : 'User',
          ),
          token: token,
          id: id,
        );
      }
    } catch (e) {
      debugPrint('Backend request failed: $e');
    }

    return null;
  }

  Future<void> _saveUserProfileLocally(UserModel user) async {
    // Token is saved separately now – no more user.token
    await SecureStorage.saveUserName(user.displayName ?? 'User');
    await SecureStorage.saveUserEmail(user.email ?? '');
    await SecureStorage.saveFirstName(user.firstName ?? '');
    await SecureStorage.saveLastName(user.lastName ?? '');
  }

  String _extractErrorMessage(http.Response? response) {
    if (response == null) return 'No response from server';

    try {
      final json = jsonDecode(response.body);
      return json['message'] ??
          json['error'] ??
          'Delete failed (${response.statusCode})';
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
        MaterialPageRoute(builder: (_) => const LoginDemo()),
        (_) => false,
      );
    });
  }
}
