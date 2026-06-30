// NanoEmbryo-specific map configuration.
//
// When copying the map engine to a new app, replace the contents of this
// file with your own data source, filter schema, marker style resolver,
// tap navigation, fallback coordinates, and copy. Everything else in
// core/map/ is generic and can be copied unchanged.
//
// See MAP_ENGINE.md for the full integration guide.

import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nano_embryo/core/map/config/feature/map_config.dart';
import 'package:nano_embryo/core/map/config/feature/map_copy.dart';
import 'package:nano_embryo/core/map/config/feature/map_fallback.dart';
import 'package:nano_embryo/core/map/config/feature/map_filter_schema.dart';
import 'package:nano_embryo/core/map/config/feature/marker_style.dart';
import 'package:nano_embryo/core/map/domain/entities/lat_lng.dart';
import 'package:nano_embryo/core/providers/location_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/marker_code_generator.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/repositories/supabase_shop_map_datasource.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_map_card.dart';

/// Build the NanoEmbryo [MapConfig]. Wire into the root `ProviderScope`:
///
///   mapConfigProvider.overrideWithValue(buildNanoEmbryoMapConfig()),
MapConfig buildNanoEmbryoMapConfig() {
  return MapConfig(
    dataSource: SupabaseShopMapDataSource(Supabase.instance.client),
    filterSchema: const MapFilterSchema(
      primaryFilterKey: 'shop_type',
      primaryAllOption: FilterOption(value: 'all', label: 'All'),
      primaryTabs: [
        FilterOption(value: 'salon', label: 'Salon'),
        FilterOption(value: 'barbershop', label: 'Barbershop'),
        FilterOption(value: 'spa', label: 'Spa'),
        FilterOption(value: 'nail_salon', label: 'Nail Salon'),
        FilterOption(value: 'lash_studio', label: 'Lash Studio'),
        FilterOption(value: 'waxing', label: 'Waxing'),
        FilterOption(value: 'massage', label: 'Massage'),
      ],
      secondaryFilterKey: 'luxury_level',
      secondaryAllOption: FilterOption(value: 'all', label: 'All'),
      secondaryChips: [
        FilterOption(value: 'Moderate', label: 'Moderate'),
        FilterOption(value: 'Luxury', label: 'Luxury'),
        FilterOption(value: 'UltraLuxury', label: 'UltraLuxury'),
      ],
    ),
    resolveMarkerStyle: (pin) => MarkerStyle(
      label: MarkerCodeGenerator.getTypeCode(
        pin.data['shop_type'] as String?,
      ),
      color: MarkerCodeGenerator.getLuxuryColor(
        pin.data['luxury_level'] as String?,
      ),
    ),
    onPinTap: (pin, context) {
      context.push(
        '/shopDetailsScreen',
        extra: {'shopId': pin.id, 'coverImageUrl': ''},
      );
    },
    buildCarouselCard: (pin, isSelected, context) => ShopMapCard(
      pin: pin,
      isSelected: isSelected,
    ),
    fallback: const MapFallback(latitude: 6.5244, longitude: 3.3792),
    appLocationProvider: userLocationNotifierProvider.select(
      (s) => s == null
          ? null
          : LatLng(latitude: s.latitude, longitude: s.longitude),
    ),
    copy: const MapCopy(
      emptyStateSubtitle:
          'This type of shop is not available in this location. '
          'You can change the luxury type for more options.',
      appLocationMissingSnackbar:
          'Set your location from the Discover screen first.',
    ),
  );
}
