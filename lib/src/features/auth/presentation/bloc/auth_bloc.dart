// lib/src/features/auth/presentation/bloc/auth_bloc.dart
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:Akarat/src/core/utils/session_manager.dart';
import 'package:http/http.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/constants.dart' as ApiService;
import '../../../../core/utils/secure_storage.dart';
import '../../../property/presentation/bloc/favorite_event.dart';

part 'auth_event.dart';
part 'auth_state.dart';

// Important: Declare this at the top level (outside the bloc)
// This will be used in main.dart
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ShowLoginRequiredDialog>(_onShowLoginRequiredDialog);
    on<NavigateToLogin>(_onNavigateToLogin);


    on<AuthLoginSuccess>((event, emit) async {
      // Optional: re-save token (you already did it in OTP screen)
      await SecureStorage.setToken(event.token);

      // Emit authenticated state
      emit(AuthAuthenticated(
        // You can add more fields later if needed
        token: event.token,
        fullName: event.fullName,
        email: event.email,
      ));

      // Auto-load favorites after successful login
      add(const LoadFavorites() as AuthEvent); // if you have this event in FavoriteBloc
    });
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    await SessionManager().restore();
    final token = SessionManager().token;

    if (token != null && token.isNotEmpty) {
      await SessionManager().refreshProfileFromServer();

      // FIXED: pass the token
      emit(AuthAuthenticated(
        token: token,
        // fullName: SessionManager().userName,   // optional
        // email: SessionManager().userEmail,     // optional
        // firstName: ..., lastName: ...          // optional
      ));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // Your real login API call (replace with actual repository)
      final loginResponse = await AuthRepository().login(
        email: event.email,
        password: event.password,
      );

      final user = loginResponse.user;
      final authToken = loginResponse.token;

      // Save session data
      await SessionManager().setAuth(
        token: authToken,
        userName: user.name ??
            (user.firstName != null && user.lastName != null
                ? '${user.firstName} ${user.lastName}'
                : event.email.split('@')[0]),
        userEmail: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
      );

      // Send FCM token to backend
      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken != null) {
        try {
          final response = await http.post(
            Uri.parse('${ApiService.baseUrl}/api/v1/devices/register-token'),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'token': fcmToken,
              'device_type': 'android',
            }),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            debugPrint('FCM token sent to backend successfully');
          } else {
            debugPrint('Failed to send token: ${response.statusCode} - ${response.body}');
          }
        } catch (e) {
          debugPrint('Error sending FCM token: $e');
        }
      }

      // FIXED: Pass the token (and optionally other fields)
      emit(AuthAuthenticated(
        token: authToken,
        fullName: user.name ??
            (user.firstName != null && user.lastName != null
                ? '${user.firstName} ${user.lastName}'
                : null),
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Handle registration start
      emit(AuthRegistrationInProgress());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    SessionManager().clear();
    emit(AuthUnauthenticated());
  }

// New: Show the red "Login required" dialogs
  Future<void> _onShowLoginRequiredDialog(
      ShowLoginRequiredDialog event, Emitter<AuthState> emit) async {
    showDialog(
      context: event.context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Container(
          height: 70,
          margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Close button
              Positioned(
                top: -14,
                right: -10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              // Message + Login link
              Positioned(
                left: 16,
                right: 16,
                bottom: 12,
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Login required to add favorites.',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(dialogContext).pop(); // Close dialog

                        // Small delay to ensure dialog is fully dismissed before navigation
                        Future.delayed(const Duration(milliseconds: 300), () {
                          navigatorKey.currentState?.pushNamed('/login');
                        });
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                          decorationThickness: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  // New: Navigate to login screen safely using global navigator key
  void _onNavigateToLogin(NavigateToLogin event, Emitter<AuthState> emit) {
    navigatorKey.currentState?.pushNamed('/login');
  }

  AuthRepository() {}
}