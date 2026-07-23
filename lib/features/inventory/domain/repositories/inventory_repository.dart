import '../entities/movement_type.dart';
import '../entities/product.dart';
import '../entities/product_category.dart';
import '../entities/product_input.dart';
import '../entities/product_stock.dart';

/// Products + stock, scoped to the ACTIVE workshop (read from session
/// storage by the implementation — cubits never handle workshop codes).
abstract class InventoryRepository {
  /// `GET /product-categories` (tree).
  Future<List<ProductCategory>> getCategories();

  /// `GET /workshops/{workshopCode}/products?category-code=&search=`
  Future<List<Product>> getProducts({String? categoryCode, String? search});

  /// `POST /workshops/{workshopCode}/products` (stock starts at 0).
  Future<Product> createProduct(ProductInput input);

  /// `PUT /products/{productCode}`
  Future<Product> updateProduct(String code, ProductInput input);

  /// `POST /workshops/{workshopCode}/products/{productCode}/movements`
  Future<ProductStock> addMovement({
    required String productCode,
    required MovementType type,
    required double quantity,
    String? reason,
  });
}
