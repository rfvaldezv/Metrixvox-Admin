import 'package:flutter/foundation.dart';
import 'package:metrixvox_admin/models/dashboard_metrics.dart';
import 'package:metrixvox_admin/services/dashboard_service.dart';
import 'package:metrixvox_admin/services/api_client.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardMetrics? _metrics;
  bool _isLoading = false;
  String? _error;
  bool _unauthorized = false;

  DashboardMetrics? get metrics => _metrics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isUnauthorized => _unauthorized;

  Future<void> load({
    required String token,
    required String tenantId,
  }) async {
    _isLoading = true;
    _error = null;
    _unauthorized = false;
    notifyListeners();

    try {
      _metrics = await DashboardService.getMetrics(
        token: token,
        tenantId: tenantId,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        _unauthorized = true;
      } else {
        _error = e.message;
        _metrics = DashboardMetrics.empty();
      }
    } catch (e) {
      _error = e.toString();
      _metrics = DashboardMetrics.empty();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _metrics = null;
    _error = null;
    _isLoading = false;
    _unauthorized = false;
    notifyListeners();
  }
}
