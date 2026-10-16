import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/models/tenant.dart';
import 'package:metrixvox_admin/services/tenant_service.dart';

enum TenantFormMode { create, edit }

class TenantFormDialog extends StatefulWidget {
  final TenantFormMode mode;
  final String token;
  final Tenant? tenant;

  const TenantFormDialog({
    super.key,
    required this.mode,
    required this.token,
    this.tenant,
  });

  @override
  State<TenantFormDialog> createState() => _TenantFormDialogState();
}

class _TenantFormDialogState extends State<TenantFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tenantIdController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late bool _isActive;

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tenantIdController =
        TextEditingController(text: widget.tenant?.tenantId ?? '');
    _nameController = TextEditingController(text: widget.tenant?.name ?? '');
    _emailController =
        TextEditingController(text: widget.tenant?.contactEmail ?? '');
    _isActive = widget.tenant?.isActive ?? true;
  }

  @override
  void dispose() {
    _tenantIdController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (widget.mode == TenantFormMode.create) {
        await TenantService.create(
          token: widget.token,
          tenantId: _tenantIdController.text.trim(),
          displayName: _nameController.text.trim(),
          contactEmail: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
        );
      } else {
        await TenantService.update(
          token: widget.token,
          id: widget.tenant!.id,
          displayName: _nameController.text.trim(),
          contactEmail: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
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
    final isCreate = widget.mode == TenantFormMode.create;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isCreate ? 'Nuevo cliente' : 'Editar cliente'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tenantIdController,
                enabled: isCreate,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Código del cliente (TenantId)',
                  hintText: 'Ej. HOSPITAL_SAN_JOSE',
                  prefixIcon: Icon(Icons.tag),
                  helperText: 'Solo mayúsculas, números y _',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requerido';
                  if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                  if (!RegExp(r'^[A-Za-z0-9_]+$').hasMatch(v)) {
                    return 'Solo letras, números y _';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre comercial',
                  hintText: 'Ej. Hospital San José',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email de contacto (opcional)',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              if (!isCreate) ...[
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Cliente activo'),
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
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AdminTheme.rose,
                    ),
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
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(isCreate ? 'Crear cliente' : 'Guardar cambios'),
        ),
      ],
    );
  }
}
