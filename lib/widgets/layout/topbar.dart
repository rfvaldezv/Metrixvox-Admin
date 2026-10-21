import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/providers/auth_provider.dart';
import 'package:metrixvox_admin/providers/tenant_provider.dart';

class AdminTopbar extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const AdminTopbar({super.key, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final tenants = context.watch<TenantProvider>();

    // Iniciales del usuario
    String initials = 'U';
    if (user != null && user.fullName.isNotEmpty) {
      final parts = user.fullName.trim().split(' ');
      if (parts.length > 1) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = parts[0][0].toUpperCase();
      }
    }

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Row(
        children: [
          // Si es móvil, mostramos el botón de hamburguesa
          if (scaffoldKey != null) ...[
            IconButton(
              icon: const Icon(Icons.menu, color: AdminTheme.dark),
              onPressed: () => scaffoldKey!.currentState?.openDrawer(),
            ),
            const SizedBox(width: 8),
          ],

          // Título (solo en PC)
          if (scaffoldKey == null)
            const Text(
              'Panel de Administración',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AdminTheme.dark,
              ),
            ),

          const Spacer(),

          // Selector de tenant
          if (tenants.tenants.isNotEmpty)
            const _TenantSelector(),

          const SizedBox(width: 16),

          // Perfil de usuario
          PopupMenuButton(
            icon: CircleAvatar(
              backgroundColor: AdminTheme.indigo.withOpacity(0.1),
              child: Text(
                initials,
                style: const TextStyle(color: AdminTheme.indigo, fontWeight: FontWeight.bold),
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.logout, color: AdminTheme.rose),
                  title: const Text('Cerrar sesión'),
                  onTap: () => context.read<AuthProvider>().logout(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TenantSelector extends StatelessWidget {
  const _TenantSelector();

  @override
  Widget build(BuildContext context) {
    final tenants = context.watch<TenantProvider>();
    final selected = tenants.selected;
    if (selected == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AdminTheme.lightGray,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected.tenantId,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AdminTheme.dark),
          items: tenants.tenants.map((t) {
            return DropdownMenuItem(
              value: t.tenantId,
              child: Row(
                children: [
                  const Icon(Icons.business, size: 16, color: AdminTheme.gray),
                  const SizedBox(width: 8),
                  Text(t.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              final t = tenants.tenants.firstWhere((t) => t.tenantId == val);
              tenants.selectTenant(t);
            }
          },
        ),
      ),
    );
  }
}
