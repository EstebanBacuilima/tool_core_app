import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/movement_type.dart';
import '../../domain/repositories/inventory_repository.dart';
import 'stock_movement_state.dart';

/// Cubit for registering a stock movement on a product.
class StockMovementCubit extends Cubit<StockMovementState> {
  final InventoryRepository _repository;

  StockMovementCubit(this._repository) : super(const StockMovementInitial());

  Future<void> submit({
    required String productCode,
    required MovementType type,
    required double quantity,
    String? reason,
  }) async {
    if (state is StockMovementSaving) return;

    emit(const StockMovementSaving());
    try {
      final stock = await _repository.addMovement(
        productCode: productCode,
        type: type,
        quantity: quantity,
        reason: reason,
      );
      emit(StockMovementSuccess(stock));
    } on ApiException catch (e) {
      emit(StockMovementFailure(e.code));
    } catch (_) {
      emit(const StockMovementFailure(ClientErrorCodes.unexpected));
    }
  }
}
