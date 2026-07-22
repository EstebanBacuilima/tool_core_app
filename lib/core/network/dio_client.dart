import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../storage/session_storage.dart';
import 'auth_interceptor.dart';

class DioClient {
  DioClient._();

  static Dio create({
    required SessionStorage storage,
    required void Function() onSessionExpired,
  }) {
    final options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
    );

    final dio = Dio(options);

    dio.interceptors.add(
      AuthInterceptor(
        storage: storage,
        // Bare Dio used internally for the refresh call and request retries.
        plainDio: Dio(options),
        onSessionExpired: onSessionExpired,
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(responseBody: true));
    }

    return dio;
  }
}
