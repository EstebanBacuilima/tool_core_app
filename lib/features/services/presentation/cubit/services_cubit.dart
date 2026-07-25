import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/service.dart';
import '../../domain/repositories/services_repository.dart';
import 'services_state.dart';

class ServicesCubit extends Cubit<ServicesState> {
  final ServicesRepository _repository;
  Service? lastToggled;

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

  /// Activates/deactivates [service]
  Future<void> toggleActive(Service service, bool isActive) async {
    final current = state;
    if (current is! ServicesLoaded || current.togglingCode != null) return;
    emit(current.copyWith(togglingCode: service.code));
    try {
      final updated = await _repository.update(
        code: service.code,
        name: service.name,
        price: service.price,
        description: service.description,
        isActive: isActive,
      );
      final services = [
        for (final s in current.services) s.code == updated.code ? updated : s,
      ];
      lastToggled = updated;
      emit(ServicesLoaded(services));
    } on ApiException catch (e) {
      emit(current.copyWith(errorCode: e.code));
    } catch (_) {
      emit(current.copyWith(errorCode: ClientErrorCodes.unexpected));
    }
  }
}
