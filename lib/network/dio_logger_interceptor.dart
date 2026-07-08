import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../common/app_env.dart' show AppEnv;

/// Pretty-printed HTTP logger for the Dio client.
///
/// Wraps [PrettyDioLogger] as a singleton so the same instance is shared
/// across the app. Logs full request and response details — headers,
/// bodies, and status codes — in a human-readable, coloured format.
///
/// Errors are included (`error: true`) so failed requests are visible in the
/// log alongside their request details. Business-level error handling and
/// recovery (e.g. token refresh on 401) is still delegated to [ApiInterceptors].
///
/// ## Registration
///
/// Registered once in [ApiUtil.getDio]:
///
/// ```dart
/// _dio!.interceptors.add(DioLoggerInterceptor());
/// ```
class DioLoggerInterceptor extends PrettyDioLogger {
  // singleton constructor
  DioLoggerInterceptor._internal() : super(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    responseHeader: true,
    error: true,
    compact: true,
    maxWidth: 120,
    enabled: AppEnv.enableLogging,
  );

  static final DioLoggerInterceptor _instance = DioLoggerInterceptor._internal();

  /// Returns the singleton [DioLoggerInterceptor] instance.
  factory DioLoggerInterceptor() => _instance;
}
