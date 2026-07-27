import '../../domain/entities/product.dart';

/// Backend `ProductDto`.
class ProductDto {
  final String code;
  final String name;
  final String? description;
  final String? brand;
  final String? barcode;
  final String? unit;
  final double costPrice;
  final double salePrice;
  final double salePriceWithTax;
  final bool isTaxable;
  final bool isActive;
  final String categoryCode;
  final String categoryName;
  final double? stock;

  const ProductDto({
    required this.code,
    required this.name,
    this.description,
    this.brand,
    this.barcode,
    this.unit,
    required this.costPrice,
    required this.salePrice,
    required this.salePriceWithTax,
    required this.isTaxable,
    required this.isActive,
    required this.categoryCode,
    required this.categoryName,
    this.stock,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    final salePrice = (json['salePrice'] as num? ?? 0).toDouble();
    return ProductDto(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      brand: json['brand'] as String?,
      barcode: json['barcode'] as String?,
      unit: json['unit'] as String?,
      costPrice: (json['costPrice'] as num? ?? 0).toDouble(),
      salePrice: salePrice,
      salePriceWithTax:
          (json['salePriceWithTax'] as num?)?.toDouble() ?? salePrice,
      isTaxable: json['isTaxable'] as bool? ?? true,
      isActive: json['isActive'] as bool? ?? true,
      categoryCode: json['categoryCode'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      stock: (json['stock'] as num?)?.toDouble(),
    );
  }

  Product toEntity() => Product(
        code: code,
        name: name,
        description: description,
        brand: brand,
        barcode: barcode,
        unit: unit,
        costPrice: costPrice,
        salePrice: salePrice,
        salePriceWithTax: salePriceWithTax,
        isTaxable: isTaxable,
        isActive: isActive,
        categoryCode: categoryCode,
        categoryName: categoryName,
        stock: stock,
      );
}
