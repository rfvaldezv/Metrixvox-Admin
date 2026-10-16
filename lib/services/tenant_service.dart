import 'package:metrixvox_admin/config/app_config.dart';
import 'package:metrixvox_admin/models/tenant.dart';
import 'package:metrixvox_admin/services/api_client.dart';

/// Servicio para consultar tenants desde la API.
class TenantService {
  /// Lista todos los tenants disponibles (solo SuperAdmin).
  static Future<List<Tenant>> list(String token) async {
    final api = ApiClient(token: token);

    final json = await api.get(AppConfig.adminTenants);

    if (json == null) return [];

    // El backend puede devolver un array directo o envuelto en {value: []}
    List<dynamic> list;
    if (json is List) {
      list = json;
    } else if (json is Map && json['value'] is List) {
      list = json['value'] as List<dynamic>;
    } else {
      return [];
    }

    return list
        .map((t) => Tenant.fromJson(t as Map<String, dynamic>))
        .toList();
  }
}
