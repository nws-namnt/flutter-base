/// App-wide string constants, primarily [SharedPreferences] keys.
///
/// Centralising keys here prevents typos and makes key renames a
/// single-location change.
class AppConstants {
  /// [SharedPreferences] key that records whether the user has completed onboarding.
  static const String kOnboard = "kOnboard";

  /// Android notification channel configuration.
  static const String kAndroidChannelId = 'fox_channel';
  static const String kAndroidChannelName = 'Fox Push Notification Channel';
  static const String kAndroidChannelDescription = 'This channel is used for push notifications.';
  static const String kAndroidNotificationIcon = 'notification';
}