// lib/src/features/auth/data/models/user_model.dart

import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String token;
  final String email;
  final String firstName;
  final String lastName;
  final String displayName;

  const UserModel({
    required this.token,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.displayName,
  });

  // Optional: Add fromJson / toJson if your backend returns more fields
  // factory UserModel.fromJson(Map<String, dynamic> json) { ... }

  @override
  List<Object?> get props => [
    token,
    email,
    firstName,
    lastName,
    displayName,
  ];

  // Helper to copy with new values (useful in Bloc)
  UserModel copyWith({
    String? token,
    String? email,
    String? firstName,
    String? lastName,
    String? displayName,
  }) {
    return UserModel(
      token: token ?? this.token,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
    );
  }
}