import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/models/admin_user.dart';
import 'package:metrixvox_admin/providers/users_provider.dart';

enum UserFormMode { create, edit }

class UserFormDialog extends StatefulWidget {
  final UserFormMode mode;
  final String token;
  final String tenantId;
  final AdminUser? user;

  const UserFormDialog({
    super.key,
    required this.mode,
    required this.token,
    required this.tenantId,
    this.user,
  });

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _nameController;
  late String _role;
  late bool _isActive;

  bool _isLoading = false;
  String? _error;

  // Ahora los valores internos coinciden con el backend, pero mostramos labels amigables
  static const _roles = [
    ('TenantAdmin', 'Corporativo (Administrador)'),
    ('Analyst', 'Analista (Solo lectura)'),
  ];

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _nameController = TextEditingController(text: widget.user?.fullName ?? '');
    
    // Si el usuario actual es SuperAdmin, no debería poder editarse aquí
    _role = widget.user?.role == 'TenantAdmin' ? 'TenantAdmin' : 'Analyst';
    _isActive = widget.user?.isActive ?? true;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = context.read<UsersProvider>();

      if (widget.mode == UserFormMode.create) {
        await provider.create(
          token: widget.token,
          tenantId: widget.tenantId,
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          role: _role,
        );
      } else {
        await provider.update(
          token: widget.token,
          tenantId: widget.tenantId,
          id: widget.user!.id,
          fullName: _nameController.text.trim(),
          role: _role,
          isActive: _isActive,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreate = widget.mode == UserFormMode.create;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isCreate ? 'Nuevo usuario' : 'Editar usuario'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                enabled: isCreate,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requerido';
                  if (!v.contains('@')) return 'Correo inválido';
                  return null;
                },
              ),
              if (isCreate) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña temporal',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                ),
                items: _roles
                    .map((r) => DropdownMenuItem(value: r.$1, child: Text(r.$2)))
                    .toList(),
                onChanged: (v) => setState(() => _role = v ?? 'Analyst'),
              ),
              if (!isCreate) ...[
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Usuario activo'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AdminTheme.rose.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AdminTheme.rose),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(isCreate ? 'Crear usuario' : 'Guardar cambios'),
        ),
      ],
    );
  }
}
