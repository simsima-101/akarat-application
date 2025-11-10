// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../model/agencypropertiesmodel.dart'; // for Property
import '../secure_storage.dart'; // so we can read/write api_host

class ApiService {
  // =========================================================
  // BASE URL RESOLUTION (define > .env > runtime override > default)
  // =========================================================

  // In-memory runtime override (set after login to lock host: QA/PROD)
  static String? _runtimeBaseUrl;

  /// Call this right after a successful login to pin the host used there.
  /// Example: ApiService.setRuntimeBase('https://qa.akarat.com/api');
  static void setRuntimeBase(String base) {
    final clean = base.trim().replaceFirst(RegExp(r'/+$'), '');
    _runtimeBaseUrl = clean;

    // Persist so future app runs reuse the same host.
    SecureStorage.write('api_host', clean);
    if (kDebugMode) {
      print('ApiService runtime base set → $_runtimeBaseUrl');
    }
  }

  /// Clears the runtime override (e.g., on logout)
  static void clearRuntimeBase() {
    _runtimeBaseUrl = null;
    SecureStorage.delete('api_host');
    if (kDebugMode) print('ApiService runtime base cleared.');
  }

  /// Best-effort: read persisted host from storage on app start (call once in main()).
  static Future<void> ensureBaseFromStorage() async {
    if (_runtimeBaseUrl != null) return;
    final stored = (await SecureStorage.read('api_host'))?.trim();
    if (stored != null && stored.isNotEmpty) {
      _runtimeBaseUrl = stored.replaceFirst(RegExp(r'/+$'), '');
      if (kDebugMode) {
        print(
          'ApiService restored runtime base from storage → $_runtimeBaseUrl',
        );
      }
    }
  }

  // 1) Compile-time define / dart-define
  static String get _rawBaseUrl {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.trim().isNotEmpty) {
      return fromDefine.replaceFirst(RegExp(r'/+$'), '');
    }

    // 2) .env at runtime (if loaded in main before first access)
    final fromEnv = (dotenv.env['API_BASE_URL'] ?? '').trim();
    if (fromEnv.isNotEmpty) {
      return fromEnv.replaceFirst(RegExp(r'/+$'), '');
    }

    // 3) Fallback → default to QA
    return 'https://qa.akarat.com/api';
  }

  /// Returns the currently effective base:
  /// - prefers in-memory runtime override (pinned host),
  /// - else compile/env value,
  /// - Android emulator localhost rewrite is applied.
  static String get _effectiveBaseUrl {
    var url = (_runtimeBaseUrl ?? _rawBaseUrl);

    // Android emulator localhost adjustment
    if (!kIsWeb &&
        Platform.isAndroid &&
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

  /// Public base URL getter (rarely needed directly; prefer [buildUri])
  static String get baseUrl => _effectiveBaseUrl;

  /// Call once (e.g., in main()) to confirm what URL is used.
  static void debugPrintBaseUrl() {
    if (kDebugMode) {
      print('BASE URL (define/env):          $_rawBaseUrl');
      print('BASE URL (runtime override):    ${_runtimeBaseUrl ?? '(none)'}');
      print('BASE URL (effective):           $_effectiveBaseUrl');
    }
  }

  // =========================================================
  // HEADERS
  // =========================================================
  static const Map<String, String> _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
    'X-Requested-With': 'XMLHttpRequest',
  };

  static Map<String, String> _authHeaders(String token) => {
    ..._jsonHeaders,
    'Authorization': 'Bearer $token',
  };

  // =========================================================
  // UTILS
  // =========================================================

  static bool _looksJson(http.Response r) {
    final ct = (r.headers['content-type'] ?? '').toLowerCase();
    return ct.contains('application/json');
  }

  static bool _looksHtml(http.Response r) {
    final ct = (r.headers['content-type'] ?? '').toLowerCase();
    if (ct.contains('text/html')) return true;
    final body = r.body.trimLeft();
    return body.startsWith('<!doctype') || body.startsWith('<html');
  }

  /// INTERNAL Uri builder
  static Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final cleanEndpoint =
    endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    var uri = Uri.parse('$_effectiveBaseUrl/$cleanEndpoint');
    if (queryParams != null) uri = uri.replace(queryParameters: queryParams);
    return uri;
  }

  /// PUBLIC Uri builder – use this in other files instead of hard-coding
  /// "https://akarat.com/api/..." or using `$apiBase`.
  ///
  /// Example:
  ///   final url = ApiService.buildUri('toggle-saved-property');
  ///   final url = ApiService.buildUri('properties/$id');
  ///   final url = ApiService.buildUri('saved-property-list', query: {'page': '1'});
  static Uri buildUri(String endpoint, {Map<String, String>? query}) {
    return _buildUri(endpoint, query);
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
  // GOOGLE LOGIN ONLY
  // =========================================================

  static Future<bool> checkUserExistsByEmail(String email) async {
    final normalized = _normEmail(email);
    final resp = await _get('/users/check', {'email': normalized});
    if (resp.statusCode == 200) {
      final j = _decodeMap(resp.body);
      final v = j['exists'];
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v.toLowerCase() == 'true' || v == '1';
      return false;
    }
    if (resp.statusCode == 422 || resp.statusCode == 404) {
      return false;
    }
    throw Exception('Check failed: ${resp.statusCode} ${resp.body}');
  }

  /// Main Google login (sends { "google_id_token": "<Firebase ID token>" }).
  static Future<Map<String, dynamic>> loginWithGoogleIdToken(
      String firebaseIdToken,
      ) async {
    final resp =
    await _post('/login-google', {"google_id_token": firebaseIdToken});

    if (_looksHtml(resp)) {
      throw Exception(
        'Non-JSON from /login-google (HTML). Check API_BASE_URL (QA vs PROD) and route.',
      );
    }

    final data = _decodeMap(resp.body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      // If backend returns host hints (not required), you could pin here:
      // setRuntimeBase(baseUrl);
      return data;
    }
    throw Exception(
      data['message'] ?? 'Google login failed (${resp.statusCode})',
    );
  }

  /// If some legacy caller uses "tryLoginGoogle", keep this safe version.
  static Future<String?> tryLoginGoogle(String firebaseIdToken) async {
    try {
      final r =
      await _post('/login-google', {'google_id_token': firebaseIdToken});
      if (kDebugMode) {
        print('[/login-google] -> ${r.statusCode} ${r.body}');
      }
      if (r.statusCode >= 200 && r.statusCode < 300) {
        final m = _decodeMap(r.body);
        final t = ((m['token'] ??
            m['access_token'] ??
            m['data']?['token'] ??
            m['data']?['access_token']) ??
            '')
            .toString();
        if (t.isNotEmpty) return t;
      }
    } catch (e) {
      if (kDebugMode) print('[/login-google] error: $e');
    }
    return null;
  }

  /// Logout with an existing token.
  static Future<void> logoutUser(String token) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: _effectiveBaseUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    final r = await dio.post('/logout');
    if (r.statusCode != 200) throw Exception('Logout failed');
  }

  // =========================================================
  // DISABLED LEGACY AUTH ENDPOINTS (to avoid accidental calls)
  // =========================================================

  @Deprecated('Disabled: Google login only')
  static Future<Never> socialAuthGoogle({
    required String idToken,
    String? email,
    String? name,
    String? photo,
    String? providerUid,
  }) async {
    throw UnimplementedError(
      '/social-auth/google is not supported. Use /login-google with google_id_token.',
    );
  }

  @Deprecated('Disabled: Google login only')
  static Future<Never> registerUser({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    throw UnimplementedError('/register disabled. Use Google login only.');
  }

  @Deprecated('Disabled: Google login only')
  static Future<Never> loginUser({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError('/login disabled. Use Google login only.');
  }

  @Deprecated('Disabled: Google login only')
  static Future<Never> forgotPassword(String email) async {
    throw UnimplementedError(
      'Password reset disabled. Use Google login only.',
    );
  }

  @Deprecated('Disabled: Google login only')
  static Future<Never> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    throw UnimplementedError(
      'Password reset disabled. Use Google login only.',
    );
  }

  // =========================================================
  // ✅ OTP + REGISTRATION (ENABLED)
  // =========================================================

  /// Start registration (returns normalized shape incl. otp/expires/resendAfter/name/email)
  static Future<Map<String, dynamic>> registerStart({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneCountryCode,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    String? _pick(Map<String, dynamic> map, List<String> paths) {
      for (final p in paths) {
        dynamic cur = map;
        for (final k in p.split('.')) {
          if (cur is Map && cur.containsKey(k)) {
            cur = cur[k];
          } else {
            cur = null;
            break;
          }
        }
        if (cur == null) continue;
        if (cur is String && cur.trim().isNotEmpty) return cur.trim();
        if (cur is num) return cur.toString();
      }
      return null;
    }

    int? _pickInt(Map<String, dynamic> map, List<String> paths) {
      final v = _pick(map, paths);
      if (v == null) return null;
      return int.tryParse(v);
    }

    String? _extractFirstErrorMessage(Map<String, dynamic> data) {
      final errs = data['errors'];
      if (errs is Map) {
        for (final entry in errs.entries) {
          final val = entry.value;
          if (val is List && val.isNotEmpty) return val.first.toString();
          if (val is String && val.isNotEmpty) return val;
        }
      }
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      return null;
    }

    final resp = await _postForm('/register', {
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'email': _normEmail(email),
      'phone_country_code': phoneCountryCode.trim(),
      'phone': phone.trim(),
      'password': password,
      'password_confirmation': passwordConfirmation,
    });

    if (_looksHtml(resp)) {
      throw Exception(
        'Non-JSON from /register. Check API_BASE_URL (QA/PROD) and route mapping.',
      );
    }

    final data = _decodeMap(resp.body);

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final otp = _pick(data, ['otp', 'data.otp', 'meta.otp']);
      final emailOut = _pick(data, ['email', 'data.email', 'user.email']) ??
          _normEmail(email);
      final expiresIn =
          _pickInt(data, ['expires_in', 'meta.expires_in']) ?? 300;
      final resendAfter =
          _pickInt(data, ['resend_after', 'meta.resend_after']) ?? 60;
      final nameOut =
          _pick(data, ['user', 'name', 'data.name']) ?? '$firstName $lastName';

      return {
        'otp': otp,
        'email': emailOut,
        'expires_in': expiresIn,
        'resend_after': resendAfter,
        'user': nameOut,
        'raw': data,
      };
    }

    if (resp.statusCode == 422 || resp.statusCode == 409) {
      final msg = _extractFirstErrorMessage(data) ??
          'This email is already registered or the data is invalid.';
      throw Exception(msg);
    }

    final backendMsg = _extractFirstErrorMessage(data);
    throw Exception(backendMsg ?? 'Registration failed (${resp.statusCode}).');
  }

  /// Verify OTP
  static Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    const candidates = <String>[
      '/verify-otp',
      '/register/verify-otp',
      '/auth/verify-otp',
      '/register/verify',
      '/auth/verify',
    ];

    for (final ep in candidates) {
      final resp = await _postForm(ep, {
        'email': _normEmail(email),
        'otp': otp.trim(),
      });

      if (_looksHtml(resp)) continue;

      final code = resp.statusCode;
      if (code >= 200 && code < 300) {
        final j = _decodeMap(resp.body);
        final success = (j['success'] == true) ||
            (j['verified'] == true) ||
            (j['status']?.toString().toLowerCase() == 'ok') ||
            (j['message']?.toString().toLowerCase().contains('verified') ??
                false);
        return success;
      }

      if (code == 422 || code == 409) {
        final j = _decodeMap(resp.body);
        final msg = (j['message'] ??
            (j['errors'] is Map
                ? (j['errors'] as Map).values.first
                : null))
            ?.toString();
        throw Exception(msg ?? 'Invalid or expired OTP.');
      }

      if (code == 404 || code == 405) continue;
    }

    throw Exception(
      'OTP verify endpoint not found. Ask backend for POST /verify-otp.',
    );
  }

  /// Resend OTP
  static Future<bool> resendOtp({required String email}) async {
    const candidates = <String>[
      '/resend-otp',
      '/register/resend-otp',
      '/auth/resend-otp',
    ];

    for (final ep in candidates) {
      final resp = await _postForm(ep, {'email': _normEmail(email)});
      if (_looksHtml(resp)) continue;

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final j = _decodeMap(resp.body);
        final ok = (j['success'] == true) ||
            (j['status']?.toString().toLowerCase() == 'ok') ||
            (j['message']?.toString().toLowerCase().contains('sent') ??
                false);
        return ok;
      }
      if (resp.statusCode == 404 || resp.statusCode == 405) continue;
      if (resp.statusCode == 422) {
        final j = _decodeMap(resp.body);
        throw Exception(j['message']?.toString() ?? 'Unable to resend OTP.');
      }
    }
    throw Exception(
      'Resend OTP endpoint not found. Ask backend for POST /resend-otp.',
    );
  }

  /// Complete registration (optional token if your backend uses it)
  static Future<Map<String, dynamic>> completeRegistration({
    required String firstName,
    required String lastName,
    required String name,
    required String email,
    required String password,
    String? token,
    String? phoneCountryCode,
    String? phone,
  }) async {
    String? _pick(Map<String, dynamic> map, List<String> paths) {
      for (final p in paths) {
        dynamic cur = map;
        for (final k in p.split('.')) {
          if (cur is Map && cur.containsKey(k)) {
            cur = cur[k];
          } else {
            cur = null;
            break;
          }
        }
        if (cur == null) continue;
        if (cur is String && cur.trim().isNotEmpty) return cur.trim();
        if (cur is num) return cur.toString();
      }
      return null;
    }

    const candidates = <String>[
      '/complete-registration',
      '/register/complete',
      '/auth/register/complete',
    ];

    final fields = <String, String>{
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'name': name.trim().isNotEmpty ? name.trim() : '$firstName $lastName',
      'email': _normEmail(email),
      'password': password,
      if (phoneCountryCode != null && phoneCountryCode.trim().isNotEmpty)
        'phone_country_code': phoneCountryCode.trim(),
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      if (token != null && token.trim().isNotEmpty) 'token': token.trim(),
    };

    for (final ep in candidates) {
      final resp = await _postForm(ep, fields);
      if (_looksHtml(resp)) continue;

      final data = _decodeMap(resp.body);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final t = _pick(data, [
          'token',
          'access_token',
          'data.token',
          'data.access_token',
        ]);

        final userEmail =
            _pick(data, ['email', 'data.email', 'user.email']) ?? email;
        final userName =
            _pick(data, ['user', 'name', 'data.name']) ?? '$firstName $lastName';

        return {
          'token': t, // may be null if backend doesn’t issue at this step
          'email': userEmail,
          'user': userName,
          'raw': data,
        };
      }

      if (resp.statusCode == 422 || resp.statusCode == 409) {
        final msg = (data['message'] ??
            (data['errors'] is Map
                ? (data['errors'] as Map).values.first
                : null))
            ?.toString();
        throw Exception(msg ?? 'Completion failed. Check provided data.');
      }

      if (resp.statusCode == 404 || resp.statusCode == 405) continue;
    }

    throw Exception(
      'Complete registration endpoint not found. Ask backend for POST /complete-registration.',
    );
  }

  // =========================================================
  // Profile helpers
  // =========================================================

  /// Fetch current user profile. Normalizes the most common shapes.
  /// (Call with the Sanctum token you got from /login-google)
  static Future<Map<String, dynamic>> getMe(String token) async {
    final resp = await _getAuth('/me', token);

    if (!_looksJson(resp)) {
      final head =
      resp.body.substring(0, resp.body.length > 160 ? 160 : resp.body.length);
      throw Exception(
        'Non-JSON from /me (status ${resp.statusCode}). '
            'Likely wrong host/guard. Head: ${head.replaceAll('\n', ' ')}',
      );
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
    if (resp.statusCode == 200 && _looksJson(resp)) {
      final decoded = _decodeMap(resp.body);
      final list = (decoded['data'] != null && decoded['data']['data'] != null)
          ? (decoded['data']['data'] as List<dynamic>)
          : <dynamic>[];
      return list.map((e) => Property.fromJson(e)).toList();
    }
    throw Exception(
      'Failed to get saved properties: ${resp.statusCode} ${resp.body}',
    );
  }

  static Future<bool> toggleSavedProperty(
      String token,
      int propertyId,
      ) async {
    final resp = await _postAuth(
      '/toggle-saved-property',
      token,
      {"property_id": propertyId},
    );
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
      Map<String, String> filters,
      ) async {
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
      'name': name.trim(),
      'email': _normEmail(email),
      'phone': phone.trim(),
      'subject': subject.trim(),
      'message': message.trim(),
    });
    if (kDebugMode) {
      print(
        '[POST-FORM] ${resp.request?.url} -> ${resp.statusCode} ${resp.body}',
      );
    }
    return resp.statusCode == 200 || resp.statusCode == 201;
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
      data['message'] ?? 'Failed to create alert (${resp.statusCode})',
    );
  }

  static Future<List<dynamic>> getSavedSearches(String token) async {
    final resp = await _getAuth('/saved-searches', token);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final decoded = jsonDecode(resp.body);
      if (decoded is List) return decoded;
      if (decoded is Map) {
        if (decoded['data'] is List) return decoded['data'];
        if (decoded['data'] is Map &&
            decoded['data']['data'] is List) {
          return decoded['data']['data'];
        }
        if (decoded['saved_searches'] is List) {
          return decoded['saved_searches'];
        }
      }
      return <dynamic>[];
    }
    final body = _decodeMap(resp.body);
    throw Exception(
      body['message'] ??
          'Failed to fetch saved alerts (${resp.statusCode})',
    );
  }

  // =========================================================
  // Generic HTTP
  // =========================================================

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
      if (_looksJson(resp)) {
        print('[GET*]  $url -> ${resp.statusCode}');
      } else {
        final head =
        resp.body.substring(0, resp.body.length > 120 ? 120 : resp.body.length);
        print(
          '[GET*]  $url -> ${resp.statusCode} (Non-JSON) head: $head',
        );
      }
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
    final resp =
    await http.get(url, headers: _jsonHeaders).timeout(_timeout);
    if (kDebugMode) {
      final ct = resp.headers['content-type'] ?? '';
      if (!ct.contains('application/json')) {
        final head =
        resp.body.substring(0, resp.body.length > 120 ? 120 : resp.body.length);
        print(
          '[GET]   $url -> ${resp.statusCode} (Non-JSON) body: $head',
        );
      } else {
        print('[GET]   $url -> ${resp.statusCode}');
      }
    }
    return resp;
  }

  // --- Helpers for form-encoded posting (Laravel friendly) ---
  static const Map<String, String> _formHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/x-www-form-urlencoded',
    'X-Requested-With': 'XMLHttpRequest',
  };

  static Future<http.Response> _postForm(
      String endpoint,
      Map<String, String> fields,
      ) async {
    final url = _buildUri(endpoint);
    final resp = await http
        .post(url, headers: _formHeaders, body: fields)
        .timeout(_timeout);
    if (kDebugMode) {
      print('[POST-FORM] $url -> ${resp.statusCode} ${resp.body}');
    }
    return resp;
  }
}
