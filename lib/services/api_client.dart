import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:metrixvox_admin/config/app_config.dart';

/// Excepción genérica de la API.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Cliente HTTP base para la API de MetrixVox.
/// Maneja el token JWT automáticamente en cada request.
class ApiClient {
  final String? _token;
  final String? _tenantId;

  ApiClient({String? token, String? tenantId})
      : _token = token,
        _tenantId = tenantId;

  /// GET
  Future<dynamic> get(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Tiempo de espera agotado. Verifica tu conexión.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Error de conexión: $e');
    }
  }

  /// POST
  Future<dynamic> post(String url, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Tiempo de espera agotado. Verifica tu conexión.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Error de conexión: $e');
    }
  }

  /// PUT
  Future<dynamic> put(String url, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Tiempo de espera agotado. Verifica tu conexión.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Error de conexión: $e');
    }
  }

  /// DELETE
  Future<dynamic> delete(String url) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: _headers,
      ).timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Tiempo de espera agotado. Verifica tu conexión.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Error de conexión: $e');
    }
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    if (_tenantId != null && _tenantId!.isNotEmpty) {
      headers['X-Tenant-Id'] = _tenantId!;
    }
    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    // Status 2xx → devolver body parseado (o null si vacío)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {
        return response.body;
      }
    }

    // Errores específicos
    String errorMsg;
    try {
      final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
      errorMsg = errorBody['error'] ?? errorBody['message'] ?? 'Error desconocido';
    } catch (_) {
      errorMsg = 'Error del servidor (${response.statusCode})';
    }

    switch (response.statusCode) {
      case 400:
        throw ApiException(errorMsg, statusCode: 400);
      case 401:
        throw ApiException('Sesión expirada o credenciales inválidas.',
            statusCode: 401);
      case 403:
        throw ApiException('No tienes permisos para esta acción.',
            statusCode: 403);
      case 404:
        throw ApiException(errorMsg, statusCode: 404);
      case 500:
        throw ApiException('Error del servidor: $errorMsg', statusCode: 500);
      default:
        throw ApiException(
          '$errorMsg (${response.statusCode})',
          statusCode: response.statusCode,
        );
    }
  }
}
