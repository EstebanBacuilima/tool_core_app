import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';

/// States of the inventory list screen. Loaded carries the active
/// filters so the UI stays in sync after reloads.
sealed class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {
  const InventoryInitial();
}

class InventoryLoading extends InventoryState {
  const InventoryLoading();
}

class InventoryLoaded extends InventoryState {
  final List<Product> products;
  final List<ProductCategory> categories;
  final String? selectedCategoryCode;
  final String search;

  const InventoryLoaded({
    required this.products,
    required this.categories,
    this.selectedCategoryCode,
    this.search = '',
  });

  @override
  List<Object?> get props => [products, categories, selectedCategoryCode, search];
}

class InventoryFailure extends InventoryState {
  final String code;

  const InventoryFailure(this.code);

  @override
  List<Object?> get props => [code];
}
