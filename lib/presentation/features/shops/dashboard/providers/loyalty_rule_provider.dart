// lib/presentation/features/shops/dashboard/providers/loyalty_rule_provider.dart
//
// Phase 13 — per-shop loyalty rule provider.
//
// Keyed on shopId. Returns null when the shop has no ACTIVE rule
// configured (the bookings trigger then no-ops for that shop).
//
// Invalidate after a save via:
//   ref.invalidate(loyaltyRuleProvider(shopId));

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/loyalty_rule_dto.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';

final loyaltyRuleProvider =
    FutureProvider.family<LoyaltyRuleDTO?, String>((ref, shopId) async {
  final repo = ref.watch(promotionsRepositoryProvider);
  return repo.getLoyaltyRule(shopId: shopId);
});
