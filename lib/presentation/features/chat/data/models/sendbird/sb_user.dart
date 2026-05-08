/// Represents Sendbird's User structure
class SBUser {
  final String userId;
  final String? nickname;
  final String? profileUrl;
  final String? metadata;
  final bool isActive;
  final DateTime? lastSeenAt;
  final List<String>? preferredLanguages;
  
  const SBUser({
    required this.userId,
    this.nickname,
    this.profileUrl,
    this.metadata,
    this.isActive = true,
    this.lastSeenAt,
    this.preferredLanguages,
  });
  
  // Helper methods
  String get displayName => nickname ?? userId;
}
