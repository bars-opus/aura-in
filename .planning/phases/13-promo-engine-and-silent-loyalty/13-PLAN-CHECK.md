# Phase 13 PLAN-CHECK

**Verdict: PASS-WITH-NOTES**

The plan will deliver all 9 SPEC success criteria. Hard constraints are honored. Wave ordering is sound. Three correctness defects in the smoke SQL and one CHECK-constraint logic gap should be tightened before execution but none block goal achievement; the executor can fix them in-line during Wave 5 / Wave 0.

---

## Goal-backward — 9 success criteria → tasks

| SC | Owner-observable outcome | Task(s) |
|----|--------------------------|---------|
| 1 | SUMMER10 per-shop; cross-shop invisible | 0.1 (RLS swap + per-shop UNIQUE), 3.4 (PromotionsScreen), smoke §A |
| 2 | Client enters code → total updates, fee recomputed | 1.2 validate RPC, 4.1 ClientPromoCodeField + fee recompute, smoke §B |
| 3 | Same client 2nd attempt → PromoMaxRedemptionsException | 1.2 per_client_max check, 3.1 PromoPerClientMaxException, smoke §D |
| 4 | Loyalty rule + 6th completion → loyalty row appears | 0.2 loyalty_rules, 1.3 upsert, 1.4 generate, 1.6 trigger, smoke §I |
| 5 | 7th booking auto-applies on mount, no badge | 1.2 NULL-code branch, 4.1 on-mount call, smoke §F |
| 6 | recovery_checkin body contains a real code | 1.5 generate_recovery_code, 1.7 helper patch, 6.1 v2 template, smoke §J |
| 7 | Expired / not-found / wrong-service rejections | 1.2 HINT branches, 3.1 exceptions, smoke §C + §E |
| 8 | Re-validate same input → same result, no side effects | 1.2 read-only contract, smoke §H/§I idempotency |
| 9 | redeem twice → 1 row | 1.1 ON CONFLICT DO NOTHING, smoke §H |

All 9 trace to executable tasks. **PASS** on coverage.

---

## Hard constraint enforcement

1. EXTEND existing tables — PASS. PLAN.md L26 explicitly drops the `promo_codes` / `promo_redemptions` parallel-schema plan. Wave 0 only ALTERs `promotions` + `promotion_redemptions` (L156–230).
2. REUSE `redeem_promotion` — PASS. L27 drops `record_promo_redemption`. Migration §3 (L322–383) CREATE OR REPLACEs the existing RPC, body byte-for-byte from `20260604000400` plus one column.
3. Per-shop UNIQUE replaces global — PASS. L192 `DROP CONSTRAINT IF EXISTS promotions_code_key`, L194 `CREATE UNIQUE INDEX promotions_shop_code_unique ... (shop_id, UPPER(code)) WHERE archived_at IS NULL`.
4. `promotion_redemptions.user_id` nullable + `guest_profile_id` added — PASS. L205–208.
5. Pre-flight duplicate check is BLOCKING — PASS. L110–120 + Task 0.0 acceptance L870 "BLOCK migration deployment if check 4 returns any rows". Smoke header L130 also documents.
6. `redeem_promotion` REVOKE — PASS. L377 inside Wave 1 migration; Task 0.3 (L888–892) documents the timing rationale.
7. `recovery_checkin_v2` is the helper's new target — PASS. L829–833 template switch CASE; L830 explicit `'recovery_checkin_v2'`.
8. 30-day recovery TTL, NULL/sentinel loyalty TTL — PASS. L677 `now() + INTERVAL '10 years'` (loyalty); L747 `now() + INTERVAL '30 days'` (recovery). Note: SPEC §Definitions L106 says `valid_until = NULL` for loyalty; plan uses 10-year sentinel instead. Justified at L919 ("no-expiry sentinel") and locked at L1198. Allows the validate RPC's `valid_to > now()` predicate (L435) to function uniformly. Accept.
9. Highest-discount tiebreak + sooner-expiring secondary — PASS. L442–449 `ORDER BY CASE ... DESC, p.valid_to ASC LIMIT 1`.
10. Recovery reuses shop's active loyalty rule — PASS. L732–736; returns NULL when no rule (L734–736), no hardcoded fallback.
11. Platform fee recomputes against `new_total` — PASS server-side (validate returns `new_total`, L536). PASS client-side: L1025 `_discountedTotal * paymentConfigProvider.platformFeeFraction`. Note: trust model is "client sends, webhook trusts" (L35, R9 L1149) — carry-over from Phase 11, locked.
12. Webhook integration via `pending_payments.booking_data` — PASS. L960 `bookingData.promotionId` (not `metadata.promotionId`). Task 2.2 description (L956–971) explicit on four insertion points.
13. Every new RPC: authz-first + HINT + REVOKE/GRANT + COMMENT — PASS for `validate_and_apply_promo` (L412–423 null-shape first, L463–522 HINTs, L541–545 REVOKE+GRANT+COMMENT), `upsert_loyalty_rule` (L572–578 authz first, L618–622), `generate_loyalty_code` (L685–689), `generate_recovery_code` (L755–758).
14. Typed exceptions via HINT, no string matching — PASS. Task 5.2 case (j) covers fallback; L1051 grep gate `'e\.toString().contains'` returns 0; L1219 same gate in Definition of done.
15. Loyalty trigger AFTER UPDATE OF status, idempotent — PASS. L811–814 `AFTER UPDATE OF status ... WHEN (NEW.status = 'completed')`; L775–777 explicit re-mark-as-completed early-return; helper's NOT EXISTS guard L659–664.

All 15 hard constraints PASS.

---

## Smoke SQL coverage — defects

Mapping holds (§A→SC1, §B→SC2, §C→SC7, §D→SC3, §E→SC7, §F→SC5, §G→authz, §H→SC9, §I→SC4+SC8, §J→SC6). However three smoke-script defects will trip on execution:

**WARNING 1 — §J PERFORM outside DO block (line 457 of smoke SQL).** `PERFORM public.enqueue_booking_reminder(...)` is invalid as a top-level statement. PL/pgSQL only. Must wrap in `DO $$ BEGIN PERFORM ...; END $$;` or call as `SELECT public.enqueue_booking_reminder(...);` — the function returns void so `SELECT` works. Fix: change L457 to `SELECT`.

**WARNING 2 — §B/§F treat `RETURNS TABLE` as scalar (smoke L88–104, L242–257).** `validate_and_apply_promo` returns TABLE(promotion_id, code, amount_off, new_total, source) — multi-column. `result->>'amount_off'` only works if the result is a composite/JSON. The subquery `SELECT public.validate_and_apply_promo(...) AS result` will produce a record-typed column whose JSON cast is undefined in the SQL editor. Fix: `SELECT * FROM public.validate_and_apply_promo(...)` and read columns directly (`WHERE amount_off = 10`).

**WARNING 3 — §I doesn't trigger.** Smoke L367–379 INSERTs two bookings with `status='completed'` directly. The trigger is `AFTER UPDATE OF status WHEN (NEW.status='completed')` — INSERTs do NOT fire it. The visit-count query (L786–793 of plan) counts all completed rows including those two, so the L394 UPDATE on `a3` will correctly fire on the 3rd visit. Behavior is right by accident. But the §I comment claims "2 prior completed bookings, no loyalty code yet" — to assert that explicitly, add a SELECT COUNT after the two INSERTs proving zero loyalty codes exist, before the UPDATE. Otherwise §I appears to pass even if the trigger fires too eagerly on INSERT in a future refactor.

**BLOCKER 4 — `promotion_redemptions_identity_check` is wrong (plan L216–222).** The CHECK reads `(user_id IS NULL) OR (guest_profile_id IS NULL)` — this allows BOTH NULL (intended per L99 "possibly neither") AND rejects only the BOTH-NOT-NULL case. That is correct logic, but SPEC §99 says "at most one ... non-null" which matches. False alarm; **NOT a blocker**. Withdrawn.

**WARNING 4 — Smoke §A pre-condition assumes `archived_at IS NULL` semantics on the partial-unique BEFORE the migration runs.** The pre-flight query at plan L114–115 has the comment `archived_at IS NULL OR archived_at IS NULL  -- archived_at not yet present`. Will fail with `column archived_at does not exist` against the pre-Wave-0 prod DB. Fix: drop the WHERE clause on the pre-flight query (it's running against the global UNIQUE, which doesn't care about archived_at):
```sql
SELECT UPPER(code) AS code_text, COUNT(*) AS shop_count, array_agg(shop_id) AS shops
FROM public.promotions
GROUP BY UPPER(code) HAVING COUNT(*) > 1;
```

**WARNING 5 — §I bookings missing required NOT NULL columns.** `bookings` schema in prod has many NOT NULL columns (payment_method, etc., per recent git log). The minimal INSERT at L367–379 will fail unless every NOT NULL column has a default. Fix: add `payment_method`, `payment_status`, plus any other NOT-NULL-no-default fields, or pre-flight against an actual `\d bookings` output.

---

## Dependency ordering

- Wave 0 schema BEFORE Wave 1 RPCs — PASS. Migrations 000000/000100 strictly precede 000200–000800 by timestamp; rollout L1159–1168 lists them in order.
- Wave 1 RPCs BEFORE Wave 2 webhook patches — PASS. Rollout step 3 deploys SQL; step 4 ships webhooks.
- Wave 1 BEFORE Wave 4 checkout — PASS. Wave 4 task 4.1 (L1021) explicitly depends on Task 1.2.
- Pre-flight BLOCKS Wave 0 — PASS. Task 0.0 acceptance L870.
- `recovery_checkin_v2` Meta submission (Task 6.1) doesn't block Wave 2 — PASS. Rollout step 1 (L1157) submits to Meta ≥12h before SQL; worker's 6h retry covers approval window (L1089, R6 L1146).

---

## Style + risk

- Voice matches Phase 12 (terse, file-path-led). PASS.
- Risk register populated with 11 entries, P0/P1/M/L severities, each mitigated. PASS.
- Definition of done is grep-checkable: 10 grep gates + 1 psql gate (L1215–1226). PASS.

---

## Required fixes before execution

1. **Smoke §J L457** — replace `PERFORM` with `SELECT` (or wrap in `DO`).
2. **Smoke §B L96–103 + §F L249–256** — change scalar→column form: `SELECT amount_off, new_total, promotion_id FROM public.validate_and_apply_promo(...)`.
3. **Pre-flight check 4 L113–117** — drop the `WHERE archived_at IS NULL OR archived_at IS NULL` clause; the global UNIQUE pre-condition runs against rows that don't yet have that column.
4. **Smoke §I bookings INSERT L367–390** — pre-check `\d bookings` for NOT NULL columns and add `payment_method` / `payment_status` defaults.
5. **Smoke §I** — add `SELECT COUNT(*) FROM promotions WHERE source='loyalty' AND target_user_id=...` between the two INSERTs and the UPDATE, asserting 0 — to lock the "trigger fires on UPDATE only, not on INSERT" guarantee explicitly.

None block goal achievement; all five are mechanical edits the executor can apply during Task 5.4. Plan otherwise approves for execution.

---

## Conclusion

PASS-WITH-NOTES. Goal is achievable; all 15 hard constraints honored; ordering correct; risk register complete. Five mechanical defects in the smoke SQL need fixing during Wave 5 — none change task scope or wave structure. Executor proceeds.
