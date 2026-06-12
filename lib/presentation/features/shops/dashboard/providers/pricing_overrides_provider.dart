// lib/presentation/features/shops/dashboard/providers/pricing_overrides_provider.dart
//
// Phase 15 — active overrides for a slot, keyed by slotId.
// Invalidate after create / update / archive via:
//   ref.invalidate(pricingOverridesProvider(slotId));

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/pricing_override_dto.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';

final pricingOverridesProvider =
    FutureProvider.family<List<PricingOverrideDTO>, String>(
        (ref, slotId) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getPricingOverrides(slotId: slotId);
});
