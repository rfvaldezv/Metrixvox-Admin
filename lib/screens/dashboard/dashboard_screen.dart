import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/providers/auth_provider.dart';
import 'package:metrixvox_admin/providers/dashboard_provider.dart';
import 'package:metrixvox_admin/providers/tenant_provider.dart';
import 'package:metrixvox_admin/services/report_service.dart';
import 'package:metrixvox_admin/widgets/dashboard/category_bars.dart';
import 'package:metrixvox_admin/widgets/dashboard/kpi_card.dart';
import 'package:metrixvox_admin/widgets/dashboard/sentiment_donut.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _loadedTenantId;
  bool _isExporting = false;

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
        context.read<DashboardProvider>().load(
              token: auth.token!,
              tenantId: tenant.tenantId,
            );
      });
    }
  }

  Future<void> _exportReport(String tenantId) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    setState(() => _isExporting = true);

    try {
      await ReportService.downloadExecutiveReport(
        token: token,
        tenantId: tenantId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte descargado correctamente'),
          backgroundColor: AdminTheme.emerald,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar reporte: $e'),
          backgroundColor: AdminTheme.rose,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final tenant = context.watch<TenantProvider>().selected;
    final dashboard = context.watch<DashboardProvider>();

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
                    Text(
                      'Bienvenido, ${user?.fullName.split(' ').first ?? ''}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AdminTheme.dark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Resumen de actividad y métricas',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        color: AdminTheme.gray,
                      ),
                    ),
                    if (tenant != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.business,
                            size: 14,
                            color: AdminTheme.indigo.withOpacity(0.7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Cliente activo: ${tenant.name}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AdminTheme.indigo.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed:
                    (tenant == null || dashboard.isLoading || _isExporting)
                        ? null
                        : () => _exportReport(tenant.tenantId),
                icon: _isExporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf, size: 18),
                label: Text(_isExporting ? 'Generando...' : 'Exportar PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.rose,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Recargar métricas',
                onPressed: dashboard.isLoading || tenant == null
                    ? null
                    : () {
                        final token = context.read<AuthProvider>().token;
                        if (token != null) {
                          context.read<DashboardProvider>().load(
                                token: token,
                                tenantId: tenant.tenantId,
                              );
                        }
                      },
              ),
            ],
          ),

          const SizedBox(height: 32),

          if (dashboard.error != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AdminTheme.rose.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminTheme.rose.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AdminTheme.rose, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dashboard.error!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AdminTheme.rose,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: KpiCard(
                    icon: Icons.assignment_turned_in,
                    title: 'Total respuestas',
                    value: '${dashboard.metrics?.totalResponses ?? 0}',
                    color: AdminTheme.indigo,
                    isLoading: dashboard.isLoading,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: KpiCard(
                    icon: Icons.sentiment_satisfied,
                    title: 'Score promedio',
                    value:
                        '${(dashboard.metrics?.globalScore ?? 0).toStringAsFixed(2)} / 5',
                    color: AdminTheme.emerald,
                    isLoading: dashboard.isLoading,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: KpiCard(
                    icon: Icons.thumb_up_outlined,
                    title: 'Positivos',
                    value:
                        '${dashboard.metrics?.sentiment.positiveCount ?? 0}',
                    color: AdminTheme.sky,
                    isLoading: dashboard.isLoading,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: KpiCard(
                    icon: Icons.warning_amber_rounded,
                    title: 'Alertas pendientes',
                    value: '${dashboard.metrics?.alerts.length ?? 0}',
                    color: AdminTheme.rose,
                    isLoading: dashboard.isLoading,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _ChartCard(
                    title: 'Análisis de Sentimiento (IA)',
                    child: dashboard.metrics == null
                        ? const Center(child: CircularProgressIndicator())
                        : SentimentDonut(
                            sentiment: dashboard.metrics!.sentiment),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 3,
                  child: _ChartCard(
                    title: 'Rendimiento por Categoría',
                    child: dashboard.metrics == null
                        ? const Center(child: CircularProgressIndicator())
                        : CategoryBars(
                            categories: dashboard.metrics!.categories,
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

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AdminTheme.dark,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }
}
