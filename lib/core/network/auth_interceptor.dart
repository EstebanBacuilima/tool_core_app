import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/session_storage.dart';

/// Attaches auth headers to every request and handles token refresh.
///
/// - Adds `Authorization: Bearer <token>` and `X-Company-Code` when present.
/// - On a 401 (outside `/auth/*`): calls `POST /auth/refresh-token` ONCE,
///   retries the original request with the new token; if refresh fails,
///   clears the session and notifies [onSessionExpired] so the AuthCubit
///   sends the user back to login (the go_router guard listens to it).
///
/// Extends [QueuedInterceptor] so concurrent 401s are handled one at a
/// time and only one refresh call is fired.
class AuthInterceptor extends QueuedInterceptor {
  final SessionStorage _storage;

  /// Bare Dio (no interceptors) used for the refresh call and the retry,
  /// to avoid re-entering this interceptor.
  final Dio _plainDio;

  final void Function() onSessionExpired;

  AuthInterceptor({
    required this._storage,
    required this._plainDio,
    required this.onSessionExpired,
  });

  static const _retriedFlag = 'auth_retried';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.readToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    final companyCode = await _storage.readActiveCompanyCode();
    if (companyCode != null) {
      options.headers[ApiConstants.companyCodeHeader] = companyCode;
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isAuthEndpoint = err.requestOptions.path.contains('/auth/');
    final alreadyRetried = err.requestOptions.extra[_retriedFlag] == true;

    if (!isUnauthorized || isAuthEndpoint || alreadyRetried) {
      return handler.next(err);
    }

    final refreshed = await _tryRefreshToken();
    if (!refreshed) {
      // Refresh failed: session is over. Clear storage and let the app
      // navigate back to login.
      await _storage.clear();
      onSessionExpired();
      return handler.next(err);
    }

    try {
      final response = await _retry(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }

  Future<bool> _tryRefreshToken() async {
    final token = await _storage.readToken();
    if (token == null) return false;

    try {
      final response = await _plainDio.post<Map<String, dynamic>>(
        '/auth/refresh-token',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data?['data'] as Map<String, dynamic>?;
      final newToken = data?['token'] as String?;
      if (newToken == null) return false;

      await _storage.writeToken(newToken);
      return true;
    } on DioException {
      return false;
    }
  }

  /// Re-fires the original request with the refreshed token.
  Future<Response<dynamic>> _retry(RequestOptions options) async {
    final token = await _storage.readToken();
    options.headers['Authorization'] = 'Bearer $token';
    options.extra[_retriedFlag] = true;
    return _plainDio.fetch(options);
  }
}
