import '../../domain/entities/product_input.dart';

/// Body for create/update (backend `ProductSaveDto`).
class ProductSaveDto {
  final ProductInput input;

  const ProductSaveDto(this.input);

  Map<String, dynamic> toJson() => {
        'name': input.name,
        'categoryCode': input.categoryCode,
        'description': input.description,
        'brand': input.brand,
        'barcode': input.barcode,
        'unit': input.unit,
        'costPrice': input.costPrice,
        'salePrice': input.salePrice,
        'isTaxable': input.isTaxable,
      };
}
