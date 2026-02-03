// features/saved_alerts/bloc/saved_alerts_event.dart
import '../../data/models/saved_alert_model.dart';

sealed class SavedAlertsEvent {}

class LoadSavedAlerts extends SavedAlertsEvent {
  final bool initial;
  LoadSavedAlerts({this.initial = false});
}

class ReloadSavedAlerts extends SavedAlertsEvent {
  final bool goToLastPage;
  ReloadSavedAlerts({this.goToLastPage = false});
}

class DeleteSingleAlert extends SavedAlertsEvent {
  final SavedAlert alert;
  DeleteSingleAlert(this.alert);
}

class DeleteAllAlerts extends SavedAlertsEvent {}

class ChangePage extends SavedAlertsEvent {
  final int page;
  ChangePage(this.page);
}

class CreateNewAlert extends SavedAlertsEvent {}