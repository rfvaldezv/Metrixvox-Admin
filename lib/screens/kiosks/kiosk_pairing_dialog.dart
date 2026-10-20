import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/providers/auth_provider.dart';
import 'package:metrixvox_admin/providers/kiosks_provider.dart';
import 'package:metrixvox_admin/providers/tenant_provider.dart';

class KioskPairingDialog extends StatefulWidget {
  final String kioskId;
  final String kioskName;

  const KioskPairingDialog({
    super.key,
    required this.kioskId,
    required this.kioskName,
  });

  @override
  State<KioskPairingDialog> createState() => _KioskPairingDialogState();
}

class _KioskPairingDialogState extends State<KioskPairingDialog> {
  bool _isLoading = true;
  bool _copied = false;
  String? _error;
  String? _pairingCode;

  @override
  void initState() {
    super.initState();
    _generateCode();
  }

  Future<void> _generateCode() async {
    try {
      final auth = context.read<AuthProvider>();
      final tenant = context.read<TenantProvider>().selected;
      
      if (auth.token == null || tenant == null) {
        throw Exception('No hay sesión o cliente activo.');
      }

      final code = await context.read<KiosksProvider>().generatePairingCode(
            token: auth.token!,
            tenantId: tenant.tenantId,
            id: widget.kioskId,
          );

      if (mounted) {
        setState(() {
          _pairingCode = code;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _copyToClipboard() {
    if (_pairingCode == null) return;
    Clipboard.setData(ClipboardData(text: _pairingCode!));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(32),
        child: _isLoading
            ? const SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Generando código...'),
                    ],
                  ),
                ),
              )
            : _error != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: AdminTheme.rose, size: 48),
                      const SizedBox(height: 16),
                      Text('Error: $_error', textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AdminTheme.indigo.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.pin_outlined, size: 40, color: AdminTheme.indigo),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Código de Vinculación',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AdminTheme.dark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Para: ${widget.kioskName}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AdminTheme.gray,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Ingresa este código en la tablet del kiosco.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AdminTheme.gray,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _copyToClipboard,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                          decoration: BoxDecoration(
                            color: AdminTheme.dark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _pairingCode ?? '------',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _copyToClipboard,
                        icon: Icon(
                          _copied ? Icons.check_circle : Icons.copy,
                          size: 18,
                          color: _copied ? AdminTheme.emerald : AdminTheme.indigo,
                        ),
                        label: Text(
                          _copied ? '¡Copiado al portapapeles!' : 'Copiar código',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            color: _copied ? AdminTheme.emerald : AdminTheme.indigo,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 20, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Este código expira en 15 minutos y solo puede usarse una vez.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Entendido'),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
