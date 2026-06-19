/// App-wide string constants, primarily [SharedPreferences] keys.
///
/// Centralising keys here prevents typos and makes key renames a
/// single-location change.
class AppConstants {
  /// [SharedPreferences] key that records whether the user has completed onboarding.
  static const String kOnboard = "kOnboard";
}