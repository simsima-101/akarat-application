// lib/src/features/auth/data/repositories/auth_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/constants.dart' as ApiService;
import '../models/user_model.dart'; // ← create this model if not already exists

class AuthRepository {
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/login'), // ← change to your real login endpoint
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);

        // Adjust according to your real API response structure
        final user = UserModel.fromJson(json['user'] ?? json['data']['user']);
        final token = json['token'] ?? json['access_token'] ?? json['data']['token'];

        return LoginResponse(user: user, token: token);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error during login: $e');
    }
  }

// Optional: Add register, forgot password, etc. later
}

// Simple response wrapper class (you can also use a tuple or record)
class LoginResponse {
  final UserModel user;
  final String token;

  LoginResponse({required this.user, required this.token});
}