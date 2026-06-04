# Phase 10 Research — Cancellation & No-Show Metric

## Summary

We are adding a single "lost-booking rate" KPI card to the Analytics tab of the
shop-owner dashboard, backed by three new SECURITY DEFINER RPCs and three new
widgets. The change is low-risk because it is purely additive — no schema
change, no mutation, no edit to the existing analytics surface beyond a single
widget insertion at `analytics_screen.dart`.

There is **one spec assumption that must be revised before planning**: the SPEC
claims `idx_bookings_shop_date_status` covers all three RPCs. It does not. The
real index is `(shop_id, booking_date, status)` but every new RPC filters on
`start_time`. The planner must add a new partial index (or rewrite the RPCs to
filter on `booking_date`). See §1.

The other notable correction: guest bookings are a first-class population in
this codebase (`bookings.user_id` is nullable, see
`supabase/migrations/20260528120000_link_booking_guest_support.sql:50`). The
offenders RPC's `user_id IS NOT NULL` filter is correct for v1 but the planner
should explicitly count the guest-loss bucket in the headline rather than
silently dropping it. See §2.

## Findings

### 1. Index coverage — SPEC is WRONG

The existing index is defined at
`supabase/migrations/20260517010000_booking_schema.sql:154-155`:

```sql
CREATE INDEX IF NOT EXISTS idx_bookings_shop_date_status
  ON bookings (shop_id, booking_date, status);
```

The index key is `booking_date`, NOT `start_time`. All three SPEC RPCs filter
on `start_time` (`10-SPEC.md:127, 198-199, 280-282`). Postgres will not use a
`(shop_id, booking_date, status)` index to satisfy a `WHERE shop_id = X AND
start_time >= Y` predicate — `start_time` is not a leading column and is not
in the index at all.

The query will degrade to either:
- An `idx_bookings_shop_id` (key: `(shop_id, start_time DESC)`) index scan, which
  *is* serviceable since `start_time` is part of that key (line 148). This is
  the realistic fallback Postgres will pick.
- A seq scan on small shops.

So the queries will likely run on `idx_bookings_shop_id`. Status filtering and
the FILTER aggregates happen post-fetch. Acceptable for v1.

**Planner instruction:** Strike the "covered by `idx_bookings_shop_date_status`"
language from the SPEC and replace with: *"Queries use `idx_bookings_shop_id`
(`shop_id, start_time DESC`) as the primary access path; status filtering is
post-index. Add a partial covering index ONLY if EXPLAIN ANALYZE shows a
sequential scan on shops with > 50k terminal bookings."* If a covering index is
needed later:

```sql
CREATE INDEX idx_bookings_shop_terminal_starttime
  ON bookings (shop_id, start_time DESC)
  WHERE status IN ('completed','cancelled','no_show');
```

The phase plan should include a Wave-N task: run `EXPLAIN ANALYZE` against a
real shop after migration apply, attach the output to the PR, and only then
decide whether to ship the partial index. SPEC line 312–322's `EXPLAIN` step
exists but is mis-stated about which index will fire.

### 2. Repeat-offender RPC scope — guests + profiles RLS

**Guest bookings.** Since `20260528120000_link_booking_guest_support.sql:50`
the `bookings.user_id` column is nullable and a `bookings_user_or_guest_chk`
constraint (line 68) enforces exactly-one-of (`user_id`, `guest_profile_id`).
Guest bookings are not a fringe case — the web booking flow at
`aura-in-web.vercel.app/book/<slug>` is the guest path and is in production.

The SPEC's offender RPC filters `b.user_id IS NOT NULL`
(`10-SPEC.md:281`), which silently drops the entire guest population from the
offenders list. **This is acceptable for v1** (the offenders table needs a
joinable identity), but the SPEC also currently lets guest bookings into the
headline RATE (the summary RPC has no `user_id IS NOT NULL` filter). That is
the correct behavior — guests should count toward the headline because they
cancel and no-show at least as often as logged-in clients.

**Planner instruction:** Keep guests in the summary and weekly-series RPCs.
Exclude them from offenders RPC for v1. In the drill-down sheet's "Repeat
offenders" tab, add a footer line: *"Excludes N guest bookings — guests don't
have stable identity to attribute repeats."* The `N` is derivable client-side
from `(summary.lost) - SUM(offender.lost_bookings)` or via a tiny extra count.
Decide which during planning; the cheaper option is to skip the footer in v1
and document the gap inline.

**`profiles` RLS interaction.** The offenders RPC LEFT JOINs `profiles` from a
SECURITY DEFINER context. `profiles_select_public` at
`supabase/migrations/20260521020000_profiles_username_unique_and_rls.sql:31-35`
already permits `authenticated` to SELECT any profile row, so there is no
privacy boundary being crossed — the shop owner can already query any
profile by `id` directly. The join is safe. No additional check needed.

### 3. `cancelled_at` semantics — only `cancel_booking` sets it; `mark_booking_no_show` does NOT

`cancel_booking` at `supabase/migrations/20260517020000_booking_hardening.sql:421-426`
sets `cancelled_at = now()`. `mark_booking_no_show` at lines 487-533 of the
same file does NOT touch `cancelled_at` — it only sets `status = 'no_show'`
and `updated_at = now()`.

This breaks the SPEC's `MAX(b.cancelled_at) FILTER (WHERE b.status IN
('cancelled','no_show')) AS last_lost_at` aggregate (`10-SPEC.md:277-278`). For
no-show rows, `cancelled_at` is always NULL, so `MAX()` will return only the
last *cancellation* time for that client and ignore their no-shows.

**Planner instruction:** Change `last_lost_at` in the offenders RPC to:

```sql
MAX(CASE
  WHEN b.status = 'cancelled' THEN b.cancelled_at
  WHEN b.status = 'no_show'   THEN b.updated_at
END) AS last_lost_at
```

This is correct because the `mark_booking_no_show` RPC sets `updated_at = now()`
at the moment of transition (line 522) and no other path in the codebase mutates
a no-show row after that point. The planner should include a SQL test that
creates one cancellation and one no-show for the same client, runs the RPC,
and asserts `last_lost_at` is the later of the two timestamps.

Alternative (cleaner but bigger blast radius): add a migration that backfills
and starts populating a single `terminal_at` timestamp on every cancel/no-show
transition. **Out of scope** — defer to a future phase.

### 4. Threshold colour bands — industry benchmarks

The SPEC's `≤ 8%` healthy / `8–15%` watch / `> 15%` hot bands are reasonable
but un-cited. Industry signal from Booksy
([Crafting A 'No-Show' Policy](https://biz.booksy.com/en-us/blog/no-show-policy-tips))
states the cross-industry average is 10–15% and salons "should aim to keep their
no-shows below this range." Forgetfulness is the #1 cause (28.4% of consumers).

Two adjustments worth making:

- **Hot at 15% is too lenient.** Booksy explicitly frames 10–15% as "industry
  average" — not a healthy target. Recommend tightening to: healthy ≤ 7%,
  watch 7–12%, hot > 12%. This puts the "watch" band at the industry average
  and the "hot" band visibly above it.
- **Note the rate combines cancellations + no-shows.** Most published
  benchmarks are no-show only. Our combined metric will run higher by
  definition. The advisory chip copy should say "combined cancel + no-show
  rate" so an owner reading "industry average is 10%" doesn't think they're
  doing badly.

**Planner instruction:** Adopt 7/12% as defaults but expose them as named
constants in `lost_booking_thresholds.dart` so the first-week tuning is a
one-line change, not a sweep across the painter. Flag in the PR description
that these are first-week tunables.

### 5. Refresh signal — `bookingMutationProvider` wiring

The booking-mutation surface is centralized in two places:

- `lib/presentation/features/shops/booking/data/repositories/supabase_booking_repository.dart:397` (`markAsNoShow`)
- `lib/presentation/features/shops/booking/data/repositories/supabase_booking_repository.dart:946` (`cancelBooking`)

The repository methods are invoked from:

- `lib/presentation/features/shops/appointments/shop_daily_schedule/providers/daily_schedule_notifier.dart:78-91` — `DailyScheduleNotifier.cancelBooking` and `markBookingAsNoShow`. Both end with `refreshDate(date)` — local to the daily-schedule cache only. They do not signal anything else.
- `lib/presentation/features/shops/booking/presentation/screens/shared/booking_detail_screen.dart:185` — invalidates `bookingDetailProvider` post-action.

There is no existing `bookingMutationProvider`. The lightest wiring:

1. Add `lib/presentation/features/shops/booking/presentation/providers/booking_mutation_signal.dart` exposing a `StateProvider<int>` whose value bumps on every cancel/no-show/complete. (StateProvider not Notifier — tick semantics, no payload required.)
2. Bump it in two places: at the end of `DailyScheduleNotifier.cancelBooking` and `markBookingAsNoShow` (lines 83, 89). Both currently swallow the booking model return; bumping a counter is a one-liner.
3. The new `LostBookingsController` listens via `ref.listen` and calls `loadAnalytics()` on tick. Use `ref.listen`, not `ref.watch`, so we don't tear down state on every tick.

**Planner instruction:** Wire as above. Do NOT route the signal through the
repository — the repository must stay free of Riverpod refs. Booking detail
screen already invalidates the per-booking provider, which is orthogonal.

Note: `booking_detail_screen.dart:185` also calls `ref.invalidate(...)` for
something — the planner should verify it isn't a redundant signal we can also
hook into.

### 6. Widget patterns to mimic / reuse

- **Headline card chrome** — `revenue_comparison_card.dart:41` wraps in
  `CardInkWell` with a `BottomSheetUtils.showDocumentationBottomSheet` on tap.
  The new `LostBookingHeadlineCard` should use the same wrapper to keep tap
  affordances and elevation consistent. Card layout is `Row` of
  `_ComparisonItem` children — useful precedent for the headline rate + delta +
  lost revenue triplet.
- **Bar chart / sparkline** — `quarterly_revenue_chart.dart:2,110` uses
  `fl_chart`'s `BarChart` + `BarChartGroupData` + `BarChartRodData`. It is
  *fully* coupled to `YearlyRevenue` (`quarters` list, `amount` field) — the
  painter is not extractable. **Do not try to reuse it.** Build
  `LostBookingSparkline` as a thin CustomPainter (no fl_chart) — 12 bars is
  small enough that a 30-line painter beats pulling fl_chart's `BarChart`
  through configuration gymnastics. Match the visual idiom (rounded top, 1px
  baseline) but own the code.
- **Theme tokens** — `quarterly_revenue_chart.dart:6` imports `design_tokens.dart`;
  `revenue_comparison_card.dart:5` imports `app_colors.dart`. Both new widgets
  must use these, not literal hex.
- **fl_chart is already a project dependency** — no need to add anything for the
  drill-down's "by weekday" sub-tab.

### 7. Test infrastructure

`test/` exists (`test/booking/`, `test/chat/`, `test/payment/`, etc.) — the SPEC
asserts there is no `test/` directory; that is incorrect. Existing tests use
`flutter_test` (e.g. `test/booking/booking_validators_test.dart`). The booking
test directory is the right place for new controller + model unit tests.

`supabase/tests/` does NOT exist. No pgTAP runner is wired into CI. SPEC test
items #1–#6 ("SQL") have no current runner.

**Planner instruction:**

- Dart unit tests for `LostBookingSummary.currentRate`, threshold-band selection,
  and the controller's graceful-degradation path go in
  `test/dashboard/lost_bookings_controller_test.dart` (create directory). Use
  `mocktail` (already in pubspec — verify).
- For SQL: do NOT add a pgTAP runner in this phase. Replace SPEC's pgTAP items
  with a `supabase/tests/lost_booking_rpcs.sql` file containing executable psql
  snippets that an engineer can run manually post-migration (the same shape as
  the EXPLAIN block already in the SPEC). Document in the PR: "SQL tests are
  manual; pgTAP scaffolding is a future testing-foundation phase."
- Widget tests for the headline card (Healthy/Watch/Hot rendering) go in
  `test/dashboard/lost_booking_headline_card_test.dart`. Use
  `flutter_test`'s golden testing only if there's already golden infrastructure
  — otherwise use plain finder assertions.

### 8. Money handling

The SPEC's decision to keep `lost_revenue` as `double` is consistent with the
rest of the dashboard. `RevenueComparisonCard` takes `double weeklyRevenue` and
friends (`revenue_comparison_card.dart:11-23`); `YearlyRevenue.quarters[i].amount`
is double; the `get_revenue_comparisons` RPC pipeline serializes to JSON
numbers. There is no money-in-minor-units anywhere in the dashboard layer today.

**Planner instruction:** Do not attempt the minor-units conversion in this
phase. Add a `TODO(money-minor-units)` comment on the `lostRevenue` field of
`LostBookingPeriod` referencing checklist item 2.19, so the eventual sweep has
a grep target. No new code rule beyond that.

### 9. Checklist v3.1 coverage gaps

Re-reading `algorithm_quality_review_checklist.md` against the SPEC's checklist
mapping section (`10-SPEC.md:504-521`), the following items are either missing
or hand-wavy:

| # | Gap | Required action |
|---|-----|------------------|
| 1.8 | Big-O claim "O(B + C log C)" for offenders is hand-wavy — the GROUP BY is O(B) and the ORDER BY OFFSET is implicit. State concretely: O(B) where B = bookings in lookback window for the shop. | Restate in plan task #1's commit message. |
| 2.5 | Resource limits cover RPC inputs. **Missing:** result-size cap on offenders. SPEC §3.1 says "capped at the natural per-shop client population … not needed for v1" but a busy shop with 1000 clients each with 2 lost would emit 1000 rows. Add `LIMIT 50` to the offenders RPC. | Planner enforces `LIMIT 50` in SQL. |
| 4.4 | PII glossary requires redacting "full names." The offenders RPC RETURNS `display_name` straight from `profiles.display_name`. That's not log — it's payload — but the AppLogger lines that fire on RPC failure must not echo any offender payload. | Add explicit instruction: `AppLogger.warn` calls in the offenders fetcher MAY include `shop_id` and `error_code`, must NOT include any element of the response body. |
| 4.5 | SPEC mentions `analytics.load_failed`. Confirm log level. | Use `AppLogger.warn` (matches `analytics_controller.dart:184` precedent), not `error`. |
| 5.1 | "Hot" state advisory is one string. Spec doesn't define what happens when the rate is `null` (no terminal bookings). SPEC §"Edge state" on `LostBookingHeadlineCard` covers it; SPEC's checklist row 5.1 doesn't reference that. | Cross-reference in plan. |
| 5.2 | p95 ≤ 200ms for in-app interactive paths. The headline card render is local once state is hydrated; the RPC fetch is the external hop. Per checklist 5.2's external-dep carve-out, target is "loading indicator within 200ms." | Add to plan: ensure the controller emits `isLoading: true` synchronously before the first await, and `LostBookingHeadlineCard` renders a skeleton when `state.isLoading && state.summary == null`. |
| 6.1 | Edge cases listed in SPEC §"Edge cases (resolve up-front)" are good but the test list (§Tests > Dart) doesn't cover them all. Add tests for: same-day cancellation counted; future-dated cancellation excluded from current period; owner-cancellation still counted. | Add to plan's test matrix. |
| 6.3 | Concurrency — RPCs are read-only, but the controller's `Future.wait` parallelism could double-fire on rapid pull-to-refresh. Add the same `_disposed` guard as `analytics_controller.dart:96,113,153`. | Lift the disposed-guard pattern into the new controller. |
| 8.1 | Rollback procedure: SPEC §Rollout doesn't list one. Per checklist Tier-2 (manual runbook), require: revert migration + delete the new widget import from `analytics_screen.dart`. The widget is additive so the rollback is non-destructive. | Add a "rollback" subsection to plan. |

P0-U items (1.4, 1.5, 2.4, 2.5, 5.5) are already addressed by the SPEC's RPC
shape (SECURITY DEFINER + ownership check + range cap + sanitized errors +
no `e.toString()` in UI). No gaps there.

## Recommendations for the planner

- **Strike the SPEC's index claim.** The queries will use `idx_bookings_shop_id`. Add an `EXPLAIN ANALYZE` task to the plan post-migration. Defer the partial covering index unless EXPLAIN shows seq scan.
- **Change `last_lost_at` aggregation** to `MAX(CASE WHEN status='cancelled' THEN cancelled_at WHEN status='no_show' THEN updated_at END)`. Add a SQL test for this.
- **Keep guest bookings in summary/weekly-series RPCs.** Exclude from offenders. Skip the offender-tab guest-count footer in v1.
- **Tighten thresholds to 7% / 12%** with named constants; flag as first-week tunable.
- **Add `bookingMutationProvider` as a `StateProvider<int>` tick counter**, bumped in `DailyScheduleNotifier.cancelBooking` and `markBookingAsNoShow`. Listen, don't watch.
- **Build `LostBookingSparkline` as a hand-rolled CustomPainter**, not via fl_chart. Don't try to reuse `quarterly_revenue_chart.dart`.
- **Headline card wraps in `CardInkWell`** like `RevenueComparisonCard`; open the drill-down via `BottomSheetUtils.showDocumentationBottomSheet`.
- **Tests go under `test/dashboard/`** (new dir). Skip pgTAP. Use `supabase/tests/lost_booking_rpcs.sql` as a manual psql script for SQL coverage.
- **Add `LIMIT 50` to the offenders RPC.** SPEC says "natural cap" — make it explicit.
- **Money stays double.** Annotate with `TODO(money-minor-units)` for the future sweep.
- **Mirror analytics_controller's `_disposed` guard pattern** in `LostBookingsController` to prevent state writes after disposal.
- **Document the rollback procedure** (Tier 2 manual) in the plan.

## Open questions for the user

1. **P1 — Threshold defaults.** Adopt 7% / 12% (industry-aware) or stick with SPEC's 8% / 15% (looser, less alarming)? Recommendation: 7% / 12%. The planner can proceed with these and the user can tune in the PR if they disagree.
2. **P2 — Guest-bucket disclosure.** Should the drill-down's offenders tab show an "Excludes N guest bookings" footer in v1, or is silent exclusion fine? Recommendation: silent for v1 with an inline code comment. Revisit if owners ask "why do my offender counts not add up."
3. **P2 — Cancellation-actor 4th RPC (`get_cancellation_actor_split`).** SPEC says "defer if scope pressure." Recommendation: defer. Headline + sparkline + offenders is the MVP; the actor-split is polish that owners can see in the audit log already.

## RESEARCH COMPLETE
