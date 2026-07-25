import 'package:equatable/equatable.dart';

class WorkOrderSummary extends Equatable {
  final String code;
  final String orderNumber;
  final String statusCode;
  final String statusName;
  final String paymentStatus;
  final String customerName;
  final String vehiclePlate;
  final double total;
  final double balance;
  final DateTime? createdAt;

  const WorkOrderSummary({
    required this.code,
    required this.orderNumber,
    required this.statusCode,
    required this.statusName,
    required this.paymentStatus,
    required this.customerName,
    required this.vehiclePlate,
    required this.total,
    required this.balance,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    code,
    orderNumber,
    statusCode,
    statusName,
    paymentStatus,
    customerName,
    vehiclePlate,
    total,
    balance,
    createdAt,
  ];
}
