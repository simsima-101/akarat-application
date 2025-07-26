import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String? _token;
  String? _username;
  String? _email;
  String? _result;
  final List<Map<String, dynamic>> _guestFavorites = []; // ✅ Guest favorites list

  String? get token => _token;
  String? get username => _username;
  String? get email => _email;       // ✅ Getter
  String? get result => _result;
  bool get isLoggedIn => _token != null;
  List<Map<String, dynamic>> get guestFavorites => List.unmodifiable(_guestFavorites);

  /// Load saved user session (call this on app start)
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _username = prefs.getString('username');
    _email = prefs.getString('email');     // ✅ Load email
    _result = prefs.getString('result');

    // Load guest favorites
    final favList = prefs.getStringList('guest_favorites') ?? [];
    _guestFavorites
      ..clear()
      ..addAll(favList.map((e) => Map<String, dynamic>.from(jsonDecode(e))));

    notifyListeners();
  }

  /// Save user session after login
  Future<void> setUser(String token, String username, {String? email, String? result}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('username', username);

    if (email != null) {
      await prefs.setString('email', email);
      _email = email;
    }

    if (result != null) {
      await prefs.setString('result', result);
      _result = result;
    }

    _token = token;
    _username = username;
    notifyListeners();
  }


  /// Logout user (clears session + guest favorites)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');
    await prefs.remove('guest_favorites');
    await prefs.remove('email');   // ✅ Clear email
    await prefs.remove('result');  // ✅ Clear result

    _token = null;
    _username = null;
    _email = null;
    _result = null;
    _guestFavorites.clear();
    notifyListeners();
  }

  /// Delete account (API + clear local session)
  Future<bool> deleteAccount() async {
    if (_token == null) return false;

    final response = await http.delete(
      Uri.parse('https://akarat.com/api/delete-account'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      await logout();
      return true;
    }
    return false;
  }

  // ===========================
  // Guest Favorites Management
  // ===========================

  Future<void> addGuestFavorite(Map<String, dynamic> project) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_guestFavorites.any((p) => p['id'] == project['id'])) {
      _guestFavorites.add(project);
      final encodedList = _guestFavorites.map((e) => jsonEncode(e)).toList();
      await prefs.setStringList('guest_favorites', encodedList);
      notifyListeners();
    }
  }

  Future<void> removeGuestFavorite(int projectId) async {
    final prefs = await SharedPreferences.getInstance();
    _guestFavorites.removeWhere((p) => p['id'] == projectId);
    final encodedList = _guestFavorites.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('guest_favorites', encodedList);
    notifyListeners();
  }

  Future<void> clearGuestFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('guest_favorites');
    _guestFavorites.clear();
    notifyListeners();
  }
}
