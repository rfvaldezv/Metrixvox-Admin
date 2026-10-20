/// Pregunta de una encuesta.
class SurveyQuestion {
  final String id;
  final String text;
  final String type;
  final bool isRequired;
  final double weight;
  final String? optionsJson;

  SurveyQuestion({
    required this.id,
    required this.text,
    required this.type,
    required this.isRequired,
    required this.weight,
    this.optionsJson,
  });

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) => SurveyQuestion(
        id: json['id'] as String? ?? '',
        text: json['text'] as String? ?? '',
        type: json['type'] as String? ?? 'CSAT_5',
        isRequired: json['isRequired'] as bool? ?? true,
        weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
        optionsJson: json['optionsJson'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'text': text,
        'questionType': type,
        'isRequired': isRequired,
        'weight': weight,
        'optionsJson': optionsJson,
      };
}

/// Sección con preguntas.
class SurveySection {
  final String sectionName;
  final List<SurveyQuestion> questions;

  SurveySection({
    required this.sectionName,
    required this.questions,
  });

  factory SurveySection.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'] as List<dynamic>? ?? [];
    return SurveySection(
      sectionName: json['sectionName'] as String? ?? '',
      questions: rawQuestions
          .map((q) => SurveyQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Detalle completo de una encuesta.
class SurveyDetail {
  final String surveyCode;
  final String surveyTitle;
  final String scope;
  final String industryType;
  final List<SurveySection> sections;

  SurveyDetail({
    required this.surveyCode,
    required this.surveyTitle,
    required this.scope,
    this.industryType = 'Generic',
    required this.sections,
  });

  factory SurveyDetail.fromJson(Map<String, dynamic> json) {
    final rawSections = json['sections'] as List<dynamic>? ?? [];
    return SurveyDetail(
      surveyCode: json['surveyCode'] as String? ?? '',
      surveyTitle: json['surveyTitle'] as String? ?? '',
      scope: json['scope'] as String? ?? 'Customer',
      industryType: json['industryType'] as String? ?? 'Generic',
      sections: rawSections
          .map((s) => SurveySection.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
