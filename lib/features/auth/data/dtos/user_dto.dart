import '../../../../shared/data/dtos/company_dto.dart';
import '../../../../shared/data/dtos/role_dto.dart';
import '../../domain/entities/user_profile.dart';

/// Backend `UserProfileDto` (`GET /users/me`).
class UserDto {
  final String code;
  final String username;
  final String email;
  final String? displayName;
  final String? identificationNumber;
  final String? phone;
  final List<CompanyDto> companies;
  final List<RoleDto> roles;

  const UserDto({
    required this.code,
    required this.username,
    required this.email,
    this.displayName,
    this.identificationNumber,
    this.phone,
    required this.companies,
    required this.roles,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      code: json['code'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String?,
      identificationNumber: json['identificationNumber'] as String?,
      phone: json['phone'] as String?,
      companies: (json['companies'] as List<dynamic>? ?? const [])
          .map((e) => CompanyDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      roles: (json['roles'] as List<dynamic>? ?? const [])
          .map((e) => RoleDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      code: code,
      username: username,
      email: email,
      displayName: displayName,
      identificationNumber: identificationNumber,
      phone: phone,
      companies: companies.map((c) => c.toEntity()).toList(),
      roles: roles.map((r) => r.toEntity()).toList(),
    );
  }
}
