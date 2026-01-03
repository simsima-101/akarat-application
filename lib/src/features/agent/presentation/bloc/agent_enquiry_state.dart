// part of agent_enquiry_bloc.dart

import 'package:equatable/equatable.dart';

abstract class AgentEnquiryState extends Equatable {
  const AgentEnquiryState();

  @override
  List<Object?> get props => [];
}

class AgentEnquiryInitial extends AgentEnquiryState {}

class AgentEnquiryLoading extends AgentEnquiryState {}

class AgentEnquirySuccess extends AgentEnquiryState {
  final String message;
  const AgentEnquirySuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AgentEnquiryFailure extends AgentEnquiryState {
  final String error;
  const AgentEnquiryFailure({required this.error});

  @override
  List<Object?> get props => [error];
}