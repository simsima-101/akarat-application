import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _favoriteKey = 'favorite_properties';

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
}
