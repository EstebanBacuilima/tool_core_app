import '../../domain/entities/company.dart';
import 'workshop_dto.dart';

/// Backend `CompanyDto`.
class CompanyDto {
  final String code;
  final String name;
  final String ruc;
  final String? phone;
  final String? email;
  final String? address;
  final String? logo;
  final bool isActive;
  final List<WorkshopDto> workshops;

  const CompanyDto({
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

  factory CompanyDto.fromJson(Map<String, dynamic> json) {
    return CompanyDto(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      ruc: json['ruc'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      logo: json['logo'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      workshops: (json['workshops'] as List<dynamic>? ?? const [])
          .map((e) => WorkshopDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Company toEntity() => Company(
        code: code,
        name: name,
        ruc: ruc,
        phone: phone,
        email: email,
        address: address,
        logo: logo,
        isActive: isActive,
        workshops: workshops.map((w) => w.toEntity()).toList(),
      );
}
