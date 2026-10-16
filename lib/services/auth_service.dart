import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metrixvox_admin/config/app_config.dart';
import 'package:metrixvox_admin/models/user.dart';
import 'package:metrixvox_admin/services/api_client.dart';

/// Resultado del login/refresh.
class AuthResult {
  final String token;
  final String refreshToken;
  final DateTime expiresAt;
  final User user;

  AuthResult({
    required this.token,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
        token: json['token'] as String? ?? '',
        refreshToken: json['refreshToken'] as String? ?? '',
        expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? '') ??
            DateTime.now().add(const Duration(hours: 1)),
        user: User.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      );
}

/// Servicio de autenticación con la API.
class AuthService {
  /// Login con email + password.
  static Future<AuthResult> login(String email, String password) async {
    final api = ApiClient(); // Sin token, es público

    final json = await api.post(
      AppConfig.authLogin,
      body: {'email': email, 'password': password},
    );

    if (json == null || json['token'] == null) {
      throw ApiException('Respuesta del servidor inválida.');
    }

    final result = AuthResult.fromJson(json as Map<String, dynamic>);

    // Persistir tokens y usuario
    await _saveAuth(result);

    return result;
  }

  /// Refresh del token usando el refresh token.
  static Future<AuthResult> refresh(String refreshToken) async {
    final api = ApiClient();

    final json = await api.post(
      AppConfig.authRefresh,
      body: {'refreshToken': refreshToken},
    );

    final result = AuthResult.fromJson(json as Map<String, dynamic>);
    await _saveAuth(result);
    return result;
  }

  /// Logout: invalida el refresh token y limpia storage.
  static Future<void> logout(String token) async {
    try {
      final api = ApiClient(token: token);
      await api.post(AppConfig.authLogout);
    } catch (_) {
      // Ignorar errores al hacer logout
    }
    await clearStorage();
  }

  /// Carga la sesión guardada (si existe).
  static Future<AuthResult?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConfig.storageKeyToken);
    final refreshToken = prefs.getString(AppConfig.storageKeyRefreshToken);
    final userJson = prefs.getString(AppConfig.storageKeyUser);

    if (token == null || refreshToken == null || userJson == null) {
      return null;
    }

    try {
      final user = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      return AuthResult(
        token: token,
        refreshToken: refreshToken,
        expiresAt: DateTime.now(),
        user: user,
      );
    } catch (_) {
      return null;
    }
  }

  /// Limpia todo el storage de auth.
  static Future<void> clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.storageKeyToken);
    await prefs.remove(AppConfig.storageKeyRefreshToken);
    await prefs.remove(AppConfig.storageKeyUser);
  }

  static Future<void> _saveAuth(AuthResult result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.storageKeyToken, result.token);
    await prefs.setString(AppConfig.storageKeyRefreshToken, result.refreshToken);
    await prefs.setString(AppConfig.storageKeyUser, jsonEncode(result.user.toJson()));
  }
}
