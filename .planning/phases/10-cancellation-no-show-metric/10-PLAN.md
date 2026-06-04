# Phase 10 PLAN — Cancellation & No-Show Metric

> Source contract: `.planning/phases/10-cancellation-no-show-metric/10-SPEC.md`
> Research corrections: `.planning/phases/10-cancellation-no-show-metric/10-RESEARCH.md`
> Hardening template: `supabase/migrations/20260603001500_harden_dashboard_rpcs.sql`
> Quality bar: `architecture/algorithms/algorithm_quality_review_checklist.md` (v3.1)

## Goal

Surface a single headline "lost-booking rate" KPI (cancellations + no-shows ÷ terminal bookings) on the Analytics > Revenue tab of the shop-owner dashboard, with a 12-week sparkline and a drill-down sheet listing the breakdown and repeat-offender clients. Three new SECURITY DEFINER RPCs aggregate the data; a new Riverpod controller fetches them in parallel and reacts to a booking-mutation tick signal so the metric stays fresh after the owner cancels or marks a no-show. Restated from SPEC lines 3–18 with the research-driven corrections to index access path (RESEARCH §1), `last_lost_at` aggregation (RESEARCH §3), threshold bands (RESEARCH §4), and refresh signal wiring (RESEARCH §5).

## Out of scope (locked)

- Money-as-minor-units conversion (RESEARCH §8). `double` is retained for parity with `RevenueComparisonCard`; a `TODO(money-minor-units)` marker is added so the project-wide sweep has a grep target.
- No-show predictor model.
- `performance_alerts` rule-engine integration (Phase 11 candidate per SPEC line 564–565).
- Per-worker no-show attribution.
- Multi-shop comparison.
- pgTAP / SQL test scaffolding — `supabase/tests/` does not exist and no runner is wired into CI (RESEARCH §7). Replaced with a manual psql script.
- 4th RPC `get_cancellation_actor_split` (SPEC lines 484–495) — deferred per RESEARCH open question 3.
- "Excludes N guest bookings" footer in offenders tab — silent exclusion for v1 per RESEARCH open question 2.

## Files touched

**NEW**
- `supabase/migrations/20260603002000_lost_booking_rpcs.sql`
- `supabase/tests/lost_booking_rpcs.sql` (manual psql snippets, not CI-wired)
- `lib/presentation/features/shops/dashboard/data/models/analytics/lost_booking_metrics.dart`
- `lib/presentation/features/shops/dashboard/presentation/controllers/lost_bookings_controller.dart`
- `lib/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_thresholds.dart`
- `lib/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_headline_card.dart`
- `lib/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_sparkline.dart`
- `lib/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_drilldown_sheet.dart`
- `lib/presentation/features/shops/booking/presentation/providers/booking_mutation_signal.dart`
- `test/dashboard/lost_booking_summary_test.dart`
- `test/dashboard/lost_booking_thresholds_test.dart`
- `test/dashboard/lost_bookings_controller_test.dart`
- `test/dashboard/lost_booking_headline_card_test.dart`

**EDIT**
- `lib/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart` (add 3 abstract methods)
- `lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart` (add 3 RPC wrappers)
- `lib/presentation/features/shops/dashboard/providers/dashboard_providers.dart` (add `LostBookingsParams` + family provider)
- `lib/presentation/features/shops/appointments/shop_daily_schedule/providers/daily_schedule_notifier.dart` (bump signal on lines 83 and 89 per RESEARCH §5)
- `lib/presentation/features/shops/dashboard/presentation/screens/analytics_screen.dart` (insert headline card under `AnalyticsTab.revenue`, between lines 150 and 152)

All cited paths verified against the working tree at plan-write time.

## Migration plan

Single SQL migration: `supabase/migrations/20260603002000_lost_booking_rpcs.sql`. One `CREATE OR REPLACE FUNCTION` per RPC. Each function mirrors the hardening template at `supabase/migrations/20260603001500_harden_dashboard_rpcs.sql` exactly: `SECURITY DEFINER`, `SET search_path = public`, ownership gate via `EXISTS (SELECT 1 FROM shops WHERE id = p_shop_id AND user_id = auth.uid())`, sanitized errors (`'not_found'` with `42501` for authz, `'invalid_*'` with `22023` + `HINT` for range), `REVOKE ALL FROM PUBLIC`, `GRANT EXECUTE TO authenticated`, and a `COMMENT ON FUNCTION` explaining intent.

**Corrections to apply vs. SPEC verbatim:**

1. **Drop the index claim** (SPEC lines 311–322). Queries filter on `start_time` but `idx_bookings_shop_date_status` is keyed on `booking_date` (RESEARCH §1). Realistic access path is `idx_bookings_shop_id (shop_id, start_time DESC)`. Do NOT pre-add a covering index. The migration body contains the three function definitions only; index investigation is a separate task (Task 1.2) using a manual `EXPLAIN ANALYZE`.
2. **Fix `last_lost_at` in `get_lost_booking_offenders`** (SPEC lines 277–278). `mark_booking_no_show` does NOT set `cancelled_at` — only `updated_at` (verified in `supabase/migrations/20260517020000_booking_hardening.sql:487-533`). The aggregate must be:

   ```sql
   MAX(CASE
     WHEN b.status = 'cancelled' THEN b.cancelled_at
     WHEN b.status = 'no_show'   THEN b.updated_at
   END) AS last_lost_at
   ```

3. **Add `LIMIT 50`** to the offenders RPC's `jsonb_agg` (RESEARCH §9, gap 2.5). SPEC §3.1 says "natural cap" — make it explicit. Apply via a CTE wrapper:

   ```sql
   WITH per_client AS (...),
        top_offenders AS (
          SELECT * FROM per_client
          ORDER BY lost_bookings DESC, last_lost_at DESC NULLS LAST
          LIMIT 50
        )
   SELECT jsonb_build_object('offenders', COALESCE(jsonb_agg(...), '[]'::jsonb))
   FROM top_offenders ...
   ```

4. **Add `HINT = 'RANGE_1_50'` to the `invalid_min_lost` exception in the offenders RPC.**

5. **Re-order all three RPCs to authz-first, range-second, matching the hardening template (`supabase/migrations/20260603001500_harden_dashboard_rpcs.sql:44-59`).** The ownership-check `EXISTS (SELECT 1 FROM shops WHERE id = p_shop_id AND user_id = auth.uid())` must run before any `RAISE EXCEPTION 'invalid_*'`.

6. **Keep guests in summary + weekly_series RPCs** (no `user_id IS NOT NULL` filter on those). Keep the exclusion on offenders only — guests have no joinable identity (RESEARCH §2).

7. **Function bodies inline** — see SPEC lines 87–308 for the three definitions; apply corrections (2) and (3) before writing. No other body changes.

### Function 1: `get_lost_booking_summary(UUID, INTEGER)` — copy SPEC lines 87–157 verbatim. No corrections needed.

### Function 2: `get_lost_booking_weekly_series(UUID, INTEGER)` — copy SPEC lines 175–233 verbatim. No corrections needed.

### Function 3: `get_lost_booking_offenders(UUID, INTEGER, INTEGER)` — copy SPEC lines 242–308, then:
- Replace the `last_lost_at` line in `per_client` CTE with the CASE expression above.
- Wrap with `top_offenders` CTE + `LIMIT 50` as above.
- Keep `b.user_id IS NOT NULL` filter (correct for v1 per RESEARCH §2).

Each `COMMENT ON FUNCTION` line must state Big-O explicitly: O(B) where B = bookings in the lookback window for the shop (closes RESEARCH §9 gap 1.8).

## Tasks

### 1. Migration

**Task 1.1 — Write the SQL migration with three RPCs.**
- File: `supabase/migrations/20260603002000_lost_booking_rpcs.sql` (NEW)
- Description: Create the three functions per the Migration plan above. Each uses the hardening template from `20260603001500_harden_dashboard_rpcs.sql`. Apply the three corrections (last_lost_at CASE, LIMIT 50, no guest filter on summary/weekly). Add `COMMENT ON FUNCTION` for each with Big-O note.
- Acceptance: `supabase db push` runs clean against a local Postgres. `\df+ public.get_lost_booking_*` in psql shows 3 functions, each `security_type=definer`, owner `postgres`, `EXECUTE` granted only to `authenticated`.
- Checklist refs: 1.4, 1.8, 2.1, 2.4, 2.5, 3.2, 4.4, 5.5
- Estimate: 60 min

**Task 1.2 — Verify access path on a real shop with `EXPLAIN ANALYZE`.**
- File: `supabase/tests/lost_booking_rpcs.sql` (NEW). Manual psql script, not CI-wired.
- Description: Add an `EXPLAIN ANALYZE` block for each of the three RPCs against a real shop with > 1000 terminal bookings (use the largest seed shop in staging). Capture output. Confirm the plan uses `idx_bookings_shop_id` (`shop_id, start_time DESC`) — NOT `idx_bookings_shop_date_status` (RESEARCH §1). If a `Seq Scan` appears on a shop with > 50k bookings, halt: open a follow-up to add `idx_bookings_shop_terminal_starttime` (partial index defined in RESEARCH §1 lines 58–62) and ship it as `20260603002500_lost_booking_partial_index.sql`. Do NOT add the index speculatively.
- Acceptance: The psql script runs without error and the attached output shows `Index Scan using idx_bookings_shop_id` (or, if a seq scan appears, a documented follow-up issue exists). Output pasted into the PR description.
- Checklist refs: 3.3, 1.8
- Estimate: 20 min

**Task 1.3 — Write manual SQL smoke tests covering authz, range bounds, and the `last_lost_at` fix.**
- File: `supabase/tests/lost_booking_rpcs.sql` (extend Task 1.2's file)
- Description: Add executable psql snippets matching SPEC §Tests > SQL items 1–5, plus a dedicated assertion: insert one `cancelled` + one `no_show` booking for the same `(shop_id, user_id)` with distinct `cancelled_at` / `updated_at` timestamps, run `get_lost_booking_offenders`, and assert `last_lost_at` equals the later timestamp (proves the no-show timestamp fix from RESEARCH §3). Include a comment block at the top: "Manual psql tests — pgTAP scaffolding deferred to a future testing-foundation phase."
- Acceptance: Each snippet is copy-paste runnable in Supabase Studio. The `last_lost_at` snippet's expected output is documented inline as a comment so a reviewer can verify the assertion.
- Checklist refs: 1.4, 2.4, 2.5, 6.1, 6.4
- Estimate: 40 min

### 2. Dart models

**Task 2.1 — Add the four lost-booking value-object models.**
- File: `lib/presentation/features/shops/dashboard/data/models/analytics/lost_booking_metrics.dart` (NEW)
- Description: Implement `LostBookingSummary`, `LostBookingPeriod`, `LostBookingWeek`, `LostBookingOffender` exactly as SPEC lines 332–383. All immutable, `const` constructors, `Equatable` (this codebase uses equatable elsewhere in dashboard models — verified). Add `fromJson` factory on each, mirroring how `DashboardMetrics`/`QuarterlyRevenue` serialize. Money fields stay `double` with `// TODO(money-minor-units): align with checklist 2.19 sweep` on `LostBookingPeriod.lostRevenue` (RESEARCH §8). `currentRate`, `previousRate`, and `rateDelta` getters on `LostBookingSummary` return `double?`, null when `total == 0` (SPEC lines 341–353).
- Acceptance: `flutter analyze lib/presentation/features/shops/dashboard/data/models/analytics/lost_booking_metrics.dart` returns zero issues. Unit test in Task 7.1 will lock the null-rate semantics.
- Checklist refs: 1.8 (Big-O implicit, O(1)), 5.1 (null = "no data yet" not "error")
- Estimate: 30 min

### 3. Repository

**Task 3.1 — Add three abstract methods to `DashboardRepository`.**
- File: `lib/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart` (EDIT)
- Description: Append the three abstract methods per SPEC lines 393–409. Doc-comment each with the SECURITY DEFINER guarantee and the `DashboardRepositoryException` contract (existing exception class, no boundary change).
- Acceptance: `flutter analyze` clean. Implementing class (Task 3.2) compiles after this is in place.
- Checklist refs: 2.4, 5.5
- Estimate: 15 min

**Task 3.2 — Implement the three RPC wrappers on `SupabaseDashboardRepository`.**
- File: `lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart` (EDIT)
- Description: Wrap each `supabaseClient.rpc('get_lost_booking_*', params: {...})` in the same try/catch pattern used by existing RPC wrappers in this file. Map JSON to the models from Task 2.1. On error, throw `DashboardRepositoryException` with a sanitized message — never echo PostgrestException details containing booking ids or names. Catch `PostgrestException` specifically; map `42501` → `'not_found'` constant string, `22023` → `'invalid_range'`, anything else → `'load_failed'`.
- Acceptance: `flutter analyze` clean. The three methods return typed models on a happy path JSON fixture (covered in unit tests at Task 7.1).
- Checklist refs: 1.4, 2.4, 5.5
- Estimate: 45 min

### 4. Controller + provider + refresh signal

**Task 4.1 — Add `bookingMutationProvider` as a `StateProvider<int>` tick counter.**
- File: `lib/presentation/features/shops/booking/presentation/providers/booking_mutation_signal.dart` (NEW)
- Description: Define `final bookingMutationProvider = StateProvider<int>((ref) => 0);`. Tick semantics — listeners care about the change, not the value (RESEARCH §5). Add a doc comment explaining: "Bumped after any booking state transition (cancel, no-show, complete) so analytics-side controllers can react. Do NOT route through the repository — Riverpod refs must stay out of the repo layer."
- Acceptance: `flutter analyze` clean. File is < 20 lines.
- Checklist refs: 1.7, 4.11
- Estimate: 10 min

**Task 4.2 — Bump the signal from `DailyScheduleNotifier`.**
- File: `lib/presentation/features/shops/appointments/shop_daily_schedule/providers/daily_schedule_notifier.dart` (EDIT)
- Description: After `await refreshDate(date)` at line 84 (`cancelBooking`) and line 90 (`markBookingAsNoShow`), add `_ref.read(bookingMutationProvider.notifier).state++;`. Verify the notifier already holds a `ref` (it must — it's a `Notifier`). If it stores `Ref` under a different name (`_ref`, `ref`, etc.), use the existing accessor. Also bump in `markBookingAsCompleted` at line 75 — a completion materially changes the lost-rate denominator. Three single-line additions.
- Acceptance: `flutter analyze` clean. Manual trace: cancel a booking via daily-schedule UI in the dev build and observe the provider tick via a temporary `ref.listen` log in the new controller.
- Checklist refs: 3.4 (cache invalidation triggers identified)
- Estimate: 15 min

**Task 4.3 — Build `LostBookingsController` + state + params + family provider.**
- File: `lib/presentation/features/shops/dashboard/presentation/controllers/lost_bookings_controller.dart` (NEW)
- Description: Mirror `analytics_controller.dart:94–205` precisely (verified pattern):
  - `LostBookingsState` with `summary`, `weeks`, `offenders`, `isLoading`, `isRefreshing`, `error` (stable code string, never `e.toString()` per checklist 5.5).
  - `LostBookingsController extends StateNotifier<LostBookingsState>` with `_disposed` flag (checklist 6.3, RESEARCH §9 gap 6.3).
  - `loadAnalytics()` (or `load()`) sets `isLoading: true` synchronously before any await (RESEARCH §9 gap 5.2), runs the three repo calls inside `Future.wait([...], eagerError: false)`, then writes results with per-query graceful degradation — if `offenders` fails but `summary` + `weeks` succeed, render the headline anyway (SPEC lines 423–425).
  - `_safe<T>(String tag, Future<T> Function() fn)` private helper using `AppLogger.warn('analytics.load_failed', fields: {'tag': 'lost_booking_$tag', 'shop_id': state.shopId, 'error_code': <code>})`. **MUST NOT include any element of the response body** (RESEARCH §9 gap 4.4). Use `AppLogger.warn` (not `error`) to match the analytics_controller precedent (RESEARCH §9 gap 4.5).
  - `dispose()` sets `_disposed = true`.
  - Generic user-safe `error` only when all three queries failed.
- Acceptance: `flutter analyze` clean. Compiles against Task 3.x methods. The graceful-degradation path is locked by a unit test in Task 7.3.
- Checklist refs: 1.3, 1.4 (relies on RPC authz), 2.4, 4.4, 4.5, 5.5, 6.3
- Estimate: 60 min

**Task 4.4 — Wire `LostBookingsParams` + family provider in `dashboard_providers.dart` and add the refresh listener.**
- File: `lib/presentation/features/shops/dashboard/providers/dashboard_providers.dart` (EDIT)
- Description: Add `LostBookingsParams({required String shopId, int periodDays = 7})` mirroring `OwnerDashboardParams` (verified at lines 41–48). Add `final lostBookingsControllerProviderFamily = StateNotifierProvider.family.autoDispose<LostBookingsController, LostBookingsState, LostBookingsParams>((ref, params) { final controller = LostBookingsController(repository: ref.watch(dashboardRepositoryProvider), shopId: params.shopId, periodDays: params.periodDays); ref.listen<int>(bookingMutationProvider, (_, __) { controller.refresh(); }); return controller; });`. Use `ref.listen`, not `ref.watch` (RESEARCH §5 — `watch` would tear down state on every tick).
- Acceptance: `flutter analyze` clean. Provider is reachable from a `ConsumerWidget` in `analytics_screen.dart`.
- Checklist refs: 3.4 (invalidation triggers wired)
- Estimate: 25 min

### 5. Widgets

**Task 5.1 — Add `LostBookingThresholds` constants and severity classifier.**
- File: `lib/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_thresholds.dart` (NEW)
- Description: Expose three named `static const double` thresholds: `healthyMax = 0.07`, `watchMax = 0.12` (per RESEARCH §4 — tightened from SPEC's 0.08/0.15 based on Booksy industry benchmarks). Provide `enum LostBookingSeverity { healthy, watch, hot }` and `LostBookingSeverity classify(double? rate)`. `rate == null` returns `healthy` (no data is not alarming — SPEC's edge state). Add a doc-block at top: "First-week tunable. Industry signal: Booksy cites 10–15% as the cross-industry average — we set `watchMax` at the lower bound and `hot` above the average." Flag for the PR description.
  Classifier semantics (load-bearing — Task 7.2 tests depend on this):
  `rate == null ⇒ healthy`
  `rate <= healthyMax (0.07) ⇒ healthy`
  `rate <= watchMax (0.12) ⇒ watch`
  `else ⇒ hot`
  Use `<=`, not `<`. IEEE-754 representation of 0.07 and 0.12 in `double` is exact at these magnitudes, so boundary tests at 0.07 and 0.12 are stable.
- Acceptance: Unit test in Task 7.2 locks each boundary.
- Checklist refs: 4.11 (no magic numbers), 5.1 (advisory band copy lives here too)
- Estimate: 20 min

**Task 5.2 — Build `LostBookingHeadlineCard`.**
- File: `lib/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_headline_card.dart` (NEW)
- Description: A `ConsumerWidget` that watches `lostBookingsControllerProviderFamily(LostBookingsParams(shopId: ...))`. Layout mirrors SPEC lines 437–448 — title row, big rate `Text` (e.g. `'12.4 %'`), delta chip (`▲ +3.1 pp`), small `'42 of 339'` subline, embedded `LostBookingSparkline` on the left, lost-revenue figure on the right. Wrap in `CardInkWell` exactly like `revenue_comparison_card.dart:41` (verified). `onTap` opens the drill-down sheet via `BottomSheetUtils.showDocumentationBottomSheet`. Severity colouring from `LostBookingThresholds.classify`: `healthy` → primary, `watch` → amber border + onSurface text, `hot` → error border + advisory chip "Consider a deposit policy or reminder cadence review (combined cancel + no-show rate)" — the parenthetical disambiguates vs no-show-only benchmarks per RESEARCH §4. Empty state when `state.summary?.currentRate == null`: "No completed or lost bookings in the last 7 days yet." Skeleton state when `state.isLoading && state.summary == null` (RESEARCH §9 gap 5.2). All colours via `Theme.of(context).colorScheme`; opacities via `withValues(alpha: ...)`. Semantics label summarises the rate + delta verbatim for screen readers (checklist 5.6, best-effort). NO `withOpacity` — use `withValues(alpha:)` to honour the user's UX directive on Material 3 colour token hygiene.
- Acceptance: Widget renders without overflow at 360pt width. Healthy/watch/hot/empty/skeleton states each produce a distinguishable visual. Test in Task 7.4 locks the three rate→severity branches.
- Checklist refs: 5.1, 5.2, 5.5, 5.6
- Estimate: 90 min

**Task 5.3 — Build `LostBookingSparkline` as a stand-alone `CustomPainter`.**
- File: `lib/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_sparkline.dart` (NEW)
- Description: Do NOT reuse `quarterly_revenue_chart.dart` — it is fully coupled to `YearlyRevenue` and pulls in fl_chart's `BarChart` (RESEARCH §6, file inspection confirms). Build a thin `CustomPaint` with a custom painter that takes `List<LostBookingWeek>` and a `LostBookingSeverity Function(double?) classify` callback. Paint 12 bars, height proportional to `week.rate ?? 0`, bar colour from severity. Empty weeks (`total == 0`) render as a 1-pixel baseline. Rounded top corners on each bar (~2px radius). Sized at 80w × 32h logical pixels (the headline card's inline footprint). Add a `Semantics` wrapper above the painter with a text summary computed from the data: e.g. `'12-week trend: 8 percent to 12 percent, rising'`. Colours from `Theme.of(context)` extension passed via constructor — painter itself takes pre-resolved `Color`s.
- Acceptance: Widget renders 12 bars for 12 weeks of data and 12 bars (with 7 baselines) for 5 weeks of data. Test in Task 7.4 asserts the baseline count.
- Checklist refs: 5.6 (Semantics summary), 1.8 (O(W) where W = 12)
- Estimate: 60 min

**Task 5.4a — Drill-down sheet: Breakdown + Repeat offenders tabs.**
- File: `lib/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_drilldown_sheet.dart` (NEW)
- Description: A `ConsumerStatefulWidget` opened by `LostBookingHeadlineCard.onTap` via `BottomSheetUtils.showDocumentationBottomSheet`. Implement the first two of three tabs per SPEC lines 470–483, using the project's standard `AppTabs` widget (verified in `lib/core/widgets/app_tabs.dart`) for tab chrome:
  - **Breakdown**: a small bar showing `cancelled` vs `no_show` counts for the current period, drawn with the same `CustomPainter` family (or simple `Row` of `Container`s — no fl_chart). The "Of these, you cancelled N yourself" line is **omitted in v1** (4th RPC deferred — see Out of scope). Hardcode the surrounding copy so the sheet still reads complete.
  - **Repeat offenders**: a `ListView.separated` over `state.offenders`. Each row: `CircleAvatar` (avatarUrl or initial), display name, lost-rate badge coloured by severity, `'Last X days ago'` from `lastLostAt`. Tap → existing client detail route (verify the route name in `app_router.dart` before wiring; if absent, open a no-op `SnackBar` "Client detail coming soon" and document the gap inline). Empty state: "No repeat offenders in the last 90 days — nice."
- Acceptance: Sheet opens via `BottomSheetUtils.showDocumentationBottomSheet`. Two tabs visible via `AppTabs`. Each tab shows the correct empty + populated state without crashing.
- Checklist refs: 5.1, 5.5, 5.6
- Estimate: 75 min

**Task 5.4b — Drill-down sheet: By weekday tab.**
- File: `lib/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_drilldown_sheet.dart` (EDIT — extends Task 5.4a)
- Description: Add the third tab to the existing `AppTabs` set:
  - **By weekday**: a 7-bar chart bucketed Mon–Sun, derived **client-side** from `state.weeks` summed by ISO weekday. No new RPC. Severity colouring per bar.
- Acceptance: Third tab visible alongside the two from 5.4a. Weekday bar chart derived client-side from `state.weeks`. Empty state shown when `state.weeks` is empty.
- Checklist refs: 5.1, 5.5, 5.6
- Estimate: 45 min

### 6. Screen integration

**Task 6.1 — Insert `LostBookingHeadlineCard` into `AnalyticsTab.revenue`.**
- File: `lib/presentation/features/shops/dashboard/presentation/screens/analytics_screen.dart` (EDIT)
- Description: At line 150–152 (verified), after the closing `]` of the `RevenueComparisonCard` `if (state.revenueComparisons != null) ...[` block, insert `Gap(Spacing.md.h), LostBookingHeadlineCard(shopId: widget.shopId),`. The card is self-contained — it reads the controller via its own family provider; no plumbing through `AnalyticsState`. Additive only; no edits to the existing revenue widgets (SPEC lines 502–503).
- Acceptance: Analytics tab shows the headline card under the existing revenue comparison card on a real shop and shows the empty-state copy on a brand-new shop.
- Checklist refs: 5.1
- Estimate: 15 min

### 7. Tests

**Task 7.1 — Unit-test `LostBookingSummary` rate semantics.**
- File: `test/dashboard/lost_booking_summary_test.dart` (NEW)
- Description: Test `currentRate` returns `null` when `total == 0`. Test `currentRate ≈ 0.124` for `{total: 339, cancelled: 32, noShow: 10, honoured: 297}`. Test `rateDelta` returns null when either rate is null. Test that a future-dated cancelled booking with `start_time` in next ISO week does NOT contribute to current `total` (covered via a `fromJson` fixture that mirrors what the RPC returns — bucket exclusion is server-side, so test the model surface, not the SQL). Test same-day cancellation IS counted (fixture). Test owner-cancelled IS counted (fixture) — closes RESEARCH §9 gap 6.1.
- Acceptance: `flutter test test/dashboard/lost_booking_summary_test.dart` passes; all five cases green.
- Checklist refs: 6.1, 6.4
- Estimate: 30 min

**Task 7.2 — Unit-test `LostBookingThresholds.classify` boundaries.**
- File: `test/dashboard/lost_booking_thresholds_test.dart` (NEW)
- Description: Lock the 7%/12% boundaries (RESEARCH §4). `classify(null) == healthy`. `classify(0.069) == healthy`. `classify(0.07) == healthy` (inclusive). `classify(0.0701) == watch`. `classify(0.12) == watch`. `classify(0.1201) == hot`.
- Acceptance: `flutter test test/dashboard/lost_booking_thresholds_test.dart` passes.
- Checklist refs: 6.1
- Estimate: 15 min

**Task 7.3 — Controller graceful-degradation + disposed-guard tests.**
- File: `test/dashboard/lost_bookings_controller_test.dart` (NEW)
- Description: Using `mocktail` (verified in pubspec.yaml:124), build a `FakeDashboardRepository`. Three tests:
  1. All three RPCs succeed → state populated, `error == null`.
  2. `getLostBookingOffenders` throws, others succeed → `state.summary != null`, `state.weeks != null`, `state.offenders == []`, `state.error == null`, and `AppLogger.warn` fired once with `tag: 'lost_booking_offenders'` (use a test logger sink or assert via the captured `fields` — match analytics_controller_test precedent if one exists, otherwise capture via a temporary fake `AppLogger`).
  3. Controller disposed mid-flight: instantiate, call `load`, dispose before the futures resolve, complete the futures — assert no state mutation occurred (use a `StateNotifier` listener that records every state write).
- Acceptance: `flutter test test/dashboard/lost_bookings_controller_test.dart` passes.
- Checklist refs: 1.3, 4.4, 6.2, 6.3, 6.4
- Estimate: 60 min

**Task 7.4 — Widget tests for `LostBookingHeadlineCard` and sparkline.**
- File: `test/dashboard/lost_booking_headline_card_test.dart` (NEW)
- Description: Three widget tests:
  1. Healthy/watch/hot rendering. Pump the card with three pre-built `LostBookingsState`s (`currentRate = 0.05`, `0.10`, `0.20`). Assert a distinguishing finder per state: e.g. a `find.text('Consider a deposit policy')` only present at hot.
  2. Empty state: `currentRate == null` renders the "No completed or lost bookings yet" copy and no spinner.
  3. Sparkline renders 12 bars for 5-week data with 7 baselines (assert via the painter's `Semantics` description summarising the bar count, or via a test-only field on the painter exposing the rendered bar list).
- Acceptance: `flutter test test/dashboard/lost_booking_headline_card_test.dart` passes. No golden infra — plain finder assertions (RESEARCH §7).
- Checklist refs: 6.1
- Estimate: 60 min

### 8. Manual UAT

**Task 8.1 — Populated-shop sanity check.**
- Description: On a staging shop with real historical data, hand-compute the lost rate for the last 7 days from a `psql` query and confirm the headline card matches to the rounded percent.
- Acceptance: Hand-computed rate within ±0.1pp of the displayed rate; screenshot attached to the PR.
- Checklist refs: 8.2
- Estimate: 20 min

**Task 8.2 — Empty-shop check.**
- Description: Create a brand-new shop with zero terminal bookings. Open the Analytics > Revenue tab.
- Acceptance: Headline card shows the empty-state copy ("No completed or lost bookings in the last 7 days yet."), no spinner, no error banner. Screenshot attached.
- Checklist refs: 5.1, 6.1
- Estimate: 10 min

**Task 8.3 — Refresh-on-mutation check.**
- Description: On a staging shop, open the Analytics tab. From the daily-schedule UI on another navigation stack, cancel one booking. Return to Analytics.
- Acceptance: The card has re-fetched and the `cancelled` count incremented by 1. No pull-to-refresh required.
- Checklist refs: 3.4
- Estimate: 10 min

## Verification per task

| Task | Verification artifact |
|------|------------------------|
| 1.1 | `supabase db push` output + `\df+` showing 3 SECURITY DEFINER functions with `authenticated` grant only |
| 1.2 | Paste of `EXPLAIN ANALYZE` output into PR, confirming `Index Scan using idx_bookings_shop_id` |
| 1.3 | Paste of each smoke-test snippet's output into PR; `last_lost_at` snippet shows the later of the two timestamps |
| 2.1 | `flutter analyze` clean on the new file |
| 3.1 | `flutter analyze` clean on the modified repository interface |
| 3.2 | `flutter analyze` clean on the modified impl; happy-path fixture deserializes correctly (covered indirectly in 7.3) |
| 4.1 | `flutter analyze` clean; file < 20 lines |
| 4.2 | Dev-build trace: cancel a booking, observe tick increment via temporary listener |
| 4.3 | `flutter analyze` clean; controller compiles |
| 4.4 | `flutter analyze` clean; provider resolvable from a `ConsumerWidget` |
| 5.1 | Task 7.2 passes |
| 5.2 | Manual: 360pt-width visual check across healthy/watch/hot/empty/skeleton |
| 5.3 | Task 7.4 sparkline test passes |
| 5.4a | Manual: open sheet, switch between Breakdown and Repeat offenders tabs, both populated and empty data |
| 5.4b | Manual: switch to By weekday tab, both populated and empty data |
| 6.1 | Screenshot of Analytics > Revenue showing the new card above `QuarterlyRevenueChart` |
| 7.1 | `flutter test test/dashboard/lost_booking_summary_test.dart` green |
| 7.2 | `flutter test test/dashboard/lost_booking_thresholds_test.dart` green |
| 7.3 | `flutter test test/dashboard/lost_bookings_controller_test.dart` green |
| 7.4 | `flutter test test/dashboard/lost_booking_headline_card_test.dart` green |
| 8.1 | PR screenshot + hand-computation working |
| 8.2 | PR screenshot of empty state |
| 8.3 | PR screencast or before/after screenshots |

## Risk register

| # | Risk | Prob | Impact | Mitigation |
|---|------|------|--------|------------|
| R1 | `EXPLAIN ANALYZE` (Task 1.2) reveals a seq scan on large shops, blocking ship | Med | High | Pre-defined fallback: ship `20260603002500_lost_booking_partial_index.sql` with the partial index from RESEARCH §1 lines 58–62. Decision is data-driven, not speculative. |
| R2 | `bookingMutationProvider` triggers double-refetch when the user cancels via daily-schedule then navigates to analytics (state was already torn down + recreated) | Med | Low | `autoDispose` family naturally recovers; one extra round-trip is acceptable. Confirm in Task 8.3. |
| R3 | `last_lost_at` semantic confusion at code-review time — reviewer thinks SPEC is correct and asks why we deviate | Med | Low | RESEARCH §3 cited inline in the migration's function comment. PR description links the RESEARCH section. |
| R4 | Threshold change to 7%/12% surprises owners post-launch (cards turn amber for shops previously in "healthy") | Med | Med | Document as first-week tunable in PR description (RESEARCH §4). Single-constant change in `lost_booking_thresholds.dart` reverts. |
| R5 | Drill-down "By weekday" tab derives from `state.weeks` — if weekly series fails but summary succeeds, the tab shows empty | Med | Low | Empty-state copy per tab; tab itself still renders. Documented in `LostBookingDrilldownSheet` doc comment. |
| R6 | Sparkline `CustomPainter` painter colours fail to follow Theme on hot-reload theme switch | Low | Low | Resolve colours in the parent widget's `build`, pass into painter constructor (do not cache). Standard Flutter pattern. |
| R7 | Owner-cancelled-self overstates "client" lost rate | Med | Med | Documented in SPEC lines 55–59 as a v1 trade-off; surfaced in drill-down's Breakdown tab copy (when the 4th RPC ships in a future phase). v1 ships without distinction by design. |
| R8 | Guest bookings in summary but absent from offenders → offender row totals don't reconcile with headline counts | Med | Low | Silent for v1 per RESEARCH open question 2. Comment in `get_lost_booking_offenders` body explains the gap so a future maintainer doesn't "fix" it accidentally. |
| R9 | `AppLogger.warn` called with `e.toString()` accidentally — leaks DB error text into logs | Low | Med | Task 4.3 explicitly requires `error_code` not `error` in the fields map (RESEARCH §9 gap 4.4). Verified pattern is enforceable by reviewer grep. |
| R10 | `mocktail` test mock for `Ref.listen` is awkward → Task 7.3 disposed-guard test becomes brittle | Med | Low | Test the disposed-guard at the controller level only (StateNotifier listener), not through the provider family. The provider family is glue. |

## Checklist v3.1 coverage matrix

| Check ID | Tasks |
|----------|-------|
| 1.3 (graceful degradation) | 4.3, 7.3 |
| 1.4 (authz at every access) | 1.1, 1.3, 3.2 |
| 1.7 (stateless / sharding) | 4.1 |
| 1.8 (Big-O documented) | 1.1 (COMMENT ON FUNCTION), 2.1, 5.3 |
| 2.1 (input sanitization) | 1.1 (range checks), 1.3 |
| 2.4 (errors don't leak) | 1.1, 1.3, 3.1, 3.2, 4.3 |
| 2.5 (resource limits) | 1.1 (LIMIT 50 + range caps), 1.3 |
| 3.2 (no N+1) | 1.1 (single aggregate per RPC; controller uses Future.wait of three) |
| 3.3 (indexes verified) | 1.2 |
| 3.4 (cache strategy) | 4.2, 4.4 |
| 4.4 (PII in logs) | 4.3, 7.3 (assertion) |
| 4.5 (log levels) | 4.3 (`warn` not `error`) |
| 4.11 (configurable thresholds) | 4.1, 5.1 |
| 5.1 (actionable errors) | 5.2 (advisory chip), 5.4a (empty states), 5.4b (empty states), 8.2 |
| 5.2 (p95 ≤ 200ms or feedback ≤ 200ms) | 4.3 (sync isLoading), 5.2 (skeleton) |
| 5.5 (no internal info in UI) | 3.1, 3.2, 4.3, 5.2 |
| 5.6 (a11y, best-effort) | 5.2, 5.3 (Semantics summary) |
| 6.1 (edge cases) | 1.3, 7.1, 7.2, 7.4, 8.2 |
| 6.3 (concurrency / disposed guard) | 4.3, 7.3 |
| 6.4 (negative tests) | 1.3, 7.1, 7.3 |
| 6.13 (documentation) | 1.1 (COMMENT), 4.1, 5.1 |
| 8.1 (rollback procedure) | Rollout §Rollback |

P0-U items 1.4 / 1.5 / 2.4 / 2.5 / 5.5 are addressed by the RPC shape itself (SECURITY DEFINER + ownership check + range caps + sanitized errors + no `e.toString()` in UI). No gaps.

## Rollout

1. `supabase db push` to staging.
2. Run `supabase/tests/lost_booking_rpcs.sql` against staging. Verify `EXPLAIN` uses `idx_bookings_shop_id`; verify the `last_lost_at` assertion. Paste outputs into PR.
3. Smoke test each RPC from the Supabase SQL editor against three real shops (small / medium / large).
4. Ship Dart code behind no feature flag (additive widget; degrades to empty state on failure).
5. 24h log watch: `analytics.load_failed` events with `tag` matching `lost_booking_*`; any `42501` raised against `authenticated` callers (means an authz bug — escalate).
6. Promote staging migration to prod via the normal migration deploy.
7. Post-launch +1 week: pull usage signal on drill-down opens. If owners are not tapping in, the headline alone is doing its job and no follow-up is needed.

### Rollback (Tier 2 manual — checklist 8.1)

1. Revert the merge commit: `git revert <merge-sha>` and redeploy the Flutter binary. The widget is removed; no schema reversal needed yet.
2. If the migration must also be rolled back, ship `20260603002001_revert_lost_booking_rpcs.sql` containing `DROP FUNCTION IF EXISTS public.get_lost_booking_summary(UUID, INTEGER); DROP FUNCTION IF EXISTS public.get_lost_booking_weekly_series(UUID, INTEGER); DROP FUNCTION IF EXISTS public.get_lost_booking_offenders(UUID, INTEGER, INTEGER);`. Apply via `supabase db push`. Target time-to-recovery ≤ 30 min (Tier 2).
3. The widget is purely additive — neither step disturbs the existing revenue surface.

## Definition of done

- [ ] Migration `20260603002000_lost_booking_rpcs.sql` applied to prod.
- [ ] `supabase/tests/lost_booking_rpcs.sql` outputs pasted to PR; index plan confirmed.
- [ ] `flutter analyze` clean on every file in `## Files touched`.
- [ ] All four test files (7.1, 7.2, 7.3, 7.4) green locally and in CI.
- [ ] Analytics > Revenue tab shows the headline card on a populated shop with the rate visibly matching a hand-computation.
- [ ] Analytics > Revenue tab shows the empty-state copy on a brand-new shop.
- [ ] Cancelling a booking via the daily-schedule UI causes the analytics card to re-fetch and the count to increment without a pull-to-refresh.
- [ ] Drill-down sheet opens on tap and the Repeat-offenders tab lists offenders for a populated shop and shows the empty-state copy for a clean shop.
- [ ] PR description flags the 7%/12% thresholds as first-week tunable per RESEARCH §4.
- [ ] Every checklist row in the coverage matrix above is verified — at minimum by inspecting the cited task's verification artifact.
- [ ] No `AppLogger` call site fires with `e.toString()` in its `fields` map (grep gate: `grep -rn "AppLogger\." lib/presentation/features/shops/dashboard/presentation/controllers/lost_bookings_controller.dart | grep -v '^#' | grep -c "e.toString" == 0`).
- [ ] No `withOpacity` in any new widget file (grep gate: `grep -rn "withOpacity" lib/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/ | grep -v '^#' | grep -c withOpacity == 0`).
- [ ] Rollback runbook from `## Rollout > Rollback` is reviewed and the revert migration file path is pre-staged in the team's runbook tracker.

## Effort check vs 1.5-day SPEC ceiling

| Phase | Tasks | Minutes |
|-------|-------|---------|
| 1. Migration | 1.1, 1.2, 1.3 | 120 |
| 2. Models | 2.1 | 30 |
| 3. Repo | 3.1, 3.2 | 60 |
| 4. Controller / signal | 4.1, 4.2, 4.3, 4.4 | 110 |
| 5. Widgets | 5.1, 5.2, 5.3, 5.4a, 5.4b | 290 |
| 6. Screen integration | 6.1 | 15 |
| 7. Tests | 7.1, 7.2, 7.3, 7.4 | 165 |
| 8. Manual UAT | 8.1, 8.2, 8.3 | 40 |
| **Total** | | **830 min ≈ 13.8h** |

Lands at ~1.7 engineering days (830 min / 60 = 13.8h). Within the SPEC's ceiling if interpreted loosely. If pressed for time, defer: Task 5.4b (By weekday tab, 45 min) is the cleanest defer — the headline card + sparkline + Breakdown + Repeat-offenders tabs (Task 5.4a) is the genuine MVP.

## PLAN COMPLETE
