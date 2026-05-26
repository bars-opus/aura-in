# Map "Airbnb Trio" Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add three reinforcing interactions to the map engine — native marker clustering, "Search this area" button, and always-visible horizontal card carousel with bidirectional marker-selection sync — bringing the NanoEmbryo map to Airbnb-level marketplace UX.

**Architecture:** Replace `PointAnnotationManager`-based marker rendering with Mapbox-native `GeoJsonSource` + symbol layers for clustering. Decouple viewport pan from data fetch (controller no longer auto-fetches on pan; a "Search this area" pill triggers fetches). Add a horizontal carousel that's bidirectionally synced with marker selection via two new state fields (`selectedPinId`, `viewportIsDirty`). Cards are app-specific via a new `MapConfig.buildCarouselCard` callback; the engine stays generic.

**Tech Stack:** Flutter, Riverpod, `mapbox_maps_flutter ^2.1.0`, `flutter_screenutil`, Equatable. Mapbox-native features used: `GeoJsonSource(cluster: true)`, `SymbolLayer`/`CircleLayer`, `Style.addStyleImage`, `feature-state`, `Source.getClusterExpansionZoom`.

**Reference docs:**
- Spec: [docs/superpowers/specs/2026-05-26-map-airbnb-trio-design.md](../specs/2026-05-26-map-airbnb-trio-design.md)
- Engine guide: [architecture/MAP_ENGINE.md](../../../architecture/MAP_ENGINE.md)

---

## File structure (final state)

```
lib/core/map/
├── config/
│   ├── feature/
│   │   ├── map_config.dart           # MODIFIED — add buildCarouselCard + clusterRadius + clusterMaxZoom
│   │   └── map_copy.dart             # MODIFIED — add searchThisAreaLabel
│   └── map_config.dart               # MODIFIED — NanoEmbryo wires ShopMapCard via buildCarouselCard
├── presentation/
│   ├── controllers/
│   │   └── map_controller.dart       # MODIFIED — decouple viewport from fetch, add selectPin + refreshForCurrentViewport, 2 new state fields
│   ├── screens/
│   │   └── map_screen.dart           # MODIFIED — mount carousel + pill, swap marker manager, rewire viewport listener
│   └── widgets/
│       ├── animated_marker_manager.dart  # DELETED
│       ├── marker_source_manager.dart    # NEW — GeoJsonSource + symbol layers + clustering
│       ├── map_pin_carousel.dart         # NEW — PageView with bidirectional sync
│       ├── search_this_area_pill.dart    # NEW
│       ├── map_fab_column.dart           # MODIFIED — accept carousel-aware bottom offset
│       └── map_filter_bar.dart           # unchanged
└── …other engine files unchanged

lib/presentation/features/shops/query/presentation/widgets/
└── shop_map_card.dart                # NEW — per-shop compact carousel card

test/map/
└── map_controller_test.dart          # MODIFIED — flip debounce test, add tests for new methods

architecture/MAP_ENGINE.md            # MODIFIED — document new API + interaction semantics
```

---

# Slice A — Decouple viewport from fetch

Goal: `MapController.updateViewport` stops auto-fetching. New `refreshForCurrentViewport` method does explicit fetches. New `selectPin` method. Two new state fields. The app's map screen will be broken until Slice C lands the pill, so don't manual-verify between A and C.

---

### Task A.1: Add `selectedPinId` and `viewportIsDirty` to `MapState`

**Files:**
- Modify: `lib/core/map/presentation/controllers/map_controller.dart`

- [ ] **Step 1: Add fields and update `copyWith`**

Open `lib/core/map/presentation/controllers/map_controller.dart`. Update the `MapState` class:

Add the two new fields to the field declarations (after `fetchMode`):
```dart
  final String? selectedPinId;
  final bool viewportIsDirty;
```

Add them to the constructor parameter list and initializer list:
```dart
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
```

Update `copyWith` to accept and propagate them. `selectedPinId` uses the sentinel pattern so callers can explicitly pass `null` to clear it:

```dart
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
```

- [ ] **Step 2: Verify build**

Run: `flutter analyze lib/core/map/presentation/controllers/map_controller.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/presentation/controllers/map_controller.dart
git commit -m "feat(map-trio): add selectedPinId + viewportIsDirty to MapState

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task A.2: Replace `updateViewport` debounce-fetch with dirty-flag

**Files:**
- Modify: `lib/core/map/presentation/controllers/map_controller.dart`

- [ ] **Step 1: Rewrite `updateViewport`**

Replace the current `updateViewport` method:
```dart
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
```

With this version (return type stays `Future<void>` for API stability; body is now synchronous):
```dart
  /// Pan/zoom-driven update. Records the new viewport but does NOT fetch.
  /// Setting [MapState.viewportIsDirty] = true tells the UI to show the
  /// "Search this area" pill. The pill triggers [refreshForCurrentViewport].
  ///
  /// Initial-load fetches (GPS / app-location / fallback) go through
  /// [fetchNearby], which is unchanged — only pan-driven viewport updates
  /// follow the new dirty-flag path.
  Future<void> updateViewport(
    MapBounds bounds,
    Map<String, dynamic> filters,
  ) async {
    if (!bounds.isValid()) return;
    state = state.copyWith(
      currentBounds: bounds,
      fetchMode: MapFetchMode.browse,
      viewportIsDirty: true,
    );
  }
```

The `filters` parameter is intentionally retained even though unused — callers pass it from `mapFiltersProvider` and we preserve the signature so the screen's `_onCameraChanged` doesn't need to change in this slice.

Also: delete `_debounceTimer` field and remove its `_debounceTimer?.cancel()` call from the `dispose()` method, since nothing schedules it anymore.

After edits, the `MapController` class should no longer reference `_debounceTimer` or `_debounce` (the constructor param is dead too — keep it for now to avoid changing the provider wiring; we'll clean it up at the end of Slice E).

- [ ] **Step 2: Verify build**

Run: `flutter analyze lib/core/map/presentation/controllers/map_controller.dart`
Expected: `No issues found!`

Note: `dart:async` import becomes unused if `_debounceTimer` field is removed. If analyzer flags it, remove the import too:
```dart
import 'dart:async';
```

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/presentation/controllers/map_controller.dart
git commit -m "feat(map-trio): updateViewport no longer auto-fetches — sets viewportIsDirty instead

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task A.3: Add `refreshForCurrentViewport` and `selectPin` methods

**Files:**
- Modify: `lib/core/map/presentation/controllers/map_controller.dart`

- [ ] **Step 1: Add the two methods**

Add these methods to `MapController`, right after the existing `refresh` method:

```dart
  /// Explicit fetch for the current viewport + filters. Called by the
  /// "Search this area" pill. Clears [MapState.viewportIsDirty] and
  /// [MapState.selectedPinId] on success.
  Future<void> refreshForCurrentViewport(Map<String, dynamic> filters) async {
    if (state.currentBounds == null) return;
    await _fetchInBounds(state.currentBounds!, filters);
    if (!mounted) return;
    if (state.error == null) {
      state = state.copyWith(
        viewportIsDirty: false,
        selectedPinId: null,
      );
    }
  }

  /// Set or clear the active marker/card selection. Called by the carousel
  /// when the active page changes, and by the marker source manager when
  /// the user taps a pin.
  void selectPin(String? pinId) {
    if (state.selectedPinId == pinId) return;
    state = state.copyWith(selectedPinId: pinId);
  }
```

The `if (state.error == null)` guard prevents the dirty flag from clearing when the fetch failed — we want the user to be able to retry.

- [ ] **Step 2: Verify build**

Run: `flutter analyze lib/core/map/presentation/controllers/map_controller.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/presentation/controllers/map_controller.dart
git commit -m "feat(map-trio): add refreshForCurrentViewport + selectPin to MapController

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task A.4: Update controller tests

**Files:**
- Modify: `test/map/map_controller_test.dart`

- [ ] **Step 1: Replace the debounce test with a no-auto-fetch test**

In `test/map/map_controller_test.dart`, find the test named `'updateViewport debounces multiple rapid calls into one fetch'` and replace it ENTIRELY with:

```dart
    test('updateViewport sets viewportIsDirty and does NOT fetch', () async {
      fake.queueViewport(const [
        MapPin(id: 'a', latitude: 0, longitude: 0),
      ]);

      const bounds = MapBounds(north: 1, south: 0, east: 1, west: 0);
      await controller.updateViewport(bounds, const {'k': 'v1'});

      // No matter how long we wait, the controller must not call the
      // data source. The pill drives the fetch now, not the controller.
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(fake.viewportCalls, 0);
      expect(controller.state.viewportIsDirty, isTrue);
      expect(controller.state.currentBounds, bounds);
      expect(controller.state.fetchMode, MapFetchMode.browse);
    });
```

- [ ] **Step 2: Add a `refreshForCurrentViewport` test**

Add this test inside the `group('MapController', ...)` block, right after the test you just modified:

```dart
    test('refreshForCurrentViewport fetches and clears dirty + selection', () async {
      // Arrange: set up a dirty viewport with an existing selection.
      fake.queueViewport(const [
        MapPin(id: 'shop-x', latitude: 0, longitude: 0),
      ]);
      const bounds = MapBounds(north: 1, south: 0, east: 1, west: 0);
      await controller.updateViewport(bounds, const {});
      controller.selectPin('previously-selected');
      expect(controller.state.viewportIsDirty, isTrue);
      expect(controller.state.selectedPinId, 'previously-selected');

      // Act
      await controller.refreshForCurrentViewport(const {'shop_type': 'salon'});

      // Assert: fetch fired with the filters; state cleaned up.
      expect(fake.viewportCalls, 1);
      expect(fake.lastViewportFilters, equals({'shop_type': 'salon'}));
      expect(controller.state.pins.single.id, 'shop-x');
      expect(controller.state.viewportIsDirty, isFalse);
      expect(controller.state.selectedPinId, isNull);
    });

    test('refreshForCurrentViewport keeps dirty true on fetch error', () async {
      fake.queueError(Exception('network down'));
      const bounds = MapBounds(north: 1, south: 0, east: 1, west: 0);
      await controller.updateViewport(bounds, const {});

      await controller.refreshForCurrentViewport(const {});

      // Error path: dirty flag stays so the user can retry the pill.
      expect(controller.state.error, contains('network down'));
      expect(controller.state.viewportIsDirty, isTrue);
    });

    test('refreshForCurrentViewport no-ops when currentBounds is null', () async {
      // Fresh controller, no updateViewport yet → currentBounds is null.
      await controller.refreshForCurrentViewport(const {});
      expect(fake.viewportCalls, 0);
    });
```

- [ ] **Step 3: Add `selectPin` tests**

Add inside the same group, after the refreshForCurrentViewport tests:

```dart
    test('selectPin updates selectedPinId', () {
      controller.selectPin('shop-1');
      expect(controller.state.selectedPinId, 'shop-1');
      controller.selectPin('shop-2');
      expect(controller.state.selectedPinId, 'shop-2');
    });

    test('selectPin(null) clears the selection', () {
      controller.selectPin('shop-1');
      controller.selectPin(null);
      expect(controller.state.selectedPinId, isNull);
    });

    test('selectPin with same id is a no-op (does not emit new state)', () {
      controller.selectPin('shop-1');
      final stateBefore = controller.state;
      controller.selectPin('shop-1');
      expect(identical(controller.state, stateBefore), isTrue);
    });
```

- [ ] **Step 4: Run tests**

Run: `flutter test test/map/map_controller_test.dart`
Expected: `+11: All tests passed!` (5 existing + 6 new — the debounce test was replaced, not added, so net +6 over the prior 5; but the new "no auto-fetch" test counts as one of the +1 to the existing 5).

Concretely: existing 5 tests stay (fetchNearby switches mode, stale fetch generation token, fetch error, clearError preserves pins, plus the rewritten no-auto-fetch test) + new tests (refreshForCurrentViewport happy path, error path, no-bounds no-op, selectPin updates, selectPin clears, selectPin no-op-on-same-id) = 11 total.

If any fail, fix and re-run. Do not change tests except for syntax errors.

- [ ] **Step 5: Commit**

```bash
git add test/map/map_controller_test.dart
git commit -m "test(map-trio): cover no-auto-fetch + refreshForCurrentViewport + selectPin

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

# Slice B — `MarkerSourceManager` (clustering)

Goal: Replace `AnimatedMarkerManager` with a Mapbox-native `GeoJsonSource(cluster: true)` + two symbol layers (clusters + individual pins). Tap handlers: cluster tap → flyTo expansion zoom; pin tap → emit callback. Feature-state-based selection visual.

After this slice, the existing app's map renders pins via the new manager (still no carousel, still no pill — those come in Slices C and D). Manual sanity at end of slice: clusters visible at low zoom, expand on zoom-in, taps work.

---

### Task B.1: Verify Mapbox v2.1.0 source/layer API surface

**Files:**
- No file changes — research only.

- [ ] **Step 1: Check `mapbox_maps_flutter` package for the APIs we need**

Run:
```bash
grep -rn "class GeoJsonSource\|class CircleLayer\|class SymbolLayer\|addStyleImage\|setFeatureState\|getClusterExpansionZoom" \
  ~/.pub-cache/hosted/pub.dev/mapbox_maps_flutter-*/lib/ 2>/dev/null | head -40
```

Expected: matches for each of these symbols. Note the exact class names and method signatures the package exposes. If any of these aren't present, STOP and report BLOCKED — the design assumes they exist. Likely alternatives:
- If `setFeatureState` is missing: fall back to data-driven updates (re-push GeoJSON with `selected: true` property on the active feature).
- If `getClusterExpansionZoom` is missing: use a fixed zoom-in increment (current zoom + 2) instead.

- [ ] **Step 2: Note the actual constructor signatures**

For each of `GeoJsonSource`, `CircleLayer`, `SymbolLayer`: print the constructor or factory parameters. Save them in a scratch note (no commit needed); the next tasks reference them.

If the API drifts from what's used in this plan, adjust the code in subsequent tasks to match. The CONCEPT is right (sources, layers, expressions) — the parameter names may vary slightly.

---

### Task B.2: Create `MarkerSourceManager` — source + style image registration

**Files:**
- Create: `lib/core/map/presentation/widgets/marker_source_manager.dart`

- [ ] **Step 1: Create the file with source setup + image registration**

```dart
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:nano_embryo/core/map/config/feature/marker_style.dart';
import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';
import 'package:nano_embryo/core/map/presentation/widgets/canvas_marker_builder.dart';

/// Manages the GeoJSON source + symbol/circle layers that render
/// clustered + individual pins on the Mapbox map.
///
/// Replaces `AnimatedMarkerManager` (PointAnnotationManager-based).
/// Mapbox handles clustering natively at the source level; we layer
/// individual pin images on top via on-demand-registered style images.
class MarkerSourceManager {
  static const String _sourceId = 'engine-pins';
  static const String _layerIndividual = 'engine-pins-individual';
  static const String _layerClusterBubble = 'engine-pins-cluster-bubble';
  static const String _layerClusterCount = 'engine-pins-cluster-count';
  static const String _imageCluster = 'engine-pin-cluster';

  final MapboxMap _mapboxMap;
  final double _clusterRadius;
  final double _clusterMaxZoom;
  final BuildContext _context;
  final MarkerStyleResolver _resolveStyle;
  final void Function(String pinId) _onPinTap;

  /// Style-image names already registered with the map style. Lazy:
  /// only register the (label,color,shape,selected) combos we've seen.
  final Set<String> _registeredImages = {};

  /// Image bytes cache so we don't re-rasterize identical markers.
  final Map<String, Uint8List> _imageBytesCache = {};

  bool _layersAdded = false;
  String? _selectedPinId;
  List<MapPin> _currentPins = const [];

  MarkerSourceManager({
    required MapboxMap mapboxMap,
    required double clusterRadius,
    required double clusterMaxZoom,
    required BuildContext context,
    required MarkerStyleResolver resolveStyle,
    required void Function(String pinId) onPinTap,
  })  : _mapboxMap = mapboxMap,
        _clusterRadius = clusterRadius,
        _clusterMaxZoom = clusterMaxZoom,
        _context = context,
        _resolveStyle = resolveStyle,
        _onPinTap = onPinTap;

  /// Build the source, register the cluster bubble image, and add the
  /// three layers. Idempotent — safe to call once per map lifecycle.
  Future<void> initialize() async {
    if (_layersAdded) return;

    // 1. Register the cluster-bubble image (single image; text overlays).
    final clusterBytes = await CanvasMarkerBuilder.drawClusterMarker(
      count: 0, // count is rendered by the text symbol layer, not the image
      size: 56,
    );
    await _mapboxMap.style.addStyleImage(
      _imageCluster,
      1.0, // scale
      MbxImage(width: 56, height: 56, data: clusterBytes),
      false, // sdf
      const [], // stretchX
      const [], // stretchY
      null, // content
    );

    // 2. Add the GeoJSON source with clustering enabled. Empty until
    //    updatePins is called.
    await _mapboxMap.style.addSource(GeoJsonSource(
      id: _sourceId,
      data: '{"type":"FeatureCollection","features":[]}',
      cluster: true,
      clusterRadius: _clusterRadius,
      clusterMaxZoom: _clusterMaxZoom,
    ));

    // 3. Cluster bubble layer (circle layer with the registered image).
    //    Filter: only cluster features.
    await _mapboxMap.style.addLayer(SymbolLayer(
      id: _layerClusterBubble,
      sourceId: _sourceId,
      iconImage: _imageCluster,
      iconAllowOverlap: true,
      iconIgnorePlacement: true,
      filter: ['has', 'point_count'],
    ));

    // 4. Cluster count overlay (text on top of bubble).
    await _mapboxMap.style.addLayer(SymbolLayer(
      id: _layerClusterCount,
      sourceId: _sourceId,
      textField: ['get', 'point_count_abbreviated'],
      textSize: 14.0,
      textColor: Colors.white.value,
      textAllowOverlap: true,
      textIgnorePlacement: true,
      filter: ['has', 'point_count'],
    ));

    // 5. Individual pin layer. Uses per-feature `iconImage` property
    //    so each pin can have its own style-image name. Filter: only
    //    non-cluster features.
    await _mapboxMap.style.addLayer(SymbolLayer(
      id: _layerIndividual,
      sourceId: _sourceId,
      iconImage: ['get', 'iconImage'],
      iconSize: [
        'case',
        ['boolean', ['feature-state', 'selected'], false],
        1.4,
        1.0,
      ],
      iconAllowOverlap: true,
      iconIgnorePlacement: true,
      filter: ['!', ['has', 'point_count']],
    ));

    _layersAdded = true;

    // Wire tap routing.
    _mapboxMap.onMapTapListener = _handleMapTap;
  }

  // updatePins, selectPin, _handleMapTap, dispose — added in Task B.3 + B.4 + B.5.
}
```

Note: parameter names like `iconImage`, `iconSize`, `filter`, `textField`, `textColor` follow the Mapbox v2.x naming convention. If Task B.1 surfaced different exact names, adapt them here (the concepts are the same).

The `MbxImage` constructor parameters and `addStyleImage` signature are taken from Mapbox v2.x. If different, adjust.

- [ ] **Step 2: Verify the file compiles**

Run: `flutter analyze lib/core/map/presentation/widgets/marker_source_manager.dart`

Expected: a few warnings about unused private fields/methods (`_selectedPinId`, `_currentPins`, `_onPinTap`, etc.) — that's OK; they're consumed by Tasks B.3 / B.4 / B.5. NO errors though. If you see "method/class not found" errors related to Mapbox APIs, this is where you adapt to the actual API surface from Task B.1.

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/presentation/widgets/marker_source_manager.dart
git commit -m "feat(map-trio): MarkerSourceManager skeleton + source + layers (WIP)

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task B.3: Implement `updatePins` — push features + register per-pin images

**Files:**
- Modify: `lib/core/map/presentation/widgets/marker_source_manager.dart`

- [ ] **Step 1: Append `updatePins` and image registration helpers**

Inside the `MarkerSourceManager` class, just before the closing brace, add:

```dart
  /// Push a new list of pins to the source.
  ///
  /// Registers any not-yet-registered marker style images first, then
  /// pushes the GeoJSON. Style-image names are stable across calls so the
  /// same image is reused across re-fetches.
  Future<void> updatePins(List<MapPin> pins) async {
    if (!_layersAdded) return;

    _currentPins = pins;

    // 1. Lazy-register a style image for every unique (label,color,shape)
    //    + selected variant seen in the data.
    for (final pin in pins) {
      final style = _resolveStyle(pin);
      await _ensureStyleImageRegistered(style, isSelected: false);
      await _ensureStyleImageRegistered(style, isSelected: true);
    }

    // 2. Build the GeoJSON FeatureCollection. Each feature carries its
    //    pin id (used by tap routing) and the iconImage name that the
    //    layer expression reads.
    final features = pins.map((pin) {
      final style = _resolveStyle(pin);
      final imageName = _imageNameFor(style, isSelected: false);
      // ignore: avoid_dynamic_calls
      return {
        'type': 'Feature',
        'id': pin.id,
        'properties': {
          'pinId': pin.id,
          'iconImage': imageName,
          'iconImageSelected':
              _imageNameFor(style, isSelected: true),
        },
        'geometry': {
          'type': 'Point',
          'coordinates': [pin.longitude, pin.latitude],
        },
      };
    }).toList();

    final geojson = {
      'type': 'FeatureCollection',
      'features': features,
    };

    await _mapboxMap.style.setStyleSourceProperty(
      _sourceId,
      'data',
      geojson,
    );

    // Selected state may have been set before pins arrived; reapply.
    if (_selectedPinId != null) {
      await _applySelectionState(_selectedPinId!);
    }
  }

  Future<void> _ensureStyleImageRegistered(
    MarkerStyle style, {
    required bool isSelected,
  }) async {
    final name = _imageNameFor(style, isSelected: isSelected);
    if (_registeredImages.contains(name)) return;

    final bytes = await _drawMarkerImage(style, isSelected: isSelected);
    final width = 100.h.toInt();
    final height = 80.w.toInt();

    await _mapboxMap.style.addStyleImage(
      name,
      1.0,
      MbxImage(width: width, height: height, data: bytes),
      false,
      const [],
      const [],
      null,
    );
    _registeredImages.add(name);
  }

  Future<Uint8List> _drawMarkerImage(
    MarkerStyle style, {
    required bool isSelected,
  }) async {
    final cacheKey = _imageNameFor(style, isSelected: isSelected);
    final cached = _imageBytesCache[cacheKey];
    if (cached != null) return cached;

    final bytes = await CanvasMarkerBuilder.drawSimpleMarker(
      typeCode: style.label,
      accentColor: style.color,
      shape: style.shape,
      context: _context,
      isSelected: isSelected,
      width: 100.h,
      height: 80.w,
    );
    _imageBytesCache[cacheKey] = bytes;
    return bytes;
  }

  String _imageNameFor(MarkerStyle style, {required bool isSelected}) {
    return 'engine-pin'
        '-${style.label}'
        '-${style.color.value}'
        '-${style.shape.name}'
        '-${isSelected ? 'sel' : 'norm'}';
  }
```

- [ ] **Step 2: Verify compile**

Run: `flutter analyze lib/core/map/presentation/widgets/marker_source_manager.dart`
Expected: still some warnings (`_applySelectionState`, `_handleMapTap` referenced but not defined yet) — that's fine, they're added in B.4.

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/presentation/widgets/marker_source_manager.dart
git commit -m "feat(map-trio): MarkerSourceManager.updatePins + image registration (WIP)

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task B.4: Implement tap routing + selection state

**Files:**
- Modify: `lib/core/map/presentation/widgets/marker_source_manager.dart`

- [ ] **Step 1: Add `_handleMapTap`, `selectPin`, `_applySelectionState`, `dispose`**

Append inside the `MarkerSourceManager` class, before the closing brace:

```dart
  /// Update the active selection. Either pinId or null (clear).
  Future<void> selectPin(String? pinId) async {
    if (_selectedPinId == pinId) return;

    // Clear old selection.
    if (_selectedPinId != null) {
      await _mapboxMap.setFeatureState(
        sourceId: _sourceId,
        sourceLayerId: null,
        featureId: _selectedPinId!,
        state: '{"selected": false}',
      );
    }

    _selectedPinId = pinId;

    if (pinId != null) {
      await _applySelectionState(pinId);
    }
  }

  Future<void> _applySelectionState(String pinId) async {
    await _mapboxMap.setFeatureState(
      sourceId: _sourceId,
      sourceLayerId: null,
      featureId: pinId,
      state: '{"selected": true}',
    );
  }

  /// Cluster tap → fly to expansion zoom.
  /// Pin tap → emit onPinTap(pinId).
  Future<void> _handleMapTap(ScreenCoordinate screenCoord) async {
    // 1. Check cluster bubble layer first (priority for taps on overlap).
    final clusterFeatures = await _mapboxMap.queryRenderedFeatures(
      RenderedQueryGeometry(
        value: jsonEncodeScreenBox(screenCoord),
        type: Type.SCREEN_BOX,
      ),
      RenderedQueryOptions(
        layerIds: [_layerClusterBubble],
        filter: null,
      ),
    );

    if (clusterFeatures.isNotEmpty) {
      final clusterId = clusterFeatures.first.queriedFeature.feature['id'];
      // Mapbox returns cluster_id inside the feature properties:
      final clusterIdInt =
          (clusterFeatures.first.queriedFeature.feature['properties']
                  as Map?)?['cluster_id'];
      if (clusterIdInt is num) {
        // Compute expansion zoom and fly to it.
        // ignore: deprecated_member_use
        final feature = clusterFeatures.first;
        final geom = feature.queriedFeature.feature['geometry'] as Map;
        final coords = (geom['coordinates'] as List).cast<num>();
        // Mapbox v2 doesn't expose getClusterExpansionZoom directly on
        // GeoJsonSource — fall back to a fixed zoom increment.
        final cameraState = await _mapboxMap.getCameraState();
        await _mapboxMap.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(
                coords[0].toDouble(),
                coords[1].toDouble(),
              ),
            ),
            zoom: cameraState.zoom + 2.0,
          ),
          MapAnimationOptions(duration: 600),
        );
        return;
      }
    }

    // 2. Check individual pin layer.
    final pinFeatures = await _mapboxMap.queryRenderedFeatures(
      RenderedQueryGeometry(
        value: jsonEncodeScreenBox(screenCoord),
        type: Type.SCREEN_BOX,
      ),
      RenderedQueryOptions(
        layerIds: [_layerIndividual],
        filter: null,
      ),
    );

    if (pinFeatures.isNotEmpty) {
      final props =
          pinFeatures.first.queriedFeature.feature['properties'] as Map?;
      final pinId = props?['pinId'] as String?;
      if (pinId != null) _onPinTap(pinId);
    }
  }

  /// Helper to build a small bounding box around a tap point for
  /// queryRenderedFeatures. Mapbox v2 doesn't accept a raw ScreenCoordinate
  /// for box queries; it wants a JSON-encoded geometry. We expand ±10 px.
  String jsonEncodeScreenBox(ScreenCoordinate point) {
    final minX = point.x - 10;
    final maxX = point.x + 10;
    final minY = point.y - 10;
    final maxY = point.y + 10;
    return '{"min": {"x": $minX, "y": $minY}, "max": {"x": $maxX, "y": $maxY}}';
  }

  Future<void> dispose() async {
    _mapboxMap.onMapTapListener = null;
    // Remove layers + source in reverse order. Best-effort: if the map
    // is being torn down, these calls may throw — swallow.
    try {
      await _mapboxMap.style.removeStyleLayer(_layerIndividual);
    } catch (_) {}
    try {
      await _mapboxMap.style.removeStyleLayer(_layerClusterCount);
    } catch (_) {}
    try {
      await _mapboxMap.style.removeStyleLayer(_layerClusterBubble);
    } catch (_) {}
    try {
      await _mapboxMap.style.removeStyleSource(_sourceId);
    } catch (_) {}
    _registeredImages.clear();
    _imageBytesCache.clear();
    _currentPins = const [];
    _selectedPinId = null;
    _layersAdded = false;
  }
```

NOTE on Mapbox API quirks (likely needing tweak per Task B.1's findings):
- The `onMapTapListener` API may be named `onTapListener` or use a different setter pattern.
- `queryRenderedFeatures` signature might differ — adjust as needed.
- `setFeatureState` may take a `Map<String, dynamic>` instead of a JSON string.
- Removing a style layer that doesn't exist may throw — that's why the try/catch wrappers.

If the cluster's `cluster_id` property isn't accessible via that path, the fallback is to use a fixed `+ 2.0` zoom increment (already what this code does). The "ideal" approach with `getClusterExpansionZoom` requires a method that may not exist on the Flutter binding — the fixed increment is the pragmatic substitute.

- [ ] **Step 2: Verify compile**

Run: `flutter analyze lib/core/map/presentation/widgets/marker_source_manager.dart`
Expected: clean (no errors). Some `info`-level deprecation warnings may appear (e.g. `withOpacity` carryover) — acceptable.

If Mapbox API mismatches show up as errors, fix them based on the actual signatures discovered in Task B.1.

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/presentation/widgets/marker_source_manager.dart
git commit -m "feat(map-trio): MarkerSourceManager tap routing + selection state

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task B.5: Wire `MarkerSourceManager` into `MapEngineScreen`

**Files:**
- Modify: `lib/core/map/presentation/screens/map_screen.dart`

- [ ] **Step 1: Replace `AnimatedMarkerManager` with `MarkerSourceManager`**

In `lib/core/map/presentation/screens/map_screen.dart`:

Change the import:
```dart
import 'package:nano_embryo/core/map/presentation/widgets/animated_marker_manager.dart';
```
TO:
```dart
import 'package:nano_embryo/core/map/presentation/widgets/marker_source_manager.dart';
```

Rename the field:
```dart
  AnimatedMarkerManager? _markerManager;
```
TO:
```dart
  MarkerSourceManager? _markerManager;
```

Update `_initMarkerManager`:
```dart
  Future<void> _initMarkerManager() async {
    if (_mapboxMap == null) return;
    _markerManager = AnimatedMarkerManager(_mapboxMap!, context, this);
    await _markerManager?.initialize();
  }
```
TO:
```dart
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
        ref.read(mapControllerProvider.notifier).selectPin(pinId);
      },
    );
    await _markerManager?.initialize();
  }
```

Note: `config.clusterRadius` and `config.clusterMaxZoom` are added to `MapConfig` in Task B.6. If you're following slice order, run B.6 before this step OR temporarily inline the defaults `50` and `14.0` here.

Update `_updateMarkers`:
```dart
  void _updateMarkers(List<MapPin> pins) {
    final config = ref.read(mapConfigProvider);
    _markerManager?.updateMarkers(
      pins,
      (pin) => config.onPinTap(pin, context),
      config.resolveMarkerStyle,
    );
  }
```
TO:
```dart
  void _updateMarkers(List<MapPin> pins) {
    _markerManager?.updatePins(pins);
  }
```

Remove the `onViewportChangeNeeded` wiring inside `_onMapCreated` — it no longer exists on the new manager:
```dart
      _markerManager?.onViewportChangeNeeded = () {
        if (mounted) _onCameraChanged(controller);
      };
```
DELETE the above block. Zoom no longer triggers a fetch (the dirty-flag + pill pattern handles it).

In `dispose()`, the existing call works with both managers since they both have a `dispose()` method:
```dart
    _markerManager?.dispose();
```
KEEP this — no change needed.

- [ ] **Step 2: Add `selectedPinId` listener**

Inside `build()`, alongside the existing `ref.listen<MapState>` block, add:

```dart
    ref.listen<String?>(
      mapControllerProvider.select((s) => s.selectedPinId),
      (prev, next) {
        _markerManager?.selectPin(next);
      },
    );
```

This propagates selection state changes from the controller down to the marker manager so the visual highlight updates.

- [ ] **Step 3: Verify build**

Run: `flutter analyze lib/core/map/presentation/screens/map_screen.dart`
Expected: errors about `clusterRadius` and `clusterMaxZoom` not being on `MapConfig` (resolved in B.6). If you inlined the defaults, no errors expected.

- [ ] **Step 4: Commit**

```bash
git add lib/core/map/presentation/screens/map_screen.dart
git commit -m "feat(map-trio): screen uses MarkerSourceManager; listens for selectedPinId

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task B.6: Add `clusterRadius` and `clusterMaxZoom` to `MapConfig`

**Files:**
- Modify: `lib/core/map/config/feature/map_config.dart`

- [ ] **Step 1: Add the two fields**

In `lib/core/map/config/feature/map_config.dart`, inside the `MapConfig` class, add to the field declarations (after `viewportDebounce`):

```dart
  /// Mapbox cluster radius in screen pixels. Defaults to 50.
  final double clusterRadius;

  /// Maximum zoom at which clusters still form. Beyond this, every pin
  /// is shown individually. Defaults to 14.
  final double clusterMaxZoom;
```

Add them to the constructor parameter list:
```dart
    this.clusterRadius = 50,
    this.clusterMaxZoom = 14,
```

- [ ] **Step 2: Verify build**

Run: `flutter analyze lib/core/map/`
Expected: `No issues found!` (the screen file from B.5 now resolves these fields).

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/config/feature/map_config.dart
git commit -m "feat(map-trio): add clusterRadius + clusterMaxZoom to MapConfig

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task B.7: Delete `AnimatedMarkerManager`

**Files:**
- Delete: `lib/core/map/presentation/widgets/animated_marker_manager.dart`

- [ ] **Step 1: Verify nothing still imports it**

Run:
```bash
grep -rln "animated_marker_manager\|AnimatedMarkerManager" lib/ test/ 2>/dev/null
```
Expected: empty. If any results remain, fix those imports first (they should now refer to `MarkerSourceManager`).

- [ ] **Step 2: Delete the file**

```bash
git rm lib/core/map/presentation/widgets/animated_marker_manager.dart
```

- [ ] **Step 3: Verify build + tests**

Run:
```bash
flutter analyze
flutter test test/map/
```

Expected: analyzer clean (or only pre-existing deprecations); 11 tests pass.

- [ ] **Step 4: Commit**

```bash
git commit -m "refactor(map-trio): delete legacy AnimatedMarkerManager

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

# Slice C — `SearchThisAreaPill`

Goal: A small pill that appears at top-center when `viewportIsDirty == true`. Tap → triggers `refreshForCurrentViewport`. This heals the Slice A regression — panning is usable again.

---

### Task C.1: Add `searchThisAreaLabel` to `MapCopy`

**Files:**
- Modify: `lib/core/map/config/feature/map_copy.dart`

- [ ] **Step 1: Add the field with default**

In `MapCopy`, add `searchThisAreaLabel`:

```dart
class MapCopy extends Equatable {
  final String emptyStateSubtitle;
  final String errorRetryLabel;
  final String locationPermissionTitle;
  final String locationPermissionBody;
  final String locationPermissionCancelLabel;
  final String locationPermissionOpenSettingsLabel;
  final String appLocationMissingSnackbar;
  final String searchThisAreaLabel;

  const MapCopy({
    this.emptyStateSubtitle = 'No results in this area.',
    this.errorRetryLabel = 'Retry',
    this.locationPermissionTitle = 'Location Permission Required',
    this.locationPermissionBody =
        'Please enable location permission to see results near you. '
        'You can change this in your device settings.',
    this.locationPermissionCancelLabel = 'Cancel',
    this.locationPermissionOpenSettingsLabel = 'Open Settings',
    this.appLocationMissingSnackbar = 'Set your location first.',
    this.searchThisAreaLabel = 'Search this area',
  });

  @override
  List<Object?> get props => [
        emptyStateSubtitle,
        errorRetryLabel,
        locationPermissionTitle,
        locationPermissionBody,
        locationPermissionCancelLabel,
        locationPermissionOpenSettingsLabel,
        appLocationMissingSnackbar,
        searchThisAreaLabel,
      ];
}
```

- [ ] **Step 2: Verify build**

Run: `flutter analyze lib/core/map/config/feature/map_copy.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/config/feature/map_copy.dart
git commit -m "feat(map-trio): add searchThisAreaLabel to MapCopy

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task C.2: Create `SearchThisAreaPill` widget

**Files:**
- Create: `lib/core/map/presentation/widgets/search_this_area_pill.dart`

- [ ] **Step 1: Create the widget**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/map/config/feature/map_config.dart';
import 'package:nano_embryo/core/map/presentation/controllers/map_controller.dart';
import 'package:nano_embryo/core/map/presentation/providers/map_filter_providers.dart';
import 'package:nano_embryo/core/utils/animations/animated_scale_fade.dart';

/// Floats at top-center of the map. Visible when the user has panned
/// since the last fetch (`MapState.viewportIsDirty == true`). Tapping
/// triggers `MapController.refreshForCurrentViewport`.
class SearchThisAreaPill extends ConsumerWidget {
  const SearchThisAreaPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDirty = ref.watch(
      mapControllerProvider.select((s) => s.viewportIsDirty),
    );
    final isFetching = ref.watch(
      mapControllerProvider.select((s) => s.isFetching),
    );
    final copy = ref.watch(mapConfigProvider.select((c) => c.copy));
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedScaleFade(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      child: isDirty
          ? GestureDetector(
              onTap: isFetching
                  ? null
                  : () {
                      final controller =
                          ref.read(mapControllerProvider.notifier);
                      final filters = ref.read(mapFiltersProvider);
                      controller.refreshForCurrentViewport(filters);
                    },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.lg.w,
                  vertical: Spacing.sm.h,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isFetching) ...[
                      SizedBox(
                        width: 14.w,
                        height: 14.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: Spacing.sm.w),
                    ] else ...[
                      Icon(
                        Icons.search,
                        size: 16.r,
                        color: colorScheme.onPrimary,
                      ),
                      SizedBox(width: Spacing.xs.w),
                    ],
                    Text(
                      copy.searchThisAreaLabel,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
```

If `AnimatedScaleFade` doesn't support a nullable / shrinking child cleanly, wrap the conditional differently. Verify the file analyzes cleanly.

- [ ] **Step 2: Verify build**

Run: `flutter analyze lib/core/map/presentation/widgets/search_this_area_pill.dart`
Expected: clean (or only the project-wide pre-existing `withOpacity` deprecation info).

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/presentation/widgets/search_this_area_pill.dart
git commit -m "feat(map-trio): SearchThisAreaPill widget

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task C.3: Mount the pill in `MapEngineScreen`

**Files:**
- Modify: `lib/core/map/presentation/screens/map_screen.dart`

- [ ] **Step 1: Add the import**

Add at the top with the other widget imports:
```dart
import 'package:nano_embryo/core/map/presentation/widgets/search_this_area_pill.dart';
```

- [ ] **Step 2: Add the pill to the Stack**

Inside the `Stack` in `build()`, AFTER the empty-state / error-state cards but BEFORE the `MapFabColumn`, add:

```dart
            Positioned(
              top: MediaQuery.of(context).padding.top + Spacing.lg.h,
              left: 0,
              right: 0,
              child: const Center(child: SearchThisAreaPill()),
            ),
```

- [ ] **Step 3: Verify build**

Run: `flutter analyze lib/core/map/presentation/screens/map_screen.dart`
Expected: clean.

- [ ] **Step 4: Manual sanity (Slice A regression healed)**

Run: `flutter run --flavor development`. Navigate to the map. Pan the map → pill should appear at top-center. Tap pill → fetch fires, pill disappears, pins refresh. Pan again → pill reappears.

If this works, Slice C is the first user-visible new feature. Don't yet expect clustering visuals or carousel — those are B (already done) and D (coming next).

- [ ] **Step 5: Commit**

```bash
git add lib/core/map/presentation/screens/map_screen.dart
git commit -m "feat(map-trio): mount SearchThisAreaPill in MapEngineScreen

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

# Slice D — `MapPinCarousel` + selection sync

Goal: An always-visible horizontal carousel at the bottom. Bidirectional sync: marker tap scrolls the carousel; carousel swipe flies the camera. Card tap opens existing `ShopInfoBottomSheetLoader`.

---

### Task D.1: Add `buildCarouselCard` to `MapConfig`

**Files:**
- Modify: `lib/core/map/config/feature/map_config.dart`

- [ ] **Step 1: Add the required field**

In `MapConfig`, add after `onPinTap`:

```dart
  /// Builds one card for the horizontal carousel. Called per visible pin.
  /// Receives [isSelected] so the card can highlight when its marker
  /// is the active selection.
  final Widget Function(MapPin pin, bool isSelected, BuildContext context)
      buildCarouselCard;
```

Add to the constructor's required-params block (alongside the other required fields):
```dart
    required this.buildCarouselCard,
```

- [ ] **Step 2: Verify build**

Run: `flutter analyze lib/core/map/config/feature/map_config.dart`
Expected: clean.

The NanoEmbryo per-app config (`lib/core/map/config/map_config.dart`) will now fail to compile because it doesn't pass `buildCarouselCard`. We fix that in Task D.5.

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/config/feature/map_config.dart
git commit -m "feat(map-trio): MapConfig.buildCarouselCard required field (WIP, app config to follow)

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task D.2: Create `MapPinCarousel`

**Files:**
- Create: `lib/core/map/presentation/widgets/map_pin_carousel.dart`

- [ ] **Step 1: Create the file**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:nano_embryo/core/map/config/feature/map_config.dart';
import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';
import 'package:nano_embryo/core/map/presentation/controllers/map_controller.dart';

/// Always-visible horizontal carousel at the bottom of the map.
///
/// Bidirectional sync with marker selection:
/// - Page change → `controller.selectPin(pinId)`. The screen listens
///   and flies the camera to the selected pin.
/// - `selectedPinId` change (from outside, e.g. marker tap) →
///   carousel animates to that page. The `_isProgrammaticChange` flag
///   prevents the listener loop.
///
/// Hidden (zero-height) when there are no pins.
class MapPinCarousel extends ConsumerStatefulWidget {
  const MapPinCarousel({super.key});

  @override
  ConsumerState<MapPinCarousel> createState() => _MapPinCarouselState();
}

class _MapPinCarouselState extends ConsumerState<MapPinCarousel> {
  static const double _carouselHeight = 200;
  static const double _viewportFraction = 0.85;

  late final PageController _pageController;
  bool _isProgrammaticChange = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _viewportFraction);
    _pageController.addListener(_onPageScroll);
  }

  void _onPageScroll() {
    if (_isProgrammaticChange) return;
    if (!_pageController.hasClients || _pageController.page == null) return;
    final pins = ref.read(mapControllerProvider).pins;
    if (pins.isEmpty) return;

    final pageIndex = _pageController.page!.round();
    if (pageIndex < 0 || pageIndex >= pins.length) return;

    final pin = pins[pageIndex];
    final currentSelected = ref.read(mapControllerProvider).selectedPinId;
    if (currentSelected != pin.id) {
      ref.read(mapControllerProvider.notifier).selectPin(pin.id);
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pins = ref.watch(mapControllerProvider.select((s) => s.pins));
    final selectedId = ref.watch(
      mapControllerProvider.select((s) => s.selectedPinId),
    );
    final config = ref.watch(mapConfigProvider);

    // External selection change → animate carousel to that page.
    ref.listen<String?>(
      mapControllerProvider.select((s) => s.selectedPinId),
      (prev, next) {
        if (next == null) return;
        final index = pins.indexWhere((p) => p.id == next);
        if (index < 0) return;
        if (!_pageController.hasClients) return;
        // If page already there (e.g. set by us via _onPageScroll), skip.
        final current = _pageController.page?.round();
        if (current == index) return;

        _isProgrammaticChange = true;
        _pageController
            .animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            )
            .then((_) {
          if (mounted) {
            Future<void>.delayed(const Duration(milliseconds: 50), () {
              _isProgrammaticChange = false;
            });
          }
        });
      },
    );

    if (pins.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: _carouselHeight.h,
      child: PageView.builder(
        controller: _pageController,
        itemCount: pins.length,
        itemBuilder: (context, index) {
          final pin = pins[index];
          final isSelected = pin.id == selectedId;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => config.onPinTap(pin, context),
            child: config.buildCarouselCard(pin, isSelected, context),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Verify build**

Run: `flutter analyze lib/core/map/presentation/widgets/map_pin_carousel.dart`
Expected: clean.

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/presentation/widgets/map_pin_carousel.dart
git commit -m "feat(map-trio): MapPinCarousel with bidirectional selection sync

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task D.3: Mount the carousel in `MapEngineScreen` + fly camera on selection

**Files:**
- Modify: `lib/core/map/presentation/screens/map_screen.dart`

- [ ] **Step 1: Add the import**

Add at the top:
```dart
import 'package:nano_embryo/core/map/presentation/widgets/map_pin_carousel.dart';
```

- [ ] **Step 2: Add carousel to the Stack and adjust FAB positioning**

Inside the `Stack`, BELOW all overlays (loading, empty, error) and AFTER the `MapFabColumn`, add:

```dart
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: const MapPinCarousel(),
            ),
```

The FABs (in `MapFabColumn`) should sit above the carousel when it's present. Look at the existing `Positioned` block for the FABs in `MapFabColumn` and adjust the bottom-offset constants there — increase by 200.h to account for the carousel.

This is done by modifying `lib/core/map/presentation/widgets/map_fab_column.dart`:

Open it. The `Positioned` blocks currently use bottoms like `Spacing.xxl.h + Spacing.xxl.h` and `Spacing.lg.h + Spacing.md.h`. Change them to:
```dart
        Positioned(
          bottom: 200.h + Spacing.xxl.h + Spacing.xxl.h, // existing offset + carousel reserve
          right: Spacing.md.w,
          // …rest unchanged
```
and similarly for the second `Positioned`:
```dart
          bottom: 200.h + Spacing.lg.h + Spacing.md.h,
```

This pushes the FABs above the carousel area regardless of whether the carousel is currently rendering pins (we reserve the space unconditionally). This is the documented design.

- [ ] **Step 3: Camera fly-to on selection change**

In `MapEngineScreen.build()`, add a new `ref.listen` AFTER the existing `selectedPinId` listener (the one added in B.5 for the marker manager):

```dart
    ref.listen<String?>(
      mapControllerProvider.select((s) => s.selectedPinId),
      (prev, next) {
        if (next == null) return;
        final pin = mapState.pins.firstWhere(
          (p) => p.id == next,
          orElse: () => MapPin(id: '', latitude: 0, longitude: 0),
        );
        if (pin.id.isEmpty) return;
        // Fly camera to the selected pin without changing zoom.
        _mapboxMap?.flyTo(
          CameraOptions(
            center: Point(coordinates: Position(pin.longitude, pin.latitude)),
          ),
          MapAnimationOptions(duration: 400),
        );
      },
    );
```

Note: `mapState` is already captured at the top of `build()` — this listener uses it via closure. If reading `mapState.pins` at listener fire-time is stale, switch to `ref.read(mapControllerProvider).pins` inside the listener body. Either works for this flow.

- [ ] **Step 4: Verify build**

Run: `flutter analyze lib/core/map/`
Expected: clean.

- [ ] **Step 5: Commit**

```bash
git add lib/core/map/presentation/screens/map_screen.dart lib/core/map/presentation/widgets/map_fab_column.dart
git commit -m "feat(map-trio): mount MapPinCarousel; FABs lift above; camera flies on selection

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task D.4: Create `ShopMapCard` (per-app compact card)

**Files:**
- Create: `lib/presentation/features/shops/query/presentation/widgets/shop_map_card.dart`

- [ ] **Step 1: Inspect what shop data is reachable from `MapPin.data`**

The current `SupabaseShopMapDataSource._rowsToPins` packs `shop_type` and `luxury_level` into `pin.data`. The card needs richer info (image, name, rating, price, distance). Two options:
- (a) Pack more fields into the data source's RPC return (adds backend work + DB migration).
- (b) Lazy-load shop details inside the card via the existing `mapShopProvider(pinId)` async provider used by `ShopInfoBottomSheetLoader`.

Choose **(b)** for this slice — no backend changes, reuse existing data path. The card shows a skeleton while loading, then renders.

- [ ] **Step 2: Create the card**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/map_shop_provider.dart';

/// Compact carousel card for a shop on the map.
///
/// Lazy-loads full shop details via `mapShopProvider(pin.id)`. Shows
/// a skeleton state while loading and a thin error placeholder on
/// failure. When [isSelected] is true the card gets a primary-color
/// border to mirror the active marker.
class ShopMapCard extends ConsumerWidget {
  final MapPin pin;
  final bool isSelected;

  const ShopMapCard({
    super.key,
    required this.pin,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final shopAsync = ref.watch(mapShopProvider(pin.id));

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sm.w,
        vertical: Spacing.md.h,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(BorderRadiusTokens.lg),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.15),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.10 : 0.05),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: shopAsync.when(
          loading: () => _buildSkeleton(context),
          error: (e, st) => _buildError(context, e),
          data: (shop) {
            if (shop == null) return _buildError(context, 'No data');
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cover image
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(BorderRadiusTokens.lg),
                    bottomLeft: Radius.circular(BorderRadiusTokens.lg),
                  ),
                  child: SizedBox(
                    width: 140.w,
                    child: shop.coverImageUrl.isEmpty
                        ? Container(color: colorScheme.surfaceVariant)
                        : Image.network(
                            shop.coverImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: colorScheme.surfaceVariant),
                          ),
                  ),
                ),
                // Right side text
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(Spacing.md.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          shop.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          shop.shopType,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 16.r,
                              color: Colors.amber.shade700,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              shop.rating.toStringAsFixed(1),
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: Spacing.sm.w),
                            Text(
                              '(${shop.reviewCount})',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              shop.luxuryLevel,
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 140.w,
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(BorderRadiusTokens.lg),
              bottomLeft: Radius.circular(BorderRadiusTokens.lg),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(Spacing.md.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 14.h,
                  width: 120.w,
                  color: colorScheme.surfaceVariant,
                ),
                Container(
                  height: 10.h,
                  width: 80.w,
                  color: colorScheme.surfaceVariant,
                ),
                Container(
                  height: 12.h,
                  width: 60.w,
                  color: colorScheme.surfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, Object? error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Spacing.md.w),
        child: Text(
          'Failed to load',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
      ),
    );
  }
}
```

Important: this references fields on the loaded shop object — `name`, `shopType`, `coverImageUrl`, `rating`, `reviewCount`, `luxuryLevel`. Inspect what `mapShopProvider(pinId)` actually returns (presumably a `ShopListItemDTO` or similar — see the import in `shop_info_bottom_sheet_loader.dart`). If the field names differ, adapt the references in the `data:` branch. Don't invent fields.

Run:
```bash
grep -n "class ShopListItemDTO\|final" lib/presentation/features/shops/query/data/models/dtos/shop_list_item_dto.dart | head -20
```
to discover the actual DTO shape, then update the card's field accesses to match.

- [ ] **Step 3: Verify build**

Run: `flutter analyze lib/presentation/features/shops/query/presentation/widgets/shop_map_card.dart`
Expected: clean (after adapting field names from Step 2).

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/features/shops/query/presentation/widgets/shop_map_card.dart
git commit -m "feat(shop-query): ShopMapCard compact card for map carousel

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task D.5: Wire `buildCarouselCard` in `buildNanoEmbryoMapConfig`

**Files:**
- Modify: `lib/core/map/config/map_config.dart`

- [ ] **Step 1: Add the import**

```dart
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_map_card.dart';
```

- [ ] **Step 2: Add the field to the `MapConfig(...)` invocation**

Inside `buildNanoEmbryoMapConfig()`, in the `return MapConfig(...)`, add a new named argument (e.g. between `onPinTap` and `fallback`):

```dart
    buildCarouselCard: (pin, isSelected, context) => ShopMapCard(
      pin: pin,
      isSelected: isSelected,
    ),
```

- [ ] **Step 3: Verify build**

Run: `flutter analyze lib/core/map/ lib/main.dart`
Expected: clean.

- [ ] **Step 4: Run tests**

Run: `flutter test test/map/`
Expected: 11 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/map/config/map_config.dart
git commit -m "feat(map-trio): wire ShopMapCard via buildCarouselCard in NanoEmbryo config

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

# Slice E — Final wiring, docs, verification

Goal: Cleanup, update the engine docs, manual end-to-end verification.

---

### Task E.1: Remove dead `viewportDebounce` plumbing

**Files:**
- Modify: `lib/core/map/presentation/controllers/map_controller.dart`

The `viewportDebounce` field on `MapConfig` and the `_debounce` field on `MapController` became dead in Slice A. Clean them up.

- [ ] **Step 1: Delete `_debounce` field + constructor param**

In `MapController`:
- Remove the field `final Duration _debounce;`
- Remove the constructor parameter `required Duration viewportDebounce,`
- Remove the initializer `_debounce = viewportDebounce,` (delete the comma chain entry).

The provider needs an update too. At the bottom of the same file:

```dart
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
```

Drop the `viewportDebounce` line:

```dart
final mapControllerProvider =
    StateNotifierProvider<MapController, MapState>((ref) {
  final config = ref.watch(mapConfigProvider);
  return MapController(
    dataSource: config.dataSource,
    viewportLimit: config.viewportLimit,
    nearbyLimit: config.nearbyLimit,
  );
});
```

- [ ] **Step 2: Delete `viewportDebounce` from `MapConfig`**

In `lib/core/map/config/feature/map_config.dart`:
- Delete the field `final Duration viewportDebounce;`
- Delete the parameter `this.viewportDebounce = const Duration(milliseconds: 500),`

- [ ] **Step 3: Update tests (the controller test setUp passes viewportDebounce)**

In `test/map/map_controller_test.dart`, the `setUp` creates `MapController(...)` with `viewportDebounce: const Duration(milliseconds: 50)`. Remove that argument:

```dart
      controller = MapController(
        dataSource: fake,
        viewportLimit: 100,
        nearbyLimit: 50,
      );
```

- [ ] **Step 4: Verify + run tests**

Run:
```bash
flutter analyze lib/core/map/
flutter test test/map/
```
Expected: clean; 11 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/map/presentation/controllers/map_controller.dart lib/core/map/config/feature/map_config.dart test/map/map_controller_test.dart
git commit -m "refactor(map-trio): remove dead viewportDebounce now that updateViewport doesn't fetch

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task E.2: Update `architecture/MAP_ENGINE.md`

**Files:**
- Modify: `architecture/MAP_ENGINE.md`

- [ ] **Step 1: Document the new fields and interactions**

Open `architecture/MAP_ENGINE.md`. Find the section that lists `MapConfig` fields (likely the "What you get out of the box" or the example builder). Add the three new fields:

In the example builder code block, add (alongside `onPinTap`):
```dart
    buildCarouselCard: (pin, isSelected, context) => MyCard(pin: pin, isSelected: isSelected),
    clusterRadius: 50,
    clusterMaxZoom: 14,
```

In the "What you get out of the box" table (or equivalent), add rows:
```
| Clustering | Mapbox-native; cluster bubbles expand on zoom-in |
| Search-this-area pill | Pan-to-explore pattern; user explicitly triggers fetches |
| Card carousel | Always-visible bottom carousel synced bidirectionally with markers |
```

Find the section describing interaction semantics (likely the "Mount the screen" section) and add a new subsection:

```markdown
## Interaction semantics (post-trio)

- **Initial load**: auto-fetch via 3-tier fallback (GPS → app-location → configured fallback). No pill.
- **User pans/zooms**: `viewportIsDirty: true`. The `Search this area` pill appears at top-center. NO auto-fetch.
- **User taps the pill**: explicit fetch fires for the current viewport. Pill hides on success.
- **User taps a marker**: carousel scrolls to that pin's card; marker becomes visually selected (1.4× scale + primary color). NO modal.
- **User swipes the carousel**: corresponding marker becomes selected; camera flies to that pin (zoom unchanged).
- **User taps a card**: `config.onPinTap(pin, ctx)` fires — opens whatever modal/screen the app wires up (`ShopInfoBottomSheetLoader` in NanoEmbryo).
- **User taps a cluster bubble**: camera flies in by ~+2 zoom levels until the cluster splits.
```

Add a brief note about the new copy field in the "Files to change per app" or equivalent section:

```
| `MapCopy.searchThisAreaLabel` | Override for non-English locales. Default `'Search this area'`. |
```

- [ ] **Step 2: Verify markdown renders**

Open `architecture/MAP_ENGINE.md` in your preview tool; visually confirm the new sections render cleanly.

- [ ] **Step 3: Commit**

```bash
git add architecture/MAP_ENGINE.md
git commit -m "docs(map-engine): document clustering, search-area pill, card carousel

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task E.3: Manual end-to-end verification

This is the regression gate for the entire trio. No commit.

- [ ] **Step 1: Launch the app**

```bash
flutter run --flavor development
```

- [ ] **Step 2: Walk through the 8-step trio verification**

In addition to the existing 11-step engine verification, run these new steps:

12. **Cluster zoom-in** — Pan/zoom out to a country-level view → see cluster bubbles with counts → tap one → camera flies in by ~2 zoom levels → bubble splits into individual pins. Continue until bubbles fully split.

13. **`Search this area` flow** — Pan the map a small amount → pill appears at top-center → tap pill → spinner replaces the search icon briefly → pins refresh → pill hides. Pan again → pill reappears.

14. **Marker → carousel sync** — Tap a marker → carousel scrolls to that pin's card (animated, ~300ms) → marker is visually distinct (1.4× scale + primary color background).

15. **Carousel → marker sync** — Swipe carousel left/right → camera flies to corresponding pin (zoom unchanged) → marker becomes selected.

16. **Card tap** — Tap any card → existing `ShopInfoBottomSheetLoader` opens with the shop details. Dismiss → return to map with selection intact.

17. **Selection clears on `Search this area`** — Select a marker → tap pill → after refresh, no marker is selected (highlight cleared) AND `selectedPinId` is null in the controller state.

18. **Carousel hides when empty** — Pan to an empty area → tap pill → carousel collapses (zero height); existing FAB position remains stable thanks to the reserved space.

19. **Cluster + carousel coexistence** — Zoom out enough that clusters show → carousel still works because it draws from `state.pins` (the full list).

20. **No more legacy stagger / bounce** — Confirm the old per-marker stagger-in animation and the bounce-on-tap are gone (replaced by persistent selection state). This is intentional; if you see them, the marker source manager didn't fully replace `AnimatedMarkerManager`.

21. **Existing FABs still work** — GPS FAB and app-location FAB still trigger their fetches and highlight correctly. Pan after FAB-triggered fetch → pill appears (fetchMode switches to browse).

- [ ] **Step 3: If ANY step fails, fix the underlying issue before proceeding**

Don't skip the verification or "explain away" issues. If a step fails, file the failure mode in your head (or via the user), fix the responsible code, re-run the affected step.

Common failure modes to look out for:
- Pill doesn't appear → `viewportIsDirty` not being set in `updateViewport`. Check the screen's `_onCameraChanged` calls `controller.updateViewport`.
- Cluster bubbles don't appear → style image registration failed, or the source's `cluster: true` wasn't honored. Check the addStyleImage call and source creation.
- Carousel doesn't scroll on marker tap → `selectPin` not being called from the marker manager's onPinTap callback, or the carousel's external-listener isn't firing.
- Camera flies wrong direction → coordinate order (Position takes longitude FIRST, latitude SECOND). Easy bug.
- FAB icons disappear → check the bottom offsets in `MapFabColumn` — too high pushes them off screen.

---

### Task E.4: Final analyzer + test pass

- [ ] **Step 1: Run full analyzer**

```bash
flutter analyze 2>&1 | tail -20
```
Expected: no NEW errors. Pre-existing `withOpacity` deprecation warnings are fine.

- [ ] **Step 2: Run full test suite**

```bash
flutter test 2>&1 | tail -5
```
Expected: 11 map tests pass; ~258 total project tests; the 4 pre-existing chat test failures remain.

- [ ] **Step 3: Spot-check engine boundary**

```bash
grep -rn -i "shop\|luxury\|salon" lib/core/map/ \
  | grep -v "config/map_config.dart"
```
Expected: empty. (The per-app `lib/core/map/config/map_config.dart` legitimately references shop terms; everything else in `lib/core/map/` must stay generic.)

- [ ] **Step 4: If anything surfaced needing cleanup, commit**

```bash
git add -A
git commit -m "chore(map-trio): final cleanup after manual verification

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Done

The trio is shipped. Trio-specific commits live between [HEAD of slice A start] and the final cleanup commit. Engine guide is updated. The manual verification flow now covers steps 1–21.

**Highlights of what's now possible:**
- Drop the engine into a second app for events/listings: provide a `buildCarouselCard` callback that returns an event card; the rest works unchanged.
- Tune cluster behavior per app via `clusterRadius` / `clusterMaxZoom`.
- Localize the pill via `MapCopy.searchThisAreaLabel`.
