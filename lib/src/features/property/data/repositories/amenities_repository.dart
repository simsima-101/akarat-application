// lib/core/api/api_client.dart
import 'package:dio/dio.dart';
import 'dart:ui' as ui;

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://qa.akarat.com/api',
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: Duration(seconds: 12),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  // Call this whenever you want to ensure the header is up-to-date
  static void updateLanguageHeader() {
    final String langCode = ui.window.locale.languageCode.toLowerCase();
    // You can also do: '${locale.languageCode}-${locale.countryCode ?? ''}'
    dio.options.headers['Accept-Language'] = langCode;
  }

  // Optional: auto-update on locale change
  static void initialize() {
    updateLanguageHeader();
    // If you support hot locale change without restart (rare), listen here:
    // ui.window.onLocaleChanged = updateLanguageHeader;
  }
}