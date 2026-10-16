import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/providers/auth_provider.dart';
import 'package:metrixvox_admin/providers/tenant_provider.dart';

/// Pantalla del dashboard. Placeholder por ahora (FASE 4.2 lo llena).
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final tenant = context.watch<TenantProvider>().selected;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
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
            'Aquí verás un resumen de tu actividad y métricas.',
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

          const SizedBox(height: 32),

          // Cards de placeholder
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.6,
              children: [
                _PlaceholderCard(
                  icon: Icons.desktop_windows,
                  title: 'Kioscos activos',
                  value: '—',
                  color: AdminTheme.indigo,
                ),
                _PlaceholderCard(
                  icon: Icons.assignment_turned_in,
                  title: 'Respuestas hoy',
                  value: '—',
                  color: AdminTheme.emerald,
                ),
                _PlaceholderCard(
                  icon: Icons.sentiment_satisfied,
                  title: 'Score promedio',
                  value: '—',
                  color: AdminTheme.amber,
                ),
                _PlaceholderCard(
                  icon: Icons.warning_amber_rounded,
                  title: 'Alertas pendientes',
                  value: '—',
                  color: AdminTheme.rose,
                ),
                _PlaceholderCard(
                  icon: Icons.trending_up,
                  title: 'Tendencia semanal',
                  value: '—',
                  color: AdminTheme.sky,
                ),
                _PlaceholderCard(
                  icon: Icons.business,
                  title: 'Clientes',
                  value: '—',
                  color: AdminTheme.purple,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AdminTheme.indigo.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminTheme.indigo.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AdminTheme.indigo, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Próximamente (FASE 4.2): métricas reales, gráficos con fl_chart, '
                    'últimas respuestas capturadas, y KPIs del sistema.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AdminTheme.dark,
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

class _PlaceholderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _PlaceholderCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AdminTheme.gray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
