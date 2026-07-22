import 'package:dio/dio.dart';

import '../../../../core/models/api_response.dart';
import '../dtos/auth_response_dto.dart';
import '../dtos/login_request_dto.dart';
import '../dtos/user_dto.dart';

class AuthRemoteDatasource {
  final Dio _dio;

  const AuthRemoteDatasource(this._dio);

  Future<AuthResponseDto> login(LoginRequestDto request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: request.toJson(),
    );

    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => AuthResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<UserDto> getProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('/users/me');

    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => UserDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }
}
