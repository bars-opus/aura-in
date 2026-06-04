# Phase 10 — Cancellation & No-Show Rate Metric

## Outcome

Shop owners see, on the Analytics tab, a single headline KPI for "what
fraction of my bookings this period weren't honoured", with a
12-week sparkline and a drill-down into the offending bookings and
clients. Owners can act on it: tighten their deposit/reminder policy,
flag repeat-offender clients, or notice a sudden spike before it
becomes a revenue problem.

Success looks like: an owner opens the Analytics tab and within 5
seconds can answer

- "Is my no-show rate getting worse?"
- "Which clients keep doing this?"
- "Which day of the week is the worst?"

## Why now

- Dataset already exists — `bookings.status` includes `'cancelled'` and
  `'no_show'`; the booking-hardening migration added a state machine
  that timestamps each transition (`cancelled_at`).
- Current Analytics tab computes revenue by treating cancelled/no-show
  bookings as zero-revenue rather than as a signal. We're discarding
  the most actionable retention/operations data we have.
- Cancellation policy (deposit vs no-deposit, reminder cadence) is the
  single most controllable lever a service business owns. Surfacing
  the rate is a precondition for tuning it.

## Definitions

Lock these so the SQL, Dart model, and UI copy agree.

| Term | Definition |
|------|------------|
| **Honoured booking** | `status = 'completed'` |
| **Cancellation** | `status = 'cancelled'`. Counts regardless of who cancelled (client or shop). Reason and actor are surfaced in the drill-down but not in the headline rate. |
| **No-show** | `status = 'no_show'`. By definition: the booking time passed and the shop owner ran `mark_booking_no_show` — i.e. the client never arrived. |
| **Lost booking** | `cancellation + no_show` |
| **Booking universe (denominator)** | All bookings whose `start_time` falls inside the period and whose terminal status is one of `completed`, `cancelled`, `no_show`. Excludes `pending` and `confirmed` future bookings — they haven't had a chance to be honoured yet. |
| **Lost-booking rate** | `lost_bookings ÷ booking_universe`. Range [0, 1], display as %. |
| **Period** | Always rolling. Headline = last 7 days. Sparkline = 12 weeks (ISO weeks). Drill-down period = configurable but defaults to last 30 days. |
| **Repeat offender** | A client with ≥ 2 lost bookings in the last 90 days. Surfaced in drill-down with their lost-rate vs honour-rate. |

### Edge cases (resolve up-front)

- **Future-dated bookings in `cancelled` status**: a booking for next
  Tuesday cancelled today belongs to *next Tuesday's* period. We
  bucket by `start_time`, not by `cancelled_at`. (Tested in unit
  tests below.)
- **Same-day cancellation**: still counts as a cancellation.
- **Walk-ins / manually-added bookings**: included if and only if they
  follow the same state machine.
- **Cancellation by shop owner**: still counts. We surface "who
  cancelled" in the drill-down via `booking_audit_log.actor_id` so
  the owner can self-correct (e.g. "I cancelled 40% of these myself
  because a worker called in sick — that's a staffing issue, not a
  client problem"). This is shown but NOT excluded from the rate.
- **Bookings without any terminal status** (still `confirmed` after
  the slot passed — owner forgot to mark): excluded from denominator.
  Could be revisited but for v1 we don't want to penalise owners for
  forgetting to mark complete.
- **`pending` bookings that expire**: not in scope; the existing
  `expire_stale_pending_payments` job moves them out of `pending`
  but they never had `start_time` honoured semantics.

## Data sources (all exist today)

- `public.bookings` — has `status`, `start_time`, `shop_id`,
  `user_id`, `cancelled_at`, `cancellation_reason`, `total_amount`.
  Indexed on `(shop_id, start_time DESC)` via `idx_bookings_shop_id`.
- `public.booking_audit_log` — has `actor_id`, `action`,
  `target_id`. Used only in the drill-down to surface
  who cancelled.
- `public.profiles` — for client display name in the
  repeat-offender list.

No schema changes required. No new tables.

## Server

### RPC 1 — `get_lost_booking_summary(shop_id, period_days)`

Returns the headline KPI + period-over-period delta.

```sql
CREATE OR REPLACE FUNCTION public.get_lost_booking_summary(
  p_shop_id      UUID,
  p_period_days  INTEGER DEFAULT 7
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_owns_shop   BOOLEAN;
  v_now         TIMESTAMPTZ := now();
  v_curr_start  TIMESTAMPTZ;
  v_prev_start  TIMESTAMPTZ;
  result        JSONB;
BEGIN
  IF p_period_days IS NULL OR p_period_days < 1 OR p_period_days > 90 THEN
    RAISE EXCEPTION 'invalid_period' USING ERRCODE = '22023', HINT = 'RANGE_1_90';
  END IF;

  SELECT EXISTS (
    SELECT 1 FROM shops WHERE id = p_shop_id AND user_id = auth.uid()
  ) INTO v_owns_shop;
  IF NOT v_owns_shop THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  v_curr_start := v_now - (p_period_days || ' days')::INTERVAL;
  v_prev_start := v_curr_start - (p_period_days || ' days')::INTERVAL;

  WITH buckets AS (
    SELECT
      CASE
        WHEN start_time >= v_curr_start                       THEN 'curr'
        WHEN start_time >= v_prev_start AND start_time < v_curr_start THEN 'prev'
      END AS bucket,
      status,
      total_amount
    FROM bookings
    WHERE shop_id = p_shop_id
      AND start_time >= v_prev_start
      AND start_time <  v_now
      AND status IN ('completed','cancelled','no_show')
  )
  SELECT jsonb_build_object(
    'period_days', p_period_days,
    'window_start', v_curr_start,
    'window_end',   v_now,
    'current', jsonb_build_object(
      'total',         COUNT(*) FILTER (WHERE bucket = 'curr'),
      'honoured',      COUNT(*) FILTER (WHERE bucket = 'curr' AND status = 'completed'),
      'cancelled',     COUNT(*) FILTER (WHERE bucket = 'curr' AND status = 'cancelled'),
      'no_show',       COUNT(*) FILTER (WHERE bucket = 'curr' AND status = 'no_show'),
      'lost_revenue',  COALESCE(SUM(total_amount) FILTER (WHERE bucket = 'curr' AND status IN ('cancelled','no_show')), 0)
    ),
    'previous', jsonb_build_object(
      'total',         COUNT(*) FILTER (WHERE bucket = 'prev'),
      'honoured',      COUNT(*) FILTER (WHERE bucket = 'prev' AND status = 'completed'),
      'cancelled',     COUNT(*) FILTER (WHERE bucket = 'prev' AND status = 'cancelled'),
      'no_show',       COUNT(*) FILTER (WHERE bucket = 'prev' AND status = 'no_show')
    )
  ) INTO result
  FROM buckets;

  RETURN result;
END;
$$;

REVOKE ALL ON FUNCTION public.get_lost_booking_summary(UUID, INTEGER) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_lost_booking_summary(UUID, INTEGER) TO authenticated;
```

### RPC 2 — `get_lost_booking_weekly_series(shop_id, weeks)`

Sparkline data: rate per ISO week, oldest first, for the last N
weeks. Used to render the 12-bar trendline. Caps `weeks` at 52.

Output:
```json
{
  "weeks": [
    {"iso_year": 2026, "iso_week": 18, "start_date": "...", "total": 42, "lost": 5, "rate": 0.119},
    ...
  ]
}
```

```sql
CREATE OR REPLACE FUNCTION public.get_lost_booking_weekly_series(
  p_shop_id UUID,
  p_weeks   INTEGER DEFAULT 12
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_owns_shop BOOLEAN;
  v_start     DATE;
  result      JSONB;
BEGIN
  IF p_weeks IS NULL OR p_weeks < 1 OR p_weeks > 52 THEN
    RAISE EXCEPTION 'invalid_weeks' USING ERRCODE = '22023', HINT = 'RANGE_1_52';
  END IF;
  SELECT EXISTS (SELECT 1 FROM shops WHERE id = p_shop_id AND user_id = auth.uid())
    INTO v_owns_shop;
  IF NOT v_owns_shop THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  v_start := (CURRENT_DATE - (p_weeks * 7 || ' days')::INTERVAL)::DATE;

  WITH weekly AS (
    SELECT
      EXTRACT(ISOYEAR FROM start_time)::INT AS iso_year,
      EXTRACT(WEEK    FROM start_time)::INT AS iso_week,
      DATE_TRUNC('week', start_time)::DATE  AS week_start,
      COUNT(*)                              AS total,
      COUNT(*) FILTER (WHERE status IN ('cancelled','no_show')) AS lost
    FROM bookings
    WHERE shop_id = p_shop_id
      AND start_time >= v_start
      AND start_time <  now()
      AND status IN ('completed','cancelled','no_show')
    GROUP BY 1, 2, 3
  )
  SELECT jsonb_build_object(
    'weeks', COALESCE(jsonb_agg(
      jsonb_build_object(
        'iso_year',  iso_year,
        'iso_week',  iso_week,
        'start_date', week_start,
        'total',     total,
        'lost',      lost,
        'rate',      ROUND(lost::NUMERIC / NULLIF(total, 0), 4)
      ) ORDER BY iso_year, iso_week
    ), '[]'::jsonb)
  ) INTO result
  FROM weekly;

  RETURN result;
END;
$$;

REVOKE ALL ON FUNCTION public.get_lost_booking_weekly_series(UUID, INTEGER) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_lost_booking_weekly_series(UUID, INTEGER) TO authenticated;
```

### RPC 3 — `get_lost_booking_offenders(shop_id, lookback_days, min_lost)`

Returns clients with ≥ `min_lost` lost bookings in `lookback_days`,
sorted by lost-rate desc. Capped at 50 rows.

Output: array of `{client_id, display_name, avatar_url, total_bookings, lost_bookings, lost_rate, last_lost_at}`.

```sql
CREATE OR REPLACE FUNCTION public.get_lost_booking_offenders(
  p_shop_id       UUID,
  p_lookback_days INTEGER DEFAULT 90,
  p_min_lost      INTEGER DEFAULT 2
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_owns_shop BOOLEAN;
  v_since     TIMESTAMPTZ;
  result      JSONB;
BEGIN
  IF p_lookback_days IS NULL OR p_lookback_days < 7 OR p_lookback_days > 365 THEN
    RAISE EXCEPTION 'invalid_lookback' USING ERRCODE = '22023', HINT = 'RANGE_7_365';
  END IF;
  IF p_min_lost IS NULL OR p_min_lost < 1 OR p_min_lost > 50 THEN
    RAISE EXCEPTION 'invalid_min_lost' USING ERRCODE = '22023';
  END IF;

  SELECT EXISTS (SELECT 1 FROM shops WHERE id = p_shop_id AND user_id = auth.uid())
    INTO v_owns_shop;
  IF NOT v_owns_shop THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  v_since := now() - (p_lookback_days || ' days')::INTERVAL;

  WITH per_client AS (
    SELECT
      b.user_id,
      COUNT(*) AS total_bookings,
      COUNT(*) FILTER (WHERE b.status IN ('cancelled','no_show')) AS lost_bookings,
      MAX(b.cancelled_at) FILTER (WHERE b.status IN ('cancelled','no_show')) AS last_lost_at
    FROM bookings b
    WHERE b.shop_id = p_shop_id
      AND b.start_time >= v_since
      AND b.user_id IS NOT NULL
      AND b.status IN ('completed','cancelled','no_show')
    GROUP BY b.user_id
    HAVING COUNT(*) FILTER (WHERE b.status IN ('cancelled','no_show')) >= p_min_lost
  )
  SELECT jsonb_build_object(
    'offenders', COALESCE(jsonb_agg(
      jsonb_build_object(
        'client_id',      pc.user_id,
        'display_name',   COALESCE(p.display_name, p.username, 'Client'),
        'avatar_url',     p.avatar_url,
        'total_bookings', pc.total_bookings,
        'lost_bookings',  pc.lost_bookings,
        'lost_rate',      ROUND(pc.lost_bookings::NUMERIC / NULLIF(pc.total_bookings, 0), 4),
        'last_lost_at',   pc.last_lost_at
      ) ORDER BY pc.lost_bookings DESC, pc.last_lost_at DESC
    ), '[]'::jsonb)
  ) INTO result
  FROM per_client pc
  LEFT JOIN profiles p ON p.id = pc.user_id;

  RETURN result;
END;
$$;

REVOKE ALL ON FUNCTION public.get_lost_booking_offenders(UUID, INTEGER, INTEGER) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_lost_booking_offenders(UUID, INTEGER, INTEGER) TO authenticated;
```

### Index plan

The existing `idx_bookings_shop_date_status` covers all three RPCs.
Verify by running `EXPLAIN` after migration apply:

```sql
EXPLAIN ANALYZE
SELECT 1 FROM bookings
WHERE shop_id = 'TEST_UUID'
  AND start_time >= now() - INTERVAL '7 days'
  AND status IN ('completed','cancelled','no_show');
-- Expect: Index Scan using idx_bookings_shop_date_status
```

If a sequential scan appears for shops with > 50k bookings, add a
partial covering index — but defer until measured.

## Dart layer

### New model — `lib/.../data/models/analytics/lost_booking_metrics.dart`

```dart
class LostBookingSummary {
  final int periodDays;
  final DateTime windowStart;
  final DateTime windowEnd;
  final LostBookingPeriod current;
  final LostBookingPeriod previous;

  /// Lost-rate this period, [0.0, 1.0]. Returns null when there were
  /// zero terminal bookings (rate is undefined; UI shows em-dash).
  double? get currentRate => current.total == 0
      ? null
      : (current.cancelled + current.noShow) / current.total;

  double? get previousRate => previous.total == 0
      ? null
      : (previous.cancelled + previous.noShow) / previous.total;

  /// Percentage-point delta vs previous period. Null when either rate
  /// is undefined.
  double? get rateDelta => (currentRate == null || previousRate == null)
      ? null
      : currentRate! - previousRate!;
}

class LostBookingPeriod {
  final int total;
  final int honoured;
  final int cancelled;
  final int noShow;
  /// Sum of `total_amount` on lost bookings, in the shop's currency.
  final double lostRevenue;
}

class LostBookingWeek {
  final int isoYear;
  final int isoWeek;
  final DateTime startDate;
  final int total;
  final int lost;
  final double? rate;   // null if total == 0
}

class LostBookingOffender {
  final String clientId;
  final String displayName;
  final String? avatarUrl;
  final int totalBookings;
  final int lostBookings;
  final double lostRate;
  final DateTime? lastLostAt;
}
```

All money fields stay `double` for now (consistent with the rest of
the analytics layer). Money-as-minor-units is its own follow-up phase
that should sweep all dashboard models together — out of scope here.

### Repository additions

Add to `DashboardRepository`:

```dart
Future<LostBookingSummary> getLostBookingSummary({
  required String shopId,
  int periodDays = 7,
});

Future<List<LostBookingWeek>> getLostBookingWeeklySeries({
  required String shopId,
  int weeks = 12,
});

Future<List<LostBookingOffender>> getLostBookingOffenders({
  required String shopId,
  int lookbackDays = 90,
  int minLost = 2,
});
```

Implementations call the three RPCs directly. Sanitised errors via
the same `DashboardRepositoryException` already in use; nothing
new in the boundary.

### Controller — `LostBookingsController` (new family)

State: `LostBookingsState { summary, weeks, offenders, isLoading,
isRefreshing, error }`. Same shape as `AnalyticsController` — error
is a stable code string, never `e.toString()` (checklist 5.5).

Loading strategy: `Future.wait` the three RPCs in parallel (mirrors
the parallel-fetch pattern we just added to `AnalyticsController`).
Per-query graceful degradation: if `offenders` fails but `summary`
and `weeks` succeed, the headline still renders.

Provider: `lostBookingsControllerProviderFamily(LostBookingsParams)`
keyed by `(shopId, periodDays)`. Defaults match the SQL: 7-day
headline, 12-week series, 90-day offender lookback.

### Widget contracts

Three new widgets, all under
`lib/.../presentation/widgets/analytics/lost_bookings/`:

1. **`LostBookingHeadlineCard`** — top of Analytics > Revenue tab,
   above the existing `RevenueComparisonCard`.

   Layout:
   ```
   ┌────────────────────────────────────────────┐
   │  Lost bookings · last 7 days               │
   │                                            │
   │   12.4 %                ▲ +3.1 pp          │
   │   42 of 339             vs prev 7 days     │
   │                                            │
   │   ─▁▂▁▃▁▂▃▄▃▅▆          GHS 1,820 lost     │
   │   (12-week trend)        revenue           │
   └────────────────────────────────────────────┘
   ```

   States:
   - **Healthy** (rate ≤ 8%): primary colour, no callout.
   - **Watch** (8% < rate ≤ 15%): amber border.
   - **Hot** (rate > 15%): red border + small advisory chip "Consider
     a deposit policy or reminder cadence review".

   Tap → drill-down sheet (widget #3).

   Edge state: when `currentRate == null` (zero terminal bookings in
   the window) show "No completed or lost bookings in the last 7
   days yet." No spinner, no error.

2. **`LostBookingSparkline`** — pure painter. Takes `List<LostBookingWeek>`,
   paints 12 vertical bars, height proportional to `rate`. Bars
   coloured per threshold (same Healthy/Watch/Hot scale). Empty weeks
   are rendered as a 1-pixel baseline. Accessible via Semantics with a
   text summary ("12-week trend: 8% to 12%, rising").

3. **`LostBookingDrilldownSheet`** — opened via `BottomSheetUtils.showDocumentationBottomSheet`.

   Tabs:
   - **Breakdown**: pie/bar showing cancellations vs no-shows for the
     current period. Below: "Of these, you cancelled N yourself" —
     pulled by joining `booking_audit_log` (see "Cancellation actor"
     below).
   - **Repeat offenders**: list of `LostBookingOffender`. Each row
     shows display name + avatar, lost-rate badge, "Last X days ago".
     Tap → existing client detail screen.
   - **By weekday**: grouped bar chart. Same data as headline but
     bucketed by day-of-week. Surfaces "Saturdays are your worst day"
     patterns without a new RPC — derived client-side from the weekly
     series data already in state.

### Cancellation actor (drill-down only)

The "you cancelled N yourself" line in the Breakdown tab needs to
distinguish owner-initiated cancellations from client-initiated.
Source: `booking_audit_log` with `action = 'booking.cancel'` and
`actor_id = <owner_uid>`.

Implement as a 4th lightweight RPC `get_cancellation_actor_split` that
returns `{owner_cancelled, client_cancelled, unknown}` for the current
period. Defer if scope pressure — the headline + sparkline + offenders
list is the MVP; this is the polish.

### Wiring into Analytics tab

Edit `lib/.../presentation/screens/analytics_screen.dart`:

- Inside `AnalyticsTab.revenue`, insert `LostBookingHeadlineCard`
  immediately after `RevenueComparisonCard`. Wrap in a `Gap(Spacing.md.h)`.
- No change to the existing revenue widgets — additive only.

## Checklist v3.1 mapping

| # | Check | How this phase satisfies it |
|---|-------|------------------------------|
| 1.4 | Authz at every access point | All 3 (or 4) RPCs are SECURITY DEFINER + `EXISTS shops WHERE user_id = auth.uid()` at the top. RLS on `bookings` and `profiles` is the second layer. |
| 1.8 | Big-O documented | Per RPC. `get_lost_booking_summary` is O(B) over bookings in 2× period; `weekly_series` O(B) over weeks × period; `offenders` O(B + C log C) for the join + group. |
| 2.4 | Errors don't leak | RPC raises `not_found` for unauthorized, `invalid_*` for bad inputs — no balance/id leakage. Dart never interpolates `$e` into UI. |
| 2.5 | Resource limits | `period_days ≤ 90`, `weeks ≤ 52`, `lookback_days ≤ 365`. Hard SQL guards. |
| 3.1 | Pagination / max page size | Offenders capped at the natural per-shop client population (server-side limit added if it grows past 200 — track as TODO; not needed for v1). |
| 3.2 | No N+1 | Single SQL aggregate per RPC. Dart calls 3 RPCs in parallel via `Future.wait`. |
| 3.3 | Indexes verified | `idx_bookings_shop_date_status` covers all three queries; `EXPLAIN` step in rollout. |
| 3.4 | Cache strategy | Riverpod family keyed on `(shopId, periodDays)`. Invalidate on pull-to-refresh and after `mark_booking_no_show` / `cancel_booking` succeed (controller listens to a `bookingMutationProvider` signal — to add). |
| 4.4 | PII in logs | Repo uses `AppLogger.warn` with shop_id + error code only. No client names, no booking ids. |
| 5.1 | Error responses actionable | "Hot" state shows the advisory chip with a concrete suggestion. Empty states explain why (no terminal bookings ≠ failure). |
| 5.5 | No internal info leaked in UI | Error code → fixed user copy in widget. Never `state.error.toString()`. |
| 6.1 | Edge cases | See test list below. |
| 6.4 | Negative tests | Test that authz failure returns the same "not_found" shape as unknown shop id (no enumeration). |
| 6.13 | Documentation | This spec + inline comments on RPCs + widget Semantics labels. |

## Tests

### SQL (pgTAP or psql snapshot tests)

1. Owner of shop A calls all 3 RPCs with shop B id → `42501` raised, no rows returned.
2. `period_days = 0`, `period_days = 91`, `weeks = 53`, `lookback_days = 6`, `min_lost = 0` → `22023` raised in each.
3. Shop with zero bookings: all 3 RPCs return empty/zero shapes without errors.
4. Shop with one bookings, status `pending`, `start_time` in past: excluded from `total` (denominator).
5. Booking with `cancelled` status whose `start_time` is next week: counted in *next week's* bucket, not this week's.
6. Index check: `EXPLAIN ANALYZE` shows `Index Scan` not `Seq Scan` for shops with > 1000 bookings.

### Dart (widget + unit)

1. `LostBookingSummary.currentRate == null` when `total == 0` → headline shows "No completed or lost bookings yet."
2. Rate threshold transitions render correct severity colour (Healthy/Watch/Hot).
3. Sparkline renders 12 bars even when only 5 weeks of data exist (others as baseline).
4. Drill-down sheet's repeat-offender list shows empty state with copy "No repeat offenders in the last 90 days — nice."
5. Controller: if `getLostBookingOffenders` throws but the other two succeed, state is populated with summary + weeks, offenders is `[]`, and a structured warn log fires.
6. Controller: pull-to-refresh invalidates and re-fetches; the existing screen-level `RefreshIndicator` already wraps the tab.

### Manual UAT

- A salon with real data: confirm the headline rate matches a hand-computed value over the same window.
- A brand new shop: confirm the empty state is friendly and doesn't show spinners forever.
- A shop where the owner has been mass-cancelling (worker strike): confirm the "you cancelled N yourself" surfaces in the drill-down.

## Rollout

1. Push the new migration (`20260603002000_lost_booking_rpcs.sql`).
2. Verify in Studio: the three (or four) RPCs exist, grants are correct, an `EXPLAIN` against a real shop_id uses the expected index.
3. Ship the Dart code behind no feature flag — the widget is additive
   and degrades to an empty state on any failure, so dark-launch isn't
   needed.
4. Watch logs for 24h:
   - `analytics.load_failed` with tag containing `lost_booking_*`
   - any 42501 raised against authenticated callers (means an authz bug)
5. Post-launch, gather 1 week of usage signal: are owners tapping into the drill-down? If not, the headline alone is doing its job (which is fine).

## Out of scope (deliberately)

- No-show predictor model.
- Push notification when rate spikes (belongs in the future
  `performance_alerts` rule engine — Phase 11 candidate).
- Per-worker no-show attribution.
- Money in minor units. The whole dashboard's money-as-double conversion
  is a separate sweep.
- Multi-shop comparison view.
- Configurable rate thresholds per shop (8%/15% are hardcoded for v1).

## Files touched

- **New SQL migration:** `supabase/migrations/20260603002000_lost_booking_rpcs.sql`
- **New Dart models:** `lib/.../data/models/analytics/lost_booking_metrics.dart`
- **Repo interface:** `lib/.../data/repositories/dashboard_repository.dart` (+3 abstract methods)
- **Repo impl:** `lib/.../data/repositories/supabase_dashboard_repository.dart` (+3 RPC wrappers)
- **New controller:** `lib/.../presentation/controllers/lost_bookings_controller.dart`
- **Provider:** `lib/.../providers/dashboard_providers.dart` (+1 family)
- **New widgets:** `lib/.../presentation/widgets/analytics/lost_bookings/{headline_card,sparkline,drilldown_sheet}.dart`
- **Edited screen:** `lib/.../presentation/screens/analytics_screen.dart` (+1 widget insertion)
- **Tests:** SQL snapshot in `supabase/tests/`, Dart widget+unit tests under `test/`

## Estimated effort

| Step | Time |
|------|------|
| SQL migration + EXPLAIN verification | ~3h |
| Dart models + repository methods + tests | ~2h |
| Controller + provider + unit tests | ~2h |
| Headline card + sparkline + threshold logic | ~3h |
| Drill-down sheet (3 sub-tabs) | ~4h |
| Wiring + screen integration + smoke test | ~1h |
| **Total** | **~1.5 days** |

If the drill-down's "by weekday" sub-tab and the cancellation-actor
4th RPC are deferred, MVP is **~1 day**.
