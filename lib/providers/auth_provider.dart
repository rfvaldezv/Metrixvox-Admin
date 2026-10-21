import 'package:flutter/foundation.dart';
import 'package:metrixvox_admin/models/user.dart';
import 'package:metrixvox_admin/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;

  Future<void> bootstrap() async {
    // Como no tienes tryAutoLogin, por ahora no hacemos nada aquí.
    // La sesión se maneja al hacer login manual.
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AuthService.login(email, password);
      _token = result.token;
      _user = result.user;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      try {
        await AuthService.logout(_token!);
      } catch (_) {
        // Ignorar errores al hacer logout
      }
    }
    _token = null;
    _user = null;
    notifyListeners();
  }

  void handleUnauthorized() {
    _token = null;
    _user = null;
    notifyListeners();
  }
}
