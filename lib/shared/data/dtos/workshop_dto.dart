import '../../domain/entities/workshop.dart';
import 'workshop_setting_dto.dart';

class WorkshopDto {
  final String code;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final bool isActive;
  final WorkshopSettingDto? setting;

  const WorkshopDto({
    required this.code,
    required this.name,
    this.phone,
    this.email,
    this.address,
    required this.isActive,
    this.setting,
  });

  factory WorkshopDto.fromJson(Map<String, dynamic> json) {
    return WorkshopDto(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      setting: json['setting'] == null
          ? null
          : WorkshopSettingDto.fromJson(
              json['setting'] as Map<String, dynamic>),
    );
  }

  Workshop toEntity() => Workshop(
        code: code,
        name: name,
        phone: phone,
        email: email,
        address: address,
        isActive: isActive,
        setting: setting?.toEntity(),
      );
}
