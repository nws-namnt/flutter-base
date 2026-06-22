import 'package:flutter/material.dart';

enum AppLanguage {
  eng(locale: Locale('en'), label: 'English', flag: '🇺🇸'),
  vi(locale: Locale('vi'), label: 'Tiếng Việt', flag: '🇻🇳'),
  ja(locale: Locale('ja'), label: '日本語', flag: '🇯🇵');

  final Locale locale;
  final String label;
  final String flag;

  const AppLanguage({
    required this.locale,
    required this.label,
    required this.flag,
  });
}