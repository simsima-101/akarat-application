// lib/providers/email_enquiry_provider.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';

class EmailEnquiryProvider extends ChangeNotifier {
  bool isSubmitting = false;
  String? lastError;
  String? lastMessage;

  // Existing method - for property enquiries
  Future<bool> submitEmailEnquiry({
    required int propertyId,
    required String name,
    required String email,
    required String phone,
    required String message,
    String? deviceId,
    String? token,
  }) async {
    isSubmitting = true;
    lastError = null;
    lastMessage = null;
    notifyListeners();

    final uri = ApiService.buildUri('property-email-enquiry');

    final Map<String, dynamic> payload = {
      "name": name,
      "email": email,
      "phone": phone,
      "property_id": propertyId.toString(),
      "contact_type": "email",
      "message": message,
    };

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (deviceId != null && deviceId.isNotEmpty) {
      headers['X-Device-ID'] = deviceId;
    }
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    debugPrint("Email enquiry (provider)");
    debugPrint("URL = $uri");
    debugPrint("headers = $headers");
    debugPrint("payload = $payload");

    try {
      final res = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(payload),
      );

      debugPrint('Email enquiry response ${res.statusCode}: ${res.body}');

      Map<String, dynamic> data = {};
      try {
        if (res.body.isNotEmpty) {
          data = jsonDecode(res.body) as Map<String, dynamic>;
        }
      } catch (e) {
        debugPrint('Failed to decode response JSON: $e');
      }

      final bool ok = res.statusCode == 200 && (data['status'] == true || data['success'] == true);

      if (ok) {
        lastMessage = (data['message'] as String?) ?? 'Email enquiry sent successfully';
        return true;
      } else {
        lastError = (data['message'] as String?) ?? 'Failed to submit enquiry. Please try again later.';
        return false;
      }
    } catch (e, st) {
      debugPrint('Email enquiry exception: $e\n$st');
      lastError = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  // ADD THIS METHOD HERE - For sending email to AGENT
  Future<bool> sendAgentEmail({
    required int agentId,
    required String name,
    required String email,
    required String phone,
    required String message,
    required String? deviceId,
    String? token,
  }) async {
    isSubmitting = true;
    lastError = null;
    lastMessage = null;
    notifyListeners();

    try {
      final uri = Uri.parse('${ApiService.baseUrl}/send-agent-email');

      final payload = {
        "agent_id": agentId,
        "name": name,
        "email": email,
        "phone": phone,
        "message": message.isEmpty ? "-" : message,
        "contact_type": "email",
      };

      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      if (deviceId != null && deviceId.isNotEmpty) {
        headers['X-Device-ID'] = deviceId;
      }
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      debugPrint("Sending agent email enquiry");
      debugPrint("URL: $uri");
      debugPrint("Payload: $payload");

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(payload),
      );

      final jsonResponse = jsonDecode(response.body);

      debugPrint("Agent email response ${response.statusCode}: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        lastMessage = jsonResponse['message'] ?? "Message sent successfully!";
        debugPrint("Agent email sent successfully");
        return true;
      } else {
        lastError = jsonResponse['message'] ?? "Failed to send message";
        debugPrint("Agent email failed: ${response.statusCode} - $lastError");
        return false;
      }
    } catch (e, st) {
      lastError = "Network error. Please try again.";
      debugPrint("Exception in sendAgentEmail: $e\n$st");
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }


  // ADD THIS METHOD - For sending email to COMPANY / AGENCY
  Future<bool> sendCompanyEmail({
    required int companyId,
    required String name,
    required String email,
    required String phone,
    required String message,
    String? deviceId,
    String? token,
  }) async {
    isSubmitting = true;
    lastError = null;
    lastMessage = null;
    notifyListeners();

    try {
      final uri = Uri.parse('${ApiService.baseUrl}/send-company-email');

      final payload = {
        "company_id": companyId,
        "name": name,
        "email": email,
        "phone": phone,
        "message": message.isEmpty ? "-" : message,
        "contact_type": "email",
      };

      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      if (deviceId != null && deviceId.isNotEmpty) {
        headers['X-Device-ID'] = deviceId;
      }
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      debugPrint("Sending company email enquiry");
      debugPrint("URL: $uri");
      debugPrint("Payload: $payload");

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(payload),
      );

      final jsonResponse = jsonDecode(response.body);

      debugPrint("Company email response ${response.statusCode}: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        lastMessage = jsonResponse['message'] ?? "Message sent successfully!";
        return true;
      } else {
        lastError = jsonResponse['message'] ?? "Failed to send message";
        return false;
      }
    } catch (e, st) {
      lastError = "Network error. Please try again.";
      debugPrint("Exception in sendCompanyEmail: $e\n$st");
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}