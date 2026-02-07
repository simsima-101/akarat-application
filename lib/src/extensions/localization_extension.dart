import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations_ar.dart';
import '../../l10n/app_localizations_en.dart';
import '../../l10n/app_localizations_tr.dart';
import '../features/localization/presentation/bloc/localization_cubit.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n {
    final loc = AppLocalizations.of(this);

    if (loc != null) {
      return loc;
    }

    // Fallback during rebuild / timing issues
    debugPrint("Warning: AppLocalizations not ready yet → using fallback");

    // Try to get current language from LocalizationCubit (non-listening read)
    final cubit = read<LocalizationCubit>();
    final lang = cubit.state.language.toLowerCase();

    // Return the matching localization class
    switch (lang) {
      case 'ar':
        return AppLocalizationsAr();
      case 'tr':
        return AppLocalizationsTr();
      default:
        return AppLocalizationsEn();
    }
  }

  // Optional: nullable version (no fallback logic)
  AppLocalizations? get l10nOrNull => AppLocalizations.of(this);
}