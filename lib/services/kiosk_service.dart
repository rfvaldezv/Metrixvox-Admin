import 'package:metrixvox_admin/config/app_config.dart';
import 'package:metrixvox_admin/models/kiosk.dart';
import 'package:metrixvox_admin/services/api_client.dart';

/// Servicio de kioscos contra la API.
class KioskService {
  /// Lista todos los kioscos del tenant activo.
  static Future<List<Kiosk>> list({
    required String token,
    required String tenantId,
  }) async {
    final api = ApiClient(token: token, tenantId: tenantId);
    final json = await api.get(AppConfig.adminKiosks);

    if (json == null) return [];

    // Acepta array directo o envuelto en {value: []}
    List<dynamic> raw;
    if (json is List) {
      raw = json;
    } else if (json is Map && json['value'] is List) {
      raw = json['value'] as List<dynamic>;
    } else {
      return [];
    }

    return raw
        .map((k) => Kiosk.fromJson(k as Map<String, dynamic>))
        .toList();
  }

  /// Crea un kiosco nuevo. Devuelve el resultado con el token generado.
  static Future<CreateKioskResult> create({
    required String token,
    required String tenantId,
    required String name,
    required String branchName,
    required String surveyCode,
  }) async {
    final api = ApiClient(token: token, tenantId: tenantId);

    final json = await api.post(
      AppConfig.adminKiosks,
      body: {
        'name': name,
        'branchName': branchName,
        'surveyCode': surveyCode,
        // Como SuperAdmin, forzamos el tenant correcto
        'tenantIdOverride': tenantId,
      },
    );

    return CreateKioskResult.fromJson(json as Map<String, dynamic>);
  }

  /// Actualiza un kiosco.
  static Future<Kiosk> update({
    required String token,
    required String tenantId,
    required String id,
    required String name,
    required String branchName,
    required String surveyCode,
    required bool isActive,
  }) async {
    final api = ApiClient(token: token, tenantId: tenantId);

    final json = await api.put(
      '${AppConfig.adminKiosks}/$id',
      body: {
        'name': name,
        'branchName': branchName,
        'surveyCode': surveyCode,
        'isActive': isActive,
      },
    );

    return Kiosk.fromJson(json as Map<String, dynamic>);
  }

  /// Soft delete (marca IsActive = false).
  static Future<void> delete({
    required String token,
    required String tenantId,
    required String id,
  }) async {
    final api = ApiClient(token: token, tenantId: tenantId);
    await api.delete('${AppConfig.adminKiosks}/$id');
  }

  /// Genera un código de vinculación (Pairing Code) para la tablet.
  static Future<String> generatePairingCode({
    required String token,
    required String tenantId,
    required String id,
  }) async {
    final api = ApiClient(token: token, tenantId: tenantId);
    final json = await api.post('${AppConfig.adminKiosks}/$id/generate-pairing-code');
    
    if (json is Map && json['pairingCode'] != null) {
      return json['pairingCode'] as String;
    }
    throw Exception('Respuesta del servidor no contiene el código de pairing.');
  }
}
