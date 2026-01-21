part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String token;
  final String? fullName;
  final String? email;
  final String? firstName;
  final String? lastName;

  const AuthAuthenticated({
    required this.token,
    this.fullName,
    this.email,
    this.firstName,
    this.lastName,
  });

  @override
  List<Object?> get props => [
    token,
    fullName,
    email,
    firstName,
    lastName,
  ];
}

class AuthUnauthenticated extends AuthState {}

class AuthRegistrationInProgress extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}