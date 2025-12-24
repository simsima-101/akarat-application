import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileCache {
  // We key by email; if you have stable userId, prefer that.
  static String _k(String email) => 'profile_override::$email';

  static Future<void> save({
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    if (email.isEmpty) return;
    final sp = await SharedPreferences.getInstance();
    final payload = {
      'first': firstName,
      'last': lastName,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await sp.setString(_k(email.toLowerCase()), jsonEncode(payload));
  }

  static Future<({String first, String last})?> load(String email) async {
    if (email.isEmpty) return null;
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_k(email.toLowerCase()));
    if (raw == null || raw.isEmpty) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return (first: (m['first'] ?? '').toString(), last: (m['last'] ?? '').toString());
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear(String email) async {
    if (email.isEmpty) return;
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_k(email.toLowerCase()));
  }
}