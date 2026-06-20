# Randomized Discovery Ordering — Design

**Date:** 2026-06-20
**Status:** Approved (ready for implementation plan)

## Goal

Make discovery lists (shops, freelancers, products — everything on the
DiscoverScreen and their "see all" screens) appear in a randomized order by
default, so users don't see the same list in the same order every visit —
while keeping pagination correct and honoring explicit user-chosen sorts.

## Key decisions

- **Randomize the default view only.** When the user picks an explicit sort
  (`rating` / `price` / `distance` / `name`), honor it exactly. The shuffle
  applies only to the default/no-explicit-sort case.
- **Per-session seed.** A client-generated random int per discovery session
  (regenerated on pull-to-refresh) drives a deterministic shuffle, so pages
  1,2,3 stay consistent (no duplicates/gaps) within a session, but a new
  session/refresh reshuffles.
- **Convert discovery reads to RPCs.** PostgREST `.order()` cannot order by a
  seeded random expression; SQL functions can. Each discovery list becomes an
  RPC taking `p_seed` and ordering by a deterministic hash.
- **Surfaces:** shops (browse + nearby), freelancers (nearby), products
  (marketplace), premium + top-rated rails, and all DiscoverScreen lists incl.
  their "see all" / paginated variants.
- **Builds on verification gating:** every discovery RPC keeps the
  `verification_status = 'approved'` predicate from the verification feature.

---

## Section 1 — Seed model & ordering primitive

### Per-session seed

`discoverySeedProvider` — a Riverpod `StateProvider<int>` holding a random int,
generated when a discovery session begins and regenerated on pull-to-refresh
(`ref.read(discoverySeedProvider.notifier).state = _newSeed()`). It always has
a value (initialized at construction). Every discovery query/RPC receives it.

### Deterministic seeded ordering (SQL)

Default-mode ordering uses a hash mixing row id with the seed:

```sql
ORDER BY md5(id::text || p_seed::text)
```

Deterministic for a given `(row, seed)`; `id` is unique so there are no ties →
no duplicate/skipped rows across offset pages. A new seed yields a fresh,
uniform permutation.

Explicit-sort mode ignores the seed for primary ordering (uses
rating/price/name/distance as today); the seed MAY be used only as a final
tie-breaker so equal-ranked items still vary.

### Nearby distance blend

The nearby RPCs default to distance ordering. To "randomize the default view"
without destroying geographic relevance, default mode orders by a coarse
distance band first, then by `md5(id::text || p_seed::text)` within the band —
so nearby results stay sensible but vary per visit. Concrete blend
(confirmable in the plan): bucket distance to a band width (e.g.
`floor(distance_km / 2.0)`) then hash within. If pure random is preferred for
nearby, that is a one-line change (drop the band term).

---

## Section 2 — RPCs and seed plumbing

### SQL functions (all take `p_seed int DEFAULT 0`; all keep the verification gate)

- `get_nearby_shops` / `get_nearby_freelancers` — already RPCs; add `p_seed`
  param + distance-band blend (re-`CREATE OR REPLACE`, building on the
  verification-gate migration `20260620130000`).
- `discover_shops(p_seed, filters…, p_limit, p_offset)` — replaces the
  `getShops` PostgREST query (browse + see-all shops grid). Filters mirror the
  current ones: searchQuery (ilike on shop_name), shop_type, luxury_level,
  verifiedOnly, minRating.
- `discover_premium_shops(p_seed, …, p_limit, p_offset)` and
  `discover_top_rated_shops(p_seed, …, p_limit, p_offset)` — DiscoverScreen
  rails + their see-all/paginated variants. These are ranked rails: default
  becomes seeded shuffle, but an explicit `rating` sort remains available so
  the "top rated" semantic still works when requested.
- `discover_products(p_seed, filters…, p_limit, p_offset)` — marketplace
  default listing. Filters mirror current product filters (category, search,
  the existing SortOption set).

All RPCs return the SAME column shape the existing DTOs parse
(`ShopListItemDTO`, the freelancer DTO, `ProductModel`), so DTO mapping is
unchanged. All are consistent with the existing `SECURITY DEFINER`-style
discovery functions and include `verification_status = 'approved'` (shops:
`s.verification_status`; workers: `w.verification_status`; products: the
shop-approval join from `products_read_active`).

### Repo layer

Affected methods switch from `.from(...).order(...).range(...)` to
`.rpc('discover_*', params: {... p_seed, p_limit, p_offset})`:

- `supabase_shop_repository`: `getShops`, `getPremiumShops` +
  `getPremiumShopsPaginated`, `getTopRatedShops` +
  `getTopRatedShopsPaginated`, `getNearbyShops` + `getNearbyShopsPaginated`.
- `supabase_freelancer_repository`: the nearby freelancer fetch paths (both
  `get_nearby_freelancers` overloads' callers).
- `supabase_product_repository`: the marketplace product listing.

Pagination stays offset-based (`p_offset`/`p_limit`), which is now correct
because ordering is seed-deterministic.

### Seed plumbing

Query param objects (`ShopQueryParams`, the product/freelancer equivalents)
gain a `seed` (`int`) field. Discovery notifiers read `discoverySeedProvider`
and pass it through. Pull-to-refresh sets a new seed before reloading.

---

## Section 3 — Correctness, untouched lists, errors, testing

### Pagination correctness

Offset pagination is stable iff the total ordering is deterministic for a
fixed seed. `md5(id::text || seed::text)` is deterministic per `(row, seed)`
and `id` is unique → no ties → no duplicate/skipped rows. The seed is held
constant for the whole paginated run; it changes only on explicit refresh.

### Explicitly NOT touched (randomizing would break the UI)

- Shop sub-lists: media (`is_cover`/`sort_order`), opening hours
  (`day_of_week`), reviews (`created_at`), worker assignments, appointment
  slots, type/luxury counts.
- Freelancer sub-lists: tools, availability, day-of-week ordering.
- `getShopsByProfileId` (owner's own shops), shop/freelancer detail reads.

Only the discovery/browse list ENTRY POINTS become seeded.

### Error handling & fallback

- A discovery RPC error surfaces the existing user-facing error via
  `runRepoQuery` — no silent empty list.
- `p_seed int DEFAULT 0` → a null seed yields a stable order rather than
  failing. The seed provider always holds a value.

### Testing

- **SQL:** same `(seed, offset)` → identical rows; different seed → different
  order; no row on two consecutive pages for one seed; verification gate still
  excludes non-approved; explicit sort → deterministic non-random order.
- **Dart:** `discoverySeedProvider` regenerates on refresh; param objects
  carry the seed; RPC params include `p_seed`/`p_limit`/`p_offset`.
- **Manual:** open Discover → note order; pull-to-refresh → order changes;
  page 2 → no repeats from page 1; pick explicit sort → deterministic order.

---

## Algorithm Quality Review Checklist (applied)

- **Input validation:** `p_limit` clamped (1..50) and `p_offset >= 0` in each
  RPC; seed defaulted; filters validated as today.
- **Idempotency:** seeded determinism makes pagination idempotent for a fixed
  seed (the core correctness property).
- **Error/edge handling:** RPC errors surface via runRepoQuery; null/absent
  seed falls back to a stable order; empty result is a valid empty list.
- **Security boundaries:** every discovery RPC retains
  `verification_status='approved'`; no widening of what's visible.
- **No regressions:** sub-lists and owner/detail reads untouched; DTO shapes
  preserved; explicit sorts still work.

## Out of scope (YAGNI)

- Personalized/ML ranking — this is uniform shuffle, not recommendation.
- Server-side seed persistence — seed is client-held per session.
- Changing pagination from offset to keyset.
