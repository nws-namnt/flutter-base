/// App-wide string constants, primarily [SharedPreferences] keys.
///
/// Centralising keys here prevents typos and makes key renames a
/// single-location change.
class AppConstants {
  /// [SharedPreferences] key that records whether the user has completed onboarding.
  static const String kOnboard = "kOnboard";

  /// Android notification channel configuration.
  static const String kAndroidChannelId = 'fox_channel';

  /// Android notification channel display name.
  static const String kAndroidChannelName = 'Fox Push Notification Channel';

  /// Android notification channel description.
  static const String kAndroidChannelDescription = 'This channel is used for push notifications.';

  /// Drawable resource name used as the small icon for push notifications.
  static const String kAndroidNotificationIcon = 'notification';
}