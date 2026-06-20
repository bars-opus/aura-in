# Randomized Discovery Ordering Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make discovery lists (shops, freelancers, products, and all DiscoverScreen rails + their "see all" screens) appear in a per-session-randomized default order, with correct pagination and explicit sorts still honored.

**Architecture:** A client-generated per-session seed (Riverpod) is threaded into discovery queries. Discovery reads become SQL RPCs that order by `md5(id::text || p_seed::text)` in default mode (and a coarse distance-band blend for nearby), so a fixed seed yields a stable permutation across offset pages while a new seed reshuffles. Every discovery RPC keeps the `verification_status='approved'` gate.

**Tech Stack:** Flutter, Riverpod, Supabase (Postgres functions/RPCs, PostGIS).

## Global Constraints

- Per-session seed: client-generated `int`, regenerated on pull-to-refresh; passed to every discovery query/RPC.
- Default-mode ordering: `ORDER BY md5(id::text || p_seed::text)`. Explicit sorts (rating/price/name/distance) take precedence; seed may only be a tie-breaker.
- Nearby default: coarse distance band then hash within band — `ORDER BY floor(distance_km / 2.0), md5(id::text || p_seed::text)`.
- Every discovery RPC includes the verification gate (shops: `s.verification_status='approved'`; workers: `w.verification_status='approved'`; products: shop-approval join).
- `p_seed int DEFAULT 0`; `p_limit` clamped 1..50; `p_offset >= 0`.
- RPCs MUST return the exact column shape the existing DTOs parse (`ShopListItemDTO`, freelancer DTO, `ProductModel.fromJson`) — do not change DTO mapping.
- Do NOT touch sub-lists (media, hours, reviews, slots, tools, counts), `getShopsByProfileId`, or detail reads.
- SQL functions follow the existing discovery-RPC style; build on migration `20260620130000` for the nearby ones.
- Edge/RPC SQL files are Postgres migrations under `supabase/migrations/`. Deno not involved.

---

## File Structure

**Backend (Supabase migrations):**
- `supabase/migrations/20260620140000_discover_rpcs.sql` — new `discover_shops`, `discover_premium_shops`, `discover_top_rated_shops`, `discover_products` functions.
- `supabase/migrations/20260620150000_nearby_rpcs_add_seed.sql` — re-`CREATE OR REPLACE` `get_nearby_shops` + both `get_nearby_freelancers` overloads adding `p_seed` + distance-band blend.

**Flutter:**
- `lib/presentation/features/discover/providers/discovery_seed_provider.dart` — seed provider + helper (Create).
- `lib/presentation/features/search/models/shop_query_params.dart` — add `seed` field (Modify).
- `lib/presentation/features/shops/query/data/repositories/supabase_shop_repository.dart` — switch discovery reads to RPCs w/ seed (Modify).
- `lib/presentation/features/freelancer/data/repositories/supabase_freelancer_repository.dart` — pass seed to nearby RPC (Modify).
- `lib/presentation/features/products/data/repositories/supabase_product_repository.dart` — marketplace listing → RPC w/ seed (Modify).
- The discovery notifiers/providers that build params — thread the seed + reshuffle on refresh (Modify; located in Task 3).

---

## Task 1: Seed provider

**Files:**
- Create: `lib/presentation/features/discover/providers/discovery_seed_provider.dart`

**Interfaces:**
- Produces:
  - `discoverySeedProvider` → `StateProvider<int>` initialized to a random 31-bit int.
  - `int newDiscoverySeed()` — returns a fresh random 31-bit int.
  - extension/helper `reshuffleDiscovery(WidgetRef ref)` → sets a new seed.

- [ ] **Step 1: Write the provider**

```dart
// lib/presentation/features/discover/providers/discovery_seed_provider.dart
//
// Per-session seed for randomized discovery ordering. Held constant within a
// browse session (so offset pagination stays stable) and regenerated on
// pull-to-refresh via reshuffleDiscovery().
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _rng = Random();

/// A fresh 31-bit positive seed (fits a Postgres int4 / Dart int comfortably).
int newDiscoverySeed() => _rng.nextInt(1 << 31);

final discoverySeedProvider = StateProvider<int>((ref) => newDiscoverySeed());

/// Regenerate the seed so the next discovery load reshuffles.
void reshuffleDiscovery(Ref ref) {
  ref.read(discoverySeedProvider.notifier).state = newDiscoverySeed();
}
```

- [ ] **Step 2: Analyze**

Run: `flutter analyze lib/presentation/features/discover/providers/discovery_seed_provider.dart`
Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/features/discover/providers/discovery_seed_provider.dart
git commit -m "feat(discover): per-session randomization seed provider"
```

---

## Task 2: `discover_shops` + `discover_products` RPCs (migration)

**Files:**
- Create: `supabase/migrations/20260620140000_discover_rpcs.sql`

**Interfaces:**
- Produces (this task adds the first two; Task 5 appends premium/top-rated to the SAME file):
  - `discover_shops(p_seed int, p_search text, p_shop_type text, p_luxury_level text, p_min_rating numeric, p_sort_by text, p_limit int, p_offset int)` → returns columns matching the `shops_with_cover` select in `getShops` (`id, shop_name, average_rating, number_clients_worked, luxury_level, verified, shop_type, cover_image_url`).
  - `discover_products(p_seed int, p_category text, p_min_price numeric, p_max_price numeric, p_sort_by text, p_limit int, p_offset int)` → returns the `products` row shape plus the embedded shop fields that `ProductModel.fromJson` reads.

- [ ] **Step 1: Inspect the exact shapes to reproduce**

Run:
```bash
grep -n "shops_with_cover\|cover_image_url\|ShopListItemDTO(" lib/presentation/features/shops/query/data/repositories/supabase_shop_repository.dart | head
grep -n "shops!inner\|ProductModel.fromJson\|select(" lib/presentation/features/products/data/repositories/supabase_product_repository.dart | head
sed -n '1,80p' lib/presentation/features/products/data/models/product_model.dart
```
Confirm: the shop discovery returns `cover_image_url` (the `shops_with_cover` view already computes it); `ProductModel.fromJson` expects an embedded `shops` object with `id, shop_name, verified, luxury_level, average_rating`. The RPC must return JSON in the same shape the DTO reads. If `ProductModel.fromJson` reads a nested `shops` map, the products RPC should `RETURNS TABLE(... , shop jsonb)` or return the joined columns and the Dart mapping adapts — decide based on what fromJson reads and note it.

- [ ] **Step 2: Write the migration (discover_shops + discover_products)**

```sql
-- supabase/migrations/20260620140000_discover_rpcs.sql
-- Discovery RPCs with per-session seeded ordering. Default mode shuffles by
-- md5(id || seed) so a fixed seed gives a stable permutation across offset
-- pages; explicit sorts take precedence. All keep the verification gate.

-- ── discover_shops ──────────────────────────────────────────────────────────
create or replace function public.discover_shops(
  p_seed int default 0,
  p_search text default null,
  p_shop_type text default null,
  p_luxury_level text default null,
  p_min_rating numeric default null,
  p_sort_by text default null,
  p_limit int default 20,
  p_offset int default 0
)
returns table(
  id uuid, shop_name text, average_rating numeric,
  number_clients_worked integer, luxury_level text, verified boolean,
  shop_type text, cover_image_url text
)
language plpgsql
as $function$
declare
  v_limit int := least(greatest(coalesce(p_limit, 20), 1), 50);
  v_offset int := greatest(coalesce(p_offset, 0), 0);
begin
  return query
  select s.id, s.shop_name, s.average_rating, s.number_clients_worked,
         s.luxury_level, s.verified, s.shop_type, s.cover_image_url
  from public.shops_with_cover s
  where s.verification_status = 'approved'
    and (p_search is null or p_search = '' or s.shop_name ilike '%' || p_search || '%')
    and (p_shop_type is null or p_shop_type = '' or s.shop_type = p_shop_type)
    and (p_luxury_level is null or p_luxury_level = '' or s.luxury_level = p_luxury_level)
    and (p_min_rating is null or s.average_rating >= p_min_rating)
  order by
    case when p_sort_by = 'rating' then s.average_rating end desc nulls last,
    case when p_sort_by = 'name'   then s.shop_name end asc nulls last,
    -- default (and final tie-break): seeded shuffle
    md5(s.id::text || p_seed::text)
  limit v_limit offset v_offset;
end;
$function$;

-- ── discover_products ───────────────────────────────────────────────────────
-- Returns product columns + the embedded shop fields ProductModel.fromJson
-- reads. Gate: product active AND its shop approved (mirrors products_read_active).
create or replace function public.discover_products(
  p_seed int default 0,
  p_category text default null,
  p_min_price numeric default null,
  p_max_price numeric default null,
  p_sort_by text default null,
  p_limit int default 20,
  p_offset int default 0
)
returns table(product jsonb)
language plpgsql
as $function$
declare
  v_limit int := least(greatest(coalesce(p_limit, 20), 1), 50);
  v_offset int := greatest(coalesce(p_offset, 0), 0);
begin
  return query
  select to_jsonb(p) || jsonb_build_object(
           'shops', jsonb_build_object(
             'id', s.id, 'shop_name', s.shop_name, 'verified', s.verified,
             'luxury_level', s.luxury_level, 'average_rating', s.average_rating
           )
         ) as product
  from public.products p
  join public.shops s on s.id = p.shop_id
  join public.profiles pr on pr.id = s.user_id
  where p.is_active = true
    and pr.account_status = 'active'
    and s.verification_status = 'approved'
    and (p_category is null or p_category = '' or p.category = p_category)
    and (p_min_price is null or p.price >= p_min_price)
    and (p_max_price is null or p.price <= p_max_price)
  order by
    case when p_sort_by = 'price_low'  then p.price end asc nulls last,
    case when p_sort_by = 'price_high' then p.price end desc nulls last,
    case when p_sort_by = 'popular'    then p.total_orders_count end desc nulls last,
    case when p_sort_by = 'recent'     then p.created_at end desc nulls last,
    md5(p.id::text || p_seed::text)
  limit v_limit offset v_offset;
end;
$function$;
```

- [ ] **Step 3: Adjust to real shapes if Step 1 revealed differences**

If `shops_with_cover` does not expose `verification_status` (it's a view), either add it to the view or join `shops` for the gate. Run:
`grep -rn "shops_with_cover" supabase/migrations/*.sql` to find the view definition; if absent (live-DB view), have discover_shops select from `shops s` joined to the cover subquery instead (replicate the cover_image_url subquery used in get_nearby_shops). Note the choice. Similarly, confirm `total_orders_count` and `category` column names on `products` match the DTO/source; adapt if different.

- [ ] **Step 4: Validate SQL well-formedness**

If a local DB/Docker is available: `supabase db reset` and confirm it applies. Otherwise inspect for balanced `$function$`, valid `order by`, and idempotent `create or replace`; note runtime test deferred.

- [ ] **Step 5: Commit**

```bash
git add supabase/migrations/20260620140000_discover_rpcs.sql
git commit -m "feat(db): discover_shops + discover_products seeded RPCs"
```

---

## Task 3: Seed plumbing — params + notifiers + refresh

**Files:**
- Modify: `lib/presentation/features/search/models/shop_query_params.dart`
- Modify: the discovery notifiers that build params and handle refresh (located in Step 1).

**Interfaces:**
- Consumes: `discoverySeedProvider`, `newDiscoverySeed`, `reshuffleDiscovery`.
- Produces: `ShopQueryParams.seed` (`int?`), threaded into params; refresh regenerates the seed.

- [ ] **Step 1: Locate the discovery notifiers**

Run:
```bash
grep -rn "shopListProvider\|loadNextPage\|ShopQueryParams(\|onRefresh\|RefreshIndicator\|invalidate" lib/presentation/features/shops/query/providers lib/presentation/features/discover | head -30
```
Identify (a) where `ShopQueryParams` is constructed for discovery, and (b) the pull-to-refresh handler(s) on DiscoverScreen and the see-all screens. Record the file:line of each.

- [ ] **Step 2: Add `seed` to ShopQueryParams**

In `shop_query_params.dart` add the field, constructor param, copyWith param+assignment, and props entry:
```dart
  final int? seed;
```
(constructor) `this.seed,` — (copyWith) `int? seed,` and `seed: seed ?? this.seed,` — (props) add `seed`.

- [ ] **Step 3: Thread the seed when building params**

Where discovery builds `ShopQueryParams(...)`, read the seed and include it:
```dart
final seed = ref.watch(discoverySeedProvider);
// ... ShopQueryParams(..., seed: seed)
```
Add the import for `discovery_seed_provider.dart`. Apply to each discovery params construction site found in Step 1.

- [ ] **Step 4: Reshuffle on refresh**

In each pull-to-refresh handler for discovery surfaces, regenerate the seed before reloading:
```dart
reshuffleDiscovery(ref); // sets a new discoverySeedProvider value
// then the existing refresh/invalidate logic re-fetches with the new seed
```
Apply to DiscoverScreen + see-all refresh handlers found in Step 1. Report each site.

- [ ] **Step 5: Analyze**

Run: `flutter analyze lib/presentation/features/search/models/shop_query_params.dart lib/presentation/features/discover lib/presentation/features/shops/query/providers`
Expected: No errors.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(discover): thread per-session seed through params + refresh"
```

---

## Task 4: Wire `getShops` + products to the seeded RPCs

**Files:**
- Modify: `lib/presentation/features/shops/query/data/repositories/supabase_shop_repository.dart` (`getShops`)
- Modify: `lib/presentation/features/products/data/repositories/supabase_product_repository.dart` (`getMarketplaceProducts`)

**Interfaces:**
- Consumes: `discover_shops`, `discover_products` RPCs; `ShopQueryParams.seed`.

- [ ] **Step 1: Switch `getShops` to the RPC**

Replace the `_client.from('shops_with_cover').select(...)....range(...)` body of `getShops` with an `.rpc('discover_shops', params: {...})` call. Map `params.sortBy` to the RPC's `p_sort_by` (pass null for default), thread `p_seed: params.seed ?? 0`, `p_offset: offset`, `p_limit: limit`, and the existing filters (`p_search`, `p_shop_type`, `p_luxury_level`, `p_min_rating`). Parse the returned rows into `ShopListItemDTO` exactly as before (same column names). Keep the existing `_dedupe`, `nextCursor` (offset+limit) logic. Show the full rewritten method in the implementation.

- [ ] **Step 2: Switch products to the RPC**

Replace the `_supabase.from('products').select('...shops!inner...')` query in `getMarketplaceProducts` with `.rpc('discover_products', params: {...})`, threading `p_seed`, `p_category`, `p_min_price`, `p_max_price`, `p_sort_by` (mapped from `SortOption`: recent→'recent', priceLowHigh→'price_low', priceHighLow→'price_high', popular→'popular'; default→null for seeded shuffle), `p_limit`, `p_offset: page*limit`. The RPC returns rows of `{product: jsonb}` shaped for `ProductModel.fromJson` — extract `row['product']` and pass to `ProductModel.fromJson`. Add a `seed` parameter to `getMarketplaceProducts` (default 0) and have the caller pass the discovery seed.

- [ ] **Step 3: Pass the seed from the product caller**

Find the product marketplace provider/notifier that calls `getMarketplaceProducts` (grep `getMarketplaceProducts`), add `seed: ref.watch(discoverySeedProvider)` (or thread via its params). Report the site.

- [ ] **Step 4: Analyze**

Run: `flutter analyze lib/presentation/features/shops/query/data/repositories/supabase_shop_repository.dart lib/presentation/features/products/data/repositories/supabase_product_repository.dart`
Expected: No errors.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat(discover): getShops + marketplace products use seeded RPCs"
```

---

## Task 5: Premium + top-rated rail RPCs + wiring

**Files:**
- Modify: `supabase/migrations/20260620140000_discover_rpcs.sql` (append two functions)
- Modify: `lib/presentation/features/shops/query/data/repositories/supabase_shop_repository.dart` (premium + top-rated methods, incl. paginated)

**Interfaces:**
- Produces: `discover_premium_shops(p_seed, p_shop_type, p_luxury_level, p_limit, p_offset)` and `discover_top_rated_shops(p_seed, p_shop_type, p_luxury_level, p_min_rating, p_limit, p_offset)` returning the `ShopListItemDTO` column shape.

- [ ] **Step 1: Read the current premium/top-rated methods**

Run:
```bash
sed -n '193,560p' lib/presentation/features/shops/query/data/repositories/supabase_shop_repository.dart
```
Note: these have distance-sorted RPC branches (`get_premium_shops_by_distance`), unsorted fallbacks, and paginated variants. The goal is to make the DEFAULT (non-distance, non-explicit-sort) ordering seeded, WITHOUT breaking the distance branch or the fallback. Decide per method: where it currently orders by `average_rating`/`created_at` as the default browse order, replace that path with the new RPC; leave the distance-RPC branch intact (Task 6 adds seed to the nearby/distance RPCs).

- [ ] **Step 2: Append the two rail functions to the migration**

```sql
-- (appended to 20260620140000_discover_rpcs.sql)

create or replace function public.discover_premium_shops(
  p_seed int default 0,
  p_shop_type text default null,
  p_luxury_level text default null,
  p_limit int default 10,
  p_offset int default 0
)
returns table(
  id uuid, shop_name text, average_rating numeric,
  number_clients_worked integer, luxury_level text, verified boolean,
  shop_type text, cover_image_url text
)
language plpgsql
as $function$
declare
  v_limit int := least(greatest(coalesce(p_limit, 10), 1), 50);
  v_offset int := greatest(coalesce(p_offset, 0), 0);
begin
  return query
  select s.id, s.shop_name, s.average_rating, s.number_clients_worked,
         s.luxury_level, s.verified, s.shop_type, s.cover_image_url
  from public.shops_with_cover s
  where s.verification_status = 'approved'
    and (p_shop_type is null or p_shop_type = '' or s.shop_type = p_shop_type)
    and (p_luxury_level is null or p_luxury_level = '' or s.luxury_level = p_luxury_level)
    and coalesce(s.luxury_level, '') <> ''  -- premium = has a luxury level
  order by md5(s.id::text || p_seed::text)
  limit v_limit offset v_offset;
end;
$function$;

create or replace function public.discover_top_rated_shops(
  p_seed int default 0,
  p_shop_type text default null,
  p_luxury_level text default null,
  p_min_rating numeric default 4.0,
  p_limit int default 10,
  p_offset int default 0
)
returns table(
  id uuid, shop_name text, average_rating numeric,
  number_clients_worked integer, luxury_level text, verified boolean,
  shop_type text, cover_image_url text
)
language plpgsql
as $function$
declare
  v_limit int := least(greatest(coalesce(p_limit, 10), 1), 50);
  v_offset int := greatest(coalesce(p_offset, 0), 0);
begin
  return query
  select s.id, s.shop_name, s.average_rating, s.number_clients_worked,
         s.luxury_level, s.verified, s.shop_type, s.cover_image_url
  from public.shops_with_cover s
  where s.verification_status = 'approved'
    and (p_shop_type is null or p_shop_type = '' or s.shop_type = p_shop_type)
    and (p_luxury_level is null or p_luxury_level = '' or s.luxury_level = p_luxury_level)
    and s.average_rating >= coalesce(p_min_rating, 4.0)
  order by md5(s.id::text || p_seed::text)
  limit v_limit offset v_offset;
end;
$function$;
```

(If Step 1/Task 2-Step 3 showed `shops_with_cover` lacks `verification_status`, apply the same join workaround here.)

- [ ] **Step 3: Wire the rail methods to the new RPCs**

For each default-order rail method (`getPremiumShops`/`getPremiumShopsPaginated`/`getTopRatedShops`/`getTopRatedShopsPaginated`), replace its default-order query path with `.rpc('discover_premium_shops'|'discover_top_rated_shops', params: {p_seed: <seed>, ...})`. Add a `seed` parameter to these methods (default 0) and pass it from their callers (grep the method names to find providers). Preserve: the distance-RPC branch, the cover-image batch-fetch, dedupe, and pagination cursor logic. Show each rewritten method.

- [ ] **Step 4: Analyze**

Run: `flutter analyze lib/presentation/features/shops/query/data/repositories/supabase_shop_repository.dart`
Expected: No errors.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat(discover): premium + top-rated rails use seeded RPCs"
```

---

## Task 6: Nearby RPCs — add seed + distance-band blend

**Files:**
- Create: `supabase/migrations/20260620150000_nearby_rpcs_add_seed.sql`
- Modify: `lib/presentation/features/shops/query/data/repositories/supabase_shop_repository.dart` (nearby callers)
- Modify: `lib/presentation/features/freelancer/data/repositories/supabase_freelancer_repository.dart` (nearby callers)

**Interfaces:**
- Produces: `get_nearby_shops` (+ `p_seed`), both `get_nearby_freelancers` overloads (+ `p_seed`), each default-ordering by `floor(distance_km/2.0), md5(id::text||p_seed::text)`.

- [ ] **Step 1: Base on the gated definitions**

Read `supabase/migrations/20260620130000_gate_nearby_rpcs_on_verification.sql` (the current full bodies of all three functions). The new migration re-`CREATE OR REPLACE`s the same three with: (a) a new trailing `p_seed int DEFAULT 0` parameter, and (b) the default ORDER BY changed to the distance-band blend. Preserve every other line (signatures otherwise identical, verification gate, PostGIS distance math).

- [ ] **Step 2: Write the migration**

For each of the three functions, copy its body from `20260620130000`, add `p_seed int DEFAULT 0` as the LAST parameter, and replace the `ORDER BY` clause:
- `get_nearby_shops`: change the default ordering so when `sort_by` is not 'rating'/'name', it orders by `floor(distance_km / 2.0), md5(id::text || p_seed::text)`. Keep the explicit `rating`/`name` cases.
- both `get_nearby_freelancers` overloads: change the default (`p_sort_by='distance'` / else) branch to `floor(distance_km / 2.0), md5(worker_id::text || p_seed::text)`; keep the explicit `rating`/`revenue` cases.
Write the complete `CREATE OR REPLACE` for all three (full bodies, not diffs).

- [ ] **Step 3: Pass the seed from the nearby callers**

In `supabase_shop_repository.dart` `getNearbyShops`/`getNearbyShopsPaginated`, add `'p_seed': <seed>` to the params map and add a `seed` parameter to the methods. In `supabase_freelancer_repository.dart`, add `'p_seed': <seed>` to each `get_nearby_freelancers` rpc params and a `seed` param to those methods. Thread the seed from their providers (grep the method names). Report the sites.

- [ ] **Step 4: Validate SQL + analyze Dart**

SQL: if Docker/local DB available, apply; else inspect for balanced bodies + correct ORDER BY. Dart: `flutter analyze` the two repositories. Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat(db): nearby RPCs add seed + distance-band shuffle"
```

---

## Task 7: Full analyze + manual verification

**Files:** none (verification only)

- [ ] **Step 1: Full analyze**

Run: `flutter analyze lib/`
Expected: no NEW errors in lib/ (pre-existing test/ errors unrelated).

- [ ] **Step 2: Apply migrations (manual; needs DB access)**

```bash
supabase db push   # applies 20260620140000 + 20260620150000
```

- [ ] **Step 3: Manual smoke test**

1. Open Discover → note the order of shops / freelancers / products / rails.
2. Pull-to-refresh → order changes (seed regenerated).
3. Scroll to page 2 of the shops grid (and a see-all screen) → no items repeat from page 1, none missing (seeded pagination correct).
4. Pick an explicit sort (rating / price / name / distance) → deterministic, non-random order.
5. Confirm unverified producers never appear (gate preserved).

- [ ] **Step 4: Commit any fixes**

```bash
git add -A
git commit -m "fix: address discovery randomization smoke-test findings"
```

---

## Notes on the Algorithm Quality Review Checklist

- **Input validation:** `p_limit` clamped 1..50, `p_offset>=0`, `p_seed` defaulted in every RPC; filters validated as before.
- **Idempotency:** seeded determinism makes offset pagination idempotent for a fixed seed (no dup/skip across pages).
- **Error/edge handling:** RPC errors surface via `runRepoQuery`; null seed → stable order; empty result is a valid empty list; existing distance fallbacks preserved.
- **Security boundaries:** every discovery RPC keeps `verification_status='approved'`; no widening of visibility.
- **No regressions:** sub-lists, owner/detail reads untouched; DTO shapes preserved; explicit sorts still deterministic.
