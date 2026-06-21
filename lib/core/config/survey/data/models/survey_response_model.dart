import 'package:nano_embryo/core/config/survey/domain/entities/survey_response.dart';

class SurveyResponseModel extends SurveyResponse {
  const SurveyResponseModel({
    required super.userId,
    required super.featureKey,
    required super.sentiment,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Convert from Supabase JSON
  factory SurveyResponseModel.fromJson(Map<String, dynamic> json) {
    return SurveyResponseModel(
      userId: json['user_id'],
      featureKey: json['feature_key'],
      sentiment: Sentiment.fromValue(json['sentiment']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// Convert to Supabase JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'feature_key': featureKey,
      'sentiment': sentiment.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
