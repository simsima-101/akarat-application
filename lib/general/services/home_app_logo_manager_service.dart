import 'package:Akarat/general/utils/app_images.dart';
import 'package:flutter/material.dart';

class HomeAppLogoManagerService {
  static const Map<String, String> _homeAppLogos = {
    'en': AppImages.homeAppLogoEN,
    'ar': AppImages.homeAppLogoAR,
    'tr': AppImages.homeAppLogoEN
  };

  // Get logo based on Locale
  static String getHomeAppLogoBasedLocale(Locale locale) {
    return _homeAppLogos[locale.languageCode] ?? _homeAppLogos['en']!;
  }
}
