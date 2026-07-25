import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../shared/domain/entities/customer.dart';
import '../../../../shared/domain/entities/vehicle.dart';
import '../../domain/entities/work_order_input.dart';
import '../../domain/repositories/customers_repository.dart';
import '../../domain/repositories/work_orders_repository.dart';
import 'create_order_state.dart';

class CreateOrderCubit extends Cubit<CreateOrderState> {
  final WorkOrdersRepository _ordersRepository;
  final CustomersRepository _customersRepository;

  CreateOrderCubit(this._ordersRepository, this._customersRepository)
    : super(const CreateOrderState());

  Future<void> loadDocumentTypes() async {
    if (state.documentTypes.isNotEmpty) return;
    try {
      final types = await _customersRepository.getDocumentTypes();
      emit(state.copyWith(documentTypes: types));
    } on ApiException catch (e) {
      emit(state.copyWith(errorCode: e.code));
    }
  }

  String _customersQuery = '';
  int _customersPage = 1;

  Future<void> searchCustomers(String query) async {
    _customersQuery = query;
    _customersPage = 1;
    emit(state.copyWith(searching: true));
    try {
      final result = await _customersRepository.search(query);
      emit(
        state.copyWith(
          customers: result.items,
          customersHasMore: result.hasNext,
          searching: false,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(searching: false, errorCode: e.code));
    }
  }

  Future<void> loadMoreCustomers() async {
    if (!state.customersHasMore || state.loadingMoreCustomers) return;
    emit(state.copyWith(loadingMoreCustomers: true));
    try {
      final result = await _customersRepository.search(
        _customersQuery,
        page: _customersPage + 1,
      );
      _customersPage++;
      emit(
        state.copyWith(
          customers: [...state.customers, ...result.items],
          customersHasMore: result.hasNext,
          loadingMoreCustomers: false,
        ),
      );
    } on ApiException {
      emit(state.copyWith(loadingMoreCustomers: false));
    }
  }

  Future<void> selectCustomer(Customer customer) async {
    emit(
      state.copyWith(
        customer: customer,
        clearVehicle: true,
        vehicles: const [],
        loadingVehicles: true,
      ),
    );
    try {
      final vehicles = await _customersRepository.getVehicles(customer.code);
      emit(state.copyWith(vehicles: vehicles, loadingVehicles: false));
    } on ApiException catch (e) {
      emit(state.copyWith(loadingVehicles: false, errorCode: e.code));
    }
  }

  void selectVehicle(Vehicle vehicle) {
    emit(state.copyWith(vehicle: vehicle));
  }

  void clearCustomer() {
    emit(
      state.copyWith(
        clearCustomer: true,
        clearVehicle: true,
        vehicles: const [],
      ),
    );
  }

  Future<bool> createCustomer({
    required String firstName,
    String? lastName,
    String? documentTypeCode,
    String? identificationNumber,
    String? phone,
  }) async {
    try {
      final customer = await _customersRepository.createCustomer(
        firstName: firstName,
        lastName: lastName,
        documentTypeCode: documentTypeCode,
        identificationNumber: identificationNumber,
        phone: phone,
      );
      await selectCustomer(customer);
      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(errorCode: e.code));
      return false;
    }
  }

  Future<bool> createVehicle({
    required String plate,
    required String brand,
    required String model,
    int? year,
    String? color,
    int? mileage,
  }) async {
    final customer = state.customer;
    if (customer == null) return false;

    try {
      final vehicle = await _customersRepository.createVehicle(
        customerCode: customer.code,
        plate: plate,
        brand: brand,
        model: model,
        year: year,
        color: color,
        mileage: mileage,
      );
      emit(
        state.copyWith(
          vehicles: [...state.vehicles, vehicle],
          vehicle: vehicle,
        ),
      );
      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(errorCode: e.code));
      return false;
    }
  }

  Future<void> submit({
    int? intakeMileage,
    String? fuelLevel,
    String? customerComplaint,
  }) async {
    final vehicle = state.vehicle;
    if (vehicle == null || state.status == CreateOrderStatus.saving) return;

    emit(state.copyWith(status: CreateOrderStatus.saving));
    try {
      final code = await _ordersRepository.create(
        WorkOrderInput(
          vehicleCode: vehicle.code,
          intakeMileage: intakeMileage,
          fuelLevel: fuelLevel,
          customerComplaint: customerComplaint,
        ),
      );
      emit(
        state.copyWith(
          status: CreateOrderStatus.success,
          createdOrderCode: code,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(status: CreateOrderStatus.idle, errorCode: e.code));
    } catch (_) {
      emit(
        state.copyWith(
          status: CreateOrderStatus.idle,
          errorCode: ClientErrorCodes.unexpected,
        ),
      );
    }
  }
}
