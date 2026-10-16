import 'package:flutter/material.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/widgets/layout/sidebar.dart';
import 'package:metrixvox_admin/widgets/layout/topbar.dart';

/// Shell principal de la app: sidebar + topbar + contenido.
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.lightGray,
      body: Row(
        children: [
          // Sidebar fijo a la izquierda
          const AdminSidebar(),

          // Columna derecha: topbar + contenido
          Expanded(
            child: Column(
              children: [
                const AdminTopbar(),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                    ),
                    child: Container(
                      color: Colors.white,
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
