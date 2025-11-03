// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../model/agencypropertiesmodel.dart';

class ApiService {
  // ------------------------------------------------------------
  // BASE URL RESOLUTION (define > .env > default)
  // ------------------------------------------------------------
  static String get _rawBaseUrl {
    // 1) Compile-time define: --dart-define=API_BASE_URL=...
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.trim().isNotEmpty) {
      return fromDefine.replaceFirst(RegExp(r'/+$'), '');
    }

    // 2) .env at runtime (if loaded in main before first access)
    final fromEnv = (dotenv.env['API_BASE_URL'] ?? '').trim();
    if (fromEnv.isNotEmpty) {
      return fromEnv.replaceFirst(RegExp(r'/+$'), '');
    }

    // 3) Fallback
    return 'https://qa.akarat.com/api';
  }

  /// Effective base URL:
  /// - iOS Simulator: uses given host as-is (localhost/127.0.0.1 are fine).
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
      print('BASE URL (define/env resolved): $_rawBaseUrl');
      print('BASE URL (effective):           $_effectiveBaseUrl');
    }
  }

  // ------------------------------------------------------------
  // HEADERS
  // ------------------------------------------------------------
  static const Map<String, String> _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
    'X-Requested-With': 'XMLHttpRequest',
  };

  static Map<String, String> _authHeaders(String token) => {
    ..._jsonHeaders,
    'Authorization': 'Bearer $token',
  };

  // ------------------------------------------------------------
  // UTILS
  // ------------------------------------------------------------
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
      "name": name.trim(),
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
  // Google SOCIAL AUTH HELPERS
  // =========================================================

  /// POST /social-auth/google (JSON) – if your backend supports a single social entrypoint.
  static Future<Map<String, dynamic>> socialAuthGoogle({
    required String idToken,      // Firebase ID token or Google ID token (as your backend expects)
    String? email,
    String? name,
    String? photo,
    String? providerUid,
  }) async {
    final resp = await _post('/social-auth/google', {
      "id_token": idToken,
      if (email != null && email.isNotEmpty) "email": _normEmail(email),
      if (name != null && name.isNotEmpty) "name": name.trim(),
      if (photo != null && photo.isNotEmpty) "photo": photo.trim(),
      if (providerUid != null && providerUid.isNotEmpty) "provider_uid": providerUid.trim(),
      "provider": "google",
    });
    final data = _decodeMap(resp.body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) return data;
    throw Exception(data['message'] ?? 'Google social auth failed (${resp.statusCode})');
  }

  /// POST /login-google (JSON) – if your backend exposes a dedicated login route.
  static Future<Map<String, dynamic>> loginWithGoogleIdToken(String idToken) async {
    final resp = await _post('/login-google', {"id_token": idToken});
    final data = _decodeMap(resp.body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) return data;
    throw Exception(data['message'] ?? 'Google login failed (${resp.statusCode})');
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

    dynamic pick(List<List<String>> paths) {
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

    final first = (pick([
      ['first_name'],
      ['data', 'first_name'],
      ['user', 'first_name'],
      ['data', 'user', 'first_name'],
    ]) ??
        '')
        .toString()
        .trim();

    final last = (pick([
      ['last_name'],
      ['data', 'last_name'],
      ['user', 'last_name'],
      ['data', 'user', 'last_name'],
    ]) ??
        '')
        .toString()
        .trim();

    String name = (pick([
      ['name'],
      ['data', 'name'],
      ['user', 'name'],
      ['data', 'user', 'name'],
    ]) ??
        '')
        .toString()
        .trim();

    final email = (pick([
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
    final resp =
    await _postAuth('/toggle-saved-property', token, {"property_id": propertyId});
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
    final resp = await _postForm('/contact', {
      'name'   : name.trim(),
      'email'  : _normEmail(email),
      'phone'  : phone.trim(),
      'subject': subject.trim(),
      'message': message.trim(),
    });
    if (kDebugMode) {
      print('[POST-FORM] ${resp.request?.url} -> ${resp.statusCode} ${resp.body}');
    }
    return resp.statusCode == 200 || resp.statusCode == 201;
  }



  // static Future<bool> submitContactForm({
  //   required String name,
  //   required String email,
  //   required String phone,
  //   required String subject,
  //   required String message,
  // }) async {
  //   final resp = await _post('/contact', {
  //     "name": name.trim(),
  //     "email": _normEmail(email),
  //     "phone": phone.trim(),
  //     "subject": subject.trim(),
  //     "message": message.trim(),
  //   });
  //   return resp.statusCode == 200 || resp.statusCode == 201;
  // }

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
      print('[POST]  $url -> ${resp.statusCode} ${resp.body}');
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
      print('[GET*]  $url -> ${resp.statusCode} ${resp.body}');
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
      print('[GET]   $url -> ${resp.statusCode} ${resp.body}');
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

  // --- Helpers for form-encoded posting (Laravel friendly) ---
  static const Map<String, String> _formHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/x-www-form-urlencoded',
    'X-Requested-With': 'XMLHttpRequest',
  };

  static Future<http.Response> _postForm(String endpoint, Map<String, String> fields) async {
    final url = _buildUri(endpoint);
    final resp = await http.post(url, headers: _formHeaders, body: fields).timeout(_timeout);
    if (kDebugMode) print('[POST-FORM] $url -> ${resp.statusCode} ${resp.body}');
    return resp;
  }

// --- Google backend exchange attempts with rich logs ---
  static Future<String?> tryLoginGoogle(String idToken) async {
    // 1) /login-google  (JSON: { id_token })
    try {
      final r = await _post('/login-google', {'id_token': idToken});
      if (kDebugMode) print('[/login-google] -> ${r.statusCode} ${r.body}');
      if (r.statusCode >= 200 && r.statusCode < 300) {
        final m = _decodeMap(r.body);
        final t = ((m['token'] ?? m['access_token'] ?? m['data']?['token'] ?? m['data']?['access_token']) ?? '').toString();
        if (t.isNotEmpty) return t;
      }
    } catch (e) {
      if (kDebugMode) print('[/login-google] error: $e');
    }
    return null;
  }

  static Future<String?> trySocialAuthGoogle({
    required String idToken,
    required String email,
    required String name,
    required String photo,
    required String providerUid,
  })  async {
    try {
      final r = await _post('/social-auth/google', {
        'id_token': idToken,
        if (email != null && email.isNotEmpty) 'email': _normEmail(email),
        if (name  != null && name .isNotEmpty) 'name' : name.trim(),
        if (photo != null && photo.isNotEmpty) 'photo': photo.trim(),
        if (providerUid != null && providerUid.isNotEmpty) 'provider_uid': providerUid.trim(),
        'provider': 'google',
      });
      if (kDebugMode) print('[/social-auth/google] -> ${r.statusCode} ${r.body}');
      if (r.statusCode >= 200 && r.statusCode < 300) {
        final m = _decodeMap(r.body);
        final t = ((m['token'] ?? m['access_token'] ?? m['data']?['token'] ?? m['data']?['access_token']) ?? '').toString();
        if (t.isNotEmpty) return t;
      }
    } catch (e) {
      if (kDebugMode) print('[/social-auth/google] error: $e');
    }
    return null;
  }

  static Future<bool> tryRegisterGoogleShadow({
    required String name,
    required String email,
    required String password,
    String? providerUid,
  }) async {
    try {
      final r = await _post('/register', {
        'name': name.trim(),
        'email': _normEmail(email),
        'password': password,
        'password_confirmation': password,
        'provider': 'google',
        if (providerUid != null && providerUid.isNotEmpty) 'provider_uid': providerUid,
      });
      if (kDebugMode) print('[/register] -> ${r.statusCode} ${r.body}');
      return r.statusCode >= 200 && r.statusCode < 300;
    } catch (e) {
      if (kDebugMode) print('[/register] error: $e');
      return false;
    }
  }

  /// Tries /login with JSON, then falls back to x-www-form-urlencoded.
  static Future<String?> tryPasswordLoginBothEncodings({
    required String email,
    required String password,
  }) async {
    // JSON first
    try {
      final r1 = await _post('/login', {'email': _normEmail(email), 'password': password});
      if (kDebugMode) print('[/login JSON] -> ${r1.statusCode} ${r1.body}');
      if (r1.statusCode >= 200 && r1.statusCode < 300) {
        final m = _decodeMap(r1.body);
        final t = ((m['token'] ?? m['access_token'] ?? m['data']?['token'] ?? m['data']?['access_token']) ?? '').toString();
        if (t.isNotEmpty) return t;
      }
    } catch (e) {
      if (kDebugMode) print('[/login JSON] error: $e');
    }

    // Then FORM
    try {
      final r2 = await _postForm('/login', {
        'email': _normEmail(email),
        'password': password,
      });
      if (kDebugMode) print('[/login FORM] -> ${r2.statusCode} ${r2.body}');
      if (r2.statusCode >= 200 && r2.statusCode < 300) {
        final m = _decodeMap(r2.body);
        final t = ((m['token'] ?? m['access_token'] ?? m['data']?['token'] ?? m['data']?['access_token']) ?? '').toString();
        if (t.isNotEmpty) return t;
      }
    } catch (e) {
      if (kDebugMode) print('[/login FORM] error: $e');
    }
    return null;
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
