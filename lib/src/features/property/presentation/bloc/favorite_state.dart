// lib/features/property/presentation/bloc/favorite_state.dart

import 'package:equatable/equatable.dart';
import '../../data/models/property_model.dart';

abstract class FavoriteState extends Equatable {
  const FavoriteState();

  @override
  List<Object?> get props => [];
}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {}

class FavoriteLoaded extends FavoriteState {
  final List<Property> favorites;

  const FavoriteLoaded(this.favorites);

  Set<int> get favoriteIds => favorites
      .map((p) => int.tryParse(p.id ?? ''))
      .whereType<int>()
      .toSet();

  @override
  List<Object?> get props => [favorites];
}

class FavoriteError extends FavoriteState {
  final String message;

  const FavoriteError(this.message);

  @override
  List<Object?> get props => [message];
}