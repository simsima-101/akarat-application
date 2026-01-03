// part of agent_enquiry_bloc.dart

import 'package:equatable/equatable.dart';

abstract class AgentEnquiryEvent extends Equatable {
  const AgentEnquiryEvent();

  @override
  List<Object?> get props => [];
}

class SendAgentEnquiry extends AgentEnquiryEvent {
  final int agentId;
  final String name;
  final String email;
  final String phone;
  final String message;
  final String? deviceId;
  final String? token;

  const SendAgentEnquiry({
    required this.agentId,
    required this.name,
    required this.email,
    required this.phone,
    required this.message,
    this.deviceId,
    this.token,
  });

  @override
  List<Object?> get props => [
    agentId,
    name,
    email,
    phone,
    message,
    deviceId,
    token,
  ];
}