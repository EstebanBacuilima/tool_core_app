import 'package:dio/dio.dart';

import '../../../../core/models/api_paged_response.dart';
import '../../../../core/models/api_response.dart';
import '../dtos/product_category_dto.dart';
import '../dtos/product_dto.dart';
import '../dtos/product_save_dto.dart';
import '../dtos/product_stock_dto.dart';


class InventoryRemoteDatasource {
  final Dio _dio;

  const InventoryRemoteDatasource(this._dio);

  Future<List<ProductCategoryDto>> getCategories() async {
    final response =
        await _dio.get<Map<String, dynamic>>('/product-categories');

    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => (json as List<dynamic>)
          .map((e) => ProductCategoryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return envelope.data ?? const [];
  }

  Future<ApiPagedResponse<ProductDto>> getProducts(
    String workshopCode, {
    String? categoryCode,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/workshops/$workshopCode/products',
      queryParameters: {
        'category-code': ?categoryCode,
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
        'page-size': pageSize,
      },
    );

    return ApiPagedResponse.fromJson(response.data!, ProductDto.fromJson);
  }

  Future<ProductDto> create(String workshopCode, ProductSaveDto dto) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/workshops/$workshopCode/products',
      data: dto.toJson(),
    );

    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => ProductDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<ProductDto> update(String productCode, ProductSaveDto dto) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/products/$productCode',
      data: dto.toJson(),
    );

    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => ProductDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<ProductStockDto> addMovement(
    String workshopCode,
    String productCode,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/workshops/$workshopCode/products/$productCode/movements',
      data: body,
    );

    final envelope = ApiResponse.fromJson(
      response.data!,
      (json) => ProductStockDto.fromJson(json as Map<String, dynamic>),
    );
    return envelope.data!;
  }
}
