import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/models/kiosk.dart';
import 'package:metrixvox_admin/providers/auth_provider.dart';
import 'package:metrixvox_admin/providers/kiosks_provider.dart';
import 'package:metrixvox_admin/providers/tenant_provider.dart';
import 'package:metrixvox_admin/screens/kiosks/kiosk_form_dialog.dart';
import 'package:metrixvox_admin/screens/kiosks/kiosk_token_dialog.dart';

class KiosksScreen extends StatefulWidget {
  const KiosksScreen({super.key});

  @override
  State<KiosksScreen> createState() => _KiosksScreenState();
}

class _KiosksScreenState extends State<KiosksScreen> {
  String? _loadedTenantId;
  String _searchQuery = '';

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
        context.read<KiosksProvider>().load(
              token: auth.token!,
              tenantId: tenant.tenantId,
            );
      });
    }
  }

  Future<void> _createKiosk() async {
    final auth = context.read<AuthProvider>();
    final tenant = context.read<TenantProvider>().selected;
    if (auth.token == null || tenant == null) return;

    final result = await showDialog<CreateKioskResult>(
      context: context,
      builder: (_) => KioskFormDialog(
        mode: KioskFormMode.create,
        token: auth.token!,
        tenantId: tenant.tenantId,
      ),
    );

    if (result != null && mounted) {
      // Mostrar el token generado
      await showDialog(
        context: context,
        builder: (_) => KioskTokenDialog(
          kioskName: result.kiosk.name,
          kioskToken: result.kioskToken,
        ),
      );
    }
  }

  Future<void> _editKiosk(Kiosk kiosk) async {
    final auth = context.read<AuthProvider>();
    final tenant = context.read<TenantProvider>().selected;
    if (auth.token == null || tenant == null) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => KioskFormDialog(
        mode: KioskFormMode.edit,
        token: auth.token!,
        tenantId: tenant.tenantId,
        kiosk: kiosk,
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kiosco actualizado')),
      );
    }
  }

  Future<void> _deleteKiosk(Kiosk kiosk) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desactivar kiosco'),
        content: Text(
          '¿Desactivar "${kiosk.name}"?\n\n'
          'El kiosco dejará de funcionar y su token quedará inválido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AdminTheme.rose),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final tenant = context.read<TenantProvider>().selected;
    if (auth.token == null || tenant == null) return;

    try {
      await context.read<KiosksProvider>().delete(
            token: auth.token!,
            tenantId: tenant.tenantId,
            id: kiosk.id,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kiosco desactivado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showToken(Kiosk kiosk) {
    showDialog(
      context: context,
      builder: (_) => KioskTokenDialog(
        kioskName: kiosk.name,
        kioskToken: kiosk.kioskToken,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KiosksProvider>();
    final tenant = context.watch<TenantProvider>().selected;

    final filteredKiosks = _searchQuery.isEmpty
        ? provider.kiosks
        : provider.kiosks.where((k) {
            final q = _searchQuery.toLowerCase();
            return k.name.toLowerCase().contains(q) ||
                k.branchName.toLowerCase().contains(q) ||
                k.surveyCode.toLowerCase().contains(q);
          }).toList();

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kioscos',
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
                onPressed: tenant == null ? null : _createKiosk,
                icon: const Icon(Icons.add),
                label: const Text('Nuevo kiosco'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Búsqueda
          TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar por nombre, sucursal o encuesta...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),

          const SizedBox(height: 24),

          // Contenido
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                    ? _ErrorState(
                        error: provider.error!,
                        onRetry: () {
                          final auth = context.read<AuthProvider>();
                          if (auth.token != null && tenant != null) {
                            context.read<KiosksProvider>().load(
                                  token: auth.token!,
                                  tenantId: tenant.tenantId,
                                );
                          }
                        },
                      )
                    : filteredKiosks.isEmpty
                        ? _EmptyState(
                            hasSearch: _searchQuery.isNotEmpty,
                            onCreate: tenant == null ? null : _createKiosk,
                          )
                        : ListView.separated(
                            itemCount: filteredKiosks.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final kiosk = filteredKiosks[index];
                              return _KioskCard(
                                kiosk: kiosk,
                                onEdit: () => _editKiosk(kiosk),
                                onDelete: () => _deleteKiosk(kiosk),
                                onShowToken: () => _showToken(kiosk),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _KioskCard extends StatelessWidget {
  final Kiosk kiosk;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShowToken;

  const _KioskCard({
    required this.kiosk,
    required this.onEdit,
    required this.onDelete,
    required this.onShowToken,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Row(
        children: [
          // Ícono + estado
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: kiosk.isActive
                  ? AdminTheme.emerald.withOpacity(0.12)
                  : AdminTheme.gray.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.desktop_windows,
              color: kiosk.isActive ? AdminTheme.emerald : AdminTheme.gray,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        kiosk.name,
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
                    _StatusBadge(isActive: kiosk.isActive),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${kiosk.branchName} · ${kiosk.surveyCode}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AdminTheme.gray,
                  ),
                ),
              ],
            ),
          ),

          // Acciones
          IconButton(
            icon: const Icon(Icons.key_outlined),
            tooltip: 'Ver token',
            onPressed: onShowToken,
            color: AdminTheme.indigo,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: onEdit,
            color: AdminTheme.gray,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Desactivar',
            onPressed: onDelete,
            color: AdminTheme.rose,
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? AdminTheme.emerald.withOpacity(0.12)
            : AdminTheme.gray.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'Activo' : 'Inactivo',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? AdminTheme.emerald : AdminTheme.gray,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  final VoidCallback? onCreate;

  const _EmptyState({required this.hasSearch, this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearch ? Icons.search_off : Icons.desktop_windows_outlined,
            size: 64,
            color: AdminTheme.gray.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            hasSearch ? 'Sin resultados' : 'Aún no hay kioscos',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AdminTheme.gray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearch
                ? 'Prueba con otra búsqueda'
                : 'Crea tu primer kiosco para empezar a capturar encuestas',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AdminTheme.gray,
            ),
          ),
          if (!hasSearch && onCreate != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Crear el primer kiosco'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AdminTheme.rose),
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: AdminTheme.rose,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
