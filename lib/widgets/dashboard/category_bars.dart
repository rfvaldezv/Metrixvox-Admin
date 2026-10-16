import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/models/dashboard_metrics.dart';

/// Gráfico de barras horizontales del rendimiento por categoría.
class CategoryBars extends StatelessWidget {
  final List<CategoryPerformance> categories;

  const CategoryBars({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: AdminTheme.gray),
            SizedBox(height: 12),
            Text(
              'Sin datos de categorías',
              style: TextStyle(color: AdminTheme.gray),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final cat = categories[index];
        final pct = (cat.averageScore / 5.0).clamp(0.0, 1.0);
        final color = _colorForScore(cat.averageScore);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    cat.categoryName,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AdminTheme.dark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${cat.averageScore.toStringAsFixed(2)} / 5.0',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Container(
                    height: 10,
                    color: AdminTheme.lightGray,
                  ),
                  FractionallySizedBox(
                    widthFactor: pct,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Color _colorForScore(double score) {
    if (score >= 4.5) return AdminTheme.emerald;
    if (score >= 3.5) return AdminTheme.sky;
    if (score >= 2.5) return AdminTheme.amber;
    return AdminTheme.rose;
  }
}
