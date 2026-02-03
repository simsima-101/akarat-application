// features/saved_alerts/bloc/saved_alerts_state.dart
import 'package:equatable/equatable.dart';
import '../../data/models/saved_alert_model.dart';

enum SavedAlertsStatus {
  initial,
  loading,
  success,
  error,
  deleting,
  deleteSuccess,
  deleteError,
}

class SavedAlertsState extends Equatable {
  final SavedAlertsStatus status;
  final List<SavedAlert> alerts;
  final int currentPage;
  final int pageSize;
  final String? errorMessage;
  final bool isDeletingAll;

  const SavedAlertsState({
    this.status = SavedAlertsStatus.initial,
    this.alerts = const [],
    this.currentPage = 1,
    this.pageSize = 4,
    this.errorMessage,
    this.isDeletingAll = false,
  });

  int get totalPages => alerts.isEmpty ? 1 : ((alerts.length - 1) ~/ pageSize) + 1;

  List<SavedAlert> get pageItems {
    if (alerts.isEmpty) return const [];
    final start = (currentPage - 1) * pageSize;
    final end = (currentPage * pageSize).clamp(0, alerts.length);
    if (start >= alerts.length) return const [];
    return alerts.sublist(start, end);
  }

  bool get isLastPage => currentPage >= totalPages;

  SavedAlertsState copyWith({
    SavedAlertsStatus? status,
    List<SavedAlert>? alerts,
    int? currentPage,
    String? errorMessage,
    bool? isDeletingAll,
  }) {
    return SavedAlertsState(
      status: status ?? this.status,
      alerts: alerts ?? this.alerts,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize,
      errorMessage: errorMessage ?? this.errorMessage,
      isDeletingAll: isDeletingAll ?? this.isDeletingAll,
    );
  }

  @override
  List<Object?> get props => [
    status,
    // Use .toList() to make sure a new instance is compared
    alerts.toList(growable: false),
    currentPage,
    pageSize,
    errorMessage,
    isDeletingAll,
  ];
}