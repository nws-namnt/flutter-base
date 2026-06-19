/// Common constants, configuration, theming, and environment helpers
/// shared across all layers of the app.
///
/// - [AppColors] — semantic color palette constants
/// - [AppConfig] — compile-time constants (font family, etc.)
/// - [AppConstants] — [SharedPreferences] key constants
/// - [AppEnv] — runtime environment config loaded from `.env.<flavor>`
/// - [M3Theme] — Material 3 light / dark / high-contrast [ThemeData]
// ignore: unnecessary_library_name
library common;

export 'app_colors.dart';
export 'app_config.dart';
export 'app_constants.dart';
export 'app_env.dart';
export 'app_themes.dart';
