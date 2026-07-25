import 'package:dio/dio.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/service.dart';
import '../../domain/repositories/services_repository.dart';
import '../datasources/services_remote_datasource.dart';
import '../dtos/service_save_dto.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final ServicesRemoteDatasource _remote;
  final SessionStorage _storage;

  const ServicesRepositoryImpl(this._remote, this._storage);

  /// The active workshop is resolved at login; if it is missing the user
  /// has no workshop membership yet.
  Future<String> _workshopCode() async {
    final code = await _storage.readActiveWorkshopCode();
    if (code == null) {
      throw const ApiException(ClientErrorCodes.workshopNotSelected);
    }
    return code;
  }

  @override
  Future<List<Service>> getAll() async {
    try {
      final dtos = await _remote.getAllByWorkshop(await _workshopCode());
      return dtos.map((d) => d.toEntity()).toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<Service> create({
    required String name,
    required double price,
    String? description,
  }) async {
    try {
      final dto = await _remote.create(
        await _workshopCode(),
        ServiceSaveDto(name: name, price: price, description: description),
      );
      return dto.toEntity();
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<Service> update({
    required String code,
    required String name,
    required double price,
    String? description,
    bool? isActive,
  }) async {
    try {
      final dto = await _remote.update(
        code,
        ServiceSaveDto(
          name: name,
          price: price,
          description: description,
          isActive: isActive,
        ),
      );
      return dto.toEntity();
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }
}
