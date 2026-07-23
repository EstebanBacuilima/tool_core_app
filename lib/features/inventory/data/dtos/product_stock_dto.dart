import '../../domain/entities/product_stock.dart';

/// Backend `WorkshopProductStockDto` (returned after a movement).
class ProductStockDto {
  final String productCode;
  final String productName;
  final double stock;

  const ProductStockDto({
    required this.productCode,
    required this.productName,
    required this.stock,
  });

  factory ProductStockDto.fromJson(Map<String, dynamic> json) {
    return ProductStockDto(
      productCode: json['productCode'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      stock: (json['stock'] as num? ?? 0).toDouble(),
    );
  }

  ProductStock toEntity() => ProductStock(
        productCode: productCode,
        productName: productName,
        stock: stock,
      );
}
