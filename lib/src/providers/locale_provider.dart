import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  String get languageCode => _locale.languageCode;

  static const List<String> supportedCodes = ['en', 'ar', 'tr'];

  /// Load saved or device locale on app start
  Future<void> loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString('app_locale');

      if (savedCode != null && supportedCodes.contains(savedCode)) {
        _locale = Locale(savedCode);
        debugPrint("Locale loaded from prefs: $savedCode");
      } else {
        // First launch: match device locale
        final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
        final deviceCode = deviceLocale.languageCode.toLowerCase();

        String matchedCode = 'en';
        if (supportedCodes.contains(deviceCode)) {
          matchedCode = deviceCode;
        } else if (deviceCode.startsWith('ar')) {
          matchedCode = 'ar';
        } else if (deviceCode.startsWith('tr')) {
          matchedCode = 'tr';
        }

        _locale = Locale(matchedCode);
        await prefs.setString('app_locale', matchedCode);
        debugPrint("First launch → matched device locale: $matchedCode");
      }
    } catch (e) {
      debugPrint("Error loading locale: $e → fallback to 'en'");
    }

    notifyListeners();
  }

  /// Change language (called from settings or elsewhere)
  Future<void> setLocale(String code) async {
    if (!supportedCodes.contains(code)) {
      debugPrint("Unsupported language code: $code");
      return;
    }

    if (code != _locale.languageCode) {
      _locale = Locale(code);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_locale', code);
      debugPrint("Language changed to: $code");
      notifyListeners();
    }
  }

  /// Sync with current device language (e.g. on resume or manual trigger)
  Future<void> syncWithDevice() async {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final deviceCode = deviceLocale.languageCode.toLowerCase();

    String targetCode = 'en';
    if (supportedCodes.contains(deviceCode)) {
      targetCode = deviceCode;
    } else if (deviceCode.startsWith('ar')) {
      targetCode = 'ar';
    } else if (deviceCode.startsWith('tr')) {
      targetCode = 'tr';
    }

    if (targetCode != _locale.languageCode) {
      await setLocale(targetCode);
    }
  }
}