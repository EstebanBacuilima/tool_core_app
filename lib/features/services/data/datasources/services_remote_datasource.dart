import 'package:dio/dio.dart';

import '../../../../core/models/api_response.dart';
import '../dtos/service_dto.dart';
import '../dtos/service_save_dto.dart';

class ServicesRemoteDatasource {
  final Dio _dio;

  const ServicesRemoteDatasource(this._dio);

  Future<List<ServiceDto>> getAllByWorkshop(String workshopCode) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/workshops/$workshopCode/services',
      queryParameters: {'include-inactive': true},
    );

    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => (json as List<dynamic>)
          .map((e) => ServiceDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return envelope.data ?? const [];
  }

  Future<ServiceDto> create(String workshopCode, ServiceSaveDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/workshops/$workshopCode/services',
      data: dto.toJson(),
    );

    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => ServiceDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<ServiceDto> update(String serviceCode, ServiceSaveDto dto) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/services/$serviceCode',
      data: dto.toJson(),
    );

    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => ServiceDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }
}
