part of 'properties_bloc.dart';

enum PropertiesStatus { initial, loading, loaded, loadingMore, error }

class PropertiesState extends Equatable {
  final List<ProjectData> properties;
  final int currentPage;
  final bool hasMore;
  final PropertiesStatus status;
  final String? errorMessage;
  final String endpoint;
  final int? totalProperties;
  final String currentSort;

  const PropertiesState({
    required this.properties,
    required this.currentPage,
    required this.hasMore,
    required this.status,
    this.errorMessage,
    required this.endpoint,
    this.totalProperties,
    this.currentSort = "newest",
  });

  const PropertiesState.initial()
      : this(
    properties: const [],
    currentPage: 1,
    hasMore: true,
    status: PropertiesStatus.initial,
    endpoint: '',
    totalProperties: null,

  );

  PropertiesState copyWith({
    List<ProjectData>? properties,
    int? currentPage,
    bool? hasMore,
    PropertiesStatus? status,
    String? errorMessage,
    String? endpoint,
    int? totalProperties,
    String? currentSort,
  }) {
    return PropertiesState(
      properties: properties ?? this.properties,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      status: status ?? this.status,
      errorMessage: errorMessage,
      endpoint: endpoint ?? this.endpoint,
      totalProperties: totalProperties ?? this.totalProperties,
      currentSort: currentSort ?? this.currentSort,
    );
  }

  @override
  List<Object?> get props => [properties, currentPage, hasMore, status, errorMessage, endpoint, totalProperties, currentSort];
}