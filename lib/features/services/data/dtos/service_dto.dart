import '../../domain/entities/service.dart';

class ServiceDto {
  final String code;
  final String name;
  final double price;
  final double priceWithTax;

  final String? description;
  final bool isActive;

  const ServiceDto({
    required this.code,
    required this.name,
    required this.price,
    required this.priceWithTax,
    this.description,
    required this.isActive,
  });

  factory ServiceDto.fromJson(Map<String, dynamic> json) {
    final price = (json['price'] as num? ?? 0).toDouble();
    return ServiceDto(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: price,
      priceWithTax: (json['priceWithTax'] as num?)?.toDouble() ?? price,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Service toEntity() => Service(
    code: code,
    name: name,
    price: price,
    priceWithTax: priceWithTax,
    description: description,
    isActive: isActive,
  );
}
