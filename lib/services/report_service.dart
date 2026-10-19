// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:metrixvox_admin/config/app_config.dart';

/// Servicio para descargar reportes PDF generados por el backend.
class ReportService {
  static Future<void> downloadExecutiveReport({
    required String token,
    required String tenantId,
  }) async {
    final uri = Uri.parse(
      '${AppConfig.apiBaseUrl}/api/v1/admin/reports/executive',
    );

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'X-Tenant-Id': tenantId,
    });

    if (response.statusCode != 200) {
      throw Exception(
        'Error al generar reporte (código ${response.statusCode})',
      );
    }

    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final filename = 'Reporte_${tenantId}_$dateStr.pdf';

    _triggerDownload(response.bodyBytes, filename);
  }

  static void _triggerDownload(Uint8List bytes, String filename) {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..download = filename
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}
