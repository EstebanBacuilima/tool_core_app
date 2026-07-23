import '../../domain/entities/service.dart';

class ServiceDto {
  final String code;
  final String name;
  final double price;
  final String? description;
  final bool isActive;

  const ServiceDto({
    required this.code,
    required this.name,
    required this.price,
    this.description,
    required this.isActive,
  });

  factory ServiceDto.fromJson(Map<String, dynamic> json) {
    return ServiceDto(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num? ?? 0).toDouble(),
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Service toEntity() => Service(
    code: code,
    name: name,
    price: price,
    description: description,
    isActive: isActive,
  );
}
