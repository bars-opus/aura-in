import 'dart:async';

import 'package:flutter/foundation.dart'
    show FlutterError, FlutterErrorDetails, FlutterExceptionHandler;
import 'package:flutter/services.dart' show PlatformException;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:nano_embryo/presentation/features/auth/utility/auth_exports.dart';
import 'package:nano_embryo/presentation/features/map/data/models/shop_location_dto.dart';
import 'package:nano_embryo/presentation/features/map/presentation/controllers/map_controller.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:nano_embryo/presentation/features/map/presentation/providers/map_filter_providers.dart';
import 'package:nano_embryo/presentation/features/map/presentation/widgets/animated_marker_manager.dart';
import 'package:nano_embryo/presentation/features/map/presentation/widgets/map_filter_bar.dart';
import 'package:nano_embryo/presentation/features/map/presentation/widgets/shop_info_bottom_sheet_loader.dart';

// Lagos, Nigeria — used as hardcoded fallback when neither GPS nor app
// location is available. Close enough to real shops in the target market.
const double _kFallbackLat = 6.5244;
const double _kFallbackLng = 3.3792;

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with TickerProviderStateMixin {
  Key _mapKey = UniqueKey();

  MapboxMap? _mapboxMap;
  bool _isMapReady = false;
  bool _showMap = false;
  Timer? _mapInitTimeout;
  AnimatedMarkerManager? _markerManager;
  bool _isFetchingNearby = false;

  // Retry state for "recreating_view" recovery.
  int _retryCount = 0;
  static const int _maxRetries = 4;

  // Saved so we can restore it in dispose() and not swallow errors from other
  // widgets on this screen.
  bool Function(Object, StackTrace)? _prevOnError;
  FlutterExceptionHandler? _prevFlutterOnError;

  @override
  void initState() {
    super.initState();

    // The "recreating_view" PlatformException is thrown deep inside
    // SystemChannels.platform_views.invokeMethod('create') — before
    // _onMapCreated fires. We intercept at both the platform-dispatcher level
    // (for uncaught async errors) and FlutterError level (for framework-
    // reported errors) to make sure we catch it regardless of propagation path.
    final dispatcher = WidgetsBinding.instance.platformDispatcher;
    _prevOnError = dispatcher.onError;
    dispatcher.onError = (error, stack) {
      if (error is PlatformException && error.code == 'recreating_view') {
        debugPrint('Mapbox platform view conflict — scheduling retry');
        _retryMapCreation();
        return true; // handled — suppresses the "Unhandled Exception" crash
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

  /// Defers MapWidget rendering and arms the safety timeout.
  ///
  /// The first creation adds a 300 ms buffer so the native layer has time to
  /// finish tearing down any leftover Mapbox view from a hot-restart or
  /// rapid navigation. Retries don't add the extra delay here because
  /// [_retryMapCreation] already waits with exponential backoff.
  void _scheduleMapCreation() {
    final initialDelay =
        _retryCount == 0 ? const Duration(milliseconds: 300) : Duration.zero;

    Future.delayed(initialDelay, () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _showMap = true);

        // Safety net: if _onMapCreated still hasn't fired after 10 s, stop
        // the spinner so the Retry button becomes tappable.
        _mapInitTimeout = Timer(const Duration(seconds: 10), () {
          if (mounted && !_isMapReady) {
            debugPrint('MapWidget init timeout — resetting to idle');
            ref.read(mapControllerProvider.notifier).resetToIdle();
          }
        });
      });
    });
  }

  /// Hides the MapWidget, waits with exponential back-off, then shows it again
  /// with a fresh [UniqueKey] so the native Mapbox SDK creates a new view.
  ///
  /// Gives up after [_maxRetries] and calls [MapController.resetToIdle] so
  /// the spinner stops and the Retry button is visible — preventing an
  /// infinite loop when the native view is permanently stuck (e.g. hot restart).
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
    // Backoff: 500 ms → 1 s → 2 s → 4 s
    final delay = Duration(milliseconds: 500 * (1 << (_retryCount - 1)));
    debugPrint(
      'MapWidget: retry $_retryCount/$_maxRetries in ${delay.inMilliseconds} ms',
    );

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

  void _updateMarkers(List<ShopLocationDTO> shops) {
    _markerManager?.updateMarkers(shops, _onMarkerTap);
  }

  _cardWell(Widget child) {
    return Center(
      child: SizedBox(
        height: 300.h,
        child: CardInkWell(
          elevation: ElevationTokens.md,
          borderRadius: BorderRadiusTokens.xlAll,
          padding: const EdgeInsets.all(0),
          margin: EdgeInsets.only(
            left: Spacing.md,
            top: Spacing.lg,
            right: Spacing.md,
          ),
          onTap: () {},
          child: child,
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final mapStyleUri = isDarkMode ? MapboxStyles.DARK : MapboxStyles.MAPBOX_STREETS;
    final colorScheme = Theme.of(context).colorScheme;
    final mapState = ref.watch(mapControllerProvider);
    final controller = ref.read(mapControllerProvider.notifier);

    ref.listen(mapFiltersProvider, (previous, next) {
      if (previous != next) controller.refresh(next);
    });

    // Always update markers — including clearing them when the list goes empty.
    ref.listen(mapControllerProvider, (previous, next) {
      if (previous?.shops != next.shops) _updateMarkers(next.shops);
    });

    return Scaffold(
      extendBody: true,
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: EdgeInsets.only(bottom: Spacing.xxl + Spacing.xl),
        child: Stack(
          children: [
            // ── Map ─────────────────────────────────────────────────────────
            // _showMap is false for one frame after initState so the native
            // Mapbox plugin can release the previous platform view before this
            // one requests the same id. See initState for details.
            if (_showMap)
              MapWidget(
                key: _mapKey,
                onMapCreated:
                    (mapboxMap) => _onMapCreated(mapboxMap, controller),
                // World-view default; _initializeMapWithLocation flies to the
                // real location immediately after the map is ready.
                cameraOptions: CameraOptions(
                  center: Point(coordinates: Position(20.0, 5.0)),
                  zoom: 3.0,
                ),
                styleUri: mapStyleUri,
              ),

            // ── Loading (initial / nearby fetch) ────────────────────────────
            if (mapState.isLoading && mapState.shops.isEmpty)
              const Center(child: CircularLoadingIndicator()),

            // ── Empty state ──────────────────────────────────────────────────
            if (!mapState.isLoading &&
                !mapState.isFetching &&
                mapState.shops.isEmpty &&
                mapState.error == null)
              _cardWell(
                Center(
                  child: EmptyStateWidget(
                    icon: Icons.map_outlined,
                    subtitle:
                        'This type of shop is not available in this location. You can change the luxury type for more options.',
                    actionLabel: 'Retry',
                    onAction: () {
                      if (!_isMapReady) {
                        // Map widget failed to initialise — use the same retry
                        // path as the automatic platform-dispatcher intercept.
                        _retryMapCreation();
                      } else {
                        controller.refresh(ref.read(mapFiltersProvider));
                      }
                    },
                  ),
                ),
              ),

            // ── Error state ──────────────────────────────────────────────────
            if (mapState.error != null)
              _cardWell(
                ErrorStateWidget(
                  subtitle: mapState.error,
                  onPrimaryAction: () {
                    controller.clearError();
                    controller.refresh(ref.read(mapFiltersProvider));
                  },
                ),
              ),

            // ── "Finding shops…" overlay shown during button-triggered fetch ─
            // if (_isFetchingNearby) Center(child: CircularLoadingIndicator()),

            // ── FAB: device GPS location ─────────────────────────────────────
            // Tapping fetches shops near the phone's current GPS position.
            // Active (green) when the map is locked to that location.
            // Tapping again while active switches back to browse (pan) mode.
            Positioned(
              bottom: Spacing.xxl.h + Spacing.xxl.h,
              right: Spacing.md.w,
              child: AnimatedScaleFade(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                child: FloatingActionButton.small(
                  heroTag: 'fab_gps',
                  backgroundColor: colorScheme.surface,
                  onPressed: () => _useDeviceLocation(controller),
                  child:
                      _isFetchingNearby
                          ? CircularLoadingIndicator()
                          : Icon(
                            mapState.fetchMode == MapFetchMode.deviceGps
                                ? Icons.gps_fixed
                                : Icons.gps_not_fixed,
                            color:
                                mapState.fetchMode == MapFetchMode.deviceGps
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                          ),
                ),
              ),
            ),

            // ── FAB: app-selected location ───────────────────────────────────
            // Tapping fetches shops near the location the user set in the app
            // via LocationDisplayWidget (e.g. "Accra, Ghana").
            // Active (green) when the map is locked to that location.
            // Tapping again while active switches back to browse (pan) mode.
            Positioned(
              bottom: Spacing.lg.h + Spacing.md.h,
              right: Spacing.md.w,
              child: AnimatedScaleFade(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                child: FloatingActionButton.small(
                  heroTag: 'fab_app_location',
                  backgroundColor: colorScheme.surface,
                  onPressed: () => _useAppLocation(controller),
                  child:
                      _isFetchingNearby
                          ? CircularLoadingIndicator()
                          : Icon(
                            mapState.fetchMode == MapFetchMode.appLocation
                                ? Icons.location_on
                                : Icons.location_on_outlined,
                            color:
                                mapState.fetchMode == MapFetchMode.appLocation
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: mapState.error != null ? null : const MapFilterBar(),
    );
  }

  // ── Map lifecycle ─────────────────────────────────────────────────────────

  // Await _initMarkerManager() before any shop data arrives so that
  // _annotationManager is never null when updateMarkers() is first called.
  void _onMapCreated(MapboxMap mapboxMap, MapController controller) async {
    // Map created successfully — cancel timeout and reset retry counter.
    _mapInitTimeout?.cancel();
    _retryCount = 0;
    try {
      _mapboxMap = mapboxMap;

      await _initMarkerManager();

      // Zoom changes also shift the visible area — wire the marker manager's
      // zoom listener back to _onCameraChanged so a viewport fetch fires too.
      _markerManager?.onViewportChangeNeeded = () {
        if (mounted) _onCameraChanged(controller);
      };

      if (!mounted) return;
      setState(() => _isMapReady = true);

      _mapboxMap?.onMapScrollListener = (MapContentGestureContext ctx) {
        _onCameraChanged(controller);
      };

      _initializeMapWithLocation(controller);
    } catch (e) {
      // Mapbox can throw PlatformException("recreating_view") on hot-restart
      // or rapid navigation if the native platform view with id '0' hasn't
      // fully released. Stop the loading spinner and let the user retry.
      debugPrint('MapWidget init error: $e');
      if (mounted) controller.resetToIdle();
    }
  }

  Future<void> _initMarkerManager() async {
    if (_mapboxMap == null) return;
    _markerManager = AnimatedMarkerManager(_mapboxMap!, context, this);
    await _markerManager?.initialize();
  }

  void _onMarkerTap(ShopLocationDTO shop) {
    BottomSheetUtils.showDocumentationBottomSheet(
      maxHeight: 550.h,
      padding: 0,
      context: context,
      widget: ShopInfoBottomSheetLoader(shopId: shop.id),
    );
  }

  void _onCameraChanged(MapController controller) async {
    if (!_isMapReady || _mapboxMap == null) return;

    final cameraState = await _mapboxMap?.getCameraState();
    if (cameraState == null) return;

    final coordinates = cameraState.center.coordinates;
    final zoom = cameraState.zoom;
    final span = 0.1 * (12 / zoom);

    final bounds = MapBounds(
      north: coordinates.lat + span,
      south: coordinates.lat - span,
      east: coordinates.lng + span,
      west: coordinates.lng - span,
    );

    controller.updateViewport(bounds, ref.read(mapFiltersProvider));
  }

  // ── Location helpers ──────────────────────────────────────────────────────

  /// Returns the device GPS position, or null if permission is missing.
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

  /// Fly to [latitude]/[longitude] then fetch shops.
  ///
  /// [mode] == [MapFetchMode.browse] triggers a viewport fetch at that
  /// position (fallback path). Any other mode uses a radius fetch, highlights
  /// the corresponding FAB, and then auto-fits the camera to encompass all
  /// returned shops so the user never has to manually zoom/pan to find them.
  Future<void> _flyToAndFetchNearby({
    required MapController controller,
    required double latitude,
    required double longitude,
    required MapFetchMode mode,
  }) async {
    // Fly to a moderate zoom first so the user sees regional context while
    // shops are loading (zoom 12 ≈ city level — wide enough for context).
    await _mapboxMap?.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(longitude, latitude)),
        zoom: 12.0,
      ),
      MapAnimationOptions(duration: 800),
    );

    if (!mounted) return;

    if (mode == MapFetchMode.browse) {
      _onCameraChanged(controller);
      return;
    }

    final filters = ref.read(mapFiltersProvider);
    await controller.fetchNearbyShops(
      latitude: latitude,
      longitude: longitude,
      radiusKm: 5.0,
      shopType: filters.shopType,
      luxuryLevel: filters.luxuryLevel,
      mode: mode,
    );

    if (!mounted) return;

    final shops = ref.read(mapControllerProvider).shops;
    _updateMarkers(shops);

    // Fit the camera so every returned shop is visible — this handles the
    // "I'm in Tema but the shops are 2 km away" case without the user having
    // to zoom or pan manually.
    if (shops.isNotEmpty) {
      await _fitCameraToShops(
        shops: shops,
        userLat: latitude,
        userLng: longitude,
      );
    }
  }

  /// Adjusts the camera to fit all [shops] plus the user's pin inside the
  /// viewport, with comfortable padding. Skips the adjustment when all shops
  /// are within a very tight cluster (< ~200 m spread) because the city-level
  /// zoom is already appropriate for that case.
  Future<void> _fitCameraToShops({
    required List<ShopLocationDTO> shops,
    required double userLat,
    required double userLng,
  }) async {
    if (_mapboxMap == null) return;

    double minLat = userLat, maxLat = userLat;
    double minLng = userLng, maxLng = userLng;

    for (final shop in shops) {
      if (shop.latitude < minLat) minLat = shop.latitude;
      if (shop.latitude > maxLat) maxLat = shop.latitude;
      if (shop.longitude < minLng) minLng = shop.longitude;
      if (shop.longitude > maxLng) maxLng = shop.longitude;
    }

    // ~0.002° ≈ 220 m — if all shops are this close together the current
    // zoom is already fine; a camera fit would just zoom in awkwardly.
    if ((maxLat - minLat) < 0.002 && (maxLng - minLng) < 0.002) return;

    // Small geographic buffer so markers aren't clipped at the viewport edge.
    const buf = 0.004;
    final bounds = CoordinateBounds(
      southwest: Point(coordinates: Position(minLng - buf, minLat - buf)),
      northeast: Point(coordinates: Position(maxLng + buf, maxLat + buf)),
      infiniteBounds: false,
    );

    try {
      final camera = await _mapboxMap!.cameraForCoordinateBounds(
        bounds,
        // Extra bottom padding for the filter bar; extra top for the FABs.
        MbxEdgeInsets(top: 100, left: 60, bottom: 180, right: 60),
        null, // bearing — keep current
        null, // pitch — keep current
        14.0, // maxZoom — never zoom in tighter than street level
        null,
      );

      if (mounted) {
        await _mapboxMap?.flyTo(camera, MapAnimationOptions(duration: 700));
      }
    } catch (e) {
      debugPrint('Camera fit error: $e');
    }
  }

  // ── Init: 3-tier location fallback ───────────────────────────────────────

  /// Priority order on map open:
  ///   1. Device GPS — best signal; uses phone's real position.
  ///   2. App-selected location — what the user set in LocationDisplayWidget.
  ///   3. Hardcoded Lagos fallback — ensures *something* loads on first open.
  Future<void> _initializeMapWithLocation(MapController controller) async {
    // Tier 1: device GPS
    final gpsPosition = await _getDeviceLocation();
    if (gpsPosition != null && mounted) {
      await _flyToAndFetchNearby(
        controller: controller,
        latitude: gpsPosition.latitude,
        longitude: gpsPosition.longitude,
        mode: MapFetchMode.deviceGps,
      );
      return;
    }

    if (!mounted) return;

    // Tier 2: location the user entered in the app
    final appLocation = ref.read(userLocationNotifierProvider);
    if (appLocation != null) {
      await _flyToAndFetchNearby(
        controller: controller,
        latitude: appLocation.latitude,
        longitude: appLocation.longitude,
        mode: MapFetchMode.appLocation,
      );
      return;
    }

    if (!mounted) return;

    // Tier 3: hardcoded fallback (Lagos, Nigeria)
    await _flyToAndFetchNearby(
      controller: controller,
      latitude: _kFallbackLat,
      longitude: _kFallbackLng,
      mode: MapFetchMode.browse,
    );
  }

  // ── FAB actions ───────────────────────────────────────────────────────────

  /// Tapping this FAB fetches shops near the device's GPS coordinates.
  /// Tapping again while active returns to browse (pan) mode.
  Future<void> _useDeviceLocation(MapController controller) async {
    if (ref.read(mapControllerProvider).fetchMode == MapFetchMode.deviceGps) {
      _onCameraChanged(controller); // re-enters browse mode via updateViewport
      return;
    }

    setState(() => _isFetchingNearby = true);
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
      if (mounted) setState(() => _isFetchingNearby = false);
    }
  }

  /// Tapping this FAB fetches shops near the location the user set in the app
  /// via LocationDisplayWidget. Tapping again returns to browse mode.
  Future<void> _useAppLocation(MapController controller) async {
    if (ref.read(mapControllerProvider).fetchMode == MapFetchMode.appLocation) {
      _onCameraChanged(controller);
      return;
    }

    final appLocation = ref.read(userLocationNotifierProvider);
    if (appLocation == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Set your location from the Discover screen first.'),
          ),
        );
      }
      return;
    }

    setState(() => _isFetchingNearby = true);
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
      if (mounted) setState(() => _isFetchingNearby = false);
    }
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
              'Please enable location permission to see shops near you. '
              'You can change this in your device settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  geo.Geolocator.openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    // Restore both error handlers so we don't intercept errors from other
    // widgets after this screen is gone.
    WidgetsBinding.instance.platformDispatcher.onError = _prevOnError;
    FlutterError.onError = _prevFlutterOnError;
    _mapInitTimeout?.cancel();
    _markerManager?.dispose();
    _mapboxMap?.onMapScrollListener = null;
    _mapboxMap?.onMapZoomListener = null;
    _mapboxMap = null;
    super.dispose();
  }
}
