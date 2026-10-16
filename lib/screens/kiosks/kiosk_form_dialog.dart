import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/models/kiosk.dart';
import 'package:metrixvox_admin/providers/kiosks_provider.dart';

enum KioskFormMode { create, edit }

class KioskFormDialog extends StatefulWidget {
  final KioskFormMode mode;
  final String token;
  final String tenantId;
  final Kiosk? kiosk;

  const KioskFormDialog({
    super.key,
    required this.mode,
    required this.token,
    required this.tenantId,
    this.kiosk,
  });

  @override
  State<KioskFormDialog> createState() => _KioskFormDialogState();
}

class _KioskFormDialogState extends State<KioskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _branchController;
  late TextEditingController _surveyController;
  late bool _isActive;

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.kiosk?.name ?? '');
    _branchController =
        TextEditingController(text: widget.kiosk?.branchName ?? '');
    _surveyController = TextEditingController(
      text: widget.kiosk?.surveyCode ?? 'SURVEY_HOSPITAL_01',
    );
    _isActive = widget.kiosk?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _branchController.dispose();
    _surveyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = context.read<KiosksProvider>();

      if (widget.mode == KioskFormMode.create) {
        final result = await provider.create(
          token: widget.token,
          tenantId: widget.tenantId,
          name: _nameController.text.trim(),
          branchName: _branchController.text.trim(),
          surveyCode: _surveyController.text.trim(),
        );
        if (!mounted) return;
        Navigator.pop(context, result);
      } else {
        await provider.update(
          token: widget.token,
          tenantId: widget.tenantId,
          id: widget.kiosk!.id,
          name: _nameController.text.trim(),
          branchName: _branchController.text.trim(),
          surveyCode: _surveyController.text.trim(),
          isActive: _isActive,
        );
        if (!mounted) return;
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreate = widget.mode == KioskFormMode.create;

    return AlertDialog(
      title: Text(isCreate ? 'Nuevo kiosco' : 'Editar kiosco'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  labelText: 'Nombre del kiosco',
                  hintText: 'Ej. Sucursal Centro 1',
                  prefixIcon: Icon(Icons.desktop_windows_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _branchController,
                decoration: const InputDecoration(
                  labelText: 'Sucursal',
                  hintText: 'Ej. Sucursal Centro',
                  prefixIcon: Icon(Icons.store_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _surveyController,
                decoration: const InputDecoration(
                  labelText: 'Código de encuesta',
                  hintText: 'Ej. SURVEY_HOSPITAL_01',
                  prefixIcon: Icon(Icons.assignment_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              if (!isCreate) ...[
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Kiosco activo'),
                  subtitle: const Text(
                    'Si está desactivado, no podrá capturar encuestas',
                  ),
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
          onPressed: _isLoading ? null : () => Navigator.pop(context),
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
              : Text(isCreate ? 'Crear kiosco' : 'Guardar cambios'),
        ),
      ],
    );
  }
}
