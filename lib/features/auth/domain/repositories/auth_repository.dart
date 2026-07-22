import '../entities/user_profile.dart';

/// Repository for the auth feature.
abstract class AuthRepository {
  /// Login endpoint.
  Future<void> login({required String username, required String password});

  /// Profile endpoint.
  Future<UserProfile> getProfile();

  /// Whether a token exists in secure storage.
  Future<bool> hasSession();

  /// Persists the active company code.
  Future<void> setActiveCompany(String companyCode);

  Future<String?> getActiveCompany();

  /// Clears token and company code from secure storage.
  Future<void> logout();
}
