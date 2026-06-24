import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Type-safe wrapper around flutter_dotenv.
/// Usage:
///   await AppEnv.load(flavor: 'dev');
///   print(AppEnv.apiBaseUrl);
///
/// Keys are read from `assets/env/.env.<flavor>`.
/// Required keys throw [StateError] at load time if missing or empty.
class AppEnv {
  AppEnv._();

  static String _flavor = 'dev';

  /// The active flavor detected at startup ('dev' | 'uat' | 'prod').
  static String get flavor => _flavor;

  // ── Required keys ──────────────────────────────────────────────────────────

  /// Base URL for the REST API. Required.
  static String get apiBaseUrl => _require('API_BASE_URL');

  // ── Optional keys with defaults ────────────────────────────────────────────

  /// API key / token. Defaults to empty string.
  static String get apiKey => _optional('API_KEY', '');

  /// Gemini API key for AI features. Defaults to empty string.
  ///
  /// Get a free key at https://aistudio.google.com/apikey and set
  /// GEMINI_API_KEY in each `assets/env/.env.<flavor>` file.
  static String get geminiApiKey => _optional('GEMINI_API_KEY', '');

  /// Whether verbose (request/response) logging is enabled. Defaults to false.
  static bool get enableLogging =>
      _optional('ENABLE_LOGGING', 'false').toLowerCase() == 'true';

  /// Whether cURL logging is enabled. Defaults to false.
  ///
  /// When true, [CurlLoggerInterceptor] is attached to the Dio client so every
  /// outgoing request is also printed as a cURL command — useful for reproducing
  /// requests in Postman or a terminal. Should be false in uat/prod.
  static bool get enableCurlLogging =>
      _optional('ENABLE_CURL_LOGGING', 'false').toLowerCase() == 'true';

  /// Whether the debug banner is shown. Defaults to false.
  static bool get showDebugBanner =>
      _optional('SHOW_DEBUG_BANNER', 'false').toLowerCase() == 'true';

  /// Network connect/receive timeout in milliseconds. Defaults to 30000 (30 s).
  ///
  /// Maps to [Dio.options.connectTimeout] and [Dio.options.receiveTimeout].
  static int get timeoutMs =>
      int.tryParse(_optional('TIMEOUT_MS', '30000')) ?? 30000;

  /// Load the env file for [flavor] and validate required keys.
  /// Must be called before accessing any getter (typically in main()).
  static Future<void> load({required String flavor}) async {
    _flavor = flavor;
    await dotenv.load(fileName: 'assets/env/.env.$flavor');
    _validate();
  }

  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError(
        '[AppEnv] Required key "$key" is missing or empty in .env.$_flavor',
      );
    }
    return value;
  }

  static String _optional(String key, String defaultValue) =>
      dotenv.env[key]?.isNotEmpty == true ? dotenv.env[key]! : defaultValue;

  static void _validate() {
    // Eagerly read all required keys so startup fails fast with a clear message.
    apiBaseUrl;
  }
}
