/// Métricas agregadas del dashboard para un tenant.
class DashboardMetrics {
  final String tenantId;
  final int totalResponses;
  final double globalScore;
  final SentimentBreakdown sentiment;
  final List<CategoryPerformance> categories;
  final List<PendingAlert> alerts;

  DashboardMetrics({
    required this.tenantId,
    required this.totalResponses,
    required this.globalScore,
    required this.sentiment,
    required this.categories,
    required this.alerts,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      tenantId: json['tenantId'] as String? ?? '',
      totalResponses: (json['totalResponses'] as num?)?.toInt() ?? 0,
      globalScore: (json['globalScore'] as num?)?.toDouble() ?? 0.0,
      sentiment: SentimentBreakdown.fromJson(
        json['sentimentBreakdown'] as Map<String, dynamic>? ?? {},
      ),
      categories: (json['categoryPerformances'] as List<dynamic>? ?? [])
          .map((c) =>
              CategoryPerformance.fromJson(c as Map<String, dynamic>))
          .toList(),
      alerts: (json['pendingAlerts'] as List<dynamic>? ?? [])
          .map((a) => PendingAlert.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  static DashboardMetrics empty() => DashboardMetrics(
        tenantId: '',
        totalResponses: 0,
        globalScore: 0,
        sentiment: SentimentBreakdown.empty(),
        categories: [],
        alerts: [],
      );
}

class SentimentBreakdown {
  final int positiveCount;
  final int neutralCount;
  final int negativeCount;

  SentimentBreakdown({
    required this.positiveCount,
    required this.neutralCount,
    required this.negativeCount,
  });

  factory SentimentBreakdown.fromJson(Map<String, dynamic> json) {
    return SentimentBreakdown(
      positiveCount: (json['positiveCount'] as num?)?.toInt() ?? 0,
      neutralCount: (json['neutralCount'] as num?)?.toInt() ?? 0,
      negativeCount: (json['negativeCount'] as num?)?.toInt() ?? 0,
    );
  }

  static SentimentBreakdown empty() => SentimentBreakdown(
        positiveCount: 0,
        neutralCount: 0,
        negativeCount: 0,
      );

  int get total => positiveCount + neutralCount + negativeCount;
}

class CategoryPerformance {
  final String categoryName;
  final double averageScore;

  CategoryPerformance({
    required this.categoryName,
    required this.averageScore,
  });

  factory CategoryPerformance.fromJson(Map<String, dynamic> json) {
    return CategoryPerformance(
      categoryName: json['categoryName'] as String? ?? '',
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PendingAlert {
  final String insightId;
  final String verbatimSnippet;
  final String summaryDescription;
  final String detectedCategory;
  final DateTime? createdAt;

  PendingAlert({
    required this.insightId,
    required this.verbatimSnippet,
    required this.summaryDescription,
    required this.detectedCategory,
    required this.createdAt,
  });

  factory PendingAlert.fromJson(Map<String, dynamic> json) {
    return PendingAlert(
      insightId: json['insightId'] as String? ?? '',
      verbatimSnippet: json['verbatimSnippet'] as String? ?? '',
      summaryDescription: json['summaryDescription'] as String? ?? '',
      detectedCategory: json['detectedCategory'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}
