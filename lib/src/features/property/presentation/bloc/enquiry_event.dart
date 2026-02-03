// lib/src/features/property/presentation/bloc/enquiry_event.dart

part of 'enquiry_bloc.dart';

abstract class EnquiryEvent extends Equatable {
  const EnquiryEvent();

  @override
  List<Object?> get props => [];
}

class SubmitEnquiry extends EnquiryEvent {
  final int propertyId;
  final String name;
  final String email;
  final String phone;
  final String message;
  final String? deviceId;
  final String token;

  const SubmitEnquiry({
    required this.propertyId,
    required this.name,
    required this.email,
    required this.phone,
    required this.message,
    this.deviceId,
    required this.token,
  });

  @override
  List<Object?> get props => [propertyId, name, email, phone, message, deviceId, token];
}