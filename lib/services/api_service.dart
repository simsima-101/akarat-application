// lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import '../model/agencypropertiesmodel.dart';

class ApiService {
  /// Base URL is overridable at build time:
  ///   flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
  /// If not provided, it falls back to PROD.
  static final String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://akarat.com/api',
  ).replaceFirst(RegExp(r'/+$'), '');

  // Call this once (e.g., in main()) if you want a startup log.
  static void debugPrintBaseUrl() {
    if (kDebugMode) {
      // ignore: avoid_print
      print('BASE URL: $baseUrl');
    }
  }

  // ---------- Headers ----------
  static const Map<String, String> _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
  };

  static Map<String, String> _authHeaders(String token) => {
    ..._jsonHeaders,
    'Authorization': 'Bearer $token',
  };

  // ---------- Utils ----------
  static Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final cleanEndpoint =
    endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    var uri = Uri.parse('$baseUrl/$cleanEndpoint');
    if (queryParams != null) uri = uri.replace(queryParameters: queryParams);
    return uri;
  }

  static Map<String, dynamic> _decodeMap(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  /// Safely extract a List from common API shapes:
  /// [], { data: [] }, { data: { data: [] } }
  static List<dynamic> _decodeList(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is List) return decoded;
      if (decoded is Map && decoded['data'] is List) {
        return decoded['data'] as List<dynamic>;
      }
      if (decoded is Map &&
          decoded['data'] is Map &&
          (decoded['data'] as Map)['data'] is List) {
        return (decoded['data'] as Map)['data'] as List<dynamic>;
      }
      return <dynamic>[];
    } catch (_) {
      return <dynamic>[];
    }
  }

  static String _normEmail(String email) => email.trim().toLowerCase();

  // Timeouts for all http.* calls
  static const _timeout = Duration(seconds: 25);

  // ---------- Generic HTTP ----------
  static Future<http.Response> _post(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    final url = _buildUri(endpoint);
    final resp = await http
        .post(url, headers: _jsonHeaders, body: jsonEncode(body))
        .timeout(_timeout);
    if (kDebugMode) {
      // ignore: avoid_print
      print('[POST] $url -> ${resp.statusCode} ${resp.body}');
    }
    return resp;
  }

  static Future<http.Response> _postAuth(
      String endpoint,
      String token,
      Map<String, dynamic> body,
      ) async {
    final url = _buildUri(endpoint);
    final resp = await http
        .post(url, headers: _authHeaders(token), body: jsonEncode(body))
        .timeout(_timeout);
    if (kDebugMode) {
      // ignore: avoid_print
      print('[POST*] $url -> ${resp.statusCode} ${resp.body}');
    }
    return resp;
  }

  static Future<http.Response> _get(
      String endpoint, [
        Map<String, String>? qs,
      ]) async {
    final url = _buildUri(endpoint, qs);
    final resp =
    await http.get(url, headers: _jsonHeaders).timeout(_timeout);
    if (kDebugMode) {
      // ignore: avoid_print
      print('[GET]  $url -> ${resp.statusCode} ${resp.body}');
    }
    return resp;
  }

  static Future<http.Response> _getAuth(
      String endpoint,
      String token, [
        Map<String, String>? qs,
      ]) async {
    final url = _buildUri(endpoint, qs);
    final resp = await http
        .get(url, headers: _authHeaders(token))
        .timeout(_timeout);
    if (kDebugMode) {
      // ignore: avoid_print
      print('[GET*] $url -> ${resp.statusCode} ${resp.body}');
    }
    return resp;
  }

  // =========================================================
  // Auth: Register/Login/OTP
  // =========================================================

  /// (Legacy) Direct registration WITHOUT OTP.
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final resp = await _post('/register', {
      "name": name.trim(),
      "email": _normEmail(email),
      "password": password,
      "password_confirmation": passwordConfirmation,
    });

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return _decodeMap(resp.body);
    }
    throw Exception('Failed to register user: ${resp.body}');
  }

  /// 🔁 Canonical resend endpoint (POST /api/resend-otp)
  static Future<Map<String, dynamic>> resendOtp({
    required String email,
  }) async {
    final resp = await _post('/resend-otp', {"email": _normEmail(email)});
    final data = _decodeMap(resp.body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      // e.g. { message, resend_after, expires_in, otp_sent: true/false }
      return data;
    }
    throw Exception(data['message'] ?? 'Resend OTP failed (${resp.statusCode})');
  }

  /// (Old flow some backends exposed) GET /register/send-otp
  @Deprecated('Use resendOtp(email: ...) instead.')
  static Future<Map<String, dynamic>> sendRegisterOtp({
    required String email,
  }) async {
    // Keep this shim so existing UI doesn’t break; call the new endpoint.
    return resendOtp(email: email);
  }

  /// Verify OTP (shared by REGISTER + RESET). Returns short-lived token.
  static Future<String> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final resp = await _post('/verify-otp', {
      "email": _normEmail(email),
      "otp": otp.trim(),
    });
    final data = _decodeMap(resp.body);
    if (resp.statusCode == 200 && data['token'] != null) {
      return data['token'].toString();
    }
    throw Exception(data['message'] ?? 'Invalid or expired OTP');
  }

  /// Step 2 (REGISTER): Complete signup using the token from verifyOtp.
  static Future<Map<String, dynamic>> completeRegistration({
    required String name,
    required String email,
    required String password,
    required String token,
  }) async {
    final resp = await _post('/register/complete', {
      "name": name.trim(),
      "email": _normEmail(email),
      "password": password,
      "password_confirmation": password,
      "token": token,
    });
    final data = _decodeMap(resp.body);
    if (resp.statusCode == 200) return data;
    throw Exception(data['message'] ?? 'Registration failed');
  }

  // ---------- Login / Logout ----------
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final resp = await _post('/login', {
      "email": _normEmail(email),
      "password": password,
    });

    if (resp.statusCode == 200) return _decodeMap(resp.body);
    throw Exception('Login failed: ${resp.body}');
  }

  static Future<void> logoutUser(String token) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Authorization': 'Bearer $token'},
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    final r = await dio.post('/logout');
    if (r.statusCode != 200) throw Exception('Logout failed');
  }

  // =========================================================
  // Forgot / Reset Password (OTP)
  // =========================================================

  /// Step 1 (RESET): trigger OTP
  static Future<bool> forgotPassword(String email) async {
    final resp =
    await _post('/forgot-password', {"email": _normEmail(email)});
    return resp.statusCode == 200;
  }

  /// Step 2 (RESET): after verifyOtp -> token, then call this to set new password
  static Future<bool> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final resp = await _post('/reset-password', {
      "email": _normEmail(email),
      "token": token,
      "password": password,
      "password_confirmation": passwordConfirmation,
    });

    final data = _decodeMap(resp.body);
    if (resp.statusCode == 200) {
      if (data['success'] == true ||
          data['status'] == 'success' ||
          data['message'] == 'Password reset successful.') {
        return true;
      }
      return true;
    }
    return false;
  }

  // =========================================================
  // Registration (with OTP kick-off)
  // =========================================================

  /// Starts registration AND (backend should) send OTP (POST /api/register)
  /// Returns whatever the backend returns; we only normalize timers.
  static Future<Map<String, dynamic>> registerStart({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneCountryCode, // e.g. "971"
    required String phone, // e.g. "565356435"
    required String password,
    required String passwordConfirmation,
  }) async {
    final payload = {
      "name": '${firstName.trim()} ${lastName.trim()}'.trim(),
      "first_name": firstName.trim(), // ok if backend ignores
      "last_name": lastName.trim(), // ok if backend ignores
      "email": _normEmail(email),
      "phone_country_code": phoneCountryCode.trim(),
      "phone": phone.trim(),
      "password": password,
      "password_confirmation": passwordConfirmation,
    };

    final resp = await _post('/register', payload);
    final data = _decodeMap(resp.body);

    // 422 validation
    if (resp.statusCode == 422 && data['errors'] is Map) {
      final errorsMap = data['errors'] as Map;
      final msg = errorsMap.values
          .where((v) => v is List && v.isNotEmpty)
          .map((v) => (v as List).first.toString())
          .join('\n');
      throw Exception(
          msg.isEmpty ? (data['message'] ?? 'Validation failed') : msg);
    }

    // 409 conflict (email exists, etc.)
    if (resp.statusCode == 409) {
      throw Exception(
          data['message'] ?? 'This email is already registered.');
    }

    // Success range: trust the backend's flags. DO NOT invent otp_sent.
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      data['expires_in'] ??= 300; // 5 min default
      data['resend_after'] ??= 60; // 60s default
      return data;
    }

    throw Exception(
        data['message'] ?? 'Registration failed (${resp.statusCode})');
  }

  // =========================================================
  // Properties & other existing calls
  // =========================================================

  static Future<List<Property>> getSavedProperties(String token) async {
    final resp = await _getAuth('/saved-property-list', token);
    if (resp.statusCode == 200) {
      final decoded = _decodeMap(resp.body);
      final list = (decoded['data'] != null &&
          decoded['data']['data'] != null)
          ? (decoded['data']['data'] as List<dynamic>)
          : <dynamic>[];
      return list.map((e) => Property.fromJson(e)).toList();
    }
    throw Exception('Failed to get saved properties');
  }

  static Future<bool> toggleSavedProperty(
      String token,
      int propertyId,
      ) async {
    final resp = await _postAuth(
        '/toggle-saved-property', token, {"property_id": propertyId});
    return resp.statusCode == 200;
  }

  static Future<List<dynamic>> getAgents({int page = 1}) async {
    final resp = await _get('/agents', {"page": page.toString()});
    if (resp.statusCode == 200) return _decodeList(resp.body);
    throw Exception('Failed to get agents');
  }

  static Future<Map<String, dynamic>> getAgentDetails(int id) async {
    final resp = await _get('/agent/$id');
    if (resp.statusCode == 200) return _decodeMap(resp.body);
    throw Exception('Failed to get agent details');
  }

  static Future<List<dynamic>> getFeaturedProperties({int page = 1}) async {
    final resp =
    await _get('/featured-properties', {"page": page.toString()});
    if (resp.statusCode == 200) return _decodeList(resp.body);
    throw Exception('Failed to get featured properties');
  }

  static Future<List<dynamic>> getFilteredProperties(
      Map<String, String> filters) async {
    final resp = await _get('/filters', filters);
    if (resp.statusCode == 200) return _decodeList(resp.body);
    throw Exception('Failed to get filtered properties');
  }

  static Future<bool> submitContactForm({
    required String name,
    required String email,
    required String phone,
    required String subject,
    required String message,
  }) async {
    final resp = await _post('/contact', {
      "name": name.trim(),
      "email": _normEmail(email),
      "phone": phone.trim(),
      "subject": subject.trim(),
      "message": message.trim(),
    });
    return resp.statusCode == 200 || resp.statusCode == 201;
  }
}
