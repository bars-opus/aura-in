# Product Currency, Location, Shop-Types & Buy-Tab Discovery — Design

**Date:** 2026-06-20
**Status:** Approved (ready for implementation plan)
**Compliance target:** Algorithm Quality Review Checklist v3.1
**Scope tags:** `[MUTATION]` (product/shop/location writes), `[SERVICE]` (discovery
RPCs), `[UI]`/`[MOBILE]` (form + discover screens). `[FIN]` partially — see the
2.19 carve-out below.

## Goal

Make products carry and surface their shop's **currency** and **location**, let
sellers tag a product with **multiple shop types**, give client-sellers a
**location step** in onboarding, and make the Discover **Buy** tab show products
**by the user's location** filtered by **selected shop types** — mirroring how
shops/freelancers already work.

## Key decisions (settled)

- **Product shop-types:** new `products.shop_types text[]` (per-product
  multi-select). Independent of the shop's single `shop_type`.
- **Currency:** derived from the owning shop (`shops.currency` /
  `currency_symbol`), not duplicated on the product. Avoids drift.
- **Location:** derived from the shop's `shop_locations` row (the same table
  shop proximity uses). Not duplicated on the product.
- **Seller onboarding** gains an `EditLocationScreen`-style step: address →
  auto-detected currency (with manual override) → writes `shop_locations` +
  shop currency, exactly like a real shop.
- **Buy-tab discovery:** a `discover_products` proximity RPC joining
  `products → shops → shop_locations`, filtered by `ST_DWithin` (user location)
  AND `shop_types && selected_types` overlap (driven by the existing
  ServiceCategoryTabs selection; empty = all). Keeps the verification gate and
  seeded shuffle from the discovery feature.
- **Shop-type vocabulary:** the canonical list (`Salon`, `Barbershop`, `Spa`,
  `Nail Salon`) is extracted to one shared constant `ShopTypes.all`, read by
  EditBasicsScreen, ProductFormScreen, and the Buy-tab filter. Values are stored
  verbatim (display strings) so they overlap with `shops.shop_type` and the
  discover tabs.

## Checklist v3.1 carve-out — 2.19 (money as float)

**2.19 (P0-U)** requires money as integer minor units. The marketplace
currently stores/computes `price` as `double` end-to-end (ProductModel, cart,
checkout, orders). **This feature is display-only for currency** — it does NOT
change price storage. 2.19 is therefore a **pre-existing violation**, explicitly
**skipped for this feature** with this justification, and tracked as separate
`[FIN]` debt: a future "marketplace money → minor units" refactor spanning
products.price + cart + checkout + orders. No new float math is introduced here.

---

## Section 1 — Data model

**`products` — one new column:**
- `shop_types text[] NOT NULL DEFAULT '{}'` — canonical display-string values;
  GIN-indexed for the `&&` overlap filter (3.3).

**Currency + location are derived from the owning shop (no new product columns):**
- Currency ← `shops.currency` / `shops.currency_symbol`.
- Location ← `shop_locations` (lat/lng, `is_primary`).

**`ProductModel`** gains:
- `shopTypes` (`List<String>`) — from the row.
- `shopCurrencySymbol` (`String?`), `shopCurrencyCode` (`String?`) — from the
  nested `shops` join.
- `distanceKm` (`double?`) — populated by the nearby-product RPC (null in
  non-proximity lists).

**`ShopTypes` shared constant** (`lib/.../shops/.../shop_types.dart` or a core
constants file): `static const List<String> all = ['Salon','Barbershop','Spa',
'Nail Salon'];`. EditBasicsScreen, ProductFormScreen, and the Buy-tab filter all
read it.

---

## Section 2 — ProductFormScreen (UI) `[UI][MOBILE][MUTATION]`

- **Shop-type chips:** `AppFilterChip` multi-select from `ShopTypes.all`, bound
  to local `List<String> _selectedShopTypes`. At least one required (2.1 input
  validation). Persisted to `products.shop_types` on save.
- **Currency-aware price:** on init, the form loads the owning shop's
  `currency_symbol`/`currency` (lightweight select keyed by `widget.shopId`) and
  shows the symbol on the price field; fallback to `Currency.symbol`.
- **Validation/UX (5.1, 5.5):** actionable inline errors ("Select at least one
  category"); no internal info leaked.

---

## Section 3 — Seller onboarding location step `[UI][MUTATION]`

`SellerOnboardingScreen` gains an `EditLocationScreen`-style step reusing its
address picker + `CurrencySelector` + `country_currency_mapper`:
- Captures address/city/country/lat/lng; auto-detects currency from country;
  manual override allowed.
- On submit, the minimal shop is created with `currency`/`currency_symbol` and a
  `shop_locations` row (`is_primary = true`) — identical to a real shop.
- Idempotency (1.1/2.18): the existing-shop check already prevents duplicate
  seller-shops; re-submitting onboarding updates rather than duplicates.

---

## Section 4 — Buy-tab discovery `[SERVICE]`

**`discover_products` RPC** (extends the discovery-feature RPC):
- Joins `products p → shops s → profiles pr → shop_locations sl`.
- Gates: `p.is_active`, `pr.account_status='active'`,
  `s.verification_status='approved'` (preserve the verification gate).
- **Location:** when user lat/lng provided, `ST_DWithin(sl, user, radius)` and
  return `distance_km`; default ordering uses the distance-band + seeded shuffle
  blend (consistent with the discovery feature).
- **Shop-type overlap:** when `p_shop_types text[]` is non-empty,
  `p.shop_types && p_shop_types`; empty/null = no type filter.
- Returns the product jsonb shape (incl. nested `shops` with currency) +
  `distance_km`. `p_limit` clamp 1..50, `p_offset>=0`, `p_seed default 0`.
- Indexes (3.3): GIN on `products.shop_types`; existing `shop_locations` spatial
  index; `EXPLAIN` verified.

**Flutter wiring:** the Buy tab passes `userLocation` (proximity) +
ServiceCategoryTabs selection (`shop_types`) + the discovery seed into the
product query. Mirrors the existing shop-tab wiring.

---

## Algorithm Quality Review Checklist v3.1 — application

- **2.1 input sanitization (P0-U):** shop-types validated against `ShopTypes.all`
  server-side in the RPC path is unnecessary (array overlap is safe), but the
  form requires ≥1 selection; price/lat/lng validated.
- **2.2 parameterized queries (P0-U):** all via PostgREST/RPC params; no string
  interpolation. The `&&` filter binds `p_shop_types` as a typed `text[]`.
- **2.4 / 5.5 no leakage (P0-U):** RPC + form errors are generic/actionable.
- **1.4/1.5 authz/authn (P0-U):** product create/update already authz'd to the
  owning shop; location write goes through the owner-scoped onboarding/edit path.
- **3.1 pagination, 3.2 no N+1, 3.3 indexes (P2):** offset pagination with
  clamped page size; single joined RPC (no N+1); GIN + spatial indexes.
- **3.9/3.10 retry:** discovery reads are safe to retry; no retry on 4xx.
- **5.2 latency (P2):** chips/price are local (≤200ms); discovery shows a loading
  state immediately.
- **6.1/6.4 tests:** shop-type overlap (empty, one, many, no-match), currency
  fallback, location-missing, verification-gate-still-applies, seeded pagination
  stability.
- **2.19 (P0-U):** skipped-with-justification (see carve-out) — pre-existing
  float price, display-only change, tracked as separate `[FIN]` debt.

---

## Out of scope (YAGNI)

- Marketplace money → integer minor units (separate `[FIN]` refactor).
- Per-product location distinct from its shop.
- Promoting `shops.shop_type` to an array (shops stay single-type).
- A separate product-category vocabulary (reuses `ShopTypes.all`).
