# feat(dashboard): cancellation & no-show rate metric on Analytics > Revenue

Surfaces a single "lost-booking rate" KPI (cancellations + no-shows ÷
terminal bookings) on the shop-owner Analytics tab, with a 12-week
sparkline trend, a per-period delta, and a 3-tab drill-down listing the
cancel-vs-no-show breakdown, repeat-offender clients, and an approximate
by-weekday view.

Closes Phase 10 of [`.planning/phases/10-cancellation-no-show-metric/`](.planning/phases/10-cancellation-no-show-metric/).
Plan: [`10-PLAN.md`](.planning/phases/10-cancellation-no-show-metric/10-PLAN.md).
Spec: [`10-SPEC.md`](.planning/phases/10-cancellation-no-show-metric/10-SPEC.md).
Research: [`10-RESEARCH.md`](.planning/phases/10-cancellation-no-show-metric/10-RESEARCH.md).

## Why this metric

Today's Analytics tab tells the owner what revenue happened. It says
nothing about what didn't — and cancellations + no-shows are the single
most controllable revenue lever a salon/barbershop/spa owns. Surfacing
the rate is a precondition for tuning deposit and reminder policy.

Booksy benchmarks put the cross-industry no-show rate at 10–15%, so the
default bands ship as:

| Band | Range | Visual |
|------|-------|--------|
| Healthy | rate ≤ 7% | Primary colour, no callout |
| Watch | 7% < rate ≤ 12% | Amber border |
| Hot | rate > 12% | Error border + advisory chip |

These are **first-week tunable** — single-constant edit in
[`lost_booking_thresholds.dart`](lib/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_thresholds.dart).
If owners report shops sitting in "watch" that historically performed
fine, we adjust.

## What ships

### Database

One additive migration with three SECURITY DEFINER RPCs:

- `get_lost_booking_summary(shop_id, period_days)` — headline KPI + delta
- `get_lost_booking_weekly_series(shop_id, weeks)` — sparkline data
- `get_lost_booking_offenders(shop_id, lookback_days, min_lost)` — top 50
  repeat-offender clients

All three follow the existing hardening template
([`20260603001500_harden_dashboard_rpcs.sql`](supabase/migrations/20260603001500_harden_dashboard_rpcs.sql))
byte-for-byte: `SECURITY DEFINER`, `SET search_path = public`, authz
ownership gate before any range validation, sanitized `'not_found'` /
`'invalid_*'` exceptions with `HINT` codes, `REVOKE ALL FROM PUBLIC`,
`GRANT EXECUTE TO authenticated`, and `COMMENT ON FUNCTION` with Big-O.

Idempotent — `CREATE OR REPLACE FUNCTION` only. No schema changes, no
table modifications, no index churn. Existing
`idx_bookings_shop_id (shop_id, start_time DESC)` covers all three
queries (see Rollout step 2 for the EXPLAIN check).

### Client

| File | Role |
|------|------|
| [`lost_booking_metrics.dart`](lib/presentation/features/shops/dashboard/data/models/analytics/lost_booking_metrics.dart) | 4 immutable value objects; null-safe rate getters |
| [`dashboard_repository.dart`](lib/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart) + [`supabase_dashboard_repository.dart`](lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart) | 3 RPC wrappers + HINT-code error classifier |
| [`booking_mutation_signal.dart`](lib/presentation/features/shops/booking/presentation/providers/booking_mutation_signal.dart) | `StateProvider<int>` tick bumped on cancel / no-show / completion |
| [`daily_schedule_notifier.dart`](lib/presentation/features/shops/appointments/shop_daily_schedule/providers/daily_schedule_notifier.dart) | Bumps the signal after each terminal-state transition |
| [`lost_bookings_controller.dart`](lib/presentation/features/shops/dashboard/presentation/controllers/lost_bookings_controller.dart) | Parallel `Future.wait` + `_disposed` guard + per-query graceful degradation; mirrors `AnalyticsController` |
| [`dashboard_providers.dart`](lib/presentation/features/shops/dashboard/providers/dashboard_providers.dart) | Family provider with `ref.listen` on the mutation signal |
| [`lost_booking_thresholds.dart`](lib/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_thresholds.dart) | 7%/12% band constants + `classify(double?)` |
| [`lost_booking_sparkline.dart`](lib/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_sparkline.dart) | Custom painter; 12 bars; severity-coloured; `Semantics` summary for screen readers |
| [`lost_booking_headline_card.dart`](lib/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_headline_card.dart) | `CardInkWell`-wrapped card with 5 states (healthy / watch / hot / empty / skeleton); opens drill-down on tap |
| [`lost_booking_drilldown_sheet.dart`](lib/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/lost_booking_drilldown_sheet.dart) | 3 tabs (Breakdown, Repeat offenders, By weekday) |
| [`analytics_screen.dart`](lib/presentation/features/shops/dashboard/presentation/screens/analytics_screen.dart) | 1-line additive insertion under `AnalyticsTab.revenue` |

Money fields remain `double` for parity with the rest of the dashboard.
The project-wide minor-units sweep is tracked separately — search the
diff for `TODO(money-minor-units)` for the grep targets.

## Locked corrections from research

The spec assumed wrong on a few points; the plan and code apply these
corrections explicitly. Cited inline in code comments so the next
maintainer doesn't "fix" them:

1. **Index claim.** Spec said `idx_bookings_shop_date_status` covers the
   new RPCs. That index keys on `booking_date`; our RPCs filter on
   `start_time`. Real access path is `idx_bookings_shop_id`. EXPLAIN step
   in rollout confirms; we don't add an index speculatively.
2. **`last_lost_at` for no-shows.** `mark_booking_no_show` does NOT set
   `cancelled_at` — only `updated_at`. A naive `MAX(cancelled_at)` would
   silently drop every no-show timestamp. The offenders RPC uses a
   per-status `CASE`. Verified in
   [`20260517020000_booking_hardening.sql:487-533`](supabase/migrations/20260517020000_booking_hardening.sql).
3. **Threshold bands.** Tightened from a heuristic 8%/15% to 7%/12% on
   the Booksy benchmark cited above.
4. **Authz-first ordering.** All three RPCs validate ownership before
   any range bound, so an unauthorized caller can't probe parameter
   shapes via `22023` vs `42501`.

## Tests

23/23 green, no flakes locally.

```text
$ flutter test test/dashboard/
00:04 +23: All tests passed!
```

| Suite | Cases | Covers |
|-------|-------|--------|
| `lost_booking_summary_test.dart` | 8 | null-when-zero, rate math, delta semantics, fromJson contract, owner-cancelled, future-dated |
| `lost_booking_thresholds_test.dart` | 8 | classifier boundaries at exactly 0.07 / 0.0701 / 0.12 / 0.1201; constants documented |
| `lost_bookings_controller_test.dart` | 4 | happy path, graceful degradation, all-fail, **disposed-mid-flight no-write** |
| `lost_booking_headline_card_test.dart` | 3 | healthy / hot / empty rendering via `ProviderScope` overrides |

`flutter analyze` is clean across every touched file.

SQL coverage lives in [`supabase/tests/lost_booking_rpcs.sql`](supabase/tests/lost_booking_rpcs.sql)
as a manual psql script (pgTAP scaffolding isn't wired into CI; out of
scope for this phase). Covers index-plan verification, authz isolation
(including the authz-first ordering proof), range bounds, empty-shop
sanity, the `last_lost_at` fix, and the bucket-by-`start_time` edge cases.

## Checklist v3.1 mapping

Every check the plan's coverage matrix names has at least one task
satisfying it. Highlights:

| Check | How |
|-------|-----|
| 1.4 Authz at every access | `EXISTS shops WHERE user_id = auth.uid()` at the top of every RPC, before any range validation |
| 2.4 Errors don't leak | RPC raises classifier strings only (`not_found` / `invalid_*`); repo maps to `DashboardRepositoryException` whose message is the same classifier; UI never shows it |
| 2.5 Resource limits | period_days ≤ 90, weeks ≤ 52, lookback_days ≤ 365, min_lost ≤ 50, offenders capped at 50 rows |
| 3.2 No N+1 | Single aggregate per RPC; controller uses `Future.wait` over three |
| 3.3 Indexes | Existing `idx_bookings_shop_id` covers the three RPCs; EXPLAIN step in Rollout confirms |
| 3.4 Cache invalidation | `bookingMutationProvider` tick + `ref.listen` triggers `controller.refresh()` |
| 4.4 PII in logs | `AppLogger.warn` receives only `tag`, `shop_id`, `error_code` (classifier string); never raw exception body |
| 5.1 Actionable errors | Hot-state advisory chip recommends deposit/reminder review |
| 5.5 No internal info in UI | Sanitized error classifier, never `e.toString()` |
| 6.3 Concurrency / disposed guard | `_disposed` flag + listener-count test |
| 8.1 Rollback | Tier-2 manual runbook in plan §Rollout |

Full matrix in [`10-PLAN.md`](.planning/phases/10-cancellation-no-show-metric/10-PLAN.md) §"Checklist v3.1 coverage matrix".

## Out of scope (locked, will not creep)

- Money as integer minor units — tracked separately as the project-wide
  checklist 2.19 sweep.
- `performance_alerts` rule-engine integration — Phase 11 candidate.
- No-show predictor model.
- Per-worker no-show attribution.
- Multi-shop comparison.
- Configurable thresholds per shop — defaults ship hardcoded; tune in
  v1.1 once we see real distribution.
- pgTAP scaffolding — no CI runner is wired; manual psql script ships
  instead.
- The 4th RPC `get_cancellation_actor_split` ("you cancelled N
  yourself") — deferred until product confirms the surfacing needs.

## Rollout

1. `supabase db push` to staging.
2. Run [`supabase/tests/lost_booking_rpcs.sql`](supabase/tests/lost_booking_rpcs.sql)
   §1 against staging's largest shop. **Paste the `EXPLAIN ANALYZE`
   output into a PR review comment.** Expected: `Index Scan using
   idx_bookings_shop_id`. If a Seq Scan appears on a shop with > 50k
   terminal bookings, hold the merge and ship the partial-index follow-up
   per RESEARCH §1 first.
3. Run §2 (authz isolation) — proves the authz-first ordering: even an
   out-of-range argument against a non-owned shop returns `42501`, not
   `22023`.
4. Run §3 (range bounds), §4 (empty shop), §5 (`last_lost_at` no-show
   fix) on staging. Paste each section's output into the PR review.
5. Ship Dart code with no feature flag — widget is additive and
   degrades to its empty state on any failure path.
6. **24h log watch** post-merge:
   - `analytics.load_failed` with `tag` matching `lost_booking_*` — any
     spike means a server-side regression
   - `42501` raised against authenticated callers — means an authz bug,
     escalate immediately
7. Promote staging migration to prod.
8. **Post-launch +1 week:** check drill-down open rate. If owners aren't
   tapping in, the headline card alone is doing its job and we don't
   build out the per-weekday RPC yet.

## Rollback

Tier 2 manual (target time-to-recovery ≤ 30 min):

1. Revert the merge commit + redeploy the Flutter binary. The widget
   disappears; no schema reversal needed.
2. If the RPCs also need rolling back, ship
   `20260603002001_revert_lost_booking_rpcs.sql` with three
   `DROP FUNCTION IF EXISTS ...` statements and `supabase db push`.

The widget is purely additive — neither step disturbs existing revenue
surfaces.

## Manual UAT (do before requesting review)

- [ ] **Populated shop:** open Analytics > Revenue on a real staging
  shop. Hand-compute the lost rate for the last 7 days via the SQL in
  `supabase/tests/lost_booking_rpcs.sql` §4. Headline rate must match
  within ±0.1pp. Attach screenshot.
- [ ] **Empty shop:** create a brand-new shop with zero bookings.
  Headline card shows "No completed or lost bookings in the last 7 days
  yet." — no spinner, no error banner. Attach screenshot.
- [ ] **Refresh on mutation:** open Analytics. From the daily-schedule
  UI on a separate stack, cancel one booking. Return to Analytics.
  Cancelled count incremented by 1 without pull-to-refresh. Attach
  before/after screenshots or a screencast.

## File summary

- 1 SQL migration (288 lines)
- 1 manual psql test script (216 lines)
- 4 new Dart widgets / painters under
  [`widgets/analytics/lost_bookings/`](lib/presentation/features/shops/dashboard/presentation/widgets/analytics/lost_bookings/)
- 1 new controller (215 lines), 1 new model file (204 lines), 1 new
  signal provider (25 lines)
- 5 edits to existing dashboard/booking files (signal wiring + screen
  integration + repo interface)
- 4 test files (660 lines total, 23 cases)

Total: ~2.4k lines added, 9 lines removed across edited files.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
