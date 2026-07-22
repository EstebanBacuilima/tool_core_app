import 'package:equatable/equatable.dart';

import 'workshop_setting.dart';

class Workshop extends Equatable {
  final String code;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final bool isActive;
  final WorkshopSetting? setting;

  const Workshop({
    required this.code,
    required this.name,
    this.phone,
    this.email,
    this.address,
    required this.isActive,
    this.setting,
  });

  @override
  List<Object?> get props =>
      [code, name, phone, email, address, isActive, setting];
}
