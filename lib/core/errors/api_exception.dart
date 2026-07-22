class ApiException implements Exception {
  final String code;
  final int? statusCode;

  const ApiException(this.code, {this.statusCode});

  @override
  String toString() => 'ApiException($code, status: $statusCode)';
}

/// Custom error codes for the app.
class ClientErrorCodes {
  ClientErrorCodes._();

  static const String network = 'network-error';
  static const String tooManyRequests = 'too-many-requests';
  static const String sessionExpired = 'session-expired';
  static const String unexpected = 'unexpected-error';
}
