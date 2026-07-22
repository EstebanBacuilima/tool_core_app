/// API-related constants. The base URL is NEVER hardcoded in code paths:
/// it comes from `--dart-define=API_BASE_URL` at build/run time.
///
/// Local:            http://localhost:5125/api/v1
/// Android emulator: http://10.0.2.2:5125/api/v1
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5125/api/v1',
  );

  /// Header used by tenant-scoped endpoints.
  static const String companyCodeHeader = 'X-Company-Code';
}
