import 'package:flutter/material.dart';
import '../model/agencypropertiesmodel.dart';


class FavoriteProvider with ChangeNotifier {
  final List<Property> _favorites = [];

  List<Property> get favorites => _favorites;

  void addFavorite(Property property) {
    if (!_favorites.any((p) => p.id == property.id)) {
      _favorites.add(property);
      notifyListeners();
    }
  }

  void removeFavorite(String id) {
    _favorites.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  bool isFavorite(String id) {
    return _favorites.any((p) => p.id == id);
  }
}
