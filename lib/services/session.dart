// lib/session.dart
//
// Tiny auth/session singleton with storage sync.
// - Holds token/name/email/first/last in memory (fast reads for UI)
// - Hydrates from SecureStorage on app start or resume
// - Writes back to SecureStorage whenever auth/profile changes
//
// Usage:
//   await Session().hydrate(); // app start
//   Session().isAuthenticated;
//   Session().setAuth(token: t, userName: 'Anand Alleppey', userEmail: '...');
//   Session().updateProfile(firstName: 'Anand', lastName: 'Alleppey');
//   await Session().signOut(); // clears storage + memory
//
import 'package:flutter/foundation.dart';

import '../secure_storage.dart';


class Session {
  // ---- Singleton ----
  Session._();
  static final Session _i = Session._();
  factory Session() => _i;

  // ---- Private state ----
  String? _token;
  String? _userName;   // preferred display name (full)
  String? _userEmail;
  String? _firstName;
  String? _lastName;

  // ---- Getters for UI ----
  bool get isAuthenticated => (_token ?? '').trim().isNotEmpty;
  String? get token => _token;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get firstName => _firstName;
  String? get lastName  => _lastName;

  // ---------- Hydration ----------
  /// Pull the latest token/profile from SecureStorage into memory.
  /// Note: In your setup, PII reads are NO-OP and return null; names should be
  /// provided via setAuth() after login/OTP, or via /me then updateProfile().
  Future<void> hydrate() async {
    final t   = await SecureStorage.getToken();
    final nm  = (await SecureStorage.getUserName())?.trim();
    final em  = (await SecureStorage.getUserEmail())?.trim();

    _token     = (t ?? '').trim().isNotEmpty ? t : null;
    _userName  = (nm ?? '').isNotEmpty ? nm : null;
    _userEmail = (em ?? '').isNotEmpty ? em : null;

    // Best-effort first/last derivation if only full name exists.
    if ((_firstName == null && _lastName == null) &&
        (_userName ?? '').toString().trim().isNotEmpty) {
      final parts = _userName!.trim().split(RegExp(r'\s+'));
      _firstName = parts.isNotEmpty ? parts.first : '';
      _lastName  = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    if (kDebugMode) {
      debugPrint(
        'Session.hydrate → token=${isAuthenticated ? 'yes' : 'no'} '
            'name=$_userName email=$_userEmail',
      );
    }
  }

  // ---------- Auth set/clear ----------
  /// Call right after a successful login (email/pwd or Google) or OTP verify.
  /// Automatically persists token; name/email persisted via NO-OP facade (safe).
  Future<void> setAuth({
    required String token,
    String? userName,
    String? userEmail,
    String? firstName,
    String? lastName,
  }) async {
    _token = token.trim();
    if ((userName ?? '').trim().isNotEmpty)  _userName  = userName!.trim();
    if ((userEmail ?? '').trim().isNotEmpty) _userEmail = userEmail!.trim();
    if ((firstName ?? '').trim().isNotEmpty) _firstName = firstName!.trim();
    if ((lastName ?? '').trim().isNotEmpty)  _lastName  = lastName!.trim();

    // Derive first/last if only full name is known
    if ((_firstName == null || _firstName!.isEmpty) &&
        (_lastName == null  || _lastName!.isEmpty) &&
        (_userName ?? '').toString().trim().isNotEmpty) {
      final parts = _userName!.trim().split(RegExp(r'\s+'));
      _firstName = parts.isNotEmpty ? parts.first : '';
      _lastName  = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    // Persist token
    await SecureStorage.setToken(_token!);

    // Persist name/email through facade (NO-OP for PII; keeps legacy calls safe)
    await SecureStorage.setUserProfile(
      name : _userName ?? _joinName(_firstName, _lastName),
      email: _userEmail ?? '',
      // NOTE: no `image:` arg here — your SecureStorage.setUserProfile has no image param
    );
  }

  /// Clears storage + memory (use on logout or account deletion).
  Future<void> signOut() async {
    await SecureStorage.signOutLocal(); // clears token (and profile in your implementation)
    await SecureStorage.clearProfile(); // defensive (NO-OP in your facade)
    clear();                            // memory
  }

  /// Memory-only clear (rarely needed).
  void clear() {
    _token = null;
    _userName = null;
    _userEmail = null;
    _firstName = null;
    _lastName = null;
  }

  // ---------- Profile updates ----------
  /// Call after saving profile (/update) or after fetching /me.
  /// Automatically persists via SecureStorage facade (NO-OP for PII).
  Future<void> updateProfile({
    String? userName,
    String? userEmail,
    String? firstName,
    String? lastName,
  }) async {
    if ((userName ?? '').trim().isNotEmpty)  _userName  = userName!.trim();
    if ((userEmail ?? '').trim().isNotEmpty) _userEmail = userEmail!.trim();
    if ((firstName ?? '').trim().isNotEmpty) _firstName = firstName!.trim();
    if ((lastName ?? '').trim().isNotEmpty)  _lastName  = lastName!.trim();

    final finalName = _userName ?? _joinName(_firstName, _lastName);
    await SecureStorage.setUserProfile(
      name : finalName,
      email: _userEmail ?? '',
      // NOTE: no `image:` arg here either
    );
  }

  // ---------- Helpers ----------
  String _joinName(String? f, String? l) {
    final fn = (f ?? '').trim();
    final ln = (l ?? '').trim();
    return [fn, ln].where((s) => s.isNotEmpty).join(' ').trim();
  }
}
