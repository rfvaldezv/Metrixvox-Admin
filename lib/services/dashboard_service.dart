import 'package:metrixvox_admin/config/app_config.dart';
import 'package:metrixvox_admin/models/dashboard_metrics.dart';
import 'package:metrixvox_admin/services/api_client.dart';

/// Servicio para consultar métricas del dashboard.
class DashboardService {
  /// Obtiene las métricas agregadas del tenant activo.
  static Future<DashboardMetrics> getMetrics({
    required String token,
    required String tenantId,
  }) async {
    final api = ApiClient(token: token, tenantId: tenantId);

    final json = await api.get(AppConfig.dashboardMetrics);

    if (json == null) return DashboardMetrics.empty();

    return DashboardMetrics.fromJson(json as Map<String, dynamic>);
  }
}
