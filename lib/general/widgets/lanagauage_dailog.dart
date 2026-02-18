import 'dart:io';

import 'package:Akarat/src/features/localization/data/model/language_mdoel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';
import '../../src/features/localization/presentation/bloc/localization_cubit.dart';
import '../../src/features/localization/presentation/bloc/localization_state.dart';

void showChangeLanguageDialog({
  required BuildContext context,
  VoidCallback? onOpenSettings,
  void Function(Locale language)? onLanguageSelected,
}) {
  final l10n = AppLocalizations.of(context)!;
  showModalBottomSheet(


    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
    ),
    builder: (_) {
      if (Platform.isIOS) {
        // iOS bottom sheet (UNCHANGED)
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.language, size: 27),
                  const SizedBox(width: 10),
                  Text(
                    l10n.changeLanguage,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.changeLanguageInstruction,
                    style: const TextStyle(fontSize: 15.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.stepOpenSettings,
                    style: const TextStyle(fontSize: 15.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                   l10n.stepSelectLanguage,
                    style: const TextStyle(fontSize: 15.5),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onOpenSettings,
                  child: Text(
                    l10n.openSettings,
                    style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      } else {
        // 🔴 ANDROID SECTION (UPDATED)
        final languageList = [
          LanguageModel(language: l10n.english, locale: Locale("en")),
          LanguageModel(language: l10n.arabic, locale: Locale("ar")),
          LanguageModel(language: l10n.turkish, locale: Locale("tr")),
        ];

        return Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 35),
          child: BlocBuilder<LocalizationCubit, LocalizationState>(
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.language, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          l10n.changeLanguage,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  ...languageList.map((lang) {
                    final isSelected =
                        state.locale.languageCode == lang.locale.languageCode;

                    return Container(
                      color: isSelected
                          ? Colors.red
                              .withOpacity(0.08) // 👈 light reddish highlight
                          : Colors.transparent,
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        title: Text(
                          lang.language,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected ? Colors.red : Colors.black,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.red)
                            : const Icon(Icons.chevron_right),
                        onTap: () {
                          if (onLanguageSelected != null) {
                            onLanguageSelected(lang.locale);
                            // Navigator.pop(context);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
        );
      }
    },
  );
}
