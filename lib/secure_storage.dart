// lib/secure_storage.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // Private storage instance
  static final _storage = const FlutterSecureStorage();

  // ========================================
  // AUTH TOKEN
  // ========================================
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token.trim());
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'token');
  }

  // ========================================
  // USER PROFILE (Name, Email, First/Last)
  // ========================================
  static Future<void> saveUserName(String name) async {
    await _storage.write(key: 'user_name', value: name.trim());
  }

  static Future<String?> getUserName() async {
    return await _storage.read(key: 'user_name');
  }

  static Future<void> saveUserEmail(String email) async {
    await _storage.write(key: 'user_email', value: email.trim().toLowerCase());
  }

  static Future<String?> getUserEmail() async {
    return await _storage.read(key: 'user_email');
  }

  static Future<void> saveFirstName(String name) async {
    await _storage.write(key: 'first_name', value: name.trim());
  }

  static Future<String?> getFirstName() async {
    return await _storage.read(key: 'first_name');
  }

  static Future<void> saveLastName(String name) async {
    await _storage.write(key: 'last_name', value: name.trim());
  }

  static Future<String?> getLastName() async {
    return await _storage.read(key: 'last_name');
  }

  // ========================================
  // BACKWARD COMPATIBILITY (Legacy Methods)
  // Keep these so old code doesn't crash
  // ========================================
  @Deprecated('Use saveToken() instead')
  static Future<void> setToken(String token) => saveToken(token);

  @Deprecated('Use saveUserName() + saveUserEmail() instead')
  static Future<void> setUserProfile({
    required String name,
    required String email,
    String? firstName,
    String? lastName,
  }) async {
    await saveUserName(name);
    await saveUserEmail(email);
    if (firstName != null) await saveFirstName(firstName);
    if (lastName != null) await saveLastName(lastName);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ========================================
  // LOGOUT & CLEANUP
  // ========================================
  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  static Future<void> signOutLocal() async {
    await deleteAll();
  }

  // Optional: Debug helper (only in debug mode)
  static void debugPrintAll() async {
    if (!kDebugMode) return;
    final all = await _storage.readAll();
    debugPrint('SecureStorage contents: $all');
  }
}