import 'package:flutter/foundation.dart';
import 'package:metrixvox_admin/models/kiosk.dart';
import 'package:metrixvox_admin/services/kiosk_service.dart';

/// Estado global de la lista de kioscos.
class KiosksProvider extends ChangeNotifier {
  List<Kiosk> _kiosks = [];
  bool _isLoading = false;
  String? _error;

  List<Kiosk> get kiosks => _kiosks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carga los kioscos del tenant activo.
  Future<void> load({
    required String token,
    required String tenantId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _kiosks = await KioskService.list(token: token, tenantId: tenantId);
    } catch (e) {
      _error = e.toString();
      _kiosks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crea un kiosco nuevo.
  Future<CreateKioskResult> create({
    required String token,
    required String tenantId,
    required String name,
    required String branchName,
    required String surveyCode,
  }) async {
    final result = await KioskService.create(
      token: token,
      tenantId: tenantId,
      name: name,
      branchName: branchName,
      surveyCode: surveyCode,
    );
    // Recargar la lista
    await load(token: token, tenantId: tenantId);
    return result;
  }

  /// Actualiza un kiosco.
  Future<void> update({
    required String token,
    required String tenantId,
    required String id,
    required String name,
    required String branchName,
    required String surveyCode,
    required bool isActive,
  }) async {
    await KioskService.update(
      token: token,
      tenantId: tenantId,
      id: id,
      name: name,
      branchName: branchName,
      surveyCode: surveyCode,
      isActive: isActive,
    );
    await load(token: token, tenantId: tenantId);
  }

  /// Elimina un kiosco (soft delete).
  Future<void> delete({
    required String token,
    required String tenantId,
    required String id,
  }) async {
    await KioskService.delete(token: token, tenantId: tenantId, id: id);
    await load(token: token, tenantId: tenantId);
  }

  /// Genera el código de vinculación para un kiosco.
  Future<String> generatePairingCode({
    required String token,
    required String tenantId,
    required String id,
  }) async {
    return await KioskService.generatePairingCode(
      token: token,
      tenantId: tenantId,
      id: id,
    );
  }

  void clear() {
    _kiosks = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
