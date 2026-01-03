// lib/features/property/presentation/bloc/favorite_bloc.dart

import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:http/http.dart' as http;

import '../../../../core/utils/secure_storage.dart';
import '../../../property/data/models/featuredmodel.dart' as featured;
import '../../../property/data/models/property_model.dart'; // Adjust path to your unified Property model file
import 'favorite_event.dart';
import 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  FavoriteBloc() : super(FavoriteInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadFavorites(
      LoadFavorites event,
      Emitter<FavoriteState> emit,
      ) async {
    emit(FavoriteLoading());

    try {
      final token = await SecureStorage.getToken();

      // If no token → user not logged in
      if (token == null || token.isEmpty) {
        emit(FavoriteLoaded([]));
        return;
      }

      final response = await http.get(
        Uri.parse('https://akarat.com/api/saved-properties'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint("Saved properties response: ${response.statusCode} ${response.body}");

      // Handle 401: token invalid or expired
      if (response.statusCode == 401) {
        await SecureStorage.deleteToken(); // Clear bad token
        emit(FavoriteLoaded([]));
        return;
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        final List<dynamic> rawList = json['data']['data'] as List<dynamic>;

        // Convert raw JSON directly to unified Property model
        // This fixes the image loading because Property.fromJson correctly handles the 'image' field
        // when no 'media' array is present
        final List<Property> properties = rawList
            .map((item) => Property.fromJson(item as Map<String, dynamic>))
            .toList();

        emit(FavoriteLoaded(properties));
      } else {
        emit(FavoriteError('Failed to load favorites: ${response.statusCode}'));
      }
    } catch (e) {
      debugPrint("Load favorites error: $e");
      emit(FavoriteError('Error loading favorites: $e'));
    }
  }

  Future<void> _onToggleFavorite(
      ToggleFavorite event,
      Emitter<FavoriteState> emit,
      ) async {
    final currentState = state;
    if (currentState is! FavoriteLoaded) return;

    final propertyId = event.propertyId;
    final isCurrentlyFavorited = currentState.favoriteIds.contains(propertyId);

    // Optimistic UI update
    final updatedIds = Set<int>.from(currentState.favoriteIds);
    if (isCurrentlyFavorited) {
      updatedIds.remove(propertyId);
    } else {
      updatedIds.add(propertyId);
    }

    // Emit optimistic state (favorites is now List<Property>)
    emit(FavoriteLoaded(currentState.favorites));

    try {
      final token = await SecureStorage.getToken();
      if (token == null || token.isEmpty) {
        // Not logged in anymore → revert
        emit(currentState);
        return;
      }

      final response = await http.post(
        Uri.parse('https://akarat.com/api/toggle-saved-property'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"property_id": propertyId}),
      );

      // Handle 401 in toggle too
      if (response.statusCode == 401) {
        await SecureStorage.deleteToken();
        emit(FavoriteLoaded([]));
        add(const LoadFavorites()); // Trigger reload to show empty
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success → reload fresh data from server
        add(const LoadFavorites());
      } else {
        // Failed → revert optimistic update
        emit(currentState);
        emit(FavoriteError('Failed to update favorite'));
      }
    } catch (e) {
      // Network error → revert
      emit(currentState);
      emit(FavoriteError('Network error: $e'));
    }
  }
}