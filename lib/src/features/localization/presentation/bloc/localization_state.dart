import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class LocalizationState extends Equatable {
  final String language;
  final Locale locale;

  const LocalizationState({required this.language, required this.locale});

  LocalizationState copyWith({String? language, Locale? locale}) {
    return LocalizationState(
      language: language ?? this.language,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [language, locale];
}
