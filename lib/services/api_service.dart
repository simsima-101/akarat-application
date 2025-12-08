// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../model/propertymodel.dart';

class ApiService {
  // =========================================================
  // BASE URL RESOLUTION (define > .env > default) + runtime override
  // =========================================================
  static String? _runtimeBaseUrl;

  static void setRuntimeBase(String base) {
    final clean = base.trim().replaceFirst(RegExp(r'/+$'), '');
    _runtimeBaseUrl = clean;
    if (kDebugMode) print('ApiService runtime base set → $_runtimeBaseUrl');
  }

  static void clearRuntimeBase() {
    _runtimeBaseUrl = null;
    if (kDebugMode) print('ApiService runtime base cleared.');
  }

  static String get _rawBaseUrl {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.trim().isNotEmpty) {
      return fromDefine.replaceFirst(RegExp(r'/+$'), '');
    }
    final fromEnv = (dotenv.env['API_BASE_URL'] ?? '').trim();
    if (fromEnv.isNotEmpty) {
      return fromEnv.replaceFirst(RegExp(r'/+$'), '');
    }
    return 'https://qa.akarat.com/api';
  }

  static String get _effectiveBaseUrl {
    var url = (_runtimeBaseUrl ?? _rawBaseUrl);
    if (!kIsWeb &&
        Platform.isAndroid &&
        (url.contains('127.0.0.1') || url.contains('localhost'))) {
      try {
        final u = Uri.parse(url);
        final host =
        (u.host == 'localhost' || u.host == '127.0.0.1') ? '10.0.2.2' : u.host;
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

  static void debugPrintBaseUrl() {
    if (kDebugMode) {
      print('BASE URL (define/env):       $_rawBaseUrl');
      print('BASE URL (runtime override): ${_runtimeBaseUrl ?? '(none)'}');
      print('BASE URL (effective):        $_effectiveBaseUrl');
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
  static const _timeout = Duration(seconds: 25);

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

  static Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final cleanEndpoint =
    endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    var uri = Uri.parse('$_effectiveBaseUrl/$cleanEndpoint');
    if (queryParams != null) uri = uri.replace(queryParameters: queryParams);
    return uri;
  }

  static Uri buildUri(String endpoint, {Map<String, String>? query}) =>
      _buildUri(endpoint, query);

  static Map<String, dynamic> _decodeMap(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

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

  /// Extracts token from common shapes:
  /// {token}, {access_token}, {data:{token}}, {data:{access_token}}
  static String? extractToken(Map<String, dynamic> m) {
    final t1 = (m['token'] ?? '').toString().trim();
    if (t1.isNotEmpty) return t1;
    final t2 = (m['access_token'] ?? '').toString().trim();
    if (t2.isNotEmpty) return t2;
    final d = m['data'];
    if (d is Map<String, dynamic>) {
      final t3 = (d['token'] ?? '').toString().trim();
      if (t3.isNotEmpty) return t3;
      final t4 = (d['access_token'] ?? '').toString().trim();
      if (t4.isNotEmpty) return t4;
    }
    return null;
  }

  // =========================================================
  // IDENTITY HELPERS (fixes name fallback issues on re-login)
  // =========================================================

  /// Extract “best available” identity from a typical backend JSON.
  /// Supports:
  ///  - flat: { first_name,last_name,name,email }
  ///  - nested: { user:{...} } / { data:{ user:{...} } }
  ///
  ///
  ///


  // --- compatibility wrapper so existing call sites can use extractIdentity(...) ---
  static ({String first, String last, String name, String email}) extractIdentity(
      Map<String, dynamic> src) {
    return extractIdentityFromAny(src);
  }



  static ({String first, String last, String name, String email}) extractIdentityFromAny(
      Map<String, dynamic> src) {
    String pickStr(List<List<String>> paths) {
      for (final p in paths) {
        dynamic cur = src;
        for (final k in p) {
          if (cur is Map && cur.containsKey(k)) {
            cur = cur[k];
          } else {
            cur = null;
            break;
          }
        }
        if (cur is String && cur.trim().isNotEmpty) {
          return cur.trim();
        }
      }
      return '';
    }

    final first = pickStr([
      ['first_name'],
      ['user', 'first_name'],
      ['data', 'first_name'],
      ['data', 'user', 'first_name'],
    ]);

    final last = pickStr([
      ['last_name'],
      ['user', 'last_name'],
      ['data', 'last_name'],
      ['data', 'user', 'last_name'],
    ]);

    String name = pickStr([
      ['name'],
      ['user', 'name'],
      ['data', 'name'],
      ['data', 'user', 'name'],
    ]);

    String email = pickStr([
      ['email'],
      ['user', 'email'],
      ['data', 'email'],
      ['data', 'user', 'email'],
    ]);

    // Synthesize missing pieces from name when possible
    String f = first, l = last;
    if ((f.isEmpty || l.isEmpty) && name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      f = f.isEmpty ? (parts.isNotEmpty ? parts.first : '') : f;
      l = l.isEmpty ? (parts.length > 1 ? parts.sublist(1).join(' ') : '') : l;
    }
    if (name.isEmpty) {
      name = [f, l].where((s) => s.isNotEmpty).join(' ').trim();
    }

    return (first: f, last: l, name: name, email: email);
  }

  /// Try `/me` to fetch canonical identity if the login payload is thin.
  static Future<({String first, String last, String name, String email})?>
  tryFetchMe(String token) async {
    try {
      // Try multiple possible endpoints (in order)
      final endpoints = ['/me', '/user', '/profile', '/account'];

      for (final endpoint in endpoints) {
        try {
          final resp = await _getAuth(endpoint, token);
          if (resp.statusCode != 200) continue;

          if (!_looksJson(resp)) continue;

          final data = _decodeMap(resp.body);

          // Debug: Print raw response so you can see what's returned
          if (kDebugMode) {
            print('[/api$endpoint] RESPONSE: ${resp.body}');
          }

          final id = extractIdentityFromAny(data);

          // If we got valid first + last name → use it
          if (id.first.isNotEmpty || id.last.isNotEmpty) {
            final fullName = '${id.first} ${id.last}'.trim();
            return (
            first: id.first,
            last: id.last,
            name: fullName.isNotEmpty ? fullName : id.name,
            email: id.email
            );
          }

          // Fallback: if only 'name' exists and it's not empty
          if (id.name.isNotEmpty) {
            return id;
          }
        } catch (e) {
          if (kDebugMode) print('Failed on $endpoint: $e');
          continue;
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) print('tryFetchMe all failed: $e');
      return null;
    }
  }



  /// Convenience: perform `/login`, return token + best-available identity.
  /// UI can use this to avoid guessing name from email on re-login.
  static Future<({
  String token,
  String first,
  String last,
  String name,
  String email,
  Map<String, dynamic> raw
  })> loginWithIdentity({
    required String email,
    required String password,
  }) async {
    final res = await login(email: email, password: password);
    final status = res['__status'] as int? ?? 500;
    if (status != 200) {
      throw Exception(res['message']?.toString().isNotEmpty == true
          ? res['message'].toString()
          : 'Login failed ($status)');
    }

    final token = extractToken(res);
    if (token == null || token.isEmpty) {
      throw Exception('Login succeeded but token missing.');
    }

    // Extract identity from login body first
    var id = extractIdentityFromAny(res);

    // If first/last missing, try /me
    if (id.first.isEmpty && id.last.isEmpty) {
      final fetched = await tryFetchMe(token);
      if (fetched != null) id = fetched;
    }

    // Final fallback: synthesize from email local-part (only if still empty)
    if (id.first.isEmpty && id.last.isEmpty) {
      final local = (id.email.isNotEmpty ? id.email : _normEmail(email)).split('@').first;
      id = (first: local, last: '', name: id.name.isNotEmpty ? id.name : local, email: id.email.isNotEmpty ? id.email : _normEmail(email));
    }

    return (token: token, first: id.first, last: id.last, name: id.name, email: id.email, raw: res);
  }

  // =========================================================
  // GOOGLE LOGIN
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
    if (resp.statusCode == 422 || resp.statusCode == 404) return false;
    throw Exception('Check failed: ${resp.statusCode} ${resp.body}');
  }

  static Future<Map<String, dynamic>> loginWithGoogleIdToken(
      String firebaseIdToken) async {
    final resp =
    await _post('/login-google', {"google_id_token": firebaseIdToken});

    if (_looksHtml(resp)) {
      throw Exception(
        'Non-JSON from /login-google (HTML). Check API_BASE_URL (QA vs PROD) and route.',
      );
    }

    final data = _decodeMap(resp.body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return data;
    }
    throw Exception(
      data['message'] ?? 'Google login failed (${resp.statusCode})',
    );
  }

  /// Convenience: Google login + identity (mirrors loginWithIdentity).
  static Future<({
  String token,
  String first,
  String last,
  String name,
  String email,
  Map<String, dynamic> raw
  })> loginWithGoogleIdentity(String firebaseIdToken) async {
    final data = await loginWithGoogleIdToken(firebaseIdToken);
    final token = extractToken(data);
    if (token == null || token.isEmpty) {
      throw Exception('Google login succeeded but token missing.');
    }

    var id = extractIdentityFromAny(data);
    if (id.first.isEmpty && id.last.isEmpty) {
      final fetched = await tryFetchMe(token);
      if (fetched != null) id = fetched;
    }
    if (id.first.isEmpty && id.last.isEmpty) {
      final local = (id.email.isNotEmpty ? id.email : '').split('@').first;
      id = (first: local, last: '', name: id.name.isNotEmpty ? id.name : local, email: id.email);
    }

    return (token: token, first: id.first, last: id.last, name: id.name, email: id.email, raw: data);
  }

  static Future<String?> tryLoginGoogle(String firebaseIdToken) async {
    try {
      final r =
      await _post('/login-google', {'google_id_token': firebaseIdToken});
      if (kDebugMode) {
        print('[/login-google] -> ${r.statusCode} ${r.body}');
      }
      if (r.statusCode >= 200 && r.statusCode < 300) {
        final m = _decodeMap(r.body);
        return extractToken(m);
      }
    } catch (e) {
      if (kDebugMode) print('[/login-google] error: $e');
    }
    return null;
  }

  static Future<void> logoutUser(String token) async {
    final resp = await _postAuth('/logout', token, const {});
    if (resp.statusCode != 200) {
      throw Exception('Logout failed: ${resp.statusCode}');
    }
  }

  // =========================================================
  // EMAIL/PASSWORD + OTP REGISTRATION
  // =========================================================

  /// Thin register call (JSON). Prefer `registerStart()` which normalizes output.
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneCode, // '971' or '+971'
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final cc = phoneCode.trim().startsWith('+')
        ? phoneCode.trim()
        : '+${phoneCode.trim()}';

    final res = await http
        .post(
      _buildUri('/register'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_country_code': cc,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    )
        .timeout(_timeout);
    return _decorateStatus(res);
  }

  /// Start registration. Returns a normalized shape and includes token if backend returns it.
  ///
  /// Output keys:
  /// { '__status', 'message', 'otp', 'expires_in', 'resend_after', 'email', 'user', 'token', '__raw' }
  static Future<Map<String, dynamic>> registerStart({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneCountryCode, // include '+'
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

    String? _firstErr(Map<String, dynamic> data) {
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

    final cc = phoneCountryCode.trim().startsWith('+')
        ? phoneCountryCode.trim()
        : '+${phoneCountryCode.trim()}';

    final resp = await _postForm('/register', {
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'email': _normEmail(email),
      'phone_country_code': cc,
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

    if (kDebugMode) {
      print('[POST-FORM] ${resp.request?.url} -> ${resp.statusCode} ${resp.body}');
    }

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final otp = _pick(data, ['otp', 'data.otp', 'meta.otp']);
      final emailOut =
          _pick(data, ['email', 'data.email', 'user.email']) ?? _normEmail(email);
      final expiresIn =
          _pickInt(data, ['expires_in', 'meta.expires_in']) ?? 300;
      final resendAfter =
          _pickInt(data, ['resend_after', 'meta.resend_after']) ?? 60;
      final nameOut =
          _pick(data, ['user', 'name', 'data.name']) ?? '$firstName $lastName';
      final tokenOut = extractToken(data);

      return {
        '__status': resp.statusCode,
        'message': (data['message'] ?? '').toString(),
        'otp': otp,
        'expires_in': expiresIn,
        'resend_after': resendAfter,
        'email': emailOut,
        'user': nameOut,
        'token': tokenOut, // may be null if not issued at register step
        '__raw': data,
      };
    }

    if (resp.statusCode == 422 || resp.statusCode == 409) {
      final msg = _firstErr(data) ??
          'This email is already registered or the data is invalid.';
      throw Exception(msg);
    }

    final backendMsg = _firstErr(data);
    throw Exception(backendMsg ?? 'Registration failed (${resp.statusCode}).');
  }

  /// Verify OTP — returns raw body so the OTP screen can extract token/name/email.
  ///
  /// Output keys:
  /// { '__status', 'message', '__raw' }
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final res = await http
        .post(
      _buildUri('/verify-otp'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'otp': otp}),
    )
        .timeout(_timeout);

    Map<String, dynamic> raw;
    try {
      raw = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      raw = <String, dynamic>{};
    }

    if (kDebugMode) {
      print('[POST-JSON] ${res.request?.url} -> ${res.statusCode} ${res.body}');
    }

    return {
      '__status': res.statusCode,
      'message': (raw['message'] ?? '').toString(),
      '__raw': raw,
    };
  }

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
            (j['message']?.toString().toLowerCase().contains('sent') ?? false);
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

  /// Optional "complete registration" helper, tries a few common endpoints.
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

    final cc = (phoneCountryCode ?? '').trim();
    final ccFixed = cc.isEmpty ? null : (cc.startsWith('+') ? cc : '+$cc');

    final fields = <String, String>{
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'name': name.trim().isNotEmpty ? name.trim() : '$firstName $lastName',
      'email': _normEmail(email),
      'password': password,
      if (ccFixed != null) 'phone_country_code': ccFixed,
      if ((phone ?? '').trim().isNotEmpty) 'phone': (phone ?? '').trim(),
      if ((token ?? '').trim().isNotEmpty) 'token': (token ?? '').trim(),
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
          '__status': resp.statusCode,
          'token': t,
          'email': userEmail,
          'user': userName,
          '__raw': data,
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
  // LOGIN (email/password)
  // =========================================================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http
        .post(
      _buildUri('/login'),
      headers: const {'Accept': 'application/json'},
      body: {'email': _normEmail(email), 'password': password},
    )
        .timeout(_timeout);
    return _decorateStatus(res);
  }

  // =========================================================
  // Profile (/me)
  // =========================================================
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
    // Normalize via the same extractor so callers always get the same shape
    final id = extractIdentityFromAny(data);

    return {
      'first_name': id.first,
      'last_name': id.last,
      'name': id.name,
      'email': id.email,
      'raw': data,
    };
  }

  // =========================================================
  // Properties & other existing calls
  // =========================================================
  /// Fetch authenticated user's saved/favorite properties from the correct endpoint.
  /// Returns a list of [Property] objects with `saved = true` already set.
  /// Uses the correct endpoint: `/saved-properties` (Laravel API resource route)
  ///
  /// ← FIXED: Previously used deprecated/broken `/saved-properties` → 500 error
  /// → Now uses current backend route → 200 OK + proper pagination structure
  static Future<List<Property>> getSavedProperties(String token) async {
    final resp = await _getAuth('/saved-properties', token);

    if (resp.statusCode == 200 && _looksJson(resp)) {
      final Map<String, dynamic> decoded = _decodeMap(resp.body);

      // Backend structure: { data: { data: [...] } } due to pagination
      final List<dynamic> list = decoded['data']?['data'] is List
          ? decoded['data']['data']
          : <dynamic>[];

      return list.map((e) {
        final p = Property.fromJson(e as Map<String, dynamic>);
        p.saved = true;  // Mark as saved locally
        return p;
      }).toList();
    }

    // Better error message for debugging
    throw Exception(
      'Failed to load saved properties: ${resp.statusCode}\n'
          'Response: ${resp.body.substring(0, resp.body.length.clamp(0, 200))}...',
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
    final resp = await _get('/featured-properties', {"page": page.toString()});
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
      print('[POST-FORM] ${resp.request?.url} -> ${resp.statusCode} ${resp.body}');
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
        Map<String, dynamic>? extra,
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
        if (decoded['data'] is Map && decoded['data']['data'] is List) {
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
      body['message'] ?? 'Failed to fetch saved alerts (${resp.statusCode})',
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
        print('[GET*]  $url -> ${resp.statusCode} (Non-JSON) head: $head');
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
    final resp = await http.get(url, headers: _jsonHeaders).timeout(_timeout);
    if (kDebugMode) {
      final ct = resp.headers['content-type'] ?? '';
      if (!ct.contains('application/json')) {
        final head =
        resp.body.substring(0, resp.body.length > 120 ? 120 : resp.body.length);
        print('[GET]   $url -> ${resp.statusCode} (Non-JSON) body: $head');
      } else {
        print('[GET]   $url -> ${resp.statusCode}');
      }
    }
    return resp;
  }

  // --- Laravel-friendly form posts ---
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
    final resp =
    await http.post(url, headers: _formHeaders, body: fields).timeout(_timeout);
    if (kDebugMode) {
      print('[POST-FORM] $url -> ${resp.statusCode} ${resp.body}');
    }
    return resp;
  }

  static Map<String, dynamic> _decorateStatus(http.Response r) {
    Map<String, dynamic> m = {};
    try {
      final v = jsonDecode(r.body);
      if (v is Map<String, dynamic>) m = v;
    } catch (_) {}
    m['__status'] = r.statusCode;
    return m;
  }
}
