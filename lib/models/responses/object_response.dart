import 'package:equatable/equatable.dart';

/// Generic wrapper for API responses that return a single object.
///
/// [T] is the type of the returned [data] object.
///
/// Example JSON:
/// ```json
/// {
///   "status": 200,
///   "message": "Success",
///   "data": { ... }
/// }
/// ```
class ObjectResponse<T> extends Equatable {
  /// Human-readable message returned by the server.
  final String? message;

  /// HTTP-level or business status code from the server.
  final int? status;

  /// The single object returned by the server.
  final T? data;

  /// Creates an [ObjectResponse] with the given fields.
  const ObjectResponse({this.message, this.status, this.data});

  /// Returns a copy of this instance with the given fields replaced.
  ObjectResponse<T> copyWith({
    final String? message,
    final int? status,
    final T? data,
  }) => ObjectResponse<T>(
    message: message ?? this.message,
    status: status ?? this.status,
    data: data ?? this.data,
  );

  /// Deserializes from [json].
  ///
  /// [fromJsonT] converts the raw `data` value into [T].
  factory ObjectResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final base = ObjectResponse<T>(
      message: json['message'] as String?,
      status: json['status'] as int?,
    );
    if (json['data'] != null) {
      return base.copyWith(data: fromJsonT(json['data']));
    }
    return base;
  }

  /// Serializes to a JSON map.
  ///
  /// [toJsonT] converts the [data] object of type [T] to a JSON-compatible value.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) => {
    'message': message,
    'status': status,
    'data': data != null ? toJsonT(data as T) : null,
  };

  /// Properties compared by [Equatable] for value equality.
  @override
  List<Object?> get props => [message, status, data];
}
