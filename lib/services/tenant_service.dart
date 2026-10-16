import 'package:metrixvox_admin/config/app_config.dart';
import 'package:metrixvox_admin/models/tenant.dart';
import 'package:metrixvox_admin/services/api_client.dart';

/// Servicio para consultar y gestionar tenants.
class TenantService {
  static String get _base => '${AppConfig.apiBaseUrl}/api/v1/admin/tenants';

  static Future<List<Tenant>> list(String token) async {
    final api = ApiClient(token: token);
    final json = await api.get(_base);

    if (json == null) return [];

    List<dynamic> raw;
    if (json is List) {
      raw = json;
    } else if (json is Map && json['value'] is List) {
      raw = json['value'] as List<dynamic>;
    } else {
      return [];
    }

    return raw.map((t) => Tenant.fromJson(t as Map<String, dynamic>)).toList();
  }

  static Future<Tenant> create({
    required String token,
    required String tenantId,
    required String displayName,
    String? contactEmail,
  }) async {
    final api = ApiClient(token: token);
    final json = await api.post(_base, body: {
      'tenantId': tenantId,
      'displayName': displayName,
      'contactEmail': contactEmail,
    });
    return Tenant.fromJson(json as Map<String, dynamic>);
  }

  static Future<void> update({
    required String token,
    required String id,
    required String displayName,
    String? contactEmail,
    required bool isActive,
  }) async {
    final api = ApiClient(token: token);
    await api.put('$_base/$id', body: {
      'displayName': displayName,
      'contactEmail': contactEmail,
      'isActive': isActive,
    });
  }

  static Future<void> delete({
    required String token,
    required String id,
  }) async {
    final api = ApiClient(token: token);
    await api.delete('$_base/$id');
  }
}
