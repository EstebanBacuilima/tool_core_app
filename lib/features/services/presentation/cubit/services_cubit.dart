import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/repositories/services_repository.dart';
import 'services_state.dart';

/// Cubit for the services list screen.
class ServicesCubit extends Cubit<ServicesState> {
  final ServicesRepository _repository;

  ServicesCubit(this._repository) : super(const ServicesInitial());

  Future<void> load() async {
    emit(const ServicesLoading());
    try {
      final services = await _repository.getAll();
      emit(ServicesLoaded(services));
    } on ApiException catch (e) {
      emit(ServicesFailure(e.code));
    } catch (_) {
      emit(const ServicesFailure(ClientErrorCodes.unexpected));
    }
  }
}
