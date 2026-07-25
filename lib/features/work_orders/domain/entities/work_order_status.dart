import 'package:equatable/equatable.dart';

class WorkOrderStatus extends Equatable {
  final String code;
  final String name;

  const WorkOrderStatus({required this.code, required this.name});

  @override
  List<Object?> get props => [code, name];
}
