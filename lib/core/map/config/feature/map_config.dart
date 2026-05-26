import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nano_embryo/core/map/config/feature/map_copy.dart';
import 'package:nano_embryo/core/map/config/feature/map_fallback.dart';
import 'package:nano_embryo/core/map/config/feature/map_filter_schema.dart';
import 'package:nano_embryo/core/map/config/feature/marker_style.dart';
import 'package:nano_embryo/core/map/domain/data_source/map_data_source.dart';
import 'package:nano_embryo/core/map/domain/entities/lat_lng.dart';
import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';

/// The single per-app configuration object for the map engine.
///
/// Override [mapConfigProvider] in your root `ProviderScope` with an
/// instance returned from your app's `build…MapConfig()` factory (mirrors
/// the notification engine's `notificationConfigProvider` pattern).
///
/// When porting the engine to a new app, only `lib/core/map/config/map_config.dart`
/// (the per-app file one folder up) should change.
class MapConfig {
  /// Adapter the engine calls to fetch pins. Required.
  final MapDataSource dataSource;

  /// Drives the filter bar (tabs + chips). Required.
  final MapFilterSchema filterSchema;

  /// Per-pin → marker visual. Required.
  final MarkerStyleResolver resolveMarkerStyle;

  /// Called when the user taps a marker. Required.
  final void Function(MapPin pin, BuildContext context) onPinTap;

  /// Builds one card for the horizontal carousel. Called per visible pin.
  /// Receives [isSelected] so the card can highlight when its marker
  /// is the active selection.
  final Widget Function(MapPin pin, bool isSelected, BuildContext context)
      buildCarouselCard;

  /// Tier-3 fallback coordinates. Required.
  final MapFallback fallback;

  /// User-facing copy. Defaults to a generic `'No results in this area.'`
  /// style; override for app-specific wording.
  final MapCopy copy;

  /// Optional: a Riverpod listenable exposing the user's in-app location.
  /// When `null`, the app-location FAB hides and tier-2 fallback is
  /// skipped (device GPS → fallback only).
  final ProviderListenable<LatLng?>? appLocationProvider;

  /// Radius (km) used by the GPS/app-location FABs.
  final double defaultRadiusKm;

  /// Max pins per viewport fetch.
  final int viewportLimit;

  /// Max pins per radius fetch.
  final int nearbyLimit;

  /// Mapbox cluster radius in screen pixels. Defaults to 50.
  final double clusterRadius;

  /// Maximum zoom at which clusters still form. Beyond this, every pin
  /// is shown individually. Defaults to 14.
  final double clusterMaxZoom;

  const MapConfig({
    required this.dataSource,
    required this.filterSchema,
    required this.resolveMarkerStyle,
    required this.onPinTap,
    required this.buildCarouselCard,
    required this.fallback,
    this.copy = const MapCopy(),
    this.appLocationProvider,
    this.defaultRadiusKm = 5.0,
    this.viewportLimit = 100,
    this.nearbyLimit = 50,
    this.clusterRadius = 50,
    this.clusterMaxZoom = 14,
  });
}

/// Provider the engine reads. Apps MUST override this in `ProviderScope`
/// — there is no sensible default `dataSource`, so the default throws.
final mapConfigProvider = Provider<MapConfig>((ref) {
  throw UnimplementedError(
    'mapConfigProvider has not been overridden. '
    'Add `mapConfigProvider.overrideWithValue(buildXxxMapConfig(ref))` to '
    'your root ProviderScope. See lib/core/map/MAP_ENGINE.md.',
  );
});
