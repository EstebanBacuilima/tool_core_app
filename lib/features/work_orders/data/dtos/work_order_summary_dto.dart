import '../../domain/entities/work_order_summary.dart';

class WorkOrderSummaryDto {
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

  const WorkOrderSummaryDto({
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

  factory WorkOrderSummaryDto.fromJson(Map<String, dynamic> json) {
    return WorkOrderSummaryDto(
      code: json['code'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      statusCode: json['statusCode'] as String? ?? '',
      statusName: json['statusName'] as String? ?? '',
      paymentStatus: json['paymentStatus'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      vehiclePlate: json['vehiclePlate'] as String? ?? '',
      total: (json['total'] as num? ?? 0).toDouble(),
      balance: (json['balance'] as num? ?? 0).toDouble(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'] as String),
    );
  }

  WorkOrderSummary toEntity() => WorkOrderSummary(
    code: code,
    orderNumber: orderNumber,
    statusCode: statusCode,
    statusName: statusName,
    paymentStatus: paymentStatus,
    customerName: customerName,
    vehiclePlate: vehiclePlate,
    total: total,
    balance: balance,
    createdAt: createdAt,
  );
}
