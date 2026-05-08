import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:nano_embryo/presentation/features/map/data/models/shop_location_dto.dart';
import 'package:nano_embryo/presentation/features/map/domain/repositories/map_repository.dart';
import 'package:nano_embryo/presentation/features/map/presentation/providers/map_filter_providers.dart';
import 'package:nano_embryo/presentation/features/map/presentation/providers/map_providers.dart';

// Sentinel to distinguish "caller didn't pass error" from "caller passed null"
// so that copyWith() preserves an existing error unless explicitly cleared.
const Object _kAbsent = Object();

/// Which source is driving the current map fetch.
enum MapFetchMode {
  /// User is panning — shops are fetched for the visible viewport.
  browse,

  /// Locked to the device's GPS coordinates (radius-based fetch).
  deviceGps,

  /// Locked to the location the user set in the app (radius-based fetch).
  appLocation,
}

/// State for the map feature
class MapState {
  final List<ShopLocationDTO> shops;
  final bool isLoading;
  final bool isFetching;
  final String? error;
  final geo.Position? userLocation;
  final MapBounds? currentBounds;
  final double? currentZoom;
  final MapFetchMode fetchMode;

  const MapState({
    this.shops = const [],
    this.isLoading = false,
    this.isFetching = false,
    this.error,
    this.userLocation,
    this.currentBounds,
    this.currentZoom,
    this.fetchMode = MapFetchMode.browse,
  });

  MapState copyWith({
    List<ShopLocationDTO>? shops,
    bool? isLoading,
    bool? isFetching,
    Object? error = _kAbsent,
    geo.Position? userLocation,
    MapBounds? currentBounds,
    double? currentZoom,
    MapFetchMode? fetchMode,
  }) {
    return MapState(
      shops: shops ?? this.shops,
      isLoading: isLoading ?? this.isLoading,
      isFetching: isFetching ?? this.isFetching,
      error: identical(error, _kAbsent) ? this.error : error as String?,
      userLocation: userLocation ?? this.userLocation,
      currentBounds: currentBounds ?? this.currentBounds,
      currentZoom: currentZoom ?? this.currentZoom,
      fetchMode: fetchMode ?? this.fetchMode,
    );
  }
}

/// Bounding box for viewport queries
class MapBounds {
  final double north;
  final double south;
  final double east;
  final double west;

  const MapBounds({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
  });

  bool isValid() {
    return north > south && east > west;
  }
}

/// Controller for map state management
class MapController extends StateNotifier<MapState> {
  final MapRepository _repository;
  Timer? _debounceTimer;

  // Incremented on every fetch initiation. Each fetch captures its generation
  // on entry and discards results if the generation changed (stale request).
  int _generation = 0;

  // Start with isLoading: true so the UI shows a spinner instead of the
  // empty state while the first location + fetch are in flight.
  MapController(this._repository) : super(const MapState(isLoading: true));

  Future<void> _fetchShopsInBounds(MapBounds bounds, MapFilters filters) async {
    final gen = ++_generation;
    state = state.copyWith(isFetching: true, error: null);

    try {
      final shops = await _repository.getShopsInViewport(
        north: bounds.north,
        south: bounds.south,
        east: bounds.east,
        west: bounds.west,
        shopType: filters.shopType,
        luxuryLevel: filters.luxuryLevel,
        limit: 100,
      );

        if (_generation != gen) return;
      state = state.copyWith(
        shops: shops,
        isLoading: false,
        isFetching: false,
        error: null,
      );
    } catch (e) {
      if (_generation != gen) return;
      state = state.copyWith(
        isLoading: false,
        isFetching: false,
        error: e.toString(),
      );
    }
  }

  /// Fetch shops within a radius of the given coordinates.
  ///
  /// [mode] must be [MapFetchMode.deviceGps] or [MapFetchMode.appLocation] —
  /// pass whichever source supplied the coordinates so the UI can highlight
  /// the correct button.
  Future<void> fetchNearbyShops({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    String? shopType,
    String? luxuryLevel,
    MapFetchMode mode = MapFetchMode.deviceGps,
  }) async {
    final gen = ++_generation;
    state = state.copyWith(
      isLoading: true,
      isFetching: false,
      error: null,
      fetchMode: mode,
    );

    try {
      final shops = await _repository.getShopsNearby(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        shopType: shopType,
        luxuryLevel: luxuryLevel,
        limit: 50,
      );

      if (_generation != gen) return;
      state = state.copyWith(
        shops: shops,
        isLoading: false,
        error: null,
        userLocation: geo.Position(
          latitude: latitude,
          longitude: longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        ),
      );
    } catch (e) {
      if (_generation != gen) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update viewport and debounce the fetch.
  ///
  /// Any pan/scroll call switches the mode back to [MapFetchMode.browse] so
  /// the GPS and app-location buttons deactivate automatically when the user
  /// starts manually exploring the map (Airbnb-style behaviour).
  Future<void> updateViewport(MapBounds bounds, MapFilters filters) async {
    if (!bounds.isValid()) return;

    // Panning always re-enters browse mode and marks a pending fetch right
    // away to prevent the empty-state overlay from flashing.
    state = state.copyWith(
      currentBounds: bounds,
      isFetching: true,
      fetchMode: MapFetchMode.browse,
    );

    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () => _fetchShopsInBounds(bounds, filters),
    );
  }

  /// Re-fetch with new filters, respecting the current fetch mode.
  ///
  /// In browse mode: re-fetches the visible viewport.
  /// In GPS/app-location mode: re-fetches the same radius from the stored
  /// user location so filters apply without losing the fixed-point anchor.
  Future<void> refresh(MapFilters filters) async {
    if (state.fetchMode != MapFetchMode.browse && state.userLocation != null) {
      await fetchNearbyShops(
        latitude: state.userLocation!.latitude,
        longitude: state.userLocation!.longitude,
        shopType: filters.shopType,
        luxuryLevel: filters.luxuryLevel,
        mode: state.fetchMode,
      );
    } else if (state.currentBounds != null) {
      await _fetchShopsInBounds(state.currentBounds!, filters);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Resets loading/fetching flags without clearing shops.
  /// Called when map initialisation fails so the UI doesn't spin forever.
  void resetToIdle() {
    state = state.copyWith(isLoading: false, isFetching: false);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Provider for MapController
final mapControllerProvider = StateNotifierProvider<MapController, MapState>((
  ref,
) {
  final repository = ref.watch(mapRepositoryProvider);
  return MapController(repository);
});
