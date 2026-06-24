import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../services/network_service.dart';
import '../utils/app_logger.dart' as logger;

/// A Dio interceptor that queues failed requests and retries them automatically
/// once internet connectivity is restored.
///
/// ## How it works
///
/// 1. [onError] fires when a Dio request fails.
/// 2. [_shouldRetry] checks whether the failure is connectivity-related
///    ([SocketException] or [ArgumentError] with [DioExceptionType.unknown]).
/// 3. If retryable, [DioConnectivityRequestRetries.scheduleRequestRetry]
///    subscribes to [NetworkService.connectStream] and re-fires the original
///    request the moment internet comes back.
/// 4. Non-retryable errors pass straight through via
///    [ErrorInterceptorHandler.next] — no request is ever left hanging.
///
/// ## Registration
///
/// Add to [ApiUtil.getDio] after [ApiInterceptors]:
///
/// ```dart
/// _dio!.interceptors.add(
///   ApiRetryInterceptor(
///     requestRetries: DioConnectivityRequestRetries(dio: _dio!),
///   ),
/// );
/// ```
class ApiRetryInterceptor extends Interceptor {
  final DioConnectivityRequestRetries requestRetries;

  ApiRetryInterceptor({required this.requestRetries});

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldRetry(err)) {
      try {
        return requestRetries.scheduleRequestRetry(err.requestOptions, handler);
      } catch (e, s) {
        logger.err('ApiRetryInterceptor: failed to schedule retry', e, s);
        return handler.next(err);
      }
    }
    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.unknown &&
        err.error != null &&
        (err.error is SocketException || err.error is ArgumentError);
  }
}

/// Holds a single queued [RequestOptions] and replays it once
/// [NetworkService] reports a live connection.
///
/// Only one retry attempt is made — if the retry itself fails, the error is
/// forwarded via [ErrorInterceptorHandler.reject] so the caller always gets
/// a result and the request is never left hanging.
class DioConnectivityRequestRetries {
  final Dio dio;

  DioConnectivityRequestRetries({required this.dio});

  Future<void> scheduleRequestRetry(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    late StreamSubscription<bool> subscription;

    subscription = networkService.connectStream.listen(
      (isConnected) async {
        if (!isConnected) return;

        await subscription.cancel();

        try {
          final response = await dio.requestUri(
            requestOptions.uri,
            cancelToken: requestOptions.cancelToken,
            data: requestOptions.data,
            onReceiveProgress: requestOptions.onReceiveProgress,
            onSendProgress: requestOptions.onSendProgress,
            options: Options(
              method: requestOptions.method,
              headers: requestOptions.headers,
            ),
          );
          handler.resolve(response);
        } catch (e, s) {
          logger.err('ApiRetryInterceptor: retry request failed', e, s);
          handler.reject(
            DioException(
              requestOptions: requestOptions,
              error: e,
              stackTrace: s,
              type: DioExceptionType.unknown,
            ),
          );
        }
      },
    );
  }
}
