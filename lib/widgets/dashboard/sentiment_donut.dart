import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:metrixvox_admin/config/theme.dart';
import 'package:metrixvox_admin/models/dashboard_metrics.dart';

/// Gráfico de dona del análisis de sentimiento.
class SentimentDonut extends StatelessWidget {
  final SentimentBreakdown sentiment;

  const SentimentDonut({super.key, required this.sentiment});

  @override
  Widget build(BuildContext context) {
    final total = sentiment.total;

    if (total == 0) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.donut_large_outlined, size: 64, color: AdminTheme.gray),
            SizedBox(height: 12),
            Text(
              'Sin datos de sentimiento',
              style: TextStyle(color: AdminTheme.gray),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 60,
              sections: [
                if (sentiment.positiveCount > 0)
                  PieChartSectionData(
                    value: sentiment.positiveCount.toDouble(),
                    color: AdminTheme.emerald,
                    title:
                        '${(sentiment.positiveCount / total * 100).round()}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                if (sentiment.neutralCount > 0)
                  PieChartSectionData(
                    value: sentiment.neutralCount.toDouble(),
                    color: AdminTheme.amber,
                    title:
                        '${(sentiment.neutralCount / total * 100).round()}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                if (sentiment.negativeCount > 0)
                  PieChartSectionData(
                    value: sentiment.negativeCount.toDouble(),
                    color: AdminTheme.rose,
                    title:
                        '${(sentiment.negativeCount / total * 100).round()}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Legend(
              color: AdminTheme.emerald,
              label: 'Positivos',
              value: sentiment.positiveCount,
            ),
            _Legend(
              color: AdminTheme.amber,
              label: 'Neutros',
              value: sentiment.neutralCount,
            ),
            _Legend(
              color: AdminTheme.rose,
              label: 'Negativos',
              value: sentiment.negativeCount,
            ),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _Legend({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AdminTheme.gray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '$value',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
