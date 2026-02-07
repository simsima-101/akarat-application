// lib/core/services/api_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:Akarat/main.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../features/localization/presentation/bloc/localization_cubit.dart';

class ApiService {
  // ==============================a
  // 🔐 Credentials
  // ==============================
  static const String _appKey = 'akarat_mobile_key_2025';
  static const String _appSecret = 'akarat_mobile_secret_2025';

  // ==============================
  // Base URL
  // ==============================
  static String? _runtimeBaseUrl;

  static String get baseUrl {
    final rc = FirebaseRemoteConfig.instance;
    final rcValue = rc.getString('api_base_url').trim();
    if (rcValue.isNotEmpty && rcValue.startsWith('https://')) {
      final cleanRc = rcValue.replaceFirst(RegExp(r'/+$'), '');
      if (kDebugMode) print('Using Remote Config base URL: $cleanRc');
      return cleanRc;
    }

    if (_runtimeBaseUrl != null && _runtimeBaseUrl!.isNotEmpty) {
      final clean = _runtimeBaseUrl!.replaceFirst(RegExp(r'/+$'), '');
      if (kDebugMode) print('Using runtime override base: $clean');
      return clean;
    }

    const fromDefine = String.fromEnvironment('API_BASE_URL');
    final fromEnv = (dotenv.env['API_BASE_URL'] ?? '').trim();

    final fallback = fromDefine.isNotEmpty
        ? fromDefine
        : fromEnv.isNotEmpty
            ? fromEnv
            : 'https://akarat.com/api';

    final cleanFallback = fallback.replaceFirst(RegExp(r'/+$'), '');
    if (kDebugMode) print('Falling back to base URL: $cleanFallback');

    return cleanFallback;
  }

  // ==============================
  // Build URI
  // ==============================
  static Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final cleanEndpoint =
        endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    var uri = Uri.parse('$baseUrl/$cleanEndpoint');
    if (queryParams != null) uri = uri.replace(queryParameters: queryParams);
    return uri;
  }

  static Uri buildUri(String endpoint, {Map<String, String>? query}) =>
      _buildUri(endpoint, query);

  static String _getLanguageCode() {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return 'en';
    return ctx.read<LocalizationCubit>().state.language;
  }

  // ==============================
  // Signature
  // ==============================
  static Map<String, String> _signedHeaders(String method, String path) {
    final timestamp =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final payload = method.toUpperCase() + path + timestamp;

    final hmac = Hmac(sha256, utf8.encode(_appSecret));
    final signature = hmac.convert(utf8.encode(payload)).toString();
    // final langCode = navigatorKey.currentContext!
    //     .read<LocalizationCubit>()
    //     .currentLanguageCode;

    final langCode = _getLanguageCode();

    return {
      'X-APP-KEY': _appKey,
      'X-APP-TIMESTAMP': timestamp,
      'X-APP-SIGNATURE': signature,
      'Accept-Language': langCode,
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  // ==============================
  // Core request
  // ==============================
  static Future<http.Response> request({
    required String method,
    required String endpoint,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    Map<String, String>? extraHeaders,
  }) async {
    final uri = _buildUri(endpoint, query);
    final pathWithQuery = uri.path + (uri.hasQuery ? '?${uri.query}' : '');

    final headers = _signedHeaders(method, pathWithQuery);

    // Merge extra headers
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

  // ==============================
  // Helpers
  // ==============================
  static Future<http.Response> get(
    String endpoint, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) =>
      request(
          method: 'GET',
          endpoint: endpoint,
          query: query,
          extraHeaders: headers);

  static Future<http.Response> post(
    String endpoint, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) =>
      request(
          method: 'POST',
          endpoint: endpoint,
          query: query,
          body: body,
          extraHeaders: headers);

  static Future<http.Response> put(
    String endpoint, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) =>
      request(
          method: 'PUT',
          endpoint: endpoint,
          query: query,
          body: body,
          extraHeaders: headers);

  static Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) =>
      request(
          method: 'DELETE',
          endpoint: endpoint,
          query: query,
          extraHeaders: headers);

  // ==============================
  // Multipart File Upload (new method)
  // ==============================
  /// Uploads a file using multipart/form-data with signed headers
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

  // ==============================
  // Optional: runtime base override
  // ==============================
  static void setRuntimeBaseUrl(String baseUrl) => _runtimeBaseUrl = baseUrl;
}
