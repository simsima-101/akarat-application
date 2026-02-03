// lib/src/features/property/presentation/bloc/enquiry_bloc.dart

import 'dart:convert';

import 'package:equatable/equatable.dart'; // ← THIS WAS MISSING – now added
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/api_service.dart';
import '../../../../utils/shared_preference_manager.dart';

// ====================== EVENTS ======================
part 'enquiry_event.dart';   // ← move events here (see below)

// ====================== STATES ======================
part 'enquiry_state.dart';   // ← move states here (see below)

// ====================== BLOC ======================
class EnquiryBloc extends Bloc<EnquiryEvent, EnquiryState> {
  final SharedPreferencesManager prefManager = SharedPreferencesManager();

  EnquiryBloc() : super(const EnquiryInitial()) {
    on<SubmitEnquiry>(_onSubmitEnquiry);
  }

  Future<void> _onSubmitEnquiry(
      SubmitEnquiry event,
      Emitter<EnquiryState> emit,
      ) async {
    emit(const EnquiryLoading());

    try {
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final msg = json['message']?.toString() ?? 'Enquiry sent successfully';
        emit(EnquirySuccess(msg));
      } else {
        final errorMsg = jsonDecode(response.body)['message']?.toString() ??
            'Failed: ${response.statusCode}';
        emit(EnquiryFailure(errorMsg));
      }
    } catch (e) {
      emit(EnquiryFailure('Network error: $e'));
    }
  }
}