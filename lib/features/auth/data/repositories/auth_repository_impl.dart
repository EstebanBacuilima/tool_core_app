import 'package:dio/dio.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../dtos/login_request_dto.dart';

/// Default implementation of [AuthRepository]: remote datasource for HTTP
/// plus secure storage for the session. Converts transport errors into
/// domain [ApiException]s via [ErrorMapper].
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remote;
  final SessionStorage _storage;

  const AuthRepositoryImpl(this._remote, this._storage);

  @override
  Future<void> login({
    required String username,
    required String password,
  }) async {
    try {
      final auth = await _remote.login(
        LoginRequestDto(username: username, password: password),
      );
      await _storage.writeToken(auth.token);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<UserProfile> getProfile() async {
    try {
      final user = await _remote.getProfile();
      return user.toEntity();
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<bool> hasSession() async => await _storage.readToken() != null;

  @override
  Future<void> setActiveCompany(String companyCode) =>
      _storage.writeActiveCompanyCode(companyCode);

  @override
  Future<String?> getActiveCompany() => _storage.readActiveCompanyCode();

  @override
  Future<void> setActiveWorkshop(String workshopCode) =>
      _storage.writeActiveWorkshopCode(workshopCode);

  @override
  Future<String?> getActiveWorkshop() => _storage.readActiveWorkshopCode();

  @override
  Future<void> logout() => _storage.clear();
}
