import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FavoriteProvider with ChangeNotifier {
  Set<int> _favorites = {};

  Set<int> get favorites => _favorites;

  /// ✅ Returns true if a property ID is marked as favorite
  bool isFavorite(int id) => _favorites.contains(id);

  /// ✅ Load favorites from SharedPreferences
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('favorite_properties') ?? [];
    _favorites = saved.map(int.parse).toSet();
    debugPrint('❤️ Loaded ${_favorites.length} favorites from SharedPreferences');
    notifyListeners();
  }

  /// ✅ Set all favorites at once (e.g. from API)
  void setFavorites(Set<int> newFavorites) {
    _favorites = newFavorites;
    _saveToPrefs();
    notifyListeners();
  }

  /// ✅ Add a property to favorites
  void addFavorite(int id) {
    _favorites.add(id);
    _saveToPrefs();
    notifyListeners();
  }

  /// ✅ Remove a property from favorites
  void removeFavorite(int id) {
    _favorites.remove(id);
    _saveToPrefs();
    notifyListeners();
  }

  /// ✅ Toggle favorite locally
  Future<void> toggleFavorite(int id) async {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
      debugPrint('💔 Removed $id from favorites');
    } else {
      _favorites.add(id);
      debugPrint('❤️ Added $id to favorites');
    }
    await _saveToPrefs();
    notifyListeners();
  }

  /// ✅ Toggle favorite with API
  Future<bool> toggleFavoriteWithApi(int id, String token) async {
    final url = Uri.parse('https://akarat.com/api/toggle-saved-property');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"property_id": id}),
      );

      if (response.statusCode == 200) {
        // Update local state if API succeeds
        await toggleFavorite(id);
        return true;
      } else {
        debugPrint("❌ API Failed: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("🚨 API Error: $e");
      return false;
    }
  }

  /// ✅ Clear all favorites
  Future<void> clearFavorites() async {
    _favorites.clear();
    await _saveToPrefs();
    debugPrint('🗑️ Cleared all favorites');
    notifyListeners();
  }

  /// ✅ Save to SharedPreferences
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favorite_properties',
      _favorites.map((e) => e.toString()).toList(),
    );
  }

  /// ✅ Number of favorites (used for badge or indicator)
  int get favoriteCount => _favorites.length;

  /// Optional: expose all favorites
  Set<int> get allFavorites => _favorites;
}
