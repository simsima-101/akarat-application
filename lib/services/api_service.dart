// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import '../model/agencypropertiesmodel.dart';

class ApiService {
  /// Overridable at build time:
  ///   flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8020/api
  /// Falls back to PROD if not provided.
  static final String _rawBaseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://akarat.com/api',
  ).replaceFirst(RegExp(r'/+$'), '');

  /// Effective base URL:
  /// - iOS Simulator: uses 127.0.0.1 / localhost as-is (perfect for local dev)
  /// - Android Emulator: rewrites localhost/127.0.0.1 → 10.0.2.2
  static String get _effectiveBaseUrl {
    var url = _rawBaseUrl;
    if (!kIsWeb && Platform.isAndroid &&
        (url.contains('127.0.0.1') || url.contains('localhost'))) {
      try {
        final u = Uri.parse(url);
        final host = (u.host == 'localhost' || u.host == '127.0.0.1')
            ? '10.0.2.2'
            : u.host;
        url = u.replace(host: host).toString();
      } catch (_) {
        url = url
            .replaceFirst('127.0.0.1', '10.0.2.2')
            .replaceFirst('localhost', '10.0.2.2');
      }
    }
    return url;
  }

  static String get baseUrl => _effectiveBaseUrl;

  // Call once (e.g., in main()) to confirm what URL is used.
  static void debugPrintBaseUrl() {
    if (kDebugMode) {
      print('BASE URL (raw):       $_rawBaseUrl');
      print('BASE URL (effective): $_effectiveBaseUrl');
    }
  }

  // ---------- Headers ----------
  static const Map<String, String> _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
    'X-Requested-With': 'XMLHttpRequest',
  };

  static Map<String, String> _authHeaders(String token) => {
    ..._jsonHeaders,
    'Authorization': 'Bearer $token',
  };

  // ---------- Utils ----------
  static Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final cleanEndpoint =
    endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    var uri = Uri.parse('$_effectiveBaseUrl/$cleanEndpoint');
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

  // =========================================================
  // Auth: Register/Login/OTP
  // =========================================================

  // Check if a user exists by email (GET /api/users/check?email=...)
  static Future<bool> checkUserExistsByEmail(String email) async {
    final resp = await _get('/users/check', {'email': _normEmail(email)});
    if (resp.statusCode == 200) {
      final j = _decodeMap(resp.body);
      final v = j['exists'];
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v.toLowerCase() == 'true' || v == '1';
      return false;
    }
    if (resp.statusCode == 422) return false; // invalid/missing email
    throw Exception('Check failed: ${resp.statusCode} ${resp.body}');
  }

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
      return data;
    }
    throw Exception(data['message'] ?? 'Resend OTP failed (${resp.statusCode})');
  }

  /// (Old flow) Just keep for compatibility.
  @Deprecated('Use resendOtp(email: ...) instead.')
  static Future<Map<String, dynamic>> sendRegisterOtp({
    required String email,
  }) async {
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

  /// ✅ Step 2 (REGISTER): Complete signup using the token from verifyOtp.
  /// Include first_name / last_name so backend stores them.
  static Future<Map<String, dynamic>> completeRegistration({
    required String firstName,
    required String lastName,
    required String name, // full name (legacy)
    required String email,
    required String password,
    required String token,
    String? phoneCountryCode,
    String? phone,
  }) async {
    final body = <String, dynamic>{
      "first_name": firstName.trim(),
      "last_name": lastName.trim(),
      "name": name.trim(), // keep for backends still reading `name`
      "email": _normEmail(email),
      "password": password,
      "password_confirmation": password,
      "token": token,
      if ((phoneCountryCode ?? '').trim().isNotEmpty)
        "phone_country_code": phoneCountryCode!.trim(),
      if ((phone ?? '').trim().isNotEmpty) "phone": phone!.trim(),
    };

    final resp = await _post('/register/complete', body);
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
        baseUrl: _effectiveBaseUrl,
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

  static Future<bool> forgotPassword(String email) async {
    final resp = await _post('/forgot-password', {"email": _normEmail(email)});
    return resp.statusCode == 200;
  }

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
  // Registration (OTP kick-off)
  // =========================================================

  static Future<Map<String, dynamic>> registerStart({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneCountryCode, // "971"
    required String phone, // "565356435"
    required String password,
    required String passwordConfirmation,
  }) async {
    final payload = {
      "name": '${firstName.trim()} ${lastName.trim()}'.trim(),
      "first_name": firstName.trim(),
      "last_name": lastName.trim(),
      "email": _normEmail(email),
      "phone_country_code": phoneCountryCode.trim(),
      "phone": phone.trim(),
      "password": password,
      "password_confirmation": passwordConfirmation,
    };

    final resp = await _post('/register', payload);
    final data = _decodeMap(resp.body);

    if (resp.statusCode == 422 && data['errors'] is Map) {
      final errorsMap = data['errors'] as Map;
      final msg = errorsMap.values
          .where((v) => v is List && v.isNotEmpty)
          .map((v) => (v as List).first.toString())
          .join('\n');
      throw Exception(msg.isEmpty ? (data['message'] ?? 'Validation failed') : msg);
    }

    if (resp.statusCode == 409) {
      throw Exception(data['message'] ?? 'This email is already registered.');
    }

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      data['expires_in'] ??= 300; // 5 min default
      data['resend_after'] ??= 60; // 60s default
      return data;
    }

    throw Exception(data['message'] ?? 'Registration failed (${resp.statusCode})');
  }

  // =========================================================
  // Profile helpers
  // =========================================================

  /// ✅ Fetch current user profile. Normalizes the most common shapes.
  static Future<Map<String, dynamic>> getMe(String token) async {
    final resp = await _getAuth('/me', token);
    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch profile: ${resp.statusCode}');
    }
    final data = _decodeMap(resp.body);

    dynamic _pick(List<List<String>> paths) {
      for (final p in paths) {
        dynamic cur = data;
        for (final k in p) {
          if (cur is Map && cur.containsKey(k)) {
            cur = cur[k];
          } else {
            cur = null;
            break;
          }
        }
        if (cur != null) return cur;
      }
      return null;
    }

    final first = (_pick([
      ['first_name'],
      ['data', 'first_name'],
      ['user', 'first_name'],
      ['data', 'user', 'first_name'],
    ]) ??
        '')
        .toString()
        .trim();

    final last = (_pick([
      ['last_name'],
      ['data', 'last_name'],
      ['user', 'last_name'],
      ['data', 'user', 'last_name'],
    ]) ??
        '')
        .toString()
        .trim();

    String name = (_pick([
      ['name'],
      ['data', 'name'],
      ['user', 'name'],
      ['data', 'user', 'name'],
    ]) ??
        '')
        .toString()
        .trim();

    final email = (_pick([
      ['email'],
      ['data', 'email'],
      ['user', 'email'],
      ['data', 'user', 'email'],
    ]) ??
        '')
        .toString()
        .trim();

    // If backend only returns `name`, synthesize first/last
    String f = first, l = last;
    if ((f.isEmpty || l.isEmpty) && name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      f = f.isEmpty ? (parts.isNotEmpty ? parts.first : '') : f;
      l = l.isEmpty ? (parts.length > 1 ? parts.sublist(1).join(' ') : '') : l;
    }
    if (name.isEmpty) {
      name = [f, l].where((s) => s.isNotEmpty).join(' ').trim();
    }

    return {
      'first_name': f,
      'last_name': l,
      'name': name,
      'email': email,
      'raw': data,
    };
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
    throw Exception(
        'Failed to get saved properties: ${resp.statusCode} ${resp.body}');
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
    final resp = await _get('/featured-properties', {"page": page.toString()});
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

  // ---------- Generic HTTP ----------
  static Future<http.Response> _post(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    final url = _buildUri(endpoint);
    final resp =
    await http.post(url, headers: _jsonHeaders, body: jsonEncode(body)).timeout(_timeout);
    if (kDebugMode) {
      print('[POST] $url -> ${resp.statusCode} ${resp.body}');
    }
    return resp;
  }

  static Future<http.Response> _postAuth(
      String endpoint,
      String token,
      Map<String, dynamic> body,
      ) async {
    if (token.isEmpty) {
      throw Exception('No auth token present for $_effectiveBaseUrl$endpoint');
    }
    final url = _buildUri(endpoint);
    final resp = await http
        .post(url, headers: _authHeaders(token), body: jsonEncode(body))
        .timeout(_timeout);
    if (kDebugMode) {
      print('[POST*] $url -> ${resp.statusCode} ${resp.body}');
    }
    if (resp.statusCode == 401) {
      throw Exception('Unauthorized (401) on $url');
    }
    return resp;
  }

  static Future<http.Response> _getAuth(
      String endpoint,
      String token, [
        Map<String, String>? qs,
      ]) async {
    if (token.isEmpty) {
      throw Exception('No auth token present for $_effectiveBaseUrl$endpoint');
    }
    final url = _buildUri(endpoint, qs);
    final resp =
    await http.get(url, headers: _authHeaders(token)).timeout(_timeout);
    if (kDebugMode) {
      print('[GET*] $url -> ${resp.statusCode} ${resp.body}');
    }
    if (resp.statusCode == 401) {
      throw Exception('Unauthorized (401) on $url');
    }
    return resp;
  }

  static Future<http.Response> _get(
      String endpoint, [
        Map<String, String>? qs,
      ]) async {
    final url = _buildUri(endpoint, qs);
    final resp = await http.get(url, headers: _jsonHeaders).timeout(_timeout);
    if (kDebugMode) {
      print('[GET]  $url -> ${resp.statusCode} ${resp.body}');
    }
    return resp;
  }

  // ===== Alerts/Saved Searches =====
  static Future<Map<String, dynamic>> createAlert(
      String token, {
        required String name,
        required String frequency,
        required String purpose,
        required String propertyType,
        Map<String, dynamic>? extra, // min_price, max_price, etc.
      }) async {
    final body = {
      "name": name.trim(),
      "frequency": frequency.trim(),
      "purpose": purpose.trim(),
      "property_type": propertyType.trim(),
      if (extra != null) ...extra,
    };
    final resp = await _postAuth('/alerts', token, body);
    final data = _decodeMap(resp.body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) return data;
    throw Exception(
        data['message'] ?? 'Failed to create alert (${resp.statusCode})');
  }

  static Future<List<dynamic>> getSavedSearches(String token) async {
    final resp = await _getAuth('/saved-searches', token);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final decoded = jsonDecode(resp.body);
      if (decoded is List) return decoded;
      if (decoded is Map) {
        if (decoded['data'] is List) return decoded['data'];
        if (decoded['data'] is Map && decoded['data']['data'] is List) {
          return decoded['data']['data'];
        }
        if (decoded['saved_searches'] is List) return decoded['saved_searches'];
      }
      return <dynamic>[];
    }
    final body = _decodeMap(resp.body);
    throw Exception(
        body['message'] ?? 'Failed to fetch saved alerts (${resp.statusCode})');
  }
}
