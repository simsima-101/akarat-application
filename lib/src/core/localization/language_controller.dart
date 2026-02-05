// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class LanguageController extends ChangeNotifier {
//   static LanguageController? _instance;
//   static LanguageController get instance => _instance ??= LanguageController._internal();
//
//   Locale _currentLocale = const Locale('en');
//   String? _userSelectedCode; // null = follow device, non-null = user forced this code
//
//   // Optional: let other parts of the app (screens, blocs) listen to real changes
//   VoidCallback? onLanguageChanged;
//
//   LanguageController._internal() {
//     _loadInitialLanguage();
//     // We will also listen to locale changes in main.dart / app lifecycle
//   }
//
//   Future<void> _loadInitialLanguage() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final savedCode = prefs.getString('language_code')?.trim().toLowerCase();
//
//       if (savedCode != null && ['ar', 'en', 'tr'].contains(savedCode)) {
//         _userSelectedCode = savedCode;
//         _currentLocale = Locale(savedCode);
//         debugPrint('→ Loaded user-selected language: $savedCode');
//       } else {
//         _userSelectedCode = null;
//         _updateFromDevice();
//         debugPrint('→ No user preference → following device language');
//       }
//     } catch (e) {
//       debugPrint('Failed to load language preference: $e');
//       _updateFromDevice();
//     }
//
//     notifyListeners();
//   }
//
//   void _updateFromDevice() {
//     final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
//     final deviceCode = deviceLocale.languageCode.toLowerCase().trim();
//
//     String newCode;
//     if (['ar', 'en', 'tr'].contains(deviceCode)) {
//       newCode = deviceCode;
//     } else {
//       newCode = 'en';
//     }
//
//     if (_currentLocale.languageCode != newCode) {
//       _currentLocale = Locale(newCode);
//       debugPrint('Device language detected → updated to: $newCode');
//       _notifyChange();
//     }
//   }
//
//   bool get isFollowingDevice => _userSelectedCode == null;
//
//   Locale get locale => _currentLocale;
//
//   String get languageCode => _currentLocale.languageCode.toLowerCase();
//
//   /// User manually selected a language in the app
//   Future<void> setLanguage(String code) async {
//     final normalized = code.toLowerCase().trim();
//     if (!['ar', 'en', 'tr'].contains(normalized)) {
//       debugPrint('Unsupported language code: $normalized');
//       return;
//     }
//
//     if (_currentLocale.languageCode == normalized) {
//       debugPrint('Language already set to $normalized — no change');
//       return;
//     }
//
//     _userSelectedCode = normalized;
//     _currentLocale = Locale(normalized);
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('language_code', normalized);
//       debugPrint('User selected & saved language: $normalized');
//     } catch (e) {
//       debugPrint('Failed to save language preference: $e');
//     }
//
//     _notifyChange();
//   }
//
//   /// User wants to go back to following device language
//   Future<void> useDeviceLanguage() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('language_code');
//       debugPrint('Cleared user language preference → now following device');
//     } catch (e) {
//       debugPrint('Failed to clear preference: $e');
//     }
//
//     _userSelectedCode = null;
//     _updateFromDevice();
//     _notifyChange();
//   }
//
//   /// Called when app resumes or when we want to sync with device
//   void refreshFromDeviceIfNeeded() {
//     final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
//     final deviceCode = deviceLocale.languageCode.toLowerCase().trim();
//
//     String newCode;
//     if (['ar', 'en', 'tr'].contains(deviceCode)) {
//       newCode = deviceCode;
//     } else {
//       newCode = 'en';
//     }
//
//     if (_currentLocale.languageCode != newCode) {
//       debugPrint('Device language changed → forcing update to $newCode (even if user selected)');
//       _userSelectedCode = null; // Clear user pref
//       useDeviceLanguage(); // Save clearance (removes from prefs)
//       _currentLocale = Locale(newCode);
//       _notifyChange();
//     }
//   }
//
//   void _notifyChange() {
//     notifyListeners();
//     onLanguageChanged?.call(); // Optional: trigger data reload, etc.
//     debugPrint('Language changed → now: ${languageCode.toUpperCase()}');
//   }
//
//   // Optional: helper to check RTL
//   bool get isRTL => languageCode == 'ar';
// }
