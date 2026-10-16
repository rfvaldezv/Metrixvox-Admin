import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/providers/auth_provider.dart';
import 'package:metrixvox_admin/providers/tenant_provider.dart';

/// Barra superior de la app con selector de tenant + usuario.
class AdminTopbar extends StatelessWidget {
  const AdminTopbar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final tenants = context.watch<TenantProvider>();

    return Container(
      height: 70,
      color: Colors.white,
      child: Row(
        children: [
          const SizedBox(width: 32),

          // Título
          const Text(
            'Panel de Administración',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AdminTheme.dark,
            ),
          ),

          const SizedBox(width: 32),

          // Selector de tenant (solo si hay tenants cargados)
          if (tenants.tenants.isNotEmpty) const _TenantSelector(),

          const Spacer(),

          // Notificaciones
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: 'Notificaciones',
            color: AdminTheme.gray,
          ),

          const SizedBox(width: 8),

          // Usuario + menú
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AdminTheme.indigo.withOpacity(0.15),
                    child: Text(
                      _initials(user?.fullName ?? '??'),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AdminTheme.indigo,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    user?.fullName.split(' ').first ?? 'Usuario',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AdminTheme.dark,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: AdminTheme.gray,
                  ),
                ],
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? '',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AdminTheme.dark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: AdminTheme.gray,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: AdminTheme.rose),
                    SizedBox(width: 10),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthProvider>().logout();
              }
            },
          ),

          const SizedBox(width: 16),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '??';
    if (parts.length == 1) return parts.first.substring(0, 2).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

/// Selector de tenant activo (dropdown en el topbar).
class _TenantSelector extends StatelessWidget {
  const _TenantSelector();

  @override
  Widget build(BuildContext context) {
    final tenants = context.watch<TenantProvider>();
    final selected = tenants.selected;

    if (selected == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AdminTheme.lightGray,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12, right: 4),
            child: Icon(
              Icons.business_outlined,
              size: 18,
              color: AdminTheme.indigo,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Cliente:',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AdminTheme.gray,
              ),
            ),
          ),
          DropdownButton<String>(
            value: selected.tenantId,
            underline: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(10),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            items: tenants.tenants
                .map((t) => DropdownMenuItem<String>(
                      value: t.tenantId,
                      child: Text(
                        t.name,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AdminTheme.dark,
                        ),
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              final tenant =
                  tenants.tenants.firstWhere((t) => t.tenantId == value);
              context.read<TenantProvider>().selectTenant(tenant);
            },
          ),
        ],
      ),
    );
  }
}
