# Phase 10 Plan Re-Check

## Verdict
PASS

## Fix verification

### Fix 1 — HINT on invalid_min_lost
APPLIED — bullet #4 at `10-PLAN.md:78` explicitly states: "Add `HINT = 'RANGE_1_50'` to the `invalid_min_lost` exception in the offenders RPC." Names the HINT value and the exception by name.

### Fix 2 — Authz-first ordering
APPLIED — bullet #5 at `10-PLAN.md:80` states: "Re-order all three RPCs to authz-first, range-second, matching the hardening template (`supabase/migrations/20260603001500_harden_dashboard_rpcs.sql:44-59`)." Cites the template line range and follows with explicit ordering rule: ownership check must run before any `RAISE EXCEPTION 'invalid_*'`.

### Fix 3 — Classifier operator pinned
APPLIED — `10-PLAN.md:188-193` enumerates all four cases:
- `rate == null ⇒ healthy`
- `rate <= healthyMax (0.07) ⇒ healthy`
- `rate <= watchMax (0.12) ⇒ watch`
- `else ⇒ hot`

Followed by explicit "Use `<=`, not `<`." with IEEE-754 stability rationale at line 193.

### Fix 4 — Task 5.4 split
APPLIED correctly.
- Task 5.4a at `10-PLAN.md:212-219` — Breakdown + Repeat offenders, 75 min ✓
- Task 5.4b at `10-PLAN.md:221-227` — By weekday, 45 min ✓
- §5 rollup at `10-PLAN.md:406` shows tasks "5.1, 5.2, 5.3, 5.4a, 5.4b | 290" — math: 20+90+60+75+45 = 290 ✓
- Grand total at `10-PLAN.md:410`: 830 min. Verified: 120+30+60+110+290+15+165+40 = 830 ✓
- Note: the grand-total line reads "830 min ≈ 13.8h" and "~1.7 engineering days" — the prior plan's "1.5 days" framing was updated to reflect the recomputed total.
- Defer clause at `10-PLAN.md:412` references "Task 5.4b (By weekday tab, 45 min)" ✓

## Collateral damage scan
None. Spot-checked task IDs, file paths, RESEARCH citations, checklist refs, risk register, rollout/rollback, and definition-of-done — all unchanged from prior check except where required by the four fixes. The "If pressed for time, defer" line was updated only to swap the old "5.4 By weekday sub-tab" reference for the new "Task 5.4b" ID, consistent with Fix 4.

## RECHECK COMPLETE
