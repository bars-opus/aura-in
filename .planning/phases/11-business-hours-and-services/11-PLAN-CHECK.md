# Phase 11 Plan Check

## Verdict
PASS-WITH-FIXES

## Summary
The plan delivers every SPEC outcome end-to-end and applies every locked correction the research called out. RPC bodies are hardened byte-for-byte against `20260603001500_harden_dashboard_rpcs.sql`, the cascade covers all seven surfaces, and atomicity is proven by smoke §f plus airplane-mode UAT 10.1 step 5. Three real defects keep this off a clean PASS: (1) Task 1.2's smoke §f atomicity proof relies on a "test wrapper that injects RAISE EXCEPTION between DELETE and INSERT" that cannot be implemented without modifying the function under test (11-PLAN.md:237, 465), (2) Tasks 1.4 and 1.5 specify body bodies for cascade surfaces 1 and 4 ("create_booking_with_conflict_check" and freelancer RPC) that raise `archived_slot` AFTER the SELECT but the existing function bodies perform downstream work that may execute before the raise depending on existing control flow — the plan does not show where the new IF block lands (11-PLAN.md:250, 257), and (3) the `_selectedDaysProvider` top-level `StateProvider` carry-over is acknowledged in R9 but NOT added to the formal `### Out of scope (carry-over bugs)` list at the top of the plan, contradicting locked correction 11 which requires exactly four items there (11-PLAN.md:20-28 vs R9 at 538). All three are mechanical to fix.

## Findings

### Goal achievement
PASS. All four SPEC outcomes are covered:
- (a) BusinessHoursScreen + atomic RPC save: Tasks 1.2, 5.1, 5.2, 4.2 (11-PLAN.md:234-239, 335-367).
- (b) ServiceManagementScreen with edit/add/archive: Tasks 7.1, 7.2, 1.3, 6.1 (11-PLAN.md:383-395, 241-246, 371-379).
- (c) Booking pipeline honors archived slots across all six SQL surfaces + edge function: Tasks 1.4, 1.5, 1.6, 2.1 (11-PLAN.md:248-276). Specifically: surfaces 1-6 enumerated at 11-PLAN.md:206-211; resolve-link at 11-PLAN.md:215.
- (d) tools_screen.dart Cards 4 and 5 routed to working screens: Task 8.1 (11-PLAN.md:399-403).

### Locked corrections from research applied
All eleven locked corrections present:
1. `opens_at` / `closes_at` TEXT, no `::TIME` cast — 11-PLAN.md:146-147, 156, 232 (RPC body and COMMENT both confirm).
2. `appointment_slots.archived_at` migration with partial index — 11-PLAN.md:76-85 (Task 1.1).
3. `is_active` NOT touched — 11-PLAN.md:73-74, 84, 607 (grep gate enforces zero `is_active` references in new screens).
4. Filter cascade covers all SEVEN surfaces (six SQL + resolve-link) on BOTH read and create — 11-PLAN.md:206-215. Specifically: read paths (`check_slot_availability`, three `generate_available_slots` variants, `resolve-link`) AND create paths (`create_booking_with_conflict_check` + freelancer RPC) both patched.
5. `day_of_week BETWEEN 0 AND 7` inclusive — 11-PLAN.md:127-135, 156.
6. `BusinessHoursEditController` separate from `HoursNotifier` — 11-PLAN.md:337-356 (Task 5.1) plus grep gate at 605 enforcing zero `shopCreationProvider`/`freelancerCreationProvider` refs.
7. `bufferMinutes: 15` hard-code fixed — 11-PLAN.md:375 (Task 6.1(b)) plus regression test Task 9.5 at 436-441.
8. `ServiceFormModal` refactored to take `availableHours` as constructor parameter — 11-PLAN.md:374 (Task 6.1(a)).
9. Both Coming Soon SnackBars dropped, `Snackbar` import KEPT — 11-PLAN.md:401-402 plus grep gate at 515 (`Snackbar` count ≥ 1 verifies retention).
10. Creation-flow loop bug deferred — 11-PLAN.md:27 (carry-over) and 108 (RESEARCH echo).
11. Carry-over bugs documented in §Out of scope — 11-PLAN.md:20-28 lists four items: day_of_week mismatch, `_parseTime`, analytics archive filter, creation-flow loop. **GAP**: research Finding 5 line 80 also flags `ServiceFormModal._selectedDaysProvider` as carry-over, and Risk R9 (11-PLAN.md:538) re-states this — but it is NOT in the four-item §Out of scope carry-over list at the top. Either move R9 to the carry-over list or strike R9.

### RPC hardening
PASS. Both new RPCs match `20260603001500_harden_dashboard_rpcs.sql` byte-for-byte where it matters:
- `LANGUAGE plpgsql SECURITY DEFINER SET search_path = public` — 11-PLAN.md:100, 167 (template 20260603001500:36-37, 117-118).
- Ownership gate FIRST via `EXISTS shops WHERE user_id = auth.uid()` — 11-PLAN.md:107-114, 177-185 (template 45-51, 125-131).
- `RAISE EXCEPTION 'not_found' USING ERRCODE = '42501'` — 11-PLAN.md:113, 184 (template 50, 130).
- `'invalid_input' / ERRCODE 22023 + HINT` — 11-PLAN.md:118-119, 123-124, 133-134, 173-174 (template 55-58, 134-135).
- `REVOKE ALL ... FROM PUBLIC; GRANT EXECUTE ... TO authenticated;` — 11-PLAN.md:153-154, 194-195 (template 105-106, 164-165).
- `COMMENT ON FUNCTION ... IS '... Big-O ...'` — 11-PLAN.md:155-156, 196-197 (template 107-108, 166-167). Both COMMENTs explicitly state Big-O ("O(1) — bounded at 7 rows per call" and "O(1)").

Cascade surfaces (Tasks 1.4-1.6) reuse the same trio per surface (11-PLAN.md:250, 257, 264). No deviations from the template found.

### Migration ordering + atomicity
Mostly PASS, with one defect.

- Timestamp order 000050 → 000100 → 000200 → 000300 holds (11-PLAN.md:34-37). Task 1.1 depends declared before Task 1.3 at 11-PLAN.md:243 ("Depends on Task 1.1").
- Atomicity-of-rollout for the cascade: claim is "one transaction, all six functions replaced or none." Postgres `CREATE OR REPLACE FUNCTION` is transactional when wrapped in a single migration file applied via `BEGIN;...COMMIT;`. Supabase migrations apply each `.sql` file inside an implicit transaction. So all six `CREATE OR REPLACE FUNCTION` statements in `20260605000300_archive_filter_cascade.sql` either all commit or all roll back. Claim holds.
- **DEFECT**: Smoke §f atomicity test at 11-PLAN.md:237 and 465 calls for a "test wrapper that injects `RAISE EXCEPTION` between DELETE and INSERT." There is no way to inject mid-function — the RPC body is sealed. To prove transactional atomicity you must either (a) write a separate test function `test_rebuild_with_failure` that runs `BEGIN; DELETE FROM shop_opening_hours WHERE shop_id = X; RAISE EXCEPTION 'forced'; ROLLBACK;` and verify row count, or (b) trigger atomicity by passing a payload that fails the INSERT after the DELETE completes (e.g., a payload that passes pre-validation but causes an INSERT-time constraint violation). Option (b) is harder because the validation is exhaustive. The plan must specify which approach §f uses; currently it specifies an impossible one.

### Checklist v3.1 coverage
PASS for everything SPEC + research named.

P0-U items present and mapped:
- 1.4 Authz → Tasks 1.2-1.6 (11-PLAN.md:545)
- 2.1 Input sanitization → Tasks 1.2, 1.3, 4.2 (549)
- 2.4 Error messages don't leak → Tasks 3.1, 3.2, 4.2, 5.2, 7.1, 7.2 (550)
- 2.5 Resource limits → Tasks 4.2 (`.limit(200)`), 1.2 (7-element cap) (551)
- 4.4 PII excluded from logs → Task 4.2 (`AppLogger.warn` only logs `fields:`) (557)
- 5.5 No internal info in UI → Tasks 3.1, 3.2, 4.2, 5.2, 7.1, 7.2 (560)

P1 items the research flagged:
- 1.6 Concurrency (BusinessHoursEditController scoping) → Task 5.1 (546)
- 1.10 Compensating tx → Tasks 1.2, 1.4, 7.1, 7.2 (548)
- 2.18 Idempotency → Task 1.3 (`WHERE archived_at IS NULL` makes re-archive a no-op) + smoke §i (553)
- 6.1, 6.2, 6.4 negative tests → Tasks 9.3 (b), 9.5, 9.6 (c, d) (561-563)

No uncovered P0-U or research-named P1.

NOT covered (and not required for this phase): 2.7-2.9 secret scans (no secrets touched), 2.19-2.23 financial (no money handled — explicitly stated at 554), 7.6 CSRF/CORS (mobile-only, per checklist v3.1 line 266).

### Atomicity and verifiability
Mostly PASS.
- Every task has a concrete done check via the "Acceptance" line.
- Tasks ordered for incremental verification (1.1 → 1.2 → 1.3 → 1.4-1.6 → 2.1 → 3.x → 4.x → 5.x → 6.x → 7.x → 8.x → 9.x → 10.x).
- DEFECT: Tasks 1.4 and 1.5 say "copy the current body of `<fn>` verbatim and insert `AND archived_at IS NULL` into the `SELECT ... WHERE id = p_slot_id` clause" and "after the SELECT, add: `IF v_name IS NULL THEN RAISE EXCEPTION ...`" (11-PLAN.md:250, 257). For `create_booking_with_conflict_check`, the SELECT at booking_schema.sql:542 may be followed by other statements (lookups, validation, conflict checks) before the eventual INSERT. The plan does not specify WHERE the new IF block lands — immediately after the SELECT (correct) or somewhere later (potentially still after side effects). The executor must place the IF block IMMEDIATELY after the SELECT, before any other statement, to honor the "archived-slot raise happens BEFORE any INSERT" claim at 11-PLAN.md:252. Add an explicit "place the IF block on the line directly following the SELECT, before any other statement" instruction to Tasks 1.4 and 1.5.

### Risk register
PASS — every entry is specific and reviewer-grade:
- R1 names the six-surface cascade and the failure mode (cosmetic archive + customer can book archived service). Mitigation is Task-level traceable (11-PLAN.md:530).
- R2 names bufferMinutes regression at line and pins it to a specific test (531).
- R3 names the TEXT vs TIME drift and the corruption mode (532).
- R5 specifically names the silent overwrite of the creation draft (534).
- R6 calls out the atomicity-claim-regression (a future reviewer "optimizing" the RPC into a Dart loop). This is a reviewer-grade observation rare to see in a plan.
- R10 specifically addresses the partial-cascade race using Postgres snapshot isolation semantics (539).

Two risks I expected and found: partial-cascade race (R1 + R10), bufferMinutes regression (R2), atomicity proof (R3 + R6).

### Out-of-scope discipline
Mostly PASS. The four formal carry-over items at 11-PLAN.md:20-28 are exactly the four locked correction 11 required (day_of_week, `_parseTime`, analytics filter, creation-flow loop).

Sneak-ins audit:
- `is_active`: locked correction 3 says "MUST NOT add code that sets or filters on `is_active`." Grep gate at 11-PLAN.md:607 enforces zero `is_active` refs in the two new screens. PASS.
- `_parseTime`: not touched anywhere in the plan. PASS.
- analytics archive filter: not touched. The dashboard analytics RPCs at 20260603000000:137 and 20260603001500:208 are explicitly NOT in the cascade list (11-PLAN.md:26). PASS.
- creation-flow loop: not touched. PASS.

DEFECT noted under "Locked corrections" item 11: R9 (the `_selectedDaysProvider` top-level StateProvider) appears in the Risk register at 11-PLAN.md:538 as an accepted carry-over but is missing from the formal §Out of scope carry-over list. This is the only sneak-in concern: R9 says it is "out of Phase 11 scope to refactor" but never declares the carry-over formally at the top.

### Effort honesty
PASS. Breakdown justifies the bump from ~12.3h to ~15.3h:
- 6 cascade surfaces × ~50 min/surface = ~5h vs SPEC's 2-surface 2.5h (~+2.5h)
- BusinessHoursEditController separate from HoursNotifier (locked correction 6) is genuinely new work not in SPEC (~50 min)
- bufferMinutes fix + regression test (locked correction 7) (~30 + 30 min)
- ServiceFormModal refactor to take hours param (locked correction 8) (~35 min)
- Smoke cases §j–§o split across 6 surfaces vs SPEC's 2 (~30 min additional)

Total justified delta: ~3h, which matches the 12.3 → 15.3 = +3h gap (11-PLAN.md:614). Breakdown traces to research findings, not padding.

## Required fixes before execution

1. **Task 1.2 smoke §f** (11-PLAN.md:237, 465) — atomicity proof references a "test wrapper that injects `RAISE EXCEPTION` between DELETE and INSERT." This cannot be implemented without modifying the function under test. Replace with one of:
   - (a) A separate `BEGIN; SELECT public.rebuild_shop_opening_hours(<shop>, <good payload>); INSERT INTO test_only_failure_token VALUES (1); INSERT INTO test_only_failure_token VALUES (1); ROLLBACK;` then assert `count(*)` on `shop_opening_hours` for that shop equals the pre-call count (since ROLLBACK undoes the rebuild as well as the duplicate-insert violation).
   - (b) A payload that passes RPC pre-validation but fails INSERT (e.g., legitimately encoded JSON that triggers a CHECK constraint or FK violation on shop_id, if any exist).
   Pick (a). It is straightforward and proves transactional atomicity without modifying the RPC.

2. **Tasks 1.4 and 1.5 IF-block placement** (11-PLAN.md:250, 257) — the plan says "after the SELECT, add: `IF v_name IS NULL THEN RAISE EXCEPTION ...`" but does not enforce "before any other statement." For `create_booking_with_conflict_check` (booking_schema.sql:542) and the freelancer booking RPC (booking_hardening.sql:338), the executor must place the IF block IMMEDIATELY on the line following the SELECT statement, before any subsequent variable assignment, conflict check, or INSERT. Append to both task descriptions: "The IF block MUST be on the line directly following the SELECT, before any other statement, to guarantee no side effects occur for an archived slot."

3. **Locked correction 11 — `_selectedDaysProvider` carry-over** (11-PLAN.md:20-28 + 538). Either:
   - (a) Add a fifth bullet to §Out of scope (carry-over bugs): "`ServiceFormModal._selectedDaysProvider` top-level `StateProvider`. A second simultaneously-open modal would inherit the previous modal's selection until the `Future.microtask` reset in `initState` fires. Modals are non-stacking in current UX so this is unreachable in practice. Out of Phase 11 scope to refactor into a Riverpod family. (RESEARCH Finding 5 line 80.)"
   - (b) Strike Risk R9 from the register on the grounds that it is unreachable in current UX.
   Pick (a) — it is consistent with how the other carry-overs are documented.

## Optional improvements

1. Task 1.2's smoke §e at 11-PLAN.md:237 should also assert that the inserted rows' `opens_at` value, when round-tripped through `SELECT opens_at FROM shop_opening_hours WHERE shop_id = X`, equals the input `"09:00 AM"` byte-for-byte. Currently §e says "TEXT values intact" but the verification doesn't pin the exact byte sequence; a future schema change to `TIME` would silently break this without §e failing.

2. The grep gate at 11-PLAN.md:609 (`grep -c 'archived_at IS NULL' ... | returns at least 6`) is a one-sided assertion. Consider also asserting `≤ 8` (one predicate per surface + a few in COMMENT bodies is plausible) to detect accidental duplication that might indicate an executor pasted a body twice. Non-blocking — the upper bound is hard to fix exactly.

3. Risk R10 (snapshot isolation) is technically correct for default `READ COMMITTED` Postgres but could be made more concrete by naming the isolation level explicitly: "Postgres `READ COMMITTED` default + SECURITY DEFINER single-tx makes this safe." Adds zero risk surface; just clarity for the future reviewer.

4. Consider adding to Task 5.1 (BusinessHoursEditController) an explicit `_load()` debounce or single-flight guard. If a user rapidly taps Discard, two concurrent `getShopDetails` calls fire and the later one might overwrite a half-edited state if Discard is allowed mid-`save()`. Non-blocking — current UX has Discard pop the screen so the race is unreachable, but the controller should be defensive.

## PLAN CHECK COMPLETE
