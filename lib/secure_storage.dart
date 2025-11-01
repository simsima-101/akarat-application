// lib/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Centralized, safe storage for auth + profile.
/// - Keeps token and profile in sync
/// - Clears cached profile when token is removed (prevents ghost user)
/// - Backward-compatible with older token helpers
class SecureStorage {
  // ===== Platform-specific options =====
  static const _aOpts = AndroidOptions(
    encryptedSharedPreferences: true, // hardware-backed when available
    resetOnError: true,
  );
  static const _iOpts = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  static final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: _aOpts,
    iOptions: _iOpts,
  );

  // ===== Keys (do not change without a data migration) =====
  static const String _kToken     = 'token';
  static const String _kUserName  = 'user_name';
  static const String _kUserEmail = 'user_email';
  static const String _kUserImage = 'user_image';

  // ===== Generic helpers (still available if you need them) =====
  static Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  static Future<String?> read(String key) =>
      _storage.read(key: key);

  static Future<void> delete(String key) =>
      _storage.delete(key: key);

  static Future<void> deleteAll() =>
      _storage.deleteAll();

  // ===== Token helpers =====
  static Future<String?> getToken() => _storage.read(key: _kToken);

  /// Sets token. If empty/blank, removes token and clears profile to avoid ghost user.
  static Future<void> setToken(String token) async {
    final t = token.trim();
    if (t.isEmpty) {
      await deleteToken();
    } else {
      await _storage.write(key: _kToken, value: t);
    }
  }

  /// Deletes token **and** clears profile.
  static Future<void> deleteToken() async {
    await _storage.delete(key: _kToken);
    await clearProfile(); // keep state consistent
  }

  // Backward-compat aliases (keep old code working)
  static Future<void> saveToken(String token) => setToken(token);
  static Future<void> writeToken(String token) => setToken(token);

  // ===== Profile helpers =====
  /// Persist profile only if a valid token exists and email is non-empty.
  static Future<void> setUserProfile({
    required String name,
    required String email,
    String? image,
  }) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      await clearProfile();
      return;
    }

    final n = name.trim();
    final e = email.trim();
    final img = (image ?? '').trim();

    if (e.isEmpty) {
      // No valid identity → clear to avoid showing stale user UI
      await clearProfile();
      return;
    }

    await _storage.write(key: _kUserName,  value: n);
    await _storage.write(key: _kUserEmail, value: e);
    if (img.isNotEmpty) {
      await _storage.write(key: _kUserImage, value: img);
    } else {
      await _storage.delete(key: _kUserImage);
    }
  }

  static Future<String?> getUserName()  => _storage.read(key: _kUserName);
  static Future<String?> getUserEmail() => _storage.read(key: _kUserEmail);
  static Future<String?> getUserImage() => _storage.read(key: _kUserImage);

  static Future<void> clearProfile() async {
    await _storage.delete(key: _kUserName);
    await _storage.delete(key: _kUserEmail);
    await _storage.delete(key: _kUserImage);
  }

  /// Considered "logged in" only if there's a token AND a non-empty email cached.
  static Future<bool> isLoggedIn() async {
    final t = await getToken();
    if (t == null || t.isEmpty) return false;
    final email = (await getUserEmail())?.trim() ?? '';
    return email.isNotEmpty;
  }

  /// One-shot local sign-out (no network): clears token + profile.
  static Future<void> signOutLocal() async {
    await deleteToken(); // also clears profile
  }
}
