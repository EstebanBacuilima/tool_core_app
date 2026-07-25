import 'package:equatable/equatable.dart';

import 'vehicle.dart';

class Customer extends Equatable {
  final String code;
  final String firstName;
  final String? lastName;
  final String? identificationNumber;
  final String? email;
  final String? phone;
  final String? address;

  final List<Vehicle> vehicles;

  const Customer({
    required this.code,
    required this.firstName,
    this.lastName,
    this.identificationNumber,
    this.email,
    this.phone,
    this.address,
    this.vehicles = const [],
  });

  String get fullName => [firstName, ?lastName].join(' ');

  @override
  List<Object?> get props => [
    code,
    firstName,
    lastName,
    identificationNumber,
    email,
    phone,
    address,
    vehicles,
  ];
}
