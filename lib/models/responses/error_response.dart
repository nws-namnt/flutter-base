import 'package:equatable/equatable.dart';

/// Represents a standard error response returned by the API.
///
/// Example JSON:
/// ```json
/// {
///   "statusCode": 400,
///   "message": "Bad Request",
///   "error": "Validation failed"
/// }
/// ```
class ErrorResponse extends Equatable {
  /// HTTP status code returned by the server.
  final int? status;

  /// Human-readable message describing the error.
  final String? message;

  /// Short error identifier or detail provided by the server.
  final String? error;

  const ErrorResponse({this.status, this.message, this.error});

  /// Returns a copy of this instance with the given fields replaced.
  ErrorResponse copyWith({
    final int? status,
    final String? message,
    final String? error,
  }) => ErrorResponse(
    message: message ?? this.message,
    status: status ?? this.status,
    error: error ?? this.error,
  );

  /// Deserializes from [json].
  factory ErrorResponse.fromJson(Map<String, dynamic> json) => ErrorResponse(
    message: json['message'] as String?,
    status: json['status'] as int?,
    error: json['error'] as String?,
  );

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'error': error,
  };

  @override
  List<Object?> get props => [message, status, error];
}
