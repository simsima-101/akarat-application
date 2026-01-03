part of 'new_projects_bloc.dart';

enum NewProjectsStatus { initial, loading, loaded, loadingMore, error }

class NewProjectsState extends Equatable {
  final List<ProjectData> projects;
  final int currentPage;
  final bool hasMore;
  final NewProjectsStatus status;
  final String? errorMessage;

  const NewProjectsState({
    required this.projects,
    required this.currentPage,
    required this.hasMore,
    required this.status,
    this.errorMessage,
  });

  const NewProjectsState.initial()
      : this(
    projects: const [],
    currentPage: 1,
    hasMore: true,
    status: NewProjectsStatus.initial,
  );

  NewProjectsState copyWith({
    List<ProjectData>? projects,
    int? currentPage,
    bool? hasMore,
    NewProjectsStatus? status,
    String? errorMessage,
  }) {
    return NewProjectsState(
      projects: projects ?? this.projects,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [projects, currentPage, hasMore, status, errorMessage];
}