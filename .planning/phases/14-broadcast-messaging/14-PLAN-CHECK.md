# Phase 14 PLAN check

**Verdict: PASS-WITH-NOTES**

All 10 SPEC success criteria trace to executable tasks. All 20 hard constraints are honored at the SQL/Dart contract level. Dependency ordering is correct. Smoke SQL covers every locked decision. The notes below are smoke-script execution-environment gaps and one minor matrix typo — none of them affect the merge-time correctness of the RPCs or RLS.

---

## Goal-backward — 10 SPEC success criteria

| SC | Plan task | Status |
|----|-----------|--------|
| 1 Tools → Broadcasts → "+" opens form | 2.3 + 2.4 + 2.5 + widget test 4.3 | covered |
| 2 Preview > 0 default All clients | 2.4 + smoke §A | covered |
| 3 By service reveals service dropdown | 2.4 + widget test 4.3 | covered |
| 4 Lapsed = 0 for fresh shop | smoke §B + 1.1 | covered (B's `by_service` assertion is soft — see Note 2) |
| 5 Promo dropdown filter + confirmation copy | 2.4 + smoke §C | covered |
| 6 Send → broadcasts row with delivered_at + recipient_count | smoke §E + 1.2 | covered |
| 7 Same-day re-send → rate limit | smoke §F | covered |
| 8 Expired/archived promo → PROMO_NOT_VALID | smoke §D | covered |
| 9 scheduled_notifications channels correct | smoke §E + §I | covered |
| 10 accepts_marketing=FALSE excluded | smoke §J | covered |

No criterion is unreachable.

---

## Hard constraints (20 locked decisions)

| # | Constraint | Where enforced | OK |
|---|------------|----------------|----|
| 1 | Audience cap 1000 server-enforced before fan-out | RPC §10a lines 411–453 | ✓ |
| 2 | Promo source = 'owner_defined' | RPC §7 line 392 | ✓ |
| 3 | Lapsed STRICT IN ('confirmed','completed') | RPC §10a line 434; preview line 275 | ✓ |
| 4 | All-clients = status != 'pending' | preview line 261; RPC §10a line 420 | ✓ |
| 5 | WhatsApp template body locked | Wave 0 Task 0.1 line 846 + jsonb params line 510 | ✓ |
| 6 | 4-status enum | table CHECK line 183 | ✓ |
| 7 | Subject 100 / body 800 CHECKs | table CHECK lines 172–173 + RPC §3 lines 340, 344 | ✓ (defense-in-depth) |
| 8 | UTC day rate limit via date_trunc AT TIME ZONE 'UTC' | RPC §6 lines 374–375 | ✓ |
| 9 | Advisory lock at top of send_broadcast | RPC §1 line 326 | ✓ |
| 10 | Recipient dedup COALESCE(user_id::text, guest_profile_id::text) | RPC §10a line 417; §10b line 460 | ✓ |
| 11 | enqueue_booking_reminder NOT reused | RPC fan-out is direct INSERT INTO scheduled_notifications lines 494–527 | ✓ |
| 12 | Worker NOT modified | "NOT TOUCHED" line 79 + no edge function tasks | ✓ |
| 13 | Broadcasts immutable (SELECT + INSERT only — actually SELECT only via RLS; INSERT via SECURITY DEFINER bypass) | migration lines 195–207 | ✓ |
| 14 | guest_profiles.accepts_marketing column + fan-out gate | migration §2 + RPC filtered CTE line 488–492 | ✓ |
| 15 | REVOKE FROM authenticated THEN GRANT EXECUTE | lines 295–297, 540–542 | ✓ |
| 16 | HINT-based typed exceptions | classifier table line 612 | ✓ |
| 17 | PromotionsRepository extended, no new file | "EDIT" line 69 + Task 2.2 | ✓ |
| 18 | EN-only i18n | Task 3.1 + line 22 | ✓ |
| 19 | LoyaltyRuleScreen precedent for CreateBroadcastScreen | line 739 | ✓ |
| 20 | Phase 13.1 _PromotionRow pattern for list rows | line 720 (`_BroadcastRow` mirrors `_PromotionRow`) | ✓ |

---

## Smoke SQL coverage

Every section maps to a SPEC criterion or hard constraint (§A→SC2, §B→SC3/SC4, §C→#2, §D→SC8, §E→SC6/SC9, §F→SC7, §G→#9, §H→#1, §I→#10, §J→SC10, §K→#13 read side, §L→#13 write side). Contract coverage is complete.

---

## Dependency ordering

Wave 0 (schema + Meta) → Wave 1 (RPCs) → Wave 2 (client) → Wave 3 (i18n) → Wave 4 (tests) → Wave 5 (UAT). Migration timestamps strictly ascending (lines 49–53). Meta submission in Wave 0 with worker 6h defer covering approval gap — does NOT block PR per line 847. Correct.

---

## Notes (recommended tightenings, non-blocking)

**Note 1 — Smoke §K and §L do not actually exercise RLS (lines 512, 526, 543).**
The script uses `SET LOCAL "request.jwt.claims"` but never `SET LOCAL ROLE authenticated`. As superuser/postgres, RLS is bypassed and `auth.uid()` is NULL. §K will return 0 rows (because of the WHERE on shop_id, not because of RLS) and §L's UPDATE/DELETE will succeed silently (and be rolled back by the SAVEPOINT). Fix: add `SET LOCAL ROLE authenticated;` after each `request.jwt.claims` line. Both checks then exercise the actual RLS path. The Phase 13 smoke precedent likely has the same pattern; reuse it.

**Note 2 — Smoke §H (1000 cap) will FK-violate on `bookings.user_id` (lines 386–393).**
The loop synthesises 1001 UUIDs that do not exist in `auth.users`. If `bookings.user_id` has an FK to `auth.users(id)` (high likelihood given the rest of the schema uses `REFERENCES auth.users`), every insert raises 23503. Fix: either seed `auth.users` first, or change the cap smoke to use `guest_profile_id` (insert 1001 guest_profiles, all `accepts_marketing=TRUE`). Guest path also gives broader coverage since the cap check runs after the accepts_marketing filter.

**Note 3 — Smoke §B `by_service` is asserted softly (line 114–115, 137).**
The script inserts the booking but omits the `booking_services` row joining slot_a. The `v_by_service` assertion is not enforced. Either add the booking_services insert or drop the by_service line from §B and rely on a dedicated §B2.

**Note 4 — Verification matrix SC 5 references a smoke section the file does not have (line 995).**
The matrix says "promo filter widget test" — fine — but ties it to §C/§D for source/expired rejection. SC5 is actually "owner attaches a promo and confirmation shows the code", which is only covered by widget test 4.3. The matrix conflates the client-side filter with the server-side validation. Cosmetic; both behaviors are tested.

**Note 5 — §G advisory lock smoke is self-documented as not running the real race (line 374).**
Acceptable for a single-session smoke, but the cross-session harness mentioned should be a follow-up checklist item in the PR description, not just a NOTICE. Same-second double-tap is a real failure mode; the rate limit covers the long tail.

**Note 6 — Plan line 5 prose says "no INSERT/UPDATE/DELETE RLS policies."**
Strictly speaking the migration has no INSERT policy either — correct, because INSERTs flow through SECURITY DEFINER and bypass RLS. The Goal line could clarify "SELECT-only RLS, all mutations via SECURITY DEFINER" to match the migration comment on line 204–206. Cosmetic.

---

## Style + risk

- Voice matches Phase 13 PLAN.md — terse, file-path-led, RESEARCH §-cited. ✓
- Risk register populated and updated vs SPEC. ✓
- Definition of done is grep-checkable (every task has File(s) + Acceptance + Rollback + Estimate). ✓
- Pre-flight gating is explicit and blocking. ✓

---

## Required follow-ups before execution

1. Fix smoke §K and §L to `SET LOCAL ROLE authenticated` so RLS actually filters.
2. Fix smoke §H to use guest_profiles (or seed auth.users) so the 1001-row insert doesn't FK-violate.
3. Add booking_services insert to smoke §B or split the by_service case to §B2.

These three are smoke-script hygiene. The RPC contracts, migrations, RLS, client surface, and dependency wiring are correct and execution can proceed as soon as these smoke fixes are applied (they're inside Task 4.4 — fix in-place, no plan rev needed).

