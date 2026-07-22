class ApiPagedResponse<T> {
  final int status;
  final String message;
  final List<T> data;
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  const ApiPagedResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  bool get hasNext => currentPage < totalPages;
  bool get hasPrevious => currentPage > 1;

  /// [fromJsonT] converts each element of the `data` list.
  factory ApiPagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    return ApiPagedResponse<T>(
      status: json['status'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>? ?? const [])
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      currentPage: json['currentPage'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 0,
      totalCount: json['totalCount'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }
}
