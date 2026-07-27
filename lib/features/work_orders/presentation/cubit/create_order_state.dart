import 'package:equatable/equatable.dart';

import '../../../../shared/domain/entities/customer.dart';
import '../../../../shared/domain/entities/document_type.dart';
import '../../../../shared/domain/entities/vehicle.dart';

enum CreateOrderStatus { idle, saving, success }

class CreateOrderState extends Equatable {
  final List<Vehicle> vehicleResults;
  final bool searchingVehicles;
  final bool vehiclesHasMore;
  final bool loadingMoreVehicles;

  /// Catalog for the quick-create customer sheet.
  final List<DocumentType> documentTypes;

  final Customer? customer;
  final List<Vehicle> vehicles;
  final bool loadingVehicles;
  final Vehicle? vehicle;

  final CreateOrderStatus status;

  /// Code of the created order when [status] == success.
  final String? createdOrderCode;

  /// Transient error (kebab-case); cleared on the next action.
  final String? errorCode;

  const CreateOrderState({
    this.vehicleResults = const [],
    this.searchingVehicles = false,
    this.vehiclesHasMore = false,
    this.loadingMoreVehicles = false,
    this.documentTypes = const [],
    this.customer,
    this.vehicles = const [],
    this.loadingVehicles = false,
    this.vehicle,
    this.status = CreateOrderStatus.idle,
    this.createdOrderCode,
    this.errorCode,
  });

  bool get canSubmit => vehicle != null && status != CreateOrderStatus.saving;

  CreateOrderState copyWith({
    List<Vehicle>? vehicleResults,
    bool? searchingVehicles,
    bool? vehiclesHasMore,
    bool? loadingMoreVehicles,
    List<DocumentType>? documentTypes,
    Customer? customer,
    bool clearCustomer = false,
    List<Vehicle>? vehicles,
    bool? loadingVehicles,
    Vehicle? vehicle,
    bool clearVehicle = false,
    CreateOrderStatus? status,
    String? createdOrderCode,
    String? errorCode,
  }) {
    return CreateOrderState(
      vehicleResults: vehicleResults ?? this.vehicleResults,
      searchingVehicles: searchingVehicles ?? this.searchingVehicles,
      vehiclesHasMore: vehiclesHasMore ?? this.vehiclesHasMore,
      loadingMoreVehicles: loadingMoreVehicles ?? this.loadingMoreVehicles,
      documentTypes: documentTypes ?? this.documentTypes,
      customer: clearCustomer ? null : (customer ?? this.customer),
      vehicles: vehicles ?? this.vehicles,
      loadingVehicles: loadingVehicles ?? this.loadingVehicles,
      vehicle: clearVehicle ? null : (vehicle ?? this.vehicle),
      status: status ?? this.status,
      createdOrderCode: createdOrderCode ?? this.createdOrderCode,
      // errorCode is transient: only kept when explicitly passed.
      errorCode: errorCode,
    );
  }

  @override
  List<Object?> get props => [
    vehicleResults,
    searchingVehicles,
    vehiclesHasMore,
    loadingMoreVehicles,
    documentTypes,
    customer,
    vehicles,
    loadingVehicles,
    vehicle,
    status,
    createdOrderCode,
    errorCode,
  ];
}
