import 'package:dio/dio.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/models/paged_result.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/work_order_detail.dart';
import '../../domain/entities/work_order_header_input.dart';
import '../../domain/entities/work_order_input.dart';
import '../../domain/entities/work_order_status.dart';
import '../../domain/entities/work_order_summary.dart';
import '../../domain/repositories/work_orders_repository.dart';
import '../datasources/work_orders_remote_datasource.dart';
import '../dtos/work_order_detail_dto.dart';

class WorkOrdersRepositoryImpl implements WorkOrdersRepository {
  final WorkOrdersRemoteDatasource _remote;
  final SessionStorage _storage;

  const WorkOrdersRepositoryImpl(this._remote, this._storage);

  Future<String> _workshopCode() async {
    final code = await _storage.readActiveWorkshopCode();
    if (code == null) {
      throw const ApiException(ClientErrorCodes.workshopNotSelected);
    }
    return code;
  }

  @override
  Future<List<WorkOrderStatus>> getStatuses() async {
    try {
      final rows = await _remote.getStatuses();
      return rows
          .map((json) => WorkOrderStatus(
                code: json['code'] as String? ?? '',
                name: json['name'] as String? ?? '',
              ))
          .toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<PagedResult<WorkOrderSummary>> getAll({
    String? statusCode,
    String? search,
    int page = 1,
  }) async {
    try {
      final response = await _remote.getAll(
        await _workshopCode(),
        statusCode: statusCode,
        search: search,
        page: page,
      );
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
  Future<String> create(WorkOrderInput input) async {
    try {
      return await _remote.create(await _workshopCode(), input);
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  /// Wraps a datasource call that returns the full updated order.
  Future<WorkOrderDetail> _detail(
    Future<WorkOrderDetailDto> Function() call,
  ) async {
    try {
      final dto = await call();
      return dto.toEntity();
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<WorkOrderDetail> getByCode(String code) =>
      _detail(() => _remote.getByCode(code));

  @override
  Future<WorkOrderDetail> updateHeader(
    String code,
    WorkOrderHeaderInput input,
  ) =>
      _detail(() => _remote.updateHeader(code, {
            'intakeMileage': input.intakeMileage,
            'fuelLevel': input.fuelLevel,
            'customerComplaint': input.customerComplaint,
            'diagnosis': input.diagnosis,
            'observations': input.observations,
            'discount': input.discount,
          }));

  @override
  Future<WorkOrderDetail> changeStatus(
    String code, {
    required String statusCode,
    String? comment,
  }) =>
      _detail(() => _remote.changeStatus(code, {
            'statusCode': statusCode,
            'comment': comment,
          }));

  @override
  Future<WorkOrderDetail> addProductLine(
    String code, {
    required String productCode,
    required double quantity,
  }) =>
      _detail(() => _remote.addProductLine(code, {
            'productCode': productCode,
            'quantity': quantity,
          }));

  @override
  Future<WorkOrderDetail> removeProductLine(String code, int lineId) =>
      _detail(() => _remote.removeProductLine(code, lineId));

  @override
  Future<WorkOrderDetail> addLaborLine(
    String code, {
    String? serviceCode,
    String? description,
    double? hours,
    double quantity = 1,
    double? unitPrice,
  }) =>
      _detail(() => _remote.addLaborLine(code, {
            'serviceCode': serviceCode,
            'description': description,
            'hours': hours,
            'quantity': quantity,
            'unitPrice': unitPrice,
          }));

  @override
  Future<WorkOrderDetail> removeLaborLine(String code, int lineId) =>
      _detail(() => _remote.removeLaborLine(code, lineId));

  @override
  Future<WorkOrderDetail> addPayment(
    String code, {
    required double amount,
    required PaymentMethod method,
    String? reference,
    String? notes,
  }) =>
      _detail(() => _remote.addPayment(code, {
            'amount': amount,
            'method': method.value,
            'reference': reference,
            'notes': notes,
          }));
}
