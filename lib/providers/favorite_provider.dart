// lib/providers/favorite_provider.dart
import 'dart:convert';

import 'package:Akarat/model/propertymodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../secure_storage.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';

class FavoriteProvider with ChangeNotifier {
  // -------- Effective Base URL (respects --dart-define=API_BASE_URL=...) --------
  static String get apiBase => ApiService.baseUrl;

  // ---------------- State ----------------
  final Set<int> _favoriteIds = <int>{};
  Set<int> get ids => _favoriteIds;
  Set<int> get allFavorites => _favoriteIds;
  int get favoriteCount => _favoriteIds.length;
  bool isFavorite(int id) => _favoriteIds.contains(id);

  bool isLoading = false;

  List<Property> savedProperties = [];

  // ✅ Fetch server list → **merge** provider → update UI list
  Future<void> fetchSavedProperties() async {
    isLoading = true;
    notifyListeners();
    final token = await SecureStorage.getToken();

    if (token == null || token!.isEmpty) {
      return;
    }

    final base = FavoriteProvider.apiBase;
    try {
      final response = await http.get(
        Uri.parse('$base/saved-property-list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<Property> props = (data['data']['data'] as List).map((e) {
          final p = Property.fromJson(e);
          p.saved = true;
          return p;
        }).toList();

        int? toInt(dynamic v) {
          if (v == null) return null;
          if (v is int) return v;
          if (v is String) return int.tryParse(v);
          return null;
        }

        final ids = (data['data']['data'] as List)
            .map((e) => toInt(e['id']) ?? toInt(e['property_id']))
            .whereType<int>();

        // ✅ Merge (not replace) to avoid wiping optimistic items
        await mergeFavoritesFromIds(ids);

        savedProperties = props;
      } else {
        debugPrint(
            '❌ Failed to fetch saved properties: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  // ---------------- Local cache (guest mode support) ----------------
  Future<void> loadFavorites() async {
    debugPrint('🔧 API_BASE_URL = $apiBase');
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('favorite_properties') ?? <String>[];
    _favoriteIds
      ..clear()
      ..addAll(saved.map(int.parse));
    debugPrint('❤️ Loaded ${_favoriteIds.length} favorites from local prefs');
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favorite_properties',
      _favoriteIds.map((e) => e.toString()).toList(),
    );
  }

  /// Bulk replace (use carefully — overwrites local state).
  Future<void> replaceFavoritesFromIds(Iterable<int> ids) async {
    _favoriteIds
      ..clear()
      ..addAll(ids);
    await _saveToPrefs();
    notifyListeners();
  }

  /// ✅ Merge helper: union server IDs into local set (prevents wiping optimistic items).
  Future<void> mergeFavoritesFromIds(Iterable<int> ids) async {
    final before = _favoriteIds.length;
    _favoriteIds.addAll(ids);
    if (_favoriteIds.length != before) {
      await _saveToPrefs();
      notifyListeners();
    }
  }

  // ---------------- Token (ONLY from SecureStorage) ----------------
  Future<String?> _loadToken() async {
    final t = await SecureStorage.getToken();
    return (t != null && t.trim().isNotEmpty) ? t : null;
  }

  // ---------------- Local state helpers ----------------
  Future<void> _applyLocalSet(int id, bool shouldBeSaved) async {
    bool changed = false;
    if (shouldBeSaved) {
      changed = _favoriteIds.add(id);
      if (changed) debugPrint('❤️ Ensured $id saved (local)');
    } else {
      changed = _favoriteIds.remove(id);
      if (changed) debugPrint('💔 Ensured $id removed (local)');
    }
    if (changed) {
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> _applyLocalToggle(int id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
      debugPrint('💔 Removed $id (local)');
    } else {
      _favoriteIds.add(id);
      debugPrint('❤️ Added $id (local)');
    }
    await _saveToPrefs();
    notifyListeners();
  }

  // ---------------- Legacy / convenience methods ----------------
  void addFavorite(int id, BuildContext context, {bool showSnackBar = true}) {
    if (_favoriteIds.add(id)) {
      _saveToPrefs();
      if (showSnackBar)
        _showSnackBar(context, "Added to favorites", Colors.green);
      notifyListeners();
    }
  }

  void clearFavorites() {
    if (_favoriteIds.isEmpty) return;
    _favoriteIds.clear();
    _saveToPrefs();
    notifyListeners();
  }

  /// Back-compat shim (delegates to unified method).
  Future<bool> toggleFavoriteWithApi(
    int id,
    String _unusedToken,
    BuildContext context, {
    bool showSnackBar = true,
  }) {
    return toggleFavoriteUnified(id, context, showSnackBar: showSnackBar);
  }

  /// Pure-local toggle (guest flows)
  Future<void> toggleFavorite(
    int id,
    BuildContext context, {
    bool showSnackBar = true,
  }) async {
    await _applyLocalToggle(id);
    if (showSnackBar) {
      final added = _favoriteIds.contains(id);
      _showSnackBar(
        context,
        added ? "Added to favorites" : "Removed from favorites",
        added ? Colors.green : Colors.red,
      );
    }
  }

  // ---------------- Public sync helper ----------------
  /// By default **merges** server truth into local set to avoid wiping optimistic items.
  Future<void> syncFromServer({bool merge = true}) async {
    final token = await _loadToken();
    if (token == null) return; // guest
    final ids = await FavoriteService.fetchApiFavorites(token);

    if (merge) {
      await mergeFavoritesFromIds(ids);
    } else {
      await replaceFavoritesFromIds(ids);
    }
  }

  // ---------------- The ONE method your UI should call ----------------
  Future<bool> toggleFavoriteUnified(
    int id,
    BuildContext context, {
    bool showSnackBar = true,
  }) async {
    final token = await _loadToken();

    // Guest → local only (instant flip)
    if (token == null) {
      final willBeSaved = !_favoriteIds.contains(id);
      await _applyLocalSet(id, willBeSaved);
      if (showSnackBar) {
        _showSnackBar(
          context,
          willBeSaved
              ? "Added to favorites (local)"
              : "Removed from favorites (local)",
          willBeSaved ? Colors.green : Colors.red,
        );
      }
      return true;
    }

    // Logged-in → OPTIMISTIC flip, then API, then (optionally) merge server truth.
    final optimisticWillBeSaved = !_favoriteIds.contains(id);
    await _applyLocalSet(id, optimisticWillBeSaved); // instant UI

    final url = Uri.parse('$apiBase/toggle-saved-property');

    final jsonHeaders = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
      'X-Requested-With': 'XMLHttpRequest',
    };

    http.Response res;
    try {
      debugPrint('🌍 POST $url');
      res = await http.post(
        url,
        headers: jsonHeaders,
        body: jsonEncode({'property_id': id}),
      );
      debugPrint('🔎 Status: ${res.statusCode}  Body: ${res.body}');
    } catch (e) {
      // Rollback on network error
      await _applyLocalSet(id, !optimisticWillBeSaved);
      if (showSnackBar)
        _showSnackBar(context, "Network error updating favorites", Colors.red);
      return false;
    }

    if (res.statusCode == 200) {
      bool? savedFlag;
      try {
        final m = jsonDecode(res.body);
        if (m is Map && m['saved'] is bool) savedFlag = m['saved'] as bool;
      } catch (_) {}

      // If backend told us final state, force-align; else keep optimistic
      if (savedFlag != null && savedFlag != optimisticWillBeSaved) {
        await _applyLocalSet(id, savedFlag);
      }

      if (showSnackBar) {
        final finalState = savedFlag ?? optimisticWillBeSaved;
        _showSnackBar(
          context,
          finalState ? "Added to favorites" : "Removed from favorites",
          finalState ? Colors.green : Colors.red,
        );
      }

      // ✅ Important: MERGE server truth instead of replacing (prevents immediate flicker)
      // ignore: unawaited_futures
      syncFromServer(merge: true);

      return true;
    }

    if (res.statusCode == 401 || res.statusCode == 419) {
      // Rollback on auth error
      await _applyLocalSet(id, !optimisticWillBeSaved);
      await SecureStorage.deleteToken(); // invalidate bad token
      if (showSnackBar)
        _showSnackBar(
            context, "Session expired. Please log in again.", Colors.red);
      return false;
    }

    // Optional retry with form-encoded
    if (res.statusCode == 400 || res.statusCode == 415) {
      try {
        final retry = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
            'X-Requested-With': 'XMLHttpRequest',
          },
          body: {'property_id': id.toString()},
        );
        debugPrint('🔁 Retry -> ${retry.statusCode}  Body: ${retry.body}');
        if (retry.statusCode == 200) {
          bool? savedFlag;
          try {
            final m = jsonDecode(retry.body);
            if (m is Map && m['saved'] is bool) savedFlag = m['saved'] as bool;
          } catch (_) {}
          final finalState = savedFlag ?? optimisticWillBeSaved;
          await _applyLocalSet(id, finalState);

          if (showSnackBar) {
            _showSnackBar(
              context,
              finalState ? "Added to favorites" : "Removed from favorites",
              finalState ? Colors.green : Colors.red,
            );
          }

          // ✅ Merge, not replace
          // ignore: unawaited_futures
          syncFromServer(merge: true);
          return true;
        }
      } catch (_) {}
    }

    // Any other failure → rollback optimistic state
    await _applyLocalSet(id, !optimisticWillBeSaved);
    if (showSnackBar) {
      _showSnackBar(
        context,
        "Failed to update favorites (${res.statusCode})",
        Colors.red,
      );
    }
    return false;
  }

  // ---------------- Snackbar ----------------
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