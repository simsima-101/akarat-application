import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'; // for kDebugMode

import 'package:Akarat/src/core/localization/language_controller.dart'; // ← make sure this import exists

class DioClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://qa.akarat.com/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  )..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // Primary: get language from LanguageController (your app's current state)
        String langCode = 'en'; // safe default fallback

        try {
          langCode = LanguageController.instance.languageCode;
        } catch (e) {
          // If controller not ready yet (very early app start), use device locale
          langCode = WidgetsBinding.instance.platformDispatcher.locale.languageCode.toLowerCase();
          if (kDebugMode) {
            print('Warning: LanguageController not ready yet → fallback to device locale: $langCode');
          }
        }

        // Normalize to supported short codes
        if (langCode.startsWith('ar')) {
          langCode = 'ar';
        } else if (langCode.startsWith('tr')) {
          langCode = 'tr';
        } else {
          langCode = 'en';
        }

        // Set the header
        options.headers['Accept-Language'] = langCode;

        // ─── Your original debug prints ───
        if (kDebugMode) {
          print('REQUEST HEADERS 👉 ${options.headers}');

          // Debug only for amenities endpoint
          if (options.path.contains('amenities')) {
            print('🟢 AMENITIES LANG 👉 $langCode');
            print('🟢 HEADERS 👉 ${options.headers}');
          }

          // Additional clean debug line
          print('→ Sending Accept-Language: $langCode  (for path: ${options.path})');
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) {
        return handler.next(error);
      },
    ),
  );
}