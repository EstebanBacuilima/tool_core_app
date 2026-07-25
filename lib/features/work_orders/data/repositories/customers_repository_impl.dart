import 'package:dio/dio.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/models/paged_result.dart';
import '../../../../shared/domain/entities/customer.dart';
import '../../../../shared/domain/entities/document_type.dart';
import '../../../../shared/domain/entities/vehicle.dart';
import '../../domain/repositories/customers_repository.dart';
import '../datasources/customers_remote_datasource.dart';

class CustomersRepositoryImpl implements CustomersRepository {
  final CustomersRemoteDatasource _remote;

  const CustomersRepositoryImpl(this._remote);

  @override
  Future<PagedResult<Customer>> search(String query, {int page = 1}) async {
    try {
      final response = await _remote.search(query, page: page);
      return PagedResult(
        items: response.data.map((d) => d.toEntity()).toList(),
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        totalCount: response.totalCount,
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<List<Vehicle>> getVehicles(String customerCode) async {
    try {
      final dtos = await _remote.getVehicles(customerCode);
      return dtos.map((d) => d.toEntity()).toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<List<DocumentType>> getDocumentTypes() async {
    try {
      final dtos = await _remote.getDocumentTypes();
      return dtos.map((d) => d.toEntity()).toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<Customer> createCustomer({
    required String firstName,
    String? lastName,
    String? documentTypeCode,
    String? identificationNumber,
    String? phone,
  }) async {
    try {
      final dto = await _remote.createCustomer({
        'firstName': firstName,
        'lastName': lastName,
        'documentTypeCode': documentTypeCode,
        'identificationNumber': identificationNumber,
        'phone': phone,
      });
      return dto.toEntity();
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<Vehicle> createVehicle({
    required String customerCode,
    required String plate,
    required String brand,
    required String model,
    int? year,
    String? color,
    int? mileage,
  }) async {
    try {
      final dto = await _remote.createVehicle(customerCode, {
        'plate': plate,
        'brand': brand,
        'model': model,
        'year': year,
        'color': color,
        'mileage': mileage,
      });
      return dto.toEntity();
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }
}
