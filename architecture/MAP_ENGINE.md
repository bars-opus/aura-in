# Map Engine — Integration Guide

A plug-and-play map engine for Flutter + Mapbox + Supabase (or any backend).

Copy `lib/core/map/` into any new project and follow this guide to go from zero to a working map in under an hour.

---

## What you get out of the box

| Feature | Details |
|---|---|
| Mapbox lifecycle | Platform-view `recreating_view` recovery, retry/backoff, init timeout |
| Dual fetch modes | Browse (explicit pill) and radius (GPS / app-location) |
| 3-tier location fallback | Device GPS → in-app user location → configured fallback coords |
| Marker animation | Stagger-in appear, bounce on tap, zoom-responsive resize |
| Auto-fit camera | After a radius fetch, fits the viewport to all returned pins |
| Filter bar | Tabs + chip row driven by `MapFilterSchema` |
| Error / empty states | Themed cards with retry callbacks |
| FAB column | GPS + (optional) app-location FABs, mode-aware highlight |
| Native clustering | Mapbox-native cluster bubbles that expand on zoom-in |
| Search-this-area pill | Pan-to-explore pattern; user explicitly triggers fetches via top-center pill |
| Card carousel | Always-visible horizontal carousel synced bidirectionally with markers |

---

## Prerequisites

| Dependency | Version |
|---|---|
| `flutter_riverpod` | ^2.x |
| `mapbox_maps_flutter` | latest |
| `geolocator` | latest |
| `equatable` | ^2.x |
| `flutter_screenutil` | ^5.x |

Plus the project's existing widgets: `CardInkWell`, `EmptyStateWidget`, `ErrorStateWidget`, `CircularLoadingIndicator`, `AppFilterChip`, `HorizontalCategoryTabs`, `ShakeTransition`, `AnimatedScaleFade`.

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
    return const [];
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
      // No chip row — leave secondaryFilterKey null.
    ),
    resolveMarkerStyle: (pin) => MarkerStyle(
      label: _eventCode(pin.data['event_type']),
      color: _eventColor(pin.data['event_type']),
    ),
    onPinTap: (pin, context) => context.push('/events/${pin.id}'),
    buildCarouselCard: (pin, isSelected, context) => MyEventCard(pin: pin, isSelected: isSelected),
    clusterRadius: 50,
    clusterMaxZoom: 14,
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

## Interaction semantics

- **Initial load**: auto-fetch via 3-tier fallback (GPS → app-location → configured fallback). No pill.
- **User pans/zooms**: `viewportIsDirty: true`. The `Search this area` pill appears at top-center. NO auto-fetch.
- **User taps the pill**: explicit fetch fires for the current viewport. Pill hides on success.
- **User taps a marker**: carousel scrolls to that pin's card; marker becomes visually selected (1.4× scale + accent color). NO modal.
- **User swipes the carousel**: corresponding marker becomes selected; camera flies to that pin (zoom unchanged).
- **User taps a card**: `config.onPinTap(pin, ctx)` fires — opens whatever modal/screen the app wires up (e.g. `ShopInfoBottomSheetLoader` in NanoEmbryo).
- **User taps a cluster bubble**: camera flies in by ~+2 zoom levels until the cluster splits.

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
| `MapCopy.searchThisAreaLabel` | Override for non-English locales. Default `'Search this area'`. |

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
