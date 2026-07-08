import 'package:dio/dio.dart';
import 'package:flutter_base/base.dart';

import 'api_client.dart';
import 'api_interceptors.dart';
import 'api_retry_interceptor.dart';
import 'curl_logger_interceptor.dart';
import 'dio_logger_interceptor.dart';

/// Factory and singleton provider for the app's configured [Dio] instance
/// and the [ApiClient] Retrofit interface.
///
/// Configuration is read from the active flavor's `.env` file via [AppEnv].
///
/// ## Environment keys
///
/// | Key                   | Purpose                                               |
/// |-----------------------|-------------------------------------------------------|
/// | `API_BASE_URL`        | Base URL for all API requests                         |
/// | `TIMEOUT_MS`          | Connect/receive timeout in milliseconds               |
/// | `ENABLE_LOGGING`      | Enables [DioLoggerInterceptor] output when `"true"`   |
/// | `ENABLE_CURL_LOGGING` | Attaches [CurlLoggerInterceptor] when `"true"`        |
///
/// ## Interceptor stack (in registration order)
///
/// 1. [ApiInterceptors] — auth token injection and error-recovery logic.
/// 2. [ApiRetryInterceptor] — queues failed requests and retries on reconnect.
/// 3. [DioLoggerInterceptor] — pretty-printed request/response logging.
/// 4. [CurlLoggerInterceptor] — cURL export; dev only via `ENABLE_CURL_LOGGING`.
///
/// ## Usage
///
/// ```dart
/// final client = ApiUtil.getApiClient();
/// final response = await client.onLogin({'email': '...', 'password': '...'});
/// ```
class ApiUtil {
  static Dio? _dio;

  ApiUtil._internal();

  static final ApiUtil _apiUtil = ApiUtil._internal();

  /// Returns the singleton [ApiUtil] instance.
  factory ApiUtil() => _apiUtil;

  /// Returns the singleton [Dio] instance, creating and configuring it on
  /// the first call.
  static Dio getDio() {
    if (_dio == null) {
      _dio = Dio();
      _dio!.options.baseUrl = AppEnv.apiBaseUrl;
      _dio!.options.connectTimeout =  Duration(milliseconds: AppEnv.timeoutMs);
      _dio!.options.receiveTimeout =  Duration(milliseconds: AppEnv.timeoutMs);

      _dio!.interceptors.add(ApiInterceptors());
      _dio!.interceptors.add(
        ApiRetryInterceptor(
          requestRetries: DioConnectivityRequestRetries(dio: _dio!),
        ),
      );
      _dio!.interceptors.add(DioLoggerInterceptor());

      if (AppEnv.enableCurlLogging) {
        _dio!.interceptors.add(CurlLoggerInterceptor());
      }
    }
    return _dio!;
  }

  /// Returns an [ApiClient] backed by the shared [Dio] instance.
  static ApiClient getApiClient() => ApiClient(getDio());
}
