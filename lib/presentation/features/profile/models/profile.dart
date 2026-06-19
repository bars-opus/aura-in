import 'package:equatable/equatable.dart';

// lib/data/models/profile.dart

enum AccountStatus {
  active('active'),
  deactivated('deactivated'),
  pendingDelete('pending_delete'),
  deleted('deleted');

  final String value;

  const AccountStatus(this.value);

  static AccountStatus fromValue(String? value) {
    return AccountStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AccountStatus.active,
    );
  }
}

class Profile extends Equatable {
  final String id;
  final String? username;
  final String? displayName;
  final String? bio;
  final String? avatarUrl;
  final String? phoneE164;
  final DateTime? phoneVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AccountStatus accountStatus;
  final DateTime? deactivatedAt;
  final DateTime? pendingDeletionAt;
  final DateTime? deletionScheduledFor;
  final DateTime? deletedAt;
  final String? accountActionReason;

  const Profile({
    required this.id,
    this.username,
    this.displayName,
    this.bio,
    this.avatarUrl,
    this.phoneE164,
    this.phoneVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.accountStatus = AccountStatus.active,
    this.deactivatedAt,
    this.pendingDeletionAt,
    this.deletionScheduledFor,
    this.deletedAt,
    this.accountActionReason,
  });

  /// True once the account has completed phone verification.
  bool get isPhoneVerified => phoneVerifiedAt != null;

  // ==================== FACTORY CONSTRUCTOR ====================
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phoneE164: json['phone_e164'] as String?,
      phoneVerifiedAt: _parseNullableDate(json['phone_verified_at']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      accountStatus: AccountStatus.fromValue(json['account_status'] as String?),
      deactivatedAt: _parseNullableDate(json['deactivated_at']),
      pendingDeletionAt: _parseNullableDate(json['pending_deletion_at']),
      deletionScheduledFor: _parseNullableDate(json['deletion_scheduled_for']),
      deletedAt: _parseNullableDate(json['deleted_at']),
      accountActionReason: json['account_action_reason'] as String?,
    );
  }

  // ==================== TO JSON ====================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (phoneE164 != null) 'phone_e164': phoneE164,
      if (phoneVerifiedAt != null)
        'phone_verified_at': phoneVerifiedAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'account_status': accountStatus.value,
      if (deactivatedAt != null)
        'deactivated_at': deactivatedAt!.toIso8601String(),
      if (pendingDeletionAt != null)
        'pending_deletion_at': pendingDeletionAt!.toIso8601String(),
      if (deletionScheduledFor != null)
        'deletion_scheduled_for': deletionScheduledFor!.toIso8601String(),
      if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
      if (accountActionReason != null)
        'account_action_reason': accountActionReason,
    };
  }

  // ==================== COPY WITH (FOR PROFILE ONLY) ====================
  Profile copyWith({
    String? id,
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? phoneE164,
    DateTime? phoneVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    AccountStatus? accountStatus,
    DateTime? deactivatedAt,
    DateTime? pendingDeletionAt,
    DateTime? deletionScheduledFor,
    DateTime? deletedAt,
    String? accountActionReason,
  }) {
    return Profile(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneE164: phoneE164 ?? this.phoneE164,
      phoneVerifiedAt: phoneVerifiedAt ?? this.phoneVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      accountStatus: accountStatus ?? this.accountStatus,
      deactivatedAt: deactivatedAt ?? this.deactivatedAt,
      pendingDeletionAt: pendingDeletionAt ?? this.pendingDeletionAt,
      deletionScheduledFor: deletionScheduledFor ?? this.deletionScheduledFor,
      deletedAt: deletedAt ?? this.deletedAt,
      accountActionReason: accountActionReason ?? this.accountActionReason,
    );
  }

  // ==================== EMPTY / INITIAL STATE ====================
  factory Profile.empty(String userId) {
    final now = DateTime.now();
    return Profile(
      id: userId,
      username: null,
      displayName: null,
      bio: null,
      avatarUrl: null,
      createdAt: now,
      updatedAt: now,
      accountStatus: AccountStatus.active,
    );
  }

  // ==================== HELPER GETTERS ====================
  bool get hasUsername => username != null && username!.isNotEmpty;
  bool get hasDisplayName => displayName != null && displayName!.isNotEmpty;
  bool get hasBio => bio != null && bio!.isNotEmpty;
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;
  bool get isActive => accountStatus == AccountStatus.active;
  bool get isDeactivated => accountStatus == AccountStatus.deactivated;
  bool get isPendingDelete => accountStatus == AccountStatus.pendingDelete;
  bool get isDeleted => accountStatus == AccountStatus.deleted;
  bool get needsAccountRestore =>
      accountStatus == AccountStatus.deactivated ||
      accountStatus == AccountStatus.pendingDelete;

  // ==================== EQUATABLE ====================
  @override
  List<Object?> get props => [
    id,
    username,
    displayName,
    bio,
    avatarUrl,
    phoneE164,
    phoneVerifiedAt,
    createdAt,
    updatedAt,
    accountStatus,
    deactivatedAt,
    pendingDeletionAt,
    deletionScheduledFor,
    deletedAt,
    accountActionReason,
  ];

  static DateTime? _parseNullableDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value as String);
  }
}
