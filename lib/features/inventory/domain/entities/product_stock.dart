import 'package:equatable/equatable.dart';

/// Stock of a product in a workshop (result of a movement).
class ProductStock extends Equatable {
  final String productCode;
  final String productName;
  final double stock;

  const ProductStock({
    required this.productCode,
    required this.productName,
    required this.stock,
  });

  @override
  List<Object?> get props => [productCode, productName, stock];
}
