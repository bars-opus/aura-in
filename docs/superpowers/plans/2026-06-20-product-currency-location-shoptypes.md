# Product Currency, Location, Shop-Types & Buy-Tab Discovery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Products carry/surface their shop's currency and location, sellers tag products with multiple shop types, client-sellers set location during onboarding, and the Discover Buy tab shows products by user location filtered by selected shop types.

**Architecture:** A new `products.shop_types text[]` (GIN-indexed) drives discovery overlap; currency + location are derived from the owning shop (`shops.currency_symbol`, `shop_locations`) — no duplication. The existing `discover_products` RPC is extended with a location join (`ST_DWithin`) + shop-type overlap. ProductFormScreen gains multi-select shop-type chips and a shop-currency price symbol; seller onboarding gains a location step writing `shop_locations` + shop currency.

**Tech Stack:** Flutter, Riverpod, GoRouter, Supabase (Postgres + PostGIS + RPCs).

## Global Constraints

- Compliance target: Algorithm Quality Review Checklist v3.1.
- Canonical shop types: `['Salon', 'Barbershop', 'Spa', 'Nail Salon']`, stored verbatim (display strings) so they overlap with `shops.shop_type` and the discover tabs. One shared constant `ShopTypes.all`.
- Currency derived from `shops.currency` / `shops.currency_symbol`; location from `shop_locations` (lat/lng, `is_primary`). NOT duplicated on products.
- New product column: `shop_types text[] NOT NULL DEFAULT '{}'`, GIN-indexed.
- discover_products keeps the verification gate (`s.verification_status='approved'`, `pr.account_status='active'`, `p.is_active`) and the seeded-shuffle ordering.
- **2.19 (money-as-float) is explicitly SKIPPED for this feature** — display-only currency change; pre-existing float price tracked as separate [FIN] debt. Do NOT change price storage/types.
- Parameterized queries only (2.2); inputs validated (2.1); generic errors (2.4/5.5); offset pagination clamped (3.1); indexes verified (3.3).
- Deno: `deno check --no-config <file>`. Dart: `flutter analyze`.
- supabaseClientProvider: `lib/presentation/features/auth/providers/auth_provider.dart:12`.

---

## File Structure

**Backend:**
- `supabase/migrations/20260620170000_product_shop_types.sql` — add `products.shop_types` + GIN index; extend `discover_products` with location join + `p_user_lat/lng/radius` + `p_shop_types` overlap + `distance_km`.

**Flutter:**
- `lib/core/constants/shop_types.dart` — `ShopTypes.all` shared constant (Create).
- `lib/presentation/features/products/data/models/product_model.dart` — add `shopTypes`, `shopCurrencySymbol`, `shopCurrencyCode`, `distanceKm` (Modify).
- `lib/presentation/features/products/data/repositories/supabase_product_repository.dart` + `product_repository.dart` — `shopTypes` on create/update; product currency join (Modify).
- `lib/presentation/features/products/presentation/providers/product_providers.dart` — thread `shopTypes` (Modify).
- `lib/presentation/features/products/presentation/screens/product_form_screen.dart` — shop-type chips + shop-currency price symbol (Modify).
- `lib/presentation/features/shops/creation/presentation/screens/edit_basics_screen.dart` — read `ShopTypes.all` (Modify, small DRY).
- `lib/presentation/features/products/presentation/screens/seller_onboarding_screen.dart` — location step (Modify).
- Buy-tab discovery providers/widgets (located in Task 6).

---

## Task 1: Shared `ShopTypes` constant

**Files:**
- Create: `lib/core/constants/shop_types.dart`
- Modify: `lib/presentation/features/shops/creation/presentation/screens/edit_basics_screen.dart`

**Interfaces:**
- Produces: `class ShopTypes { static const List<String> all = ['Salon','Barbershop','Spa','Nail Salon']; }`

- [ ] **Step 1: Create the constant**

```dart
// lib/core/constants/shop_types.dart
/// Canonical shop-type vocabulary. Stored verbatim (display strings) on
/// shops.shop_type and products.shop_types so discovery filters overlap.
class ShopTypes {
  ShopTypes._();
  static const List<String> all = ['Salon', 'Barbershop', 'Spa', 'Nail Salon'];
}
```

- [ ] **Step 2: Point EditBasicsScreen at it**

In `edit_basics_screen.dart`, add the import and replace the local
`final List<String> _shopTypes = ['Salon', 'Barbershop', 'Spa', 'Nail Salon'];`
with `final List<String> _shopTypes = ShopTypes.all;` (or reference `ShopTypes.all`
directly where `_shopTypes` is used). Confirm via grep the literal list no longer
appears there.

- [ ] **Step 3: Analyze**

Run: `flutter analyze lib/core/constants/shop_types.dart lib/presentation/features/shops/creation/presentation/screens/edit_basics_screen.dart`
Expected: No issues.

- [ ] **Step 4: Commit**

```bash
git add lib/core/constants/shop_types.dart lib/presentation/features/shops/creation/presentation/screens/edit_basics_screen.dart
git commit -m "refactor(shops): extract canonical ShopTypes.all constant"
```

---

## Task 2: Migration — products.shop_types + extend discover_products

**Files:**
- Create: `supabase/migrations/20260620170000_product_shop_types.sql`

**Interfaces:**
- Produces: `products.shop_types text[]`; GIN index `idx_products_shop_types`; `discover_products(p_seed, p_category, p_min_price, p_max_price, p_sort_by, p_user_lat, p_user_lng, p_radius_km, p_shop_types, p_limit, p_offset)` returning the product jsonb shape + `distance_km`, with currency in the nested `shops` object.

- [ ] **Step 1: Read the current discover_products to extend it faithfully**

Run: `sed -n '50,110p' supabase/migrations/20260620140000_discover_rpcs.sql`
Note its current params, the `to_jsonb(p) || jsonb_build_object('shops', ...)` shape, the gate (is_active + account_status + verification_status='approved'), and the seeded ORDER BY. Preserve all of it; this task ADDS location + shop_types + currency.

- [ ] **Step 2: Write the migration**

```sql
-- supabase/migrations/20260620170000_product_shop_types.sql
-- Per-product shop types (multi-select) + location-aware, type-filtered
-- product discovery. Currency + location are derived from the owning shop.

alter table public.products
  add column if not exists shop_types text[] not null default '{}';

create index if not exists idx_products_shop_types
  on public.products using gin (shop_types);

-- Re-create discover_products: add location join (ST_DWithin + distance_km),
-- a shop_types overlap filter, and shop currency in the embedded shops object.
create or replace function public.discover_products(
  p_seed int default 0,
  p_category text default null,
  p_min_price numeric default null,
  p_max_price numeric default null,
  p_sort_by text default null,
  p_user_lat double precision default null,
  p_user_lng double precision default null,
  p_radius_km double precision default null,
  p_shop_types text[] default null,
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
  select to_jsonb(p)
         || jsonb_build_object(
              'shops', jsonb_build_object(
                'id', s.id, 'shop_name', s.shop_name, 'verified', s.verified,
                'luxury_level', s.luxury_level, 'average_rating', s.average_rating,
                'currency', s.currency, 'currency_symbol', s.currency_symbol
              ),
              'distance_km',
              case
                when p_user_lat is null or p_user_lng is null
                     or sl.latitude is null or sl.longitude is null then null
                else round(
                  (ST_Distance(
                    ST_SetSRID(ST_MakePoint(p_user_lng, p_user_lat), 4326)::geography,
                    ST_SetSRID(ST_MakePoint(sl.longitude, sl.latitude), 4326)::geography
                  ) / 1000)::numeric, 2)
              end
            ) as product
  from public.products p
  join public.shops s on s.id = p.shop_id
  join public.profiles pr on pr.id = s.user_id
  left join public.shop_locations sl on sl.shop_id = s.id and sl.is_primary = true
  where p.is_active = true
    and pr.account_status = 'active'
    and s.verification_status = 'approved'
    and (p_category is null or p_category = '' or p.category = p_category)
    and (p_min_price is null or p.price >= p_min_price)
    and (p_max_price is null or p.price <= p_max_price)
    and (p_shop_types is null or array_length(p_shop_types, 1) is null
         or p.shop_types && p_shop_types)
    and (
      p_user_lat is null or p_user_lng is null or p_radius_km is null
      or (
        sl.latitude is not null and sl.longitude is not null
        and ST_DWithin(
          ST_SetSRID(ST_MakePoint(sl.longitude, sl.latitude), 4326)::geography,
          ST_SetSRID(ST_MakePoint(p_user_lng, p_user_lat), 4326)::geography,
          p_radius_km * 1000
        )
      )
    )
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

- [ ] **Step 3: Validate SQL**

If Docker/local Supabase available: `supabase db reset`. Else inspect for balanced `$function$`, the `&&` overlap, the `ST_DWithin` guard, idempotent `create or replace` / `if not exists`; note runtime deferred.

- [ ] **Step 4: Commit**

```bash
git add supabase/migrations/20260620170000_product_shop_types.sql
git commit -m "feat(db): products.shop_types + location/type-aware discover_products"
```

---

## Task 3: ProductModel — shopTypes, currency, distance

**Files:**
- Modify: `lib/presentation/features/products/data/models/product_model.dart`

**Interfaces:**
- Produces: `ProductModel.shopTypes` (`List<String>`), `.shopCurrencySymbol` (`String?`), `.shopCurrencyCode` (`String?`), `.distanceKm` (`double?`); all parsed in `fromJson`.

- [ ] **Step 1: Add fields**

In the field list add:
```dart
  final List<String> shopTypes;
  final String? shopCurrencySymbol;
  final String? shopCurrencyCode;
  final double? distanceKm;
```
Add to the constructor: `this.shopTypes = const [],`, `this.shopCurrencySymbol,`, `this.shopCurrencyCode,`, `this.distanceKm,`.

- [ ] **Step 2: Parse in fromJson**

After the existing `shopVerified` parse:
```dart
      shopTypes: (json['shop_types'] as List?)?.map((e) => e as String).toList() ?? const [],
      shopCurrencySymbol: shop?['currency_symbol'] as String?,
      shopCurrencyCode: shop?['currency'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
```
(`shop` is the existing `json['shops']` map local.)

- [ ] **Step 3: Emit in toJson + props/Equatable**

In `toJson` add `'shop_types': shopTypes,`. If the class is Equatable, add the four fields to `props`. If it has a `copyWith`, thread them.

- [ ] **Step 4: Analyze**

Run: `flutter analyze lib/presentation/features/products/data/models/product_model.dart`
Expected: No issues.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/features/products/data/models/product_model.dart
git commit -m "feat(products): ProductModel carries shopTypes + shop currency + distance"
```

---

## Task 4: Repository + notifier — persist shop_types

**Files:**
- Modify: `lib/presentation/features/products/data/repositories/supabase_product_repository.dart`
- Modify: `lib/presentation/features/products/data/repositories/product_repository.dart` (abstract interface)
- Modify: `lib/presentation/features/products/presentation/providers/product_providers.dart`

**Interfaces:**
- Produces: `createProduct({..., required List<String> shopTypes})` and `updateProduct({..., List<String>? shopTypes})` on repo + notifier.

- [ ] **Step 1: Repository createProduct**

In `supabase_product_repository.dart` `createProduct`, add param `required List<String> shopTypes,` and add `'shop_types': shopTypes,` to the `.insert({...})` map.

- [ ] **Step 2: Repository updateProduct**

Add param `List<String>? shopTypes,`; in `updateData` add `if (shopTypes != null) 'shop_types': shopTypes,`.

- [ ] **Step 3: Abstract interface**

In `product_repository.dart`, mirror both signatures (`required List<String> shopTypes` on create, `List<String>? shopTypes` on update).

- [ ] **Step 4: Notifier**

In `product_providers.dart`, add the same params to the notifier's `createProduct`/`updateProduct` and pass them through to the repository calls.

- [ ] **Step 5: Analyze**

Run: `flutter analyze lib/presentation/features/products/data/repositories/ lib/presentation/features/products/presentation/providers/product_providers.dart`
Expected: No errors (the form caller will be updated in Task 5; if analyze flags the missing arg at the call site, that's expected and fixed next task — note it).

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/features/products/data/ lib/presentation/features/products/presentation/providers/product_providers.dart
git commit -m "feat(products): thread shop_types through repository + notifier"
```

---

## Task 5: ProductFormScreen — shop-type chips + shop-currency price

**Files:**
- Modify: `lib/presentation/features/products/presentation/screens/product_form_screen.dart`

**Interfaces:**
- Consumes: `ShopTypes.all`, `createProduct/updateProduct({shopTypes})`, `supabaseClientProvider`.

- [ ] **Step 1: Load shop currency + init shop-types state**

Add fields: `List<String> _selectedShopTypes = [];`, `String? _shopCurrencySymbol;`.
In `initState`: if edit mode, seed `_selectedShopTypes = List.of(widget.product!.shopTypes)`. Add a method to fetch the shop currency:
```dart
Future<void> _loadShopCurrency() async {
  final row = await ref.read(supabaseClientProvider)
      .from('shops').select('currency_symbol').eq('id', widget.shopId).maybeSingle();
  if (mounted) setState(() => _shopCurrencySymbol = row?['currency_symbol'] as String?);
}
```
Call it from `initState`.

- [ ] **Step 2: Shop-type chips (AppFilterChip multi-select)**

Add a section (near the category dropdown) rendering `ShopTypes.all` as `AppFilterChip`s with multi-select:
```dart
Wrap(
  spacing: 8.w, runSpacing: 8.h,
  children: ShopTypes.all.map((type) {
    final selected = _selectedShopTypes.contains(type);
    return AppFilterChip(
      label: type,
      selected: selected,
      onSelected: (sel) => setState(() {
        if (sel) {
          _selectedShopTypes.add(type);
        } else {
          _selectedShopTypes.remove(type);
        }
      }),
    );
  }).toList(),
),
```
Add the import for `ShopTypes`.

- [ ] **Step 3: Currency on the price field**

Change the price field label/prefix from the hardcoded `Currency.symbol` to
`_shopCurrencySymbol ?? Currency.symbol` (e.g. `label: 'Price (${_shopCurrencySymbol ?? Currency.symbol})'`).

- [ ] **Step 4: Validate + pass shopTypes on save**

In `_saveProduct`, after the category check, require ≥1 shop type:
```dart
if (_selectedShopTypes.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Please select at least one category type')));
  return;
}
```
Pass `shopTypes: _selectedShopTypes` to both `notifier.createProduct(...)` and `notifier.updateProduct(...)`.

- [ ] **Step 5: Analyze**

Run: `flutter analyze lib/presentation/features/products/presentation/screens/product_form_screen.dart`
Expected: No errors.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/features/products/presentation/screens/product_form_screen.dart
git commit -m "feat(products): shop-type chips + shop-currency price on product form"
```

---

## Task 6: Buy-tab discovery — location + shop-type filtering

**Files:**
- Modify: `lib/presentation/features/products/data/repositories/supabase_product_repository.dart` (`getMarketplaceProducts`)
- Modify: the marketplace product provider/notifier + the Buy-tab wiring (located in Step 1)

**Interfaces:**
- Consumes: extended `discover_products` RPC (Task 2); ServiceCategoryTabs selection; user location; discovery seed.

- [ ] **Step 1: Locate the Buy-tab data path + selection sources**

Run:
```bash
grep -rn "getMarketplaceProducts\|discover_products\|ServiceCategoryTabs\|selectedServiceCategory\|userLocation\|hasLocationProvider\|ProviderType.buy" lib/presentation/features/products lib/presentation/features/discover lib/presentation/features/shops/query/providers | head -30
```
Identify: the provider that calls `getMarketplaceProducts`, how ServiceCategoryTabs exposes the selected type(s) (`selectedServiceCategoryProvider`), and how user location is read (`hasLocationProvider` / the location provider used by shop discovery). Record file:line of each.

- [ ] **Step 2: Add location + shopTypes params to getMarketplaceProducts**

Add params `double? userLat, double? userLng, double? radiusKm, List<String>? shopTypes,` to `getMarketplaceProducts`, and pass them to the `discover_products` rpc map: `p_user_lat/p_user_lng/p_radius_km/p_shop_types`. Keep existing `p_seed/p_category/p_min_price/p_max_price/p_sort_by/p_limit/p_offset`. Parse `distance_km` is already in the product jsonb (Task 3 reads it).

- [ ] **Step 3: Thread selection + location from the Buy tab**

In the marketplace provider/notifier found in Step 1, read the ServiceCategoryTabs selection and map it to `shopTypes` (a single selected category → `[category]`; if the tabs support multiple, pass the list; empty → null = all). Read user location (same source shop discovery uses) → `userLat/userLng/radiusKm`. Pass both into `getMarketplaceProducts`. Report exactly how ServiceCategoryTabs selection is shaped (single vs multi) and how you mapped it.

- [ ] **Step 4: Analyze**

Run: `flutter analyze lib/presentation/features/products lib/presentation/features/discover`
Expected: No errors.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat(discover): Buy tab filters products by location + shop types"
```

---

## Task 7: Seller onboarding — location step

**Files:**
- Modify: `lib/presentation/features/products/presentation/screens/seller_onboarding_screen.dart`

**Interfaces:**
- Consumes: `LocationPickerBottomSheet` (returns `ParsedAddress`), `CurrencySelector`, `CountryCurrencyMapper`, `Currencies`; `createShop`.

- [ ] **Step 1: Study the reusable location widgets**

Run:
```bash
sed -n '40,75p' lib/presentation/features/shops/creation/presentation/screens/edit_location_screen.dart
grep -rn "class LocationPickerBottomSheet\|class CurrencySelector\|ParsedAddress\|CountryCurrencyMapper\|Currencies.fromCode" lib | head
```
Note: `LocationPickerBottomSheet` returns a `ParsedAddress` (address/city/country/lat/lng/countryCode); `CurrencySelector(onCurrencySelected:)`; `CountryCurrencyMapper` maps country→currency. EditLocationScreen is coupled to `shopCreationProvider`; the seller step must drive these with LOCAL state instead (do not route seller onboarding through shopCreationProvider).

- [ ] **Step 2: Add local location/currency state + a location section**

In `SellerOnboardingScreen` add local fields: `String? _address, _city, _country; double? _lat, _lng; String? _currencyCode, _currencySymbol;`. Add a location section that opens `LocationPickerBottomSheet` (via BottomSheetUtils, same as EditLocationScreen's `_openLocationPicker`); on result set the local address/lat/lng and auto-detect currency via `CountryCurrencyMapper` from the country code. Render a `CurrencySelector` showing the detected currency with manual override → updates `_currencyCode/_currencySymbol`. Require a location before continue (validation, 2.1).

- [ ] **Step 3: Pass location + currency into createShop**

In `_submit`, build the `ShopDraft` with `address: _address, city: _city, country: _country, latitude: _lat, longitude: _lng, currencyCode: _currencyCode, currencySymbol: _currencySymbol` (in addition to the existing shopName/overview/shopType). `createShop` already inserts `shop_locations` when `draft.address != null` and persists currency — verify by reading the createShop body; if the seller draft sets address, the location row is written automatically.

- [ ] **Step 4: Analyze**

Run: `flutter analyze lib/presentation/features/products/presentation/screens/seller_onboarding_screen.dart`
Expected: No errors.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/features/products/presentation/screens/seller_onboarding_screen.dart
git commit -m "feat(products): seller onboarding captures location + currency"
```

---

## Task 8: Full analyze + manual verification

**Files:** none (verification only)

- [ ] **Step 1: Full analyze**

Run: `flutter analyze lib/`
Expected: no NEW errors in lib/ (pre-existing test/ errors unrelated).

- [ ] **Step 2: Apply migration (manual; needs DB)**

```bash
supabase db push   # applies 20260620170000
```

- [ ] **Step 3: Manual smoke test**

1. As a shop owner, open the product form → price shows the shop's currency symbol; select multiple shop-type chips → save → product persists shop_types.
2. As a client, sell-a-product onboarding → set location (currency auto-detected, override works) → product form → create.
3. Discover → Buy tab → with a user location set, products appear by proximity; selecting ServiceCategoryTabs types filters products to overlapping shop_types; unverified producers' products never appear.

- [ ] **Step 4: Commit any fixes**

```bash
git add -A
git commit -m "fix: address product currency/location/shop-types smoke-test findings"
```

---

## Notes on Algorithm Quality Review Checklist v3.1

- **2.1 input validation:** ≥1 shop type required; location required in seller onboarding; price validated.
- **2.2 parameterized:** all via RPC params incl. `p_shop_types text[]` and lat/lng; no interpolation.
- **2.4/5.5 no leakage:** generic actionable errors in form + RPC.
- **1.4/1.5 authz/authn:** product writes scoped to owning shop; location write via owner path.
- **3.1/3.2/3.3:** offset pagination clamped; single joined RPC (no N+1); GIN index on shop_types + spatial index on shop_locations; EXPLAIN-verifiable.
- **5.2 latency:** chips/price local (≤200ms); discovery shows loading state immediately.
- **6.1/6.4 tests:** shop-type overlap (empty/one/many/no-match), currency fallback, location-missing, verification gate preserved, seeded pagination stable.
- **2.19 SKIPPED w/ justification:** display-only currency; pre-existing float price; separate [FIN] debt — no new float math introduced.
