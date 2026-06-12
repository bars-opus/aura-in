# Phase 16 Research — Daily Close-Out Report

**Date:** 2026-06-11
**SPEC:** `.planning/phases/16-daily-closeout/16-SPEC.md` (locked)
**Confidence:** HIGH on schema findings (verified against migrations); MEDIUM on pg_cron availability (verified `pg_cron` is conditionally used but not asserted present on this project's DB — Wave 1 pre-flight required).

## Executive summary — what the planner must absorb before writing tasks

The SPEC is mostly implementable as written, but **five facts from the live codebase conflict with assumptions the SPEC's locked decisions appear to make**. None require re-opening the SPEC outright — three require small re-statements, two require the planner to choose the right concrete shape from a small menu. Listed in §9 (Open questions / P0 blockers).

The biggest one: **`bookings.payment_status` is constrained to `('unpaid','paid','refunded','failed')` — there is NO `partial` value** ([20260517010000_booking_schema.sql:119](../../../supabase/migrations/20260517010000_booking_schema.sql#L119)). LD-13's `reason='unpaid_balance'` rule (SPEC line 300) lists `('unpaid','partial')`. Either the rule reads `('unpaid','failed')` or the SPEC needs the partial enum added.

Second: **`shops` uses `user_id`, not `owner_id`** ([20260517010000_booking_schema.sql:185](../../../supabase/migrations/20260517010000_booking_schema.sql#L185), [client_notes_table.sql:46](../../../supabase/migrations/20260605130100_client_notes_table.sql#L46), [send_broadcast_rpc.sql:266](../../../supabase/migrations/20260607000400_send_broadcast_rpc.sql), [20260605170100_client_5min_reminder.sql:49](../../../supabase/migrations/20260605170100_client_5min_reminder.sql#L49)). The SPEC LD-10 says "lookup `shops.owner_id`" — this is shorthand; the actual column is `user_id`. Authz pattern is `shops.user_id = auth.uid()` throughout the codebase.

Third: **`booking_services.price_at_booking` is `NUMERIC(12,2)` in MAJOR units** (cedis, not kobo) — verified at [20260517010000_booking_schema.sql:74,137](../../../supabase/migrations/20260517010000_booking_schema.sql#L74-L137). LD-3 mandates minor units for all aggregates. The conversion `(price_at_booking * 100)::bigint` happens in the report aggregator. This is fine (math is exact for `NUMERIC(12,2)` × 100) but MUST be a documented invariant in the migration.

Fourth: **`shops.timezone` does not exist** — confirmed by grep across all migrations (zero matches for `shops.timezone` outside Phase 15 SPEC text). LD-1 is correct; the column add is genuinely net-new.

Fifth: **The codebase has NO `list_X` RPC pattern** for paginated reads. Phase 13/14 promotions/broadcasts list reads go through `_supabase.from('table').select(...).order(...)` directly in the Dart repo (see [supabase_dashboard_repository.dart:2735-2740](../../../lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart#L2735-L2740) for the pricing_overrides precedent). LD-9 mandates a `list_daily_reports` RPC — this is a NEW pattern. The planner needs to decide: introduce the first list RPC (recommended for the keyset shape) or use a direct table query with PostgREST `.lt('report_date', cursor).limit(N)`. See §6.

---

## Section 1 — Data layer landmines

### 1.1 `shops` ownership column

- **Actual column:** `user_id UUID` (FK → `auth.users`).
- **Authz pattern used throughout:** `s.user_id = auth.uid()` — verified at [20260517010000_booking_schema.sql:185-186](../../../supabase/migrations/20260517010000_booking_schema.sql#L185-L186), [20260605130100_client_notes_table.sql:46,51,56](../../../supabase/migrations/20260605130100_client_notes_table.sql#L46), [20260604000200_schedule_manual_booking_reminder.sql:50](../../../supabase/migrations/20260604000200_schedule_manual_booking_reminder.sql#L50), [20260605170100_client_5min_reminder.sql:49](../../../supabase/migrations/20260605170100_client_5min_reminder.sql#L49).
- **Planner action:** wherever the SPEC says `owner_id`, read `user_id`. The HINT code `OWNER_NOT_FOUND` (LD-11) stays semantically correct.

### 1.2 `bookings` table column shapes

Verified at [20260517010000_booking_schema.sql:40-65](../../../supabase/migrations/20260517010000_booking_schema.sql#L40-L65):

| Column | Type | Notes |
|--------|------|-------|
| `id` | UUID PK | |
| `user_id` | UUID NOT NULL → auth.users | Client (NULL for guest bookings — see [20260528120000_link_booking_guest_support.sql](../../../supabase/migrations/20260528120000_link_booking_guest_support.sql)) |
| `shop_id` | UUID NOT NULL | |
| `booking_date` | **TIMESTAMPTZ** NOT NULL | **Not DATE.** SPEC LD-2 selector "booking_date = today_local::date" needs a cast: `b.booking_date::date = (now() AT TIME ZONE sh.timezone)::date`. |
| `start_time` | TIMESTAMPTZ NOT NULL | |
| `end_time` | TIMESTAMPTZ NOT NULL | |
| `actual_end_time` | TIMESTAMPTZ NOT NULL | Default = end_time (see seed at [:432,555](../../../supabase/migrations/20260517010000_booking_schema.sql#L432)). |
| `status` | TEXT NOT NULL DEFAULT 'pending' | CHECK enum: `('pending','confirmed','cancelled','completed','no_show')` — line 116 |
| `payment_status` | TEXT NOT NULL DEFAULT 'unpaid' | CHECK enum: **`('unpaid','paid','refunded','failed')`** — line 119. **NO `partial` value.** See §9 / Open Q1. |
| `total_amount` | NUMERIC(12,2) NOT NULL | Booking-level total, MAJOR units. |
| `deposit_amount` | NUMERIC(12,2) NOT NULL DEFAULT 0 | |

**Indexes already in place that LD-2's selector benefits from** ([:147-155](../../../supabase/migrations/20260517010000_booking_schema.sql#L147-L155)):
- `idx_bookings_shop_id ON bookings (shop_id, start_time DESC)`
- `idx_bookings_booking_date ON bookings (booking_date)`
- `idx_bookings_shop_date_status ON bookings (shop_id, booking_date, status)` — **this is the index the dispatcher should use**.

**Pitfall:** the `idx_bookings_shop_date_status` index is on `booking_date` (timestamptz) directly, not `booking_date::date`. The selector `WHERE b.booking_date::date = (now() AT TIME ZONE sh.timezone)::date` will NOT use this index efficiently because the LHS is wrapped in a function call. EXPLAIN gate at Wave 6: either (a) add a functional index `(shop_id, ((booking_date AT TIME ZONE 'Africa/Accra')::date))` — but this hard-codes the tz and breaks multi-tz; or (b) compute a half-open range in SQL: `b.booking_date >= today_local_midnight_in_utc AND b.booking_date < tomorrow_local_midnight_in_utc` which uses the index. Recommend (b). See §3 for the SQL.

### 1.3 `booking_services` and `price_at_booking`

Verified at [20260517010000_booking_schema.sql:67-80,137](../../../supabase/migrations/20260517010000_booking_schema.sql#L67-L80):

- `booking_services.price_at_booking NUMERIC(12,2) NOT NULL CHECK (price_at_booking >= 0)` — **MAJOR units** (cedis), not kobo.
- Phase 15 made `price_at_booking` carry the **effective** post-override price via the client patch ([15-PLAN.md:117-118](../15-time-based-pricing/15-PLAN.md#L117-L118)) — confirmed in the planned client edits to `booking_confirmation_screen.dart`. Phase 16 can read `price_at_booking` directly as the source of truth for per-line revenue.
- **Conversion for LD-3 minor units:** `(price_at_booking * 100)::bigint`. `NUMERIC(12,2) * 100` is exact (no float involved); cast to `bigint` is safe up to 10^18 kobo. The `bigint` accumulator handles platform revenue up to ~92 quintillion kobo — fine for the next several decades.
- **Join shape to bookings:** `booking_services bs JOIN bookings b ON b.id = bs.booking_id` — already FK with `ON DELETE CASCADE`.

### 1.4 Worker / service join paths

- **Workers table is `workers`, not `shop_workers`.** Confirmed at [20260601150000_search_rls_and_analytics.sql:95](../../../supabase/migrations/20260601150000_search_rls_and_analytics.sql#L95), [20260525040000_fix_generate_slots_preselected_direct.sql:108](../../../supabase/migrations/20260525040000_fix_generate_slots_preselected_direct.sql#L108).
- Columns referenced in codebase: `id UUID PK`, `shop_id UUID`, `user_id UUID NULL` (for auth-linked workers), `name TEXT`, `is_active BOOLEAN`.
- **Per-worker join for the report:** `bookings b JOIN booking_services bs ON bs.booking_id = b.id LEFT JOIN workers w ON w.id = bs.worker_id`. `bs.worker_id` can be NULL (services that don't require a worker, freelancer flows) — must be handled. Group these as `worker_id = NULL → name = 'Unassigned'`.
- **Per-service join via `appointment_slots`:** `booking_services bs LEFT JOIN appointment_slots aps ON aps.id = bs.slot_id`. `bs.service_name` is denormalized at booking time (see [:72](../../../supabase/migrations/20260517010000_booking_schema.sql#L72)) — prefer `bs.service_name` over `aps.service_name` so a renamed service post-booking doesn't re-attribute historical revenue. Index `idx_booking_services_slot_id` covers this join.

### 1.5 `client_notes` table for LD-13 `no_show_no_action`

Verified at [20260605130100_client_notes_table.sql:15-27](../../../supabase/migrations/20260605130100_client_notes_table.sql#L15-L27):

- `client_notes` has **`shop_id`, `user_id`, `guest_profile_id`, `body`, `updated_at`** — but **NO `booking_id` column**. It is keyed `(shop_id, COALESCE(user_id::text, guest_profile_id::text))` — one note per client per shop, last-write-wins.
- **LD-13 says "no entry in `client_notes` referencing the booking_id"** — this is unimplementable as written. There is no booking_id linkage. The only available query is "does this client (user_id or guest_profile_id) have a `client_notes` row at the parent shop?" That semantic is broader than the SPEC implies — a single follow-up note on any prior booking would suppress the `no_show_no_action` flag for every future no-show. See §9 Open Q3.

### 1.6 `shops.timezone`

- **Does not exist.** Verified by grep across all migrations — only matches are inside docs/SPEC text. LD-1's column add is genuinely net-new.
- The phrase used by every existing RPC for "what day is it" is `EXTRACT(DOW FROM p_date)::INT` ([20260517010000_booking_schema.sql:727,852](../../../supabase/migrations/20260517010000_booking_schema.sql#L727)) or `EXTRACT(ISODOW FROM p_date)::INT` after Phase 15 ([20260611000400_apply_pricing_overrides_to_generate_slots.sql:148](../../../supabase/migrations/20260611000400_apply_pricing_overrides_to_generate_slots.sql)) — both treating timestamps in session-default tz (UTC on Supabase). Phase 16 is the first surface that materially depends on per-shop local time.

### 1.7 Currency

- `shops.currency TEXT` exists — verified at [20260517010000_booking_schema.sql:299](../../../supabase/migrations/20260517010000_booking_schema.sql#L299) (used by `booking_simple` view).
- Phase 15 RESEARCH §6 already confirmed `shops.currency` is the per-shop denominator.
- **Multi-currency story for the report:** every booking on a shop is in that shop's currency — no cross-currency math needed. The snapshot stores `currency` (LD-4 line 137) as a denormalized copy at generation time so the displayed string is stable across currency rename.

---

## Section 2 — pg_cron infrastructure on this project

### 2.1 pg_cron status

- **Currently used conditionally** at [20260602150000_schedule_notifications_cron.sql:19-26](../../../supabase/migrations/20260602150000_schedule_notifications_cron.sql#L19-L26):

```sql
IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
  RAISE NOTICE 'pg_cron extension not installed — skipping scheduler cron';
  RETURN;
END IF;
```

The project's pattern is to **gracefully skip** cron registration if `pg_cron` is absent, rather than `CREATE EXTENSION pg_cron`. This is because on Supabase, `pg_cron` is enabled via the Dashboard → Database → Extensions panel (or via a one-off `CREATE EXTENSION` by a superuser), not in version-controlled migrations.

- **Wave 1 pre-flight check (REQUIRED):**
  ```sql
  SELECT extversion FROM pg_extension WHERE extname IN ('pg_cron','pg_net');
  ```
  Expected: two rows. If `pg_cron` is missing, the dispatcher won't fire and SC-1 is unmet — surface to user before merge.

### 2.2 Existing scheduled job — syntax precedent

The one in-repo example is [20260602150000_schedule_notifications_cron.sql:55-69](../../../supabase/migrations/20260602150000_schedule_notifications_cron.sql#L55-L69):

```sql
PERFORM cron.schedule(
  'process-scheduled-notifications',
  '* * * * *',  -- every minute
  format($cron$
    SELECT net.http_post(
      url := %L,
      headers := jsonb_build_object('Content-Type','application/json',
                                    'Authorization', 'Bearer ' || %L),
      body := '{}'::jsonb,
      timeout_milliseconds := 30000
    );
  $cron$, v_url || '/functions/v1/process-scheduled-notifications', v_secret)
);
```

**Pattern locked by precedent:**
- The cron's SQL body is wrapped in `format($cron$ ... $cron$, ...)` so service-role secrets stay out of the literal.
- Re-runs of the migration unschedule the existing job first (defensive idempotency):
  ```sql
  PERFORM cron.unschedule('process-scheduled-notifications')
  WHERE EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'process-scheduled-notifications');
  ```
- The cron does NOT call PL/pgSQL functions directly — it calls `net.http_post` to wake an Edge Function which then orchestrates the work. This is the project's chosen architecture (see §4 for why this matters for the dispatcher).

### 2.3 Phase 16's cron registration

**Recommended cron migration shape** (mirrors the precedent above):

```sql
PERFORM cron.schedule(
  'dispatch-daily-reports',
  '*/15 * * * *',
  $cron$ SELECT public.dispatch_daily_reports(); $cron$
);
```

Two-tier choice:
- **Option A (project precedent):** cron → `net.http_post` to an Edge Function → Edge Function calls `dispatch_daily_reports()` via the service-role Postgres connection.
- **Option B (direct):** cron → `SELECT public.dispatch_daily_reports();` directly inside the cron job body. No Edge Function involved.

**Recommend Option B** for Phase 16 because the dispatcher is pure SQL — no external HTTP needed, no Edge Function logic — and Option A buys nothing but a 60s+ extra hop. The project's only prior cron (`process-scheduled-notifications`) needed Option A because it dispatches OneSignal pushes via HTTPS; the Daily Reports dispatcher only INSERTs into `daily_reports` and INSERTs into `scheduled_notifications` (per §4 — notification is via the existing scheduled_notifications queue, not direct OneSignal). All in-database. See §4.

### 2.4 SECURITY DEFINER for cron-callable RPC

The precedent ([20260604000200_schedule_manual_booking_reminder.sql](../../../supabase/migrations/20260604000200_schedule_manual_booking_reminder.sql)) uses:
```sql
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
```
plus the standard `REVOKE ALL FROM PUBLIC; GRANT EXECUTE TO authenticated;`.

For `dispatch_daily_reports()` specifically (cron-only, never user-facing per LD-10): 
```sql
REVOKE ALL ON FUNCTION public.dispatch_daily_reports() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.dispatch_daily_reports() FROM authenticated;
-- No GRANT to authenticated — cron runs as superuser / postgres role.
```

The cron scheduler in Supabase runs as the database superuser, so it has implicit EXECUTE on every function. No GRANT needed for cron itself.

### 2.5 Rollback

Standard pattern is `PERFORM cron.unschedule('dispatch-daily-reports');` — show this in the migration COMMENT block and in the PR rollback note.

---

## Section 3 — Timezone math in PostgreSQL

### 3.1 `now() AT TIME ZONE 'Africa/Accra'` returns what

`timestamptz AT TIME ZONE 'tz'` returns `timestamp` (no zone) — it represents wall-clock time in that zone. Example: if `now()` is `2026-06-11 21:30:00+00`, then `now() AT TIME ZONE 'Africa/Accra'` returns `2026-06-11 21:30:00` (Accra is UTC+0 with no DST, so identical numbers); `now() AT TIME ZONE 'Asia/Kolkata'` returns `2026-06-12 03:00:00`. `[VERIFIED — Postgres docs: 9.9.4 AT TIME ZONE]`.

### 3.2 The dispatch tick selector — recommended form

For LD-2's "shop's local time is currently 22:22:30..22:37:30" check, the cleanest expression:

```sql
WITH shop_local AS (
  SELECT
    sh.id                                                   AS shop_id,
    sh.timezone                                             AS tz,
    (now() AT TIME ZONE sh.timezone)::time                  AS local_time,
    (now() AT TIME ZONE sh.timezone)::date                  AS local_date
  FROM public.shops sh
  WHERE sh.archived_at IS NULL  -- assuming shops has archived_at; verify Wave 1
)
SELECT sl.shop_id, sl.local_date AS report_date
FROM shop_local sl
WHERE sl.local_time BETWEEN TIME '22:22:30' AND TIME '22:37:30'
  AND EXISTS (
    SELECT 1
    FROM public.bookings b
    WHERE b.shop_id = sl.shop_id
      -- Index-friendly half-open range. Compute today's UTC bounds from local date.
      AND b.booking_date >= ((sl.local_date::timestamp) AT TIME ZONE sl.tz)
      AND b.booking_date <  (((sl.local_date + 1)::timestamp) AT TIME ZONE sl.tz)
      -- Reverse-direction AT TIME ZONE: timestamp + tz = timestamptz (UTC instant)
  )
  AND NOT EXISTS (
    SELECT 1 FROM public.daily_reports dr
    WHERE dr.shop_id = sl.shop_id AND dr.report_date = sl.local_date
  );
```

**Two non-obvious mechanics:**

1. **The reverse AT TIME ZONE direction.** `timestamp AT TIME ZONE tz` returns `timestamptz` — it treats the input as a wall-clock time in `tz` and converts to the UTC instant. So `(local_date::timestamp) AT TIME ZONE tz` = "midnight on that date in that zone, as a UTC instant." This is what makes the range index-friendly on `bookings.booking_date` (timestamptz).

2. **`shops` archived check.** Verify in Wave 1 pre-flight: `SELECT column_name FROM information_schema.columns WHERE table_name='shops' AND column_name='archived_at'`. If absent, drop the filter (or use whatever the shop-soft-delete convention is — `is_active`, etc.).

### 3.3 DST landmines

| Timezone | DST? | Implication for 22:30 dispatch |
|----------|------|-------------------------------|
| `Africa/Accra` (current default) | No (UTC+0 fixed) | Fires at 22:30 UTC year-round. Stable. |
| `Asia/Kolkata` (IST) | No (UTC+5:30 fixed) | Fires at 17:00 UTC year-round. SC-18 verifies this. |
| `Europe/London` | Yes (BST/GMT) | Fires at 21:30 UTC in winter, 22:30 BST = 21:30 UTC in summer. Wait — actually 22:30 BST = 21:30 UTC. So the UTC firing time **shifts by 1 hour** at the DST boundary. The ±7.5 min window stays correct because the calc is done locally per-shop per-tick. |
| `America/New_York` | Yes (EST/EDT) | Same as London — UTC firing time shifts ±1h at DST transitions. Local 22:30 always matches local 22:30. |

**Spring-forward edge case** (DST starts): clocks skip 02:00→03:00. A "22:30 local" tick happens normally — DST transitions never occur near 22:30 local in any IANA zone. **No risk for the dispatcher window itself**, but a cron tick fired DURING the transition might see a 1-hour gap. Acceptable: the dispatcher is idempotent (LD-2 line 107) so a missed tick is rerun on the next 15-min wake. Document in the migration.

**Fall-back edge case** (DST ends, 01:30 happens twice): same. 22:30 isn't ambiguous; only 01:30–02:00 is. No impact.

### 3.4 `(now() AT TIME ZONE tz)::date` for "today's calendar date in the shop's local tz"

This is the canonical idiom. Verified syntax. Returns Postgres `date` type. Used to derive `report_date` for the (`shop_id, report_date`) unique constraint on `daily_reports`.

---

## Section 4 — Notification path

### 4.1 The current owner-push pattern

**There is no in-Dart "send owner a push" function.** Owner pushes are dispatched via the same scheduled-notifications queue that handles client reminders:

1. PL/pgSQL (e.g. `enqueue_booking_reminder`, [20260605170100_client_5min_reminder.sql:18](../../../supabase/migrations/20260605170100_client_5min_reminder.sql#L18)) INSERTs a row into `public.scheduled_notifications` with `delivery_channel = 'push'`, `user_id = shop_owner_user_id`.
2. The `process-scheduled-notifications` Edge Function (woken every minute by the existing pg_cron at [20260602150000_schedule_notifications_cron.sql](../../../supabase/migrations/20260602150000_schedule_notifications_cron.sql)) drains pending rows and dispatches via OneSignal.
3. On the device, [main.dart:222-237](../../../lib/main.dart#L222-L237) `OneSignal.Notifications.addClickListener` reads `additionalData['type']` and routes via `_handleNotificationNavigation`.

**Concrete example of owner push insert** ([20260605170100_client_5min_reminder.sql:56-58,133-160](../../../supabase/migrations/20260605170100_client_5min_reminder.sql#L56-L160)):

```sql
v_is_owner := p_type::text IN ('booking_owner_30min', 'booking_owner_5min');
IF v_is_owner THEN
  v_recipient := v_shop_owner;
  v_channel   := 'push';
  v_template  := NULL;
END IF;
...
INSERT INTO public.scheduled_notifications (
  user_id, ..., notification_type, scheduled_for, delivery_channel, metadata
) VALUES (
  v_recipient, ..., p_type, p_scheduled_for, v_channel,
  jsonb_build_object(
    'title', v_title, 'body', v_body,
    'booking_id', p_booking_id, 'shop_id', v_booking.shop_id,
    'type', p_type::text
  )
);
```

**Phase 16 mirrors this exactly.** Inside `generate_daily_report(shop_id, report_date)`, after the JSONB row is INSERTed/UPDATEd into `daily_reports`, the RPC does:

```sql
INSERT INTO public.scheduled_notifications (
  user_id, shop_id, notification_type, scheduled_for, delivery_channel, metadata
) VALUES (
  v_shop_owner_user_id,
  p_shop_id,
  'daily_report',     -- NEW notification_type enum value, see §4.3
  now(),              -- immediate
  'push',
  jsonb_build_object(
    'title',       v_title,                       -- localized in Dart at receive time? or here? see §4.4
    'body',        v_body,
    'shop_id',     p_shop_id,
    'report_date', p_report_date,
    'type',        'daily_report'
  )
);
```

The existing `process-scheduled-notifications` Edge Function drains this within ~60s; OneSignal delivers; the device's `addClickListener` fires; `_handleNotificationNavigation` reads `type='daily_report'` and routes to the daily report screen.

### 4.2 Recommendation: in-database fan-out, no Edge Function for Phase 16

Per §2.3 — `dispatch_daily_reports()` is pure SQL: it picks shops, calls `generate_daily_report` for each, and that RPC INSERTs into `scheduled_notifications`. No HTTP, no Edge Function for this phase. The existing notifications cron + edge function handles the OneSignal delivery. **This is the architecturally-cleanest path:** zero new infrastructure beyond the dispatcher cron itself.

### 4.3 `notification_type` enum extension

The `notification_type` column on `scheduled_notifications` is declared TEXT but is governed by an explicit enum-style allowed-values check (see [20260602130000_add_notification_type_enum_values.sql](../../../supabase/migrations/20260602130000_add_notification_type_enum_values.sql) referenced in grep). Phase 16 needs a new value: `'daily_report'`. Wave 1 migration adds it.

Verify in Wave 1 pre-flight:
```sql
SELECT pg_get_constraintdef(oid) FROM pg_constraint
WHERE conrelid = 'public.scheduled_notifications'::regclass
  AND contype = 'c' AND conname LIKE '%notification_type%';
```

If it's an unconstrained TEXT column (no CHECK), no migration needed for the value — but adding a CHECK constraint extension is harmless.

### 4.4 Deep-link route format

[main.dart:266-298](../../../lib/main.dart#L266-L298) `_handleNotificationNavigation` switches on `type`. Phase 16 adds a new case:

```dart
case 'daily_report':
  if (shopId != null && reportDate != null) {
    router.push('/dashboard/$shopId/daily-report/$reportDate');
  } else {
    router.go(RouteNames.home);
  }
```

**SPEC LD-6's deep-link** `/dashboard/{shop_id}/daily-report/{report_date}` is consistent with the project's `RouteNames` pattern. Verify Wave 4 by reading [lib/app/routing/app_router.dart](../../../lib/app/routing/app_router.dart) for the existing dashboard route shape — the planner should add a child route. The notification handler change in `main.dart` is part of Wave 4 (UI / wiring), not Wave 1.

### 4.5 i18n of the notification copy

Body example "₵{revenue_major} · {booking_count} bookings" (SPEC LD-6) — currency symbol is per-shop. **Two paths:**

- (a) Server constructs the body in the RPC using the shop's currency symbol (requires a `currency_symbol_for(code)` helper or a lookup). Final text stored in `scheduled_notifications.metadata.body`.
- (b) Server stores the **components** in `metadata` (`revenue_minor`, `currency`, `booking_count`); the Edge Function (or the OneSignal payload prep layer) formats. **Cleaner.**

Recommend (b). The notification body shown to OneSignal is whatever Edge Function builds at delivery time, and that function already does some formatting. Document this choice in §10/Wave 1 for the planner. Skipping localization at the SQL layer also keeps Phase 16 EN-only consistent with Phase 13/14/15 (SPEC LD-6 says "localized via Wave 5 i18n" — that's UI-side, not SQL-side).

---

## Section 5 — Money math (minor units) — verified

### 5.1 Current storage truth

- `booking_services.price_at_booking NUMERIC(12,2) NOT NULL CHECK (price_at_booking >= 0)` — [20260517010000_booking_schema.sql:74,137](../../../supabase/migrations/20260517010000_booking_schema.sql#L74-L137). **MAJOR units.**
- `bookings.total_amount NUMERIC(12,2)` — also MAJOR units ([:49](../../../supabase/migrations/20260517010000_booking_schema.sql#L49)).
- Phase 15 did NOT change the storage unit (only the value carried — effective vs base). Verified by reading [15-PLAN.md:39](../15-time-based-pricing/15-PLAN.md#L39): "`booking_services.price_at_booking` remains the historical-snapshot invariant."

### 5.2 The conversion the report aggregator must do

```sql
SUM((bs.price_at_booking * 100)::bigint)::bigint AS revenue_minor
```

- `NUMERIC(12,2) * 100` stays exact (`NUMERIC` arithmetic is decimal, no float involved).
- `(... * 100)::bigint` truncates fractional kobo (which can only exist if a NUMERIC(12,2) value has < 2 decimal places — but the column is constrained to 2 decimals, so it's safe).
- `SUM(...)::bigint` ensures the accumulator stays in bigint. **Important:** if you write `SUM(price_at_booking * 100)` without the cast, Postgres returns NUMERIC, and downstream code that expects bigint may silently coerce. Explicit cast.

### 5.3 `bigint` is the right type

- Max bigint: 2^63 − 1 = 9.2 × 10^18.
- Even at GHS 1,000,000 per booking × 1,000,000 bookings per shop per day, kobo total is 10^14. Six orders of magnitude of headroom.
- **`integer` (4-byte) overflows at 2,147,483,647** ≈ 21.5M kobo = 215K GHS. One whale shop on a busy Saturday could overflow `integer`. Use `bigint` end-to-end.

### 5.4 Comparison deltas as basis points (LD-3)

```sql
-- delta_bps for vs-yesterday comparison
CASE WHEN yesterday_revenue = 0 THEN NULL
     ELSE ((today_revenue - yesterday_revenue) * 10000) / yesterday_revenue
END AS delta_bps
```

- All inputs `bigint`. `* 10000` cannot overflow at any realistic scale.
- Integer division truncates toward zero — for a delta of 12.34%, you get 1234 bps. Good.
- Negative deltas (revenue fell) produce negative bps. Document.
- LD-14 NULL semantic enforced by the `CASE WHEN yesterday_revenue = 0 THEN NULL` branch.

### 5.5 JSON serialization of bigint

PostgreSQL's `jsonb_build_object('revenue_minor', SUM(...)::bigint)` serializes bigint as a JSON number. **JavaScript / Dart's default JSON number is float64** (53-bit safe-integer max = 9 × 10^15). At kobo scale, this is safely below the precision boundary up to ~90 trillion kobo. Phase 16 will not exceed this for many years.

If/when the platform crosses that boundary, the migration path is to serialize `revenue_minor` as a string. Document the threshold in the migration COMMENT.

---

## Section 6 — Pagination keyset pattern in this codebase

### 6.1 There is no list_X RPC precedent

Verified by grep — no `list_promotions`, `list_broadcasts`, `list_workers`, etc. RPCs exist in `supabase/migrations/`. All list reads in Phase 11/12/13/14/15 are done via PostgREST directly from the Dart repo using `.from('table').select(...).order(...)`. Phase 15 example at [supabase_dashboard_repository.dart:2735-2740](../../../lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart#L2735-L2740):

```dart
final response = await _supabase
    .from('pricing_overrides')
    .select('*')
    .eq('slot_id', slotId)
    .isFilter('archived_at', null)
    .order('created_at', ascending: false);
```

No pagination — these lists are bounded (50 max per slot, broadcasts/promotions per-shop). For `daily_reports` history, the list IS unbounded (one row per day per shop forever), so pagination is required.

### 6.2 Recommendation for `list_daily_reports` (LD-9)

**Path A — introduce the first list RPC** (recommended for LD-9 + LD-10):

```sql
CREATE OR REPLACE FUNCTION public.list_daily_reports(
  p_shop_id      UUID,
  p_before_date  DATE DEFAULT NULL,   -- keyset cursor; NULL = first page
  p_page_size    INT  DEFAULT 30
) RETURNS TABLE (
  shop_id        UUID,
  report_date    DATE,
  revenue_minor  BIGINT,
  currency       TEXT,
  payload        JSONB,
  generated_at   TIMESTAMPTZ
)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_clamped_size INT;
BEGIN
  -- Authz first.
  IF NOT EXISTS (
    SELECT 1 FROM public.shops sh
    WHERE sh.id = p_shop_id AND sh.user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501', HINT = 'OWNER_NOT_FOUND';
  END IF;

  -- LD-9: clamp page_size to [10, 50], default 30.
  v_clamped_size := GREATEST(10, LEAST(50, COALESCE(p_page_size, 30)));

  RETURN QUERY
    SELECT dr.shop_id,
           dr.report_date,
           (dr.payload->>'revenue_minor')::bigint   AS revenue_minor,
           (dr.payload->>'currency')                AS currency,
           dr.payload,
           dr.generated_at
    FROM public.daily_reports dr
    WHERE dr.shop_id = p_shop_id
      AND (p_before_date IS NULL OR dr.report_date < p_before_date)
    ORDER BY dr.report_date DESC
    LIMIT v_clamped_size;
END;
$$;
```

**Why an RPC and not direct PostgREST:** LD-10 requires authz on every read. Direct PostgREST uses RLS — that works, but the page_size clamp can't be enforced through RLS. The RPC route makes the clamp + authz + sort-direction policy a single server-side guarantee.

**Why `before_date` not `before_created_at`:** for daily reports, `report_date DESC` is the natural sort and the keyset. `created_at` and `generated_at` are bookkeeping. The owner asks "show me older reports" — date is what they're tracking. A keyset on `report_date` is unique per `(shop_id, report_date)` (the table's PK is or includes this — see LD-4/LD-2), so the keyset is collision-free.

**Path B — direct PostgREST** (alternative if the planner doesn't want a new RPC pattern): `_supabase.from('daily_reports').select(...).eq('shop_id', shopId).lt('report_date', cursor).order('report_date', ascending: false).limit(pageSize)`. RLS already gates on shop ownership. Page-size clamp must then be done in Dart. **Less defensive; not recommended.**

Planner picks A or B as a real decision (this is in Claude's Discretion, not locked by SPEC).

---

## Section 7 — Flutter / Riverpod patterns to mirror

### 7.1 Provider shape

Phase 15 precedent at [pricing_overrides_provider.dart:11-16](../../../lib/presentation/features/shops/dashboard/providers/pricing_overrides_provider.dart#L11-L16):

```dart
final pricingOverridesProvider =
    FutureProvider.family<List<PricingOverrideDTO>, String>(
        (ref, slotId) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getPricingOverrides(slotId: slotId);
});
```

**Phase 16 mirrors this:**

```dart
// One report — keyed by composite. Use a Tuple or a small typed key class.
class DailyReportKey {
  const DailyReportKey({required this.shopId, required this.reportDate});
  final String shopId;
  final DateTime reportDate;
  // Implement == and hashCode (Riverpod family keys MUST be Equatable).
}

final dailyReportProvider =
    FutureProvider.family<DailyReportDTO?, DailyReportKey>((ref, key) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getDailyReport(shopId: key.shopId, reportDate: key.reportDate);
});

// History list — paginated; consider AsyncNotifierProvider.family for keyset state.
final dailyReportHistoryProvider =
    FutureProvider.family<List<DailyReportSummaryDTO>, String>(
        (ref, shopId) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.listDailyReports(shopId: shopId);
});
```

The composite-key DTO pattern (for `(shopId, reportDate)`) is not in Phase 15 — that one keyed on `String slotId`. The planner should pick: a custom key class (preferred — type-safe) or use `dart:record` patterns. Document.

### 7.2 Screen pattern

Phase 15 list screen is **`ConsumerWidget`** ([pricing_overrides_list_screen.dart:27](../../../lib/presentation/features/shops/dashboard/presentation/screens/pricing_overrides_list_screen.dart#L27)). The form screen is `ConsumerStatefulWidget` (mutable form state).

For Phase 16:
- `DailyReportScreen` — **ConsumerWidget** (read-only; no form state). One "Re-generate" button → fires `repo.regenerateDailyReport(shopId, reportDate)` then `ref.invalidate(dailyReportProvider(key))`.
- `DailyReportHistoryScreen` — **ConsumerWidget** with optional pagination state. If the history is small (most shops < 365 days), one shot. If keyset paging is needed, use `ConsumerStatefulWidget` to manage the cursor.

### 7.3 Notification deep-link routing

Already documented in §4.4. The change site is [main.dart:266-298](../../../lib/main.dart#L266-L298) — adding a `case 'daily_report':` arm. `RouteNames` likely needs a new constant — verify in [lib/app/routing/app_router.dart](../../../lib/app/routing/app_router.dart) and [lib/app/routing/](../../../lib/app/routing/) for the constants file.

### 7.4 i18n setup

- **arb files live at** [lib/i10n/](../../../lib/i10n/) (note: `i10n`, not `l10n`).
- `lib/i10n/app_en.arb` is the EN baseline. Other locales (`app_de.arb`, `app_es.arb`, etc.) exist but per Phase 13/14/15 precedent, Phase 16 ships EN-only and lets unset locales fall back.
- `AppLocalizations` is the standard import. Generated bindings live at `lib/i10n/generated/`.
- Phase 16 needs ~30 keys (LD-6 notification copy, screen titles, section headers, follow-up reason labels, empty-state copy, error messages). Wave 5 work.

---

## Section 8 — Algorithm Quality Checklist mapping

### 8.1 Locked decision → checklist item → concrete task hook

| LD | Checklist items the planner must reflect as tasks | Concrete task hook |
|----|-------------------------------------------------|---------------------|
| **LD-1** Timezone column | 1.11 (PII/data assessment — timezone is not PII, but it is shop-config metadata; doc retention), 2.1 (input validation on the column add — the default `'Africa/Accra'` is a valid IANA string) | Wave 1 migration COMMENT names IANA spec; backfill CHECK constraint `CHECK (timezone IS NOT NULL AND length(timezone) BETWEEN 3 AND 64)` |
| **LD-2** Cron + idempotency | 1.1 (idempotency keys → unique `(shop_id, report_date)` PK), 1.6 (concurrency — two overlapping cron ticks race), 2.13 (timeout on the cron's RPC body — wrap in `SET LOCAL statement_timeout = '10s'`), 2.16 (concurrent re-gen protected by `INSERT ... ON CONFLICT DO UPDATE`), 2.18 (idempotency), 3.3 (EXPLAIN ANALYZE attached on the dispatcher selector — index decision per §1.2) | Wave 1 migration includes EXPLAIN output as a comment; Wave 2 has the `statement_timeout`; Wave 6 has a race test (two ticks within the same minute → one row, one notification) |
| **LD-3** Minor units | 2.19 (P0-U for [FIN]) — no floats anywhere on server | Wave 2 RPC uses `bigint` exclusively; Wave 6 test asserts `(0.1 + 0.2) * 100 == 30` exactly via NUMERIC math; PR description includes the kobo-overflow analysis from §5.3 |
| **LD-4** Snapshot persistence | 1.9 (consistency model — strong, single-write per key), 6.13 (documentation: snapshot semantics) | Wave 1 migration COMMENT explicitly says "schema_version 1, snapshot semantics: late-edits to bookings do NOT re-price historical reports" |
| **LD-5** Append-only audit | 2.22 (P1 for [FIN][MUTATION]) — schema-level REVOKE on UPDATE/DELETE | Wave 1 migration runs: `REVOKE UPDATE, DELETE ON public.daily_report_runs FROM PUBLIC, authenticated, service_role`. Wave 6 test attempts an UPDATE as service_role and asserts it raises permission-denied. |
| **LD-6** Notification routing | 4.4 (PII glossary — push body must not embed full client names; follow LD-13 redaction), 5.1 (actionable error message if push fails) | Wave 2 RPC scrubs metadata payload of PII; Wave 4 adds the click-handler arm; Wave 6 tests "push API down → daily_reports row still committed" |
| **LD-7** Zero-booking skip | 6.1 (edge case), 6.2 (failure scenario), 4.1 (structured log of zero-shop ticks) | Wave 6 test: shop with 0 bookings → no row in daily_reports, no row in scheduled_notifications, but a `(shop_id=NULL, outcome='skipped_zero_bookings')` row in daily_report_runs |
| **LD-8** Manual re-generate | 1.10 (compensating cleanup — ON CONFLICT UPDATE means no compensation needed; document), 2.18 (idempotency) | Wave 6: re-gen same day twice → JSONB updated, daily_report_runs gets two rows |
| **LD-9** Pagination | 3.1 (pagination — keyset, max 50) | Wave 2 RPC signature, Wave 6 test verifies page_size clamp at 5 → 10 and at 100 → 50 |
| **LD-10** RLS + authz | 1.4 (P0-U authz at every access), 1.5 (P0-U auth verified), 5.5 (no internal IDs in UI errors) | Wave 2 RPCs: authz FIRST in every body; Wave 6 cross-shop access test; Wave 1 migration has explicit RLS policies + dispatcher REVOKEs |
| **LD-11** HINT-based errors | 2.4 (P0-U — error messages don't leak), 5.1 (actionable errors) | Wave 3 Dart exception hierarchy + classifier; Wave 6 contract test enumerates every HINT |
| **LD-12** Tomorrow peek | (No new checklist item — out-of-scope items don't gain entries) | n/a |
| **LD-13** Follow-up rules | 4.4 (P0-U PII redaction — client name as `A***`) | Wave 2 RPC redaction code reviewed; Wave 6 test asserts no full name appears in JSONB |
| **LD-14** Comparison NULL | 6.1 (edge cases: divide-by-zero) | Wave 6 test: yesterday=0 → `delta_bps` is JSON null, not 0, not Infinity |
| **LD-15** Soak/load skipped | 6.10, 6.11 skipped — **documented**, not gaps | The SPEC LD-15 IS the justification; planner copies it into the PR description |

### 8.2 Checklist items the SPEC doesn't already cover

Three places the SPEC under-specifies and the planner should make explicit in PLAN.md:

- **4.9 (alerts → runbook)** — P2 for [SERVICE]/[ASYNC]. The SPEC has no alert spec. **Recommend** the planner add a Wave 6 task: structured log line `daily_report.dispatch_completed` with fields `shop_count`, `error_count`, `duration_ms`, plus a "0 dispatches at 22:30 UTC for 48h" alert hook deferred to the team's monitoring layer (not in-codebase).
- **6.7 (≥90% branch coverage on report-builder)** — SPEC mentions it as a P2 line. **Recommend** the planner make the report aggregator a pure SQL CTE returnable in one query so it's testable as a single function call without I/O. Wave 6 test enumerates the branches (zero-booking, all-completed, mixed, late no-shows).
- **3.12 (graceful shutdown / cron mid-flight)** — P1. If the cron tick is killed mid-fan-out (DB restart, deploy), the partially-processed shops have their `daily_reports` row already committed (ON CONFLICT) so the next tick is a no-op. The half-completed `daily_report_runs` rows for shops that errored have `outcome='failed'`. **Recommend** the planner add this to Wave 6 test list explicitly (chaos test simulating mid-fan-out kill).

### 8.3 Explicit skips per LD-15

- **6.10 (24h soak)** — skipped per LD-15. SPEC justification is the platform's < 100-shop scale.
- **6.11 (2x load test)** — skipped per LD-15. Same justification.

Both belong in the PR description as "skipped per SPEC LD-15, re-evaluate at >1000 shops."

---

## Section 9 — Open questions / P0 blockers for the planner

### Open Q1 — `payment_status` enum lacks `partial` ⚠️ HIGHEST PRIORITY

**Fact:** [20260517010000_booking_schema.sql:119](../../../supabase/migrations/20260517010000_booking_schema.sql#L119) constrains `payment_status` to `('unpaid','paid','refunded','failed')`. There is no `partial`.

**SPEC LD-13** says: `reason='unpaid_balance'` — `bookings.payment_status IN ('unpaid', 'partial')`.

**The conflict:** the rule as written matches `('unpaid', 'partial')` but `'partial'` doesn't exist. The rule effectively reduces to `payment_status = 'unpaid'`. SC-6's intent ("unpaid balances" → owner needs to chase money) might be broader than just `'unpaid'` — `'failed'` payment attempts are also "unpaid balance" in operational terms.

**Proposed re-statement** (preserves LD-13 intent without re-opening SPEC):
> `reason='unpaid_balance'` — `bookings.payment_status IN ('unpaid', 'failed')` AND `bookings.end_time < now()`. (Updated from SPEC because `'partial'` is not a current payment_status value; the operational equivalent is `'failed'`.)

The planner should ask the user OR confirm the re-statement in PLAN.md.

### Open Q2 — `client_notes` has no `booking_id` linkage ⚠️ SECOND PRIORITY

**Fact:** [20260605130100_client_notes_table.sql:15-27](../../../supabase/migrations/20260605130100_client_notes_table.sql#L15-L27) keys client notes on `(shop_id, user_id OR guest_profile_id)` — one note per client per shop. No booking_id.

**SPEC LD-13** says: `reason='no_show_no_action'` — `bookings.status = 'no_show'` AND `no entry in client_notes referencing the booking_id`.

**The conflict:** the linkage doesn't exist. The closest available signal is "the no-show client has *any* client_notes row at this shop" — which means a single follow-up note suppresses *every* future no-show flag for that client. That's almost certainly wrong: an owner who logs a single retention note for a repeat-no-show client never sees subsequent no-shows surfaced.

**Three remediation options** (planner picks one):
- (a) **Use `bookings.cancellation_reason` as the proxy.** If a no-show booking has a non-NULL `cancellation_reason`, the owner has logged context. Simple. Fits the existing schema.
- (b) **Add a `client_notes.booking_id UUID NULL` column in Wave 1.** Cheap migration. Lets the LD-13 rule work as written. Probably the right long-term answer.
- (c) **Re-state LD-13 to "no_show with no client_notes for this client at all"** and accept the false-negative suppression. Worst UX.

**Recommend (b).** This is a one-line ALTER TABLE in Wave 1. Document in SPEC re-opening note: "LD-13 implementation requires `client_notes.booking_id` — added in Phase 16 Wave 1 as a no-op nullable column. Phase 12's RPCs are not modified."

### Open Q3 — `daily_reports` PK / index decision (planner choice)

The `(shop_id, report_date)` uniqueness gives idempotency. Implementation choice:
- (a) **Composite PK** `PRIMARY KEY (shop_id, report_date)` — natural, but then a single `id UUID` for FK-from-other-tables doesn't exist. No such FK is planned.
- (b) **`id UUID PK DEFAULT gen_random_uuid()` + UNIQUE constraint** `UNIQUE (shop_id, report_date)` — matches the codebase convention (every table has an `id UUID`).

**Recommend (b)** for codebase consistency. The `daily_report_runs.shop_id` FK (LD-5) is to `shops`, not `daily_reports`, so the missing UUID PK is harmless.

### Open Q4 — `shops` archived/active filter

§3.2's selector filters `WHERE sh.archived_at IS NULL`. **Verify in Wave 1 pre-flight** whether `shops.archived_at` exists. If the convention is `is_active`, swap the filter. The planner should grep `lib/presentation/features/shops/` for the active-shop predicate used in existing list queries and mirror it.

### Open Q5 — Cron Option A vs B (recommended B; user decision)

Per §2.3, two ways to wire the dispatcher cron. **Recommend Option B** (direct SQL invocation, no Edge Function). The planner should reflect this in the PR description as a documented choice ("simpler than the precedent's HTTP hop; appropriate because the dispatcher is pure SQL").

---

## Section 10 — Recommended wave breakdown

Mirroring Phase 15's 7-wave shape:

| Wave | Scope | Parallelism |
|------|-------|-------------|
| **Wave 1** | Migrations: (a) `shops.timezone` column add + backfill + CHECK + COMMENT; (b) `daily_reports` table + RLS + index; (c) `daily_report_runs` table + RLS + REVOKE UPDATE/DELETE; (d) `notification_type` enum extension for `'daily_report'`; (e) Open Q2 — `client_notes.booking_id` column add if (b) chosen; (f) cron registration `dispatch-daily-reports` with `unschedule`-first defensive idempotency. Wave 1 pre-flight verifies `pg_cron` + `pg_net` extensions present. | Serial within the wave. Migration timestamps strict order. |
| **Wave 2** | RPCs: (a) `generate_daily_report(shop_id, report_date)` — SECURITY DEFINER, ON CONFLICT DO UPDATE, builds JSONB, INSERTs into `scheduled_notifications`, writes `daily_report_runs` row; (b) `dispatch_daily_reports()` — the cron-callable selector + fan-out; (c) `list_daily_reports(shop_id, before_date, page_size)` — keyset paginated read, page_size clamped. All three with HINT-coded errors per LD-11. | Mostly serial (b depends on a; c independent). |
| **Wave 3** | Dart data layer: `DailyReportDTO`, `DailyReportSummaryDTO`, `DailyReportException` hierarchy (mirroring `PricingOverrideException`), `_classifyReportError` classifier in `supabase_dashboard_repository.dart`, extend `DashboardRepository` abstract with `getDailyReport`/`listDailyReports`/`regenerateDailyReport` methods, `dailyReportProvider` + `dailyReportHistoryProvider`. | **Parallel with Wave 5** (no shared files). |
| **Wave 4** | Owner UI: `DailyReportScreen` (read-only, sections per LD-6 / SPEC outcome), `DailyReportHistoryScreen` (paginated list), `_AdjustmentBadge`-style follow-up chips, Re-generate FAB, deep-link route registration in `app_router.dart`, `case 'daily_report':` arm in [main.dart:266](../../../lib/main.dart#L266) handler. | Serial after Wave 3 (consumes providers). |
| **Wave 5** | i18n: ~30 EN keys in `lib/i10n/app_en.arb` — notification title/body, screen titles, section labels (Today / Yesterday / Same day last week / Tomorrow / Follow-ups / Re-generate), follow-up reason labels, empty states, error messages. | **Parallel with Wave 3** (touches a disjoint file). |
| **Wave 6** | Tests + SQL smoke: contract tests for the 18 SCs, classifier coverage, race test for duplicate cron tick (SC-12), zero-booking skip (SC-13), IST shop dispatch timing (SC-18), DST notes documented but no test, NULL-comparison test (LD-14), PII redaction assertion (LD-13), append-only enforcement test (UPDATE attempt on `daily_report_runs` raises). | Mostly parallel within (independent test files). |
| **Wave 7** | Manual UAT — run the cron in staging, watch a real 22:30 fire, tap the push, verify the screen, manual re-generate. Batched at end. | Sequential by nature. |

**Wave-level parallelism opportunities:**
- Waves 3 and 5 can run in parallel — touch disjoint files (`lib/presentation/features/shops/dashboard/` vs `lib/i10n/app_en.arb`).
- Wave 6's individual test files are independent of each other — can fan out to multiple executors.
- Wave 2's RPC (c) `list_daily_reports` can be authored in parallel with (a) and (b) — no shared code.

---

## Sources

### Primary (HIGH confidence)
- `supabase/migrations/20260517010000_booking_schema.sql` — bookings + booking_services columns + RLS
- `supabase/migrations/20260605130100_client_notes_table.sql` — client_notes lacks booking_id (Open Q2)
- `supabase/migrations/20260605170100_client_5min_reminder.sql` — owner push insert precedent
- `supabase/migrations/20260602150000_schedule_notifications_cron.sql` — pg_cron syntax precedent
- `supabase/migrations/20260604000200_schedule_manual_booking_reminder.sql` — SECURITY DEFINER + HINT template
- `supabase/migrations/20260507000000_notification_engine.sql` — scheduled_notifications + in_app_notifications schema
- `lib/main.dart:222-298` — OneSignal click handler + notification navigation switch
- `lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart:2700-2895` — Phase 15 classifier template + `_classifyPricingOverrideError`
- `lib/presentation/features/shops/dashboard/data/exceptions/pricing_override_exceptions.dart` — typed exception hierarchy shape to mirror
- `lib/presentation/features/shops/dashboard/data/models/pricing_override_dto.dart` — DTO + enum shape to mirror
- `lib/presentation/features/shops/dashboard/providers/pricing_overrides_provider.dart` — FutureProvider.family shape
- `.planning/phases/15-time-based-pricing/15-RESEARCH.md` — keyset / HINT / Big-O / hardening precedent
- `.planning/phases/15-time-based-pricing/15-PLAN.md` — wave structure precedent
- `architecture/algorithms/algorithm_quality_review_checklist.md` — §8 mapping

### Secondary (MEDIUM)
- Postgres docs §9.9.4 AT TIME ZONE — verified semantics for §3 timezone math `[CITED: PostgreSQL docs]`

## RESEARCH COMPLETE
