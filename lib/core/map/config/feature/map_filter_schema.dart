import 'package:equatable/equatable.dart';

/// One option in the filter bar.
///
/// [value] is what gets passed to the data source as the filter value
/// (e.g. `'salon'`). [label] is what the user sees (e.g. `'Salon'`).
class FilterOption extends Equatable {
  final String value;
  final String label;

  const FilterOption({required this.value, required this.label});

  @override
  List<Object?> get props => [value, label];
}

/// Drives the engine's filter bar (category tabs + chip row).
///
/// The engine renders a fixed layout (tabs on top, chips below). Options
/// and the keys they map into the filter `Map` are supplied here.
///
/// Set [secondaryFilterKey] to `null` to hide the chip row entirely.
class MapFilterSchema extends Equatable {
  final String primaryFilterKey;
  final List<FilterOption> primaryTabs;
  final FilterOption? primaryAllOption;

  final String? secondaryFilterKey;
  final List<FilterOption> secondaryChips;
  final FilterOption? secondaryAllOption;

  const MapFilterSchema({
    required this.primaryFilterKey,
    required this.primaryTabs,
    this.primaryAllOption,
    this.secondaryFilterKey,
    this.secondaryChips = const [],
    this.secondaryAllOption,
  });

  /// Build the filter `Map` handed to `MapDataSource`.
  ///
  /// `null` selection on either axis omits that key from the result.
  /// A selection matching the corresponding "All" option also omits it.
  Map<String, dynamic> assembleFilters({
    required FilterOption? primary,
    required FilterOption? secondary,
  }) {
    final out = <String, dynamic>{};

    if (primary != null && primary != primaryAllOption) {
      out[primaryFilterKey] = primary.value;
    }

    if (secondaryFilterKey != null &&
        secondary != null &&
        secondary != secondaryAllOption) {
      out[secondaryFilterKey!] = secondary.value;
    }

    return out;
  }

  @override
  List<Object?> get props => [
        primaryFilterKey,
        primaryTabs,
        primaryAllOption,
        secondaryFilterKey,
        secondaryChips,
        secondaryAllOption,
      ];
}
