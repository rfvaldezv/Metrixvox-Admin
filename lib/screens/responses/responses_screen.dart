import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/models/survey_response.dart';
import 'package:metrixvox_admin/providers/auth_provider.dart';
import 'package:metrixvox_admin/providers/responses_provider.dart';
import 'package:metrixvox_admin/providers/tenant_provider.dart';

class ResponsesScreen extends StatefulWidget {
  const ResponsesScreen({super.key});

  @override
  State<ResponsesScreen> createState() => _ResponsesScreenState();
}

class _ResponsesScreenState extends State<ResponsesScreen> {
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
        context.read<ResponsesProvider>().load(
              token: auth.token!,
              tenantId: tenant.tenantId,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResponsesProvider>();
    final tenant = context.watch<TenantProvider>().selected;

    final filtered = _searchQuery.isEmpty
        ? provider.responses
        : provider.responses.where((r) {
            final q = _searchQuery.toLowerCase();
            return (r.verbatim ?? '').toLowerCase().contains(q) ||
                (r.branchOrLocationId ?? '').toLowerCase().contains(q) ||
                (r.sentiment ?? '').toLowerCase().contains(q);
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
                      'Respuestas',
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
                          : 'Cliente: ${tenant.name} · ${filtered.length} respuestas',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AdminTheme.gray,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Recargar',
                onPressed: provider.isLoading || tenant == null
                    ? null
                    : () {
                        final token = context.read<AuthProvider>().token;
                        if (token != null) {
                          context.read<ResponsesProvider>().load(
                                token: token,
                                tenantId: tenant.tenantId,
                              );
                        }
                      },
              ),
            ],
          ),

          const SizedBox(height: 24),

          TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar por comentario, sucursal o sentimiento...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
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
                    : filtered.isEmpty
                        ? const Center(
                            child: Text(
                              'Sin respuestas aún',
                              style: TextStyle(color: AdminTheme.gray),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _ResponseCard(response: filtered[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _ResponseCard extends StatelessWidget {
  final SurveyResponse response;

  const _ResponseCard({required this.response});

  @override
  Widget build(BuildContext context) {
    final dt = response.createdAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(response.createdAt!)
        : '—';

    final sentimentColor = _sentimentColor(response.sentiment);
    final sentimentLabel = response.sentiment ?? 'Sin análisis';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: sentimentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _sentimentIcon(response.sentiment),
                      size: 14,
                      color: sentimentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      sentimentLabel,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sentimentColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                response.branchOrLocationId ?? 'Sin sucursal',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AdminTheme.gray,
                ),
              ),
              const Spacer(),
              Text(
                dt,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AdminTheme.gray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoPill(
                  label: 'Score',
                  value: response.avgScore.toStringAsFixed(2),
                  color: AdminTheme.emerald,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoPill(
                  label: 'Métricas',
                  value: '${response.metricCount}',
                  color: AdminTheme.indigo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoPill(
                  label: 'Canal',
                  value: response.channel ?? '—',
                  color: AdminTheme.sky,
                ),
              ),
            ],
          ),
          if (response.verbatim != null && response.verbatim!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AdminTheme.lightGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.format_quote,
                    size: 18,
                    color: AdminTheme.gray,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '"${response.verbatim}"',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AdminTheme.dark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _sentimentColor(String? s) {
    switch (s?.toLowerCase()) {
      case 'positive':
        return AdminTheme.emerald;
      case 'negative':
        return AdminTheme.rose;
      default:
        return AdminTheme.amber;
    }
  }

  IconData _sentimentIcon(String? s) {
    switch (s?.toLowerCase()) {
      case 'positive':
        return Icons.sentiment_satisfied;
      case 'negative':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
