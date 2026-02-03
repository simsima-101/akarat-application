// lib/src/core/utils/session_manager.dart

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart'; // Core shared API service
import 'secure_storage.dart'; // Adjust path if needed

/// Singleton in-memory session manager
/// Holds current user session data during app runtime
/// Restores from SecureStorage on app start
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  // In-memory session data
  String? _token;
  String? _userName;
  String? _userEmail;
  String? _firstName;
  String? _lastName;

  // Getters
  String? get token => _token;
  String? get userName => _userName ?? 'User';
  String? get userEmail => _userEmail;
  String? get firstName => _firstName;
  String? get lastName => _lastName;

  bool get isAuthenticated => _token != null && _token!.trim().isNotEmpty;

  /// Restore session from SecureStorage (call this on app startup!)
  Future<void> restore() async {
    if (isAuthenticated) return; // Already restored

    try {
      final token = await SecureStorage.getToken();
      final name = await SecureStorage.getUserName();
      final email = await SecureStorage.getUserEmail();
      final first = await SecureStorage.getFirstName();
      final last = await SecureStorage.getLastName();

      if (token != null && token.trim().isNotEmpty) {
        _token = token.trim();
        _userName = name?.trim().isNotEmpty == true ? name!.trim() : 'User';
        _userEmail = email?.trim().isNotEmpty == true ? email!.trim() : null;
        _firstName = first?.trim().isNotEmpty == true ? first!.trim() : null;
        _lastName = last?.trim().isNotEmpty == true ? last!.trim() : null;

        // Auto-split full name if first/last are missing
        if ((_firstName == null || _firstName!.isEmpty) &&
            (_lastName == null || _lastName!.isEmpty) &&
            _userName != 'User') {
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

  /// Set authentication data after login + save to SecureStorage
  Future<void> setAuth({
    required String token,
    required String userName,
    String? userEmail,
    String? firstName,
    String? lastName,
  }) async {
    _token = token.trim();
    _userName = userName.trim().isNotEmpty ? userName.trim() : 'User';
    _userEmail =
    userEmail?.trim().isNotEmpty == true ? userEmail!.trim() : null;
    _firstName =
    firstName?.trim().isNotEmpty == true ? firstName!.trim() : null;
    _lastName = lastName?.trim().isNotEmpty == true ? lastName!.trim() : null;

    // Auto-split name if first/last missing
    if ((_firstName == null || _firstName!.isEmpty) &&
        (_lastName == null || _lastName!.isEmpty) &&
        _userName != 'User') {
      final parts = _userName!.split(RegExp(r'\s+'));
      _firstName = parts.isNotEmpty ? parts.first : '';
      _lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    // Save to SecureStorage
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

  /// Refresh profile data from server (call after login or when needed)
  Future<void> refreshProfileFromServer() async {
    final token = this.token;
    if (token == null || token.isEmpty) return;

    try {
      final me = await tryFetchMe(token);
      if (me == null) {
        if (kDebugMode)
          debugPrint('refreshProfileFromServer: tryFetchMe returned null');
        return;
      }

      final rawFirst = me.first.trim();
      final rawLast = me.last.trim();
      final rawEmail = me.email.trim();

      final fullName = [rawFirst, rawLast].where((s) => s.isNotEmpty).join(' ');
      final nameToSave = fullName.isEmpty ? 'User' : fullName;

      // Update in-memory
      _userName = nameToSave;
      _userEmail = rawEmail;
      _firstName = rawFirst;
      _lastName = rawLast;

      // Save to SecureStorage
      await Future.wait([
        SecureStorage.saveUserName(nameToSave),
        SecureStorage.saveUserEmail(rawEmail),
        SecureStorage.saveFirstName(rawFirst),
        SecureStorage.saveLastName(rawLast),
      ]);

      // Note: ProfileCache no longer exists — its logic is now in AuthLocalDataSource
      // If you still want to cache first/last override, do it via the local datasource (injected)

      if (kDebugMode) {
        debugPrint('PROFILE REFRESHED FROM SERVER');
        debugPrint(
            '   → Server sent → First: "$rawFirst" | Last: "$rawLast" | Email: "$rawEmail"');
        debugPrint(
            '   → Saved as   → Full Name: "$nameToSave" | Email: "$rawEmail"');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('refreshProfileFromServer FAILED: $e');
        debugPrint('Stack: $stack');
      }
    }
  }

  /// Try `/me` to fetch canonical identity if the login payload is thin.
  static Future<({String first, String last, String name, String email})?>
  tryFetchMe(String token) async {
    try {
      // Try multiple possible endpoints (in order)
      final endpoints = ['/me', '/user', '/profile', '/account'];

      for (final endpoint in endpoints) {
        try {
          final resp = await _getAuth(endpoint, token);
          if (resp.statusCode != 200) continue;

          if (!_looksJson(resp)) continue;

          final data = _decodeMap(resp.body);

          // Debug: Print raw response so you can see what's returned
          if (kDebugMode) {
            print('[/api$endpoint] RESPONSE: ${resp.body}');
          }

          final id = extractIdentityFromAny(data);

          // If we got valid first + last name → use it
          if (id.first.isNotEmpty || id.last.isNotEmpty) {
            final fullName = '${id.first} ${id.last}'.trim();
            return (
            first: id.first,
            last: id.last,
            name: fullName.isNotEmpty ? fullName : id.name,
            email: id.email
            );
          }

          // Fallback: if only 'name' exists and it's not empty
          if (id.name.isNotEmpty) {
            return id;
          }
        } catch (e) {
          if (kDebugMode) print('Failed on $endpoint: $e');
          continue;
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) print('tryFetchMe all failed: $e');
      return null;
    }
  }

  static Future<http.Response> _getAuth(
      String endpoint,
      String token, [
        Map<String, String>? qs,
      ]) async {
    if (token.isEmpty) {
      throw Exception(
          'No auth token present for ${ApiService.baseUrl}$endpoint');
    }
    final url = ApiService.buildUri(endpoint, query: qs);
    // final resp = await http
    //     .get(url, headers: _authHeaders(token))
    //     .timeout(Duration(seconds: 25));

    final resp = await ApiService.get(
      endpoint,
      query: qs,
      headers: _authHeaders(token),
    );

    if (kDebugMode) {
      if (_looksJson(resp)) {
        print('[GET*]  $url -> ${resp.statusCode}');
      } else {
        final head = resp.body
            .substring(0, resp.body.length > 120 ? 120 : resp.body.length);
        print('[GET*]  $url -> ${resp.statusCode} (Non-JSON) head: $head');
      }
    }
    if (resp.statusCode == 401) {
      throw Exception('Unauthorized (401) on $url');
    }
    return resp;
  }

  static Map<String, String> _authHeaders(String token) {
    final cleanToken = token.trim();
    debugPrint('SENDING AUTH HEADER → Bearer $cleanToken');

    if (cleanToken.isEmpty) {
      throw Exception('Empty token in _authHeaders');
    }

    return {
      ..._jsonHeaders,
      'Authorization': 'Bearer $cleanToken',
      'Origin': 'https://akarat.com', // ← Add this (helps Sanctum)
      'Referer': 'https://akarat.com', // ← Add this (helps Sanctum)
    };
  }

  static const Map<String, String> _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
    'X-Requested-With': 'XMLHttpRequest',
  };

  static bool _looksJson(http.Response r) {
    final ct = (r.headers['content-type'] ?? '').toLowerCase();
    return ct.contains('application/json');
  }

  static Map<String, dynamic> _decodeMap(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static ({String first, String last, String name, String email})
  extractIdentityFromAny(Map<String, dynamic> src) {
    String pickStr(List<List<String>> paths) {
      for (final p in paths) {
        dynamic cur = src;
        for (final k in p) {
          if (cur is Map && cur.containsKey(k)) {
            cur = cur[k];
          } else {
            cur = null;
            break;
          }
        }
        if (cur is String && cur.trim().isNotEmpty) {
          return cur.trim();
        }
      }
      return '';
    }

    final first = pickStr([
      ['first_name'],
      ['user', 'first_name'],
      ['data', 'first_name'],
      ['data', 'user', 'first_name'],
    ]);

    final last = pickStr([
      ['last_name'],
      ['user', 'last_name'],
      ['data', 'last_name'],
      ['data', 'user', 'last_name'],
    ]);

    String name = pickStr([
      ['name'],
      ['user', 'name'],
      ['data', 'name'],
      ['data', 'user', 'name'],
    ]);

    String email = pickStr([
      ['email'],
      ['user', 'email'],
      ['data', 'email'],
      ['data', 'user', 'email'],
    ]);

    // Synthesize missing pieces from name when possible
    String f = first, l = last;
    if ((f.isEmpty || l.isEmpty) && name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      f = f.isEmpty ? (parts.isNotEmpty ? parts.first : '') : f;
      l = l.isEmpty ? (parts.length > 1 ? parts.sublist(1).join(' ') : '') : l;
    }
    if (name.isEmpty) {
      name = [f, l].where((s) => s.isNotEmpty).join(' ').trim();
    }

    return (first: f, last: l, name: name, email: email);
  }

  /// Update profile locally (e.g., after user edits name)
  Future<void> updateProfile({
    String? userName,
    String? userEmail,
    String? firstName,
    String? lastName,
  }) async {
    if (userName?.trim().isNotEmpty == true) _userName = userName!.trim();
    if (userEmail?.trim().isNotEmpty == true) _userEmail = userEmail!.trim();
    if (firstName?.trim().isNotEmpty == true) _firstName = firstName!.trim();
    if (lastName?.trim().isNotEmpty == true) _lastName = lastName!.trim();

    // Rebuild full name if needed
    if (_userName == null || _userName!.isEmpty || _userName == 'User') {
      _userName = [_firstName ?? '', _lastName ?? '']
          .where((s) => s.isNotEmpty)
          .join(' ');
      if (_userName!.isEmpty) _userName = 'User';
    }

    // Save to SecureStorage
    await Future.wait([
      SecureStorage.saveUserName(_userName!),
      if (_userEmail != null) SecureStorage.saveUserEmail(_userEmail!),
      if (_firstName != null) SecureStorage.saveFirstName(_firstName!),
      if (_lastName != null) SecureStorage.saveLastName(_lastName!),
    ]);

    if (kDebugMode) debugPrint('Profile updated locally: $_userName');
  }

  /// Full sign out — clears SecureStorage and in-memory
  Future<void> signOut() async {
    await SecureStorage.deleteAll();
    clear();
    if (kDebugMode) debugPrint('USER SIGNED OUT – Session cleared');
  }

  /// Clear only in-memory session (e.g., for testing)
  void clear() {
    _token = null;
    _userName = null;
    _userEmail = null;
    _firstName = null;
    _lastName = null;
  }
}