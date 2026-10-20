import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:metrixvox_admin/config/app_config.dart';
import 'package:metrixvox_admin/models/survey_question.dart';
import 'package:metrixvox_admin/models/survey_summary.dart';

class SurveyAdminService {
  static String get _base => '${AppConfig.apiBaseUrl}/api/v1/admin/surveys';

  static Future<List<SurveySummary>> list({
    required String token,
    required String tenantId,
  }) async {
    final response = await http.get(
      Uri.parse(_base),
      headers: {
        'Authorization': 'Bearer $token',
        'X-Tenant-Id': tenantId,
      },
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Error al listar encuestas (${response.statusCode})');
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes));

    List<dynamic> raw;
    if (json is List) {
      raw = json;
    } else if (json is Map && json['value'] is List) {
      raw = json['value'] as List<dynamic>;
    } else {
      return [];
    }

    return raw.map((s) => SurveySummary.fromJson(s as Map<String, dynamic>)).toList();
  }

  static Future<SurveyDetail> getByCode({
    required String token,
    required String tenantId,
    required String surveyCode,
  }) async {
    final response = await http.get(
      Uri.parse('$_base/$surveyCode'),
      headers: {
        'Authorization': 'Bearer $token',
        'X-Tenant-Id': tenantId,
      },
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Error al obtener encuesta (${response.statusCode})');
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes));
    return SurveyDetail.fromJson(json as Map<String, dynamic>);
  }

  static Future<SurveyDetail> create({
    required String token,
    required String tenantId,
    required String surveyCode,
    required String surveyTitle,
    required String industryType,
    required String scope,
    required List<SurveySection> sections,
  }) async {
    final body = {
      'surveyCode': surveyCode,
      'surveyTitle': surveyTitle,
      'industryType': industryType,
      'scope': scope,
      'sections': sections
          .map((sec) => {
                'title': sec.sectionName,
                'order': sections.indexOf(sec) + 1,
                'questions': sec.questions
                    .map((q) => q.toJson())
                    .toList(),
              })
          .toList(),
    };

    final response = await http.post(
      Uri.parse(_base),
      headers: {
        'Authorization': 'Bearer $token',
        'X-Tenant-Id': tenantId,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear encuesta (${response.statusCode})');
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes));
    return SurveyDetail.fromJson(json as Map<String, dynamic>);
  }

  static Future<void> delete({
    required String token,
    required String tenantId,
    required String surveyCode,
  }) async {
    final response = await http.delete(
      Uri.parse('$_base/$surveyCode'),
      headers: {
        'Authorization': 'Bearer $token',
        'X-Tenant-Id': tenantId,
      },
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar encuesta (${response.statusCode})');
    }
  }
}
