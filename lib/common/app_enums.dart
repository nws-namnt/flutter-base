import 'package:flutter/material.dart';

/// Supported app locales.
///
/// Each value carries the [Locale], a display [label], and a [flag] emoji.
enum AppLanguage {
  /// English (US).
  eng(locale: Locale('en'), label: 'English', flag: '🇺🇸'),

  /// Vietnamese.
  vi(locale: Locale('vi'), label: 'Tiếng Việt', flag: '🇻🇳'),

  /// Japanese.
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

/// Keys used by [AppStorage] (GetStorage).
///
/// Add a new value here before adding the corresponding
/// set / get / remove methods in [AppStorage].
enum AppStorageKey {
  /// Developer / QA test flag.
  kTest('kTest');

  final String key;

  const AppStorageKey(this.key);
}

/// Keys used by [AppPreference] (SharedPreferences).
///
/// Add a new value here before adding the corresponding
/// set / get / remove methods in [AppPreference].
enum AppPreferenceKey {
  /// Developer / QA test flag.
  kTest('kTest');

  final String key;

  const AppPreferenceKey(this.key);
}

/// Input field types supported by [onValidate].
///
/// Each value carries a [rawReg] regex pattern used for validation.
enum ValidatorType {
  /// Standard email format: `user@domain.tld`.
  email(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),

  /// Password: 8–20 chars, at least one lowercase, uppercase, and digit.
  password(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,20}$'),

  /// Display name: alphanumeric and spaces, max 255 chars.
  name(r'^[a-zA-Z0-9\s]{0,255}$'),

  /// Vietnamese phone number: exactly 10 digits.
  phone(r'^\d{10}$');

  /// The regex pattern used to validate this field type.
  final String rawReg;

  const ValidatorType(this.rawReg);
}
