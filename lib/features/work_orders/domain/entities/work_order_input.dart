import 'package:equatable/equatable.dart';

/// Creation input (backend `WorkOrderSaveDto`).
class WorkOrderInput extends Equatable {
  final String vehicleCode;
  final int? intakeMileage;
  final String? fuelLevel;
  final String? customerComplaint;

  const WorkOrderInput({
    required this.vehicleCode,
    this.intakeMileage,
    this.fuelLevel,
    this.customerComplaint,
  });

  @override
  List<Object?> get props => [
    vehicleCode,
    intakeMileage,
    fuelLevel,
    customerComplaint,
  ];
}
