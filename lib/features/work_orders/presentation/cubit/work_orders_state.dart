import 'package:equatable/equatable.dart';

import '../../domain/entities/work_order_status.dart';
import '../../domain/entities/work_order_summary.dart';

sealed class WorkOrdersState extends Equatable {
  const WorkOrdersState();

  @override
  List<Object?> get props => [];
}

class WorkOrdersInitial extends WorkOrdersState {
  const WorkOrdersInitial();
}

class WorkOrdersLoading extends WorkOrdersState {
  const WorkOrdersLoading();
}

class WorkOrdersLoaded extends WorkOrdersState {
  final List<WorkOrderSummary> orders;
  final List<WorkOrderStatus> statuses;
  final String? selectedStatusCode;
  final String search;

  /// Server pagination: more pages available / next page in flight.
  final bool hasMore;
  final bool loadingMore;

  const WorkOrdersLoaded({
    required this.orders,
    required this.statuses,
    this.selectedStatusCode,
    this.search = '',
    this.hasMore = false,
    this.loadingMore = false,
  });

  WorkOrdersLoaded copyWith({
    List<WorkOrderSummary>? orders,
    bool? hasMore,
    bool? loadingMore,
  }) {
    return WorkOrdersLoaded(
      orders: orders ?? this.orders,
      statuses: statuses,
      selectedStatusCode: selectedStatusCode,
      search: search,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }

  @override
  List<Object?> get props => [
    orders,
    statuses,
    selectedStatusCode,
    search,
    hasMore,
    loadingMore,
  ];
}

class WorkOrdersFailure extends WorkOrdersState {
  final String code;

  const WorkOrdersFailure(this.code);

  @override
  List<Object?> get props => [code];
}
