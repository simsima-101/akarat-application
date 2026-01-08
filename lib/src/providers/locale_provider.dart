// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class LocaleProvider extends ChangeNotifier {
//   Locale _locale = const Locale('en'); // Default fallback to English
//
//   Locale get locale => _locale;
//
//   // Supported languages (must match your AppLocalizations.supportedLocales)
//   final List<String> supportedLanguageCodes = ['en', 'ar', 'tr'];
//
//   // Load saved locale from storage, or use device locale on first launch
//   Future<void> loadLocale() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedCode = prefs.getString('app_locale');
//
//     if (savedCode != null && supportedLanguageCodes.contains(savedCode)) {
//       _locale = Locale(savedCode);
//     } else {
//       // First launch: try to match device language
//       final deviceLocale = PlatformDispatcher.instance.locale;
//       final deviceCode = deviceLocale.languageCode;
//
//       if (supportedLanguageCodes.contains(deviceCode)) {
//         _locale = Locale(deviceCode);
//         // Save it for next time
//         await prefs.setString('app_locale', deviceCode);
//       }
//     }
//     notifyListeners();
//   }
//
//   // Change locale manually (useful later for in-app picker)
//   Future<void> setLocale(String languageCode) async {
//     if (!supportedLanguageCodes.contains(languageCode)) return;
//
//     _locale = Locale(languageCode);
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('app_locale', languageCode);
//     notifyListeners();
//   }
//
//   // Sync with current device system language
//   Future<void> syncWithDevice() async {
//     final deviceLocale = PlatformDispatcher.instance.locale;
//     final code = deviceLocale.languageCode;
//
//     if (supportedLanguageCodes.contains(code) && code != _locale.languageCode) {
//       await setLocale(code);
//     }
//   }
// }