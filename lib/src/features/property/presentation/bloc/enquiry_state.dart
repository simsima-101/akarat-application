// lib/src/features/property/presentation/bloc/enquiry_state.dart

part of 'enquiry_bloc.dart';

enum EnquiryStatus { initial, loading, success, failure }

class EnquiryState extends Equatable {
  final EnquiryStatus status;
  final String? message;

  const EnquiryState({
    this.status = EnquiryStatus.initial,
    this.message,
  });

  EnquiryState copyWith({
    EnquiryStatus? status,
    String? message,
  }) {
    return EnquiryState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  bool get isSubmitting => status == EnquiryStatus.loading;
  bool get isSuccess => status == EnquiryStatus.success;
  bool get isFailure => status == EnquiryStatus.failure;

  @override
  List<Object?> get props => [status, message];
}

class EnquiryInitial extends EnquiryState {
  const EnquiryInitial();
}

class EnquiryLoading extends EnquiryState {
  const EnquiryLoading();
}

class EnquirySuccess extends EnquiryState {
  const EnquirySuccess(String message)
      : super(status: EnquiryStatus.success, message: message);
}

class EnquiryFailure extends EnquiryState {
  const EnquiryFailure(String message)
      : super(status: EnquiryStatus.failure, message: message);
}