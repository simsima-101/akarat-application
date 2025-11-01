import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../screen/login.dart';
import '../secure_storage.dart';
import '../services/api_service.dart';


class AccountService {
  /// Shows a confirm dialog and, if confirmed, deletes the account.
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

  /// Performs the API call + local sign-out + navigation to Login.
  static Future<bool> deleteAccount(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final token = await SecureStorage.getToken();
      if (token == null || token.isEmpty) {
        messenger.showSnackBar(const SnackBar(content: Text('You are not logged in')));
        _goLogin(context);
        return false;
      }

      final base = ApiService.baseUrl; // e.g. http://127.0.0.1:8021/api or https://akarat.com/api
      final del  = Uri.parse('$base/delete');      // DELETE /api/delete
      final me   = Uri.parse('$base/me');          // sanity check

      final headers = <String, String>{
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'X-Requested-With': 'XMLHttpRequest',
      };
      final body = jsonEncode(<String, dynamic>{ 'token': token });

      http.Response resp;
      try {
        final rq = http.Request('DELETE', del)
          ..headers.addAll(headers)
          ..body = body;
        final streamed = await rq.send().timeout(const Duration(seconds: 20));
        resp = await http.Response.fromStream(streamed);
      } on TimeoutException {
        await _signOutLocalOnly();
        _goLogin(context);
        return false;
      }

      // treat these as OK
      final ok = <int>{200, 202, 204, 205, 302, 307}.contains(resp.statusCode);
      if (ok) {
        // optional: verify token invalidated
        bool looksDeleted = true;
        try {
          final meResp = await http.get(me, headers: headers).timeout(const Duration(seconds: 6));
          looksDeleted = (meResp.statusCode == 401 || meResp.statusCode == 403 || meResp.statusCode == 404);
        } catch (_) {}

        await _signOutLocalOnly();
        messenger.showSnackBar(SnackBar(
          content: Text(looksDeleted
              ? 'Account deleted successfully'
              : 'Deleted (signed out), but server still shows active.'),
        ));
        _goLogin(context);
        return true;
      }

      if (resp.statusCode == 401 || resp.statusCode == 403) {
        await _signOutLocalOnly();
        messenger.showSnackBar(
          SnackBar(content: Text('Session expired (${resp.statusCode}). Please log in again.')),
        );
        _goLogin(context);
        return false;
      }

      // Other errors
      String msg = 'Delete failed (${resp.statusCode}).';
      try {
        final m = json.decode(resp.body);
        final s = (m['message'] ?? m['error'] ?? '').toString().trim();
        if (s.isNotEmpty) msg = s;
      } catch (_) {}
      messenger.showSnackBar(SnackBar(content: Text(msg)));
      return false;
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      return false;
    }
  }

  // ---- helpers ----
  static Future<void> _signOutLocalOnly() async {
    await SecureStorage.deleteToken();
    await SecureStorage.delete('user_name');
    await SecureStorage.delete('user_email');
    await SecureStorage.delete('user_image');
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
