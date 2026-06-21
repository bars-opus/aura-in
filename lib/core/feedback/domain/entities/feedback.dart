import 'package:equatable/equatable.dart';

/// Server-managed feedback lifecycle. Stable across host apps.
enum FeedbackStatus {
  pending('pending', 'Pending Review'),
  reviewed('reviewed', 'Reviewed'),
  implemented('implemented', 'Implemented'),
  rejected('rejected', 'Not Planned');

  const FeedbackStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static FeedbackStatus fromValue(String? value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => FeedbackStatus.pending,
    );
  }
}

/// A single feedback submission.
///
/// [type] is a free-form string keyed by [FeedbackConfig.types]. Host apps
/// pick their own categories — see FEEDBACK_ENGINE.md.
class Feedback extends Equatable {
  final String? id;
  final String userId;
  final String type;
  final String title;
  final String description;
  final List<String> screenshotUrls;
  final String appVersion;
  final Map<String, dynamic>? deviceInfo;
  final FeedbackStatus status;

  /// Client-generated UUID per submission. Lets the repo retry without
  /// creating duplicate rows: the unique constraint on `(user_id,
  /// idempotency_key)` dedupes server-side.
  final String? idempotencyKey;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Feedback({
    this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    this.screenshotUrls = const [],
    required this.appVersion,
    this.deviceInfo,
    this.status = FeedbackStatus.pending,
    this.idempotencyKey,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    title,
    description,
    screenshotUrls,
    appVersion,
    deviceInfo,
    status,
    idempotencyKey,
    createdAt,
    updatedAt,
  ];

  Feedback copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? description,
    List<String>? screenshotUrls,
    String? appVersion,
    Map<String, dynamic>? deviceInfo,
    FeedbackStatus? status,
    String? idempotencyKey,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Feedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      screenshotUrls: screenshotUrls ?? this.screenshotUrls,
      appVersion: appVersion ?? this.appVersion,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      status: status ?? this.status,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
