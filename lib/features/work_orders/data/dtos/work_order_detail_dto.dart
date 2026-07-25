import '../../../../shared/data/dtos/customer_dto.dart';
import '../../../../shared/data/dtos/vehicle_dto.dart';
import '../../domain/entities/work_order_detail.dart';

class WorkOrderDetailDto {
  final Map<String, dynamic> json;

  const WorkOrderDetailDto(this.json);

  factory WorkOrderDetailDto.fromJson(Map<String, dynamic> json) =>
      WorkOrderDetailDto(json);

  WorkOrderDetail toEntity() {
    double money(String key) => (json[key] as num? ?? 0).toDouble();

    return WorkOrderDetail(
      code: json['code'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      statusCode: json['statusCode'] as String? ?? '',
      statusName: json['statusName'] as String? ?? '',
      paymentStatus: json['paymentStatus'] as String? ?? '',
      customer: CustomerDto.fromJson(
        json['customer'] as Map<String, dynamic>? ?? const {},
      ).toEntity(),
      vehicle: VehicleDto.fromJson(
        json['vehicle'] as Map<String, dynamic>? ?? const {},
      ).toEntity(),
      intakeMileage: json['intakeMileage'] as int?,
      fuelLevel: json['fuelLevel'] as String?,
      customerComplaint: json['customerComplaint'] as String?,
      diagnosis: json['diagnosis'] as String?,
      observations: json['observations'] as String?,
      products: [
        for (final line in json['products'] as List<dynamic>? ?? const [])
          _productLine(line as Map<String, dynamic>),
      ],
      labors: [
        for (final line in json['labors'] as List<dynamic>? ?? const [])
          _laborLine(line as Map<String, dynamic>),
      ],
      statusHistory: [
        for (final entry in json['statusHistory'] as List<dynamic>? ?? const [])
          _historyEntry(entry as Map<String, dynamic>),
      ],
      payments: [
        for (final payment in json['payments'] as List<dynamic>? ?? const [])
          _payment(payment as Map<String, dynamic>),
      ],
      subtotalProducts: money('subtotalProducts'),
      subtotalLabors: money('subtotalLabors'),
      discount: money('discount'),
      taxRatePercent: money('taxRatePercent'),
      taxAmount: money('taxAmount'),
      total: money('total'),
      paidAmount: money('paidAmount'),
      balance: money('balance'),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'] as String),
    );
  }

  static WorkOrderProductLine _productLine(Map<String, dynamic> json) {
    return WorkOrderProductLine(
      id: json['id'] as int? ?? 0,
      productCode: json['productCode'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      quantity: (json['quantity'] as num? ?? 0).toDouble(),
      unitPrice: (json['unitPrice'] as num? ?? 0).toDouble(),
      total: (json['total'] as num? ?? 0).toDouble(),
    );
  }

  static WorkOrderLaborLine _laborLine(Map<String, dynamic> json) {
    return WorkOrderLaborLine(
      id: json['id'] as int? ?? 0,
      serviceCode: json['serviceCode'] as String?,
      description: json['description'] as String? ?? '',
      mechanicName: json['mechanicName'] as String?,
      hours: (json['hours'] as num?)?.toDouble(),
      quantity: (json['quantity'] as num? ?? 0).toDouble(),
      unitPrice: (json['unitPrice'] as num? ?? 0).toDouble(),
      total: (json['total'] as num? ?? 0).toDouble(),
    );
  }

  static WorkOrderHistoryEntry _historyEntry(Map<String, dynamic> json) {
    return WorkOrderHistoryEntry(
      statusCode: json['statusCode'] as String? ?? '',
      statusName: json['statusName'] as String? ?? '',
      comment: json['comment'] as String?,
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'] as String),
    );
  }

  static WorkOrderPayment _payment(Map<String, dynamic> json) {
    return WorkOrderPayment(
      id: json['id'] as int? ?? 0,
      amount: (json['amount'] as num? ?? 0).toDouble(),
      method: json['method'] as String? ?? '',
      reference: json['reference'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'] as String),
    );
  }
}
