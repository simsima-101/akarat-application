// lib/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform, SocketException, File;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../features/property/data/models/property_model.dart';
import '../localization/language_controller.dart';
import '../utils/locale_utils.dart';
import 'package:flutter/widgets.dart';

class ApiService {


  static const String _appKey = 'akarat_mobile_key_2025';
  static const String _appSecret = 'akarat_mobile_secret_2025';


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

  static String get baseUrl {
    // 1. Highest priority: Firebase Remote Config
    final rc = FirebaseRemoteConfig.instance;
    final rcValue = rc.getString('api_base_url').trim();
    if (rcValue.isNotEmpty && rcValue.startsWith('https://')) {
      final cleanRc = rcValue.replaceFirst(RegExp(r'/+$'), '');
      if (kDebugMode) {
        print('Using Remote Config base URL: $cleanRc');
      }
      return cleanRc;
    }

    // 2. Runtime override
    if (_runtimeBaseUrl != null && _runtimeBaseUrl!.isNotEmpty) {
      final clean = _runtimeBaseUrl!.replaceFirst(RegExp(r'/+$'), '');
      if (kDebugMode) print('Using runtime override base: $clean');
      return clean;
    }

    // 3. .env / define / hardcoded fallback
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    final fromEnv = (dotenv.env['API_BASE_URL'] ?? '').trim();

    String fallback;
    if (fromDefine
        .trim()
        .isNotEmpty) {
      fallback = fromDefine;
    } else if (fromEnv.isNotEmpty) {
      fallback = fromEnv;
    } else {
      fallback = 'https://akarat.com/api';
    }

    final cleanFallback = fallback.replaceFirst(RegExp(r'/+$'), '');
    if (kDebugMode) {
      print('Falling back to base URL: $cleanFallback');
    }
    return cleanFallback;
  }

  static Map<String, dynamic> _sanitizeBodyForLogging(Map<String, dynamic> original) {
    final copy = Map<String, dynamic>.from(original);

    const sensitiveKeys = {
      'password',
      'password_confirmation',
      'token',
      'access_token',
      'refresh_token',
      'otp',
      'secret',
      'pin',
      'code', // sometimes used for OTP/verification
    };

    for (final key in sensitiveKeys) {
      if (copy.containsKey(key)) {
        copy[key] = '***';
      }
    }

    // Optional: handle very common nested cases (you can expand this if needed)
    if (copy.containsKey('data') && copy['data'] is Map) {
      final data = copy['data'] as Map<String, dynamic>;
      for (final key in sensitiveKeys) {
        if (data.containsKey(key)) {
          data[key] = '***';
        }
      }
    }

    return copy;
  }

  static void debugPrintBaseUrl() {
    if (kDebugMode) {
      final rc = FirebaseRemoteConfig.instance;
      print('RC api_base_url:       "${rc.getString('api_base_url')}"');
      print('Runtime override:      ${_runtimeBaseUrl ?? "(none)"}');
      print('.env / define fallback: ${dotenv.env['API_BASE_URL'] ??
          String.fromEnvironment('API_BASE_URL')}');
      print('Effective baseUrl:     $baseUrl');
    }
  }

  // =========================================================
  // HEADERS
  // =========================================================



  static Map<String, String> _getHeaders({
    bool auth = false,
    String? token,
    Map<String, String>? extraHeaders,
  }) {
    String langCode = 'en';
    String source = 'fallback-default-en';

    // ────────────────────────────────────────────────
    // Priority 1: In-app selected language (highest priority)
    // ────────────────────────────────────────────────
    try {
      final controller = LanguageController.instance;
      final appLang = controller.languageCode?.trim();

      if (appLang != null && appLang.isNotEmpty) {
        langCode = appLang;
        source = 'LanguageController (in-app choice)';
      }
    } catch (e, stack) {
      debugPrint('LanguageController access failed: $e');
      debugPrint('Stack: $stack');
      source = 'LanguageController-failed';
    }

    // ────────────────────────────────────────────────
    // Priority 2: Current device/system locale (fallback)
    // ────────────────────────────────────────────────
    if (source.startsWith('fallback') || source == 'LanguageController-failed') {
      try {
        final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
        final deviceLang = deviceLocale.languageCode.toLowerCase().trim();

        if (deviceLang.isNotEmpty) {
          langCode = deviceLang;
          source = 'device-locale (${deviceLocale.toLanguageTag()})';
        }
      } catch (e) {
        debugPrint('Failed to read device locale: $e');
        source = 'device-locale-failed';
      }
    }

    // ────────────────────────────────────────────────
    // Normalize to supported codes (only ar, tr, en for now)
    // ────────────────────────────────────────────────
    if (langCode.startsWith('ar')) {
      langCode = 'ar';
    } else if (langCode.startsWith('tr')) {
      langCode = 'tr';
    } else {
      langCode = 'en'; // explicit fallback — never send unsupported code
    }

    // ────────────────────────────────────────────────
    // Build headers
    // ────────────────────────────────────────────────
    final headers = <String, String>{
      'Accept': 'application/json',
      'Accept-Language': langCode,
      'Content-Type': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    };









      Future<http.Response> request({
        required String method,
        required String endpoint,
        Map<String, dynamic>? query,
        Map<String, dynamic>? body,
        Map<String, String>? extraHeaders,
      }) async {
        final uri = _buildUri(endpoint, query?.cast<String, String>());
        final pathWithQuery = uri.path + (uri.hasQuery ? '?${uri.query}' : '');




        final headers = _signedHeaders(method, pathWithQuery);

        if (extraHeaders != null) headers.addAll(extraHeaders);

        if (kDebugMode) {
          print('➡️ $method $uri');
          print('Headers: $headers');
          if (body != null) print('Body: $body');
        }

        switch (method.toUpperCase()) {
          case 'GET':
            return await http.get(uri, headers: headers);
          case 'POST':
            return await http.post(uri, headers: headers, body: jsonEncode(body));
          case 'PUT':
            return await http.put(uri, headers: headers, body: jsonEncode(body));
          case 'DELETE':
            return await http.delete(uri, headers: headers);
          default:
            throw Exception('Unsupported HTTP method: $method');
        }
      }

    Future<http.Response> get(
        String endpoint, {
          Map<String, dynamic>? query,
          Map<String, String>? headers,
        }) => request(
      method: 'GET',
      endpoint: endpoint,
      query: query,
      extraHeaders: headers,
    );

    Future<http.Response> post(
        String endpoint, {
          Map<String, String>? query,
          Map<String, dynamic>? body,
          Map<String, String>? headers,
        }) => request(
      method: 'POST',
      endpoint: endpoint,
      query: query,
      body: body,
      extraHeaders: headers,
    );

    Future<http.Response> put(
        String endpoint, {
          Map<String, String>? query,
          Map<String, dynamic>? body,
          Map<String, String>? headers,
        }) => request(
      method: 'PUT',
      endpoint: endpoint,
      query: query,
      body: body,
      extraHeaders: headers,
    );

    Future<http.Response> delete(
        String endpoint, {
          Map<String, String>? query,
          Map<String, String>? headers,
        }) => request(
      method: 'DELETE',
      endpoint: endpoint,
      query: query,
      extraHeaders: headers,
    );

    Future<http.StreamedResponse> uploadMultipart({
      required String endpoint,
      required File file,
      String fileFieldName = 'image',
      Map<String, String>? extraFields,
      Map<String, String>? extraHeaders,
    }) async {
      final uri = _buildUri(endpoint);
      final pathWithQuery = uri.path + (uri.hasQuery ? '?${uri.query}' : '');

      final signedHeaders = _signedHeaders('POST', pathWithQuery);

      final headers = {
        ...signedHeaders,
        ...?extraHeaders,
      };

      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers)
        ..files.add(await http.MultipartFile.fromPath(fileFieldName, file.path));

      if (extraFields != null) {
        request.fields.addAll(extraFields);
      }

      if (kDebugMode) {
        print('➡️ Multipart POST $uri');
        print('Headers: $headers');
        print('Files: ${request.files.map((f) => f.filename).join(', ')}');
        if (extraFields != null) print('Extra fields: $extraFields');
      }

      return await request.send();
    }

    void setRuntimeBaseUrl(String baseUrl) => _runtimeBaseUrl = baseUrl;

    if (auth && token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      headers['Origin'] = 'https://akarat.com';
      headers['Referer'] = 'https://akarat.com';
    }

    if (extraHeaders != null && extraHeaders.isNotEmpty) {
      headers.addAll(extraHeaders);
    }

    // ────────────────────────────────────────────────
    // Debug output — very helpful when language doesn't change
    // ────────────────────────────────────────────────
    if (kDebugMode) {
      print('┌───────────────────────────────');
      print('│  API Headers – Accept-Language');
      print('├───────────────────────────────');
      print('│  Final value   : $langCode');
      print('│  Source        : $source');
      print('│  Full locale   : ${WidgetsBinding.instance.platformDispatcher.locale}');
      print('│  Controller lang: ${LanguageController.instance.languageCode ?? "not available"}');
      print('└───────────────────────────────');
    }

    return headers;
  }


  static Map<String, String> _signedHeaders(String method, String path) {
    final timestamp =
    (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final payload = method.toUpperCase() + path + timestamp;

    final hmac = Hmac(sha256, utf8.encode(_appSecret));
    final signature = hmac.convert(utf8.encode(payload)).toString();

    return {
      'X-APP-KEY': _appKey,
      'X-APP-TIMESTAMP': timestamp,
      'X-APP-SIGNATURE': signature,
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }


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
    var uri = Uri.parse('$baseUrl/$cleanEndpoint');
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
        if (cur is String && cur
            .trim()
            .isNotEmpty) {
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
    String f = first,
        l = last;
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
  static Future<
      ({String first, String last, String name, String email})?> tryFetchMe(
      String token) async {
    try {
      final endpoints = ['/me', '/user', '/profile', '/account'];

      for (final endpoint in endpoints) {
        try {
          final resp = await wrappedGet(
            _buildUri(endpoint),
            auth: true,
            token: token,
            // extraHeaders: _getHeaders(),     // only needed if you have custom headers beyond auth
          );
          if (resp.statusCode != 200) continue;

          if (!_looksJson(resp)) continue;

          final data = _decodeMap(resp.body);

          if (kDebugMode) print('[/api$endpoint] RESPONSE: ${resp.body}');

          final id = extractIdentityFromAny(data);

          if (id.first.isNotEmpty || id.last.isNotEmpty) {
            final fullName = '${id.first} ${id.last}'.trim();
            return (first: id.first, last: id.last, name: fullName.isNotEmpty
                ? fullName
                : id.name, email: id.email);
          }

          if (id.name.isNotEmpty) return id;
        } catch (e) {
          if (kDebugMode) print('Failed on $endpoint: $e');
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
      throw Exception(res['message']
          ?.toString()
          .isNotEmpty == true
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
      final local = (id.email.isNotEmpty ? id.email : _normEmail(email))
          .split('@')
          .first;
      id = (first: local, last: '', name: id.name.isNotEmpty
          ? id.name
          : local, email: id.email.isNotEmpty ? id.email : _normEmail(email));
    }

    return (token: token, first: id.first, last: id.last, name: id
        .name, email: id.email, raw: res);
  }

  // =========================================================
  // GOOGLE LOGIN
  // =========================================================
  static Future<bool> checkUserExistsByEmail(String email) async {
    final normalized = _normEmail(email);
    final resp = await wrappedGet(
      _buildUri('/users/check', {'email': normalized}),
    );
    if (resp.statusCode == 200) {
      final j = _decodeMap(resp.body);
      final v = j['exists'];
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v.toLowerCase() == 'true' || v == '1';
      return false;
    }
    if (resp.statusCode == 422 || resp.statusCode == 404) return false;
    throw Exception('Check failed: ${resp.statusCode}');
  }

  static Future<Map<String, dynamic>> loginWithGoogleIdToken(
      String firebaseIdToken) async {
    final resp = await wrappedPost(
      _buildUri('/login-google'),
      {"google_id_token": firebaseIdToken},
    );

    if (_looksHtml(resp)) throw Exception('Non-JSON from /login-google');

    final data = _decodeMap(resp.body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) return data;
    throw Exception(data['message'] ?? 'Google login failed');
  }

  static Future<void> logoutUser(String token) async {
    final resp = await wrappedPost(
      _buildUri('/logout'),
      {},
        extraHeaders: _getHeaders(auth: true, token: token)


    );
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

    final res = await http.post(
      _buildUri('/register'),
      headers: _getHeaders(),           // ← changed extraHeaders → headers
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_country_code': cc,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    ).timeout(_timeout);

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
        if (cur is String && cur
            .trim()
            .isNotEmpty) return cur.trim();
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
      print('[POST-FORM] ${resp.request?.url} -> ${resp.statusCode} ${resp
          .body}');
    }

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final otp = _pick(data, ['otp', 'data.otp', 'meta.otp']);
      final emailOut =
          _pick(data, ['email', 'data.email', 'user.email']) ??
              _normEmail(email);
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
    final res = await http.post(
      _buildUri('/verify-otp'),
      headers: _getHeaders(),           // ← change extraHeaders → headers
      body: jsonEncode({'email': email, 'otp': otp}),
    ).timeout(_timeout);

    Map<String, dynamic> raw;
    try {
      raw = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      raw = <String, dynamic>{};
    }

    if (kDebugMode) {
      print('[POST-JSON] ${res.request?.url} → ${res.statusCode} ${res.body}');
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
        if (cur is String && cur
            .trim()
            .isNotEmpty) return cur.trim();
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
      'name': name
          .trim()
          .isNotEmpty ? name.trim() : '$firstName $lastName',
      'email': _normEmail(email),
      'password': password,
      if (ccFixed != null) 'phone_country_code': ccFixed,
      if ((phone ?? '')
          .trim()
          .isNotEmpty) 'phone': (phone ?? '').trim(),
      if ((token ?? '')
          .trim()
          .isNotEmpty) 'token': (token ?? '').trim(),
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
            _pick(data, ['user', 'name', 'data.name']) ??
                '$firstName $lastName';

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
    final url = _buildUri('/login');

    final res = await wrappedPost(
      url,
      {
        'email': _normEmail(email),
        'password': password,
      },
      // No need for extra headers here anymore
      // Accept-Language is automatically added by wrappedPost via _getHeaders()
    );

    return _decorateStatus(res);
  }

  // =========================================================
  // Profile (/me)
  // =========================================================
  static Future<Map<String, dynamic>> getMe(String token) async {
    final resp = await wrappedGet(
      _buildUri('/me'),
        extraHeaders: _getHeaders(auth: true, token: token)


    );

    if (!_looksJson(resp)) {
      final head = resp.body.substring(
        0,
        resp.body.length > 160 ? 160 : resp.body.length,
      );

      throw Exception(
        'Non-JSON from /me (status ${resp.statusCode}). '
            'Likely wrong host/guard. Head: ${head.replaceAll('\n', ' ')}',
      );
    }

    final data = _decodeMap(resp.body);

    // Normalize identity so callers always get the same shape
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
    final resp = await wrappedGet(
      _buildUri('/saved-properties'),
        extraHeaders: _getHeaders(auth: true, token: token)


    );

    if (resp.statusCode == 200 && _looksJson(resp)) {
      final decoded = _decodeMap(resp.body);
      final list = decoded['data']?['data'] is List
          ? decoded['data']['data']
          : <dynamic>[];
      return list.map((e) {
        final p = Property.fromJson(e as Map<String, dynamic>);
        p.saved = true;
        return p;
      }).toList();
    }

    throw Exception('Failed to load saved properties: ${resp.statusCode}');
  }

  static Future<bool> toggleSavedProperty(String token, int propertyId) async {
    final resp = await wrappedPost(
      _buildUri('/toggle-saved-property'),
      {"property_id": propertyId},

        extraHeaders: _getHeaders(auth: true, token: token),


    );
    return resp.statusCode == 200;
  }

  static Future<List<dynamic>> getAgents({int page = 1}) async {
    final resp = await wrappedGet(
      _buildUri('/agents', {'page': page.toString()}),
    );
    if (resp.statusCode == 200) return _decodeList(resp.body);
    throw Exception('Failed to get agents');
  }

  static Future<Map<String, dynamic>> getAgentDetails(int id) async {
    final resp = await wrappedGet(_buildUri('/agent/$id'));
    if (resp.statusCode == 200) return _decodeMap(resp.body);
    throw Exception('Failed to get agent details');
  }


  static Future<List<dynamic>> getFeaturedProperties({int page = 1}) async {
    final resp = await wrappedGet(
      _buildUri('/featured-properties', {'page': page.toString()}),
    );
    if (resp.statusCode == 200) return _decodeList(resp.body);
    throw Exception('Failed to get featured properties');
  }

  static Future<List<dynamic>> getFilteredProperties(
      Map<String, String> filters) async {
    final resp = await wrappedGet(_buildUri('/filters', filters));
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
    final resp = await wrappedPostForm(
      _buildUri('/contact'),
      {
        'name': name.trim(),
        'email': _normEmail(email),
        'phone': phone.trim(),
        'subject': subject.trim(),
        'message': message.trim(),
      },
    );
    if (kDebugMode) {
      print('[POST-FORM] ${resp.request?.url} -> ${resp.statusCode} ${resp
          .body}');
    }
    return resp.statusCode == 200 || resp.statusCode == 201;
  }

  // ===== Alerts/Saved Searches =====
  static Future<Map<String, dynamic>> createAlert(String token, {
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
    final resp = await wrappedPost(
      _buildUri('/alerts'),
      body,

        extraHeaders: _getHeaders(auth: true, token: token)


    );
    final data = _decodeMap(resp.body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) return data;
    throw Exception(data['message'] ?? 'Failed to create alert');
  }

  static Future<List<dynamic>> getSavedSearches(String token) async {
    final resp = await wrappedGet(
      _buildUri('/saved-searches'),

        extraHeaders: _getHeaders(auth: true, token: token)
    );
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
    throw Exception(body['message'] ?? 'Failed to fetch saved alerts');
  }

  // =========================================================
  // Generic HTTP
  // =========================================================
  static Future<http.Response> _post(String endpoint, Map<String, dynamic> body) async {
    final url = _buildUri(endpoint);

    final resp = await http
        .post(
      url,
      headers: _getHeaders(),           // ← changed from extraHeaders → headers
      body: jsonEncode(body),
    )
        .timeout(_timeout);

    if (kDebugMode) {
      print('[POST]  $url → ${resp.statusCode}');
      // print(resp.body);                // ← only if you really need full body in logs
    }

    return resp;
  }
  static Future<http.Response> _postAuth(
      String endpoint,
      String token,
      Map<String, dynamic> body,
      ) async {
    if (token.trim().isEmpty) {
      throw Exception('No auth token present for $baseUrl$endpoint');
    }

    final url = _buildUri(endpoint);

    final resp = await wrappedPost(
      url,
      body,
      auth: true,
      token: token,
    );

    if (kDebugMode) {
      print('[POST*] $url → ${resp.statusCode}');
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
    if (token.trim().isEmpty) {  // ← added .trim() – safer
      throw Exception('No auth token present for $baseUrl$endpoint');
    }

    final url = _buildUri(endpoint, qs);

    final resp = await http
        .get(
      url,
      headers: _getHeaders(
        auth: true,
        token: token,
      ),
    )
        .timeout(_timeout);

    if (kDebugMode) {
      if (_looksJson(resp)) {
        print('[GET*]  $url → ${resp.statusCode}');
      } else {
        final head = resp.body.substring(
          0,
          resp.body.length > 120 ? 120 : resp.body.length,
        );
        print('[GET*]  $url → ${resp.statusCode} (Non-JSON) head: $head');
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

    final resp = await http.get(
      url,
      headers: _getHeaders(),           // ← replace _jsonHeaders with _getHeaders()
    ).timeout(_timeout);

    if (kDebugMode) {
      final ct = resp.headers['content-type'] ?? '';
      if (!ct.contains('application/json')) {
        final head = resp.body.substring(
          0,
          resp.body.length > 120 ? 120 : resp.body.length,
        );
        print('[GET]   $url → ${resp.statusCode} (Non-JSON) body: $head');
      } else {
        print('[GET]   $url → ${resp.statusCode}');
      }
    }

    return resp;
  }


  static Future<http.Response> _postForm(
      String endpoint,
      Map<String, String> fields,
      ) async {
    final url = _buildUri(endpoint);

    final headers = _getHeaders();                     // ← base headers (language, accept, etc.)

    headers['Content-Type'] = 'application/x-www-form-urlencoded';

    final resp = await http
        .post(
      url,
      headers: headers,
      body: fields,
    )
        .timeout(_timeout);

    if (kDebugMode) {
      print('[POST-FORM] $url → ${resp.statusCode}');
      // print(resp.body);   // ← only uncomment if needed for debugging
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




  // Place these near the bottom in the "Generic HTTP" section

  /// Performs a GET request with automatic handling of:
  /// - Accept-Language based on app locale
  /// - Authorization header (when auth = true and token is provided)
  /// - Extra/custom headers
  /// - Query parameter merging
  /// - Debug logging
  /// - Consistent timeout
  static Future<http.Response> wrappedGet(
      Uri url, {
        Map<String, String>? extraHeaders,
        Map<String, String>? queryParams,
        bool auth = false,
        String? token,
        Duration? timeout,               // ← optional override
      }) async {
    // Build base headers (Accept, Accept-Language, X-Requested-With, etc.)
    final baseHeaders = _getHeaders(
      auth: auth,
      token: token,
      extraHeaders: extraHeaders,
    );

    // Make a copy so we don't mutate the original map
    final headers = Map<String, String>.from(baseHeaders);

    // Build final URL with merged query parameters
    var finalUrl = url;
    if (queryParams != null && queryParams.isNotEmpty) {
      finalUrl = url.replace(
        queryParameters: {
          ...url.queryParameters,
          ...queryParams,
        },
      );
    }

    // ──────────────────────────────────────────────────────────────
    // Debug logging (only in debug mode)
    // ──────────────────────────────────────────────────────────────
    if (kDebugMode) {
      print('╔═══════════════════════════════════════════════════════');
      print('║ GET Request');
      print('║ URL:          $finalUrl');
      print('║ Auth:         ${auth ? "yes (token present)" : "no"}');
      print('║ Accept-Lang:  ${headers['Accept-Language'] ?? "not set"}');
      print('║ Headers:      ${headers.entries.map((e) => "${e.key}: ${e.value}").join(", ")}');
      print('╚═══════════════════════════════════════════════════════');
    }

    try {
      final response = await http
          .get(
        finalUrl,
        headers: headers,
      )
          .timeout(timeout ?? const Duration(seconds: 25));

      // Optional: log response status in debug mode
      if (kDebugMode) {
        print('← GET ${response.statusCode}  $finalUrl');
        if (response.statusCode >= 400) {
          final preview = response.body.length > 300
              ? '${response.body.substring(0, 300)}...'
              : response.body;
          print('   Error preview: $preview');
        }
      }

      return response;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('GET request failed → $finalUrl');
        print('Error: $e');
        // print(stackTrace);  // uncomment only when debugging deeply
      }
      rethrow;
    }
  }
  static Future<http.Response> wrappedPost(
      Uri url,
      Map<String, dynamic> body, {
        Map<String, String>? extraHeaders,
        bool auth = false,
        String? token,
        Duration? timeout,              // ← allow override per call
        bool logBody = kDebugMode,      // ← control whether body is printed (sensitive data)
      }) async {
    // 1. Build base headers
    final base = _getHeaders(
      auth: auth,
      token: token,
      extraHeaders: extraHeaders,
    );

    // 2. Create independent copy — prevents accidental mutation of shared maps
    final headers = Map<String, String>.from(base);

    // 3. Ensure correct content type (most JSON APIs expect this)
    headers['Content-Type'] = 'application/json; charset=utf-8';

    // 4. Optional: add common security / tracing headers many backends like
    // headers['X-Client-Version'] = appVersion;   // if you have it
    // headers['X-Request-ID'] = uuid.v4();        // if you use uuid package

    // 5. Clean / normalize body (optional but helps catch silly bugs)
    final cleanedBody = _sanitizeBodyForLogging(body);
    final client = http.Client();

    if (kDebugMode) {
      print('→ POST  $url');
      print('   Auth:   ${auth ? "yes (token present)" : "no"}');
      print('   Headers:${headers.entries.map((e) => " ${e.key}: ${e.value}").join(',')}');
      if (logBody) {
        print('   Body:   ${jsonEncode(cleanedBody)}');
      } else {
        print('   Body:   [hidden – sensitive data]');
      }
    }

    try {
      final client = http.Client(); // ← explicit client (can add interceptors later)

      final response = await client
          .post(
        url,
        headers: headers,
        body: jsonEncode(body),
      )
          .timeout(timeout ?? _timeout);

      if (kDebugMode) {
        print('← ${response.statusCode}  $url');
        if (response.statusCode >= 400) {
          print('   Error body: ${response.body.substring(0, min(300, response.body.length))}...');
        }
      }

      return response;
    } on TimeoutException catch (e) {
      if (kDebugMode) print('Timeout on POST $url → $e');

      final effectiveTimeout = timeout ?? _timeout;
      throw TimeoutException(
        'Request to $url timed out after $effectiveTimeout',
        effectiveTimeout,           // ← pass the Duration here
      );

    } on SocketException catch (e) {
      if (kDebugMode) print('Network error on POST $url → $e');
      throw Exception('Network error: ${e.message}');
    } catch (e, stack) {
      if (kDebugMode) {
        print('Unexpected error on POST $url');
        print(e);
        // print(stack); // uncomment during deep debugging only
      }
      rethrow;
    } finally {
      client.close(); // good practice when using explicit client
    }
  }
  static Future<http.Response> wrappedPostForm(
      Uri url,
      Map<String, String> fields, {
        Map<String, String>? extraHeaders,
        bool auth = false,
        String? token,
      }) async {
    // 1. Build base headers (language, accept, etc.)
    final baseHeaders = _getHeaders(
      auth: auth,
      token: token,
      extraHeaders: extraHeaders,
    );

    // 2. Create final headers map – important: we copy so we don't mutate the original
    final headers = Map<String, String>.from(baseHeaders);

    // 3. Force correct content type for form-urlencoded (overrides any previous value)
    headers['Content-Type'] = 'application/x-www-form-urlencoded';

    // Optional: add common form-related headers if your backend expects them
    // headers['Accept'] = 'application/json';   // already in _getHeaders – keep it

    // 4. Optional safety: prevent sending empty or malformed fields
    final cleanedFields = fields.map((key, value) => MapEntry(key, value.trim()));

    if (kDebugMode) {
      print('→ POST-FORM → $url');
      print('   Headers:   $headers');
      print('   Fields:    $cleanedFields');
      print('   Auth used: $auth | Token present: ${token != null && token.isNotEmpty}');
    }

    try {
      final response = await http
          .post(
        url,
        headers: headers,
        body: cleanedFields,           // Map<String,String> is valid for form
      )
          .timeout(_timeout);

      if (kDebugMode && !_looksJson(response) && !_looksHtml(response)) {
        print('   Warning: unusual content-type → ${response.headers['content-type']}');
      }

      return response;
    } catch (e, stack) {
      if (kDebugMode) {
        print('POST-FORM failed → $url');
        print('Error: $e');
        // print(stack); // uncomment only during deep debugging
      }
      // You can rethrow or wrap – depending on your error strategy
      rethrow;
    }
  }

  // Add these at the bottom of class ApiService (after wrappedPostForm)

  static Future<http.Response> get(
      String endpoint, {
        Map<String, dynamic>? query,
        Map<String, String>? headers,
      }) async {
    final uri = buildUri(endpoint, query: query?.cast<String, String>());
    return wrappedGet(
      uri,
      extraHeaders: headers,
    );
  }

  static Future<http.Response> post(
      String endpoint, {
        Map<String, String>? query,
        Map<String, dynamic>? body,
        Map<String, String>? headers,
      }) async {
    final uri = buildUri(endpoint, query: query);
    return wrappedPost(
      uri,
      body ?? {},
      extraHeaders: headers,
    );
  }

// Optional – if other files call put/delete too
  static Future<http.Response> put(
      String endpoint, {
        Map<String, String>? query,
        Map<String, dynamic>? body,
        Map<String, String>? headers,
      }) async {
    final uri = buildUri(endpoint, query: query);
    return wrappedPost(  // PUT via POST logic – adjust if backend strictly needs PUT
      uri,
      body ?? {},
      extraHeaders: headers,
    );
  }

  static Future<http.Response> delete(
      String endpoint, {
        Map<String, String>? query,
        Map<String, String>? headers,
      }) async {
    final uri = buildUri(endpoint, query: query);
    final h = _getHeaders(extraHeaders: headers);
    return http.delete(uri, headers: h).timeout(_timeout);
  }

  static Future<http.StreamedResponse> uploadMultipart({
    required String endpoint,
    required File file,
    String fileFieldName =
    'image', // change if backend expects different field name
    Map<String, String>?
    extraFields, // optional text fields (e.g. caption, type)
    Map<String, String>? extraHeaders,
  }) async {
    final uri = _buildUri(endpoint);
    final pathWithQuery = uri.path + (uri.hasQuery ? '?${uri.query}' : '');

    // Generate signed headers (same security as regular requests)
    final signedHeaders = _signedHeaders('POST', pathWithQuery);

    // Combine signed + extra headers
    final headers = {
      ...signedHeaders,
      ...?extraHeaders,
      // IMPORTANT: Do NOT set 'Content-Type' manually — MultipartRequest sets it automatically with boundary
    };

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..files.add(await http.MultipartFile.fromPath(fileFieldName, file.path));

    // Add any extra form fields if provided
    if (extraFields != null) {
      request.fields.addAll(extraFields);
    }

    if (kDebugMode) {
      print('➡️ Multipart POST $uri');
      print('Headers: $headers');
      print('Files: ${request.files.map((f) => f.filename).join(', ')}');
      if (extraFields != null) print('Extra fields: $extraFields');
    }

    return await request.send();
  }

}