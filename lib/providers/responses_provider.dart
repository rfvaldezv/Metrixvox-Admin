import 'package:flutter/foundation.dart';
import 'package:metrixvox_admin/models/survey_response.dart';
import 'package:metrixvox_admin/services/response_service.dart';

class ResponsesProvider extends ChangeNotifier {
  List<SurveyResponse> _responses = [];
  bool _isLoading = false;
  String? _error;

  List<SurveyResponse> get responses => _responses;
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
      _responses = await ResponseService.list(
        token: token,
        tenantId: tenantId,
      );
    } catch (e) {
      _error = e.toString();
      _responses = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _responses = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
