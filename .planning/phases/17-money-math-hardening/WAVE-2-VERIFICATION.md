# Phase 17 Wave 2 — Server RPC contract verification

**Date:** 2026-06-13
**Outcome:** No DDL changes required. Every money-emitting / money-accepting
RPC keeps its NUMERIC(12,2) contract. Dart-side does boundary conversion via
`parseMoneyMinor` at every repository read (Wave 5). The server-side trust
boundary now has exact int-kobo validation post-Wave-1.

## Verified contracts

| RPC | Parameter / Return shape | Verdict |
|-----|-------------------------|---------|
| `validate_and_apply_promo` | TABLE `amount_off NUMERIC, new_total NUMERIC, promotion_id UUID, ...` | UNCHANGED. Wave 5 boundary-converts amount_off + new_total via `parseMoneyMinor` in `promotions_repository.dart`. |
| `redeem_promotion(...p_discount_amount NUMERIC)` | Param NUMERIC; returns UUID | UNCHANGED. Edge function webhooks already pass `bookingData.promoAmountOff` (NUMERIC). |
| `generate_available_slots` | RETURN TABLE `price NUMERIC, base_price NUMERIC, ...` | UNCHANGED. Wave 3.2 + 5.3 boundary-converts in `time_slot_model.dart` fromJson via `parseMoneyMinor`. |
| `create_pricing_override(p_value NUMERIC)` | Param NUMERIC; returns UUID | UNCHANGED. Owner UI passes NUMERIC cedis-major for fixed_* kinds; percent kinds carry 0–100 (not money). |
| `update_pricing_override(p_value NUMERIC)` | Same as create. | UNCHANGED. |
| `add_wallet_transaction(p_amount NUMERIC, ...)` | Param NUMERIC; returns UUID | UNCHANGED. Edge function webhooks (paystack-webhook line 359, stripe-webhook line 426) divide `netAmountMinor / 100` at the call site. Dart wallet repo will do the same on the way out. |
| `request_withdrawal` (if exists) | Inferred NUMERIC; spot-check pending | Verified below. |
| `generate_daily_report` | RETURN UUID; emits `revenue_minor` BIGINT inside JSONB payload | ALREADY KOBO. Phase 16 emitted bigint kobo inside the JSONB payload; no change. |
| `list_daily_reports` | RETURN TABLE `revenue_minor BIGINT, ...` | ALREADY KOBO. Phase 16 emits bigint kobo as a column. No change. |

## Spot-check: request_withdrawal

```bash
$ grep -l "request_withdrawal\b" supabase/migrations/*.sql
```

Two definitions found:
- `20260603000300_backfill_create_withdrawal_request.sql` — `p_amount NUMERIC`, returns UUID
- `20260603001000_consolidate_wallets.sql` — re-CREATE OR REPLACE; same signature

Verdict: NUMERIC. Dart wallet repo boundary-converts in Wave 5.5.

## Net architectural decision

The server-side stays NUMERIC end-to-end. The Dart client owns the int-kobo
representation in memory and on the wire. Boundary conversion happens at:
- **Inbound (server → client):** Dart repository unmarshalling via `parseMoneyMinor((row['col'] as num))`.
- **Outbound (client → edge function):** Dart sends int kobo under `*Minor` keys; edge function normalizes via `sanitizeAmountMinor`.

Storage is permanently major-unit NUMERIC; the wire and the in-memory math are
permanently int minor. The two boundaries are codified and easy to grep.

## What happens when a future feature adds a new money column

New money column → new RPC return → new repository boundary in Dart →
`parseMoneyMinor` at the read site → new model field typed `int *Minor`. The
pattern is mechanical from here.
