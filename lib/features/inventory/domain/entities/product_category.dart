import 'package:equatable/equatable.dart';

/// Product category (tree: a category can have children).
class ProductCategory extends Equatable {
  final String code;
  final String name;
  final List<ProductCategory> children;

  const ProductCategory({
    required this.code,
    required this.name,
    this.children = const [],
  });

  @override
  List<Object?> get props => [code, name, children];
}
