import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metrixvox_admin/models/tenant.dart';
import 'package:metrixvox_admin/services/tenant_service.dart';

/// Estado global del tenant activo (para SuperAdmin).
/// Cuando un SuperAdmin selecciona un tenant, todas las llamadas
/// a la API incluyen el header X-Tenant-Id con ese valor.
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

  /// ID del tenant para el header X-Tenant-Id. Null si no hay selección.
  String? get activeTenantId => _selected?.tenantId;

  /// Carga la lista de tenants desde la API.
  Future<void> loadTenants(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tenants = await TenantService.list(token);

      // Restaurar el último tenant guardado (si existe)
      final prefs = await SharedPreferences.getInstance();
      final savedTenantId = prefs.getString(_storageKey);

      if (savedTenantId != null &&
          _tenants.any((t) => t.tenantId == savedTenantId)) {
        _selected = _tenants.firstWhere((t) => t.tenantId == savedTenantId);
      } else if (_tenants.isNotEmpty) {
        _selected = _tenants.first;
        await _persistSelection(_selected!);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cambia el tenant activo.
  Future<void> selectTenant(Tenant tenant) async {
    _selected = tenant;
    await _persistSelection(tenant);
    notifyListeners();
  }

  /// Limpia la selección (al hacer logout).
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
