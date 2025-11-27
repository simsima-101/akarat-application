// lib/services/account_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../screen/login.dart';
import '../secure_storage.dart';
import '../services/api_service.dart';
import '../services/session.dart';

class AccountService {
  /// Show confirmation dialog before deleting account
  static Future<bool> confirmAndDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account Permanently?'),
        content: const Text(
          'This action cannot be undone. All your data, saved properties, and account will be permanently deleted.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    return await deleteAccount(context);
  }

  /// Perform actual account deletion
  static Future<bool> deleteAccount(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final token = await SecureStorage.getToken();
      if (token == null || token.isEmpty) {
        messenger.showSnackBar(const SnackBar(content: Text('You are not logged in')));
        _navigateToLogin(context);
        return false;
      }

      final base = ApiService.baseUrl;
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
          // Try DELETE first
          response = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 20));

          // If DELETE not allowed → try POST
          if (response.statusCode == 404 || response.statusCode == 405) {
            response = await http.post(uri, headers: headers, body: jsonEncode({'confirm': true}));
          }

          if (response.statusCode case 200 || 201 || 202 || 204 || 205) {
            // Success!
            await _performFullLogout(context);
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Account deleted successfully'),
                backgroundColor: Colors.red,
              ),
            );
            return true;
          }
        } catch (_) {
          continue; // try next endpoint
        }
      }

      // If we get here → all attempts failed
      final msg = _extractErrorMessage(response);
      messenger.showSnackBar(SnackBar(content: Text(msg)));
      return false;

    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Network error: $e')));
      return false;
    }
  }

  // Extract readable error from response
  static String _extractErrorMessage(http.Response? response) {
    if (response == null) return 'No response from server';

    try {
      final json = jsonDecode(response.body);
      return json['message'] ?? json['error'] ?? 'Delete failed (${response.statusCode})';
    } catch (_) {
      return 'Server error (${response.statusCode})';
    }
  }

  // Full logout: clear everything locally
  static Future<void> _performFullLogout(BuildContext context) async {
    // These return void → DO NOT await them in a way that expects a value
    Session().clear();           // Fire and forget
    SecureStorage.deleteAll();   // Fire and forget

    _navigateToLogin(context);
  }

  // Go to login screen and remove all routes
  static void _navigateToLogin(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginDemo()),
            (_) => false,
      );
    });
  }
}