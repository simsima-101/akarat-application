// lib/features/property/presentation/bloc/favorite_event.dart

import 'package:equatable/equatable.dart';

abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoriteEvent {
  const LoadFavorites();

  @override
  List<Object?> get props => [];
}

class ToggleFavorite extends FavoriteEvent {
  final int propertyId;

  const ToggleFavorite({required this.propertyId});

  @override
  List<Object?> get props => [propertyId];
}