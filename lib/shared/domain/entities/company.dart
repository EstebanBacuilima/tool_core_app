import 'package:equatable/equatable.dart';

import 'workshop.dart';

class Company extends Equatable {
  final String code;
  final String name;
  final String ruc;
  final String? phone;
  final String? email;
  final String? address;
  final String? logo;
  final bool isActive;
  final List<Workshop> workshops;

  const Company({
    required this.code,
    required this.name,
    required this.ruc,
    this.phone,
    this.email,
    this.address,
    this.logo,
    required this.isActive,
    required this.workshops,
  });

  @override
  List<Object?> get props =>
      [code, name, ruc, phone, email, address, logo, isActive, workshops];
}
