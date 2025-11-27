// lib/services/session.dart
import 'package:flutter/foundation.dart';
import '../secure_storage.dart';

class Session {
  static final Session _instance = Session._internal();
  factory Session() => _instance;
  Session._internal();

  // In-memory session data
  String? _token;
  String? _userName;
  String? _userEmail;
  String? _firstName;
  String? _lastName;

  // Getters
  String? get token => _token;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get firstName => _firstName;
  String? get lastName => _lastName;

  bool get isAuthenticated => _token != null && _token!.trim().isNotEmpty;

  /// Restore full session from SecureStorage (call this on app start!)
  Future<void> restore() async {
    // Prevent double restore
    if (_token != null && _token!.isNotEmpty) return;

    try {
      final token = await SecureStorage.getToken();
      final name = await SecureStorage.getUserName();
      final email = await SecureStorage.getUserEmail();
      final first = await SecureStorage.getFirstName();
      final last = await SecureStorage.getLastName();

      if (token != null && token.trim().isNotEmpty) {
        _token = token.trim();
        _userName = name?.trim().isNotEmpty == true ? name!.trim() : 'User';
        _userEmail = email?.trim().isNotEmpty == true ? email!.trim() : '';
        _firstName = first?.trim().isNotEmpty == true ? first!.trim() : '';
        _lastName = last?.trim().isNotEmpty == true ? last!.trim() : '';

        // Auto-split name if first/last are missing
        if ((_firstName == null || _firstName!.isEmpty) &&
            (_lastName == null || _lastName!.isEmpty) &&
            _userName != null && _userName != 'User') {
          final parts = _userName!.split(RegExp(r'\s+'));
          _firstName = parts.isNotEmpty ? parts.first : '';
          _lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
        }

        if (kDebugMode) {
          debugPrint('Session restored: $_userName ($_userEmail)');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Session restore failed: $e');
    }
  }

  /// Set authentication data + save to SecureStorage
  Future<void> setAuth({
    required String token,
    required String userName,
    String? userEmail,
    String? firstName,
    String? lastName,
  }) async {
    _token = token.trim();
    _userName = userName.trim().isNotEmpty ? userName.trim() : 'User';
    _userEmail = userEmail?.trim().isNotEmpty == true ? userEmail!.trim() : null;
    _firstName = firstName?.trim().isNotEmpty == true ? firstName!.trim() : null;
    _lastName = lastName?.trim().isNotEmpty == true ? lastName!.trim() : null;

    // Auto-split if needed
    if ((_firstName == null || _firstName!.isEmpty) &&
        (_lastName == null || _lastName!.isEmpty) &&
        _userName != 'User') {
      final parts = _userName!.split(RegExp(r'\s+'));
      _firstName = parts.isNotEmpty ? parts.first : '';
      _lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    // Save everything to SecureStorage
    await Future.wait([
      SecureStorage.saveToken(_token!),
      SecureStorage.saveUserName(_userName!),
      if (_userEmail != null) SecureStorage.saveUserEmail(_userEmail!),
      if (_firstName != null) SecureStorage.saveFirstName(_firstName!),
      if (_lastName != null) SecureStorage.saveLastName(_lastName!),
    ]);

    if (kDebugMode) {
      debugPrint('Session saved: $_userName ($_userEmail)');
    }
  }

  /// Update profile (e.g. after editing name/email)
  Future<void> updateProfile({
    String? userName,
    String? userEmail,
    String? firstName,
    String? lastName,
  }) async {
    if (userName?.trim().isNotEmpty == true) {
      _userName = userName!.trim();
    }
    if (userEmail?.trim().isNotEmpty == true) {
      _userEmail = userEmail!.trim();
    }
    if (firstName?.trim().isNotEmpty == true) {
      _firstName = firstName!.trim();
    }
    if (lastName?.trim().isNotEmpty == true) {
      _lastName = lastName!.trim();
    }

    // Rebuild full name if needed
    if (_userName == null || _userName!.isEmpty || _userName == 'User') {
      _userName = [_firstName ?? '', _lastName ?? ''].where((s) => s.isNotEmpty).join(' ');
      if (_userName!.isEmpty) _userName = 'User';
    }

    // Save updated data
    await Future.wait([
      SecureStorage.saveUserName(_userName!),
      if (_userEmail != null) SecureStorage.saveUserEmail(_userEmail!),
      if (_firstName != null) SecureStorage.saveFirstName(_firstName!),
      if (_lastName != null) SecureStorage.saveLastName(_lastName!),
    ]);

    if (kDebugMode) debugPrint('Profile updated: $_userName');
  }

  /// Full logout — clear everything
  Future<void> signOut() async {
    await SecureStorage.deleteAll();
    clear();
  }

  /// Clear in-memory session only
  void clear() {
    _token = null;
    _userName = null;
    _userEmail = null;
    _firstName = null;
    _lastName = null;
  }
}