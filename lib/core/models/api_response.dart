/// Generic deserializer for the API response envelope.
class ApiResponse<T> {
  final int status;
  final String message;
  final T? data;

  const ApiResponse({required this.status, required this.message, this.data});

  /// [fromJsonT] converts the raw `data` node into the typed payload.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      status: json['status'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] == null ? null : fromJsonT(json['data']),
    );
  }
}
