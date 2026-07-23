import '../../domain/entities/product_category.dart';

/// Backend `ProductCategoryDto` (recursive tree).
class ProductCategoryDto {
  final String code;
  final String name;
  final List<ProductCategoryDto> children;

  const ProductCategoryDto({
    required this.code,
    required this.name,
    this.children = const [],
  });

  factory ProductCategoryDto.fromJson(Map<String, dynamic> json) {
    return ProductCategoryDto(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      children: (json['children'] as List<dynamic>? ?? const [])
          .map((e) => ProductCategoryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  ProductCategory toEntity() => ProductCategory(
        code: code,
        name: name,
        children: children.map((c) => c.toEntity()).toList(),
      );
}
