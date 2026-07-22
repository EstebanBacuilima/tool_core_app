import '../../domain/entities/role.dart';

class RoleDto {
  final String code;
  final String name;
  final String? description;
  final String slug;

  const RoleDto({
    required this.code,
    required this.name,
    this.description,
    required this.slug,
  });

  factory RoleDto.fromJson(Map<String, dynamic> json) {
    return RoleDto(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      slug: json['slug'] as String? ?? '',
    );
  }

  Role toEntity() =>
      Role(code: code, name: name, description: description, slug: slug);
}
