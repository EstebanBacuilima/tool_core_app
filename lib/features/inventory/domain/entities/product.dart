import 'package:equatable/equatable.dart';

/// Spare-part / product catalog item. [stock] is the quantity in the
/// requested workshop (null outside a workshop context).
class Product extends Equatable {
  final String code;
  final String name;
  final String? description;
  final String? brand;
  final String? barcode;
  final String? unit;
  final double costPrice;
  final double salePrice;
  final bool isTaxable;
  final bool isActive;
  final String categoryCode;
  final String categoryName;
  final double? stock;

  const Product({
    required this.code,
    required this.name,
    this.description,
    this.brand,
    this.barcode,
    this.unit,
    required this.costPrice,
    required this.salePrice,
    required this.isTaxable,
    required this.isActive,
    required this.categoryCode,
    required this.categoryName,
    this.stock,
  });

  @override
  List<Object?> get props => [
        code,
        name,
        description,
        brand,
        barcode,
        unit,
        costPrice,
        salePrice,
        isTaxable,
        isActive,
        categoryCode,
        categoryName,
        stock,
      ];
}
