import 'package:equatable/equatable.dart';

/// Write model for create/update product (mirrors backend ProductSaveDto).
class ProductInput extends Equatable {
  final String name;
  final String categoryCode;
  final String? description;
  final String? brand;
  final String? barcode;
  final String? unit;
  final double costPrice;
  final double salePrice;
  final bool isTaxable;

  const ProductInput({
    required this.name,
    required this.categoryCode,
    this.description,
    this.brand,
    this.barcode,
    this.unit,
    required this.costPrice,
    required this.salePrice,
    required this.isTaxable,
  });

  @override
  List<Object?> get props => [
        name,
        categoryCode,
        description,
        brand,
        barcode,
        unit,
        costPrice,
        salePrice,
        isTaxable,
      ];
}
