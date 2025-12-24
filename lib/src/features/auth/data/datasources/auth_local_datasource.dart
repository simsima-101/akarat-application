// lib/src/features/auth/data/datasources/auth_local_datasource.dart

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart'; // Make sure CacheException exists

enum LoginMethod {
  password,
  google,
}

/// Local data source for all authentication-related persistent storage:
/// - Last used login method (password or google)
/// - Cached first/last name override (by email)
/// - Persistent user display name and email (used across app restarts)
abstract class AuthLocalDataSource {
  // Login method
  Future<void> cacheLoginMethod(LoginMethod method);
  Future<LoginMethod?> getLoginMethod();

  // Profile name override cache (first/last by email)
  Future<void> cacheProfileName({
    required String email,
    required String firstName,
    required String lastName,
  });
  Future<({String first, String last})?> getCachedProfileName(String email);

  // Persistent profile (display name + email)
  Future<void> savePersistentProfile({
    required String displayName,
    required String email,
  });
  Future<String?> getPersistentDisplayName();
  Future<String?> getPersistentEmail();
  Future<void> clearPersistentProfile();

  // Clear everything auth-related
  Future<void> clearAll();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  // Keys
  static const _kLoginMethod = 'login_method';
  static const _kPersistentName = 'user_name';     // From ProfileStorage
  static const _kPersistentEmail = 'user_email';   // From ProfileStorage
  static String _kProfileOverride(String email) => 'profile_override::${email.toLowerCase()}';

  // ===================================================================
  // Login Method
  // ===================================================================
  @override
  Future<void> cacheLoginMethod(LoginMethod method) async {
    try {
      await sharedPreferences.setString(_kLoginMethod, method.name);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<LoginMethod?> getLoginMethod() async {
    try {
      final value = sharedPreferences.getString(_kLoginMethod);
      if (value == LoginMethod.password.name) return LoginMethod.password;
      if (value == LoginMethod.google.name) return LoginMethod.google;
      return null;
    } catch (e) {
      throw CacheException();
    }
  }

  // ===================================================================
  // Profile Name Override Cache (first/last by email)
  // ===================================================================
  @override
  Future<void> cacheProfileName({
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    if (email.isEmpty) return;

    try {
      final payload = {
        'first': firstName,
        'last': lastName,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await sharedPreferences.setString(
        _kProfileOverride(email),
        jsonEncode(payload),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<({String first, String last})?> getCachedProfileName(String email) async {
    if (email.isEmpty) return null;

    try {
      final raw = sharedPreferences.getString(_kProfileOverride(email));
      if (raw == null || raw.isEmpty) return null;

      final m = jsonDecode(raw) as Map<String, dynamic>;
      return (
      first: (m['first'] ?? '').toString(),
      last: (m['last'] ?? '').toString(),
      );
    } catch (e) {
      return null;
    }
  }

  // ===================================================================
  // Persistent Profile (display name + email)
  // ===================================================================
  @override
  Future<void> savePersistentProfile({
    required String displayName,
    required String email,
  }) async {
    try {
      await sharedPreferences.setString(_kPersistentName, displayName.trim());
      await sharedPreferences.setString(_kPersistentEmail, email.trim());
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<String?> getPersistentDisplayName() async {
    try {
      return sharedPreferences.getString(_kPersistentName);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<String?> getPersistentEmail() async {
    try {
      return sharedPreferences.getString(_kPersistentEmail);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> clearPersistentProfile() async {
    try {
      await sharedPreferences.remove(_kPersistentName);
      await sharedPreferences.remove(_kPersistentEmail);
    } catch (e) {
      throw CacheException();
    }
  }

  // ===================================================================
  // Clear All Auth Data
  // ===================================================================
  @override
  Future<void> clearAll() async {
    try {
      // Clear login method
      await sharedPreferences.remove(_kLoginMethod);

      // Clear persistent profile
      await sharedPreferences.remove(_kPersistentName);
      await sharedPreferences.remove(_kPersistentEmail);

      // Clear all profile override caches
      final keys = sharedPreferences.getKeys();
      for (final key in keys) {
        if (key.startsWith('profile_override::')) {
          await sharedPreferences.remove(key);
        }
      }
    } catch (e) {
      throw CacheException();
    }
  }

  // Optional: specific clears
  Future<void> clearLoginMethod() async {
    try {
      await sharedPreferences.remove(_kLoginMethod);
    } catch (e) {
      throw CacheException();
    }
  }

  Future<void> clearProfileOverride(String email) async {
    if (email.isEmpty) return;
    try {
      await sharedPreferences.remove(_kProfileOverride(email));
    } catch (e) {
      throw CacheException();
    }
  }
}