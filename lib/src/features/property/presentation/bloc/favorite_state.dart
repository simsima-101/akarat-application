// lib/features/property/presentation/bloc/favorite_state.dart

import 'package:equatable/equatable.dart';

import '../../data/models/property_model.dart'; // ← Adjust path to your unified Property class file

abstract class FavoriteState extends Equatable {
  const FavoriteState();

  @override
  List<Object?> get props => [];
}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {}

class FavoriteLoaded extends FavoriteState {
  final List<Property> favorites;
  final Set<int> favoriteIds;

  // Removed 'const' here — this is the key fix
  FavoriteLoaded(this.favorites)
      : favoriteIds = favorites
      .map((p) => int.tryParse(p.id) ?? -1)
      .where((id) => id != -1)
      .toSet();

  @override
  List<Object?> get props => [favorites, favoriteIds];
}

class FavoriteError extends FavoriteState {
  final String message;

  const FavoriteError(this.message);

  @override
  List<Object?> get props => [message];
}