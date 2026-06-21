# Marketplace Currency Through Cart / Checkout / Orders Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show and persist the correct per-shop currency through cart, checkout, and order surfaces — replacing hardcoded ₦ — and record each order's currency.

**Architecture:** The cart is hard single-shop (one currency). Capture the product's shop currency into CartItemModel, expose it on CartState, and render cart/checkout with it. Add `currency`/`currency_symbol` to the orders table, have `create_order` source them server-side from the shop, parse them onto OrderModel, and render all order screens with `Currency.formatWithSymbol`.

**Tech Stack:** Flutter, Riverpod, Supabase (Postgres RPC), json_serializable.

## Global Constraints

- Compliance: Algorithm Quality Review Checklist v3.1.
- Money representation UNCHANGED: DB stays `NUMERIC(12,2)` (exact decimal, authoritative); Dart stays `double` (display + tolerance-checked hint). NO minor-units migration, NO new float math. 2.19 is resolved server-side (documented in spec).
- Order currency is sourced **server-side from the shop** in `create_order` — never from the client (not spoofable).
- Display via `Currency.formatWithSymbol(amount, symbol)` (already exists in `lib/presentation/features/products/data/utils/currency.dart`); falls back to default ₦ when symbol null/empty.
- Cart is single-shop (`addItem` throws `MultiShopCartException`) — so `CartState.currencySymbol = items.first.currencySymbol` is safe; no mixed-currency handling.
- `ProductModel` already has `shopCurrencySymbol` / `shopCurrencyCode`.
- `CartItemModel` is `@JsonSerializable` (has `cart_item_model.g.dart`) → run `dart run build_runner build --delete-conflicting-outputs` after editing it.
- Don't change: cart single-shop enforcement, per-shop order creation, the `create_order` total recompute + mismatch guard, the generated `order_items.subtotal` column.

---

## File Structure

**Backend:**
- `supabase/migrations/20260621000000_orders_currency.sql` — add orders.currency/currency_symbol + backfill + extend create_order.

**Flutter:**
- `lib/presentation/features/products/data/models/cart_item_model.dart` (+ `.g.dart` regen) — currency fields.
- `lib/presentation/features/products/presentation/providers/cart_provider.dart` — `CartState.currencySymbol`.
- `lib/presentation/features/products/presentation/screens/product_detail_screen.dart` + `customer_order_detail_screen.dart` — capture currency when building CartItemModel.
- `lib/presentation/features/products/data/models/order_model.dart` — OrderModel currency fields.
- `lib/presentation/features/products/presentation/screens/{cart,checkout,order_confirmation,order_detail,customer_order_detail,customer_orders,shop_orders}_screen.dart` — render with per-shop symbol.

---

## Task 1: CartItemModel currency fields

**Files:**
- Modify: `lib/presentation/features/products/data/models/cart_item_model.dart`
- Regenerate: `lib/presentation/features/products/data/models/cart_item_model.g.dart`

**Interfaces:**
- Produces: `CartItemModel.currencySymbol` (`String?`), `.currencyCode` (`String?`) — in constructor, copyWith, props, and JSON (via build_runner).

- [ ] **Step 1: Add the fields**

In `cart_item_model.dart`, after `final String shopName;`:
```dart
  final String? currencySymbol;
  final String? currencyCode;
```
Constructor — after `required this.shopName,`:
```dart
    this.currencySymbol,
    this.currencyCode,
```
copyWith — add params `String? currencySymbol,`, `String? currencyCode,` and assignments `currencySymbol: currencySymbol ?? this.currencySymbol,`, `currencyCode: currencyCode ?? this.currencyCode,`.
props — add `currencySymbol,`, `currencyCode,`.

- [ ] **Step 2: Regenerate JSON**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: completes; `cart_item_model.g.dart` now serializes the two new fields.

- [ ] **Step 3: Analyze**

Run: `flutter analyze lib/presentation/features/products/data/models/cart_item_model.dart`
Expected: No issues.

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/features/products/data/models/cart_item_model.dart lib/presentation/features/products/data/models/cart_item_model.g.dart
git commit -m "feat(cart): CartItemModel carries shop currency"
```

---

## Task 2: Capture currency when adding to cart

**Files:**
- Modify: `lib/presentation/features/products/presentation/screens/product_detail_screen.dart`
- Modify: `lib/presentation/features/products/presentation/screens/customer_order_detail_screen.dart`

**Interfaces:**
- Consumes: `CartItemModel.currencySymbol/currencyCode`, `ProductModel.shopCurrencySymbol/shopCurrencyCode`.

- [ ] **Step 1: product_detail_screen — pass currency**

Find the `CartItemModel(` construction (~line 54). Add, alongside the existing `price: product.price,` etc.:
```dart
        currencySymbol: product.shopCurrencySymbol,
        currencyCode: product.shopCurrencyCode,
```

- [ ] **Step 2: customer_order_detail_screen — pass currency on reorder**

Find the `CartItemModel(` construction (~line 56). This builds a cart item from a past order's item. Source the currency from the order being reordered: add
```dart
        currencySymbol: order.currencySymbol,
        currencyCode: order.currencyCode,
```
(where `order` is the OrderModel in scope — Task 4 adds those fields; if the variable name differs, use the in-scope order/orderItem's currency. If only the order item is in scope, thread the parent order's currencySymbol.) Report the exact source used.

- [ ] **Step 3: Analyze**

Run: `flutter analyze lib/presentation/features/products/presentation/screens/product_detail_screen.dart lib/presentation/features/products/presentation/screens/customer_order_detail_screen.dart`
Expected: No errors. (If Step 2 references OrderModel.currencySymbol before Task 4, that's a forward dep — do Task 4 first if analyze fails here, or stub by reading the order's nested shop currency. Report.)

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/features/products/presentation/screens/product_detail_screen.dart lib/presentation/features/products/presentation/screens/customer_order_detail_screen.dart
git commit -m "feat(cart): capture shop currency when adding/reordering to cart"
```

---

## Task 3: CartState.currencySymbol + cart/checkout display

**Files:**
- Modify: `lib/presentation/features/products/presentation/providers/cart_provider.dart`
- Modify: `lib/presentation/features/products/presentation/screens/cart_screen.dart`
- Modify: `lib/presentation/features/products/presentation/screens/checkout_screen.dart`

**Interfaces:**
- Produces: `CartState.currencySymbol` (`String?`).
- Consumes: `Currency.formatWithSymbol`.

- [ ] **Step 1: Add CartState.currencySymbol**

In `cart_provider.dart`, near the existing `singleShopId` getter on the cart state class:
```dart
  /// The cart is single-shop (addItem enforces it), so currency is uniform.
  String? get currencySymbol =>
      items.isEmpty ? null : items.first.currencySymbol;
```

- [ ] **Step 2: cart_screen — render with symbol**

Replace `Currency.format(cartState.totalAmount)` → `Currency.formatWithSymbol(cartState.totalAmount, cartState.currencySymbol)`; and per-item `Currency.formatCompact(item.subtotal)` / `Currency.format(item.price)` → `Currency.formatWithSymbol(item.subtotal, item.currencySymbol)` etc. Grep the file for `Currency.` and convert each money display.

- [ ] **Step 3: checkout_screen — render with symbol**

Same: replace `Currency.format(cartState.totalAmount)` and `Currency.formatCompact(item.subtotal)` with the `formatWithSymbol` variants using `cartState.currencySymbol` / `item.currencySymbol`. Leave the `createOrder(totalAmount: cartState.totalAmount, ...)` call unchanged (amount stays double; currency is server-sourced).

- [ ] **Step 4: Analyze**

Run: `flutter analyze lib/presentation/features/products/presentation/providers/cart_provider.dart lib/presentation/features/products/presentation/screens/cart_screen.dart lib/presentation/features/products/presentation/screens/checkout_screen.dart`
Expected: No errors.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/features/products/presentation/providers/cart_provider.dart lib/presentation/features/products/presentation/screens/cart_screen.dart lib/presentation/features/products/presentation/screens/checkout_screen.dart
git commit -m "feat(cart): per-shop currency in cart + checkout displays"
```

---

## Task 4: Orders currency — migration + OrderModel

**Files:**
- Create: `supabase/migrations/20260621000000_orders_currency.sql`
- Modify: `lib/presentation/features/products/data/models/order_model.dart`

**Interfaces:**
- Produces: `orders.currency`, `orders.currency_symbol`; `create_order` writes them from the shop; `OrderModel.currencySymbol` (`String?`), `.currencyCode` (`String?`).

- [ ] **Step 1: Read the live create_order body**

Run: `sed -n '147,290p' supabase/migrations/20260516000000_marketplace_hardening.sql`
This is the authoritative `create_order`. The new migration `CREATE OR REPLACE`s it with ONLY two additions: (a) fetch the shop's currency, (b) include it in the orders INSERT. Preserve every other line (validation, item locking, total recompute, mismatch guard, idempotency).

- [ ] **Step 2: Write the migration**

```sql
-- supabase/migrations/20260621000000_orders_currency.sql
-- Persist the currency an order was placed in. Sourced server-side from the
-- shop (not the client). Money columns stay NUMERIC; this is additive.

alter table public.orders
  add column if not exists currency text,
  add column if not exists currency_symbol text;

-- Backfill existing orders from their shop.
update public.orders o
  set currency = s.currency,
      currency_symbol = s.currency_symbol
  from public.shops s
  where s.id = o.shop_id and o.currency is null;
```

Then append the `CREATE OR REPLACE FUNCTION create_order(...)` copied verbatim from the live body (Step 1), with these two edits:
- In the DECLARE block, add: `v_currency TEXT; v_currency_symbol TEXT;`
- After the shop is validated / before/at the orders INSERT, add a fetch:
  `SELECT currency, currency_symbol INTO v_currency, v_currency_symbol FROM shops WHERE id = p_shop_id;`
- In `INSERT INTO orders (user_id, shop_id, status, total_amount, …)` add the columns `currency, currency_symbol` and values `v_currency, v_currency_symbol`.
Write the FULL function body (do not abbreviate); show it in the implementation.

- [ ] **Step 3: OrderModel currency fields**

In `order_model.dart`: add `final String? currencySymbol;` and `final String? currencyCode;` to OrderModel (constructor + props). In `fromJson` (which already extracts `final shop = json['shops']`):
```dart
      currencyCode: json['currency'] as String? ?? shop?['currency'] as String?,
      currencySymbol:
          json['currency_symbol'] as String? ?? shop?['currency_symbol'] as String?,
```
(Prefer the order's own column; fall back to the joined shop for legacy/unbackfilled rows.)

- [ ] **Step 4: Validate + analyze**

SQL: if Docker/local Supabase available, `supabase db reset`; else inspect for balanced `$function$`, the shop currency fetch, the INSERT additions, idempotent `add column if not exists` / `create or replace`; note runtime deferred.
Dart: `flutter analyze lib/presentation/features/products/data/models/order_model.dart` → No issues.

- [ ] **Step 5: Commit**

```bash
git add supabase/migrations/20260621000000_orders_currency.sql lib/presentation/features/products/data/models/order_model.dart
git commit -m "feat(orders): persist + source per-shop currency in create_order + OrderModel"
```

---

## Task 5: Order display surfaces use per-shop currency

**Files:**
- Modify: `lib/presentation/features/products/presentation/screens/order_confirmation_screen.dart`
- Modify: `lib/presentation/features/products/presentation/screens/order_detail_screen.dart`
- Modify: `lib/presentation/features/products/presentation/screens/customer_order_detail_screen.dart`
- Modify: `lib/presentation/features/products/presentation/screens/customer_orders_screen.dart`
- Modify: `lib/presentation/features/products/presentation/screens/shop_orders_screen.dart`

**Interfaces:**
- Consumes: `OrderModel.currencySymbol`, `Currency.formatWithSymbol`.

- [ ] **Step 1: Replace hardcoded format in each order screen**

In each of the five files, grep `Currency.format` / `Currency.formatCompact` and replace each money display with `Currency.formatWithSymbol(amount, order.currencySymbol)`, where `order` is the OrderModel in scope (for list screens it's the per-row order; for item rows use the parent order's `currencySymbol`). Run per file:
`grep -n "Currency\." <file>` before/after to confirm every money display is converted and none missed. Report the per-file count.

- [ ] **Step 2: Analyze**

Run: `flutter analyze lib/presentation/features/products/presentation/screens/order_confirmation_screen.dart lib/presentation/features/products/presentation/screens/order_detail_screen.dart lib/presentation/features/products/presentation/screens/customer_order_detail_screen.dart lib/presentation/features/products/presentation/screens/customer_orders_screen.dart lib/presentation/features/products/presentation/screens/shop_orders_screen.dart`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/features/products/presentation/screens/
git commit -m "feat(orders): order screens display per-shop currency"
```

---

## Task 6: Full analyze + manual verification

**Files:** none (verification only)

- [ ] **Step 1: Full analyze**

Run: `flutter analyze lib/`
Expected: no NEW errors in lib/ (pre-existing test/ errors unrelated).

- [ ] **Step 2: Apply migration (manual; needs DB)**

```bash
supabase db push   # applies 20260621000000_orders_currency.sql
```

- [ ] **Step 3: Manual smoke test**

1. Add a product from a non-NGN shop to cart → cart + checkout show that shop's currency symbol on item + total.
2. Place the order → order confirmation shows the shop currency.
3. Open the order in customer order history + detail, and the shop's order list → all show the shop currency.
4. Reorder from a past order → cart shows the right currency.
5. A pre-existing (legacy) order still displays (falls back to shop currency via the join, or default symbol).

- [ ] **Step 4: Commit any fixes**

```bash
git add -A
git commit -m "fix: address marketplace currency smoke-test findings"
```

---

## Notes on Algorithm Quality Review Checklist v3.1

- **2.19 (P0-U, [FIN]):** money representation unchanged; authoritative layer is exact-decimal NUMERIC + server recompute; Dart double is display-only; no new float math. Resolved per spec.
- **2.1 input validation:** no new client money input; `formatWithSymbol` null/empty-safe.
- **1.4/1.5 authz, server trust:** order currency sourced from the shop server-side in create_order; not client-supplied.
- **1.1/2.18 idempotency:** create_order's idempotency-key path + total recompute + mismatch guard unchanged; currency additive/deterministic.
- **6.1/6.4 tests:** currency flows product→cart→order→display; legacy null-currency fallback; RPC writes shop currency; mismatch validation intact.
- **No regression:** cart single-shop enforcement, per-shop orders, generated subtotal, money types all unchanged.
