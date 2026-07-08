import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/responses/object_response.dart';

part 'api_client.g.dart';

/// Retrofit-generated REST API client for all backend endpoints.
///
/// Implementation is generated into `api_client.g.dart` by `build_runner`
/// from the `@RestApi()` / `@POST` / `@GET` annotations below. Obtain an
/// instance via [ApiUtil.getApiClient] rather than constructing directly.
@RestApi()
abstract class ApiClient {
  /// Creates an [ApiClient] backed by [dio], optionally overriding [baseUrl]
  /// or supplying a custom [errorLogger] for Retrofit parse errors.
  factory ApiClient(Dio dio, {String baseUrl, ParseErrorLogger? errorLogger}) =
      _ApiClient;

  // Rest Api define: GET, POST, PATCH, PUT, DELETE
  /// Authentication Endpoints
  @POST('auths/login')
  Future<ObjectResponse<bool>> onLogin(@Body() Map<String, dynamic> body);
}
