import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import '../model/agencypropertiesmodel.dart';

class ApiService {
  // Make sure baseUrl has NO trailing slash
  static const String baseUrl = "https://akarat.com/api";

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
    final cleanBase =
    baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanEndpoint =
    endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    var uri = Uri.parse('$cleanBase/$cleanEndpoint');
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
      String endpoint, Map<String, dynamic> body) async {
    final url = _buildUri(endpoint);
    return await http
        .post(url, headers: _jsonHeaders, body: jsonEncode(body))
        .timeout(_timeout);
  }

  static Future<http.Response> _postAuth(
      String endpoint, String token, Map<String, dynamic> body) async {
    final url = _buildUri(endpoint);
    return await http
        .post(url, headers: _authHeaders(token), body: jsonEncode(body))
        .timeout(_timeout);
  }

  static Future<http.Response> _get(String endpoint,
      [Map<String, String>? qs]) async {
    final url = _buildUri(endpoint, qs);
    return await http.get(url, headers: _jsonHeaders).timeout(_timeout);
  }

  static Future<http.Response> _getAuth(String endpoint, String token,
      [Map<String, String>? qs]) async {
    final url = _buildUri(endpoint, qs);
    return await http
        .get(url, headers: _authHeaders(token))
        .timeout(_timeout);
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

  /// Step 1 (REGISTER): Send OTP to email (backend requires GET).
  static Future<Map<String, dynamic>> sendRegisterOtp({required String email}) async {
    final resp = await _get('/register/send-otp', {'email': _normEmail(email)});
    // 🔎 add logging
    // ignore: avoid_print
    print('sendRegisterOtp -> ${resp.statusCode} ${resp.body}');
    final data = _decodeMap(resp.body);

    // Some APIs return 200 even when throttled (“OTP already sent, wait Xs”)
    if (resp.statusCode == 200) return data;

    final msg = (data['message'] ?? data['error'] ?? 'Failed to send OTP') as String;
    throw Exception('$msg (HTTP ${resp.statusCode})');
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

  /// Optional: resend during registration
  static Future<void> resendRegisterOtp({required String email}) async {
    await sendRegisterOtp(email: email);
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
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {'Authorization': 'Bearer $token'},
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ));
    final r = await dio.post('/logout');
    if (r.statusCode != 200) throw Exception('Logout failed');
  }

  // =========================================================
  // Forgot / Reset Password (OTP)
  // =========================================================

  /// Step 1 (RESET): trigger OTP
  static Future<bool> forgotPassword(String email) async {
    final resp = await _post('/forgot-password', {"email": _normEmail(email)});
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
  // Properties & other existing calls
  // =========================================================

  static Future<List<Property>> getSavedProperties(String token) async {
    final resp = await _getAuth('/saved-property-list', token);
    if (resp.statusCode == 200) {
      final decoded = _decodeMap(resp.body);
      final list = (decoded['data'] != null && decoded['data']['data'] != null)
          ? (decoded['data']['data'] as List<dynamic>)
          : <dynamic>[];
      return list.map((e) => Property.fromJson(e)).toList();
    }
    throw Exception('Failed to get saved properties');
  }

  static Future<bool> toggleSavedProperty(String token, int propertyId) async {
    final resp = await _postAuth('/toggle-saved-property', token, {"property_id": propertyId});
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
    final resp = await _get('/featured-properties', {"page": page.toString()});
    if (resp.statusCode == 200) return _decodeList(resp.body);
    throw Exception('Failed to get featured properties');
  }

  static Future<List<dynamic>> getFilteredProperties(Map<String, String> filters) async {
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
