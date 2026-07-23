import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/repositories/inventory_repository.dart';
import 'inventory_state.dart';

/// Cubit for the inventory list screen: products of the active workshop
/// filtered by category and/or text search (server-side filters).
class InventoryCubit extends Cubit<InventoryState> {
  final InventoryRepository _repository;

  List<ProductCategory> _categories = const [];
  String? _categoryCode;
  String _search = '';

  InventoryCubit(this._repository) : super(const InventoryInitial());

  Future<void> load() async {
    emit(const InventoryLoading());
    try {
      // Categories rarely change: fetch them once per screen.
      if (_categories.isEmpty) {
        _categories = await _repository.getCategories();
      }
      final products = await _repository.getProducts(
        categoryCode: _categoryCode,
        search: _search,
      );
      emit(InventoryLoaded(
        products: products,
        categories: _categories,
        selectedCategoryCode: _categoryCode,
        search: _search,
      ));
    } on ApiException catch (e) {
      emit(InventoryFailure(e.code));
    } catch (_) {
      emit(const InventoryFailure(ClientErrorCodes.unexpected));
    }
  }

  Future<void> setCategory(String? categoryCode) {
    _categoryCode = categoryCode;
    return load();
  }

  /// Called by the UI already debounced.
  Future<void> setSearch(String query) {
    _search = query.trim();
    return load();
  }
}
