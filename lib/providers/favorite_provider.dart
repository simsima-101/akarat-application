// lib/providers/favorite_provider.dart
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../secure_storage.dart';
import '../services/favorite_service.dart';

class FavoriteProvider with ChangeNotifier {
  // -------- Effective Base URL (respects --dart-define=API_BASE_URL=...) --------
  // - iOS Simulator / Web: 127.0.0.1 is OK
  // - Android Emulator: rewrite localhost/127.0.0.1 → 10.0.2.2
  static String get apiBase {
    var url = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://akarat.com/api',
    ).replaceFirst(RegExp(r'/+$'), '');

    if (!kIsWeb &&
        Platform.isAndroid &&
        (url.contains('127.0.0.1') || url.contains('localhost'))) {
      url = url
          .replaceAll('127.0.0.1', '10.0.2.2')
          .replaceAll('localhost', '10.0.2.2');
    }
    return url;
  }

  // ---------------- State ----------------
  Set<int> _favorites = {};
  Set<int> get favorites => _favorites;
  int get favoriteCount => _favorites.length;
  bool isFavorite(int id) => _favorites.contains(id);
  Set<int> get allFavorites => _favorites;

  // ---------------- Local cache (guest mode support) ----------------
  Future<void> loadFavorites() async {
    debugPrint('🔧 API_BASE_URL = $apiBase');
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('favorite_properties') ?? [];
    _favorites = saved.map(int.parse).toSet();
    debugPrint('❤️ Loaded ${_favorites.length} favorites from local prefs');
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favorite_properties',
      _favorites.map((e) => e.toString()).toList(),
    );
  }

  // Bulk replace (for server → app sync on Fav screen)
  Future<void> replaceFavoritesFromIds(Iterable<int> ids) async {
    final newSet = ids.toSet();
    if (newSet.length == _favorites.length && _favorites.containsAll(newSet)) {
      return; // no change
    }
    _favorites = newSet;
    await _saveToPrefs();
    notifyListeners();
  }

  // ---------------- Token (ONLY from SecureStorage) ----------------
  Future<String?> _loadToken() async {
    final t = await SecureStorage.getToken(); // unified token source
    return (t != null && t.trim().isNotEmpty) ? t : null;
  }

  // ---------------- Local state helpers ----------------
  // Set a specific state (add/remove) instead of blindly toggling.
  Future<void> _applyLocalSet(int id, bool shouldBeSaved) async {
    bool changed = false;
    if (shouldBeSaved) {
      changed = _favorites.add(id);
      if (changed) debugPrint('❤️ Ensured $id saved (local)');
    } else {
      changed = _favorites.remove(id);
      if (changed) debugPrint('💔 Ensured $id removed (local)');
    }
    if (changed) {
      await _saveToPrefs();
      notifyListeners();
    }
  }

  // A legacy “toggle” for pure-local usage (guest screens)
  Future<void> _applyLocalToggle(int id) async {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
      debugPrint('💔 Removed $id (local)');
    } else {
      _favorites.add(id);
      debugPrint('❤️ Added $id (local)');
    }
    await _saveToPrefs();
    notifyListeners();
  }

  // ---------------- Backward-compat methods ----------------
  void addFavorite(int id, BuildContext context, {bool showSnackBar = true}) {
    if (_favorites.add(id)) {
      _saveToPrefs();
      if (showSnackBar) _showSnackBar(context, "Added to favorites", Colors.green);
      notifyListeners();
    }
  }

  void clearFavorites() {
    if (_favorites.isEmpty) return;
    _favorites.clear();
    _saveToPrefs();
    notifyListeners();
  }

  // Old signature shim (keeps old call sites compiling)
  Future<bool> toggleFavoriteWithApi(
      int id,
      String _unusedToken,
      BuildContext context, {
        bool showSnackBar = true,
      }) async {
    return toggleFavoriteUnified(id, context, showSnackBar: showSnackBar);
  }

  // Keep a pure-local toggle (used by some UIs when guest)
  Future<void> toggleFavorite(int id, BuildContext context, {bool showSnackBar = true}) async {
    await _applyLocalToggle(id);
    if (showSnackBar) {
      final added = _favorites.contains(id);
      _showSnackBar(
        context,
        added ? "Added to favorites" : "Removed from favorites",
        added ? Colors.green : Colors.red,
      );
    }
  }

  // ---------------- Public sync helper (Favorites screen can call this) ----------------
  Future<void> syncFromServer() async {
    final token = await _loadToken();
    if (token == null) return; // guest: nothing to sync from server
    final ids = await FavoriteService.fetchApiFavorites(token);
    await replaceFavoritesFromIds(ids);
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
      final willBeSaved = !_favorites.contains(id);
      await _applyLocalSet(id, willBeSaved);
      if (showSnackBar) {
        _showSnackBar(
          context,
          willBeSaved ? "Added to favorites (local)" : "Removed from favorites (local)",
          willBeSaved ? Colors.green : Colors.red,
        );
      }
      return true;
    }

    // Logged-in → OPTIMISTIC flip, then API, then align to server truth
    final optimisticWillBeSaved = !_favorites.contains(id);
    await _applyLocalSet(id, optimisticWillBeSaved); // instant UI

    final url = Uri.parse('$apiBase/toggle-saved-property');
    final headers = {
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
        headers: headers,
        body: jsonEncode({'property_id': id}),
      );
      debugPrint('🔎 Status: ${res.statusCode}  Body: ${res.body}');
    } catch (e) {
      // Rollback on network error
      await _applyLocalSet(id, !optimisticWillBeSaved);
      if (showSnackBar) _showSnackBar(context, "Network error updating favorites", Colors.red);
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

      // Refresh from server to keep Favorites screen correct (fire-and-forget)
      // ignore: unawaited_futures
      syncFromServer();

      return true;
    }

    if (res.statusCode == 401 || res.statusCode == 419) {
      // Rollback on auth error
      await _applyLocalSet(id, !optimisticWillBeSaved);
      await SecureStorage.deleteToken(); // invalidate bad token
      if (showSnackBar) _showSnackBar(context, "Session expired. Please log in again.", Colors.red);
      return false;
    }

    // Optional retry if server expects form-encoded
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
          // ignore: unawaited_futures
          syncFromServer();
          return true;
        }
      } catch (_) {
        // fallthrough to rollback below
      }
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
