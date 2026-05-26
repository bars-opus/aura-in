import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/map/config/feature/map_filter_schema.dart';

void main() {
  group('MapFilterSchema.assembleFilters', () {
    const allCategory = FilterOption(value: 'all', label: 'All');
    const allLuxury = FilterOption(value: 'all', label: 'All');
    const salon = FilterOption(value: 'salon', label: 'Salon');
    const luxury = FilterOption(value: 'Luxury', label: 'Luxury');

    const schema = MapFilterSchema(
      primaryFilterKey: 'shop_type',
      primaryAllOption: allCategory,
      primaryTabs: [salon],
      secondaryFilterKey: 'luxury_level',
      secondaryAllOption: allLuxury,
      secondaryChips: [luxury],
    );

    test('null selections produce empty map', () {
      expect(
        schema.assembleFilters(primary: null, secondary: null),
        isEmpty,
      );
    });

    test('"all" selection on either axis is omitted', () {
      expect(
        schema.assembleFilters(primary: allCategory, secondary: allLuxury),
        isEmpty,
      );
    });

    test('primary only sets primary key', () {
      expect(
        schema.assembleFilters(primary: salon, secondary: null),
        {'shop_type': 'salon'},
      );
    });

    test('both selections set both keys', () {
      expect(
        schema.assembleFilters(primary: salon, secondary: luxury),
        {'shop_type': 'salon', 'luxury_level': 'Luxury'},
      );
    });

    test('hidden secondary axis is always omitted', () {
      const noSecondary = MapFilterSchema(
        primaryFilterKey: 'event_type',
        primaryTabs: [FilterOption(value: 'concert', label: 'Concert')],
      );

      expect(
        noSecondary.assembleFilters(
          primary: const FilterOption(value: 'concert', label: 'Concert'),
          secondary: const FilterOption(value: 'X', label: 'X'),
        ),
        {'event_type': 'concert'},
      );
    });
  });
}
