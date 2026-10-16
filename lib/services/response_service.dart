import 'package:metrixvox_admin/models/survey_response.dart';
import 'package:metrixvox_admin/services/api_client.dart';

class ResponseService {
  static Future<List<SurveyResponse>> list({
    required String token,
    required String tenantId,
    int limit = 100,
  }) async {
    final api = ApiClient(token: token, tenantId: tenantId);
    final json = await api.get('${_baseUrl()}/api/v1/admin/responses?limit=$limit');

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
        .map((r) => SurveyResponse.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  static String _baseUrl() {
    const url = String.fromEnvironment(
      'API_URL',
      defaultValue: 'https://api.metrixvox.com',
    );
    return url;
  }
}
