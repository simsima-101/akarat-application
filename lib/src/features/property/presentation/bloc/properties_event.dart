part of 'properties_bloc.dart';

abstract class PropertiesEvent extends Equatable {
  const PropertiesEvent();

  @override
  List<Object?> get props => [];
}



class LoadProperties extends PropertiesEvent {
  final String endpoint;
  final String? sortBy;

  const LoadProperties({
    required this.endpoint,
    this.sortBy,
  });

  @override
  List<Object?> get props => [endpoint, sortBy];
}

class LoadMoreProperties extends PropertiesEvent {
  @override
  List<Object?> get props => [];
}

class RefreshProperties extends PropertiesEvent {
  @override
  List<Object?> get props => [];
}

class ChangeSort extends PropertiesEvent {
  final String sortBy;

  const ChangeSort({required this.sortBy});

  @override
  List<Object?> get props => [sortBy];
}