# Marketplace Currency Through Cart / Checkout / Orders — Design

**Date:** 2026-06-21
**Status:** Approved (ready for implementation plan)
**Compliance target:** Algorithm Quality Review Checklist v3.1
**Scope tags:** `[MUTATION]` (order creation), `[FIN]` (money/currency), `[UI]`/`[MOBILE]` (cart/checkout/order screens), `[SERVICE]` (create_order RPC).

## Goal

Show and persist the correct **per-shop currency** through the cart, checkout,
and order surfaces — replacing the hardcoded ₦ (NGN) `Currency.format` calls —
so a buyer sees the shop's actual currency everywhere, and each order records
the currency it was placed in.

## Verified premises (these shrink the scope)

- **The cart is hard single-shop.** `CartNotifier.addItem` throws
  `MultiShopCartException` when a new item's `shopId` differs from the cart's.
  So a cart is always one shop → **one currency**. There is no mixed-currency
  cart to handle; the cart total is always single-currency and safe to sum.
- **Orders are per-shop.** `create_order(p_shop_id, …)` makes one order per
  shop; checkout uses `cartState.items.first.shopId`.
- **DB money is exact decimal.** `products.price`, `orders.total_amount`,
  `order_items.unit_price/subtotal` are all `NUMERIC(12,2)`; `order_items.subtotal`
  is a generated column; `create_order` **recomputes** the total server-side and
  rejects a client/server mismatch (`abs(p_total_amount - v_total) > 1`).
- **Payments already use minor units** (`lib/payment` uses `amountMinor`,
  `* 100` / `/ 100` at the provider boundary) — that layer is unchanged here.

## 2.19 (money-as-float) resolution

The **authoritative** money layer is the DB (`NUMERIC`, exact decimal) and the
`create_order` RPC (server-recomputed total, mismatch-validated). The Dart
`double` for `price`/`total` is a **display + tolerance-checked hint**, never the
source of truth. Therefore 2.19's intent ("money never computed as float of
record") is **already satisfied server-side**. This feature does **not** change
money representation; Dart stays `double`, converted to text only at display via
`Currency.formatWithSymbol`. No new float math is introduced. 2.19 is recorded as
resolved (server-authoritative exact decimal); a Dart-side minor-units migration
is explicitly out of scope as low-value (non-authoritative display layer).

---

## Section 1 — Currency into the cart

- `CartItemModel` gains `currencySymbol` (`String?`) and `currencyCode`
  (`String?`), captured at `addItem` time from the product's
  `shopCurrencySymbol` / `shopCurrencyCode` (`ProductModel` already carries
  these). Thread through constructor, `copyWith`, `toJson`/`fromJson` (cart is
  persisted to local storage), and Equatable props.
- `CartState` exposes `String? get currencySymbol => items.isEmpty ? null :
  items.first.currencySymbol;` (safe — single-shop cart).
- `cart_screen` per-item and total displays use
  `Currency.formatWithSymbol(amount, cartState.currencySymbol)` instead of
  `Currency.format` / `Currency.formatCompact`.

## Section 2 — Order currency persistence + checkout `[MUTATION][FIN][SERVICE]`

**Migration** (`supabase/migrations/20260621000000_orders_currency.sql`):
- `alter table orders add column currency text`, `add column currency_symbol text`
  (nullable for legacy rows).
- Backfill existing orders from their shop:
  `update orders o set currency = s.currency, currency_symbol = s.currency_symbol
  from shops s where s.id = o.shop_id and o.currency is null`.
- `create or replace function create_order(...)` — based on the live body in
  `20260516000000_marketplace_hardening.sql`. It already loads the shop context;
  add: fetch `shops.currency` + `currency_symbol` for `p_shop_id` and write them
  into the `INSERT INTO orders (...)`. **Currency is sourced server-side from the
  shop — never from the client (cannot be spoofed).** No change to the total
  recompute or the mismatch validation.

**`OrderModel` / `OrderItem`:** add `currencySymbol` / `currencyCode`, parsed
from the order row. `createOrder` repo signature is unchanged (RPC sources
currency from the shop).

**Checkout screen:** total + per-item prices use the cart's `currencySymbol`
(from Section 1). No flow change — still one order per single-shop cart.

## Section 3 — Order display surfaces `[UI]`

Replace hardcoded `Currency.format` / `formatCompact` with
`Currency.formatWithSymbol(amount, order.currencySymbol)` in:
`order_confirmation_screen`, `order_detail_screen`,
`customer_order_detail_screen`, `customer_orders_screen`, `shop_orders_screen`.
Legacy orders with null currency fall back to the default symbol (until the
backfill runs / for any pre-existing row).

---

## Algorithm Quality Review Checklist v3.1 — application

- **1.4/1.5 authz/authn (P0-U):** order creation already authenticated +
  shop-scoped; currency is server-derived, not a new trust input.
- **2.1 input validation (P0-U):** no new client money input; currency sourced
  from the shop server-side; `formatWithSymbol` handles null/empty symbol.
- **2.2 parameterized (P0-U):** all DB access via the RPC / Supabase client; no
  string interpolation.
- **2.4/5.5 no leakage:** display + RPC errors stay generic.
- **2.19 (P0-U, [FIN]):** resolved — authoritative money is exact-decimal
  server-side; Dart double is display-only; no new float math (documented above).
- **1.1/2.18 idempotency ([MUTATION]):** `create_order` keeps its existing
  idempotency-key path; currency is additive and deterministic, so retries are
  unaffected.
- **3.3 indexes:** no new query patterns needing indexes (currency is read with
  the already-fetched order/shop rows).
- **6.1/6.4 tests:** currency flows product→cart→order→display; legacy
  null-currency order falls back; RPC writes shop currency (not client value);
  total recompute + mismatch validation still pass; `formatWithSymbol` null/empty.
- **No regression:** cart single-shop enforcement, per-shop order creation, the
  total-mismatch guard, and the generated `subtotal` column are all unchanged;
  money representation (NUMERIC / double) is unchanged.

## Out of scope (YAGNI)

- Mixed-currency carts (cart is hard single-shop — impossible by construction).
- Dart-side integer minor-units migration (display layer; non-authoritative).
- Currency conversion / FX (orders are placed in the shop's own currency).
- Changing the payment-provider minor-units boundary (already correct).
