// lib/src/features/auth/presentation/bloc/auth_event.dart
part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  const RegisterRequested();
}

class LogoutRequested extends AuthEvent {}

/// New: Show the "Login required" red dialogs
class ShowLoginRequiredDialog extends AuthEvent {
  final BuildContext context;

  const ShowLoginRequiredDialog(this.context);

  @override
  List<Object?> get props => [context];
}

/// New: Navigate to login screen (used after tapping "Login" in dialogs)
class NavigateToLogin extends AuthEvent {}