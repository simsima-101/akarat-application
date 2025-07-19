import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _favoriteKey = 'favorite_properties';


  static Set<int> loggedInFavorites = {};

  static Future<Set<int>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getStringList(_favoriteKey) ?? [];
    return savedFavorites.map(int.parse).toSet();
  }

  static Future<void> saveFavorites(Set<int> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoriteKey, favorites.map((id) => id.toString()).toList());
  }

  static Future<void> toggleFavorite(int propertyId, Set<int> currentFavorites) async {
    if (currentFavorites.contains(propertyId)) {
      currentFavorites.remove(propertyId);
    } else {
      currentFavorites.add(propertyId);
    }
    await saveFavorites(currentFavorites);
  }


  // ✅ Add this method to fetch logged-in favorites from API
  static Future<Set<int>> fetchApiFavorites(String token) async {
    final response = await http.get(
      Uri.parse('https://akarat.com/api/saved-property-list'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final ids = (data['data']['data'] as List)
          .map<int>((e) => int.parse(e['id'].toString())) // ✅ force int
          .toSet();
      return ids;
    } else {
      return {};
    }
  }

}
