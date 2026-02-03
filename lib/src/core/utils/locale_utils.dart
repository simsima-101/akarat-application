// lib/services/utils/locale_utils.dart
import 'dart:ui';
import 'package:flutter/material.dart';

/// ✅ UI-side (use ONLY inside widgets)
/// Returns normalized language code based on current context locale
String getCurrentLanguageCode(BuildContext context) {
  final locale = Localizations.localeOf(context);
  return locale.languageCode.toLowerCase(); // returns 'ar' or 'en'
}


/// ✅ Service-side (NO BuildContext — safe for ApiService)
/// Returns normalized language code based on system locale
String getCurrentLanguageCodeWithoutContext() {
  final locale = PlatformDispatcher.instance.locale;
  return _normalize(locale.languageCode);
}

/// ✅ Use this to force language from app settings (optional)
/// Example: getNormalizedLanguageCode('ar-EG') => 'ar'
String getNormalizedLanguageCode(String code) {
  return _normalize(code);
}

/// Shared normalization logic
String _normalize(String code) {
  final lc = code.toLowerCase().trim();

  if (lc.startsWith('ar')) return 'ar'; // Arabic
  if (lc.startsWith('tr')) return 'tr'; // Turkish
  return 'en'; // Default fallback
}

/// ✅ Optional: check if language is RTL
bool isRTL(String code) {
  final lang = _normalize(code);
  return lang == 'ar';
}

/// ✅ Optional: convert locale to a Locale object for MaterialApp
Locale getLocaleFromCode(String code) {
  final lang = _normalize(code);
  return Locale(lang);
}
