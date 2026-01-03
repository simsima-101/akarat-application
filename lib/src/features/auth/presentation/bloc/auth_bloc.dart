// lib/src/features/auth/presentation/bloc/auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:Akarat/src/core/utils/session_manager.dart';
import 'package:http/http.dart';

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
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    await SessionManager().restore();
    final token = SessionManager().token;

    if (token != null && token.isNotEmpty) {
      await SessionManager().refreshProfileFromServer();
      emit(AuthAuthenticated());
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // TODO: Implement actual login API call
      // final result = await AuthRepository().login(event.email, event.password);
      // await SessionManager().setAuth(token: result.token, ...);

      emit(AuthAuthenticated());
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
}