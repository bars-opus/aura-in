# Phase 10 Plan Check

## Verdict
PASS-WITH-FIXES

## Summary
The plan demonstrates strong goal-backward discipline: it restates the SPEC outcome at `10-PLAN.md:8-10`, calls out scope exclusions explicitly at `10-PLAN.md:12-21`, and applies six of the seven research corrections directly in the migration section. The biggest gap is mechanical: a single SECURITY DEFINER hardening requirement from the template (range bounds validation order, the `min_lost` upper bound HINT) is loose, and the offenders RPC's wrapped CTE description leaves the function-comment text and grant statements implicit rather than spelled out. The threshold tests at Task 7.2 (`10-PLAN.md:233`) have a numerical boundary inconsistency that will break the test on first run. Effort accounting is honest but slightly under for the controller + Drilldown sub-tabs. Nothing here blocks an executable plan, but four fixes are needed before code generation to avoid review thrash.

## Findings

### Goal achievement

The plan delivers the SPEC's headline outcome: a Lost-Booking Rate card on Analytics > Revenue with sparkline, drill-down, and threshold-driven actionability. Trace:

- Headline KPI — Task 5.2 at `10-PLAN.md:188-193`, fed by `get_lost_booking_summary` (Task 1.1, `10-PLAN.md:97-102`).
- 12-week sparkline — Task 5.3 at `10-PLAN.md:195-200`, fed by `get_lost_booking_weekly_series`.
- Drill-down — Task 5.4 at `10-PLAN.md:202-211` with three tabs.
- Actionable thresholds — Task 5.1 at `10-PLAN.md:181-186` + advisory chip wording at `10-PLAN.md:190`.
- Refresh after booking mutation — Tasks 4.1–4.4 at `10-PLAN.md:144-177`.

Two intentional divergences from the SPEC, both justified by RESEARCH and disclosed in `## Out of scope (locked)`:

- Owner-vs-client cancellation split (SPEC `10-SPEC.md:484-495`) deferred per RESEARCH open question 3 — disclosed at `10-PLAN.md:20`. The Breakdown tab still renders without the "you cancelled N yourself" line per `10-PLAN.md:205`. Acceptable.
- "Excludes N guest bookings" footer deferred per RESEARCH §2 / open question 2 — disclosed at `10-PLAN.md:21`. Acceptable for v1.

No silent regressions detected.

### Research corrections applied

| RESEARCH § | Correction | Applied? | Evidence |
|---|---|---|---|
| §1 — wrong index claim | Drop SPEC's `idx_bookings_shop_date_status` claim; rely on `idx_bookings_shop_id`; investigate via EXPLAIN | YES | `10-PLAN.md:55`, Task 1.2 at `10-PLAN.md:104-109` |
| §2 — guest handling | Keep guests in summary/weekly; exclude from offenders only; defer footer | YES | `10-PLAN.md:78, 89, 21` |
| §3 — `last_lost_at` no-show timestamp bug | Replace `MAX(cancelled_at)` with CASE expression | YES | `10-PLAN.md:56-63, 87` |
| §4 — threshold bands tightened to 7%/12% | Adopt 7%/12% as named constants; flag as first-week tunable | YES | `10-PLAN.md:183` |
| §5 — refresh signal | New `bookingMutationProvider` as `StateProvider<int>`; bumped in DailyScheduleNotifier; controller uses `ref.listen` not `ref.watch` | YES | Tasks 4.1, 4.2, 4.4 at `10-PLAN.md:146-148, 152-156, 172-176` |
| §7 — test directory exists, no pgTAP | Use existing `test/` for Dart; use `supabase/tests/lost_booking_rpcs.sql` as manual psql script | YES | `10-PLAN.md:19, 35-38, 113` |
| §9.2 — LIMIT 50 on offenders | Add `LIMIT 50` via `top_offenders` CTE | YES | `10-PLAN.md:65-76, 88` |
| §9.6.3 — `_disposed` guard | Lift pattern from `analytics_controller.dart` | YES | `10-PLAN.md:163` |
| §9.5.2 — sync `isLoading=true` before await | Stated explicitly | YES | `10-PLAN.md:164` |
| §9.4.4 — `AppLogger.warn` must not include response body | Explicit instruction | YES | `10-PLAN.md:165` |
| §9.4.5 — use `warn` not `error` | Explicit | YES | `10-PLAN.md:165` |
| §9.8.1 — rollback procedure | Tier 2 manual runbook with `DROP FUNCTION` migration | YES | `10-PLAN.md:359-363` |

All seven primary research corrections applied. No missed items.

### RPC hardening

Cross-checked against the template at `supabase/migrations/20260603001500_harden_dashboard_rpcs.sql`:

Template requirements:
1. `SECURITY DEFINER` + `SET search_path = public` — stated at `10-PLAN.md:51`. Pass.
2. Ownership gate via `EXISTS (SELECT 1 FROM shops WHERE id = p_shop_id AND user_id = auth.uid())` — stated at `10-PLAN.md:51`. Pass.
3. `RAISE EXCEPTION 'not_found' USING ERRCODE = '42501'` for authz, `'invalid_*'` with `22023` + HINT for range — stated at `10-PLAN.md:51`. Pass, with one tightening needed (see Fix 1).
4. `REVOKE ALL ON FUNCTION ... FROM PUBLIC` + `GRANT EXECUTE ON FUNCTION ... TO authenticated` — stated at `10-PLAN.md:51`. Pass.
5. `COMMENT ON FUNCTION` — stated at `10-PLAN.md:51` and `10-PLAN.md:91` with Big-O note. Pass.
6. Input range bounds with HINT codes — SPEC sources have them; one is loose (see Fix 1).

Issue: The SPEC at `10-SPEC.md:260-262` defines `min_lost` validation as `RAISE EXCEPTION 'invalid_min_lost' USING ERRCODE = '22023'` with **no HINT**. The template at `20260603001500_harden_dashboard_rpcs.sql:135` standardizes the HINT format (`HINT = 'RANGE_X_Y'`). The plan at `10-PLAN.md:51` says "`'invalid_*'` with `22023` + HINT" — this implies the plan will add the HINT — but the plan instruction at `10-PLAN.md:80` says "copy SPEC lines 242–308 verbatim, then" only lists three corrections. The missing HINT on `invalid_min_lost` is a fourth correction that is not explicitly listed.

Issue: The `weekly_series` RPC at `10-SPEC.md:188-189` validates `p_weeks` after the authz check at line 191 in the SPEC body, but the template's convention (see `20260603001500_harden_dashboard_rpcs.sql:44-59`) is authz first, then range. The summary RPC at `10-SPEC.md:103-112` has range-first, authz-second — which inverts the template. The plan does not call this out. Fix 2.

### Checklist v3.1 coverage

P0-U items the SPEC asserts are covered by RPC shape (`10-SPEC.md:521`, restated at `10-PLAN.md:347`): 1.4, 1.5, 2.4, 2.5, 5.5. Verified — these are universal-blocking and are addressed.

Plan coverage matrix at `10-PLAN.md:322-345` is mapped against tasks. Cross-checked each row against the cited tasks:

- 1.3, 1.4, 1.7, 1.8, 2.1, 2.4, 2.5, 3.2, 3.3, 3.4, 4.4, 4.5, 4.11, 5.1, 5.2, 5.5, 5.6, 6.1, 6.3, 6.4, 6.13, 8.1 — all map to concrete tasks. Pass.

P1 items from RESEARCH §9 (`10-RESEARCH.md:243-263`) cross-check:
- 1.8 hand-wavy Big-O → addressed at `10-PLAN.md:91, 99`. Pass.
- 2.5 LIMIT 50 → addressed at `10-PLAN.md:65-76`. Pass.
- 4.4 PII redact → addressed at `10-PLAN.md:165`. Pass.
- 4.5 log level → addressed at `10-PLAN.md:165`. Pass.
- 5.1 null rate edge state → covered at `10-PLAN.md:190, 222, 252`. Pass.
- 5.2 sync isLoading + skeleton → covered at `10-PLAN.md:164, 190`. Pass.
- 6.1 same-day/future-dated/owner-cancel tests → covered at `10-PLAN.md:226`. Pass.
- 6.3 disposed guard → covered at `10-PLAN.md:163, 243`. Pass.
- 8.1 rollback runbook → covered at `10-PLAN.md:359-363`. Pass.

P0-U from full checklist v3.1: 2.1 (input sanitization at RPC layer), 2.4 (errors don't leak), 2.5 (resource limits), 4.4 (PII in logs), 5.5 (no internal info in UI) all explicitly mapped. 1.4 (authz), 1.5 (auth) are RPC-level and addressed by the SECURITY DEFINER + ownership pattern.

Uncovered, mentionable:
- 2.10 (resources released in finally/defer) — Dart controller is `StateNotifier` with explicit `dispose`; covered implicitly at `10-PLAN.md:166`.
- 6.7 (branch coverage thresholds) — not mentioned. RESEARCH §7 deliberately keeps the test surface minimal. Acceptable but worth a note in the plan.
- 3.9 / 3.10 (retry policy on RPC calls) — not addressed in the repository wrappers at Task 3.2 (`10-PLAN.md:136-141`). For a read-only analytics call this is acceptable; the controller-level graceful-degradation absorbs transient errors as cell-level empty states. No fix required but flag for transparency.

### Atomicity and verifiability

Each task has a `File:`, `Description:`, `Acceptance:`, `Checklist refs:`, `Estimate:` block. Spot-checks:

- Task 1.1 (`10-PLAN.md:97-102`) — acceptance is `supabase db push` + `\df+` showing 3 SECURITY DEFINER functions with `authenticated` grant only. Verifiable.
- Task 4.1 (`10-PLAN.md:146-150`) — acceptance "file is < 20 lines" is overly tight as an acceptance criterion (cosmetic), but `flutter analyze` clean is the real gate. Acceptable.
- Task 4.2 (`10-PLAN.md:152-156`) — acceptance includes a manual dev-build trace. Verifiable.
- Task 4.3 (`10-PLAN.md:160-170`) — acceptance leans on Task 7.3 to lock the graceful-degradation path. Coupled but explicit.
- Task 5.4 (`10-PLAN.md:202-211`) — bundles three sub-tabs (Breakdown / Repeat offenders / By weekday) into a single 90-minute task. Each tab has its own acceptance condition in the description but they're not separated. Consider splitting if pressed for time — see Fix 4.
- Task 6.1 (`10-PLAN.md:215-220`) — single-line insertion with screenshot acceptance. Verifiable.
- Tasks 8.1–8.3 (`10-PLAN.md:260-276`) — each has a concrete artifact (screenshot, hand-computation, before/after). Verifiable.

Issue: Task 7.2 boundary cases at `10-PLAN.md:233`:

```
`classify(0.07) == healthy` (inclusive). `classify(0.0701) == watch`. `classify(0.12) == watch`. `classify(0.1201) == hot`.
```

This requires `healthyMax = 0.07` to be **inclusive** on the upper bound (rate `0.07` → healthy) but `watchMax = 0.12` is **also inclusive** (rate `0.12` → watch). If both are implemented as `rate <= healthyMax`, then a rate of exactly `0.0700000001` falls into `watch` and a rate of `0.07` into `healthy`. Floating-point equality on `0.07` is brittle — `0.069 + 0.001` is not exactly `0.07` in IEEE-754. The test at `0.0701` may pass but a real production value that arithmetic-coincides with `0.07000000000001` will land in `watch` unexpectedly. Document the comparison operator explicitly in Task 5.1 (`<=` or `<`) so Task 7.2 cannot drift. See Fix 3.

Ordering: Wave dependencies are sensible — Migration → Models → Repo → Controller → Widgets → Screen → Tests → UAT. Tests in §7 reference artifacts from §2–5, which are upstream. Build is incrementally verifiable: Task 1.1 alone is testable via psql; Task 2.1 is testable via `flutter analyze`; Tasks 7.1–7.4 each map to a single `flutter test` command. Pass.

### Risk register

R1 (seq scan) — real and specific, with a pre-defined fallback migration name. Strong.
R2 (double-refetch on autoDispose tear-down) — real, low-impact, acceptable trade-off. Strong.
R3 (last_lost_at deviation surprises reviewer) — real, has a citation-in-comment mitigation. Strong.
R4 (threshold change surprises owners) — real and operator-facing. Strong.
R5 (By-weekday tab empty if weekly fails) — real, has empty-state mitigation. Strong.
R6 (hot-reload theme switch on painter) — speculative but cheap to harden. Acceptable.
R7 (owner-cancelled-self overstates client rate) — real, documented as v1 trade-off. Strong.
R8 (guest reconciliation gap) — real, documented for the next maintainer. Strong.
R9 (`AppLogger.warn` accidentally with `e.toString()`) — real and PII-relevant; enforced via grep gate at `10-PLAN.md:377`. Strong.
R10 (mock awkwardness for `Ref.listen`) — narrow but mitigated by testing the controller in isolation. Acceptable.

Senior-reviewer test: are the top items money/race/auth/drift? R3 (data correctness drift), R7 (rate misattribution), R9 (PII leakage) are real reviewer-grade concerns. R1 is a real perf risk. The list is honest and not filler.

One miss worth adding: **autz drift** — the SPEC's `EXISTS (... shops WHERE id = p_shop_id AND user_id = auth.uid())` pattern at `10-PLAN.md:51` matches the template, but if a future maintainer adds a `manager_user_id` or `co_owner_id` column to `shops` (the codebase has signs of multi-owner per shop-management features), this single-owner check will silently mis-deny. Consider adding R11. Non-blocking.

### Out-of-scope discipline

SPEC explicitly defers (`10-SPEC.md:561-570`): money-as-minor-units, performance_alerts rule engine, no-show predictor, per-worker attribution, multi-shop comparison, configurable thresholds.

Plan's `## Out of scope (locked)` at `10-PLAN.md:12-21` covers all six and adds two more deferments grounded in RESEARCH:
- 4th RPC `get_cancellation_actor_split` — deferred per RESEARCH open Q3.
- pgTAP scaffolding — deferred per RESEARCH §7.
- Guest footer in offenders tab — deferred per RESEARCH open Q2.

No scope creep detected. The "By weekday" tab in Task 5.4 (`10-PLAN.md:207`) is derived client-side from existing weekly-series state, not a new RPC — within scope.

Money handling stays `double` per RESEARCH §8 with `TODO(money-minor-units)` marker at `10-PLAN.md:14, 122`. Out-of-scope discipline maintained.

### Effort honesty

Plan totals 800 min ≈ 13.3h at `10-PLAN.md:381-393`. SPEC ceiling is ~1.5 days at `10-SPEC.md:594`. 13.3h / 8h-day = 1.66 days. Plan acknowledges this is "lands at ~1.5 engineering days. Within the SPEC's ceiling." This is honest but tight.

Estimate spot-checks:
- Task 4.3 — 60 min for `LostBookingsController` with `_disposed` guard, `_safe<T>` helper, graceful-degradation logic, and `Future.wait(eagerError: false)` orchestration. Mirroring `analytics_controller.dart:94-205` is realistic at 60 min. Pass.
- Task 5.2 — 90 min for the headline card with 5 visual states (healthy / watch / hot / empty / skeleton), `CardInkWell` wrap, `BottomSheetUtils` integration, severity-driven theming, semantics label, and a 360pt overflow check. Tight but doable. Pass.
- Task 5.3 — 60 min for a hand-rolled `CustomPainter` with 12 bars, baseline rendering for empty weeks, severity colouring, and a `Semantics` wrapper computing a trend summary. Reasonable. Pass.
- Task 5.4 — 90 min for **three tabs** (Breakdown bar viz + Repeat-offenders ListView + By-weekday derived bar chart), tab chrome via `AppTabs`, empty/populated states for each. **Under-estimated.** Each tab is conservatively 45 min; total nearer 130–150 min. See Fix 4.
- Task 7.3 — 60 min for three tests including the disposed-guard mid-flight scenario. The mocktail fake plus `StateNotifier` listener pattern is feasible but the disposed-mid-flight test typically requires careful future-controller plumbing. Realistic at 60–75 min. Pass.

Corrected total: 800 + ~50 = ~850 min ≈ 14.2h ≈ 1.78 days. Still inside the "~1.5 days" ceiling if interpreted loosely (the plan's defer-clause at `10-PLAN.md:395` already names the By-weekday sub-tab as the cleanest defer). Honest enough; flag Task 5.4 for re-estimation.

## Required fixes before execution

1. **Task 1.1 — `min_lost` validation missing HINT.** At `10-PLAN.md:99-102` the plan says functions follow the hardening template, but the template (and `2.5` standard) requires a HINT code on every range exception. The SPEC's `RAISE EXCEPTION 'invalid_min_lost' USING ERRCODE = '22023'` at `10-SPEC.md:261` has no HINT. Add a fourth bullet to the "Corrections to apply" list at `10-PLAN.md:53-80`: *"Add `HINT = 'RANGE_1_50'` to the `invalid_min_lost` exception."* This is a one-line SQL change; explicit so the executor doesn't copy the SPEC verbatim and miss it.

2. **Task 1.1 — validation ordering inconsistent with template.** At `10-PLAN.md:99-102`, the three RPCs inherit the SPEC's validation order. The summary RPC at `10-SPEC.md:103-112` validates `p_period_days` **before** the authz check. The template `20260603001500_harden_dashboard_rpcs.sql:44-59` validates authz **first**, then range. This ordering matters because validating range before authz lets an unauthorized caller distinguish between an out-of-range bad request (which fires `22023`) and a not-found shop (which fires `42501`), enabling parameter-shape probing. Add a fifth bullet to "Corrections to apply" at `10-PLAN.md:53-80`: *"Re-order all three RPCs to authz-first, range-second, matching the template at `20260603001500_harden_dashboard_rpcs.sql:44-59`."*

3. **Task 5.1 / Task 7.2 — threshold comparison operator must be specified.** At `10-PLAN.md:233`, Task 7.2 asserts both `classify(0.07) == healthy` (inclusive lower band) and `classify(0.12) == watch` (inclusive lower band). The current Task 5.1 description at `10-PLAN.md:183` lists only the named constants and does not specify the comparison operator. Add to Task 5.1: *"Implement classify as: `rate == null ⇒ healthy; rate <= healthyMax ⇒ healthy; rate <= watchMax ⇒ watch; else hot`. The `<=` operator is load-bearing — the test in Task 7.2 will fail with `<`."* Also note: IEEE-754 representation of `0.07` is exact for this magnitude in `double`, so the test cases at `0.07` and `0.12` are stable.

4. **Task 5.4 — re-estimate and split.** The 90-min estimate at `10-PLAN.md:211` covers three tabs (Breakdown, Repeat offenders, By weekday) with empty + populated states each. This is under-scoped by ~45 min. Either: (a) re-estimate to 135 min and update the rollup at `10-PLAN.md:389` to 305 min for §5, total 845 min ≈ 14.1h; or (b) split into Task 5.4a (Breakdown + Offenders, 75 min) and Task 5.4b (By weekday, 45 min), with 5.4b explicitly marked as the documented defer per `10-PLAN.md:395`. Pick (b) — it preserves the 800-min total and matches the existing defer hint.

## Optional improvements

1. **R11 — multi-owner drift on `shops.user_id` ownership check.** The pattern at `10-PLAN.md:51` assumes single-owner per shop. If multi-owner is added to `shops` later, the ownership check silently mis-denies. Add to the risk register at `10-PLAN.md:307-318`: *"R11 — Future multi-owner support on `shops` will break the single-`user_id` authz pattern. Mitigation: when multi-owner ships, factor the ownership predicate into a shared SQL helper `auth.uid_owns_shop(p_shop_id)` and route all three RPCs through it."*

2. **Task 7.3 — fake `AppLogger` capture is brittle.** At `10-PLAN.md:242` the test uses "a test logger sink or assert via the captured `fields`". If no existing test logger fake exists in the codebase, this becomes a 30-min side quest. Pre-check the codebase for `FakeAppLogger` / `AppLoggerOverride` before writing the test; if absent, scope a tiny fake at the top of `lost_bookings_controller_test.dart` and document the pattern for reuse.

3. **Task 4.2 — `markBookingAsCompleted` bump justification.** At `10-PLAN.md:154` the plan adds a third tick site (`markBookingAsCompleted`) that is not in RESEARCH §5's recommendation (`10-RESEARCH.md:170-176` lists only cancel + no-show). The reasoning ("a completion materially changes the lost-rate denominator") is correct — a completion increments the honoured count and shifts the rate downward. Worth a one-line citation in the migration comment so a future reviewer doesn't strip it. Not a blocker.

4. **Definition of done grep gates.** At `10-PLAN.md:377-378` the grep gates are sound but `grep -c "e.toString" == 0` will also match comments and string literals. Consider tightening to a `ripgrep` pattern that excludes Dart string-literal contexts, or accept the false-positive risk and document. Non-blocking.

5. **Task 1.3 — extend manual SQL test to cover guest-bucket reconciliation.** `10-PLAN.md:113` covers the `last_lost_at` fix but does not assert that guest bookings appear in summary and absent from offenders. A 4-line snippet that inserts one guest cancellation + one logged-in client cancellation, then runs both summary and offenders, asserting summary counts both and offenders includes only the logged-in one, closes the documented v1 gap (`10-PLAN.md:21`) before review.

## PLAN CHECK COMPLETE
