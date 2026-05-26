import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/map/config/feature/map_config.dart';
import 'package:nano_embryo/core/map/domain/data_source/map_data_source.dart';
import 'package:nano_embryo/core/map/domain/entities/lat_lng.dart';
import 'package:nano_embryo/core/map/domain/entities/map_bounds.dart';
import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';

// Sentinel used so copyWith() preserves an existing error unless explicitly cleared.
const Object _kAbsent = Object();

/// Which source is driving the current map fetch.
enum MapFetchMode {
  /// User is panning — pins fetched for visible viewport.
  browse,

  /// Locked to device GPS coordinates (radius fetch).
  deviceGps,

  /// Locked to the in-app user location (radius fetch).
  appLocation,
}

/// State for the generic map engine.
class MapState {
  final List<MapPin> pins;
  final bool isLoading;
  final bool isFetching;
  final String? error;
  final LatLng? anchorLocation;
  final MapBounds? currentBounds;
  final double? currentZoom;
  final MapFetchMode fetchMode;
  final String? selectedPinId;
  final bool viewportIsDirty;

  const MapState({
    this.pins = const [],
    this.isLoading = false,
    this.isFetching = false,
    this.error,
    this.anchorLocation,
    this.currentBounds,
    this.currentZoom,
    this.fetchMode = MapFetchMode.browse,
    this.selectedPinId,
    this.viewportIsDirty = false,
  });

  MapState copyWith({
    List<MapPin>? pins,
    bool? isLoading,
    bool? isFetching,
    Object? error = _kAbsent,
    LatLng? anchorLocation,
    MapBounds? currentBounds,
    double? currentZoom,
    MapFetchMode? fetchMode,
    Object? selectedPinId = _kAbsent,
    bool? viewportIsDirty,
  }) {
    return MapState(
      pins: pins ?? this.pins,
      isLoading: isLoading ?? this.isLoading,
      isFetching: isFetching ?? this.isFetching,
      error: identical(error, _kAbsent) ? this.error : error as String?,
      anchorLocation: anchorLocation ?? this.anchorLocation,
      currentBounds: currentBounds ?? this.currentBounds,
      currentZoom: currentZoom ?? this.currentZoom,
      fetchMode: fetchMode ?? this.fetchMode,
      selectedPinId: identical(selectedPinId, _kAbsent)
          ? this.selectedPinId
          : selectedPinId as String?,
      viewportIsDirty: viewportIsDirty ?? this.viewportIsDirty,
    );
  }
}

/// Generic map controller. Owns debounce, generation tokens, browse vs
/// radius fetch modes, anchor-location tracking, and error/loading state.
/// Data fetching is delegated to a [MapDataSource] supplied via [MapConfig].
class MapController extends StateNotifier<MapState> {
  final MapDataSource _dataSource;
  final Duration _debounce;
  final int _viewportLimit;
  final int _nearbyLimit;

  Timer? _debounceTimer;

  // Incremented on every fetch initiation. Each fetch captures the generation
  // on entry and discards results when the generation has changed (stale).
  int _generation = 0;

  MapController({
    required MapDataSource dataSource,
    required Duration viewportDebounce,
    required int viewportLimit,
    required int nearbyLimit,
  })  : _dataSource = dataSource,
        _debounce = viewportDebounce,
        _viewportLimit = viewportLimit,
        _nearbyLimit = nearbyLimit,
        // Start loading so the UI shows a spinner instead of empty state
        // while the initial location + fetch are in flight.
        super(const MapState(isLoading: true));

  Future<void> _fetchInBounds(
    MapBounds bounds,
    Map<String, dynamic> filters,
  ) async {
    final gen = ++_generation;
    state = state.copyWith(isFetching: true, error: null);

    try {
      final pins = await _dataSource.fetchInViewport(
        bounds: bounds,
        filters: filters,
        limit: _viewportLimit,
      );

      if (_generation != gen) return;
      state = state.copyWith(
        pins: pins,
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

  /// Fetch pins within [radiusKm] of [latitude]/[longitude].
  ///
  /// [mode] must be [MapFetchMode.deviceGps] or [MapFetchMode.appLocation]
  /// — pass whichever source supplied the coordinates so the UI can
  /// highlight the correct FAB.
  Future<void> fetchNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
    required Map<String, dynamic> filters,
    required MapFetchMode mode,
  }) async {
    final gen = ++_generation;
    state = state.copyWith(
      isLoading: true,
      isFetching: false,
      error: null,
      fetchMode: mode,
    );

    try {
      final pins = await _dataSource.fetchNearby(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        filters: filters,
        limit: _nearbyLimit,
      );

      if (_generation != gen) return;
      state = state.copyWith(
        pins: pins,
        isLoading: false,
        error: null,
        anchorLocation: LatLng(latitude: latitude, longitude: longitude),
      );
    } catch (e) {
      if (_generation != gen) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Pan/zoom-driven update. Switches mode back to [MapFetchMode.browse]
  /// (Airbnb-style: GPS/app-location FABs deactivate when user explores).
  Future<void> updateViewport(
    MapBounds bounds,
    Map<String, dynamic> filters,
  ) async {
    if (!bounds.isValid()) return;

    state = state.copyWith(
      currentBounds: bounds,
      isFetching: true,
      fetchMode: MapFetchMode.browse,
    );

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () => _fetchInBounds(bounds, filters));
  }

  /// Re-fetch with new filters, preserving the current fetch mode.
  ///
  /// Browse mode: re-fetches the visible viewport.
  /// GPS / app-location mode: re-fetches the same radius from the anchor.
  Future<void> refresh(Map<String, dynamic> filters, {double? radiusKm}) async {
    if (state.fetchMode != MapFetchMode.browse &&
        state.anchorLocation != null) {
      await fetchNearby(
        latitude: state.anchorLocation!.latitude,
        longitude: state.anchorLocation!.longitude,
        radiusKm: radiusKm ?? 5.0,
        filters: filters,
        mode: state.fetchMode,
      );
    } else if (state.currentBounds != null) {
      await _fetchInBounds(state.currentBounds!, filters);
    }
  }

  void clearError() => state = state.copyWith(error: null);

  /// Reset loading/fetching flags without clearing pins.
  /// Called when map init fails so the UI doesn't spin forever.
  void resetToIdle() =>
      state = state.copyWith(isLoading: false, isFetching: false);

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final mapControllerProvider =
    StateNotifierProvider<MapController, MapState>((ref) {
  final config = ref.watch(mapConfigProvider);
  return MapController(
    dataSource: config.dataSource,
    viewportDebounce: config.viewportDebounce,
    viewportLimit: config.viewportLimit,
    nearbyLimit: config.nearbyLimit,
  );
});
