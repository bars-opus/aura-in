import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  const MapState({
    this.pins = const [],
    this.isLoading = false,
    this.isFetching = false,
    this.error,
    this.anchorLocation,
    this.currentBounds,
    this.currentZoom,
    this.fetchMode = MapFetchMode.browse,
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
    );
  }
}
