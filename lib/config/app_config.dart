/// Configuración central de MetrixVox Admin.
/// La URL de la API puede cambiarse al ejecutar:
///   flutter run -d chrome --dart-define=API_URL=http://localhost:5188
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.metrixvox.com',
  );

  // Endpoints
  static String get authLogin => '$apiBaseUrl/api/v1/auth/login';
  static String get authRefresh => '$apiBaseUrl/api/v1/auth/refresh';
  static String get authLogout => '$apiBaseUrl/api/v1/auth/logout';
  static String get authMe => '$apiBaseUrl/api/v1/auth/me';
  
  static String get adminKiosks => '$apiBaseUrl/api/v1/admin/kiosks';
  static String get adminUsers => '$apiBaseUrl/api/v1/admin/users';
  static String get adminTenants => '$apiBaseUrl/api/v1/admin/tenants';
  static String get dashboardMetrics => '$apiBaseUrl/api/v1/dashboard/metrics';
  static String get surveys => '$apiBaseUrl/api/v1/surveys';
  static String get adminResponses => '$apiBaseUrl/api/v1/admin/responses';
  static String get adminKiosksByUser => '$apiBaseUrl/api/v1/admin/users';
  
  // NUEVOS Endpoints de Reportes
  static String get adminAnalytics => '$apiBaseUrl/api/v1/admin/analytics';
  static String get adminReports => '$apiBaseUrl/api/v1/admin/reports';

  // Storage keys
  static const String storageKeyToken = 'metrixvox_admin.token';
  static const String storageKeyRefreshToken = 'metrixvox_admin.refresh_token';
  static const String storageKeyUser = 'metrixvox_admin.user';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 20);
}
