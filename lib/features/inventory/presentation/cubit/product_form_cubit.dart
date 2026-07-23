import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/product_input.dart';
import '../../domain/repositories/inventory_repository.dart';
import 'product_form_state.dart';

/// Cubit for the create/edit product form. [code] == null creates.
class ProductFormCubit extends Cubit<ProductFormState> {
  final InventoryRepository _repository;

  ProductFormCubit(this._repository) : super(const ProductFormInitial());

  Future<void> submit({String? code, required ProductInput input}) async {
    if (state is ProductFormSaving) return;

    emit(const ProductFormSaving());
    try {
      if (code == null) {
        await _repository.createProduct(input);
      } else {
        await _repository.updateProduct(code, input);
      }
      emit(const ProductFormSuccess());
    } on ApiException catch (e) {
      emit(ProductFormFailure(e.code));
    } catch (_) {
      emit(const ProductFormFailure(ClientErrorCodes.unexpected));
    }
  }
}
