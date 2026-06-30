import 'dart:async';

import 'package:flutter/foundation.dart'
    show FlutterError, FlutterErrorDetails, FlutterExceptionHandler;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/map/config/feature/map_config.dart';
import 'package:nano_embryo/core/map/domain/entities/map_bounds.dart';
import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';
import 'package:nano_embryo/core/map/presentation/controllers/map_controller.dart';
import 'package:nano_embryo/core/map/presentation/providers/map_filter_providers.dart';
import 'package:nano_embryo/core/map/presentation/widgets/marker_source_manager.dart';
import 'package:nano_embryo/core/map/presentation/widgets/map_fab_column.dart';
import 'package:nano_embryo/core/map/presentation/widgets/map_pin_carousel.dart';
import 'package:nano_embryo/core/map/presentation/widgets/search_this_area_pill.dart';
import 'package:nano_embryo/core/map/presentation/widgets/map_filter_bar.dart';

/// Generic, drop-in map screen. All app-specific behaviour is driven by
/// [mapConfigProvider]; mount it like:
///
/// ```dart
/// GoRoute(path: '/map', builder: (_, __) => const MapEngineScreen()),
/// ```
class MapEngineScreen extends ConsumerStatefulWidget {
  const MapEngineScreen({super.key});

  @override
  ConsumerState<MapEngineScreen> createState() => _MapEngineScreenState();
}

class _MapEngineScreenState extends ConsumerState<MapEngineScreen>
    with TickerProviderStateMixin {
  Key _mapKey = UniqueKey();
  MapboxMap? _mapboxMap;
  bool _isMapReady = false;
  bool _showMap = false;
  Timer? _mapInitTimeout;
  Timer? _cameraSyncDebounce;
  MarkerSourceManager? _markerManager;
  bool _isFetchingGps = false;
  bool _isFetchingAppLocation = false;

  int _retryCount = 0;
  static const int _maxRetries = 4;
  bool _cameraGesturePending = false;

  bool Function(Object, StackTrace)? _prevOnError;
  FlutterExceptionHandler? _prevFlutterOnError;

  @override
  void initState() {
    super.initState();

    final dispatcher = WidgetsBinding.instance.platformDispatcher;
    _prevOnError = dispatcher.onError;
    dispatcher.onError = (error, stack) {
      if (error is PlatformException && error.code == 'recreating_view') {
        debugPrint('Mapbox platform view conflict — scheduling retry');
        _retryMapCreation();
        return true;
      }
      return _prevOnError?.call(error, stack) ?? false;
    };

    _prevFlutterOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception is PlatformException &&
          (details.exception as PlatformException).code == 'recreating_view') {
        debugPrint(
          'Mapbox platform view conflict (framework) — scheduling retry',
        );
        _retryMapCreation();
        return;
      }
      _prevFlutterOnError?.call(details);
    };

    _scheduleMapCreation();
  }

  void _scheduleMapCreation() {
    final initialDelay =
        _retryCount == 0 ? const Duration(milliseconds: 300) : Duration.zero;

    Future.delayed(initialDelay, () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _showMap = true);

        _mapInitTimeout = Timer(const Duration(seconds: 10), () {
          if (mounted && !_isMapReady) {
            debugPrint('MapWidget init timeout — resetting to idle');
            ref.read(mapControllerProvider.notifier).resetToIdle();
          }
        });
      });
    });
  }

  void _retryMapCreation() {
    _mapInitTimeout?.cancel();

    if (_retryCount >= _maxRetries) {
      debugPrint('MapWidget: max retries ($_maxRetries) exceeded — giving up');
      if (mounted) {
        ref.read(mapControllerProvider.notifier).resetToIdle();
      }
      return;
    }

    _retryCount++;
    final delay = Duration(milliseconds: 500 * (1 << (_retryCount - 1)));

    Future.delayed(delay, () {
      if (!mounted) return;
      _markerManager?.dispose();
      _markerManager = null;
      _mapboxMap = null;
      setState(() {
        _showMap = false;
        _isMapReady = false;
        _mapKey = UniqueKey();
      });
      _scheduleMapCreation();
    });
  }

  void _updateMarkers(List<MapPin> pins) {
    _markerManager?.updatePins(pins);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final mapStyleUri =
        isDarkMode ? MapboxStyles.DARK : MapboxStyles.MAPBOX_STREETS;
    final colorScheme = Theme.of(context).colorScheme;
    final config = ref.watch(mapConfigProvider);
    final mapState = ref.watch(mapControllerProvider);
    final controller = ref.read(mapControllerProvider.notifier);
    final mediaQuery = MediaQuery.of(context);
    final navigationBarHeight =
        mediaQuery.size.width >= Breakpoints.tablet ? 72.h : 64.h;
    // The Home navigation has transparent top padding. Overlap its visible
    // surface slightly so the filter and navigation read as one docked unit.
    final bottomDockOffset =
        mediaQuery.padding.bottom + navigationBarHeight - Spacing.xs.h;

    ref.listen<Map<String, dynamic>>(mapFiltersProvider, (previous, next) {
      if (previous != next) {
        controller.refresh(next, radiusKm: config.defaultRadiusKm);
      }
    });

    ref.listen<MapState>(mapControllerProvider, (previous, next) {
      if (previous?.pins != next.pins) _updateMarkers(next.pins);
    });

    ref.listen<String?>(mapControllerProvider.select((s) => s.selectedPinId), (
      prev,
      next,
    ) {
      _markerManager?.selectPin(next);
    });

    ref.listen<String?>(mapControllerProvider.select((s) => s.selectedPinId), (
      prev,
      next,
    ) async {
      if (next == null) return;
      final pins = ref.read(mapControllerProvider).pins;
      MapPin? pin;
      for (final p in pins) {
        if (p.id == next) {
          pin = p;
          break;
        }
      }
      if (pin == null) return;
      final mapbox = _mapboxMap;
      if (mapbox == null) return;
      final mapConfig = ref.read(mapConfigProvider);
      // Determine target zoom: if current zoom is below where clusters
      // stop forming, bump to clusterMaxZoom + 1 so the cluster definitely
      // splits and the pin shows individually. Otherwise keep current zoom.
      final cameraState = await mapbox.getCameraState();
      final currentZoom = cameraState.zoom;
      final targetZoom =
          currentZoom < mapConfig.clusterMaxZoom + 1
              ? mapConfig.clusterMaxZoom + 1
              : currentZoom;
      await mapbox.flyTo(
        CameraOptions(
          center: Point(coordinates: Position(pin.longitude, pin.latitude)),
          zoom: targetZoom,
        ),
        MapAnimationOptions(duration: 400),
      );
    });

    // Opens the configured pin destination from the screen's Flutter context,
    // rather than navigating directly inside Mapbox's native tap callback.
    ref.listen<String?>(
      mapControllerProvider.select((s) => s.pendingModalForPinId),
      (prev, next) {
        if (next == null) return;
        final pins = ref.read(mapControllerProvider).pins;
        MapPin? pin;
        for (final p in pins) {
          if (p.id == next) {
            pin = p;
            break;
          }
        }
        // Always clear the flag, even if we couldn't find the pin.
        ref.read(mapControllerProvider.notifier).clearPendingModal();
        if (pin != null) {
          config.onPinTap(pin, context);
        }
      },
    );

    return Scaffold(
      extendBody: true,
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          if (_showMap)
            MapWidget(
              key: _mapKey,
              onMapCreated: (mapboxMap) => _onMapCreated(mapboxMap, controller),
              onStyleLoadedListener: (_) => _onStyleLoaded(controller),
              // Belt-and-suspenders: scroll listener fires on touch drag;
              // camera-change fires on ANY camera state update (including
              // programmatic zoom, momentum, smaller pans the scroll listener
              // may miss on real iOS device).
              onCameraChangeListener: (CameraChangedEventData data) {
                _scheduleCameraSync(controller);
              },
              cameraOptions: CameraOptions(
                center: Point(coordinates: Position(20.0, 5.0)),
                zoom: 3.0,
              ),
              styleUri: mapStyleUri,
            ),

          if (!_isMapReady)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Semantics(
                    liveRegion: true,
                    label: config.copy.loadingLabel,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(Spacing.md.w),
                        child: const SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          Positioned(
            top: MediaQuery.of(context).padding.top + Spacing.lg.h,
            left: 0,
            right: 0,
            child: const Center(child: SearchThisAreaPill()),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + Spacing.lg.h,
            right: Spacing.lg.w,
            child: MapFabColumn(
              fetchMode: mapState.fetchMode,
              isFetchingGps: _isFetchingGps,
              isFetchingAppLocation: _isFetchingAppLocation,
              showAppLocationFab: config.appLocationProvider != null,
              onGpsPressed: () => _useDeviceLocation(controller),
              onAppLocationPressed: () => _useAppLocation(controller),
              deviceLocationLabel: config.copy.deviceLocationLabel,
              appLocationLabel: config.copy.appLocationLabel,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomDockOffset,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MapPinCarousel(),
                Padding(
                  padding: EdgeInsets.only(bottom: Spacing.sm.h),
                  child: const MapFilterBar(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Map lifecycle ─────────────────────────────────────────────────────

  void _onMapCreated(MapboxMap mapboxMap, MapController controller) {
    _mapInitTimeout?.cancel();
    _retryCount = 0;
    _mapboxMap = mapboxMap;
    _mapboxMap?.onMapScrollListener = (MapContentGestureContext ctx) {
      _scheduleCameraSync(controller, userGesture: true);
    };
    _mapboxMap?.onMapZoomListener = (MapContentGestureContext ctx) {
      _scheduleCameraSync(controller, userGesture: true);
    };
    // Style may already be loaded (e.g. simulator); the widget-level
    // onStyleLoadedListener handles the normal path, but if somehow
    // style is already ready we fire directly.
    // The idempotency guard in MarkerSourceManager._layersAdded prevents
    // double-init if both paths fire.
  }

  void _onStyleLoaded(MapController controller) async {
    if (_mapboxMap == null) return;
    try {
      await _initMarkerManager();
      if (!mounted) return;
      setState(() => _isMapReady = true);
      _initializeMapWithLocation(controller);
    } catch (e) {
      debugPrint('Style loaded init error: $e');
      if (mounted) controller.resetToIdle();
    }
  }

  Future<void> _initMarkerManager() async {
    if (_mapboxMap == null) return;
    final config = ref.read(mapConfigProvider);
    _markerManager = MarkerSourceManager(
      mapboxMap: _mapboxMap!,
      clusterRadius: config.clusterRadius,
      clusterMaxZoom: config.clusterMaxZoom,
      context: context,
      resolveStyle: config.resolveMarkerStyle,
      onPinTap: (pinId) {
        // Defer navigation to the Flutter screen context. Navigating directly
        // inside Mapbox's native callback is unreliable on physical iOS devices.
        ref.read(mapControllerProvider.notifier).requestModalForPin(pinId);
      },
    );
    await _markerManager?.initialize();
  }

  void _scheduleCameraSync(
    MapController controller, {
    bool userGesture = false,
  }) {
    _cameraGesturePending = _cameraGesturePending || userGesture;
    _cameraSyncDebounce?.cancel();
    _cameraSyncDebounce = Timer(const Duration(milliseconds: 120), () {
      _syncCameraState(controller);
    });
  }

  Future<void> _syncCameraState(MapController controller) async {
    if (!_isMapReady || _mapboxMap == null) return;

    final cameraState = await _mapboxMap?.getCameraState();
    if (!mounted || cameraState == null) return;

    final coordinates = cameraState.center.coordinates;
    final zoom = cameraState.zoom;
    final span = 0.1 * (12 / zoom);

    final bounds = MapBounds(
      north: coordinates.lat + span,
      south: coordinates.lat - span,
      east: coordinates.lng + span,
      west: coordinates.lng - span,
    );

    final wasUserGesture = _cameraGesturePending;
    _cameraGesturePending = false;
    if (wasUserGesture) {
      await controller.updateViewport(bounds, ref.read(mapFiltersProvider));
    } else {
      controller.syncViewport(bounds, zoom: zoom);
    }
  }

  // ── Location helpers ──────────────────────────────────────────────────

  Future<geo.Position?> _getDeviceLocation() async {
    try {
      if (!await geo.Geolocator.isLocationServiceEnabled()) return null;

      var permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
      }
      if (permission == geo.LocationPermission.denied ||
          permission == geo.LocationPermission.deniedForever) {
        return null;
      }

      return await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _flyToAndFetchNearby({
    required MapController controller,
    required double latitude,
    required double longitude,
    required MapFetchMode mode,
  }) async {
    final config = ref.read(mapConfigProvider);

    await _mapboxMap?.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(longitude, latitude)),
        zoom: config.fallback.initialZoom,
      ),
      MapAnimationOptions(duration: 800),
    );

    if (!mounted) return;

    if (mode == MapFetchMode.browse) {
      await _syncCameraState(controller);
      if (!mounted) return;
      await controller.refreshForCurrentViewport(ref.read(mapFiltersProvider));
      return;
    }

    final filters = ref.read(mapFiltersProvider);
    await controller.fetchNearby(
      latitude: latitude,
      longitude: longitude,
      radiusKm: config.defaultRadiusKm,
      filters: filters,
      mode: mode,
    );

    if (!mounted) return;

    final pins = ref.read(mapControllerProvider).pins;
    _updateMarkers(pins);

    if (pins.isNotEmpty) {
      await _fitCameraToPins(
        pins: pins,
        anchorLat: latitude,
        anchorLng: longitude,
      );
    }
  }

  Future<void> _fitCameraToPins({
    required List<MapPin> pins,
    required double anchorLat,
    required double anchorLng,
  }) async {
    if (_mapboxMap == null) return;

    double minLat = anchorLat, maxLat = anchorLat;
    double minLng = anchorLng, maxLng = anchorLng;

    for (final pin in pins) {
      if (pin.latitude < minLat) minLat = pin.latitude;
      if (pin.latitude > maxLat) maxLat = pin.latitude;
      if (pin.longitude < minLng) minLng = pin.longitude;
      if (pin.longitude > maxLng) maxLng = pin.longitude;
    }

    if ((maxLat - minLat) < 0.002 && (maxLng - minLng) < 0.002) return;

    const buf = 0.004;
    final bounds = CoordinateBounds(
      southwest: Point(coordinates: Position(minLng - buf, minLat - buf)),
      northeast: Point(coordinates: Position(maxLng + buf, maxLat + buf)),
      infiniteBounds: false,
    );

    try {
      final camera = await _mapboxMap!.cameraForCoordinateBounds(
        bounds,
        MbxEdgeInsets(top: 100, left: 60, bottom: 320, right: 60),
        null,
        null,
        14.0,
        null,
      );

      if (mounted) {
        await _mapboxMap?.flyTo(camera, MapAnimationOptions(duration: 700));
      }
    } catch (e) {
      debugPrint('Camera fit error: $e');
    }
  }

  // ── 3-tier location fallback ──────────────────────────────────────────

  Future<void> _initializeMapWithLocation(MapController controller) async {
    final config = ref.read(mapConfigProvider);

    // Tier 1: device GPS — pulses the GPS FAB while fetching.
    setState(() => _isFetchingGps = true);
    final gpsPosition = await _getDeviceLocation();
    if (gpsPosition != null && mounted) {
      try {
        await _flyToAndFetchNearby(
          controller: controller,
          latitude: gpsPosition.latitude,
          longitude: gpsPosition.longitude,
          mode: MapFetchMode.deviceGps,
        );
      } finally {
        if (mounted) setState(() => _isFetchingGps = false);
      }
      return;
    }
    if (mounted) setState(() => _isFetchingGps = false);
    if (!mounted) return;

    // Tier 2: in-app user location — pulses the app-location FAB.
    if (config.appLocationProvider != null) {
      final appLocation = ref.read(config.appLocationProvider!);
      if (appLocation != null) {
        setState(() => _isFetchingAppLocation = true);
        try {
          await _flyToAndFetchNearby(
            controller: controller,
            latitude: appLocation.latitude,
            longitude: appLocation.longitude,
            mode: MapFetchMode.appLocation,
          );
        } finally {
          if (mounted) setState(() => _isFetchingAppLocation = false);
        }
        return;
      }
    }

    if (!mounted) return;

    // Tier 3: configured hardcoded fallback (no loading indicator).
    await _flyToAndFetchNearby(
      controller: controller,
      latitude: config.fallback.latitude,
      longitude: config.fallback.longitude,
      mode: MapFetchMode.browse,
    );
  }

  // ── FAB actions ────────────────────────────────────────────────────────

  Future<void> _useDeviceLocation(MapController controller) async {
    setState(() => _isFetchingGps = true);
    try {
      final position = await _getDeviceLocation();
      if (!mounted) return;

      if (position == null) {
        _showLocationPermissionDialog();
        return;
      }

      await _flyToAndFetchNearby(
        controller: controller,
        latitude: position.latitude,
        longitude: position.longitude,
        mode: MapFetchMode.deviceGps,
      );
    } catch (e) {
      debugPrint('Device location button error: $e');
    } finally {
      if (mounted) setState(() => _isFetchingGps = false);
    }
  }

  Future<void> _useAppLocation(MapController controller) async {
    final config = ref.read(mapConfigProvider);
    if (config.appLocationProvider == null) return;

    final appLocation = ref.read(config.appLocationProvider!);
    if (appLocation == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(config.copy.appLocationMissingSnackbar)),
        );
      }
      return;
    }

    setState(() => _isFetchingAppLocation = true);
    try {
      await _flyToAndFetchNearby(
        controller: controller,
        latitude: appLocation.latitude,
        longitude: appLocation.longitude,
        mode: MapFetchMode.appLocation,
      );
    } catch (e) {
      debugPrint('App location button error: $e');
    } finally {
      if (mounted) setState(() => _isFetchingAppLocation = false);
    }
  }

  // ── Dialogs ───────────────────────────────────────────────────────────

  void _showLocationPermissionDialog() {
    final copy = ref.read(mapConfigProvider).copy;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(copy.locationPermissionTitle),
            content: Text(copy.locationPermissionBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(copy.locationPermissionCancelLabel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  geo.Geolocator.openAppSettings();
                },
                child: Text(copy.locationPermissionOpenSettingsLabel),
              ),
            ],
          ),
    );
  }

  // ── Dispose ────────────────────────────────────────────────────────────

  @override
  void dispose() {
    WidgetsBinding.instance.platformDispatcher.onError = _prevOnError;
    FlutterError.onError = _prevFlutterOnError;
    _mapInitTimeout?.cancel();
    _cameraSyncDebounce?.cancel();
    _markerManager?.dispose();
    _mapboxMap?.onMapScrollListener = null;
    _mapboxMap?.onMapZoomListener = null;
    _mapboxMap = null;
    super.dispose();
  }
}
