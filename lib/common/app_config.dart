/// Static configuration constants shared across the app.
///
/// Values here are compile-time constants that do not vary by flavor.
/// For environment-specific values, see [AppEnv].
class AppConfig {
  /// The local font family used for the app's text theme.
  ///
  /// Must match the `family` declared under `flutter > fonts` in pubspec.yaml.
  static const String kTextTheme = "Montserrat";
}
