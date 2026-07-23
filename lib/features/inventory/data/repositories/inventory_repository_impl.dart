import 'package:dio/dio.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/movement_type.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/product_input.dart';
import '../../domain/entities/product_stock.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_datasource.dart';
import '../dtos/product_save_dto.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDatasource _remote;
  final SessionStorage _storage;

  const InventoryRepositoryImpl(this._remote, this._storage);

  Future<String> _workshopCode() async {
    final code = await _storage.readActiveWorkshopCode();
    if (code == null) {
      throw const ApiException(ClientErrorCodes.workshopNotSelected);
    }
    return code;
  }

  @override
  Future<List<ProductCategory>> getCategories() async {
    try {
      final dtos = await _remote.getCategories();
      return dtos.map((d) => d.toEntity()).toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<List<Product>> getProducts({
    String? categoryCode,
    String? search,
  }) async {
    try {
      final dtos = await _remote.getProducts(
        await _workshopCode(),
        categoryCode: categoryCode,
        search: search,
      );
      return dtos.map((d) => d.toEntity()).toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<Product> createProduct(ProductInput input) async {
    try {
      final dto = await _remote.create(
        await _workshopCode(),
        ProductSaveDto(input),
      );
      return dto.toEntity();
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<Product> updateProduct(String code, ProductInput input) async {
    try {
      final dto = await _remote.update(code, ProductSaveDto(input));
      return dto.toEntity();
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }

  @override
  Future<ProductStock> addMovement({
    required String productCode,
    required MovementType type,
    required double quantity,
    String? reason,
  }) async {
    try {
      final dto = await _remote.addMovement(
        await _workshopCode(),
        productCode,
        {'type': type.value, 'quantity': quantity, 'reason': reason},
      );
      return dto.toEntity();
    } on DioException catch (e) {
      throw ErrorMapper.fromDio(e);
    }
  }
}
