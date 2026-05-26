# Map Engine Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor `lib/presentation/features/map/` into a self-contained drop-in engine at `lib/core/map/`, mirroring the existing notification engine. After this plan, switching the map between shops, events, or any other data source requires editing one file (`lib/core/map/config/map_config.dart`) plus a per-app `MapDataSource` implementation.

**Architecture:** Generic engine in `core/map/` owns the Mapbox lifecycle, controller (state/debounce/generation tokens), filter bar, marker animation, FAB column, and screen layout. A single `MapConfig` (analogous to `NotificationConfig`) supplies the app-specific bits: a `MapDataSource` adapter for fetches, a `MapFilterSchema` for the filter bar, a `MarkerStyleResolver` for marker visuals, copy strings, fallback coordinates, and a tap callback. Pins are represented by an untyped `MapPin { id, lat, lng, data }` (mirroring `ScheduledNotification.metadata`).

**Tech Stack:** Flutter, Riverpod (hand-written `Provider`/`StateNotifierProvider`), Mapbox (`mapbox_maps_flutter`), Supabase, Equatable.

**Reference patterns in this codebase:**
- `lib/core/notifications/config/feature/notification_config.dart` — generic class + `notificationConfigProvider` declaration
- `lib/core/notifications/config/notification_config.dart` — per-app `buildNanoEmbryoNotificationConfig()` builder (the ONE file that changes per app)
- `lib/core/notifications/NOTIFICATION_ENGINE.md` — integration guide to mirror
- `lib/main.dart:119-121` — how the override is wired

**Spec:** [docs/superpowers/specs/2026-05-25-map-engine-design.md](docs/superpowers/specs/2026-05-25-map-engine-design.md)

---

## File structure (final state)

```
lib/core/map/
├── MAP_ENGINE.md                                           # NEW — integration guide
├── config/
│   ├── feature/
│   │   ├── map_config.dart                                 # NEW — class + mapConfigProvider
│   │   ├── map_filter_schema.dart                          # NEW
│   │   ├── marker_style.dart                               # NEW
│   │   ├── map_copy.dart                                   # NEW (defaults inside)
│   │   └── map_fallback.dart                               # NEW
│   └── map_config.dart                                     # NEW — buildNanoEmbryoMapConfig()
├── domain/
│   ├── entities/
│   │   ├── map_pin.dart                                    # NEW
│   │   ├── map_bounds.dart                                 # MOVED from features/map/
│   │   └── lat_lng.dart                                    # NEW (engine-local)
│   └── data_source/
│       └── map_data_source.dart                            # NEW (interface)
└── presentation/
    ├── providers/
    │   └── map_filter_providers.dart                       # NEW (generic)
    ├── controllers/
    │   └── map_controller.dart                             # MOVED from features/map/, genericised
    ├── screens/
    │   └── map_screen.dart                                 # MOVED — class renamed MapEngineScreen
    └── widgets/
        ├── map_filter_bar.dart                             # MOVED, schema-driven
        ├── animated_marker_manager.dart                    # MOVED, uses MarkerStyleResolver
        ├── canvas_marker_builder.dart                      # MOVED, extended with MarkerShape
        └── map_fab_column.dart                             # NEW (extracted from screen)

lib/presentation/features/discover/data/
├── supabase_shop_map_datasource.dart                       # NEW (app-side MapDataSource impl)
└── marker_code_generator.dart                              # MOVED from features/map/data/

test/map/
├── map_pin_test.dart                                       # NEW
├── map_filter_schema_test.dart                             # NEW
└── map_controller_test.dart                                # NEW

lib/main.dart                                               # MODIFIED — add mapConfigProvider override
lib/presentation/home/home_screen.dart                      # MODIFIED — mount MapEngineScreen
lib/presentation/features/map/                              # DELETED at slice 6
```

---

# Slice 1 — Entities & data source contract

Goal: create the generic `MapPin`, `LatLng`, `MapBounds`, and `MapDataSource` types. Add a temporary adapter so the existing `MapScreen` keeps working without touching it.

---

### Task 1.1: Create `LatLng` engine-local value type

**Files:**
- Create: `lib/core/map/domain/entities/lat_lng.dart`

- [ ] **Step 1: Create file with full content**

```dart
import 'package:equatable/equatable.dart';

/// Engine-local lightweight coordinate pair.
///
/// Kept independent of `geolocator.Position` and Mapbox's `Point` so that
/// the engine has no dependency on either when consumers wire in their
/// own location providers.
class LatLng extends Equatable {
  final double latitude;
  final double longitude;

  const LatLng({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}
```

- [ ] **Step 2: Verify build**

Run: `flutter analyze lib/core/map/domain/entities/lat_lng.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/domain/entities/lat_lng.dart
git commit -m "feat(map-engine): add LatLng value type"
```

---

### Task 1.2: Create `MapPin` entity

**Files:**
- Create: `lib/core/map/domain/entities/map_pin.dart`
- Test: `test/map/map_pin_test.dart`

- [ ] **Step 1: Write failing test**

Create `test/map/map_pin_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';

void main() {
  group('MapPin', () {
    test('two pins with same fields are equal', () {
      const a = MapPin(
        id: 'shop-1',
        latitude: 6.5244,
        longitude: 3.3792,
        data: {'shop_type': 'salon', 'luxury_level': 'Luxury'},
      );
      const b = MapPin(
        id: 'shop-1',
        latitude: 6.5244,
        longitude: 3.3792,
        data: {'shop_type': 'salon', 'luxury_level': 'Luxury'},
      );

      expect(a, equals(b));
    });

    test('pins differ when data map differs', () {
      const a = MapPin(
        id: 'shop-1',
        latitude: 6.5244,
        longitude: 3.3792,
        data: {'shop_type': 'salon'},
      );
      const b = MapPin(
        id: 'shop-1',
        latitude: 6.5244,
        longitude: 3.3792,
        data: {'shop_type': 'barbershop'},
      );

      expect(a, isNot(equals(b)));
    });

    test('data defaults to empty map', () {
      const pin = MapPin(id: 'x', latitude: 0, longitude: 0);
      expect(pin.data, isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/map/map_pin_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:nano_embryo/core/map/domain/entities/map_pin.dart'`

- [ ] **Step 3: Create `MapPin`**

Create `lib/core/map/domain/entities/map_pin.dart`:

```dart
import 'package:equatable/equatable.dart';

/// Universal map entity. Replaces per-app DTOs (`ShopLocationDTO`,
/// future `EventLocationDTO`, etc.).
///
/// App-specific fields go in [data] — read with `pin.data['shop_type']`
/// from the resolver/tap callback in your `MapConfig`. Mirrors the
/// `ScheduledNotification.metadata` pattern from the notification engine.
class MapPin extends Equatable {
  final String id;
  final double latitude;
  final double longitude;
  final Map<String, dynamic> data;

  const MapPin({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.data = const {},
  });

  @override
  List<Object?> get props => [id, latitude, longitude, data];
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/map/map_pin_test.dart`
Expected: `+3: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/core/map/domain/entities/map_pin.dart test/map/map_pin_test.dart
git commit -m "feat(map-engine): add MapPin entity with equality tests"
```

---

### Task 1.3: Move `MapBounds` into `core/map`

**Files:**
- Create: `lib/core/map/domain/entities/map_bounds.dart`
- Modify (later in slice 2): `lib/presentation/features/map/presentation/controllers/map_controller.dart` (will re-export)

- [ ] **Step 1: Create the new file**

Create `lib/core/map/domain/entities/map_bounds.dart`:

```dart
import 'package:equatable/equatable.dart';

/// Axis-aligned bounding box for viewport queries on the map.
class MapBounds extends Equatable {
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

  bool isValid() => north > south && east > west;

  @override
  List<Object?> get props => [north, south, east, west];
}
```

- [ ] **Step 2: Update old `map_controller.dart` to re-export the moved type**

Modify the top of `lib/presentation/features/map/presentation/controllers/map_controller.dart` and DELETE the existing `class MapBounds` block (lines 71-87 in current file):

Add at top of imports section:
```dart
import 'package:nano_embryo/core/map/domain/entities/map_bounds.dart';
export 'package:nano_embryo/core/map/domain/entities/map_bounds.dart' show MapBounds;
```

Delete the old class definition block:
```dart
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
```

- [ ] **Step 3: Verify build**

Run: `flutter analyze lib/`
Expected: `No issues found!` (any callers importing `MapBounds` from the old controller path keep working via the `export`)

- [ ] **Step 4: Commit**

```bash
git add lib/core/map/domain/entities/map_bounds.dart lib/presentation/features/map/presentation/controllers/map_controller.dart
git commit -m "refactor(map-engine): move MapBounds to core/map/domain"
```

---

### Task 1.4: Create `MapDataSource` interface

**Files:**
- Create: `lib/core/map/domain/data_source/map_data_source.dart`

- [ ] **Step 1: Create file**

```dart
import 'package:nano_embryo/core/map/domain/entities/map_bounds.dart';
import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';

/// Abstract adapter the engine calls to fetch pins.
///
/// Each app provides one concrete implementation (e.g.
/// `SupabaseShopMapDataSource`) and references it from `MapConfig`.
/// The engine itself never knows what backend or what entity shape
/// is being queried — it only consumes [MapPin] lists.
///
/// The `filters` map is assembled by the engine from
/// `MapFilterSchema`'s primary/secondary selections. Adapters pull
/// the keys they recognise (e.g. `filters['shop_type']`) and ignore
/// the rest.
abstract class MapDataSource {
  Future<List<MapPin>> fetchInViewport({
    required MapBounds bounds,
    required Map<String, dynamic> filters,
    int limit = 100,
  });

  Future<List<MapPin>> fetchNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
    required Map<String, dynamic> filters,
    int limit = 50,
  });
}
```

- [ ] **Step 2: Verify build**

Run: `flutter analyze lib/core/map/`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/domain/data_source/map_data_source.dart
git commit -m "feat(map-engine): add MapDataSource interface"
```

---

### Task 1.5: Verify nothing has regressed

- [ ] **Step 1: Run full analyzer**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 2: Run existing test suite**

Run: `flutter test`
Expected: all tests pass (no new failures introduced by Slice 1)

If any tests fail that were already broken, note them but do not fix in this plan — they're pre-existing.

---

# Slice 2 — Generic controller

Goal: create a generic `MapController` in `core/map/` that operates on `List<MapPin>` and `Map<String, dynamic>` filters. Keep all current behaviour (debounce, generation tokens, fetch modes). The existing feature's controller becomes a thin delegating wrapper so the existing screen keeps working.

---

### Task 2.1: Define generic `MapState` and `MapFetchMode`

**Files:**
- Create: `lib/core/map/presentation/controllers/map_controller.dart` (initial — state only)

- [ ] **Step 1: Create the file with state + enum**

```dart
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
```

Note: this file imports `map_config.dart` which doesn't exist yet — that's OK; we'll add the controller class in Task 2.2 and create `MapConfig` in Slice 3. Compile-fail is expected until Slice 3 completes. Do NOT run analyze on this file alone yet.

- [ ] **Step 2: Commit (intentionally broken intermediate state)**

```bash
git add lib/core/map/presentation/controllers/map_controller.dart
git commit -m "feat(map-engine): generic MapState and MapFetchMode (WIP)"
```

---

### Task 2.2: Add the generic `MapController` class

**Files:**
- Modify: `lib/core/map/presentation/controllers/map_controller.dart`

- [ ] **Step 1: Append the controller class to the file**

Append below the `MapState` class:

```dart
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

/// Engine-owned provider. The map screen watches this. It depends on the
/// [mapConfigProvider] so the controller is rebuilt if the config changes
/// (in practice, never — but it keeps the wiring clean).
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

- [ ] **Step 2: Commit (still WIP — depends on Slice 3)**

```bash
git add lib/core/map/presentation/controllers/map_controller.dart
git commit -m "feat(map-engine): generic MapController + provider (WIP, awaits MapConfig)"
```

The codebase will not compile until Slice 3. That's acceptable — the existing screen still uses the OLD controller path and `flutter analyze` will surface errors only inside `lib/core/map/`. We resolve them in Slice 3.

---

### Task 2.3: Add a fake `MapDataSource` for tests

**Files:**
- Create: `test/map/_fakes/fake_map_data_source.dart`

- [ ] **Step 1: Create the fake**

```dart
import 'package:nano_embryo/core/map/domain/data_source/map_data_source.dart';
import 'package:nano_embryo/core/map/domain/entities/map_bounds.dart';
import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';

/// In-memory MapDataSource for unit tests.
///
/// Records every call and returns the queued response (or throws the queued
/// error). Use [queueViewport] / [queueNearby] / [queueError] to script
/// behaviour. Defaults to returning an empty list.
class FakeMapDataSource implements MapDataSource {
  final List<List<MapPin>> _viewportQueue = [];
  final List<List<MapPin>> _nearbyQueue = [];
  Object? _nextError;

  int viewportCalls = 0;
  int nearbyCalls = 0;
  Map<String, dynamic> lastViewportFilters = const {};
  Map<String, dynamic> lastNearbyFilters = const {};

  void queueViewport(List<MapPin> pins) => _viewportQueue.add(pins);
  void queueNearby(List<MapPin> pins) => _nearbyQueue.add(pins);
  void queueError(Object error) => _nextError = error;

  @override
  Future<List<MapPin>> fetchInViewport({
    required MapBounds bounds,
    required Map<String, dynamic> filters,
    int limit = 100,
  }) async {
    viewportCalls++;
    lastViewportFilters = filters;
    if (_nextError != null) {
      final e = _nextError!;
      _nextError = null;
      throw e;
    }
    if (_viewportQueue.isEmpty) return const [];
    return _viewportQueue.removeAt(0);
  }

  @override
  Future<List<MapPin>> fetchNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
    required Map<String, dynamic> filters,
    int limit = 50,
  }) async {
    nearbyCalls++;
    lastNearbyFilters = filters;
    if (_nextError != null) {
      final e = _nextError!;
      _nextError = null;
      throw e;
    }
    if (_nearbyQueue.isEmpty) return const [];
    return _nearbyQueue.removeAt(0);
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add test/map/_fakes/fake_map_data_source.dart
git commit -m "test(map-engine): add FakeMapDataSource for controller tests"
```

---

### Task 2.4: Test controller debounce + generation tokens

**Files:**
- Create: `test/map/map_controller_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/map/domain/entities/map_bounds.dart';
import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';
import 'package:nano_embryo/core/map/presentation/controllers/map_controller.dart';

import '_fakes/fake_map_data_source.dart';

void main() {
  group('MapController', () {
    late FakeMapDataSource fake;
    late MapController controller;

    setUp(() {
      fake = FakeMapDataSource();
      controller = MapController(
        dataSource: fake,
        viewportDebounce: const Duration(milliseconds: 50),
        viewportLimit: 100,
        nearbyLimit: 50,
      );
    });

    tearDown(() => controller.dispose());

    test('updateViewport debounces multiple rapid calls into one fetch', () async {
      fake.queueViewport(const [
        MapPin(id: 'a', latitude: 0, longitude: 0),
      ]);

      const bounds = MapBounds(north: 1, south: 0, east: 1, west: 0);

      await controller.updateViewport(bounds, const {'k': 'v1'});
      await controller.updateViewport(bounds, const {'k': 'v2'});
      await controller.updateViewport(bounds, const {'k': 'v3'});

      // Before debounce window expires no fetch should have happened.
      expect(fake.viewportCalls, 0);

      await Future<void>.delayed(const Duration(milliseconds: 80));

      // Only the last call should have fired (debounced).
      expect(fake.viewportCalls, 1);
      expect(fake.lastViewportFilters, equals({'k': 'v3'}));
      expect(controller.state.pins.length, 1);
      expect(controller.state.fetchMode, MapFetchMode.browse);
    });

    test('fetchNearby switches mode and records anchor location', () async {
      fake.queueNearby(const [
        MapPin(id: 'b', latitude: 5, longitude: 5),
      ]);

      await controller.fetchNearby(
        latitude: 5.0,
        longitude: 5.0,
        radiusKm: 5.0,
        filters: const {},
        mode: MapFetchMode.deviceGps,
      );

      expect(controller.state.fetchMode, MapFetchMode.deviceGps);
      expect(controller.state.anchorLocation?.latitude, 5.0);
      expect(controller.state.anchorLocation?.longitude, 5.0);
      expect(controller.state.pins.length, 1);
    });

    test('stale fetch is discarded (generation token)', () async {
      // Queue two responses. Start a slow fetchNearby, then immediately start
      // a second one. Only the second should land in state.
      fake.queueNearby(const [MapPin(id: 'old', latitude: 0, longitude: 0)]);
      fake.queueNearby(const [MapPin(id: 'new', latitude: 1, longitude: 1)]);

      final firstFuture = controller.fetchNearby(
        latitude: 0,
        longitude: 0,
        radiusKm: 5.0,
        filters: const {},
        mode: MapFetchMode.deviceGps,
      );

      // Kick off second fetch before first resolves.
      final secondFuture = controller.fetchNearby(
        latitude: 1,
        longitude: 1,
        radiusKm: 5.0,
        filters: const {},
        mode: MapFetchMode.deviceGps,
      );

      await firstFuture;
      await secondFuture;

      expect(controller.state.pins.single.id, 'new');
    });

    test('fetch error populates error and clears loading', () async {
      fake.queueError(Exception('boom'));

      await controller.fetchNearby(
        latitude: 0,
        longitude: 0,
        radiusKm: 5.0,
        filters: const {},
        mode: MapFetchMode.deviceGps,
      );

      expect(controller.state.error, contains('boom'));
      expect(controller.state.isLoading, isFalse);
    });

    test('clearError wipes error without touching pins', () async {
      fake.queueNearby(const [MapPin(id: 'a', latitude: 0, longitude: 0)]);
      await controller.fetchNearby(
        latitude: 0,
        longitude: 0,
        radiusKm: 5.0,
        filters: const {},
        mode: MapFetchMode.deviceGps,
      );

      fake.queueError(Exception('boom'));
      await controller.fetchNearby(
        latitude: 1,
        longitude: 1,
        radiusKm: 5.0,
        filters: const {},
        mode: MapFetchMode.deviceGps,
      );

      expect(controller.state.error, isNotNull);
      controller.clearError();
      expect(controller.state.error, isNull);
    });
  });
}
```

- [ ] **Step 2: Run the test**

Run: `flutter test test/map/map_controller_test.dart`
Expected: still fails to compile because `MapController` references `mapConfigProvider` from a file that doesn't exist yet. To unblock the test, we'll temporarily comment out the `mapControllerProvider` declaration at the bottom of `lib/core/map/presentation/controllers/map_controller.dart`.

- [ ] **Step 3: Temporarily comment out the provider**

Edit `lib/core/map/presentation/controllers/map_controller.dart`, wrapping the `mapControllerProvider` declaration in a `/* */` block comment with a `TODO: re-enable in Slice 3` marker. Also remove the unused `import 'package:nano_embryo/core/map/config/feature/map_config.dart';` import.

- [ ] **Step 4: Re-run test**

Run: `flutter test test/map/map_controller_test.dart`
Expected: `+5: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add test/map/map_controller_test.dart lib/core/map/presentation/controllers/map_controller.dart
git commit -m "test(map-engine): controller debounce + generation tokens + error path"
```

---

### Task 2.5: Don't touch the existing feature controller yet

The existing `lib/presentation/features/map/presentation/controllers/map_controller.dart` continues to serve the existing `MapScreen` unchanged. We will delete it in Slice 6.

- [ ] **Step 1: Verify existing screen still works**

Run: `flutter analyze`
Expected: `No issues found!` (the new generic controller compiles in isolation now that `mapConfigProvider` reference is commented out).

If you see errors related to `MapBounds`, double-check Task 1.3 step 2 — the old controller file must still expose `MapBounds` via `export`.

---

# Slice 3 — Config types & provider

Goal: build out the `MapConfig` surface and all supporting types. Extend `CanvasMarkerBuilder` with the `MarkerShape` enum. End-state: the generic controller compiles end-to-end; the engine's `mapConfigProvider` is declared (still without a real override).

---

### Task 3.1: Create `FilterOption` and `MapFilterSchema`

**Files:**
- Create: `lib/core/map/config/feature/map_filter_schema.dart`

- [ ] **Step 1: Create the file**

```dart
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
```

- [ ] **Step 2: Verify build**

Run: `flutter analyze lib/core/map/config/feature/map_filter_schema.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/config/feature/map_filter_schema.dart
git commit -m "feat(map-engine): FilterOption + MapFilterSchema with filter assembly"
```

---

### Task 3.2: Test `MapFilterSchema.assembleFilters`

**Files:**
- Create: `test/map/map_filter_schema_test.dart`

- [ ] **Step 1: Write the test**

```dart
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
```

- [ ] **Step 2: Run test**

Run: `flutter test test/map/map_filter_schema_test.dart`
Expected: `+5: All tests passed!`

- [ ] **Step 3: Commit**

```bash
git add test/map/map_filter_schema_test.dart
git commit -m "test(map-engine): MapFilterSchema.assembleFilters covers null/all/single/both/hidden-axis"
```

---

### Task 3.3: Create `MarkerStyle` and `MarkerShape`

**Files:**
- Create: `lib/core/map/config/feature/marker_style.dart`

- [ ] **Step 1: Create file**

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';

/// Visual shape of a marker. The default `pill` preserves the existing
/// rectangle-with-tail look drawn by `CanvasMarkerBuilder`.
enum MarkerShape { pill, circle, square }

/// Resolved marker visual derived from a [MapPin].
class MarkerStyle extends Equatable {
  /// Text shown inside the marker (e.g. 'SAL.', '$45', 'TODAY').
  final String label;

  /// Background color of the marker body.
  final Color color;

  /// Visual shape. Defaults to the current pill-with-tail look.
  final MarkerShape shape;

  const MarkerStyle({
    required this.label,
    required this.color,
    this.shape = MarkerShape.pill,
  });

  @override
  List<Object?> get props => [label, color, shape];
}

/// Resolver function: per-pin, return how the marker should look.
typedef MarkerStyleResolver = MarkerStyle Function(MapPin pin);
```

- [ ] **Step 2: Verify build**

Run: `flutter analyze lib/core/map/config/feature/marker_style.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/config/feature/marker_style.dart
git commit -m "feat(map-engine): MarkerStyle, MarkerShape, MarkerStyleResolver"
```

---

### Task 3.4: Create `MapCopy` with defaults

**Files:**
- Create: `lib/core/map/config/feature/map_copy.dart`

- [ ] **Step 1: Create file**

```dart
import 'package:equatable/equatable.dart';

/// User-facing copy used by the engine. All fields have sensible defaults
/// so a minimal `MapConfig` doesn't need to fill any of these out.
class MapCopy extends Equatable {
  final String emptyStateSubtitle;
  final String errorRetryLabel;
  final String locationPermissionTitle;
  final String locationPermissionBody;
  final String locationPermissionCancelLabel;
  final String locationPermissionOpenSettingsLabel;
  final String appLocationMissingSnackbar;

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
      ];
}
```

- [ ] **Step 2: Verify build**

Run: `flutter analyze lib/core/map/config/feature/map_copy.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/config/feature/map_copy.dart
git commit -m "feat(map-engine): MapCopy with default strings"
```

---

### Task 3.5: Create `MapFallback`

**Files:**
- Create: `lib/core/map/config/feature/map_fallback.dart`

- [ ] **Step 1: Create file**

```dart
import 'package:equatable/equatable.dart';

/// Tier-3 fallback used when neither device GPS nor app-location is
/// available. The engine flies the camera here and runs an initial
/// viewport fetch.
class MapFallback extends Equatable {
  final double latitude;
  final double longitude;
  final double initialZoom;

  const MapFallback({
    required this.latitude,
    required this.longitude,
    this.initialZoom = 12.0,
  });

  @override
  List<Object?> get props => [latitude, longitude, initialZoom];
}
```

- [ ] **Step 2: Verify build**

Run: `flutter analyze lib/core/map/config/feature/map_fallback.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/config/feature/map_fallback.dart
git commit -m "feat(map-engine): MapFallback (lat/lng/zoom for tier-3 fallback)"
```

---

### Task 3.6: Create `MapConfig` class + `mapConfigProvider`

**Files:**
- Create: `lib/core/map/config/feature/map_config.dart`

- [ ] **Step 1: Create the file**

```dart
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

  /// Debounce between pan/zoom and the resulting viewport fetch.
  final Duration viewportDebounce;

  const MapConfig({
    required this.dataSource,
    required this.filterSchema,
    required this.resolveMarkerStyle,
    required this.onPinTap,
    required this.fallback,
    this.copy = const MapCopy(),
    this.appLocationProvider,
    this.defaultRadiusKm = 5.0,
    this.viewportLimit = 100,
    this.nearbyLimit = 50,
    this.viewportDebounce = const Duration(milliseconds: 500),
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
```

- [ ] **Step 2: Re-enable the `mapControllerProvider`**

Edit `lib/core/map/presentation/controllers/map_controller.dart`:
1. Add back the import: `import 'package:nano_embryo/core/map/config/feature/map_config.dart';`
2. Uncomment the `mapControllerProvider` declaration block.

- [ ] **Step 3: Verify build**

Run: `flutter analyze lib/core/map/`
Expected: `No issues found!`

- [ ] **Step 4: Re-run controller tests**

Run: `flutter test test/map/map_controller_test.dart`
Expected: `+5: All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/core/map/config/feature/map_config.dart lib/core/map/presentation/controllers/map_controller.dart
git commit -m "feat(map-engine): MapConfig class + mapConfigProvider, re-enable controller provider"
```

---

### Task 3.7: Move `CanvasMarkerBuilder` and extend with `MarkerShape`

**Files:**
- Create: `lib/core/map/presentation/widgets/canvas_marker_builder.dart`
- Delete: `lib/presentation/features/map/presentation/widgets/canvas_marker_builder.dart`

- [ ] **Step 1: Copy the existing canvas builder to its new home**

Read `lib/presentation/features/map/presentation/widgets/canvas_marker_builder.dart` (the full ~370 lines). Create `lib/core/map/presentation/widgets/canvas_marker_builder.dart` with the same contents, but:

1. Add the new import at top:

```dart
import 'package:nano_embryo/core/map/config/feature/marker_style.dart';
```

2. Change the `drawSimpleMarker` signature to accept a `MarkerShape`:

Replace this signature:
```dart
static Future<Uint8List> drawSimpleMarker({
    required String typeCode,
    required Color luxuryColor,
    required BuildContext context,
    bool isSelected = false,
    double? width,
    double? height,
    double tailHeight = 30.0,
    double tailWidth = 50.0,
    Color? borderColor,
  }) async {
```

With:
```dart
static Future<Uint8List> drawSimpleMarker({
    required String typeCode,
    required Color luxuryColor,
    required BuildContext context,
    bool isSelected = false,
    MarkerShape shape = MarkerShape.pill,
    double? width,
    double? height,
    double tailHeight = 30.0,
    double tailWidth = 50.0,
    Color? borderColor,
  }) async {
```

3. Inside `drawSimpleMarker`, immediately before the existing `final theme = Theme.of(context);` line, add:

```dart
// Only the pill shape is implemented today (it is the current marker look).
// Future shapes can branch off this enum without changing call sites.
assert(
  shape == MarkerShape.pill,
  'MarkerShape.${shape.name} is not yet implemented; '
  'CanvasMarkerBuilder currently only supports MarkerShape.pill. '
  'Add a branch above or extend this function before using it.',
);
```

This keeps current behaviour 100% identical (`pill` is the default) while making the surface area for `MarkerShape.circle` / `MarkerShape.square` explicit. We do not implement them — YAGNI.

4. Leave `drawClusterMarker` unchanged.

- [ ] **Step 2: Delete the original**

Run: `git rm lib/presentation/features/map/presentation/widgets/canvas_marker_builder.dart`

- [ ] **Step 3: Update the import in the legacy `animated_marker_manager.dart`**

Edit `lib/presentation/features/map/presentation/widgets/animated_marker_manager.dart` line 8:

Replace:
```dart
import 'package:nano_embryo/presentation/features/map/presentation/widgets/canvas_marker_builder.dart';
```

With:
```dart
import 'package:nano_embryo/core/map/presentation/widgets/canvas_marker_builder.dart';
```

- [ ] **Step 4: Verify build**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add -A lib/core/map/presentation/widgets/canvas_marker_builder.dart lib/presentation/features/map/presentation/widgets/canvas_marker_builder.dart lib/presentation/features/map/presentation/widgets/animated_marker_manager.dart
git commit -m "refactor(map-engine): move CanvasMarkerBuilder to core/map and accept MarkerShape"
```

---

# Slice 4 — Generic widgets

Goal: build the generic `MapFilterBar`, `AnimatedMarkerManager`, filter providers, and extract `MapFabColumn` from the screen.

---

### Task 4.1: Generic filter providers + combined-filters provider

**Files:**
- Create: `lib/core/map/presentation/providers/map_filter_providers.dart`

- [ ] **Step 1: Create the file**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nano_embryo/core/map/config/feature/map_config.dart';
import 'package:nano_embryo/core/map/config/feature/map_filter_schema.dart';

/// User's current selection on the primary tab axis. `null` = none chosen
/// (engine will fall back to `primaryAllOption` if the schema has one).
final selectedPrimaryFilterProvider = StateProvider<FilterOption?>((ref) => null);

/// User's current selection on the secondary chip axis. `null` = none chosen.
final selectedSecondaryFilterProvider =
    StateProvider<FilterOption?>((ref) => null);

/// Combined filter map handed to the controller / data source.
///
/// Re-computes whenever either selection changes. Uses the schema's
/// `assembleFilters` so `null` and "all" selections drop out cleanly.
final mapFiltersProvider = Provider<Map<String, dynamic>>((ref) {
  final config = ref.watch(mapConfigProvider);
  final primary = ref.watch(selectedPrimaryFilterProvider);
  final secondary = ref.watch(selectedSecondaryFilterProvider);
  return config.filterSchema.assembleFilters(
    primary: primary,
    secondary: secondary,
  );
});
```

- [ ] **Step 2: Verify build**

Run: `flutter analyze lib/core/map/presentation/providers/`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/presentation/providers/map_filter_providers.dart
git commit -m "feat(map-engine): generic filter providers + combined filters"
```

---

### Task 4.2: Generic `MapFilterBar`

**Files:**
- Create: `lib/core/map/presentation/widgets/map_filter_bar.dart`

- [ ] **Step 1: Create the file**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/map/config/feature/map_config.dart';
import 'package:nano_embryo/core/map/config/feature/map_filter_schema.dart';
import 'package:nano_embryo/core/map/presentation/providers/map_filter_providers.dart';
import 'package:nano_embryo/core/utils/animations/shake_transition.dart';
import 'package:nano_embryo/core/widgets/app_filer_chip.dart';
import 'package:nano_embryo/core/widgets/shop_category_tabs.dart';

/// Filter bar for the engine — primary tabs above, optional secondary
/// chip row below. Layout is fixed; values come from
/// `MapConfig.filterSchema`. The chip row hides entirely if
/// `secondaryFilterKey` is `null`.
class MapFilterBar extends ConsumerWidget {
  const MapFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(mapConfigProvider);
    final schema = config.filterSchema;
    final selectedPrimary = ref.watch(selectedPrimaryFilterProvider);
    final selectedSecondary = ref.watch(selectedSecondaryFilterProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Compose the tab list: "All" option first if present, then primary tabs.
    final primaryEntries = <FilterOption>[
      if (schema.primaryAllOption != null) schema.primaryAllOption!,
      ...schema.primaryTabs,
    ];
    final primaryLabels = primaryEntries.map((e) => e.label).toList();
    final selectedPrimaryLabel =
        selectedPrimary?.label ?? schema.primaryAllOption?.label;

    return Container(
      padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(BorderRadiusTokens.xl),
          topRight: Radius.circular(BorderRadiusTokens.xl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShakeTransition(
            duration: const Duration(milliseconds: 700),
            child: ShopCategoryTabs(
              categories: primaryLabels,
              selectedCategory: selectedPrimaryLabel,
              onCategorySelected: (label) {
                final picked = primaryEntries
                    .firstWhere((e) => e.label == label, orElse: () => primaryEntries.first);
                ref.read(selectedPrimaryFilterProvider.notifier).state =
                    picked == schema.primaryAllOption ? null : picked;
              },
              isLoading: false,
              tabWidth: 90.w,
              containerHeight: 40.h,
              showBottomBorder: false,
              selectedIndicatorColor: colorScheme.primary,
              selectedTextColor: colorScheme.primary,
              unselectedTextColor: colorScheme.onSurfaceVariant,
            ),
          ),

          if (schema.secondaryFilterKey != null) ...[
            Gap(Spacing.xs),
            ShakeTransition(
              offset: -140,
              child: SizedBox(
                height: 48.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (schema.secondaryAllOption != null)
                      Padding(
                        padding: EdgeInsets.only(right: Spacing.sm.w),
                        child: AppFilterChip(
                          label: schema.secondaryAllOption!.label,
                          selected: selectedSecondary == null,
                          onSelected: (selected) {
                            if (selected) {
                              ref
                                  .read(selectedSecondaryFilterProvider.notifier)
                                  .state = null;
                            }
                          },
                          selectedColor: colorScheme.primary,
                          backgroundColor: Colors.transparent,
                          borderWidth: 0.3,
                        ),
                      ),
                    ...schema.secondaryChips.map((opt) {
                      final isSelected = selectedSecondary == opt;
                      return Padding(
                        padding: EdgeInsets.only(right: Spacing.sm.w),
                        child: AppFilterChip(
                          label: opt.label,
                          selected: isSelected,
                          onSelected: (selected) {
                            ref
                                .read(selectedSecondaryFilterProvider.notifier)
                                .state = selected ? opt : null;
                          },
                          selectedColor: colorScheme.primary,
                          backgroundColor: colorScheme.background,
                          labelColor: colorScheme.onSurface,
                          borderWidth: 0.3,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify build**

Run: `flutter analyze lib/core/map/presentation/widgets/map_filter_bar.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/presentation/widgets/map_filter_bar.dart
git commit -m "feat(map-engine): generic MapFilterBar driven by MapFilterSchema"
```

---

### Task 4.3: Generic `AnimatedMarkerManager` using `MarkerStyleResolver`

**Files:**
- Create: `lib/core/map/presentation/widgets/animated_marker_manager.dart`

- [ ] **Step 1: Create the new generic version**

Copy the existing `lib/presentation/features/map/presentation/widgets/animated_marker_manager.dart` to `lib/core/map/presentation/widgets/animated_marker_manager.dart` and make these surgical changes:

1. Replace the top imports block with:

```dart
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:nano_embryo/core/map/config/feature/marker_style.dart';
import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';
import 'package:nano_embryo/core/map/presentation/widgets/canvas_marker_builder.dart';
```

(The old `ShopLocationDTO` import and `MarkerCodeGenerator` import are dropped.)

2. Replace all uses of `ShopLocationDTO` with `MapPin`. Specifically:
- Field: `Function(ShopLocationDTO)? _onMarkerTap;` → `Function(MapPin)? _onMarkerTap;`
- Field: `final Map<String, ShopLocationDTO> _shopIdToShop = {};` → `final Map<String, MapPin> _pinIdToPin = {};`
- Field: `List<ShopLocationDTO> _currentShops = [];` → `List<MapPin> _currentPins = [];`
- Field: `final Map<String, String> _annotationIdToShopId = {};` → `final Map<String, String> _annotationIdToPinId = {};`
- Rename internal references from `shop`/`shopId`/`shops` to `pin`/`pinId`/`pins`.
- Method: `Future<void> updateMarkers(List<ShopLocationDTO> shops, Function(ShopLocationDTO) onMarkerTap)` → `Future<void> updateMarkers(List<MapPin> pins, Function(MapPin) onMarkerTap, MarkerStyleResolver resolveStyle)`.
- All references to `shop.luxuryLevel` / `shop.shopType` are removed (no longer accessed directly).

3. Replace `_getHighResMarkerImage`'s body so it uses the resolver:

Old:
```dart
Future<Uint8List> _getHighResMarkerImage(
    ShopLocationDTO shop,
    bool isSelected,
    BuildContext context,
  ) async {
    final cacheKey =
        '${shop.id}_${shop.luxuryLevel}_${shop.shopType}_${isSelected ? 'selected' : 'normal'}';
    if (_imageCache.containsKey(cacheKey)) {
      return _imageCache[cacheKey]!;
    }

    final typeCode = MarkerCodeGenerator.getTypeCode(shop.shopType);
    final luxuryColor = MarkerCodeGenerator.getLuxuryColor(shop.luxuryLevel);

    final imageBytes = await CanvasMarkerBuilder.drawSimpleMarker(
      typeCode: typeCode,
      luxuryColor: luxuryColor,
      context: context,
      isSelected: isSelected,
      width: 100.h,
      height: 80.w,
    );

    _imageCache[cacheKey] = imageBytes;
    return imageBytes;
  }
```

New:
```dart
Future<Uint8List> _getHighResMarkerImage(
    MapPin pin,
    bool isSelected,
    BuildContext context,
  ) async {
    final style = _resolveStyle!(pin);

    // Cache key derived from the resolved style (not the pin) so the
    // cache stays correct across resolver swaps.
    final cacheKey =
        '${pin.id}_${style.label}_${style.color.value}_${style.shape.name}_${isSelected ? 'selected' : 'normal'}';

    if (_imageCache.containsKey(cacheKey)) {
      return _imageCache[cacheKey]!;
    }

    final imageBytes = await CanvasMarkerBuilder.drawSimpleMarker(
      typeCode: style.label,
      luxuryColor: style.color,
      shape: style.shape,
      context: context,
      isSelected: isSelected,
      width: 100.h,
      height: 80.w,
    );

    _imageCache[cacheKey] = imageBytes;
    return imageBytes;
  }
```

4. Add a new private field at the top of the class:

```dart
MarkerStyleResolver? _resolveStyle;
```

5. In `updateMarkers`, store the resolver:

After `_onMarkerTap = onMarkerTap;` add:
```dart
_resolveStyle = resolveStyle;
```

- [ ] **Step 2: Verify build**

Run: `flutter analyze lib/core/map/presentation/widgets/animated_marker_manager.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/presentation/widgets/animated_marker_manager.dart
git commit -m "feat(map-engine): generic AnimatedMarkerManager driven by MarkerStyleResolver"
```

---

### Task 4.4: Extract `MapFabColumn`

**Files:**
- Create: `lib/core/map/presentation/widgets/map_fab_column.dart`

- [ ] **Step 1: Create the file**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/animations/animated_scale_fade.dart';
import 'package:nano_embryo/core/widgets/circular_loading_indicator.dart';
import 'package:nano_embryo/core/map/presentation/controllers/map_controller.dart';

/// Stacks the device-GPS and (optional) app-location FABs on the
/// right edge of the map.
///
/// The app-location FAB is hidden when [showAppLocationFab] is false
/// (i.e. when `MapConfig.appLocationProvider` is null).
class MapFabColumn extends StatelessWidget {
  final MapFetchMode fetchMode;
  final bool isFetching;
  final bool showAppLocationFab;
  final VoidCallback onGpsPressed;
  final VoidCallback onAppLocationPressed;

  const MapFabColumn({
    super.key,
    required this.fetchMode,
    required this.isFetching,
    required this.showAppLocationFab,
    required this.onGpsPressed,
    required this.onAppLocationPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned(
          bottom: Spacing.xxl.h + Spacing.xxl.h,
          right: Spacing.md.w,
          child: AnimatedScaleFade(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            child: FloatingActionButton.small(
              heroTag: 'fab_gps',
              backgroundColor: colorScheme.surface,
              onPressed: onGpsPressed,
              child: isFetching
                  ? const CircularLoadingIndicator()
                  : Icon(
                      fetchMode == MapFetchMode.deviceGps
                          ? Icons.gps_fixed
                          : Icons.gps_not_fixed,
                      color: fetchMode == MapFetchMode.deviceGps
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
            ),
          ),
        ),
        if (showAppLocationFab)
          Positioned(
            bottom: Spacing.lg.h + Spacing.md.h,
            right: Spacing.md.w,
            child: AnimatedScaleFade(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              child: FloatingActionButton.small(
                heroTag: 'fab_app_location',
                backgroundColor: colorScheme.surface,
                onPressed: onAppLocationPressed,
                child: isFetching
                    ? const CircularLoadingIndicator()
                    : Icon(
                        fetchMode == MapFetchMode.appLocation
                            ? Icons.location_on
                            : Icons.location_on_outlined,
                        color: fetchMode == MapFetchMode.appLocation
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
              ),
            ),
          ),
      ],
    );
  }
}
```

Note: this file imports `CircularLoadingIndicator`. Verify the actual import path with `grep -rn "class CircularLoadingIndicator" lib/`. If the path differs from `lib/core/widgets/circular_loading_indicator.dart`, update the import.

- [ ] **Step 2: Verify build**

Run: `flutter analyze lib/core/map/presentation/widgets/map_fab_column.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/presentation/widgets/map_fab_column.dart
git commit -m "feat(map-engine): extract MapFabColumn (hides app-location FAB when unconfigured)"
```

---

# Slice 5 — Generic screen (`MapEngineScreen`)

Goal: create the generic screen at `lib/core/map/presentation/screens/map_screen.dart`. It reads `mapConfigProvider` for every app-specific bit. The existing app's `MapScreen` is still mounted from `home_screen.dart` and continues to work until Slice 6.

---

### Task 5.1: Create the skeleton of `MapEngineScreen`

**Files:**
- Create: `lib/core/map/presentation/screens/map_screen.dart`

- [ ] **Step 1: Copy + adapt the existing screen**

Start by copying `lib/presentation/features/map/presentation/screens/map_screen.dart` to `lib/core/map/presentation/screens/map_screen.dart`. Then apply these changes (presented as the final file — paste verbatim):

```dart
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
import 'package:nano_embryo/core/map/domain/entities/lat_lng.dart';
import 'package:nano_embryo/core/map/domain/entities/map_bounds.dart';
import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';
import 'package:nano_embryo/core/map/presentation/controllers/map_controller.dart';
import 'package:nano_embryo/core/map/presentation/providers/map_filter_providers.dart';
import 'package:nano_embryo/core/map/presentation/widgets/animated_marker_manager.dart';
import 'package:nano_embryo/core/map/presentation/widgets/map_fab_column.dart';
import 'package:nano_embryo/core/map/presentation/widgets/map_filter_bar.dart';
import 'package:nano_embryo/core/utils/bottom_sheet_utils.dart' show CardInkWell;
import 'package:nano_embryo/core/widgets/circular_loading_indicator.dart';
import 'package:nano_embryo/core/widgets/feedback/empty_state.dart';
import 'package:nano_embryo/core/widgets/feedback/error_state.dart';

// NOTE: some widget imports (e.g. `CardInkWell`, `EmptyStateWidget`,
// `CircularLoadingIndicator`, `AppFilterChip`, `ShopCategoryTabs`,
// `ShakeTransition`, `AnimatedScaleFade`, `Spacing`) live in this project
// under specific paths. If `flutter analyze` flags any of these imports in
// step 2 below as unresolved, run `grep -rln "class <SymbolName>" lib/` to
// find the real source file and adjust the import.

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
  AnimatedMarkerManager? _markerManager;
  bool _isFetchingNearby = false;

  int _retryCount = 0;
  static const int _maxRetries = 4;

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
    final config = ref.read(mapConfigProvider);
    _markerManager?.updateMarkers(
      pins,
      (pin) => config.onPinTap(pin, context),
      config.resolveMarkerStyle,
    );
  }

  Widget _cardWell(Widget child) {
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final mapStyleUri =
        isDarkMode ? MapboxStyles.DARK : MapboxStyles.MAPBOX_STREETS;
    final colorScheme = Theme.of(context).colorScheme;
    final config = ref.watch(mapConfigProvider);
    final mapState = ref.watch(mapControllerProvider);
    final controller = ref.read(mapControllerProvider.notifier);

    ref.listen<Map<String, dynamic>>(mapFiltersProvider, (previous, next) {
      if (previous != next) {
        controller.refresh(next, radiusKm: config.defaultRadiusKm);
      }
    });

    ref.listen<MapState>(mapControllerProvider, (previous, next) {
      if (previous?.pins != next.pins) _updateMarkers(next.pins);
    });

    return Scaffold(
      extendBody: true,
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: EdgeInsets.only(bottom: Spacing.xxl + Spacing.xl),
        child: Stack(
          children: [
            if (_showMap)
              MapWidget(
                key: _mapKey,
                onMapCreated:
                    (mapboxMap) => _onMapCreated(mapboxMap, controller),
                cameraOptions: CameraOptions(
                  center: Point(coordinates: Position(20.0, 5.0)),
                  zoom: 3.0,
                ),
                styleUri: mapStyleUri,
              ),

            if (mapState.isLoading && mapState.pins.isEmpty)
              const Center(child: CircularLoadingIndicator()),

            if (!mapState.isLoading &&
                !mapState.isFetching &&
                mapState.pins.isEmpty &&
                mapState.error == null)
              _cardWell(
                Center(
                  child: EmptyStateWidget(
                    icon: Icons.map_outlined,
                    subtitle: config.copy.emptyStateSubtitle,
                    actionLabel: config.copy.errorRetryLabel,
                    onAction: () {
                      if (!_isMapReady) {
                        _retryMapCreation();
                      } else {
                        controller.refresh(
                          ref.read(mapFiltersProvider),
                          radiusKm: config.defaultRadiusKm,
                        );
                      }
                    },
                  ),
                ),
              ),

            if (mapState.error != null)
              _cardWell(
                ErrorStateWidget(
                  subtitle: mapState.error,
                  onPrimaryAction: () {
                    controller.clearError();
                    controller.refresh(
                      ref.read(mapFiltersProvider),
                      radiusKm: config.defaultRadiusKm,
                    );
                  },
                ),
              ),

            MapFabColumn(
              fetchMode: mapState.fetchMode,
              isFetching: _isFetchingNearby,
              showAppLocationFab: config.appLocationProvider != null,
              onGpsPressed: () => _useDeviceLocation(controller),
              onAppLocationPressed: () => _useAppLocation(controller),
            ),
          ],
        ),
      ),
      bottomNavigationBar: mapState.error != null ? null : const MapFilterBar(),
    );
  }

  // ── Map lifecycle ─────────────────────────────────────────────────────

  void _onMapCreated(MapboxMap mapboxMap, MapController controller) async {
    _mapInitTimeout?.cancel();
    _retryCount = 0;
    try {
      _mapboxMap = mapboxMap;
      await _initMarkerManager();

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
      debugPrint('MapWidget init error: $e');
      if (mounted) controller.resetToIdle();
    }
  }

  Future<void> _initMarkerManager() async {
    if (_mapboxMap == null) return;
    _markerManager = AnimatedMarkerManager(_mapboxMap!, context, this);
    await _markerManager?.initialize();
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
      _onCameraChanged(controller);
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
        MbxEdgeInsets(top: 100, left: 60, bottom: 180, right: 60),
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

    // Tier 2: in-app user location (only if configured)
    if (config.appLocationProvider != null) {
      final appLocation = ref.read(config.appLocationProvider!);
      if (appLocation != null) {
        await _flyToAndFetchNearby(
          controller: controller,
          latitude: appLocation.latitude,
          longitude: appLocation.longitude,
          mode: MapFetchMode.appLocation,
        );
        return;
      }
    }

    if (!mounted) return;

    // Tier 3: configured hardcoded fallback
    await _flyToAndFetchNearby(
      controller: controller,
      latitude: config.fallback.latitude,
      longitude: config.fallback.longitude,
      mode: MapFetchMode.browse,
    );
  }

  // ── FAB actions ────────────────────────────────────────────────────────

  Future<void> _useDeviceLocation(MapController controller) async {
    if (ref.read(mapControllerProvider).fetchMode == MapFetchMode.deviceGps) {
      _onCameraChanged(controller);
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

  Future<void> _useAppLocation(MapController controller) async {
    final config = ref.read(mapConfigProvider);
    if (config.appLocationProvider == null) return;

    if (ref.read(mapControllerProvider).fetchMode == MapFetchMode.appLocation) {
      _onCameraChanged(controller);
      return;
    }

    final appLocation = ref.read(config.appLocationProvider!);
    if (appLocation == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(config.copy.appLocationMissingSnackbar)),
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

  // ── Dialogs ───────────────────────────────────────────────────────────

  void _showLocationPermissionDialog() {
    final copy = ref.read(mapConfigProvider).copy;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
    _markerManager?.dispose();
    _mapboxMap?.onMapScrollListener = null;
    _mapboxMap?.onMapZoomListener = null;
    _mapboxMap = null;
    super.dispose();
  }
}
```

- [ ] **Step 2: Verify build**

Run: `flutter analyze lib/core/map/`
Expected: `No issues found!`

The screen exists but is not yet mounted from anywhere — the old `MapScreen` is still the one wired into `home_screen.dart`. That swap happens in Slice 6.

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/presentation/screens/map_screen.dart
git commit -m "feat(map-engine): generic MapEngineScreen reading mapConfigProvider"
```

---

# Slice 6 — Wire the app, verify, delete legacy

Goal: implement the real shop `MapDataSource`, write the per-app `MapConfig` builder, wire the provider override, swap the mounted screen, run the manual flow, then delete `lib/presentation/features/map/`.

---

### Task 6.1: Implement `SupabaseShopMapDataSource`

**Files:**
- Create: `lib/presentation/features/discover/data/supabase_shop_map_datasource.dart`

- [ ] **Step 1: Verify the discover feature folder exists**

Run: `ls lib/presentation/features/discover/`
If the directory does not exist, run: `mkdir -p lib/presentation/features/discover/data`. (The feature folder is where shop-discovery code naturally lives, separate from the engine.)

- [ ] **Step 2: Create the data source**

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nano_embryo/core/map/domain/data_source/map_data_source.dart';
import 'package:nano_embryo/core/map/domain/entities/map_bounds.dart';
import 'package:nano_embryo/core/map/domain/entities/map_pin.dart';

/// Concrete `MapDataSource` that queries the existing
/// `get_shops_in_viewport` and `get_shops_nearby` Supabase RPC functions.
///
/// Translates rows into [MapPin] with shop-specific fields packed into
/// `pin.data` (`shop_type`, `luxury_level`). The engine never sees the
/// row structure directly.
class SupabaseShopMapDataSource implements MapDataSource {
  final SupabaseClient _client;

  SupabaseShopMapDataSource(this._client);

  @override
  Future<List<MapPin>> fetchInViewport({
    required MapBounds bounds,
    required Map<String, dynamic> filters,
    int limit = 100,
  }) async {
    final params = <String, dynamic>{
      'p_north': bounds.north,
      'p_south': bounds.south,
      'p_east': bounds.east,
      'p_west': bounds.west,
      'p_limit': limit,
    };

    final shopType = filters['shop_type'];
    if (shopType is String && shopType.isNotEmpty) {
      params['p_shop_type'] = shopType;
    }
    final luxuryLevel = filters['luxury_level'];
    if (luxuryLevel is String && luxuryLevel.isNotEmpty) {
      params['p_luxury_level'] = luxuryLevel;
    }

    try {
      final response =
          await _client.rpc('get_shops_in_viewport', params: params);
      return _rowsToPins(response);
    } on PostgrestException catch (e) {
      throw _wrap(e, 'get_shops_in_viewport');
    }
  }

  @override
  Future<List<MapPin>> fetchNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
    required Map<String, dynamic> filters,
    int limit = 50,
  }) async {
    final params = <String, dynamic>{
      'p_latitude': latitude,
      'p_longitude': longitude,
      'p_radius_km': radiusKm,
      'p_limit': limit,
    };

    final shopType = filters['shop_type'];
    if (shopType is String && shopType.isNotEmpty) {
      params['p_shop_type'] = shopType;
    }
    final luxuryLevel = filters['luxury_level'];
    if (luxuryLevel is String && luxuryLevel.isNotEmpty) {
      params['p_luxury_level'] = luxuryLevel;
    }

    try {
      final response = await _client.rpc('get_shops_nearby', params: params);
      return _rowsToPins(response);
    } on PostgrestException catch (e) {
      throw _wrap(e, 'get_shops_nearby');
    }
  }

  List<MapPin> _rowsToPins(dynamic response) {
    if (response == null || (response is List && response.isEmpty)) {
      return const [];
    }
    return (response as List).map((row) {
      final map = row as Map<String, dynamic>;
      return MapPin(
        id: map['id'] as String,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        data: {
          'shop_type': map['shop_type'],
          'luxury_level': map['luxury_level'],
        },
      );
    }).toList();
  }

  Exception _wrap(PostgrestException e, String op) {
    if (e.message?.contains('permission denied') ?? false) {
      return Exception('Permission denied. Please check RLS policies.');
    }
    if (e.message?.contains('does not exist') ?? false) {
      return Exception(
        'Database function $op not found. Please ensure migrations are applied.',
      );
    }
    return Exception('Database error in $op: ${e.message}');
  }
}
```

- [ ] **Step 3: Verify build**

Run: `flutter analyze lib/presentation/features/discover/`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/features/discover/data/supabase_shop_map_datasource.dart
git commit -m "feat(discover): SupabaseShopMapDataSource adapts shops to MapPin"
```

---

### Task 6.2: Move `MarkerCodeGenerator` to the discover feature folder

**Files:**
- Move: `lib/presentation/features/map/data/marker_code_generator.dart` → `lib/presentation/features/discover/data/marker_code_generator.dart`

- [ ] **Step 1: Run the move**

```bash
git mv lib/presentation/features/map/data/marker_code_generator.dart lib/presentation/features/discover/data/marker_code_generator.dart
```

- [ ] **Step 2: Find references to update**

Run: `grep -rln "presentation/features/map/data/marker_code_generator.dart" lib/`
Expected output may include the legacy `animated_marker_manager.dart` and possibly the legacy screen. We will delete those in Task 6.6 — for now, update only references that still exist after that deletion. So just verify the grep output and continue.

- [ ] **Step 3: Verify build**

Run: `flutter analyze lib/presentation/features/discover/`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git commit -m "refactor: move MarkerCodeGenerator into the discover feature"
```

---

### Task 6.3: Write `buildNanoEmbryoMapConfig()`

**Files:**
- Create: `lib/core/map/config/map_config.dart`

This is the per-app file — the ONLY file inside `core/map/` that contains app-specific code. Mirrors `lib/core/notifications/config/notification_config.dart`.

- [ ] **Step 1: Find a sample of how `userLocationNotifierProvider` is consumed today**

Run: `grep -n "userLocationNotifierProvider\|UserLocation" lib/core/providers/location_provider.dart | head -20`

Confirm `UserLocation` has `.latitude` and `.longitude` fields. Run:
```bash
grep -n "class UserLocation\b\|latitude\|longitude" lib/core/utils/location/models/user_location.dart 2>/dev/null | head -10
```

If `UserLocation` exposes `latitude` and `longitude` directly, use them. If they are nested (e.g. under `parsedAddress`), adjust the `.select(...)` closure in Step 2 accordingly.

- [ ] **Step 2: Create the per-app file**

```dart
// NanoEmbryo-specific map configuration.
//
// When copying the map engine to a new app, replace the contents of this
// file with your own data source, filter schema, marker style resolver,
// tap navigation, fallback coordinates, and copy. Everything else in
// core/map/ is generic and can be copied unchanged.
//
// See MAP_ENGINE.md for the full integration guide.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nano_embryo/core/map/config/feature/map_config.dart';
import 'package:nano_embryo/core/map/config/feature/map_copy.dart';
import 'package:nano_embryo/core/map/config/feature/map_fallback.dart';
import 'package:nano_embryo/core/map/config/feature/map_filter_schema.dart';
import 'package:nano_embryo/core/map/config/feature/marker_style.dart';
import 'package:nano_embryo/core/map/domain/entities/lat_lng.dart';
import 'package:nano_embryo/core/providers/location_provider.dart';
import 'package:nano_embryo/core/utils/bottom_sheet_utils.dart';
import 'package:nano_embryo/presentation/features/discover/data/marker_code_generator.dart';
import 'package:nano_embryo/presentation/features/discover/data/supabase_shop_map_datasource.dart';
import 'package:nano_embryo/presentation/features/shops/info/presentation/widgets/shop_info_bottom_sheet_loader.dart';

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
      BottomSheetUtils.showDocumentationBottomSheet(
        context: context,
        widget: ShopInfoBottomSheetLoader(shopId: pin.id),
        maxHeight: 550.h,
        padding: 0,
      );
    },
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
```

Note 1: `shop_info_bottom_sheet_loader.dart` currently lives at `lib/presentation/features/map/presentation/widgets/shop_info_bottom_sheet_loader.dart`. Before deleting the old map folder in Task 6.6, MOVE this file. Run:

```bash
mkdir -p lib/presentation/features/shops/info/presentation/widgets
git mv lib/presentation/features/map/presentation/widgets/shop_info_bottom_sheet_loader.dart lib/presentation/features/shops/info/presentation/widgets/shop_info_bottom_sheet_loader.dart
```

If the destination feels wrong on inspection, choose a different home for it but update the import in `map_config.dart` to match.

Note 2: `UserLocation` may not be `.latitude` directly. Inspect `lib/core/utils/location/models/user_location.dart`; adjust the `.select(...)` closure accordingly.

- [ ] **Step 3: Verify build**

Run: `flutter analyze lib/core/map/config/ lib/presentation/features/discover/`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add -A lib/core/map/config/map_config.dart lib/presentation/features/shops/info/
git commit -m "feat(map-engine): buildNanoEmbryoMapConfig + move shop info bottom sheet loader"
```

---

### Task 6.4: Wire `mapConfigProvider` override in `main.dart`

**Files:**
- Modify: `lib/main.dart` around line 119 (next to the notification override)

- [ ] **Step 1: Read the surrounding wiring**

Run: `sed -n '115,145p' lib/main.dart` (Read tool, lines 115-145).

- [ ] **Step 2: Add the import**

Add to `lib/main.dart` (alongside the other config imports):

```dart
import 'package:nano_embryo/core/map/config/feature/map_config.dart' show mapConfigProvider;
import 'package:nano_embryo/core/map/config/map_config.dart' show buildNanoEmbryoMapConfig;
```

- [ ] **Step 3: Add the override**

Inside the `overrides:` list, immediately AFTER `notificationConfigProvider.overrideWithValue(...)`, insert:

```dart
          // Map engine config — data source + filter schema + marker style + copy
          mapConfigProvider.overrideWithValue(buildNanoEmbryoMapConfig()),
```

- [ ] **Step 4: Verify build**

Run: `flutter analyze lib/main.dart`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/main.dart
git commit -m "feat(map-engine): wire mapConfigProvider override in ProviderScope"
```

---

### Task 6.5: Switch the mounted screen

**Files:**
- Modify: `lib/presentation/home/home_screen.dart`

- [ ] **Step 1: Read the current mount point**

Run: `sed -n '60,75p' lib/presentation/home/home_screen.dart` (Read tool).

You should see a `screen: MapScreen()` line. We swap it for `MapEngineScreen`.

- [ ] **Step 2: Update the import**

In `lib/presentation/home/home_screen.dart`:

Replace:
```dart
import 'package:nano_embryo/presentation/features/map/presentation/screens/map_screen.dart';
```

With:
```dart
import 'package:nano_embryo/core/map/presentation/screens/map_screen.dart';
```

- [ ] **Step 3: Update the mount line**

Replace `screen: MapScreen()` with `screen: MapEngineScreen()`.

- [ ] **Step 4: Verify build**

Run: `flutter analyze`
Expected: `No issues found!`

(The old `lib/presentation/features/map/` still exists but is now unreferenced from the app. It will be deleted in Task 6.7.)

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/home/home_screen.dart
git commit -m "feat(map-engine): mount MapEngineScreen in home navigation"
```

---

### Task 6.6: Manual verification — the regression gate

This is the critical step. Run the app and walk through every user-facing path. Do NOT delete the legacy folder until this passes.

- [ ] **Step 1: Launch**

Run: `flutter run --flavor development`

Wait for the app to start.

- [ ] **Step 2: Navigate to the map tab**

Expected: spinner appears briefly, then shops render as pill markers with type code (SAL./BARB./…) and luxury color dot. No console crash.

- [ ] **Step 3: Test category tabs**

Tap each category tab (All, Salon, Barbershop, Spa, Nail Salon, Lash Studio, Waxing, Massage). Expected: shops refetch after a short debounce; filter chip row remains untouched.

- [ ] **Step 4: Test luxury chips**

Tap All, Moderate, Luxury, UltraLuxury. Expected: shops refetch with combined `{shop_type, luxury_level}` filter. Tapping "All" clears the secondary filter.

- [ ] **Step 5: Test marker tap**

Tap any marker. Expected: shop info bottom sheet opens with the correct shop. Marker bounces. Tap another marker — the bottom sheet swaps. Dismiss — return to map.

- [ ] **Step 6: Test pan / zoom**

Drag the map. Expected: 500ms after gesture ends, shops refetch for the new viewport. Pinch-zoom: marker icons resize smoothly.

- [ ] **Step 7: Test FAB — device GPS**

Tap the GPS FAB. Expected: location permission requested (first time) → map flies to GPS coords → shops refetched → camera fits results → FAB icon turns to `gps_fixed` (primary color). Tap again: returns to browse mode (FAB → `gps_not_fixed`).

- [ ] **Step 8: Test FAB — app location**

If you have an in-app location set, tap the app-location FAB. Expected: flies to that location, refetches, FAB highlights. Tap again — browse mode.

If you have no in-app location, tapping it should show the snackbar `"Set your location from the Discover screen first."`.

- [ ] **Step 9: Test error states**

Disable wifi / cellular. Pan the map. Expected: error card appears in the centre with a `Retry` button. Tap Retry — request retries.

- [ ] **Step 10: Test empty state**

Pan to an area with no shops (mid-ocean works). Expected: empty state card with `"This type of shop is not available in this location. You can change the luxury type for more options."` and a `Retry` action button.

- [ ] **Step 11: Hot-restart map view (recreating_view recovery)**

While on the map screen, run hot-restart (`R` in `flutter run`). Expected: map re-initialises within a few seconds without leaving a permanent spinner; if it stalls, the safety timeout kicks in and the Retry button becomes tappable.

If ANY of these steps fail, fix the underlying issue before continuing. Do NOT skip to Task 6.7 with broken behaviour.

- [ ] **Step 12: Commit verification artifact (optional)**

If you captured screenshots / a screen recording during verification, leave them locally — no commit needed.

---

### Task 6.7: Delete the legacy `features/map/` folder

**Files:**
- Delete: `lib/presentation/features/map/` (entire directory)

- [ ] **Step 1: Confirm there are no remaining references**

Run:
```bash
grep -rln "features/map/" lib/ test/ 2>/dev/null
```

Expected output: empty. If any results appear, fix those imports first (they should all point to `core/map/` now, or to `features/discover/`).

Also check for stragglers from the legacy `marker_cluster_manager.dart` and `performance_monitor.dart` (both live inside `lib/presentation/features/map/presentation/widgets/`):

```bash
grep -rln "marker_cluster_manager\|performance_monitor" lib/ test/ 2>/dev/null
```

If either is referenced from outside the doomed folder, move that file into `lib/core/map/presentation/widgets/` BEFORE deleting (use `git mv`). Otherwise, leave them — they will be removed by step 2 below.

- [ ] **Step 2: Delete**

```bash
git rm -r lib/presentation/features/map/
```

- [ ] **Step 3: Run analyzer + tests**

Run:
```bash
flutter analyze
flutter test
```
Both expected to pass.

- [ ] **Step 4: Commit**

```bash
git commit -m "refactor(map-engine): delete legacy features/map/ — all consumers on core/map/ engine"
```

---

### Task 6.8: Write `MAP_ENGINE.md`

**Files:**
- Create: `lib/core/map/MAP_ENGINE.md`

- [ ] **Step 1: Create the guide**

```markdown
# Map Engine — Integration Guide

A plug-and-play map engine for Flutter + Mapbox + Supabase (or any backend).

Copy `lib/core/map/` into any new project and follow this guide to go from zero to a working map in under an hour.

---

## What you get out of the box

| Feature | Details |
|---|---|
| Mapbox lifecycle | Platform-view `recreating_view` recovery, retry/backoff, init timeout |
| Dual fetch modes | Browse (debounced viewport) and radius (GPS / app-location) |
| 3-tier location fallback | Device GPS → in-app user location → configured fallback coords |
| Marker animation | Stagger-in appear, bounce on tap, zoom-responsive resize |
| Auto-fit camera | After a radius fetch, fits the viewport to all returned pins |
| Filter bar | Tabs + chip row driven by `MapFilterSchema` |
| Error / empty states | Themed cards with retry callbacks |
| FAB column | GPS + (optional) app-location FABs, mode-aware highlight |

---

## Prerequisites

| Dependency | Version |
|---|---|
| `flutter_riverpod` | ^2.x |
| `mapbox_maps_flutter` | latest |
| `geolocator` | latest |
| `equatable` | ^2.x |
| `flutter_screenutil` | ^5.x |

Plus the project's existing widgets: `CardInkWell`, `EmptyStateWidget`, `ErrorStateWidget`, `CircularLoadingIndicator`, `AppFilterChip`, `ShopCategoryTabs`, `ShakeTransition`, `AnimatedScaleFade`. These live in `lib/core/widgets/` and `lib/core/utils/animations/`.

---

## 1 — Implement a `MapDataSource`

Write one class for your backend / entity type.

```dart
class SupabaseEventMapDataSource implements MapDataSource {
  final SupabaseClient _client;
  SupabaseEventMapDataSource(this._client);

  @override
  Future<List<MapPin>> fetchInViewport({
    required MapBounds bounds,
    required Map<String, dynamic> filters,
    int limit = 100,
  }) async {
    final response = await _client.rpc('get_events_in_viewport', params: {
      'p_north': bounds.north,
      'p_south': bounds.south,
      'p_east': bounds.east,
      'p_west': bounds.west,
      if (filters['event_type'] != null) 'p_event_type': filters['event_type'],
      'p_limit': limit,
    });
    return (response as List).map((r) => MapPin(
      id: r['id'],
      latitude: r['latitude'],
      longitude: r['longitude'],
      data: {'event_type': r['event_type'], 'date': r['date']},
    )).toList();
  }

  @override
  Future<List<MapPin>> fetchNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
    required Map<String, dynamic> filters,
    int limit = 50,
  }) async {
    // …same pattern with get_events_nearby
  }
}
```

---

## 2 — Write your `MapConfig` factory

Create `lib/core/map/config/map_config.dart`:

```dart
MapConfig buildMyAppMapConfig() {
  return MapConfig(
    dataSource: SupabaseEventMapDataSource(Supabase.instance.client),
    filterSchema: const MapFilterSchema(
      primaryFilterKey: 'event_type',
      primaryAllOption: FilterOption(value: 'all', label: 'All'),
      primaryTabs: [
        FilterOption(value: 'concert', label: 'Concert'),
        FilterOption(value: 'festival', label: 'Festival'),
      ],
      // No chip row — leave secondaryFilterKey null:
    ),
    resolveMarkerStyle: (pin) => MarkerStyle(
      label: _eventCode(pin.data['event_type']),
      color: _eventColor(pin.data['event_type']),
    ),
    onPinTap: (pin, context) => context.push('/events/${pin.id}'),
    fallback: const MapFallback(latitude: 40.7128, longitude: -74.0060), // NYC
    copy: const MapCopy(emptyStateSubtitle: 'No events in this area.'),
  );
}
```

---

## 3 — Wire the override in `main.dart`

```dart
ProviderScope(
  overrides: [
    mapConfigProvider.overrideWithValue(buildMyAppMapConfig()),
  ],
  child: MyApp(),
)
```

---

## 4 — Mount the screen

```dart
GoRoute(path: '/map', builder: (_, __) => const MapEngineScreen()),
```

That's it. The map renders, fetches via your `MapDataSource`, runs filters from your `MapFilterSchema`, and calls your `onPinTap` callback on tap.

---

## 5 — Files to change per app

| File | What to change |
|---|---|
| `core/map/config/map_config.dart` | `buildXxxMapConfig()` body (data source, schema, resolver, fallback, copy) |
| `<your feature>/data/<your>_map_datasource.dart` | Implement `MapDataSource` for your backend |
| `main.dart` | Add `mapConfigProvider.overrideWithValue(...)` |

Everything else inside `core/map/` is generic and can be copied unchanged.

---

## 6 — Architecture overview

```
┌────────────────────────────────────────────────────┐
│  Flutter App                                       │
│                                                    │
│  MapEngineScreen ─► MapboxMap + AnimatedMarkers    │
│                  ─► MapFilterBar (schema-driven)   │
│                  ─► MapFabColumn (GPS + app loc)   │
│                                                    │
│  Riverpod Providers                                │
│  ├─ mapConfigProvider           (per-app override) │
│  ├─ mapControllerProvider       (engine state)     │
│  ├─ mapFiltersProvider          (derived)          │
│  └─ selectedPrimary/Secondary…  (state)            │
└────────────────────┬───────────────────────────────┘
                     │
                MapDataSource (your impl)
                     │
                Supabase / REST / whatever
```
```

- [ ] **Step 2: Verify the file renders**

Open `lib/core/map/MAP_ENGINE.md` in any markdown viewer; check that the code blocks render correctly.

- [ ] **Step 3: Commit**

```bash
git add lib/core/map/MAP_ENGINE.md
git commit -m "docs(map-engine): MAP_ENGINE.md integration guide"
```

---

### Task 6.9: Final analyze + test run

- [ ] **Step 1: Run full analyzer**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 2: Run full test suite**

Run: `flutter test`
Expected: all tests pass — including the three new test files (`map_pin_test`, `map_filter_schema_test`, `map_controller_test`).

- [ ] **Step 3: Final commit if anything cleanup-shaped surfaced**

If everything is clean, nothing to commit. Otherwise:

```bash
git add -A
git commit -m "chore(map-engine): post-migration cleanup"
```

---

## Done

The map engine is now a drop-in folder. To port it to another app:

1. Copy `lib/core/map/` (everything except `config/map_config.dart`).
2. Write your `MapDataSource` and `buildXxxMapConfig()` in `core/map/config/map_config.dart`.
3. Add the `ProviderScope` override.
4. Mount `MapEngineScreen` in your router.
