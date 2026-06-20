import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/admin/data/verification_submission.dart';

final isCurrentUserAdminProvider = FutureProvider<bool>((ref) async {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return false;
  final client = ref.watch(supabaseClientProvider);
  final row = await client
      .from('app_admins')
      .select('user_id')
      .eq('user_id', userId)
      .maybeSingle();
  return row != null;
});

final pendingVerificationsProvider =
    FutureProvider<List<VerificationSubmission>>((ref) async {
  final client = ref.watch(supabaseClientProvider);

  // Shops pending review (admin RLS lets admins read all).
  final shopRows = await client
      .from('shops')
      .select(
        'id, overview, user_id, verification_submitted_at,'
        ' profiles!user_id(display_name, username, avatar_url),'
        ' shop_media(url, media_type)',
      )
      .eq('verification_status', 'pending')
      .order('verification_submitted_at', ascending: true);

  final workerRows = await client
      .from('workers')
      .select(
        'id, user_id, verification_submitted_at,'
        ' profiles!user_id(display_name, username, avatar_url)',
      )
      .eq('verification_status', 'pending')
      .order('verification_submitted_at', ascending: true);

  final List<VerificationSubmission> out = [];

  for (final r in (shopRows as List)) {
    final p = (r['profiles'] as Map?) ?? {};
    final media = ((r['shop_media'] as List?) ?? [])
        .where((m) => (m as Map)['media_type'] == 'document')
        .map((m) => (m as Map)['url'] as String?)
        .whereType<String>()
        .toList();
    out.add(VerificationSubmission(
      entityType: 'shop',
      entityId: r['id'] as String,
      ownerName: (p['display_name'] ?? p['username'] ?? 'Unknown') as String,
      ownerAvatarUrl: p['avatar_url'] as String?,
      submittedAt: r['verification_submitted_at'] == null
          ? null
          : DateTime.tryParse(r['verification_submitted_at'] as String),
      documentUrls: media,
      overview: r['overview'] as String?,
    ));
  }

  for (final r in (workerRows as List)) {
    final p = (r['profiles'] as Map?) ?? {};
    out.add(VerificationSubmission(
      entityType: 'worker',
      entityId: r['id'] as String,
      ownerName: (p['display_name'] ?? p['username'] ?? 'Unknown') as String,
      ownerAvatarUrl: p['avatar_url'] as String?,
      submittedAt: r['verification_submitted_at'] == null
          ? null
          : DateTime.tryParse(r['verification_submitted_at'] as String),
    ));
  }

  out.sort((a, b) {
    final at = a.submittedAt, bt = b.submittedAt;
    if (at == null && bt == null) return 0;
    if (at == null) return 1;
    if (bt == null) return -1;
    return at.compareTo(bt);
  });
  return out;
});

class VerificationActions {
  VerificationActions(this._ref);
  final Ref _ref;

  Future<void> review({
    required String entityType,
    required String entityId,
    required String decision,
    String? rejectionReason,
  }) async {
    final client = _ref.read(supabaseClientProvider);
    final res = await client.functions.invoke('review-verification', body: {
      'entity_type': entityType,
      'entity_id': entityId,
      'decision': decision,
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
    });
    final data = res.data;
    if (data is! Map || data['ok'] != true) {
      throw Exception('Could not record decision. Please try again.');
    }
    _ref.invalidate(pendingVerificationsProvider);
  }

  Future<void> submit({
    required String entityType,
    required String entityId,
  }) async {
    final client = _ref.read(supabaseClientProvider);
    final res = await client.functions.invoke('submit-verification', body: {
      'entity_type': entityType,
      'entity_id': entityId,
    });
    final data = res.data;
    if (data is! Map || data['ok'] != true) {
      throw Exception('Could not submit for review. Please try again.');
    }
    _ref.invalidate(pendingVerificationsProvider);
  }
}

final verificationActionsProvider =
    Provider<VerificationActions>((ref) => VerificationActions(ref));
