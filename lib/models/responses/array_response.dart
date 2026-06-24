import 'package:equatable/equatable.dart';

/// Generic wrapper for API responses that return a list of items.
///
/// [T] is the type of each item in [data].
///
/// Example JSON:
/// ```json
/// {
///   "status": 200,
///   "message": "Success",
///   "data": [...],
///   "pageNumber": 1,
///   "pageSize": 10,
///   "totalRecords": 100,
///   "totalPages": 10
/// }
/// ```
class ArrayResponse<T> extends Equatable {
  /// Human-readable message returned by the server.
  final String? message;

  /// HTTP-level or business status code from the server.
  final int? status;

  /// The list of items returned by the server.
  final List<T>? data;

  /// Current page number (1-based).
  final int? pageNumber;

  /// Number of items per page.
  final int? pageSize;

  /// Total number of records across all pages.
  final int? totalRecords;

  /// Total number of pages.
  final int? totalPages;

  const ArrayResponse({
    this.message,
    this.status,
    this.data,
    this.pageNumber,
    this.pageSize,
    this.totalRecords,
    this.totalPages,
  });

  /// Returns a copy of this instance with the given fields replaced.
  ArrayResponse<T> copyWith({
    final String? message,
    final int? status,
    final List<T>? data,
    final int? pageNumber,
    final int? pageSize,
    final int? totalRecords,
    final int? totalPages,
  }) {
    return ArrayResponse<T>(
      message: message ?? this.message,
      status: status ?? this.status,
      data: data ?? this.data,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      totalRecords: totalRecords ?? this.totalRecords,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  /// Deserializes from [json].
  ///
  /// [fromJsonT] converts each raw JSON element into [T].
  factory ArrayResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final base = ArrayResponse<T>(
      message: json['message'] as String?,
      status: json['status'] as int?,
      pageNumber: json['pageNumber'] as int?,
      pageSize: json['pageSize'] as int?,
      totalRecords: json['totalRecords'] as int?,
      totalPages: json['totalPages'] as int?,
    );
    if (json['data'] is List) {
      return base.copyWith(
        data: (json['data'] as List).map(fromJsonT).toList(),
      );
    }
    return base;
  }

  /// Serializes to a JSON map.
  ///
  /// [toJsonT] converts each item of type [T] to a JSON-compatible value.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) => {
    'message': message,
    'status': status,
    'data': data?.map(toJsonT).toList(),
    'pageNumber': pageNumber,
    'pageSize': pageSize,
    'totalRecords': totalRecords,
    'totalPages': totalPages,
  };

  @override
  List<Object?> get props => [
    message,
    status,
    data,
    pageSize,
    pageNumber,
    totalPages,
    totalRecords,
  ];
}
