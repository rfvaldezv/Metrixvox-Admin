import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/models/admin_user.dart';
import 'package:metrixvox_admin/providers/auth_provider.dart';
import 'package:metrixvox_admin/providers/tenant_provider.dart';
import 'package:metrixvox_admin/providers/users_provider.dart';
import 'package:metrixvox_admin/screens/users/user_form_dialog.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String? _loadedTenantId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadIfNeeded();
  }

  void _loadIfNeeded() {
    final auth = context.watch<AuthProvider>();
    final tenant = context.watch<TenantProvider>().selected;

    if (auth.token != null &&
        tenant != null &&
        tenant.tenantId != _loadedTenantId) {
      _loadedTenantId = tenant.tenantId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<UsersProvider>().load(
              token: auth.token!,
              tenantId: tenant.tenantId,
            );
      });
    }
  }

  Future<void> _createUser() async {
    final auth = context.read<AuthProvider>();
    final tenant = context.read<TenantProvider>().selected;
    if (auth.token == null || tenant == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => UserFormDialog(
        mode: UserFormMode.create,
        token: auth.token!,
        tenantId: tenant.tenantId,
      ),
    );

    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario creado')),
      );
    }
  }

  Future<void> _editUser(AdminUser user) async {
    final auth = context.read<AuthProvider>();
    final tenant = context.read<TenantProvider>().selected;
    if (auth.token == null || tenant == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => UserFormDialog(
        mode: UserFormMode.edit,
        token: auth.token!,
        tenantId: tenant.tenantId,
        user: user,
      ),
    );

    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario actualizado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UsersProvider>();
    final tenant = context.watch<TenantProvider>().selected;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Usuarios',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AdminTheme.dark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tenant == null
                          ? 'Selecciona un cliente'
                          : 'Cliente: ${tenant.name}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AdminTheme.gray,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: tenant == null ? null : _createUser,
                icon: const Icon(Icons.person_add),
                label: const Text('Nuevo usuario'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                    ? Center(
                        child: Text(
                          provider.error!,
                          style: const TextStyle(color: AdminTheme.rose),
                        ),
                      )
                    : provider.users.isEmpty
                        ? const Center(
                            child: Text(
                              'Sin usuarios',
                              style: TextStyle(color: AdminTheme.gray),
                            ),
                          )
                        : ListView.separated(
                            itemCount: provider.users.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final user = provider.users[index];
                              return _UserCard(
                                user: user,
                                onEdit: () => _editUser(user),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AdminUser user;
  final VoidCallback onEdit;

  const _UserCard({required this.user, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final dt = user.lastLoginAt != null
        ? 'Último acceso: ${DateFormat('dd/MM/yyyy HH:mm').format(user.lastLoginAt!)}'
        : 'Nunca ha iniciado sesión';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AdminTheme.indigo.withOpacity(0.15),
            child: Text(
              _initials(user.fullName),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AdminTheme.indigo,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.fullName,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AdminTheme.dark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _RoleBadge(role: user.role),
                    if (!user.isActive) ...[
                      const SizedBox(width: 6),
                      const _InactiveBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AdminTheme.gray,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dt,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AdminTheme.gray.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: onEdit,
            color: AdminTheme.gray,
          ),
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

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (role) {
      'SuperAdmin' => (AdminTheme.rose, 'Super Admin'),
      'TenantAdmin' => (AdminTheme.indigo, 'Admin'),
      'Analyst' => (AdminTheme.sky, 'Analista'),
      'Viewer' => (AdminTheme.gray, 'Visualizador'),
      _ => (AdminTheme.gray, role),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _InactiveBadge extends StatelessWidget {
  const _InactiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AdminTheme.rose.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Inactivo',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AdminTheme.rose,
        ),
      ),
    );
  }
}
