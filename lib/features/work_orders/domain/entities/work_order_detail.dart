import 'package:equatable/equatable.dart';

import '../../../../shared/domain/entities/customer.dart';
import '../../../../shared/domain/entities/vehicle.dart';
import 'work_order_status_codes.dart';

class WorkOrderDetail extends Equatable {
  final String code;
  final String orderNumber;
  final String statusCode;
  final String statusName;
  final String paymentStatus;
  final Customer customer;
  final Vehicle vehicle;
  final int? intakeMileage;
  final String? fuelLevel;
  final String? customerComplaint;
  final String? diagnosis;
  final String? observations;
  final List<WorkOrderProductLine> products;
  final List<WorkOrderLaborLine> labors;
  final List<WorkOrderHistoryEntry> statusHistory;
  final List<WorkOrderPayment> payments;
  final double subtotalProducts;
  final double subtotalLabors;
  final double discount;
  final double taxRatePercent;
  final double taxAmount;
  final double total;
  final double paidAmount;
  final double balance;
  final DateTime? createdAt;

  const WorkOrderDetail({
    required this.code,
    required this.orderNumber,
    required this.statusCode,
    required this.statusName,
    required this.paymentStatus,
    required this.customer,
    required this.vehicle,
    this.intakeMileage,
    this.fuelLevel,
    this.customerComplaint,
    this.diagnosis,
    this.observations,
    required this.products,
    required this.labors,
    required this.statusHistory,
    required this.payments,
    required this.subtotalProducts,
    required this.subtotalLabors,
    required this.discount,
    required this.taxRatePercent,
    required this.taxAmount,
    required this.total,
    required this.paidAmount,
    required this.balance,
    this.createdAt,
  });

  /// Terminal states can no longer be modified (backend rule).
  bool get isLocked =>
      statusCode == WorkOrderStatusCodes.completed ||
      statusCode == WorkOrderStatusCodes.cancelled;

  @override
  List<Object?> get props => [
    code,
    orderNumber,
    statusCode,
    statusName,
    paymentStatus,
    customer,
    vehicle,
    intakeMileage,
    fuelLevel,
    customerComplaint,
    diagnosis,
    observations,
    products,
    labors,
    statusHistory,
    payments,
    subtotalProducts,
    subtotalLabors,
    discount,
    taxRatePercent,
    taxAmount,
    total,
    paidAmount,
    balance,
    createdAt,
  ];
}

class WorkOrderProductLine extends Equatable {
  final int id;
  final String productCode;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double total;

  const WorkOrderProductLine({
    required this.id,
    required this.productCode,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  @override
  List<Object?> get props => [
    id,
    productCode,
    productName,
    quantity,
    unitPrice,
    total,
  ];
}

class WorkOrderLaborLine extends Equatable {
  final int id;
  final String? serviceCode;
  final String description;
  final String? mechanicName;
  final double? hours;
  final double quantity;
  final double unitPrice;
  final double total;

  const WorkOrderLaborLine({
    required this.id,
    this.serviceCode,
    required this.description,
    this.mechanicName,
    this.hours,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  @override
  List<Object?> get props => [
    id,
    serviceCode,
    description,
    mechanicName,
    hours,
    quantity,
    unitPrice,
    total,
  ];
}

class WorkOrderHistoryEntry extends Equatable {
  final String statusCode;
  final String statusName;
  final String? comment;
  final String createdBy;
  final DateTime? createdAt;

  const WorkOrderHistoryEntry({
    required this.statusCode,
    required this.statusName,
    this.comment,
    required this.createdBy,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    statusCode,
    statusName,
    comment,
    createdBy,
    createdAt,
  ];
}

class WorkOrderPayment extends Equatable {
  final int id;
  final double amount;
  final String method;
  final String? reference;
  final String? notes;
  final DateTime? createdAt;

  const WorkOrderPayment({
    required this.id,
    required this.amount,
    required this.method,
    this.reference,
    this.notes,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, amount, method, reference, notes, createdAt];
}
