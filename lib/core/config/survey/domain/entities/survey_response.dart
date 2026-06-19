import 'package:equatable/equatable.dart';

/// User sentiment toward a single feature.
enum Sentiment {
  like('like', '👍'),
  dislike('dislike', '👎');

  const Sentiment(this.value, this.emoji);
  final String value;
  final String emoji;

  static Sentiment fromValue(String value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => like,
    );
  }
}

class SurveyResponse extends Equatable {
  final String userId;
  final String featureKey;
  final Sentiment sentiment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SurveyResponse({
    required this.userId,
    required this.featureKey,
    required this.sentiment,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    userId,
    featureKey,
    sentiment,
    createdAt,
    updatedAt,
  ];

  SurveyResponse copyWith({
    String? userId,
    String? featureKey,
    Sentiment? sentiment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SurveyResponse(
      userId: userId ?? this.userId,
      featureKey: featureKey ?? this.featureKey,
      sentiment: sentiment ?? this.sentiment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
