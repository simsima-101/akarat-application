// lib/services/account_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../screen/login.dart';
import '../secure_storage.dart';
import '../services/api_service.dart';

class AccountService {
  /// Ask for confirmation, then delete.
  static Future<bool> confirmAndDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      return deleteAccount(context);
    }
    return false;
  }

  /// Delete account on the backend, clear local session, then go to Login.
  static Future<bool> deleteAccount(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final token = await SecureStorage.getToken();
      if (token == null || token.isEmpty) {
        if (context.mounted) {
          messenger.showSnackBar(const SnackBar(content: Text('You are not logged in')));
          _goLogin(context);
        }
        return false;
      }

      final String base = ApiService.baseUrl; // e.g. https://qa.akarat.com/api
      final Uri primary   = Uri.parse('$base/delete');           // preferred
      final Uri secondary = Uri.parse('$base/delete-account');   // fallback

      final headers = <String, String>{
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Requested-With': 'XMLHttpRequest',
      };
      final body = jsonEncode(<String, dynamic>{'token': token});

      http.Response resp;

      // 1) Try DELETE /delete
      try {
        final rq = http.Request('DELETE', primary)
          ..headers.addAll(headers)
          ..body = body;
        final streamed = await rq.send().timeout(const Duration(seconds: 20));
        resp = await http.Response.fromStream(streamed);
      } on TimeoutException {
        // Treat timeouts as "unknown" but sign out locally to prevent ghost sessions.
        await _signOutLocalOnly();
        if (context.mounted) _goLogin(context);
        return false;
      }

      // 2) If method not allowed or not found, try POST /delete or DELETE /delete-account
      if (resp.statusCode == 404 || resp.statusCode == 405) {
        final postResp = await http
            .post(primary, headers: headers, body: body)
            .timeout(const Duration(seconds: 20));

        if (postResp.statusCode >= 200 && postResp.statusCode < 300) {
          resp = postResp;
        } else {
          final del2 = await http
              .delete(secondary, headers: headers)
              .timeout(const Duration(seconds: 20));
          resp = del2;
        }
      }

      // 3) Handle results
      final okCodes = <int>{200, 202, 204, 205, 302, 307};
      if (okCodes.contains(resp.statusCode)) {
        await _signOutLocalOnly();
        if (context.mounted) {
          messenger.showSnackBar(const SnackBar(content: Text('Account deleted successfully')));
          _goLogin(context);
        }
        return true;
      }

      if (resp.statusCode == 401 || resp.statusCode == 403) {
        await _signOutLocalOnly();
        if (context.mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text('Session expired (${resp.statusCode}). Please log in again.')),
          );
          _goLogin(context);
        }
        return false;
      }

      // Other errors → show server message if present
      String msg = 'Delete failed (${resp.statusCode}).';
      try {
        final m = json.decode(resp.body);
        final s = (m['message'] ?? m['error'] ?? '').toString().trim();
        if (s.isNotEmpty) msg = s;
      } catch (_) {}

      if (context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text(msg)));
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
      return false;
    }
  }

  // ---- local helpers ----

  /// Clear only local credentials/profile; does not call the server.
  static Future<void> _signOutLocalOnly() async {
    // Token is real; the following key deletes are NO-OPs in SecureStorage (by design).
    await SecureStorage.deleteToken();
    await SecureStorage.delete('user_name');
    await SecureStorage.delete('user_email');
    await SecureStorage.delete('user_image');
    await SecureStorage.delete('user_first_name');
    await SecureStorage.delete('user_last_name');
    await SecureStorage.delete('email_verified_for');
    await SecureStorage.delete('email_verified_at');
  }

  static void _goLogin(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginDemo()),
            (_) => false,
      );
    });
  }
}
