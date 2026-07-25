import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
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

  const Vehicle({
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

  String get label => '$plate • $brand $model${year != null ? ' $year' : ''}';

  @override
  List<Object?> get props => [
    code,
    plate,
    brand,
    model,
    year,
    color,
    vin,
    mileage,
    customerCode,
    customerName,
  ];
}
