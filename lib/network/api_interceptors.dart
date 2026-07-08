import 'package:dio/dio.dart';

/// Business-logic interceptor for the Dio HTTP client.
///
/// Handles cross-cutting concerns that require custom logic on every
/// HTTP request, response, or error — such as injecting authentication
/// tokens, refreshing expired credentials, or triggering app-level
/// side effects.
///
/// HTTP logging is intentionally omitted here; it is delegated to
/// [DioLoggerInterceptor] (pretty-printed output) and
/// [CurlLoggerInterceptor] (cURL export for external tools).
///
/// ## Responsibilities
///
/// | Hook          | Typical use cases                                         |
/// |---------------|-----------------------------------------------------------|
/// | [onRequest]   | Attach `Authorization` header, add query parameters       |
/// | [onResponse]  | Validate business status codes, emit analytics events     |
/// | [onError]     | Refresh expired tokens, map errors to typed exceptions    |
///
/// ## Registration
///
/// Registered once inside [ApiUtil.getDio]:
///
/// ```dart
/// _dio!.interceptors.add(ApiInterceptors());
/// ```
///
/// ## Example — injecting a Bearer token
///
/// ```dart
/// @override
/// Future<void> onRequest(
///   RequestOptions options,
///   RequestInterceptorHandler handler,
/// ) async {
///   final token = await AppSharedPreference.getToken();
///   if (token != null) {
///     options.headers['Authorization'] = 'Bearer $token';
///   }
///   return super.onRequest(options, handler);
/// }
/// ```
///
/// ## Example — refreshing an expired token on 401
///
/// ```dart
/// @override
/// Future<void> onError(
///   DioException err,
///   ErrorInterceptorHandler handler,
/// ) async {
///   if (err.response?.statusCode == 401) {
///     final newToken = await _refreshToken();
///     final opts = err.requestOptions
///       ..headers['Authorization'] = 'Bearer $newToken';
///     final response = await ApiUtil.getDio().fetch(opts);
///     return handler.resolve(response);
///   }
///   return super.onError(err, handler);
/// }
/// ```
class ApiInterceptors extends InterceptorsWrapper {
  /// Called before each request is sent. Attach auth headers or other
  /// request-level logic here — see the class-level "Registration" example.
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Inject auth headers or other request-level logic here.
    return super.onRequest(options, handler);
  }

  /// Called when a response is received. Add response transformation or
  /// analytics logic here.
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Add response transformation or analytics logic here.
    super.onResponse(response, handler);
  }

  /// Called when a request fails. Add error-recovery logic here (e.g. token
  /// refresh on 401) — see the class-level "Example" for a sample implementation.
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Add error-recovery logic here (e.g. token refresh on 401).
    return super.onError(err, handler);
  }
}
