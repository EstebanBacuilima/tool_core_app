import 'package:dio/dio.dart';

import '../../../../core/models/api_paged_response.dart';
import '../../../../core/models/api_response.dart';
import '../../../../shared/data/dtos/customer_dto.dart';
import '../../../../shared/data/dtos/document_type_dto.dart';
import '../../../../shared/data/dtos/vehicle_dto.dart';

class CustomersRemoteDatasource {
  final Dio _dio;

  const CustomersRemoteDatasource(this._dio);

  Future<ApiPagedResponse<CustomerDto>> search(
    String query, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/customers',
      queryParameters: {
        if (query.isNotEmpty) 'search': query,
        'page': page,
        'page-size': pageSize,
      },
    );

    return ApiPagedResponse.fromJson(response.data!, CustomerDto.fromJson);
  }

  Future<ApiPagedResponse<VehicleDto>> searchVehicles(
    String query, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/vehicles',
      queryParameters: {
        if (query.isNotEmpty) 'search': query,
        'page': page,
        'page-size': pageSize,
      },
    );

    return ApiPagedResponse.fromJson(response.data!, VehicleDto.fromJson);
  }

  Future<List<VehicleDto>> getVehicles(String customerCode) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/customers/$customerCode/vehicles',
    );

    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => (json as List<dynamic>)
          .map((e) => VehicleDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return envelope.data ?? const [];
  }

  Future<List<DocumentTypeDto>> getDocumentTypes() async {
    final response = await _dio.get<Map<String, dynamic>>('/document-types');

    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => (json as List<dynamic>)
          .map((e) => DocumentTypeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return envelope.data ?? const [];
  }

  Future<CustomerDto> createCustomer(Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/customers',
      data: body,
    );

    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => CustomerDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<VehicleDto> createVehicle(
    String customerCode,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/customers/$customerCode/vehicles',
      data: body,
    );

    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => VehicleDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }
}
