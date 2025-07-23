import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _favoriteKey = 'favorite_properties';
  static Set<int> loggedInFavorites = {};

  // Load from local storage
  static Future<Set<int>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getStringList(_favoriteKey) ?? [];
    return savedFavorites.map(int.parse).toSet();
  }

  // Save to local storage
  static Future<void> saveFavorites(Set<int> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _favoriteKey,
      favorites.map((id) => id.toString()).toList(),
    );
  }

  // Toggle favorite locally
  static Future<void> toggleFavorite(int propertyId, Set<int> currentFavorites) async {
    if (currentFavorites.contains(propertyId)) {
      currentFavorites.remove(propertyId);
    } else {
      currentFavorites.add(propertyId);
    }
    await saveFavorites(currentFavorites);
  }

  // 🔁 API: Toggle favorite on server
  static Future<bool> toggleFavoriteApi(String token, int propertyId) async {
    final url = Uri.parse("https://akarat.com/api/toggle-saved-property");

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"property_id": propertyId}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("❌ Failed to toggle favorite: ${response.body}");
      return false;
    }
  }

  // 🔁 API: Fetch current favorites from backend
  static Future<Set<int>> fetchApiFavorites(String token) async {
    final response = await http.get(
      Uri.parse('https://akarat.com/api/saved-property-list'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final ids = (data['data']['data'] as List)
          .map<int>((e) => int.parse(e['id'].toString()))
          .toSet();
      return ids;
    } else {
      print("❌ Failed to fetch API favorites: ${response.body}");
      return {};
    }
  }
}
