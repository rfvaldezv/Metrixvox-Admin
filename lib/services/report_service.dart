import 'dart:convert';
import 'package:metrixvox_admin/config/app_config.dart';
import 'package:metrixvox_admin/services/api_client.dart';

class ReportService {
  /// Genera el análisis de IA para un periodo. Devuelve el JSON del análisis.
  static Future<Map<String, dynamic>> generateAnalysis({
    required String token,
    required String tenantId,
    required String surveyCode,
    required DateTime dateFrom,
    required DateTime dateTo,
  }) async {
    final api = ApiClient(token: token, tenantId: tenantId);
    
    final json = await api.post(
      '${AppConfig.adminAnalytics}/generate',
      body: {
        'tenantId': tenantId,
        'surveyCode': surveyCode,
        'dateFrom': dateFrom.toUtc().toIso8601String(),
        'dateTo': dateTo.toUtc().toIso8601String(),
      },
    );
    
    return json as Map<String, dynamic>;
  }

  /// Obtiene el historial de análisis guardados para un cliente.
  static Future<List<dynamic>> getHistory({
    required String token,
    required String tenantId,
  }) async {
    final api = ApiClient(token: token, tenantId: tenantId);
    final json = await api.get('${AppConfig.adminAnalytics}/history?tenantId=$tenantId');
    return json as List<dynamic>? ?? [];
  }

  /// Construye la URL para descargar un PDF por su ID de análisis
  static String getPdfUrlById(String id) {
    return '${AppConfig.adminReports}/executive/$id';
  }
}
