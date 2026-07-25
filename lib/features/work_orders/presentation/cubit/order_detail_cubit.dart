import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/domain/repositories/inventory_repository.dart';
import '../../../services/domain/entities/service.dart';
import '../../../services/domain/repositories/services_repository.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/work_order_detail.dart';
import '../../domain/entities/work_order_header_input.dart';
import '../../domain/repositories/work_orders_repository.dart';
import 'order_detail_state.dart';

class OrderDetailCubit extends Cubit<OrderDetailState> {
  final WorkOrdersRepository _ordersRepository;
  final InventoryRepository _inventoryRepository;
  final ServicesRepository _servicesRepository;

  final String orderCode;

  OrderDetailCubit(
    this._ordersRepository,
    this._inventoryRepository,
    this._servicesRepository, {
    required this.orderCode,
  }) : super(const OrderDetailInitial());

  Future<void> load() async {
    emit(const OrderDetailLoading());
    try {
      final results = await Future.wait([
        _ordersRepository.getByCode(orderCode),
        _ordersRepository.getStatuses(),
      ]);
      emit(
        OrderDetailLoaded(
          detail: results[0] as WorkOrderDetail,
          statuses: (results[1] as List).cast(),
        ),
      );
    } on ApiException catch (e) {
      emit(OrderDetailFailure(e.code));
    } catch (_) {
      emit(const OrderDetailFailure(ClientErrorCodes.unexpected));
    }
  }

  /// Runs a mutation and replaces the detail. Returns success so sheets
  /// can close themselves (errors inside sheets are read from state).
  Future<bool> _mutate(Future<WorkOrderDetail> Function() mutation) async {
    final current = state;
    if (current is! OrderDetailLoaded || current.saving) return false;

    emit(current.copyWith(saving: true));
    try {
      final detail = await mutation();
      emit(current.copyWith(detail: detail, saving: false));
      return true;
    } on ApiException catch (e) {
      emit(current.copyWith(saving: false, errorCode: e.code));
      return false;
    } catch (_) {
      emit(
        current.copyWith(saving: false, errorCode: ClientErrorCodes.unexpected),
      );
      return false;
    }
  }

  Future<bool> changeStatus(String statusCode, {String? comment}) => _mutate(
    () => _ordersRepository.changeStatus(
      orderCode,
      statusCode: statusCode,
      comment: comment,
    ),
  );

  Future<bool> updateHeader(WorkOrderHeaderInput input) =>
      _mutate(() => _ordersRepository.updateHeader(orderCode, input));

  Future<bool> addProduct({
    required String productCode,
    required double quantity,
  }) => _mutate(
    () => _ordersRepository.addProductLine(
      orderCode,
      productCode: productCode,
      quantity: quantity,
    ),
  );

  Future<bool> removeProduct(int lineId) =>
      _mutate(() => _ordersRepository.removeProductLine(orderCode, lineId));

  Future<bool> addLabor({
    String? serviceCode,
    String? description,
    double? hours,
    double quantity = 1,
    double? unitPrice,
  }) => _mutate(
    () => _ordersRepository.addLaborLine(
      orderCode,
      serviceCode: serviceCode,
      description: description,
      hours: hours,
      quantity: quantity,
      unitPrice: unitPrice,
    ),
  );

  Future<bool> removeLabor(int lineId) =>
      _mutate(() => _ordersRepository.removeLaborLine(orderCode, lineId));

  Future<bool> addPayment({
    required double amount,
    required PaymentMethod method,
    String? reference,
    String? notes,
  }) => _mutate(
    () => _ordersRepository.addPayment(
      orderCode,
      amount: amount,
      method: method,
      reference: reference,
      notes: notes,
    ),
  );

  /// Product picker for the add-product sheet (first page is enough for
  /// a picker — typing narrows the search).
  Future<List<Product>> searchProducts(String query) async =>
      (await _inventoryRepository.getProducts(search: query)).items;

  /// Service catalog for the add-labor sheet.
  Future<List<Service>> getServices() => _servicesRepository.getAll();
}
