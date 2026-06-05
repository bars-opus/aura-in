# Phase 12 PLAN-CHECK

**Verdict: PASS-WITH-NOTES**

Plan delivers SPEC outcome end-to-end. All 4 proof obligations covered by smoke. All 7 hard constraints met. Ordering is correct. Three tightenings recommended below.

## Goal-backward: 8 SPEC success criteria → tasks

| # | Criterion (SPEC §Success criteria L237-254) | Covering task(s) | Verified by |
|---|--------------------------------------------|------------------|-------------|
| 1 | Confirmed booking 26h out → 2 pending reminder rows | Task 1.4 (trigger, PLAN L717-722) + Task 1.2 (helper, PLAN L703-708) | Smoke §A (sql L30-62) |
| 2 | Cancel → reminders→cancelled + recovery_checkin at +7d | Task 1.5 (PLAN L724-729) + Task 1.3 (PLAN L710-715) | Smoke §B (sql L64-119) |
| 3 | Complete → reminders→cancelled + review_request at +2h | Task 1.5 + Task 1.3 | Smoke §C (sql L121-170) |
| 4 | enqueue_rebook_nudges idempotent same-day | Task 3.1 (PLAN L756-761) | Smoke §I (sql L313-365) |
| 5 | Shop with <5 samples → default 30d cadence | Task 0.3 (PLAN L687-692, default branch in MV L247-248) | Acceptance line L690 ("0 completed → 30") |
| 6 | Owner sees note; other owner gets denied/empty | Task 0.2 (RLS, PLAN L680-685) + Task 1.1 (RPC authz, L696-701) | Smoke §D (sql L172-222) |
| 7 | Note persists across future bookings for same client | Task 4.4 (provider keyed on shopId+identity, NOT bookingId — PLAN L800-804) + Task 4.6 (L821-832) | UAT Task 6.2 step 5 (PLAN L886) |
| 8 | Guest bookings get reminder flow via WhatsApp | Task 1.2 channel-branch (PLAN L703-708, MIG §5 L305-319) | Smoke §J (sql L367-456) |

All 8 criteria trace to executable tasks. No gaps.

## Hard constraints (7/7 met)

1. **Reminder consolidation: trigger + webhook diffs + backfill all present.** Trigger = Task 1.4. Webhook diffs at the exact SPEC line ranges = Task 2.2 (paystack 269-292, 524-543) and Task 2.3 (stripe 337-360, verify-payment 298). Backfill = Task 2.1. PASS.
2. **`client_for_booking` view absent.** PLAN L25 explicitly drops it; L823-831 reads identity from `booking.shopId / userId / guestProfileId` on the client. Plan-check item L973 asserts 0 matches. PASS.
3. **`notification_type` migration uses bare `ALTER TYPE ... ADD VALUE IF NOT EXISTS`** — no defensive DO block. PLAN L83-93. SPEC L259 confirmed enum 2026-06-05. PASS.
4. **Sticky-note widget: explicit Save, disabled when unchanged, no debounce.** PLAN L815 (disabled rule), L818 grep gate (`debounce|Timer.periodic|onChanged.*upsert` returns 0). PASS.
5. **Recovery messages contain no discount code.** PLAN L13, copy in MIG §5 L341 ("Book a new time whenever works for you") — no promo, no code. Plan-check item L981 asserts. PASS.
6. **WhatsApp template submission included.** Task 6.1 (PLAN L877-882). Submission BEFORE migrations land (Rollout step 1, L938). PASS.
7. **Every new RPC: authz-first + HINT + REVOKE/GRANT + COMMENT.** Verified inline:
   - `upsert_client_note` (MIG §3 L157-216): authz L170-177, HINTs L182/L187/L192, REVOKE/GRANT L213-214, COMMENT L215.
   - `enqueue_booking_reminder` (MIG §5 L282-376): SECURITY DEFINER L287, no auth needed (internal), REVOKE L373, COMMENT L375. PASS (no GRANT to authenticated is intentional — cron/trigger-only).
   - `cancel_and_followup` (MIG §6 L384-421): validation L391-394, REVOKE L419, COMMENT L420. PASS.
   - `enqueue_rebook_nudges` (MIG §10 L566-651): REVOKE L648, COMMENT L650. Cron-only — no authz path needed. PASS.
   - Three modified terminal RPCs (Task 1.5 L724-729): existing authz preserved + REVOKE/GRANT/COMMENT re-applied per Migration Plan §8 (PLAN L478-486). PASS.
8. **Client error mapping: typed exceptions only.** Task 4.3 (PLAN L777-798) explicitly bans `e.toString().contains` (L796). Grep gate L999. PASS.

## Smoke SQL coverage (4/4 proof obligations)

| Obligation | Smoke section | Lines |
|-----------|---------------|-------|
| (a) Trigger schedules 2 rows for 26h-out confirmed | §A | sql L30-62 |
| (b) Status flip cancels reminders + adds followup | §B (cancel→recovery), §C (complete→review) | sql L64-170 |
| (c) `enqueue_rebook_nudges` idempotent same-day | §I | sql L313-365 |
| (d) Sticky-note RLS denies another shop's owner | §D | sql L172-222 |

Plus bonus coverage: §E-§H (upsert authz + payload), §J (channel branching). PASS.

## Dependency ordering

PLAN §Rollout L939-949 places migrations in strict timestamp order: trigger (Task 1.4, ts 120600) → wire terminal RPCs (1.5, ts 120700) → backfill (2.1, ts 120800) → webhook diffs (2.2/2.3, edge-fn deploy AFTER SQL). PASS.

Critical check: backfill (120800) lands AFTER trigger (120600). PLAN L500-504 explains why: "Migration 7 makes the trigger the SINGLE source; without backfill, bookings confirmed BEFORE the trigger landed but AFTER the webhook write would silently lose their 24h reminder." Correct.

R1 in risk register (PLAN L923) explicitly addresses the ordering hazard — "SQL migrations first → backfill → webhook diffs in SAME release window. Backfill is idempotent — safe to re-run."

## Style + risk

- Voice matches Phase 11 (terse, file-path-led, lines-cited). PLAN follows the same §Goal / §Out of scope / §Files touched / §Migration plan / §Tasks / §Risk register / §Rollout / §Definition of done structure.
- Risk register (10 entries L922-932) is populated and actionable.
- Definition of done (L985-1004) is grep-checkable.

## Notes (3 tightenings, non-blocking)

**N1. Trigger SECURITY DEFINER + search_path interacts with webhook UPDATEs from anon role.** PLAN L431-432 sets `SECURITY DEFINER SET search_path = public` on `schedule_booking_reminders`. The paystack-webhook performs raw UPDATEs to `bookings.status` using the service-role key — that path fires the trigger as the service role. Confirm in UAT (Task 6.2 step 1) that a webhook-driven status flip to `confirmed` actually fires the trigger and writes both reminder rows. The trigger is `AFTER UPDATE OF status ... WHEN (NEW.status = 'confirmed')` (L464-468), which should work, but a webhook-initiated flow is the path that matters for prod. Add to Task 6.2 acceptance: "Step 1 must be initiated via a real payment webhook, not a direct SQL INSERT."

**N2. `cancel_and_followup` swallows `unique_violation` but `recovery_checkin` is never going to hit the cooldown index on a fresh cancel.** PLAN L407-414 wraps the `recovery_checkin` insert in `BEGIN ... EXCEPTION WHEN unique_violation`. The partial unique index (Task 3.1 L556-564) covers `recovery_checkin` for the same `(shop_id, client, date)`. The exception only matters if the same booking is cancelled twice on the same day — rare but possible (un-cancel → re-cancel). Acceptable as defence in depth, but the COMMENT (L420) could explicitly call out this edge case. Tightening: add "covers re-cancellation idempotency" to the COMMENT.

**N3. Task 1.5 mutates three existing RPCs with `CREATE OR REPLACE` by copying their bodies verbatim. PLAN L486 omits the bodies "for length".** This is the highest-bug-risk task — a subtle drift between the migration-7 copy of the original body and the live `20260517020000_booking_hardening.sql:393-440` body would silently regress existing booking behavior. Tightening: before merging Task 1.5, run `diff <(sed -n '393,440p' supabase/migrations/20260517020000_booking_hardening.sql) <(sed -n '<new-line-range>' supabase/migrations/20260605120700_wire_terminal_rpcs.sql)` and verify the only delta is the single `PERFORM public.cancel_and_followup(...)` line + the REVOKE/GRANT/COMMENT trio. Add this diff check to the Definition of done grep gates.

## Files relevant to this check

- /Users/user/nano_embryo/.planning/phases/12-autonomous-retention-engine/12-PLAN-CHECK.md (this file)
- /Users/user/nano_embryo/.planning/phases/12-autonomous-retention-engine/12-PLAN.md
- /Users/user/nano_embryo/.planning/phases/12-autonomous-retention-engine/12-SPEC.md
- /Users/user/nano_embryo/.planning/phases/12-autonomous-retention-engine/12-RESEARCH.md
- /Users/user/nano_embryo/.planning/phases/12-autonomous-retention-engine/sql/12_smoke_tests.sql
