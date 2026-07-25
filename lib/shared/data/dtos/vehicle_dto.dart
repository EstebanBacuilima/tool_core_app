import '../../domain/entities/vehicle.dart';

/// Backend `VehicleDto`.
class VehicleDto {
  final String code;
  final String plate;
  final String brand;
  final String model;
  final int? year;
  final String? color;
  final String? vin;
  final int? mileage;
  final String? customerCode;
  final String? customerName;

  const VehicleDto({
    required this.code,
    required this.plate,
    required this.brand,
    required this.model,
    this.year,
    this.color,
    this.vin,
    this.mileage,
    this.customerCode,
    this.customerName,
  });

  factory VehicleDto.fromJson(Map<String, dynamic> json) {
    return VehicleDto(
      code: json['code'] as String? ?? '',
      plate: json['plate'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: json['year'] as int?,
      color: json['color'] as String?,
      vin: json['vin'] as String?,
      mileage: json['mileage'] as int?,
      customerCode: json['customerCode'] as String?,
      customerName: json['customerName'] as String?,
    );
  }

  Vehicle toEntity() => Vehicle(
        code: code,
        plate: plate,
        brand: brand,
        model: model,
        year: year,
        color: color,
        vin: vin,
        mileage: mileage,
        customerCode: customerCode,
        customerName: customerName,
      );
}
