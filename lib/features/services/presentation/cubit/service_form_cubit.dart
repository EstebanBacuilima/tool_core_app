import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/repositories/services_repository.dart';
import 'service_form_state.dart';

/// Cubit for the create/edit service form. [code] == null creates,
/// otherwise updates that service.
class ServiceFormCubit extends Cubit<ServiceFormState> {
  final ServicesRepository _repository;

  ServiceFormCubit(this._repository) : super(const ServiceFormInitial());

  Future<void> submit({
    String? code,
    required String name,
    required double price,
    String? description,
  }) async {
    if (state is ServiceFormSaving) return;

    emit(const ServiceFormSaving());
    try {
      if (code == null) {
        await _repository.create(
          name: name,
          price: price,
          description: description,
        );
      } else {
        await _repository.update(
          code: code,
          name: name,
          price: price,
          description: description,
        );
      }
      emit(const ServiceFormSuccess());
    } on ApiException catch (e) {
      emit(ServiceFormFailure(e.code));
    } catch (_) {
      emit(const ServiceFormFailure(ClientErrorCodes.unexpected));
    }
  }
}
