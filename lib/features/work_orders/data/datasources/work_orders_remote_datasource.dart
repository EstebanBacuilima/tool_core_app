import 'package:dio/dio.dart';

import '../../../../core/models/api_paged_response.dart';
import '../../../../core/models/api_response.dart';
import '../../domain/entities/work_order_input.dart';
import '../dtos/work_order_detail_dto.dart';
import '../dtos/work_order_summary_dto.dart';

class WorkOrdersRemoteDatasource {
  final Dio _dio;

  const WorkOrdersRemoteDatasource(this._dio);

  Future<List<Map<String, dynamic>>> getStatuses() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/work-order-statuses',
    );

    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => (json as List<dynamic>).cast<Map<String, dynamic>>(),
    );
    return envelope.data ?? const [];
  }

  Future<ApiPagedResponse<WorkOrderSummaryDto>> getAll(
    String workshopCode, {
    String? statusCode,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/workshops/$workshopCode/work-orders',
      queryParameters: {
        'status': ?statusCode,
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
        'page-size': pageSize,
      },
    );

    return ApiPagedResponse.fromJson(
      response.data!,
      WorkOrderSummaryDto.fromJson,
    );
  }

  /// Returns the created order's code (detail screen fetches the rest).
  Future<String> create(String workshopCode, WorkOrderInput input) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/workshops/$workshopCode/work-orders',
      data: {
        'vehicleCode': input.vehicleCode,
        'intakeMileage': input.intakeMileage,
        'fuelLevel': input.fuelLevel,
        'customerComplaint': input.customerComplaint,
      },
    );

    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => (json as Map<String, dynamic>)['code'] as String? ?? '',
    );
    return envelope.data!;
  }

  Future<WorkOrderDetailDto> getByCode(String orderCode) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/work-orders/$orderCode',
    );
    return _detail(response.data!);
  }

  Future<WorkOrderDetailDto> updateHeader(
    String orderCode,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/work-orders/$orderCode',
      data: body,
    );
    return _detail(response.data!);
  }

  Future<WorkOrderDetailDto> changeStatus(
    String orderCode,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/work-orders/$orderCode/status',
      data: body,
    );
    return _detail(response.data!);
  }

  Future<WorkOrderDetailDto> addProductLine(
    String orderCode,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/work-orders/$orderCode/products',
      data: body,
    );
    return _detail(response.data!);
  }

  Future<WorkOrderDetailDto> removeProductLine(
    String orderCode,
    int lineId,
  ) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      '/work-orders/$orderCode/products/$lineId',
    );
    return _detail(response.data!);
  }

  Future<WorkOrderDetailDto> addLaborLine(
    String orderCode,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/work-orders/$orderCode/labors',
      data: body,
    );
    return _detail(response.data!);
  }

  Future<WorkOrderDetailDto> removeLaborLine(
    String orderCode,
    int lineId,
  ) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      '/work-orders/$orderCode/labors/$lineId',
    );
    return _detail(response.data!);
  }

  Future<WorkOrderDetailDto> addPayment(
    String orderCode,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/work-orders/$orderCode/payments',
      data: body,
    );
    return _detail(response.data!);
  }

  /// Deserializes any endpoint that returns the full updated order.
  WorkOrderDetailDto _detail(Map<String, dynamic> body) {
    final envelope = ApiResponse.fromJson(
      body,
      (json) => WorkOrderDetailDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }
}
