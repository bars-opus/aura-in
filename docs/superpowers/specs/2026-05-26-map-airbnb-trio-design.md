# Map "Airbnb Trio" — Design

**Date:** 2026-05-26
**Status:** Approved, ready for implementation planning
**Builds on:** [docs/superpowers/specs/2026-05-25-map-engine-design.md](2026-05-25-map-engine-design.md)
**Engine guide:** [architecture/MAP_ENGINE.md](../../../architecture/MAP_ENGINE.md)

---

## Goal

Bring the map engine (`lib/core/map/`) up to Airbnb-level marketplace UX by adding three reinforcing interactions:

1. **Native marker clustering** — markers cluster at low zoom and split apart on zoom-in.
2. **"Search this area" button** — replaces auto-fetch-on-pan; user explicitly triggers refresh.
3. **Horizontal card carousel** — always-visible bottom carousel, bidirectionally synced with marker selection.

These three interactions are deliberately bundled because they reinforce each other:
- Clustering reduces visible markers, making the carousel's card list manageable.
- "Search this area" replaces the carousel's confusing auto-refresh on pan.
- The carousel's marker-tap-scrolls behaviour only makes sense when each pin is individually visible (i.e. when clustering has expanded enough).

## Non-goals

- Per-cluster styling overrides via config (cluster colors / fonts hardcoded for now).
- Carousel drag-to-dismiss / collapse gestures (always-visible only).
- Skeleton/ghost pins during fetch.
- Saved/favorited shop state.
- Walking / driving time on cards.
- Result-count chip on top (could fold into pill text later; YAGNI today).

## Foundational decisions (locked during brainstorming)

| Decision | Choice | Rationale |
|---|---|---|
| Staging | One bundle, one spec, one plan | Interactions reinforce each other; designing them together avoids rework. |
| Clustering implementation | Mapbox-native: GeoJsonSource + symbol layers | Scales to thousands of markers; native zoom-driven cluster expansion; the "right" Mapbox primitive. |
| Carousel mode | Always-visible (Airbnb-style) | The signature marketplace-map interaction. Cards persist while user browses. |
| Card ownership | `MapConfig.buildCarouselCard(pin, isSelected, ctx) → Widget` | Engine renders carousel scaffolding; app supplies card visuals. Preserves engine generic-ness. |
| Tap semantics | Marker tap = scroll carousel + select. Card tap = `onPinTap` (existing modal). | Two-step browse → deep-dive. Mirrors Airbnb. |
| Pan/fetch | Button-only after initial load. Initial load still auto-fetches via GPS/app-location/fallback. | Airbnb's canonical interaction. Predictable; reduces backend calls. |
| Pill position | Top center, below status bar | Standard marketplace-map placement. Doesn't conflict with FABs or filter bar. |

---

## Layout & interaction model

### Final screen layout

```
┌─────────────────────────────────────┐
│  Status bar                         │
│         ┌─[Search this area]─┐      │ ← floating pill (only when viewportIsDirty)
│         └────────────────────┘      │
│                                     │
│             MAP                     │
│   (clusters / individual markers,   │
│    selected marker visually 1.4×    │
│    + primary color background)      │
│                                     │
│                              [⊕]    │ ← GPS FAB (existing)
│                              [○]    │ ← app-location FAB (existing)
│                                     │
│  ┌──────┐┌──────┐┌──────┐┌──────┐  │
│  │ card ││ card ││ card ││ card │  │ ← carousel (~200 dp tall)
│  └──────┘└──────┘└──────┘└──────┘  │   PageView viewportFraction 0.85
│ [primary tabs] [secondary chips]    │ ← filter bar (bottom, unchanged)
└─────────────────────────────────────┘
```

### Interaction graph

| User action | Effect |
|---|---|
| Pan / zoom map | `viewportIsDirty: true`. Pill appears at top. No auto-fetch. |
| Tap `Search this area` pill | `controller.refreshForCurrentViewport(filters)` fires. Pill hides. Carousel updates. `selectedPinId` clears. |
| Tap a marker | `controller.selectPin(pinId)`. Marker becomes selected. Carousel scrolls to that pin's card. No modal. |
| Swipe carousel to next card | `controller.selectPin(pinId)` + camera flies to that card's pin location (zoom unchanged). |
| Tap a card | `config.onPinTap(pin, ctx)` fires → existing `ShopInfoBottomSheetLoader` modal. |
| Tap a cluster | Camera flies to the zoom level at which the cluster expands (`source.getClusterExpansionZoom`). |

### Selected marker visual

- Scaled to 1.4× normal size via Mapbox `feature-state` + `iconSize` expression.
- Background overrides to primary color; text overrides to white.
- Persists until: (a) carousel scrolls away from this pin, (b) "Search this area" fires a fetch, or (c) user pans/zooms enough to remove the pin from view.

### Initial load behaviour

Unchanged from current engine: GPS → app-location → fallback, with auto-fetch on whichever tier wins. `viewportIsDirty` stays `false` after initial load. The "Search this area" pattern only kicks in after the first successful fetch settles.

---

## Architecture & API surface

### Replace `AnimatedMarkerManager` with `MarkerSourceManager`

**New file:** `lib/core/map/presentation/widgets/marker_source_manager.dart`

Owns one `GeoJsonSource('pins', cluster: true, clusterRadius: 50, clusterMaxZoom: 14)` and two symbol layers:
- `pins-clusters` — circle layer (Mapbox `CircleLayer`) with `circle-color` based on `point_count` bucket + `text-field: ['get', 'point_count_abbreviated']` overlay symbol layer.
- `pins-individual` — symbol layer using `iconImage` from named style images registered on demand.

**Style image registration:** for each distinct `(MarkerStyle.label, MarkerStyle.color.value, MarkerStyle.shape, isSelected)` tuple seen in the data, generate the image via `CanvasMarkerBuilder.drawSimpleMarker` and `mapboxMap.style.addStyleImage(...)`. Cache by tuple key. The data source's pins drive which images are registered — lazy.

**Cluster bubble image:** `CanvasMarkerBuilder.drawClusterMarker` registered as a single style image. The text count is drawn as a separate symbol layer expression rather than burnt into the image, so counts stay legible across cluster sizes.

**Tap listeners:**
- `mapboxMap.style.queryRenderedFeatures(point, [pins-clusters])` on tap → if hit, treat as cluster tap: read `clusterId`, call `source.getClusterExpansionZoom(clusterId)`, `mapboxMap.flyTo(CameraOptions(center: clusterCenter, zoom: expansionZoom + 0.5))`.
- `queryRenderedFeatures` on `[pins-individual]` → if hit, read pin id from feature properties, call `_onPinTap(pinId)` (registered callback supplied at construction).

**Selection state:** `mapboxMap.setFeatureState(sourceId: 'pins', featureId: selectedPinId, state: {'selected': true})` whenever `selectedPinId` changes. The `pins-individual` layer's `iconSize` is an expression: `['case', ['boolean', ['feature-state', 'selected'], false], 1.4, 1.0]`. Same expression chooses the "selected" image variant for `iconImage`.

**What goes away from the old manager:**
- Stagger-in animation on `updateMarkers` (Mapbox can't do per-feature stagger trivially).
- Bounce-on-tap animation (replaced by persistent selection state).
- The image-pre-caching pass (Mapbox auto-caches style images).
- `_animationControllers` map (no per-feature controllers).
- `onViewportChangeNeeded` callback (we no longer auto-fetch on zoom).

**What stays:**
- `CanvasMarkerBuilder.drawSimpleMarker` (unchanged) — generates pill images on demand.
- `CanvasMarkerBuilder.drawClusterMarker` (was unused; now used for cluster image registration).

### New: `MapPinCarousel`

**New file:** `lib/core/map/presentation/widgets/map_pin_carousel.dart`

```dart
class MapPinCarousel extends ConsumerStatefulWidget {
  const MapPinCarousel({super.key});

  @override
  ConsumerState<MapPinCarousel> createState() => _MapPinCarouselState();
}
```

**Behaviour:**
- Watches `mapControllerProvider.select((s) => s.pins)`. When `pins.isEmpty`, returns `SizedBox.shrink()` (collapses to zero height). Wrapped in `AnimatedScaleFade` for show/hide transitions.
- `PageView.builder` with `viewportFraction: 0.85`, `controller: _pageController`, `physics: PageScrollPhysics()`.
- Each card built via `config.buildCarouselCard(pins[index], pins[index].id == state.selectedPinId, context)`.
- The carousel wraps each card in a `GestureDetector(onTap: () => config.onPinTap(pin, context))`. Tap-handling is centralized in the carousel, not the card — keeps the card builder simple and avoids each app re-implementing tap wiring.
- Page change handler:
  ```dart
  _pageController.addListener(() {
    if (_isProgrammaticChange) return;
    final page = _pageController.page!.round();
    final pin = pins[page];
    ref.read(mapControllerProvider.notifier).selectPin(pin.id);
    // Flyto handled by screen's listener on selectedPinId.
  });
  ```
- `ref.listen` on `selectedPinIdProvider`:
  ```dart
  ref.listen(selectedPinIdProvider, (prev, next) {
    if (next == null || next == _currentPinId) return;
    final index = pins.indexWhere((p) => p.id == next);
    if (index < 0) return;
    _isProgrammaticChange = true;
    _pageController.animateToPage(index, duration: 300ms, curve: Curves.easeOut);
    Future.delayed(350ms, () => _isProgrammaticChange = false);
  });
  ```

**Height:** 200 dp (constant). Sits above the filter bar (`bottomNavigationBar` slot keeps the filter bar; carousel goes inside the main `Stack` above the bottom-positioned filter bar via a `Positioned` widget).

### New: `SearchThisAreaPill`

**New file:** `lib/core/map/presentation/widgets/search_this_area_pill.dart`

```dart
class SearchThisAreaPill extends ConsumerWidget {
  const SearchThisAreaPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDirty = ref.watch(
      mapControllerProvider.select((s) => s.viewportIsDirty),
    );
    final copy = ref.watch(mapConfigProvider.select((c) => c.copy));
    if (!isDirty) return const SizedBox.shrink();
    return AnimatedScaleFade(
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: () {
          final controller = ref.read(mapControllerProvider.notifier);
          final filters = ref.read(mapFiltersProvider);
          controller.refreshForCurrentViewport(filters);
        },
        child: Container(
          // pill styling: primary color background, white text,
          // borderRadius pill, padding, slight elevation
          child: Text(copy.searchThisAreaLabel),
        ),
      ),
    );
  }
}
```

Mounted in the screen's `Stack`:
```dart
Positioned(
  top: MediaQuery.of(context).padding.top + Spacing.lg,
  left: 0,
  right: 0,
  child: const Center(child: SearchThisAreaPill()),
),
```

### `MapConfig` additions

```dart
class MapConfig {
  // …existing fields…

  /// Builds one card for the horizontal carousel. Called per visible pin.
  /// Receives [isSelected] so the card can highlight when its marker
  /// is active.
  final Widget Function(MapPin pin, bool isSelected, BuildContext context)
      buildCarouselCard;

  /// Mapbox cluster radius in screen pixels. Defaults to 50.
  final double clusterRadius;

  /// Maximum zoom at which clusters still form. Beyond this, every pin
  /// is shown individually. Defaults to 14.
  final double clusterMaxZoom;

  const MapConfig({
    // …existing required fields…
    required this.buildCarouselCard,
    this.clusterRadius = 50,
    this.clusterMaxZoom = 14,
    // …existing optional fields…
  });
}
```

### `MapCopy` addition

```dart
class MapCopy {
  // …existing fields…
  final String searchThisAreaLabel;

  const MapCopy({
    // …
    this.searchThisAreaLabel = 'Search this area',
  });
}
```

### `MapState` additions

```dart
class MapState {
  // …existing fields…
  final String? selectedPinId;
  final bool viewportIsDirty;

  const MapState({
    // …
    this.selectedPinId,
    this.viewportIsDirty = false,
  });

  MapState copyWith({
    // …existing params…
    Object? selectedPinId = _kAbsent,  // sentinel — allow setting to null
    bool? viewportIsDirty,
  }) {
    return MapState(
      // …
      selectedPinId: identical(selectedPinId, _kAbsent)
          ? this.selectedPinId
          : selectedPinId as String?,
      viewportIsDirty: viewportIsDirty ?? this.viewportIsDirty,
    );
  }
}
```

### `MapController` changes

```dart
class MapController extends StateNotifier<MapState> {
  // …existing internals…

  /// Pan/zoom update. No longer fetches. Just records the new bounds,
  /// switches to browse mode, and flags the viewport as dirty so the
  /// "Search this area" pill knows to appear.
  void updateViewport(MapBounds bounds, Map<String, dynamic> filters) {
    if (!bounds.isValid()) return;
    state = state.copyWith(
      currentBounds: bounds,
      fetchMode: MapFetchMode.browse,
      viewportIsDirty: true,
    );
    // No debounce timer. No fetch.
  }

  /// Explicit fetch for the current viewport + filters. Called by the
  /// "Search this area" pill.
  Future<void> refreshForCurrentViewport(Map<String, dynamic> filters) async {
    if (state.currentBounds == null) return;
    await _fetchInBounds(state.currentBounds!, filters);
    if (!mounted) return;
    state = state.copyWith(
      viewportIsDirty: false,
      selectedPinId: null,  // clear selection on fresh fetch
    );
  }

  /// Set or clear the active marker/card selection.
  void selectPin(String? pinId) {
    if (state.selectedPinId == pinId) return;
    state = state.copyWith(selectedPinId: pinId);
  }

  // _fetchInBounds, fetchNearby, refresh, clearError, resetToIdle —
  // unchanged from current engine.
}
```

Important: `fetchNearby` (GPS / app-location radius fetch) does NOT toggle `viewportIsDirty` or clear `selectedPinId`. It's a different kind of fetch — explicitly user-initiated via a FAB. The pill semantics apply only to pan-driven viewport changes.

### Optional convenience provider

```dart
final selectedPinIdProvider = Provider<String?>(
  (ref) => ref.watch(mapControllerProvider.select((s) => s.selectedPinId)),
);
```

Used by `MapPinCarousel` and `MarkerSourceManager` to listen for selection changes without watching the whole controller state.

---

## Migration plan

The bundle ships in 5 ordered slices. Each slice ends with the app runnable.

### Slice A — Decouple viewport from fetch

- Modify `MapController.updateViewport` to remove the debounce timer and the `_fetchInBounds` call. New behaviour: set bounds + dirty flag + browse mode. No fetch.
- Add `MapController.refreshForCurrentViewport(filters)`.
- Add `selectPin(String?)` method.
- Add `selectedPinId` and `viewportIsDirty` fields on `MapState` + `copyWith`.
- Update existing controller tests:
  - "debounces multiple rapid calls" → flip to "no auto-fetch on updateViewport"; verify `viewportIsDirty` becomes true.
  - Add tests for `refreshForCurrentViewport` and `selectPin`.
- Visible behaviour change: panning the map no longer refreshes shops. Pill in Slice C makes this usable. Do NOT manually verify between Slice A and Slice C.

### Slice B — `MarkerSourceManager`

- Create `lib/core/map/presentation/widgets/marker_source_manager.dart`.
- Implement `GeoJsonSource` setup, two symbol layers, style-image registration on demand.
- Implement cluster tap → expansion-zoom flyTo.
- Implement individual pin tap → emit `onPinTap(pinId)` callback.
- Implement `feature-state`-based selection highlight.
- Replace `AnimatedMarkerManager` usage in `map_screen.dart`.
- Delete `lib/core/map/presentation/widgets/animated_marker_manager.dart`.
- Add `clusterRadius` (default 50) and `clusterMaxZoom` (default 14) to `MapConfig`.
- Manual sanity at end of slice: pan to area with many pins → see clusters → tap one → flies in.

### Slice C — `SearchThisAreaPill`

- Create `lib/core/map/presentation/widgets/search_this_area_pill.dart`.
- Add `searchThisAreaLabel` to `MapCopy` with default `'Search this area'`.
- Mount in `map_screen.dart`'s `Stack` at top-center via `Positioned`.
- After this slice, panning + tapping pill triggers a fresh fetch. Slice A regression is healed.
- Manual sanity: pan map → pill appears → tap → shops refresh → pill hides.

### Slice D — `MapPinCarousel` + selection sync

- Add `buildCarouselCard` field to `MapConfig` (required).
- Create `lib/core/map/presentation/widgets/map_pin_carousel.dart`.
- Wire bidirectional sync between `_pageController` and `selectedPinId`, with `_isProgrammaticChange` guard.
- Mount carousel in `map_screen.dart` above the filter bar.
- Wire screen-level `ref.listen` on `selectedPinId` → `mapboxMap.flyTo` to the pin's position (zoom unchanged).
- Update `MarkerSourceManager` to listen for `selectedPinId` and update feature-state.
- Create `lib/presentation/features/shops/query/presentation/widgets/shop_map_card.dart` — the per-shop compact card (image + name + rating + price + distance).
- Update `buildNanoEmbryoMapConfig` to supply `buildCarouselCard: (pin, isSelected, ctx) => ShopMapCard(pin: pin, isSelected: isSelected)`.

### Slice E — Final wiring + docs

- Update `architecture/MAP_ENGINE.md`:
  - Document the new `buildCarouselCard`, `clusterRadius`, `clusterMaxZoom` fields.
  - Document `MapCopy.searchThisAreaLabel`.
  - Update the example `buildXxxMapConfig` snippet.
  - Note the new interaction semantics (marker tap scrolls carousel; card tap opens modal).
- Run `flutter analyze` and `flutter test test/map/`.
- User does manual verification of the new flow (Slice E gate).

---

## Risk areas

| Risk | Mitigation |
|---|---|
| Mapbox style-image registration timing — images must exist before symbol layer references them | Register all required images **before** adding the symbol layers. Gate layer creation on `Future.wait([...])` of image registrations. |
| `feature-state` API support in `mapbox_maps_flutter ^2.1.0` | Verify with a quick spike during Slice B. If broken, fall back to data-driven updates (push the source data with a `selected: true` property on the active feature; slower but compatible). |
| Carousel ↔ marker sync infinite loop | `_isProgrammaticChange` flag set before triggering the programmatic action, cleared after a short delay. Same pattern used in existing notification settings screen. |
| Pan-without-fetch feels broken if user lands on Slice A alone | Don't manually verify between A and C. Bundle Slice A+B+C minimum before user testing. |
| Lazy style-image registration causes flicker on first appearance of a new marker style | Pre-register all images for the visible pins as part of the `MarkerSourceManager.updatePins(pins)` flow, before adding features to the source. |
| Cluster tap accuracy on small clusters | Mapbox's `queryRenderedFeatures` uses a small bounding box around the tap point; on dense cluster overlap, the topmost feature wins. Acceptable. |
| `mapbox_maps_flutter` API differences for `GeoJsonSource` vs `PointAnnotationManager` (the existing code path) | Confirmed in plan-time research: Mapbox v2.x supports `GeoJsonSource(cluster: true, ...)` and the `Style.addStyleImage` / `Style.addLayer` APIs. If a method signature differs, adjust during Slice B implementation. |

---

## Files changed summary

**New:**
- `lib/core/map/presentation/widgets/marker_source_manager.dart`
- `lib/core/map/presentation/widgets/map_pin_carousel.dart`
- `lib/core/map/presentation/widgets/search_this_area_pill.dart`
- `lib/presentation/features/shops/query/presentation/widgets/shop_map_card.dart`

**Modified:**
- `lib/core/map/presentation/controllers/map_controller.dart` (decouple viewport from fetch, add `selectPin`, `refreshForCurrentViewport`, two new state fields)
- `lib/core/map/presentation/screens/map_screen.dart` (mount carousel + pill, rewire viewport listener, swap marker manager)
- `lib/core/map/config/feature/map_config.dart` (add `buildCarouselCard`, `clusterRadius`, `clusterMaxZoom`)
- `lib/core/map/config/feature/map_copy.dart` (add `searchThisAreaLabel`)
- `lib/core/map/config/map_config.dart` (NanoEmbryo builder: supply `buildCarouselCard` callback)
- `architecture/MAP_ENGINE.md` (document the three new fields + new copy field + new interaction semantics)
- `test/map/map_controller_test.dart` (replace debounce test with "no auto-fetch" test; add tests for `refreshForCurrentViewport` and `selectPin`)

**Deleted:**
- `lib/core/map/presentation/widgets/animated_marker_manager.dart`

---

## Verification

After all slices, the manual flow extends the existing 11-step verification with these new steps:

12. **Cluster zoom-in** — pan to a country-level view → see cluster bubbles with counts → tap one → camera flies in until clusters split into individual pins.
13. **`Search this area` flow** — pan the map → pill appears at top-center → tap pill → fetch fires → pill hides → carousel updates with new pins.
14. **Marker → carousel sync** — tap a marker → carousel scrolls to that pin's card → marker visually selected (1.4× + primary color).
15. **Carousel → marker sync** — swipe carousel left/right → camera flies to corresponding pin → marker visually selected.
16. **Card tap** — tap a card → existing `ShopInfoBottomSheetLoader` opens with the shop details.
17. **Selection clears on refresh** — with a marker selected, tap `Search this area` → selection clears (no marker highlighted).
18. **Carousel hides when empty** — pan to a no-shops area → tap pill → carousel collapses; tap pill in a shops area → carousel reappears.
19. **Cluster + carousel coexistence** — when zoomed out enough that clusters show, the carousel still works because it draws from `state.pins` (all of them); but cluster taps zoom in rather than scrolling carousel.

---

## Generic-ness preserved

All app-specific behaviour stays in `lib/core/map/config/map_config.dart` (the per-app builder) and `lib/presentation/features/shops/query/`:

- `buildCarouselCard: (pin, isSelected, ctx) => ShopMapCard(...)` — the only line tying the engine to NanoEmbryo's shop card design.
- `ShopMapCard` widget lives entirely outside `lib/core/map/`.
- A future events app provides its own `EventMapCard` plus a matching `buildCarouselCard` callback. No engine changes needed.
- `clusterRadius` and `clusterMaxZoom` are config-tunable; default values make the engine work zero-config.
- `searchThisAreaLabel` has a sensible default; apps override only for localization.
