import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../l10n/l10n.dart';
import '../../repo/localization_repo.dart';
import 'localization_state.dart';

class LocalizationCubit extends Cubit<LocalizationState> {
  final LocalizationRepository _repo;

  bool _isUserOverridden = false;
  bool get isUserOverridden => _isUserOverridden;

  LocalizationCubit(this._repo)
      : super(const LocalizationState(language: 'en', locale: Locale('en'))) {
    _loadInitial();
  }

  /// Load initial language at app startup
  Future<void> _loadInitial() async {
    String code = 'en';

    if (Platform.isIOS) {
      // iOS: always follow system locale (no persistent override)
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      code = _resolveSupportedLanguage(systemLocale.languageCode);
    } else {
      // Android: respect user override if exists
      final saved = await _repo.getSavedLanguage();
      final overridden = await _repo.getIsOverriddenFlag() ?? false;

      if (overridden && saved != null && L10n.all.any((l) => l.languageCode == saved)) {
        _isUserOverridden = true;
        code = saved;
      } else {
        // Fallback to system
        final sys = WidgetsBinding.instance.platformDispatcher.locale;
        code = _resolveSupportedLanguage(sys.languageCode);
      }
    }

    emit(state.copyWith(language: code, locale: Locale(code)));
  }

  /// Manually change language
  Future<void> setLanguage(String langCode, {required bool isUserChoice}) async {
    if (!L10n.all.any((l) => l.languageCode == langCode)) {
      debugPrint("→ Language code '$langCode' is not supported.");
      return;
    }

    if (isUserChoice) {
      _isUserOverridden = true;
      if (!Platform.isIOS) {
        // Only save on Android
        await _repo.saveLanguage(langCode);
        await _repo.setOverriddenFlag(true);
      }
    }

    emit(state.copyWith(language: langCode, locale: Locale(langCode)));
  }

  /// Reset to follow system language
  Future<void> resetToSystem() async {
    _isUserOverridden = false;

    if (!Platform.isIOS) {
      // Clear override on Android only
      await _repo.setOverriddenFlag(false);
      // Optionally clear saved language (optional)
      // await _repo.saveLanguage(null);
    }

    final sys = WidgetsBinding.instance.platformDispatcher.locale;
    final code = _resolveSupportedLanguage(sys.languageCode);

    emit(state.copyWith(language: code, locale: Locale(code)));
  }

  /// Map any language code to supported one or fallback to 'en'
  String _resolveSupportedLanguage(String code) {
    final supportedCodes = L10n.all.map((l) => l.languageCode).toSet();
    if (supportedCodes.contains(code)) return code;

    // Fallback for variants like 'ar_AE' → 'ar'
    final baseCode = code.split('_').first;
    return supportedCodes.contains(baseCode) ? baseCode : 'en';
  }

  /// Getters
  String get currentLanguageCode => state.language;
  Locale get currentLocale => state.locale;

  /// Legacy method name (optional)
  Future<void> updateLocale(String value) async {
    await setLanguage(value, isUserChoice: true);
  }
}