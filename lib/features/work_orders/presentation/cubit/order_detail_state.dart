import 'package:equatable/equatable.dart';

import '../../domain/entities/work_order_detail.dart';
import '../../domain/entities/work_order_status.dart';

sealed class OrderDetailState extends Equatable {
  const OrderDetailState();

  @override
  List<Object?> get props => [];
}

class OrderDetailInitial extends OrderDetailState {
  const OrderDetailInitial();
}

class OrderDetailLoading extends OrderDetailState {
  const OrderDetailLoading();
}

class OrderDetailLoaded extends OrderDetailState {
  final WorkOrderDetail detail;

  final List<WorkOrderStatus> statuses;
  final bool saving;
  final String? errorCode;

  const OrderDetailLoaded({
    required this.detail,
    required this.statuses,
    this.saving = false,
    this.errorCode,
  });

  OrderDetailLoaded copyWith({
    WorkOrderDetail? detail,
    List<WorkOrderStatus>? statuses,
    bool? saving,
    String? errorCode,
  }) {
    return OrderDetailLoaded(
      detail: detail ?? this.detail,
      statuses: statuses ?? this.statuses,
      saving: saving ?? this.saving,
      errorCode: errorCode,
    );
  }

  @override
  List<Object?> get props => [detail, statuses, saving, errorCode];
}

class OrderDetailFailure extends OrderDetailState {
  final String code;

  const OrderDetailFailure(this.code);

  @override
  List<Object?> get props => [code];
}
