// lib/src/features/auth/presentation/bloc/auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:Akarat/src/core/utils/session_manager.dart'; // For session check

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RegisterRequested>(_onRegisterRequested);
    // Add more events as needed (e.g., GoogleLoginRequested)
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    // Restore session from SecureStorage / SessionManager
    await SessionManager().restore();

    final token = SessionManager().token;
    final isLoggedIn = token != null && token.isNotEmpty;

    if (isLoggedIn) {
      // Optionally refresh profile or validate token
      await SessionManager().refreshProfileFromServer();
      emit(AuthAuthenticated());
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // Call your API login (use ApiService or your auth datasource)
      // final result = await ApiService.login(email: event.email, password: event.password);

      // On success:
      // await SessionManager().setAuth(token: result.token, userEmail: event.email, ...);
      emit(AuthAuthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // Handle registration flow (may go to OTP screen, so don't emit authenticated yet)
      // await ApiService.registerStart(...);
      emit(AuthRegistrationInProgress());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    // Remove 'await' — clear() returns void or is synchronous
    SessionManager().clear();



    emit(AuthUnauthenticated());
  }
}