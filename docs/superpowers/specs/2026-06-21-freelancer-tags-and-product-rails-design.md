# Freelancer Tags & Product Discovery Rails — Design

**Date:** 2026-06-21
**Status:** Approved (design); pending spec review
**Compliance target:** Algorithm Quality Review Checklist v3.1

## Goal

Two independent discovery improvements for the marketplace:

- **Feature A — Freelancer Tags:** Replace the freelancer free-text "Specialties"
  input with a curated + custom multi-select **Tags** system, and use tags to
  filter/group freelancers on the discover screen (multi-select, overlap match).
- **Feature B — Product Discovery Rails:** Add `Top-Rated` and `Near-You`
  horizontal product rails to the discover **Buy** tab, mirroring the existing
  freelancer rails. The full-grid "All Products" section remains below.

The two features share no code and can be built/shipped independently. They are
combined in one spec because the user requested them together.

## Scope Awareness

This is a feature addition to an existing, working marketplace ([MARKETPLACE]
+ [SERVICE]/[MUTATION] for the freelancer write path). It is **not** [FIN] —
no money math changes. Checklist focus: input validation (2.1), parameterized
queries (2.2), resource limits / row caps (2.5), no N+1 (perf), surgical
changes that don't regress existing discover behavior.

**Explicitly out of scope (per user):**
- Product category selector on ProductFormScreen — already works; keep as the
  existing single-select dropdown. No change.

---

## Feature A: Freelancer Tags

### A.1 Storage (no schema migration for storage)

Tags reuse the existing `workers.specialties text[]` column. The DB column keeps
the name `specialties`; only the **UI concept** and **discovery use** change.
All existing read paths (nearby RPCs already return `specialties text[]`) keep
working unchanged. A code comment at each touch point notes the
`specialties`-column / `tags`-concept mapping so future readers aren't confused.

Rationale: renaming a populated `text[]` column + every RPC `RETURNS TABLE`
signature that exposes it is a large, risky migration for zero functional gain.
YAGNI — keep the column, change the experience.

### A.2 Curated vocabulary

New file `lib/core/constants/freelancer_tags.dart`:

```dart
/// Curated freelancer tag vocabulary. Stored in the `specialties text[]`
/// column. Freelancers may also add custom tags not in this list.
class FreelancerTags {
  FreelancerTags._();

  static const List<String> curated = [
    'Haircut',
    'Hair Coloring',
    'Balayage',
    'Braids',
    'Locs',
    'Wig Install',
    'Manicure',
    'Pedicure',
    'Nail Art',
    'Acrylics',
    'Makeup',
    'Bridal Makeup',
    'Lashes',
    'Brows',
    'Facial',
    'Waxing',
    'Massage',
    'Barbering',
  ];

  /// Normalize a tag for storage / comparison: trim + collapse internal
  /// whitespace. Display casing is preserved (we store what the user picked
  /// for curated tags, and a trimmed version of custom input).
  static String normalize(String raw) =>
      raw.trim().replaceAll(RegExp(r'\s+'), ' ');
}
```

Validation (checklist 2.1): custom tag input is trimmed + whitespace-collapsed,
rejected if empty after normalize, capped at **40 characters**, and de-duplicated
(case-insensitive) against already-selected tags. A freelancer may select at
most **15** tags total (resource cap, checklist 2.5).

### A.3 Input UX — `FreelancerTagsSelector`

New widget `lib/presentation/features/freelancer/creation/presentation/widgets/freelancer_tags_selector.dart`.

Replaces the current "Specialties" `CardInkWell` block in
`freelancer_basics_screen.dart` (the text-field + add-button + `Chip` wrap at
lines ~191-261). Behavior:

- **Curated chips:** render `FreelancerTags.curated` as `AppFilterChip`
  (multi-select). A chip is `selected` when its label is in the selected set.
- **Custom add:** a text field + add button. On add, normalize, validate (A.2),
  and append to the selected set if valid and not a duplicate.
- **Selected custom tags** that are not in the curated list render as removable
  `Chip`s below (so the freelancer can delete them), matching the existing
  delete-chip style.
- All selected tags (curated + custom) are persisted via the existing
  `freelancerCreationProvider.updateProfile(specialties: <list>)` call — same
  field, same persistence path as today.

Props:
```dart
FreelancerTagsSelector({
  required List<String> selectedTags,
  required ValueChanged<List<String>> onTagsChanged,
});
```

The screen owns the `List<String>` (seeded from `draft.specialties`), passes it
in, and writes back to the draft on every change — identical to how the current
specialties list is managed.

### A.4 Discover filtering (multi-select grouping)

**Selected-tags provider** —
`lib/presentation/features/freelancer/creation/presentation/providers/selected_freelancer_tags_provider.dart`:

```dart
/// Tags selected on the discover screen to filter freelancers.
/// Empty set = "All" (no tag filter). Multi-select: a freelancer matches
/// if ANY selected tag overlaps their tags (specialties && p_tags).
final selectedFreelancerTagsProvider =
    StateProvider<Set<String>>((ref) => <String>{});
```

**Available-tags provider + RPC.** A chip row should reflect tags that actually
exist among discoverable freelancers (same spirit as `luxuryLevelListProvider`).
New RPC `freelancer_tags_with_counts`:

```sql
-- Returns distinct tags (from workers.specialties) among verified, active
-- freelancers within radius, with a count, ordered by count desc.
-- Column references mirror get_nearby_freelancers overload B exactly:
--   specialties + the verification gate live on `workers` (w);
--   location lives on `freelancer_details` (fd.base_latitude/base_longitude).
create or replace function public.freelancer_tags_with_counts(
  p_user_lat double precision default null,
  p_user_lng double precision default null,
  p_radius_km double precision default null,
  p_limit int default 40
)
returns table(tag text, count bigint)
language sql stable
as $$
  select t.tag, count(*)::bigint as count
  from public.workers w
  inner join public.freelancer_details fd on w.id = fd.worker_id
  cross join lateral unnest(w.specialties) as t(tag)
  where w.is_freelancer = true
    and w.is_active = true
    and w.verification_status = 'approved'
    and (
      p_user_lat is null or p_user_lng is null or p_radius_km is null
      or (
        fd.base_latitude is not null and fd.base_longitude is not null
        and ST_DWithin(
          ST_SetSRID(ST_MakePoint(fd.base_longitude, fd.base_latitude), 4326)::geography,
          ST_SetSRID(ST_MakePoint(p_user_lng, p_user_lat), 4326)::geography,
          p_radius_km * 1000)
      )
    )
  group by t.tag
  order by count desc, t.tag asc
  limit least(greatest(coalesce(p_limit, 40), 1), 100);
$$;
```

> Implementation note: the gate predicates and column references above are
> copied from the existing `get_nearby_freelancers` overload B in
> `20260620150000_nearby_rpcs_add_seed.sql` (specialties + gate on `workers w`,
> location on `freelancer_details fd`). The planner re-verifies these against
> that file before writing the RPC so the chip row and the grid agree on which
> freelancers count.

Dart: `freelancerTagsProvider` (FutureProvider, watches location + radius)
calling a new `getFreelancerTags(...)` repo method that maps rows to
`List<TagCount>` (`{String tag; int count}`).

**Tag chip row** — `FreelancerTagChips` widget, placed on the discover screen
in the `ProviderType.freelancers` branch, in the same slot LuxuryLevelChips
occupies for shops (a `SliverToBoxAdapter` above the rails). Differences from
LuxuryLevelChips: **multi-select**. "All" chip is selected when the set is
empty; tapping "All" clears the set. Tapping a tag toggles its membership.

**RPC tag filter — call-site reality.** The Dart repo's discovery calls
(verified in `supabase_freelancer_repository.dart`) route to:
- `getNearbyFreelancers` → RPC `get_nearby_freelancers` **overload B**
  (`p_freelancer_types text[]` + `p_page_limit`/`p_page_offset` + `p_seed`).
- `getAllFreelancers` → RPC `get_nearby_freelancers` (when location present) OR
  `get_top_rated_freelancers` (no-location fallback).

We add the tag filter to **`get_nearby_freelancers` overload B only**. This
covers the three location-based discovery providers (`freelancerDiscoveryProvider`,
`topRatedFreelancersProvider`, `nearYouFreelancersProvider`) and the
location branch of `getAllFreelancers` — i.e. every path that runs when the
user has a location, which is the normal discover state.

**`get_top_rated_freelancers` (no-location fallback) is NOT modified** in this
work: it is not defined in any tracked migration file, so its exact signature is
unknown and changing it blind risks PGRST203 and breakage. The no-location grid
therefore ignores tag filtering (acceptable: tags are a within-radius grouping
feature, and the chip row is sourced from `freelancer_tags_with_counts` which is
location-aware). The planner flags this to the human if the no-location path
turns out to need tag support; if so, that becomes a follow-up once the function
source is located.

Filter predicate added to overload B's `WHERE` (specialties is on `workers w`):
```sql
and (p_tags is null or array_length(p_tags, 1) is null
     or w.specialties && p_tags)
```

> **PGRST203 hazard:** `CREATE OR REPLACE` with a new param creates a *new*
> overload, leaving the old signature in place → ambiguous-overload error (we
> hit this with `get_nearby_shops`). The migration MUST `DROP FUNCTION` the
> exact prior signature of overload B before recreating it with `p_tags`
> appended. Overload A (`p_freelancer_type text`) is left untouched (Dart never
> calls it). The migration lists the exact
> `DROP FUNCTION public.get_nearby_freelancers(double precision, double precision, double precision, text[], numeric, text, integer, integer, int)`
> (the overload-B arg list from `20260620150000_nearby_rpcs_add_seed.sql`),
> then recreates with `p_tags text[] default null` appended last.

**Wiring the discovery providers.** `freelancerDiscoveryProvider`,
`topRatedFreelancersProvider`, and `nearYouFreelancersProvider` each
`ref.watch(selectedFreelancerTagsProvider)` and pass
`tags: selected.isEmpty ? null : selected.toList()` into the repo. The
`getNearbyFreelancers` repo method gets a new `List<String>? tags` param that
sends `p_tags`. (`getAllFreelancers` gains the param too and forwards it on its
`get_nearby_freelancers` branch; it omits `p_tags` on the
`get_top_rated_freelancers` branch.) Empty/null = no filter (All).

### A.5 Edge cases & resilience

- Empty selected set → `p_tags = null` → no filtering (All), existing behavior.
- A selected tag with zero matches → grid shows empty state (existing
  `freelancerDiscoveryProvider` empty handling); chip stays selectable since the
  user chose it. (Available-tags RPC only surfaces tags with count > 0, so this
  is rare — only if data changes mid-session.)
- `freelancer_tags_with_counts` failure → `FreelancerTagChips` renders
  `SizedBox.shrink()` (same as LuxuryLevelChips `error` branch) so discover
  still works without the chip row.
- Row caps: available-tags RPC caps at 100; freelancer tag selection caps at 15.

---

## Feature B: Product Discovery Rails

### B.1 Data — reuse `discover_products`, no new RPC

`discover_products` already returns `average_rating`, `total_orders_count`,
`distance_km`, and supports `p_sort_by` (`popular` = `total_orders_count desc`)
and location params (`p_user_lat/p_user_lng/p_radius_km`). Both rails reuse the
existing `getMarketplaceProducts(...)` repo method — no SQL change.

- **Top-Rated rail:** `sortBy: SortOption.popular, limit: 10` (most orders, per
  user decision). No location filter (top sellers everywhere, mirroring
  `topRatedFreelancersProvider` which uses a wide radius + rating sort).
- **Near-You rail:** `sortBy: SortOption.discover` + `userLat/userLng/radiusKm`
  from location, `limit: 10` (mirrors `nearYouFreelancersProvider`).

### B.2 Providers (new, in `marketplace_providers.dart`)

```dart
/// Top-rated (most-ordered) products for the discover Buy-tab rail.
final topRatedProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final seed = ref.watch(discoverySeedProvider);
  final selectedCategory = ref.watch(selectedServiceCategoryProvider);
  return repo.getMarketplaceProducts(
    sortBy: SortOption.popular,
    limit: 10,
    page: 0,
    seed: seed,
    shopTypes: _shopTypesFilter(selectedCategory),
  );
});

/// Near-you products for the discover Buy-tab rail. Watches the radius slider.
final nearYouProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final seed = ref.watch(discoverySeedProvider);
  final userLocation = ref.watch(userLocationNotifierProvider);
  final radiusKm = ref.watch(searchRadiusKmProvider);
  final selectedCategory = ref.watch(selectedServiceCategoryProvider);
  if (userLocation == null) return const [];
  return repo.getMarketplaceProducts(
    sortBy: SortOption.discover,
    limit: 10,
    page: 0,
    seed: seed,
    userLat: userLocation.latitude,
    userLng: userLocation.longitude,
    radiusKm: radiusKm,
    shopTypes: _shopTypesFilter(selectedCategory),
  );
});
```

`_shopTypesFilter` and the watched providers are reused from the existing file
so the rails respect the same category/location/seed behavior as the grid.

### B.3 Widgets (new)

`TopRatedProductsHorizontal` and `NearYouProductsHorizontal` —
`lib/presentation/features/products/presentation/widgets/`. Each mirrors the
freelancer horizontal shell:
- Section header (title + optional "See all").
- Horizontal `ListView.separated` of compact product cards.
- `.when(data/loading/error)`; **empty list → `SizedBox.shrink()`** (rail hides
  itself, matching freelancer rails) so a sparse marketplace shows no empty rail.
- Each card taps to `context.pushNamed('productDetail', extra: product.id)`.
- Card reuses the existing `ProductGridItem` styling adapted to a fixed-width
  horizontal item (or a thin `ProductHorizontalCard` wrapper if `ProductGridItem`
  can't be width-constrained cleanly — planner decides after reading
  `ProductGridItem`).

### B.4 Discover screen wiring

In `discover_screen.dart`, the `ProviderType.buy` path currently renders only
`MarketplaceScreen`. Add the two rails as `SliverToBoxAdapter`s above the
"All Products" title/grid, matching the freelancer branch structure:

```dart
} else if (selectedType == ProviderType.buy) ...[
  const SliverToBoxAdapter(child: TopRatedProductsHorizontal()),
  const SliverToBoxAdapter(child: NearYouProductsHorizontal()),
  SliverGap(Spacing.md.h),
],
```

The existing "All Products" title + `SliverFillRemaining(child: MarketplaceScreen())`
grid stays below. (Confirm `ProviderType.buy` is the correct enum value for the
Buy tab while wiring; the planner reads the enum first.)

### B.5 Edge cases & resilience

- No location → Near-You rail returns `[]` → hides itself; Top-Rated still shows.
- Provider error → rail renders error/empty per the freelancer rail pattern;
  the grid below is unaffected.
- Row caps: `discover_products` already clamps `p_limit` to ≤ 50; rails request 10.

---

## Testing

Flutter widget/unit tests where seams exist; both features are
UI-+-provider-heavy with SQL underneath, so coverage is:

- **A — tag normalize/validate:** unit-test `FreelancerTags.normalize` and the
  selector's add-tag validation (empty, >40 chars, dup case-insensitive, 15 cap).
- **A — provider wiring:** test that a non-empty `selectedFreelancerTagsProvider`
  causes the discovery provider to pass `tags` to a fake repo (override the repo
  provider with a fake capturing the args).
- **B — provider args:** test `topRatedProductsProvider` passes
  `sortBy: popular, limit: 10` and `nearYouProductsProvider` passes location +
  radius, via a fake `ProductRepository` capturing args.
- **SQL:** no automated DB test harness in repo; migrations are reviewed for the
  DROP-before-CREATE overload safety and the `&&` predicate. Manual `supabase db
  push` + device smoke test (documented as a deferred ops step).
- `flutter analyze` clean on every touched file.

## Migrations (ops — run after merge)

1. `freelancer_tags_with_counts` RPC (new).
2. `get_nearby_freelancers` overload B: DROP exact prior signature, recreate
   with trailing `p_tags text[] default null` + `w.specialties && p_tags` filter.
   (`get_top_rated_freelancers` is intentionally untouched — see A.4.)

Both in one migration file dated `2026-06-21`. No `discover_products` change for
Feature B. No storage migration for Feature A.

## Checklist (v3.1) compliance notes

- **2.1 Input sanitization:** custom tag normalize + length/empty/dup/count caps.
- **2.2 Parameterized queries:** all filtering via RPC params (`p_tags`), never
  string-built SQL.
- **2.5 Resource limits:** tag selection cap (15), available-tags RPC cap (100),
  product rails limit (10), `discover_products` existing ≤50 clamp.
- **Perf (no N+1):** rails are single RPC calls each; tag chip counts are one
  aggregate RPC, not per-tag queries.
- **2.19 Money:** untouched; product prices continue to flow through the existing
  exact-decimal path. No float math introduced.
- **Regression safety:** `specialties` column and all existing RPC read shapes
  unchanged; overload A untouched; product grid path unchanged.
```
