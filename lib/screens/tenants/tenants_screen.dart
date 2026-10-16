import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/models/tenant.dart';
import 'package:metrixvox_admin/providers/auth_provider.dart';
import 'package:metrixvox_admin/providers/tenant_provider.dart';
import 'package:metrixvox_admin/screens/tenants/tenant_form_dialog.dart';
import 'package:metrixvox_admin/services/tenant_service.dart';

class TenantsScreen extends StatefulWidget {
  const TenantsScreen({super.key});

  @override
  State<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends State<TenantsScreen> {
  List<Tenant> _tenants = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tenants = await TenantService.list(token);
      if (!mounted) return;
      setState(() {
        _tenants = tenants;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _create() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => TenantFormDialog(
        mode: TenantFormMode.create,
        token: token,
      ),
    );

    if (ok == true && mounted) {
      _load();
      // Recargar el dropdown del topbar
      context.read<TenantProvider>().loadTenants(token);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente creado')),
      );
    }
  }

  Future<void> _edit(Tenant tenant) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => TenantFormDialog(
        mode: TenantFormMode.edit,
        token: token,
        tenant: tenant,
      ),
    );

    if (ok == true && mounted) {
      _load();
      context.read<TenantProvider>().loadTenants(token);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente actualizado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _searchQuery.isEmpty
        ? _tenants
        : _tenants.where((t) {
            final q = _searchQuery.toLowerCase();
            return t.name.toLowerCase().contains(q) ||
                t.tenantId.toLowerCase().contains(q);
          }).toList();

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
                      'Clientes',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AdminTheme.dark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${filtered.length} cliente(s) en la plataforma',
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
                onPressed: _create,
                icon: const Icon(Icons.add_business),
                label: const Text('Nuevo cliente'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar por nombre o código...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AdminTheme.rose),
                        ),
                      )
                    : filtered.isEmpty
                        ? const Center(
                            child: Text(
                              'Sin clientes',
                              style: TextStyle(color: AdminTheme.gray),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final tenant = filtered[index];
                              return _TenantCard(
                                tenant: tenant,
                                onEdit: () => _edit(tenant),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _TenantCard extends StatelessWidget {
  final Tenant tenant;
  final VoidCallback onEdit;

  const _TenantCard({required this.tenant, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final created = tenant.createdAt != null
        ? DateFormat('dd/MM/yyyy').format(tenant.createdAt!)
        : '—';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tenant.isActive
                  ? AdminTheme.indigo.withOpacity(0.12)
                  : AdminTheme.gray.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.business,
              color: tenant.isActive ? AdminTheme.indigo : AdminTheme.gray,
              size: 24,
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
                        tenant.name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AdminTheme.dark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!tenant.isActive) const _InactiveBadge(),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      tenant.tenantId,
                      style: const TextStyle(
                        fontFamily: 'Courier New',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AdminTheme.gray,
                      ),
                    ),
                    if (tenant.contactEmail != null) ...[
                      const Text(' · ',
                          style: TextStyle(color: AdminTheme.gray)),
                      Flexible(
                        child: Text(
                          tenant.contactEmail!,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AdminTheme.gray,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Creado: $created',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AdminTheme.gray.withOpacity(0.7),
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
