// features/alerts/bloc/create_alert_state.dart
import 'package:equatable/equatable.dart';
import '../../data/models/property_type_model.dart';


enum CreateAlertStatus {
  initial,
  loadingPropertyTypes,
  loaded,
  submitting,
  success,
  error,
}

class CreateAlertState extends Equatable {
  final CreateAlertStatus status;
  final String purpose;
  final String propertyType; // '' = Any
  final String timePeriod;
  final String alertName;
  final PropertyTypeModel? propertyTypeModel;
  final String? errorMessage;
  final bool isSubmitting;

  const CreateAlertState({
    this.status = CreateAlertStatus.initial,
    this.purpose = '',
    this.propertyType = '',
    this.timePeriod = 'Daily',
    this.alertName = '',
    this.propertyTypeModel,
    this.errorMessage,
    this.isSubmitting = false,
  });

  CreateAlertState copyWith({
    CreateAlertStatus? status,
    String? purpose,
    String? propertyType,
    String? timePeriod,
    String? alertName,
    PropertyTypeModel? propertyTypeModel,
    String? errorMessage,
    bool? isSubmitting,
  }) {
    return CreateAlertState(
      status: status ?? this.status,
      purpose: purpose ?? this.purpose,
      propertyType: propertyType ?? this.propertyType,
      timePeriod: timePeriod ?? this.timePeriod,
      alertName: alertName ?? this.alertName,
      propertyTypeModel: propertyTypeModel ?? this.propertyTypeModel,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
    status,
    purpose,
    propertyType,
    timePeriod,
    alertName,
    propertyTypeModel,
    errorMessage,
    isSubmitting,
  ];
}