import 'package:metrixvox_admin/models/admin_user.dart';
import 'package:metrixvox_admin/services/api_client.dart';

class UserService {
  static const String _baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.metrixvox.com',
  );

  static Future<List<AdminUser>> list({
    required String token,
    required String tenantId,
  }) async {
    final api = ApiClient(token: token, tenantId: tenantId);
    final json = await api.get('$_baseUrl/api/v1/admin/users');

    if (json == null) return [];

    List<dynamic> raw;
    if (json is List) {
      raw = json;
    } else if (json is Map && json['value'] is List) {
      raw = json['value'] as List<dynamic>;
    } else {
      return [];
    }

    return raw
        .map((u) => AdminUser.fromJson(u as Map<String, dynamic>))
        .toList();
  }

  static Future<void> create({
    required String token,
    required String tenantId,
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    final api = ApiClient(token: token, tenantId: tenantId);
    await api.post(
      '$_baseUrl/api/v1/admin/users',
      body: {
        'email': email,
        'password': password,
        'fullName': fullName,
        'role': role,
      },
    );
  }

  static Future<void> update({
    required String token,
    required String tenantId,
    required String id,
    required String fullName,
    required String role,
    required bool isActive,
  }) async {
    final api = ApiClient(token: token, tenantId: tenantId);
    await api.put(
      '$_baseUrl/api/v1/admin/users/$id',
      body: {
        'fullName': fullName,
        'role': role,
        'isActive': isActive,
      },
    );
  }

  static Future<void> resetPassword({
    required String token,
    required String tenantId,
    required String id,
    required String newPassword,
  }) async {
    final api = ApiClient(token: token, tenantId: tenantId);
    await api.post(
      '$_baseUrl/api/v1/admin/users/$id/reset-password',
      body: {'newPassword': newPassword},
    );
  }
}
