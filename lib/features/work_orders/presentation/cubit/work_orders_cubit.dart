import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/work_order_status.dart';
import '../../domain/repositories/work_orders_repository.dart';
import 'work_orders_state.dart';

class WorkOrdersCubit extends Cubit<WorkOrdersState> {
  final WorkOrdersRepository _repository;

  List<WorkOrderStatus> _statuses = const [];
  String? _statusCode;
  String _search = '';
  int _page = 1;

  WorkOrdersCubit(this._repository) : super(const WorkOrdersInitial());

  Future<void> load() async {
    emit(const WorkOrdersLoading());
    _page = 1;
    try {
      // Status catalog rarely changes: fetch once per screen.
      if (_statuses.isEmpty) {
        _statuses = await _repository.getStatuses();
      }
      final result = await _repository.getAll(
        statusCode: _statusCode,
        search: _search,
      );
      emit(
        WorkOrdersLoaded(
          orders: result.items,
          statuses: _statuses,
          selectedStatusCode: _statusCode,
          search: _search,
          hasMore: result.hasNext,
        ),
      );
    } on ApiException catch (e) {
      emit(WorkOrdersFailure(e.code));
    } catch (_) {
      emit(const WorkOrdersFailure(ClientErrorCodes.unexpected));
    }
  }

  /// Appends the next page (infinite scroll). Failures just stop the
  /// spinner; scrolling again retries.
  Future<void> loadMore() async {
    final current = state;
    if (current is! WorkOrdersLoaded ||
        !current.hasMore ||
        current.loadingMore) {
      return;
    }

    emit(current.copyWith(loadingMore: true));
    try {
      final result = await _repository.getAll(
        statusCode: _statusCode,
        search: _search,
        page: _page + 1,
      );
      _page++;
      emit(
        current.copyWith(
          orders: [...current.orders, ...result.items],
          hasMore: result.hasNext,
          loadingMore: false,
        ),
      );
    } on ApiException {
      emit(current.copyWith(loadingMore: false));
    }
  }

  Future<void> setStatus(String? statusCode) {
    _statusCode = statusCode;
    return load();
  }

  /// Called by the UI already debounced.
  Future<void> setSearch(String query) {
    _search = query.trim();
    return load();
  }
}
