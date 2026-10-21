import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/providers/auth_provider.dart';
import 'package:metrixvox_admin/providers/dashboard_provider.dart';
import 'package:metrixvox_admin/providers/tenant_provider.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadIfNeeded();
  }

  void _loadIfNeeded() {
    final auth = context.watch<AuthProvider>();
    final tenant = context.watch<TenantProvider>().selected;
    final dashboard = context.watch<DashboardProvider>();

    if (dashboard.isUnauthorized && auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        auth.handleUnauthorized();
      });
      return;
    }

    if (auth.token != null && tenant != null && tenant.tenantId != _loadedTenantId) {
      _loadedTenantId = tenant.tenantId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<DashboardProvider>().load(
              token: auth.token!,
              tenantId: tenant.tenantId,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final dashboard = context.watch<DashboardProvider>();
    final metrics = dashboard.metrics;
    final isMobile = MediaQuery.of(context).size.width < 900;

    return SingleChildScrollView(
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
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.w700, color: AdminTheme.dark),
                    ),
                    const SizedBox(height: 8),
                    const Text('Resumen de actividad y métricas', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AdminTheme.gray)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AdminTheme.indigo),
                onPressed: () {
                  final auth = context.read<AuthProvider>();
                  final tenant = context.read<TenantProvider>().selected;
                  if (auth.token != null && tenant != null) {
                    context.read<DashboardProvider>().load(token: auth.token!, tenantId: tenant.tenantId);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          if (dashboard.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()))
          else if (dashboard.error != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AdminTheme.rose.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(dashboard.error!, style: const TextStyle(color: AdminTheme.rose)),
            )
          else if (metrics != null) ...[
            // KPIs
            if (isMobile) ...[
              _KpiRow(metrics: metrics),
              const SizedBox(height: 16),
              _KpiRow2(metrics: metrics),
            ] else
              Row(
                children: [
                  Expanded(child: KpiCard(title: 'Total respuestas', value: '${metrics.totalResponses}', color: AdminTheme.indigo, icon: Icons.assignment_turned_in_outlined)),
                  const SizedBox(width: 16),
                  Expanded(child: KpiCard(title: 'Score promedio', value: metrics.globalScore.toStringAsFixed(2), color: AdminTheme.emerald, icon: Icons.star_outline)),
                  const SizedBox(width: 16),
                  Expanded(child: KpiCard(title: 'Positivos', value: '${metrics.sentiment.positiveCount}', color: AdminTheme.sky, icon: Icons.thumb_up_outlined)),
                  const SizedBox(width: 16),
                  Expanded(child: KpiCard(title: 'Alertas pendientes', value: '${metrics.alerts.length}', color: AdminTheme.rose, icon: Icons.warning_amber_outlined)),
                ],
              ),

            const SizedBox(height: 32),

            // Gráficos
            if (isMobile) ...[
              SizedBox(
                height: 300,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AdminTheme.border)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Análisis de Sentimiento (IA)', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 20),
                      Expanded(child: SentimentDonut(sentiment: metrics.sentiment)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AdminTheme.border)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rendimiento por Categoría', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 20),
                      Expanded(child: CategoryBars(categories: metrics.categories)),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 400,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AdminTheme.border)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Análisis de Sentimiento (IA)', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 24),
                            Expanded(child: SentimentDonut(sentiment: metrics.sentiment)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 400,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AdminTheme.border)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Rendimiento por Categoría', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 24),
                            Expanded(child: CategoryBars(categories: metrics.categories)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  final dynamic metrics;
  const _KpiRow({required this.metrics});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: KpiCard(title: 'Total respuestas', value: '${metrics.totalResponses}', color: AdminTheme.indigo, icon: Icons.assignment_turned_in_outlined)),
      const SizedBox(width: 16),
      Expanded(child: KpiCard(title: 'Score promedio', value: metrics.globalScore.toStringAsFixed(2), color: AdminTheme.emerald, icon: Icons.star_outline)),
    ]);
  }
}

class _KpiRow2 extends StatelessWidget {
  final dynamic metrics;
  const _KpiRow2({required this.metrics});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: KpiCard(title: 'Positivos', value: '${metrics.sentiment.positiveCount}', color: AdminTheme.sky, icon: Icons.thumb_up_outlined)),
      const SizedBox(width: 16),
      Expanded(child: KpiCard(title: 'Alertas pendientes', value: '${metrics.alerts.length}', color: AdminTheme.rose, icon: Icons.warning_amber_outlined)),
    ]);
  }
}
