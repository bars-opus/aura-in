// lib/features/discover/providers/discover_state_provider.dart
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'discover_state_provider.g.dart';

/// Shared orchestration helpers for the Discover screen.
///
/// NOTE: Loading is no longer triggered from here. shopListProvider watches
/// selectedServiceCategoryProvider and selectedLuxuryLevelProvider directly,
/// so it reloads automatically whenever those change. allFreelancersProvider
/// (FutureProvider) does the same for freelancers. This class now only
/// provides query helpers that don't fit cleanly on individual list providers.
@riverpod
class DiscoverState extends _$DiscoverState {
  @override
  void build() {}

  /// Returns the luxury levels available for the currently selected category.
  List<String> getAvailableLuxuryLevels() {
    final serviceCategory = ref.read(selectedServiceCategoryProvider);
    final luxuryAsync = ref.read(
      luxuryLevelListProvider(shopType: serviceCategory),
    );
    return luxuryAsync.value?.map((l) => l.level).toList() ?? [];
  }
}
