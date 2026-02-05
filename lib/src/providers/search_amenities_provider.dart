import 'dart:convert';

import 'package:flutter/material.dart';

import '../core/services/api_service.dart'; // Make sure this path is correct
import '../features/property/data/models/amenities_model.dart';

class AmenitiesProvider extends ChangeNotifier {
  // ────────────────────────────────────────────────
  // State
  // ────────────────────────────────────────────────
  List<Amenities> _allAmenities = [];
  List<Amenities> _searchResults = [];

  bool _isLoading = false;
  bool _isSearching = false;

  String _lastSearchQuery = '';

  final TextEditingController searchController = TextEditingController();

  // ────────────────────────────────────────────────
  // Constructor – listen to language changes
  // ────────────────────────────────────────────────
  AmenitiesProvider() {
    Future.microtask(() => refresh());
    // Optional: initial fetch on creation (uncomment if needed)
    // fetchAmenities();
  }

  // ────────────────────────────────────────────────
  // Language change handler
  // ────────────────────────────────────────────────
  void _onLanguageChanged() {
    debugPrint('AmenitiesProvider: Language changed → refreshing data');
    refresh();
  }

  // ────────────────────────────────────────────────
  // Getters
  // ────────────────────────────────────────────────
  List<Amenities> get amenities => _allAmenities;

  List<Amenities> get searchResults => _searchResults;

  bool get isLoading => _isLoading;

  bool get isSearching => _isSearching;

  bool get hasSearchResults => _searchResults.isNotEmpty;

  String get currentSearchQuery => _lastSearchQuery;

  // ────────────────────────────────────────────────
  // Fetch all amenities (initial load / refresh)
  // ────────────────────────────────────────────────
  Future<void> fetchAmenities() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get("amenities");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data =
            decoded is List ? decoded : (decoded['data'] as List? ?? []);

        _allAmenities = data.map((e) => Amenities.fromJson(e)).toList();
      } else {
        debugPrint(
            'Failed to load amenities: ${response.statusCode} - ${response.body}');
        _allAmenities = [];
      }
    } catch (e, stack) {
      debugPrint('Error fetching amenities: $e');
      debugPrint('Stack: $stack');
      _allAmenities = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ────────────────────────────────────────────────
  // Search amenities by query
  // ────────────────────────────────────────────────
  Future<void> searchAmenities(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      clearSearch();
      return;
    }

    if (trimmedQuery == _lastSearchQuery) {
      return; // avoid duplicate identical searches
    }

    _isSearching = true;
    _lastSearchQuery = trimmedQuery;
    notifyListeners();

    try {
      // final uri = ApiService.buildUri(
      //   'amenities/search',
      //   query: {'q': trimmedQuery},
      // );

      final response = await ApiService.get(
        'amenities/search',
        query: {'q': trimmedQuery},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data =
            decoded is List ? decoded : (decoded['data'] as List? ?? []);

        _searchResults = data.map((e) => Amenities.fromJson(e)).toList();
      } else {
        debugPrint('Search failed: ${response.statusCode} - ${response.body}');
        _searchResults = [];
      }
    } catch (e, stack) {
      debugPrint('Search error: $e');
      debugPrint('Stack: $stack');
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  // ────────────────────────────────────────────────
  // Clear / reset search
  // ────────────────────────────────────────────────
  void clearSearch() {
    _searchResults.clear();
    _lastSearchQuery = '';
    searchController.clear();
    _isSearching = false;
    notifyListeners();
  }

  // ────────────────────────────────────────────────
  // Refresh everything (called on language change or manually)
  // ────────────────────────────────────────────────
  Future<void> refresh() async {
    // Clear old data to force UI update
    _allAmenities = [];
    _searchResults = [];
    notifyListeners(); // Show loading state immediately

    await fetchAmenities();

    if (_lastSearchQuery.isNotEmpty) {
      debugPrint('Re-applying active search: $_lastSearchQuery');
      await searchAmenities(_lastSearchQuery);
    }
  }

  // ────────────────────────────────────────────────
  // Lifecycle cleanup
  // ────────────────────────────────────────────────
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
