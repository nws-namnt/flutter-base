// import 'dart:async';
// import 'dart:io';
//
// import 'package:dio/dio.dart';
//
// import '../utils/app_logger.dart' as error show err ;
//
// class ApiRetryInterceptor extends Interceptor {
//   final DioConnectivityRequestRetries requestRetries;
//
//   ApiRetryInterceptor({
//     required this.requestRetries,
//   });
//
//   @override
//   Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
//     if (_shouldRetry(err)) {
//       try {
//         return requestRetries.scheduleRequestRetry(err.requestOptions, handler);
//       } catch (e) {
//         error.err(e);
//       }
//     }
//     // Let the error "pass through" if it's not the error we're looking for
//     error.err(err);
//   }
//
//   bool _shouldRetry(DioException err) {
//     return err.type == DioExceptionType.unknown &&
//         err.error != null &&
//         (err.error is SocketException || err.error is ArgumentError);
//   }
// }
//
// class DioConnectivityRequestRetries {
//   final Dio dio;
//
//   DioConnectivityRequestRetries({required this.dio});
//
//   Future<dynamic> scheduleRequestRetry(RequestOptions requestOptions, ErrorInterceptorHandler handler) async {
//     late StreamSubscription streamSubscription;
//
//     void onListenConnectivity(bool isConnect) async {
//       if(isConnect) {
//         await streamSubscription.cancel();
//       }
//
//       try {
//         final response = await dio.requestUri(
//           requestOptions.uri,
//           cancelToken: requestOptions.cancelToken,
//           data: requestOptions.data,
//           onReceiveProgress: requestOptions.onReceiveProgress,
//           onSendProgress: requestOptions.onSendProgress,
//           //queryParameters: requestOptions.queryParameters,
//           options: Options(
//               method: requestOptions.method,
//               headers: requestOptions.headers
//           ),
//         );
//
//         handler.resolve(response);
//       } catch (e, s) {
//         handler.reject(DioException(
//           requestOptions: requestOptions,
//           error: e,
//           stackTrace: s,
//           type: DioExceptionType.unknown,
//         ));
//       }
//     }
//
//     streamSubscription = NetworkService.instance.connectStream.listen(onListenConnectivity);
//   }
// }