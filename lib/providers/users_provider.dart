import 'package:flutter/foundation.dart';
import 'package:metrixvox_admin/models/admin_user.dart';
import 'package:metrixvox_admin/services/user_service.dart';

class UsersProvider extends ChangeNotifier {
  List<AdminUser> _users = [];
  bool _isLoading = false;
  String? _error;

  List<AdminUser> get users => _users;
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
      _users = await UserService.list(token: token, tenantId: tenantId);
    } catch (e) {
      _error = e.toString();
      _users = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> create({
    required String token,
    required String tenantId,
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    await UserService.create(
      token: token,
      tenantId: tenantId,
      email: email,
      password: password,
      fullName: fullName,
      role: role,
    );
    await load(token: token, tenantId: tenantId);
  }

  Future<void> update({
    required String token,
    required String tenantId,
    required String id,
    required String fullName,
    required String role,
    required bool isActive,
  }) async {
    await UserService.update(
      token: token,
      tenantId: tenantId,
      id: id,
      fullName: fullName,
      role: role,
      isActive: isActive,
    );
    await load(token: token, tenantId: tenantId);
  }

  Future<void> resetPassword({
    required String token,
    required String tenantId,
    required String id,
    required String newPassword,
  }) async {
    await UserService.resetPassword(
      token: token,
      tenantId: tenantId,
      id: id,
      newPassword: newPassword,
    );
  }

  void clear() {
    _users = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
