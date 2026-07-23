import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

/// Wrapper around secure storage for session data.
class SessionStorage {
  final FlutterSecureStorage _storage;

  const SessionStorage(this._storage);

  Future<String?> readToken() => _storage.read(key: StorageKeys.token);

  Future<void> writeToken(String token) =>
      _storage.write(key: StorageKeys.token, value: token);

  Future<String?> readActiveCompanyCode() =>
      _storage.read(key: StorageKeys.activeCompanyCode);

  Future<void> writeActiveCompanyCode(String code) =>
      _storage.write(key: StorageKeys.activeCompanyCode, value: code);

  Future<String?> readActiveWorkshopCode() =>
      _storage.read(key: StorageKeys.activeWorkshopCode);

  Future<void> writeActiveWorkshopCode(String code) =>
      _storage.write(key: StorageKeys.activeWorkshopCode, value: code);

  Future<String?> readThemeMode() =>
      _storage.read(key: StorageKeys.themeMode);

  Future<void> writeThemeMode(String mode) =>
      _storage.write(key: StorageKeys.themeMode, value: mode);

  /// Clears the session (logout / expired session). The theme preference
  /// survives on purpose.
  Future<void> clear() async {
    await _storage.delete(key: StorageKeys.token);
    await _storage.delete(key: StorageKeys.activeCompanyCode);
    await _storage.delete(key: StorageKeys.activeWorkshopCode);
  }
}
