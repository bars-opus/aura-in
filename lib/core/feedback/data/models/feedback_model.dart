import 'package:nano_embryo/core/feedback/domain/entities/feedback.dart';

class FeedbackModel extends Feedback {
  const FeedbackModel({
    super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.description,
    super.screenshotUrls,
    required super.appVersion,
    super.deviceInfo,
    super.status,
    super.idempotencyKey,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      screenshotUrls: (json['screenshot_urls'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      appVersion: (json['app_version'] as String?) ?? '',
      deviceInfo: json['device_info'] is Map
          ? Map<String, dynamic>.from(json['device_info'] as Map)
          : null,
      status: FeedbackStatus.fromValue(json['status'] as String?),
      idempotencyKey: json['idempotency_key'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// `id`, `created_at`, `updated_at`, and `status` are populated by Postgres
  /// defaults / triggers on insert, so they're omitted from the payload.
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'type': type,
      'title': title,
      'description': description,
      'screenshot_urls': screenshotUrls,
      'app_version': appVersion,
      'device_info': deviceInfo,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
    };
  }
}
