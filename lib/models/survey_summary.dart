/// Resumen de una encuesta (para la lista).
class SurveySummary {
  final String surveyCode;
  final String title;
  final String industryType;
  final String scope;
  final bool isActive;
  final int sectionCount;
  final int questionCount;

  SurveySummary({
    required this.surveyCode,
    required this.title,
    required this.industryType,
    required this.scope,
    required this.isActive,
    required this.sectionCount,
    required this.questionCount,
  });

  factory SurveySummary.fromJson(Map<String, dynamic> json) => SurveySummary(
        surveyCode: json['surveyCode'] as String? ?? '',
        title: json['title'] as String? ?? '',
        industryType: json['industryType'] as String? ?? '',
        scope: json['scope'] as String? ?? '',
        isActive: json['isActive'] as bool? ?? false,
        sectionCount: (json['sectionCount'] as num?)?.toInt() ?? 0,
        questionCount: (json['questionCount'] as num?)?.toInt() ?? 0,
      );
}
