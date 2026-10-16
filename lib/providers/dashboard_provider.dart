import 'package:flutter/foundation.dart';
import 'package:metrixvox_admin/models/dashboard_metrics.dart';
import 'package:metrixvox_admin/services/dashboard_service.dart';

/// Estado del dashboard: métricas del tenant activo.
class DashboardProvider extends ChangeNotifier {
  DashboardMetrics? _metrics;
  bool _isLoading = false;
  String? _error;

  DashboardMetrics? get metrics => _metrics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carga las métricas para el tenant indicado.
  Future<void> load({
    required String token,
    required String tenantId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _metrics = await DashboardService.getMetrics(
        token: token,
        tenantId: tenantId,
      );
    } catch (e) {
      _error = e.toString();
      _metrics = DashboardMetrics.empty();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpia el estado (al hacer logout).
  void clear() {
    _metrics = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
