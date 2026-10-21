import 'package:flutter/material.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/widgets/layout/sidebar.dart';
import 'package:metrixvox_admin/widgets/layout/topbar.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Si el ancho es menor a 900px, es un celular o tablet pequeña
        final isMobile = constraints.maxWidth < 900;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AdminTheme.lightGray,
          // En móvil, el menú se abre como un Drawer
          drawer: isMobile
              ? const Drawer(
                  child: AdminSidebar(isDrawer: true),
                )
              : null,
          body: Row(
            children: [
              // Sidebar fijo SOLO en PC
              if (!isMobile) const AdminSidebar(),

              // Contenido principal
              Expanded(
                child: Column(
                  children: [
                    // Topbar (le pasamos la llave para el botón de hamburguesa)
                    AdminTopbar(scaffoldKey: isMobile ? _scaffoldKey : null),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(isMobile ? 0 : 16),
                        ),
                        child: Container(
                          color: Colors.white,
                          child: widget.child,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
