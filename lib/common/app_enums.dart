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

enum AppStorageKey {
  kTest('kTest');

  final String key;

  const AppStorageKey(this.key);
}

enum AppPreferenceKey {
  kTest('kTest');

  final String key;

  const AppPreferenceKey(this.key);
}

enum ValidatorType {
  email(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
  password(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,20}$'),
  name(r'^[a-zA-Z0-9\s]{0,255}$'),
  phone(r'^\d{10}$');

  final String rawReg;

  const ValidatorType(this.rawReg);
}