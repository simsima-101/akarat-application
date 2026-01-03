// lib/features/agent/presentation/bloc/agent_enquiry_bloc.dart

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;


import '../../../../core/constants/constants.dart' as ApiService;
import 'agent_enquiry_event.dart';
import 'agent_enquiry_state.dart';



class AgentEnquiryBloc extends Bloc<AgentEnquiryEvent, AgentEnquiryState> {
  AgentEnquiryBloc() : super(AgentEnquiryInitial()) {
    on<SendAgentEnquiry>(_onSendAgentEnquiry);
  }

  Future<void> _onSendAgentEnquiry(
      SendAgentEnquiry event,
      Emitter<AgentEnquiryState> emit,
      ) async {
    emit(AgentEnquiryLoading());

    try {
      // Exact same endpoint as in your Provider
      final uri = Uri.parse('${ApiService.baseUrl}/send-agent-email');

      final payload = {
        "agent_id": event.agentId,
        "name": event.name,
        "email": event.email,
        "phone": event.phone,
        "message": event.message.isEmpty ? "-" : event.message,
        "contact_type": "email",
      };

      if (event.deviceId != null && event.deviceId!.isNotEmpty) {
        payload["device_id"] = event.deviceId!;
      }

      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      if (event.deviceId != null && event.deviceId!.isNotEmpty) {
        headers['X-Device-ID'] = event.deviceId!;
      }

      if (event.token != null && event.token!.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${event.token}';
      }

      debugPrint("Sending agent email via Bloc");
      debugPrint("URL: $uri");
      debugPrint("Payload: $payload");

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(payload),
      );

      debugPrint("Agent email response ${response.statusCode}: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final message = jsonResponse['message'] ?? "Message sent successfully!";
        emit(AgentEnquirySuccess(message: message));
      } else {
        final jsonResponse = jsonDecode(response.body);
        final error = jsonResponse['message'] ?? "Failed to send message";
        emit(AgentEnquiryFailure(error: error));
      }
    } catch (e, stackTrace) {
      debugPrint("Exception in AgentEnquiryBloc: $e\n$stackTrace");
      emit(const AgentEnquiryFailure(error: "Network error. Please try again."));
    }
  }
}