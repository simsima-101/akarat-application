// lib/services/profile_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class ProfileStorage {
  static const String _keyName = 'user_name';
  static const String _keyEmail = 'user_email';

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  static Future<void> saveProfile({
    required String name,
    required String email,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(_keyName, name.trim());
    await prefs.setString(_keyEmail, email.trim());
  }

  static Future<String?> getName() async {
    final prefs = await _prefs;
    return prefs.getString(_keyName);
  }

  static Future<String?> getEmail() async {
    final prefs = await _prefs;
    return prefs.getString(_keyEmail);
  }

  static Future<void> clearProfile() async {
    final prefs = await _prefs;
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
  }
}