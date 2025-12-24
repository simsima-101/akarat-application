import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;

import '../../../../core/utils/secure_storage.dart';
import '../../../property/data/models/property_model.dart';
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

      if (response.statusCode == 200) {
        // TODO: parse API response properly
        final List<Property> properties = [];

        emit(FavoriteLoaded(properties));
      } else {
        emit(
          FavoriteError(
            'Failed to load favorites (Status: ${response.statusCode})',
          ),
        );
      }
    } catch (e) {
      emit(FavoriteError('Network error: ${e.toString()}'));
    }
  }

  Future<void> _onToggleFavorite(
      ToggleFavorite event,
      Emitter<FavoriteState> emit,
      ) async {
    final currentState = state;
    if (currentState is! FavoriteLoaded) return;

    // Optimistic update
    final updatedFavorites = currentState.favorites
        .where((p) => int.tryParse(p.id) != event.propertyId)
        .toList();

    emit(FavoriteLoaded(updatedFavorites));

    try {
      final token = await SecureStorage.getToken();
      if (token == null || token.isEmpty) return;

      final response = await http.post(
        Uri.parse('https://akarat.com/api/saved-properties/toggle'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: '{"property_id": ${event.propertyId}}',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        add(const LoadFavorites());
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      emit(currentState);
      emit(FavoriteError('Failed to update favorite: ${e.toString()}'));
    }
  }
}
