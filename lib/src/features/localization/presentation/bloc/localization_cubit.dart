import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../l10n/l10n.dart';
import '../../repo/localization_repo.dart';
import 'localization_state.dart';

class LocalizationCubit extends Cubit<LocalizationState> {
  final LocalizationRepository _localizationRepository;

  LocalizationCubit(this._localizationRepository)
      : super(const LocalizationState(language: 'en', locale: Locale('en'))) {
    _initializeLocale();
  }

  /// On Android: saves to secure storage
  /// On iOS: just updates state, no storage
  Future<void> updateLocale(String value) async {
    if (!L10n.all.contains(Locale(value))) {
      debugPrint("->->-> Language '$value' not found in L10n list");
      return;
    }

    emit(state.copyWith(language: value, locale: Locale(value)));

    if (!Platform.isIOS) {
      // Only save on Android
      await _localizationRepository.addLanguageToSecureStorage(value);
    }
  }

  /// Load locale at startup
  /// iOS → system locale
  /// Android → stored locale or default
  Future<void> _initializeLocale() async {
    String languageCode;

    if (Platform.isIOS) {
      // Use system locale
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      languageCode = L10n.all.contains(Locale(systemLocale.languageCode))
          ? systemLocale.languageCode
          : 'en';
    } else {
      // Android → read from secure storage
      languageCode =
          await _localizationRepository.getLanguageFromSecureStorage('en');
    }

    emit(state.copyWith(language: languageCode, locale: Locale(languageCode)));
  }

  /// Optional helper to get current locale for API calls
  String get currentLanguageCode => state.language;
  Locale get currentLocale => state.locale;
}
