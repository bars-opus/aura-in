# Map Engine — Design

**Date:** 2026-05-25
**Status:** Approved, ready for implementation planning
**Reference pattern:** `lib/core/notifications/` (notification engine)

---

## Goal

Refactor the current map feature (`lib/presentation/features/map/`) into a self-contained, drop-in engine at `lib/core/map/` that mirrors the notification engine pattern: **only one file (`map_config.dart`) changes per app**. The engine must be portable to other Flutter apps without modification — today's shop map and a hypothetical future events map differ only in the config they pass in.

## Non-goals

- Marker clustering changes (`marker_cluster_manager.dart` already pluggable enough).
- The `performance_monitor.dart` dev widget.
- Any change to Supabase RPC signatures, `MapBounds` semantics, or the Mapbox platform-view recovery logic.
- A standalone Dart package extraction — the engine stays inside `lib/core/map/` as a copyable folder, matching `core/notifications/`.

## Foundational decisions (locked during brainstorming)

| Decision | Choice | Rationale |
|---|---|---|
| Scope | Refactor + extract as drop-in folder | Matches NOTIFICATION_ENGINE.md pattern: copy `core/map/` into new app, edit one file. |
| Entity model | Untyped data bag (`MapPin { id, lat, lng, data }`) | Mirrors `ScheduledNotification.metadata`. No generics overhead. |
| Data fetching | Engine owns controller; config supplies `MapDataSource` adapter | Keeps debounce, generation tokens, browse-vs-radius logic generic. App writes only the RPC adapter. |
| Filter bar | Schema-driven (tabs + chips from `MapFilterSchema`) | Covers shops/events/listings without code changes. |
| Marker rendering | Schema-driven (`MarkerStyleResolver` returning `{label, color, shape}`) | Today's `MarkerCodeGenerator` collapses to one function. |
| App-location integration | `ProviderListenable<LatLng?>?` field on `MapConfig` | Decouples engine from `userLocationNotifierProvider`. FAB hides when null. |
| Copy + fallback | Bundled `MapCopy` + `MapFallback` records with defaults | Minimal config stays small; defaults prevent "shop" copy leaking into other apps. |

---

## Architecture

### Folder structure

```
lib/core/map/
├── MAP_ENGINE.md                       # Integration guide (mirrors NOTIFICATION_ENGINE.md)
├── config/
│   ├── map_config.dart                 # ← ONLY file that changes per app
│   ├── map_filter_schema.dart          # MapFilterSchema, FilterOption
│   ├── map_copy.dart                   # MapCopy record (defaults inside)
│   ├── map_fallback.dart               # MapFallback record + LatLng type
│   └── marker_style.dart               # MarkerStyle, MarkerShape enum, MarkerStyleResolver typedef
├── domain/
│   ├── entities/
│   │   ├── map_pin.dart                # { id, latitude, longitude, data }
│   │   └── map_bounds.dart             # moved from old controllers/
│   └── data_source/
│       └── map_data_source.dart        # abstract MapDataSource adapter
├── presentation/
│   ├── providers/
│   │   ├── map_config_provider.dart    # Provider<MapConfig> (overridden in main.dart)
│   │   └── map_filter_providers.dart   # generic primary/secondary filter state
│   ├── controllers/
│   │   └── map_controller.dart         # generic; reads config + data source
│   ├── screens/
│   │   └── map_screen.dart             # MapEngineScreen — the screen apps mount
│   └── widgets/
│       ├── map_filter_bar.dart         # renders MapFilterSchema
│       ├── animated_marker_manager.dart # uses MarkerStyleResolver
│       ├── canvas_marker_builder.dart  # extended with MarkerShape enum
│       └── map_fab_column.dart         # GPS + appLocation FABs (latter hides if no appLocationProvider)
```

### Boundary line

Everything inside `lib/core/map/` is generic. Only `lib/core/map/config/map_config.dart` (and the app's `MapDataSource` implementation, which lives in the app's feature folder, not in `core/map/`) changes per app.

### Wiring per app (`main.dart`)

```dart
ProviderScope(
  overrides: [
    mapConfigProvider.overrideWithValue(buildNanoEmbryoMapConfig(ref)),
  ],
  child: MyApp(),
)
```

Screen consumers become: `const MapEngineScreen()`.

---

## API surface

### `MapPin` — universal entity

```dart
class MapPin extends Equatable {
  final String id;
  final double latitude;
  final double longitude;
  final Map<String, dynamic> data;   // app-specific fields

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

Today's `ShopLocationDTO` becomes:
```dart
MapPin(
  id: row['id'],
  latitude: row['latitude'],
  longitude: row['longitude'],
  data: {
    'shop_type': row['shop_type'],
    'luxury_level': row['luxury_level'],
  },
)
```

### `MapDataSource` — the one interface apps implement

```dart
abstract class MapDataSource {
  Future<List<MapPin>> fetchInViewport({
    required MapBounds bounds,
    required Map<String, dynamic> filters,
    int limit,
  });

  Future<List<MapPin>> fetchNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
    required Map<String, dynamic> filters,
    int limit,
  });
}
```

The `filters` map is whatever the engine assembled from the schema (e.g. `{shop_type: 'salon', luxury_level: 'Moderate'}` or `{event_type: 'concert', date_range: 'this_week'}`). The adapter pulls the keys it knows about and ignores the rest.

### `MapFilterSchema` — drives the filter bar UI

```dart
class FilterOption {
  final String value;          // passed to data source as filter key
  final String label;          // displayed in UI
  const FilterOption({required this.value, required this.label});
}

class MapFilterSchema {
  final String primaryFilterKey;       // e.g. 'shop_type'
  final List<FilterOption> primaryTabs;
  final FilterOption? primaryAllOption; // null = no "All" tab

  final String? secondaryFilterKey;    // e.g. 'luxury_level'; null hides chip row
  final List<FilterOption> secondaryChips;
  final FilterOption? secondaryAllOption;

  const MapFilterSchema({...});
}
```

Engine assembles the filter map as `{primaryFilterKey: selectedPrimaryValue, secondaryFilterKey: selectedSecondaryValue}`, omitting keys whose value matches the corresponding "All" option.

### `MarkerStyle` resolver — drives marker visuals

```dart
enum MarkerShape { pill, circle, square }   // CanvasMarkerBuilder supports these

class MarkerStyle {
  final String label;          // 'SAL.', '$45', 'TODAY'
  final Color color;           // background
  final MarkerShape shape;     // default pill (current behaviour)
  const MarkerStyle({
    required this.label,
    required this.color,
    this.shape = MarkerShape.pill,
  });
}

typedef MarkerStyleResolver = MarkerStyle Function(MapPin pin);
```

Today's `MarkerCodeGenerator` becomes a one-liner in the config:
```dart
resolveMarkerStyle: (pin) => MarkerStyle(
  label: MarkerCodeGenerator.getTypeCode(pin.data['shop_type'] as String?),
  color: MarkerCodeGenerator.getLuxuryColor(pin.data['luxury_level'] as String?),
),
```

`MarkerCodeGenerator` moves to the app's feature folder (it's app-specific) and is referenced only from the config.

### `MapCopy` + `MapFallback` — small bits, defaults provided

```dart
class MapCopy {
  final String emptyStateSubtitle;          // default: 'No results in this area.'
  final String errorRetryLabel;             // default: 'Retry'
  final String locationPermissionTitle;     // default: 'Location Permission Required'
  final String locationPermissionBody;      // default: 'Please enable location permission…'
  final String appLocationMissingSnackbar;  // default: 'Set your location first.'

  const MapCopy({
    this.emptyStateSubtitle = 'No results in this area.',
    // …all fields have defaults
  });
}

class LatLng {
  final double latitude;
  final double longitude;
  const LatLng({required this.latitude, required this.longitude});
}

class MapFallback {
  final double latitude;
  final double longitude;
  final double initialZoom;     // default 12.0
  const MapFallback({
    required this.latitude,
    required this.longitude,
    this.initialZoom = 12.0,
  });
}
```

### The full `MapConfig`

```dart
class MapConfig {
  final MapDataSource dataSource;
  final MapFilterSchema filterSchema;
  final MarkerStyleResolver resolveMarkerStyle;
  final void Function(MapPin pin, BuildContext context) onPinTap;
  final MapFallback fallback;
  final MapCopy copy;

  /// Optional: provider exposing the app's user-chosen location.
  /// When null, the app-location FAB hides and tier-2 fallback is skipped.
  final ProviderListenable<LatLng?>? appLocationProvider;

  /// Optional: per-screen tuning. Defaults are current production values.
  final double defaultRadiusKm;          // 5.0
  final int viewportLimit;               // 100
  final int nearbyLimit;                 // 50
  final Duration viewportDebounce;       // 500ms

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
```

### Reference `buildNanoEmbryoMapConfig()`

```dart
MapConfig buildNanoEmbryoMapConfig(Ref ref) {
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
      label: MarkerCodeGenerator.getTypeCode(pin.data['shop_type'] as String?),
      color: MarkerCodeGenerator.getLuxuryColor(pin.data['luxury_level'] as String?),
    ),
    onPinTap: (pin, context) => BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      widget: ShopInfoBottomSheetLoader(shopId: pin.id),
      maxHeight: 550.h,
      padding: 0,
    ),
    fallback: const MapFallback(latitude: 6.5244, longitude: 3.3792),
    appLocationProvider: userLocationNotifierProvider.select(
      (s) => s == null ? null : LatLng(latitude: s.latitude, longitude: s.longitude),
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

---

## Migration plan

Six ordered slices. Each is independently committable; the app stays runnable between slices.

### Slice 1 — Genericise the entity and data source contract
- Create `lib/core/map/domain/entities/map_pin.dart` (`MapPin` class).
- Move `MapBounds` from the existing controller file to `lib/core/map/domain/entities/map_bounds.dart`.
- Create `lib/core/map/domain/data_source/map_data_source.dart` (`MapDataSource` interface with `fetchInViewport` + `fetchNearby`).
- Add a temporary adapter in the existing shop feature that wraps the current `MapRepository` and converts `ShopLocationDTO` → `MapPin`. App still builds.

### Slice 2 — Genericise the controller
- Create `lib/core/map/presentation/controllers/map_controller.dart` (generic version: `List<MapPin>`, `Map<String, dynamic>` filters).
- Preserve all current behaviour: debounce, generation tokens, `MapFetchMode` (browse/deviceGps/appLocation), `resetToIdle`, `clearError`.
- The existing feature's controller becomes a thin wrapper that delegates so the current screen keeps working during migration.

### Slice 3 — Build the config types & provider
- Create `lib/core/map/config/map_config.dart`, `map_filter_schema.dart`, `marker_style.dart`, `map_copy.dart`, `map_fallback.dart`.
- Add `lib/core/map/presentation/providers/map_config_provider.dart` exposing `Provider<MapConfig>` that throws `UnimplementedError` if not overridden (matches notification pattern).
- Move `CanvasMarkerBuilder` to `lib/core/map/presentation/widgets/canvas_marker_builder.dart` and extend it to accept the `MarkerShape` enum (default `pill` = current behaviour).

### Slice 4 — Genericise widgets
- Move `animated_marker_manager.dart` to `core/map/`. Replace direct `ShopLocationDTO` references with `MapPin`. Marker styling calls `config.resolveMarkerStyle(pin)`. Change the marker image cache key from `${shop.id}_${shop.luxuryLevel}_${shop.shopType}_…` to one keyed on the resolved style (`${pin.id}_${style.label}_${style.color.value}_${style.shape}_…`) so the cache stays correct across resolver swaps.
- Move `map_filter_bar.dart` to `core/map/`. Replace hardcoded `_categories` and `_luxuryLevels` with reading `config.filterSchema`. Replace `selectedMapCategoryProvider` / `selectedMapLuxuryProvider` with generic `selectedPrimaryFilterProvider` / `selectedSecondaryFilterProvider` in `core/map/presentation/providers/map_filter_providers.dart`. The combined filter map is built by watching the schema + selections.
- Extract `map_fab_column.dart` from the screen. Hides the app-location FAB when `config.appLocationProvider == null`.

### Slice 5 — Genericise the screen
- Move `map_screen.dart` to `core/map/presentation/screens/map_screen.dart`, renamed to `MapEngineScreen`.
- Replace tier-2 `ref.read(userLocationNotifierProvider)` with `config.appLocationProvider == null ? null : ref.read(config.appLocationProvider!)`.
- Replace Lagos constants with `config.fallback.latitude/longitude`.
- Replace `ShopLocationDTO` references with `MapPin`.
- Replace `_onMarkerTap` body with `config.onPinTap(pin, context)`.
- Replace empty-state subtitle with `config.copy.emptyStateSubtitle`.

### Slice 6 — Wire the app
- Create `lib/presentation/features/discover/data/supabase_shop_map_datasource.dart` — real `MapDataSource` for shops, calls `get_shops_in_viewport` / `get_shops_nearby`, maps rows to `MapPin`.
- Create `lib/app/config/map_config.dart` with `buildNanoEmbryoMapConfig()`.
- Add `mapConfigProvider.overrideWithValue(...)` to `ProviderScope` in `main.dart`.
- Delete `lib/presentation/features/map/` entirely. Replace any consumers with `const MapEngineScreen()`.
- Write `lib/core/map/MAP_ENGINE.md` (integration guide mirroring `NOTIFICATION_ENGINE.md`).

---

## Verification

After each slice, the existing shop map screen must still work end-to-end:

1. Open map → see shops on map.
2. Tap category tab → shops refetch with new filter.
3. Tap luxury chip → shops refetch with combined filter.
4. Tap marker → bottom sheet opens with shop info.
5. Dismiss sheet → return to map.
6. Pan/zoom → fetch refreshes (debounced).
7. Tap device GPS FAB → fly to GPS, fetch nearby, camera fits results.
8. Tap app-location FAB → fly to app location, fetch nearby, camera fits results.
9. Tap GPS FAB again while active → returns to browse mode.

The existing manual flow is the regression gate; no new tests are proposed.

---

## Risks & mitigations

| Risk | Mitigation |
|---|---|
| Mapbox platform-view lifecycle is fragile (`recreating_view` crashes) | Slice 5 preserves the current intercept/retry/backoff logic verbatim; only data references change. |
| Filter providers watched widely | Slice 4 keeps a derived `mapFiltersProvider` returning `Map<String, dynamic>`; the controller's `ref.listen(mapFiltersProvider)` only needs a one-line type swap. |
| `ShopInfoBottomSheetLoader` requires `shopId` | Slice 5 passes `pin.id` directly via `config.onPinTap`. Shop ID = pin ID 1:1, no schema change. |
| Marker image cache key currently embeds `shopType`/`luxuryLevel` | Slice 4 changes the cache key in `animated_marker_manager.dart` to include `style.label` + `style.color.value` + `style.shape` instead, so the cache stays correct when the resolver is swapped. |
| `MarkerCodeGenerator` referenced from new config file | Move it to a per-app location (`lib/presentation/features/discover/data/`) so it doesn't sit inside `core/map/`. |
| `userLocationNotifierProvider` returns a custom type, not `LatLng` | Use `.select((s) => LatLng(...))` in the config to project it. Keeps the engine's contract clean. |

---

## Files changed summary

**Deleted:**
- `lib/presentation/features/map/` (entire folder)

**Created in `lib/core/map/`:**
- `MAP_ENGINE.md`
- `config/{map_config,map_filter_schema,map_copy,map_fallback,marker_style}.dart`
- `domain/entities/{map_pin,map_bounds}.dart`
- `domain/data_source/map_data_source.dart`
- `presentation/providers/{map_config_provider,map_filter_providers}.dart`
- `presentation/controllers/map_controller.dart`
- `presentation/screens/map_screen.dart`
- `presentation/widgets/{map_filter_bar,animated_marker_manager,canvas_marker_builder,map_fab_column}.dart`

**Created in app:**
- `lib/presentation/features/discover/data/supabase_shop_map_datasource.dart`
- `lib/app/config/map_config.dart` (`buildNanoEmbryoMapConfig()`)

**Moved (not changed in substance):**
- `lib/presentation/features/map/data/marker_code_generator.dart` → `lib/presentation/features/discover/data/marker_code_generator.dart` (referenced only from the app's `MapConfig`, no longer from inside the engine).

**Modified:**
- `lib/main.dart` (one `ProviderScope` override)
- Any caller currently mounting the old map screen → mounts `const MapEngineScreen()`

---

## Out of scope (explicitly)

- Marker clustering algorithm changes.
- The `performance_monitor.dart` dev widget.
- Supabase RPC signature changes.
- Standalone Dart package extraction (the folder pattern is sufficient).
- Tests beyond the existing manual flow.
