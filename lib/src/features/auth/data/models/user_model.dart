// lib/src/features/auth/data/models/user_model.dart
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;              // ← Required - user ID for backend
  final String email;
  final String? firstName;
  final String? lastName;
  final String? displayName;

  const UserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.displayName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['user_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      displayName: json['name']?.toString() ??
          json['display_name']?.toString() ??
          (json['first_name'] != null && json['last_name'] != null
              ? '${json['first_name']} ${json['last_name']}'.trim()
              : null),
    );
  }

  static String? _buildDisplayName(String? first, String? last) {
    final parts = [first, last].where((e) => e != null && e.isNotEmpty);
    return parts.isEmpty ? null : parts.join(' ');
  }

  @override
  List<Object?> get props => [id, email, firstName, lastName, displayName];
}