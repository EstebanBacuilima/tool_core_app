import 'package:equatable/equatable.dart';

import '../../../../shared/domain/entities/company.dart';
import '../../../../shared/domain/entities/role.dart';

/// Entity representing an authenticated user profile (`GET /users/me`).
class UserProfile extends Equatable {
  final String code;
  final String username;
  final String email;
  final String? displayName;
  final String? identificationNumber;
  final String? phone;

  /// Companies the user belongs to, with their workshops.
  final List<Company> companies;

  final List<Role> roles;

  const UserProfile({
    required this.code,
    required this.username,
    required this.email,
    this.displayName,
    this.identificationNumber,
    this.phone,
    required this.companies,
    required this.roles,
  });

  /// Codes used to resolve the active company (`X-Company-Code`).
  List<String> get companyCodes => companies.map((c) => c.code).toList();

  /// UI-only check (hide menus/actions); real authorization is backend-side.
  bool hasRole(String slug) => roles.any((r) => r.slug == slug);

  @override
  List<Object?> get props => [
    code,
    username,
    email,
    displayName,
    identificationNumber,
    phone,
    companies,
    roles,
  ];
}
