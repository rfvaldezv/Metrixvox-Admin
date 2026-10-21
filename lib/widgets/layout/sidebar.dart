import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/providers/auth_provider.dart';
import 'package:metrixvox_admin/widgets/metrix_logo.dart';

class AdminSidebar extends StatelessWidget {
  final bool isDrawer;

  const AdminSidebar({super.key, this.isDrawer = false});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    // Lógica de Roles
    final isSuperAdmin = user?.role == 'SuperAdmin';
    final isTenantAdmin = user?.role == 'TenantAdmin'; // Corporativo
    final isAnalyst = user?.role == 'Analyst';
    
    // Permisos (Corporativo y SuperAdmin pueden crear; Analistas no)
    final canManage = isSuperAdmin || isTenantAdmin;

    return Container(
      width: 240,
      decoration: const BoxDecoration(gradient: AdminTheme.brandGradient),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: MetrixLogo(size: 32, showText: true, forceColor: Colors.white, textColor: Colors.white),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _SidebarItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Inicio', route: '/dashboard', isActive: currentRoute.startsWith('/dashboard')),
                  
                  // Solo Admin y Corporativo ven Kioscos y Encuestas
                  if (canManage) ...[
                    _SidebarItem(icon: Icons.desktop_windows_outlined, activeIcon: Icons.desktop_windows, label: 'Kioscos', route: '/kiosks', isActive: currentRoute.startsWith('/kiosks')),
                    _SidebarItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment, label: 'Encuestas', route: '/surveys', isActive: currentRoute.startsWith('/surveys')),
                  ],

                  // Todos ven Respuestas y Reportes IA
                  _SidebarItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment, label: 'Respuestas', route: '/responses', isActive: currentRoute.startsWith('/responses')),
                  _SidebarItem(icon: Icons.analytics_outlined, activeIcon: Icons.analytics, label: 'Reportes IA', route: '/reports', isActive: currentRoute.startsWith('/reports')),

                  // Solo SuperAdmin ve Clientes y Usuarios
                  if (isSuperAdmin) ...[
                    _SidebarItem(icon: Icons.business_outlined, activeIcon: Icons.business, label: 'Clientes', route: '/tenants', isActive: currentRoute.startsWith('/tenants')),
                    _SidebarItem(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Usuarios', route: '/users', isActive: currentRoute.startsWith('/users')),
                  ],
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.fullName ?? '', style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(user?.roleLabel ?? '', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white.withOpacity(0.7))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final bool isActive;

  const _SidebarItem({required this.icon, required this.activeIcon, required this.label, required this.route, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            // Si estamos en un Drawer (móvil), lo cerramos al navegar
            if (Scaffold.of(context).hasDrawer) Navigator.pop(context);
            context.go(route);
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(isActive ? activeIcon : icon, size: 20, color: Colors.white),
                const SizedBox(width: 14),
                Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: isActive ? FontWeight.w600 : FontWeight.w500, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
