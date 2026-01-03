part of 'properties_bloc.dart';

enum PropertiesStatus { initial, loading, loaded, loadingMore, error }

class PropertiesState extends Equatable {
  final List<ProjectData> properties;
  final int currentPage;
  final bool hasMore;
  final PropertiesStatus status;
  final String? errorMessage;
  final String endpoint;

  const PropertiesState({
    required this.properties,
    required this.currentPage,
    required this.hasMore,
    required this.status,
    this.errorMessage,
    required this.endpoint,
  });

  const PropertiesState.initial()
      : this(
    properties: const [],
    currentPage: 1,
    hasMore: true,
    status: PropertiesStatus.initial,
    endpoint: '',
  );

  PropertiesState copyWith({
    List<ProjectData>? properties,
    int? currentPage,
    bool? hasMore,
    PropertiesStatus? status,
    String? errorMessage,
    String? endpoint,
  }) {
    return PropertiesState(
      properties: properties ?? this.properties,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      status: status ?? this.status,
      errorMessage: errorMessage,
      endpoint: endpoint ?? this.endpoint,
    );
  }

  @override
  List<Object?> get props => [properties, currentPage, hasMore, status, errorMessage, endpoint];
}