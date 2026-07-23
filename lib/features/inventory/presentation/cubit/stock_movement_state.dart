import 'package:equatable/equatable.dart';

import '../../domain/entities/product_stock.dart';

/// States of the stock movement form (bottom sheet).
sealed class StockMovementState extends Equatable {
  const StockMovementState();

  @override
  List<Object?> get props => [];
}

class StockMovementInitial extends StockMovementState {
  const StockMovementInitial();
}

class StockMovementSaving extends StockMovementState {
  const StockMovementSaving();
}

class StockMovementSuccess extends StockMovementState {
  final ProductStock stock;

  const StockMovementSuccess(this.stock);

  @override
  List<Object?> get props => [stock];
}

class StockMovementFailure extends StockMovementState {
  final String code;

  const StockMovementFailure(this.code);

  @override
  List<Object?> get props => [code];
}
