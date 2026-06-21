enum ModerationTargetType {
  profile('profile'),
  shop('shop'),
  freelancer('freelancer');

  final String value;

  const ModerationTargetType(this.value);

  static ModerationTargetType fromValue(String? value) {
    return ModerationTargetType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ModerationTargetType.profile,
    );
  }
}

class ModerationTarget {
  final ModerationTargetType targetType;
  final String targetId;
  final String targetOwnerId;
  final String displayName;

  const ModerationTarget({
    required this.targetType,
    required this.targetId,
    required this.targetOwnerId,
    required this.displayName,
  });

  Map<String, dynamic> toJson() {
    return {
      'target_type': targetType.value,
      'target_id': targetId,
      'target_owner_id': targetOwnerId,
      'display_name': displayName,
    };
  }

  factory ModerationTarget.fromJson(Map<String, dynamic> json) {
    return ModerationTarget(
      targetType: ModerationTargetType.fromValue(
        json['target_type']?.toString(),
      ),
      targetId: json['target_id']?.toString() ?? '',
      targetOwnerId: json['target_owner_id']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
    );
  }
}

class ModerationReasonOption {
  final String key;
  final String label;

  const ModerationReasonOption({required this.key, required this.label});
}

class ModerationBlockRecord {
  final String id;
  final String blockedUserId;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? reason;
  final DateTime createdAt;

  const ModerationBlockRecord({
    required this.id,
    required this.blockedUserId,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.reason,
    required this.createdAt,
  });

  factory ModerationBlockRecord.fromJson(Map<String, dynamic> json) {
    return ModerationBlockRecord(
      id: json['id']?.toString() ?? '',
      blockedUserId: json['blocked_user_id']?.toString() ?? '',
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      reason: json['reason'] as String?,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class ModerationCheckResult {
  final bool isBlocked;
  final bool isBlockedByCurrentUser;
  final bool isBlockingCurrentUser;

  const ModerationCheckResult({
    required this.isBlocked,
    required this.isBlockedByCurrentUser,
    required this.isBlockingCurrentUser,
  });

  factory ModerationCheckResult.fromJson(Map<String, dynamic> json) {
    return ModerationCheckResult(
      isBlocked: json['is_blocked'] == true,
      isBlockedByCurrentUser: json['is_blocked_by_current_user'] == true,
      isBlockingCurrentUser: json['is_blocking_current_user'] == true,
    );
  }
}

class ModerationActionResult {
  final bool success;
  final String? reason;

  const ModerationActionResult({required this.success, this.reason});

  factory ModerationActionResult.fromJson(Map<String, dynamic> json) {
    return ModerationActionResult(
      success: json['success'] == true,
      reason: json['reason'] as String?,
    );
  }
}
