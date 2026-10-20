import 'package:flutter/foundation.dart';
import 'package:metrixvox_admin/models/survey_summary.dart';
import 'package:metrixvox_admin/services/survey_admin_service.dart';

class SurveysProvider extends ChangeNotifier {
  List<SurveySummary> _surveys = [];
  bool _isLoading = false;
  String? _error;

  List<SurveySummary> get surveys => _surveys;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load({
    required String token,
    required String tenantId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _surveys = await SurveyAdminService.list(token: token, tenantId: tenantId);
    } catch (e) {
      _error = e.toString();
      _surveys = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> delete({
    required String token,
    required String tenantId,
    required String surveyCode,
  }) async {
    await SurveyAdminService.delete(
      token: token,
      tenantId: tenantId,
      surveyCode: surveyCode,
    );
    await load(token: token, tenantId: tenantId);
  }

  void clear() {
    _surveys = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
