import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metrixvox_admin/config/theme.dart';

/// Diálogo que muestra el token del kiosco y permite copiarlo.
class KioskTokenDialog extends StatelessWidget {
  final String kioskName;
  final String kioskToken;

  const KioskTokenDialog({
    super.key,
    required this.kioskName,
    required this.kioskToken,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Token del kiosco'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Configura este token en la terminal del kiosco.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AdminTheme.gray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              kioskName,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AdminTheme.dark,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AdminTheme.lightGray,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AdminTheme.border),
              ),
              child: SelectableText(
                kioskToken,
                style: const TextStyle(
                  fontFamily: 'Courier New',
                  fontSize: 14,
                  color: AdminTheme.dark,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '⚠️ Guarda este token en un lugar seguro.\n'
              'Lo necesitarás para configurar el kiosco.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AdminTheme.gray,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: kioskToken));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Token copiado al portapapeles')),
              );
            }
          },
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Copiar token'),
        ),
      ],
    );
  }
}
