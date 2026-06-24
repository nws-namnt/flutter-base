import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

/// Interceptor that emits outgoing HTTP requests as cURL commands.
///
/// Designed for reproducing requests in external tools such as Postman,
/// Bruno, or a terminal session. On error the cURL command is always
/// emitted; on a successful response it is emitted only when
/// [printOnSuccess] is `true`.
///
/// This interceptor is conditionally attached by [ApiUtil] based on the
/// `ENABLE_CURL_LOGGER` key in the active flavor's `.env` file —
/// `true` for `dev`, `false` for `uat` and `prod`.
///
/// ## Example output
///
/// ```
/// curl -i -X POST \
///   -H "Content-Type: application/json" \
///   -H "Authorization: Bearer <token>" \
///   -d "{\"email\":\"user@example.com\",\"password\":\"***\"}" \
///   "https://api.dev.example.com/auths/login"
/// ```
class CurlLoggerInterceptor extends Interceptor {
  /// Whether to also emit the cURL command on a successful response.
  ///
  /// Defaults to `null` (treated as `false`) so only failed requests
  /// produce cURL output by default.
  final bool? printOnSuccess;

  /// Whether to convert [FormData] into `-F` flags.
  ///
  /// When `true`, each field becomes `-F "key=value"` and each file
  /// becomes `-F "key=@filename;type=contentType"`.
  final bool convertFormData;

  CurlLoggerInterceptor({this.printOnSuccess, this.convertFormData = true});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _renderCurlRepresentation(err.requestOptions);
    return handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (printOnSuccess == true) {
      _renderCurlRepresentation(response.requestOptions);
    }
    return handler.next(response);
  }

  void _renderCurlRepresentation(RequestOptions requestOptions) {
    try {
      log(_cURLRepresentation(requestOptions));
    } catch (err) {
      log('unable to create a CURL representation of the requestOptions');
    }
  }

  String _cURLRepresentation(RequestOptions options) {
    final List<String> components = ['curl -i'];
    if (options.method.toUpperCase() != 'GET') {
      components.add('-X ${options.method}');
    }

    options.headers.forEach((k, v) {
      if (k != 'Cookie') {
        components.add('-H "$k: $v"');
      }
    });

    if (options.data != null) {
      if (options.data is FormData && convertFormData) {
        final FormData formData = options.data as FormData;
        final List<String> formComponents = [];

        for (final field in formData.fields) {
          formComponents.add('-F "${field.key}=${field.value}"');
        }
        for (final file in formData.files) {
          final MultipartFile fileData = file.value;
          formComponents.add(
            '-F "${file.key}=@${fileData.filename};type=${fileData.contentType}"',
          );
        }

        components.addAll(formComponents);
      } else {
        final data = json.encode(options.data).replaceAll('"', '\\"');
        components.add('-d "$data"');
      }
    }

    components.add('"${options.uri}"');

    return components.join(' \\\n\t');
  }
}