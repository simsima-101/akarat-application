// lib/features/property/presentation/bloc/favorite_bloc.dart

import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:http/http.dart' as http;

import '../../../../core/services/api_service.dart';
import '../../../../core/utils/secure_storage.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../property/data/models/featuredmodel.dart' as featured;
import '../../../property/data/models/property_model.dart'; // Adjust path to your unified Property model file
import 'favorite_event.dart';
import 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  FavoriteBloc() : super(FavoriteInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<String?> _getValidToken() async {
    var token = SessionManager().token ?? await SecureStorage.getToken();
    if (token == null || token.isEmpty) {
      return null;
    }
    return token;
  }

  Future<void> _onLoadFavorites(
      LoadFavorites event,
      Emitter<FavoriteState> emit,
      ) async {
    emit(FavoriteLoading());

    final token = await _getValidToken();
    if (token == null) {
      emit(FavoriteLoaded([]));
      return;
    }

    try {
      final response = await http.get(
        ApiService.buildUri('saved-properties'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint("Favorites GET: ${response.statusCode} ${response.body}");

      if (response.statusCode == 401) {
        await SecureStorage.deleteToken();
        SessionManager().clear();
        emit(FavoriteLoaded([]));
        return;
      }

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final rawList = json['data']['data'] as List<dynamic>? ?? [];

        final properties = rawList
            .map((e) => Property.fromJson(e as Map<String, dynamic>))
            .toList();

        emit(FavoriteLoaded(properties));
      } else {
        emit(FavoriteError('Failed: ${response.statusCode}'));
      }
    } catch (e) {
      debugPrint("Favorites load error: $e");
      emit(FavoriteError(e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
      ToggleFavorite event,
      Emitter<FavoriteState> emit,
      ) async {
    final currentState = state;
    if (currentState is! FavoriteLoaded) return;

    final propertyId = event.propertyId;
    final wasFavorited = currentState.favoriteIds.contains(propertyId);

    // Optimistic update: toggle locally first
    final updatedFavorites = List<Property>.from(currentState.favorites);
    final updatedIds = Set<int>.from(currentState.favoriteIds);

    if (wasFavorited) {
      updatedIds.remove(propertyId);
      updatedFavorites.removeWhere((p) => int.tryParse(p.id ?? '0') == propertyId);
    } else {
      updatedIds.add(propertyId);
      // Optional: if you have the full Property object, add it here
      // Otherwise reload full list after API success
    }

    emit(FavoriteLoaded(updatedFavorites));

    try {
      final token = await _getValidToken();
      if (token == null) {
        emit(currentState); // revert
        return;
      }

      final response = await http.post(
        ApiService.buildUri('toggle-saved-property'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"property_id": propertyId}),
      );

      debugPrint("Toggle favorite: ${response.statusCode} ${response.body}");

      if (response.statusCode == 401) {
        await SecureStorage.deleteToken();
        SessionManager().clear();
        emit(FavoriteLoaded([]));
        add(const LoadFavorites());
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success → reload full fresh list from server (safest)
        add(const LoadFavorites());
      } else {
        // API failed → revert optimistic update
        emit(currentState);
      }
    } catch (e) {
      debugPrint("Toggle error: $e");
      emit(currentState); // revert
    }
  }
}