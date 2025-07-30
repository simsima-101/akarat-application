import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FavoriteProvider with ChangeNotifier {
  Set<int> _favorites = {};

  Set<int> get favorites => _favorites;

  bool isFavorite(int id) => _favorites.contains(id);

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('favorite_properties') ?? [];
    _favorites = saved.map(int.parse).toSet();
    debugPrint('❤️ Loaded ${_favorites.length} favorites from SharedPreferences');
    notifyListeners();
  }

  void setFavorites(Set<int> newFavorites) {
    _favorites = newFavorites;
    _saveToPrefs();
    notifyListeners();
  }

  void addFavorite(int id, BuildContext context) {
    _favorites.add(id);
    _saveToPrefs();
    _showSnackBar(context, "Added to favorites", Colors.green);
    notifyListeners();
  }

  void removeFavorite(int id, BuildContext context) {
    _favorites.remove(id);
    _saveToPrefs();
    _showSnackBar(context, "Removed from favorites", Colors.red);
    notifyListeners();
  }

  /// ✅ Toggle favorite locally with notification
  Future<void> toggleFavorite(int id, BuildContext context) async {
    bool added;
    if (_favorites.contains(id)) {
      _favorites.remove(id);
      added = false;
      debugPrint('💔 Removed $id from favorites');
    } else {
      _favorites.add(id);
      added = true;
      debugPrint('❤️ Added $id to favorites');
    }
    await _saveToPrefs();
    _showSnackBar(context, added ? "Added to favorites" : "Removed from favorites", added ? Colors.green : Colors.red);
    notifyListeners();
  }

  /// ✅ Toggle favorite with API and show notification
  Future<bool> toggleFavoriteWithApi(int id, String token, BuildContext context) async {
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
        await toggleFavorite(id, context);
        return true;
      } else {
        debugPrint("❌ API Failed: ${response.statusCode}");
        _showSnackBar(context, "Failed to update favorites", Colors.red);
        return false;
      }
    } catch (e) {
      debugPrint("🚨 API Error: $e");
      _showSnackBar(context, "Error updating favorites", Colors.red);
      return false;
    }
  }

  Future<void> clearFavorites() async {
    _favorites.clear();
    await _saveToPrefs();
    debugPrint('🗑️ Cleared all favorites');
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favorite_properties',
      _favorites.map((e) => e.toString()).toList(),
    );
  }

  int get favoriteCount => _favorites.length;

  Set<int> get allFavorites => _favorites;

  /// 🔔 Show global notification
  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
