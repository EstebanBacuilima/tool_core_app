import 'package:equatable/equatable.dart';

import '../../../../shared/domain/entities/customer.dart';
import '../../../../shared/domain/entities/document_type.dart';
import '../../../../shared/domain/entities/vehicle.dart';

enum CreateOrderStatus { idle, saving, success }

class CreateOrderState extends Equatable {
  /// Customer search results (step 1), server-paginated.
  final List<Customer> customers;
  final bool searching;
  final bool customersHasMore;
  final bool loadingMoreCustomers;

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
    this.customers = const [],
    this.searching = false,
    this.customersHasMore = false,
    this.loadingMoreCustomers = false,
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
    List<Customer>? customers,
    bool? searching,
    bool? customersHasMore,
    bool? loadingMoreCustomers,
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
      customers: customers ?? this.customers,
      searching: searching ?? this.searching,
      customersHasMore: customersHasMore ?? this.customersHasMore,
      loadingMoreCustomers: loadingMoreCustomers ?? this.loadingMoreCustomers,
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
    customers,
    searching,
    customersHasMore,
    loadingMoreCustomers,
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
