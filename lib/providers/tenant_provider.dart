import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metrixvox_admin/models/tenant.dart';
import 'package:metrixvox_admin/services/tenant_service.dart';
import 'package:metrixvox_admin/services/api_client.dart';

class TenantProvider extends ChangeNotifier {
  static const String _storageKey = 'metrixvox_admin.selected_tenant';

  List<Tenant> _tenants = [];
  Tenant? _selected;
  bool _isLoading = false;
  String? _error;

  List<Tenant> get tenants => _tenants;
  Tenant? get selected => _selected;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get activeTenantId => _selected?.tenantId;

  Future<void> loadTenants(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tenants = await TenantService.list(token);

      final prefs = await SharedPreferences.getInstance();
      final savedTenantId = prefs.getString(_storageKey);

      if (savedTenantId != null && _tenants.any((t) => t.tenantId == savedTenantId)) {
        _selected = _tenants.firstWhere((t) => t.tenantId == savedTenantId);
      } else if (_tenants.isNotEmpty) {
        _selected = _tenants.first;
        await _persistSelection(_selected!);
      }
    } on ApiException catch (e) {
      // Si es 401, el token expiró. Propagamos el error para que el AuthProvider actúe.
      if (e.statusCode == 401) rethrow;
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectTenant(Tenant tenant) async {
    _selected = tenant;
    await _persistSelection(tenant);
    notifyListeners();
  }

  Future<void> clear() async {
    _selected = null;
    _tenants = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    notifyListeners();
  }

  Future<void> _persistSelection(Tenant tenant) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, tenant.tenantId);
  }
}
