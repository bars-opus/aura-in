// lib/features/shops/presentation/providers/luxury_level_provider.dart
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'luxury_level_provider.g.dart';

/// Provider that fetches luxury levels for a specific shop type
@riverpod
Future<List<LuxuryLevelInfo>> luxuryLevelList(
  LuxuryLevelListRef ref, {
  required String shopType,
}) {
  final repository = ref.watch(shopRepositoryProvider);
  return repository.getLuxuryLevels(shopType);
}
