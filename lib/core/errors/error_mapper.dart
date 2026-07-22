import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Single place where transport errors (Dio) become domain [ApiException]s.
/// Repository implementations call this in their catch blocks so that
/// cubits only ever deal with [ApiException].
class ErrorMapper {
  ErrorMapper._();

  static ApiException fromDio(DioException error) {
    // No response at all -> connectivity problem.
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const ApiException(ClientErrorCodes.network);
      default:
        break;
    }

    final status = error.response?.statusCode;

    // Auth endpoints are rate-limited by IP (5/min) -> 429 without envelope.
    if (status == 429) {
      return ApiException(ClientErrorCodes.tooManyRequests, statusCode: status);
    }

    // Backend errors come wrapped in the envelope: `message` holds the
    // kebab-case code (e.g. `invalid-credentials`).
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return ApiException(message, statusCode: status);
      }
    }

    if (status == 401) {
      return ApiException(ClientErrorCodes.sessionExpired, statusCode: status);
    }

    return ApiException(ClientErrorCodes.unexpected, statusCode: status);
  }
}
