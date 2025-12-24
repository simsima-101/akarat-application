import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../features/property/data/models/amenities_model.dart';
import '../core/services/api_service.dart';

class SearchAmenitiesProvider extends ChangeNotifier {
  bool isLoading = false;
  List<Amenities> searchResults = [];

  final searchController = TextEditingController();

  Future<void> searchAmenities(String query) async {
    if (query.isEmpty) {
      searchResults = [];
      notifyListeners();
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      // Encode query to handle spaces/special characters safely
      final encodedQuery = Uri.encodeQueryComponent(query);

      // Build URI via ApiService (works with your configured base URL)
      final uri = ApiService.buildUri('amenities/search?q=$encodedQuery');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded['data'] ?? [];

        searchResults = data.map((e) => Amenities.fromJson(e)).toList();
      } else {
        searchResults = [];
        debugPrint('❌ Failed: ${response.statusCode}');
      }
    } catch (e) {
      searchResults = [];
      debugPrint('❌ Error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearSearchData() {
    searchResults.clear();
    searchController.clear();
    isLoading = false;
    notifyListeners();
  }
}