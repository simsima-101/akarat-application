import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/api_service.dart';
import '../../../../utils/shared_preference_manager.dart';

// ====================== EVENTS ======================
abstract class EnquiryEvent {}

class SubmitEnquiry extends EnquiryEvent {
  final int propertyId;
  final String name;
  final String email;
  final String phone;
  final String message;
  final String? deviceId;
  final String token;

  SubmitEnquiry({
    required this.propertyId,
    required this.name,
    required this.email,
    required this.phone,
    required this.message,
    this.deviceId,
    required this.token,
  });
}

// ====================== STATES ======================
abstract class EnquiryState {}

class EnquiryInitial extends EnquiryState {}

class EnquiryLoading extends EnquiryState {}

class EnquirySuccess extends EnquiryState {
  final String message;
  EnquirySuccess(this.message);
}

class EnquiryFailure extends EnquiryState {
  final String error;
  EnquiryFailure(this.error);
}

// ====================== BLOC ======================
class EnquiryBloc extends Bloc<EnquiryEvent, EnquiryState> {
  final SharedPreferencesManager prefManager = SharedPreferencesManager();

  EnquiryBloc() : super(EnquiryInitial()) {
    on<SubmitEnquiry>(_onSubmitEnquiry);
  }

  Future<void> _onSubmitEnquiry(
      SubmitEnquiry event, Emitter<EnquiryState> emit) async {
    emit(EnquiryLoading());

    try {
      // final url = ApiService.buildUri('email-enquiry');
      //
      // final response = await http.post(
      //   url,
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'property_id': event.propertyId,
      //     'name': event.name,
      //     'email': event.email,
      //     'phone': event.phone,
      //     'message': event.message.isEmpty ? '-' : event.message,
      //     'device_id': event.deviceId ?? 'unknown', // ← Safe fallback
      //     'token': event.token,
      //   }),
      // );

      final response = await ApiService.post(
        'email-enquiry',
        body: {
          'property_id': event.propertyId,
          'name': event.name,
          'email': event.email,
          'phone': event.phone,
          'message': event.message.isEmpty ? '-' : event.message,
          'device_id': event.deviceId ?? 'unknown',
          'token': event.token,
        },
      );

      // ... rest unchanged
    } catch (e) {
      emit(EnquiryFailure('Network error: $e'));
    }
  }
}
