// lib/secure_storage.dart
// Token-only facade (no PII persisted). Backward-compatible method names.

import 'package:flutter/foundation.dart';
import 'secure_storage_token.dart'; // must provide AuthStorage.{saveToken,readToken,clear}()

class SecureStorage {
  // =========================
  // AUTH TOKEN (real storage)
  // =========================
  static Future<String?> getToken() => AuthStorage.readToken();

  static Future<void> setToken(String token) async {
    final t = token.trim();
    if (t.isEmpty) {
      await deleteToken();
    } else {
      await AuthStorage.saveToken(t);
    }
  }

  static Future<void> deleteToken() async {
    await AuthStorage.clear();
  }

  // Legacy aliases (do not remove if older code calls these)
  static Future<void> saveToken(String token) => setToken(token);
  static Future<void> writeToken(String token) => setToken(token);

  static Future<bool> isLoggedIn() async {
    final t = await getToken();
    return (t != null && t.trim().isNotEmpty);
  }

  static Future<void> signOutLocal() => deleteToken();

  // ==========================================
  // Generic key-value API (NO-OPs by design)
  // ==========================================
  static Future<String?> read(String key) async {
    _warn('read("$key")');
    return null;
  }

  static Future<void> write(String key, String value) async {
    _warn('write("$key", "...")');
  }

  static Future<void> delete(String key) async {
    _warn('delete("$key")');
  }

  // ==========================================
  // Deprecated PII helpers (true NO-OPs)
  // Keep these to avoid breaking older call sites.
  // ==========================================
  @deprecated
  static Future<void> setUserProfile({
    required String name,
    required String email,
    String? firstName,
    String? lastName,
  }) async {
    // Intentionally not storing PII locally.
    _warn('setUserProfile(name:"$name", email:"$email")');
  }

  @deprecated
  static Future<void> clearProfile() async {
    _warn('clearProfile');
  }

  @deprecated
  static Future<String?> getUserName() async {
    _warn('getUserName');
    return null;
  }

  @deprecated
  static Future<String?> getUserEmail() async {
    _warn('getUserEmail');
    return null;
  }

  @deprecated
  static Future<String?> getUserImage() async {
    _warn('getUserImage');
    return null;
  }

  @deprecated
  static Future<void> setFirstName(String first) async {
    _warn('setFirstName("$first")');
  }

  @deprecated
  static Future<void> setLastName(String last) async {
    _warn('setLastName("$last")');
  }

  @deprecated
  static Future<String?> getFirstName() async {
    _warn('getFirstName');
    return null;
  }

  @deprecated
  static Future<String?> getLastName() async {
    _warn('getLastName');
    return null;
  }

  @deprecated
  static Future<void> setDraftNameEmail({
    required String first,
    required String last,
    required String email,
  }) async {
    _warn('setDraftNameEmail(first:"$first", last:"$last", email:"$email")');
  }

  @deprecated
  static Future<void> setFirstLastLoose({
    required String first,
    required String last,
  }) async {
    _warn('setFirstLastLoose(first:"$first", last:"$last")');
  }

  // ===== debug helper =====
  static void _warn(String method) {
    if (kDebugMode) {
      debugPrint('⚠️ SecureStorage.$method is a NO-OP (PII not stored locally).');
    }
  }
}
