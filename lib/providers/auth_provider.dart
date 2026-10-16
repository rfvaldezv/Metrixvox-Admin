import 'package:flutter/foundation.dart';
import 'package:metrixvox_admin/models/user.dart';
import 'package:metrixvox_admin/services/auth_service.dart';

/// Estado global de autenticación.
class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  String? _refreshToken;
  bool _isLoading = true;

  User? get user => _user;
  String? get token => _token;
  String? get refreshToken => _refreshToken;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null && _token != null;

  /// Carga la sesión guardada al iniciar la app.
  Future<void> bootstrap() async {
    _isLoading = true;
    notifyListeners();

    final session = await AuthService.loadSession();
    if (session != null) {
      _user = session.user;
      _token = session.token;
      _refreshToken = session.refreshToken;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Login.
  Future<void> login(String email, String password) async {
    final result = await AuthService.login(email, password);
    _user = result.user;
    _token = result.token;
    _refreshToken = result.refreshToken;
    notifyListeners();
  }

  /// Logout.
  Future<void> logout() async {
    if (_token != null) {
      await AuthService.logout(_token!);
    }
    _user = null;
    _token = null;
    _refreshToken = null;
    notifyListeners();
  }
}
