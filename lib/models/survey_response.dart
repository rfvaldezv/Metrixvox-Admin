class SurveyResponse {
  final String id;
  final String tenantId;
  final String surveyCode;
  final String? subjectId;
  final String? branchOrLocationId;
  final String? channel;
  final String? verbatim;
  final String? sentiment;
  final DateTime? createdAt;
  final int metricCount;
  final double avgScore;

  SurveyResponse({
    required this.id,
    required this.tenantId,
    required this.surveyCode,
    this.subjectId,
    this.branchOrLocationId,
    this.channel,
    this.verbatim,
    this.sentiment,
    this.createdAt,
    required this.metricCount,
    required this.avgScore,
  });

  factory SurveyResponse.fromJson(Map<String, dynamic> json) => SurveyResponse(
        id: json['id'] as String? ?? '',
        tenantId: json['tenantId'] as String? ?? '',
        surveyCode: json['surveyCode'] as String? ?? '',
        subjectId: json['subjectId'] as String?,
        branchOrLocationId: json['branchOrLocationId'] as String?,
        channel: json['channel'] as String?,
        verbatim: json['verbatim'] as String?,
        sentiment: json['sentiment'] as String?,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
        metricCount: (json['metricCount'] as num?)?.toInt() ?? 0,
        avgScore: (json['avgScore'] as num?)?.toDouble() ?? 0.0,
      );
}
