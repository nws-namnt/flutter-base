import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/responses/object_response.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl, ParseErrorLogger? errorLogger}) =
      _ApiClient;

  // Rest Api define: GET, POST, PATCH, PUT, DELETE
  /// Authentication Endpoints
  @POST('auths/login')
  Future<ObjectResponse<bool>> onLogin(@Body() Map<String, dynamic> body);
}
