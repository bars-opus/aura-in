import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nano_embryo/core/map/config/feature/map_config.dart';
import 'package:nano_embryo/core/map/config/feature/map_filter_schema.dart';

/// User's current selection on the primary tab axis. `null` = none chosen
/// (engine will fall back to `primaryAllOption` if the schema has one).
final selectedPrimaryFilterProvider = StateProvider<FilterOption?>((ref) => null);

/// User's current selection on the secondary chip axis. `null` = none chosen.
final selectedSecondaryFilterProvider =
    StateProvider<FilterOption?>((ref) => null);

/// Combined filter map handed to the controller / data source.
///
/// Re-computes whenever either selection changes. Uses the schema's
/// `assembleFilters` so `null` and "all" selections drop out cleanly.
final mapFiltersProvider = Provider<Map<String, dynamic>>((ref) {
  final config = ref.watch(mapConfigProvider);
  final primary = ref.watch(selectedPrimaryFilterProvider);
  final secondary = ref.watch(selectedSecondaryFilterProvider);
  return config.filterSchema.assembleFilters(
    primary: primary,
    secondary: secondary,
  );
});
