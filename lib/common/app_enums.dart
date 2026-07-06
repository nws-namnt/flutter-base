import 'package:flutter/material.dart';

import '../generated/l10n.dart';

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

/// Represents the status of a data-loading operation.
enum LoadStatus {
  /// No load has been triggered yet.
  initial,

  /// A load is currently in progress.
  loading,

  /// The load completed successfully.
  success,

  /// The load failed due to an error.
  failure,
}

/// Represents the status of a user-initiated action (e.g. submit, delete).
enum ActionStatus {
  /// No action has been triggered yet.
  initial,

  /// The action is currently in progress.
  loading,

  /// The action completed successfully.
  success,

  /// The action failed due to an error.
  failure,

  /// Additional items are being loaded (pagination).
  loadMore,
}

/// URI scheme used when launching an external app via [onLaunchExternalApp].
///
/// Each value maps to a well-known URI scheme. Pass the matching [data] type
/// documented on [onLaunchExternalApp] to avoid a malformed URI.
enum LaunchExternalType {
  /// Opens the default SMS app pre-filled with a recipient number.
  ///
  /// Scheme: `sms:`. Pass a phone number as `data`, e.g. `'+84123456789'`.
  sms('sms'),

  /// Dials a phone number in the default phone app.
  ///
  /// Scheme: `tel:`. Pass a phone number as `data`, e.g. `'+84123456789'`.
  tel('tel'),

  /// Opens the default email client with a pre-filled recipient.
  ///
  /// Scheme: `mailto:`. Pass an email address as `data`, e.g. `'user@example.com'`.
  /// Use the `mailSubject` parameter on [onLaunchExternalApp] to set the subject line.
  mail('mailto'),

  /// Opens a URL in a browser or in-app web view.
  ///
  /// Scheme derived from the URL itself via [Uri.parse]. Pass a full URL as
  /// `data`, e.g. `'https://example.com/path?q=1'`.
  webview('https'),

  /// Opens a local file with the system's default handler for its MIME type.
  ///
  /// Scheme: `file:`. Pass an absolute file-system path as `data`,
  /// e.g. `'/storage/emulated/0/document.pdf'`.
  /// The file must exist on disk; [onLaunchExternalApp] checks existence before launching.
  file('file');

  /// The URI scheme string associated with this type.
  final String type;

  const LaunchExternalType(this.type);
}

enum AppNotifyType {
  success(bgColor: Colors.green, icon: Icons.check_circle),
  error(bgColor: Colors.red, icon: Icons.error),
  warning(bgColor: Colors.yellow, icon: Icons.warning),
  info(bgColor: Colors.blue, icon: Icons.info);

  final Color bgColor;
  final IconData icon;

  String get title => switch (this) {
    success => S.current.lb_flush_success,
    error => S.current.lb_flush_error,
    warning => S.current.lb_flush_warning,
    info => S.current.lb_flush_info,
  };

  String get message => switch (this) {
    success => S.current.lb_flush_success,
    error => S.current.lb_flush_error,
    warning => S.current.lb_flush_warning,
    info => S.current.lb_flush_info,
  };

  const AppNotifyType({required this.bgColor, required this.icon});
}