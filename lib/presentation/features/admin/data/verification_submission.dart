class VerificationSubmission {
  final String entityType; // 'shop' | 'worker'
  final String entityId;
  final String ownerName;
  final String? ownerAvatarUrl;
  final DateTime? submittedAt;
  final List<String> documentUrls;
  final String? overview;

  const VerificationSubmission({
    required this.entityType,
    required this.entityId,
    required this.ownerName,
    this.ownerAvatarUrl,
    this.submittedAt,
    this.documentUrls = const [],
    this.overview,
  });

  String get entityLabel => entityType == 'shop' ? 'Shop' : 'Freelancer';
}
