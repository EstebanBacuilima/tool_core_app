import 'package:equatable/equatable.dart';

class WorkOrderHeaderInput extends Equatable {
  final int? intakeMileage;
  final String? fuelLevel;
  final String? customerComplaint;
  final String? diagnosis;
  final String? observations;
  final double discount;

  const WorkOrderHeaderInput({
    this.intakeMileage,
    this.fuelLevel,
    this.customerComplaint,
    this.diagnosis,
    this.observations,
    this.discount = 0,
  });

  @override
  List<Object?> get props => [
    intakeMileage,
    fuelLevel,
    customerComplaint,
    diagnosis,
    observations,
    discount,
  ];
}
