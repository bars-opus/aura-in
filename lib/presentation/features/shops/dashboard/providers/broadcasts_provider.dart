// lib/presentation/features/shops/dashboard/providers/broadcasts_provider.dart
//
// Phase 14 — list of past broadcasts for a shop, keyed by shopId.
// Invalidate after a successful sendBroadcast via:
//   ref.invalidate(broadcastsProvider(shopId));

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/broadcast_dto.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';

final broadcastsProvider =
    FutureProvider.family<List<BroadcastDTO>, String>((ref, shopId) async {
  final repo = ref.watch(promotionsRepositoryProvider);
  return repo.getBroadcasts(shopId);
});
