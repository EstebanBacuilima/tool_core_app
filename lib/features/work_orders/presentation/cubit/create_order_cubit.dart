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

  String _vehiclesQuery = '';
  int _vehiclesPage = 1;

  Future<void> searchVehicles(String query) async {
    _vehiclesQuery = query;
    _vehiclesPage = 1;
    emit(state.copyWith(searchingVehicles: true));
    try {
      final result = await _customersRepository.searchVehicles(query);
      emit(
        state.copyWith(
          vehicleResults: result.items,
          vehiclesHasMore: result.hasNext,
          searchingVehicles: false,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(searchingVehicles: false, errorCode: e.code));
    }
  }

  Future<void> loadMoreVehicles() async {
    if (!state.vehiclesHasMore || state.loadingMoreVehicles) return;
    emit(state.copyWith(loadingMoreVehicles: true));
    try {
        _vehiclesQuery,
        page: _vehiclesPage + 1,
      );
      _vehiclesPage++;
      emit(
        state.copyWith(
          vehicleResults: [...state.vehicleResults, ...result.items],
          vehiclesHasMore: result.hasNext,
          loadingMoreVehicles: false,
        ),
      );
    } on ApiException {
      emit(state.copyWith(loadingMoreVehicles: false));
    }
  }

  void selectVehicleResult(Vehicle vehicle) {
    emit(
      state.copyWith(
        vehicle: vehicle,
        clearCustomer: true,
        vehicles: const [],
      ),
    );
  }

  void clearVehicleSelection() {
    emit(state.copyWith(clearVehicle: true));
  }

  /// Dedup check for the quick-create sheet: existing customer with exactly
  /// this identification, if any. Best-effort — on error returns null and
  /// lets the backend validation catch the duplicate on create.
  Future<Customer?> findCustomerByIdentification(String identification) async {
    try {
      final result = await _customersRepository.search(identification);
      for (final customer in result.items) {
        if (customer.identificationNumber == identification) return customer;
      }
    } on ApiException {
      // Ignored: the backend re-validates on POST /customers.
    }
    return null;
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
