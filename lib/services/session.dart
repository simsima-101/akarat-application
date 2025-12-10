// lib/services/session.dart
import 'package:Akarat/services/profile_cache.dart';
import 'package:flutter/foundation.dart';
import '../secure_storage.dart';
import 'api_service.dart';

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

        // Auto-split name if first/last missing
        if ((_firstName == null || _firstName!.isEmpty) &&
            (_lastName == null || _lastName!.isEmpty) &&
            _userName != null && _userName != 'User') {
          final parts = _userName!.split(RegExp(r'\s+'));
          _firstName = parts.isNotEmpty ? parts.first : '';
          _lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
        }

        if (kDebugMode) {
          debugPrint('SESSION RESTORED');
          debugPrint('   → Name:  $_userName');
          debugPrint('   → Email: $_userEmail');
          debugPrint('   → First: $_firstName | Last: $_lastName');
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

    if ((_firstName == null || _firstName!.isEmpty) &&
        (_lastName == null || _lastName!.isEmpty) &&
        _userName != 'User') {
      final parts = _userName!.split(RegExp(r'\s+'));
      _firstName = parts.isNotEmpty ? parts.first : '';
      _lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    await Future.wait([
      SecureStorage.saveToken(_token!),
      SecureStorage.saveUserName(_userName!),
      if (_userEmail != null) SecureStorage.saveUserEmail(_userEmail!),
      if (_firstName != null) SecureStorage.saveFirstName(_firstName!),
      if (_lastName != null) SecureStorage.saveLastName(_lastName!),
    ]);

    if (kDebugMode) {
      debugPrint('SESSION SET (LOGIN)');
      debugPrint('   → Full Name:  $_userName');
      debugPrint('   → Email:      $_userEmail');
      debugPrint('   → First:      $_firstName | Last: $_lastName');
    }
  }

  /// THIS IS THE MOST IMPORTANT METHOD — REFRESH PROFILE FROM SERVER
  Future<void> refreshProfileFromServer() async {
    final token = this.token;
    if (token == null || token.isEmpty) return;

    try {
      final me = await ApiService.tryFetchMe(token);
      if (me == null) {
        if (kDebugMode) debugPrint('refreshProfileFromServer: tryFetchMe returned null');
        return;
      }

      final rawFirst = me.first.trim();
      final rawLast = me.last.trim();
      final rawEmail = me.email.trim();

      final fullName = [rawFirst, rawLast].where((s) => s.isNotEmpty).join(' ');
      final nameToSave = fullName.isEmpty ? 'User' : fullName;

      // UPDATE IN-MEMORY
      _userName = nameToSave;
      _userEmail = rawEmail;
      _firstName = rawFirst;
      _lastName = rawLast;

      // SAVE TO SECURE STORAGE
      await Future.wait([
        SecureStorage.saveUserName(nameToSave),
        SecureStorage.saveUserEmail(rawEmail),
        SecureStorage.saveFirstName(rawFirst),
        SecureStorage.saveLastName(rawLast),
      ]);

      // UPDATE CACHE
      await ProfileCache.save(
        email: rawEmail,
        firstName: rawFirst,
        lastName: rawLast,
      );

      // FINAL DEBUG LOG — THIS TELLS YOU EXACTLY WHAT THE SERVER SENT
      if (kDebugMode) {
        debugPrint('PROFILE REFRESHED FROM SERVER');
        debugPrint('   → Server sent → First: "$rawFirst" | Last: "$rawLast" | Email: "$rawEmail"');
        debugPrint('   → Saved as   → Full Name: "$nameToSave" | Email: "$rawEmail"');
        debugPrint('   → Final in-memory → Name: "$_userName" | Email: "$_userEmail"');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('refreshProfileFromServer FAILED: $e');
        debugPrint('Stack: $stack');
      }
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
    // if (lastName?.trim().isNotEmpty == true) {
    _lastName = lastName!.trim();
    // }

    // Rebuild full name if needed
    if (_userName == null || _userName!.isEmpty || _userName == 'User') {
      _userName = [_firstName ?? '', _lastName ?? '']
          .where((s) => s.isNotEmpty)
          .join(' ');
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

  /// Full logout
  Future<void> signOut() async {
    await SecureStorage.deleteAll();
    clear();
    if (kDebugMode) debugPrint('USER SIGNED OUT – Session cleared');
  }

  /// Clear in-memory only
  void clear() {
    _token = null;
    _userName = null;
    _userEmail = null;
    _firstName = null;
    _lastName = null;
  }
}