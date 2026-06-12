# Phase 16 — Daily Close-Out Report

## Outcome

At **22:30 in each shop's local timezone**, every shop with ≥ 1 booking
on that calendar day receives an in-app push notification linking to a
**persisted Daily Report** screen. The report shows:

- Today's headline numbers: revenue (in minor units, displayed in major
  units), booking counts by status (completed / no-show / cancelled),
  paid vs unpaid balances.
- Comparison row: vs. yesterday, vs. same day last week.
- Per-worker breakdown: revenue + booking count per staff member.
- Per-service breakdown: revenue per appointment_slot.
- Tomorrow's lineup: first booking time, total count, group flags.
- Follow-ups: confirmed bookings past their `end_time` (owner forgot
  to close them out), unpaid balances, missing-status no-shows.

Owners can:
- Scroll prior reports (paginated history view).
- Manually re-generate today's report (e.g. after late edits to
  booking statuses).
- Tap any section to deep-link into the canonical surface (booking
  detail, worker day, analytics).

Snapshots are **persisted as JSONB** on a `daily_reports` table — the
report the owner reads next week is the snapshot of what was true at
generation time, not a fresh recomputation that excludes late edits.
Manual re-generation overwrites the snapshot for the same
`(shop_id, report_date)` key.

The platform fan-out is **idempotent**: a duplicate cron tick is a no-op
(unique constraint), and a re-generation either inserts or replaces in
one statement.

## Why this matters

- **Operational habit**: end-of-day reconciliation is the moment owners
  actually look at numbers. The platform either provides this surface
  or owners reconcile in WhatsApp + a paper ledger. Fresha and Booksy
  both ship some form of "today's report."
- **Completes Phase 10**: Phase 10 measures no-shows; this surface
  *delivers* the metric to owners daily without them opening Analytics.
- **No new architecture**: all source numbers come from `bookings`,
  `booking_services`, `appointment_slots`, `shop_workers` — tables that
  already exist and are RLS-protected. The new architecture is
  scheduling + persistence + a screen.
- **Forces a real timezone column**: `shops.timezone` has been
  load-bearing since Phase 10 (rate-limit windows assume UTC days
  because no timezone exists). This phase finally adds it.

## Definitions

- **Daily report** — a JSONB snapshot of one shop's metrics for one
  calendar date in the shop's local timezone. Stored on
  `daily_reports` keyed on `(shop_id, report_date)`.
- **Report date** — the calendar date in the shop's local timezone.
  Reports run at 22:30 local for *that day*. A report run at
  2026-06-11 22:30 Africa/Accra covers 2026-06-11 00:00–23:59 Accra.
- **Generation trigger** — cron OR manual owner tap. Both call the
  same `generate_daily_report(shop_id, report_date)` RPC, which is
  idempotent via `INSERT ... ON CONFLICT (shop_id, report_date) DO UPDATE`.
- **Dispatch tick** — a pg_cron run (every 15 minutes) that scans
  `shops` for any shop whose local time is currently 22:30 ± 7.5 min
  AND has ≥ 1 booking today AND has no `daily_reports` row for today
  yet.
- **Follow-up** — a booking flagged in the report's `follow_ups`
  array because it requires owner attention: status still `confirmed`
  past `end_time`, OR payment_status in (`unpaid`, `partial`), OR
  a no_show status with no follow-up action recorded.

## Locked decisions

The following decisions are LOCKED. Implementation must match. Any
deviation requires re-opening this SPEC.

### LD-1 — Timezone column on shops

Add `shops.timezone TEXT NOT NULL DEFAULT 'Africa/Accra'`. Backfill
existing rows with `'Africa/Accra'`. No owner-facing UI for changing
this in Phase 16 — defer to a later phase. The default applies
because NanoEmbryo's current shop base is in West Africa.

Rationale: a per-shop timezone column is load-bearing and has been
implicitly required since Phase 10. Without it, the 22:30 dispatch
becomes platform-blanket-UTC, which is the wrong answer the moment the
platform has shops in two timezones.

### LD-2 — Cron schedule + idempotency

The dispatcher runs via `pg_cron` at `*/15 * * * *` (every 15
minutes). The job, `dispatch_daily_reports()`:

1. Selects every shop_id where:
   - The shop has ≥ 1 booking with `booking_date = (now AT TIME ZONE
     shops.timezone)::date`
   - The current local time in `shops.timezone` is between 22:22:30
     and 22:37:30 (a ±7.5 min window around 22:30, matching the cron
     resolution)
   - No `daily_reports` row exists for `(shop_id, today_local)`
2. For each matched shop, calls `generate_daily_report(shop_id,
   today_local)`.
3. Logs the dispatch tick into `daily_report_runs` (one row per
   matched shop, one zero-shop row when no matches).

The `(shop_id, report_date)` unique constraint on `daily_reports`
guarantees idempotency: a duplicate tick is a no-op INSERT.

Rationale for 15-min cron + ±7.5 min window: half-hour-offset
timezones (e.g. IST `+05:30`) would never see exactly 22:30 if we ran
at `*/30`. The ±7.5 min window covers them. For Africa/Accra (current
default `+00:00`), shops fire at 22:30 ± 7.5 min, which is operationally
indistinguishable from 22:30 sharp.

### LD-3 — Money math in minor units

Every aggregate (revenue, comparison deltas, per-worker, per-service)
is computed in `bigint` minor units (kobo for GHS). The `daily_reports`
JSONB stores minor units. Display-layer conversion to major units
happens only in the Flutter screen at render time. **No floating-point
math anywhere on the server**, including comparison percentages
(stored as `bigint` basis points: `(today - yesterday) * 10000 /
yesterday`).

Rationale: checklist 2.19 (P0-U for `[FIN]`). Phase 13/14 already use
this pattern for promo discount math.

### LD-4 — Snapshot persistence

The report is a JSONB blob on `daily_reports`. Schema:

```json
{
  "revenue_minor": 125000,
  "currency": "GHS",
  "bookings": {
    "completed": 8,
    "no_show": 1,
    "cancelled": 0,
    "confirmed_past_end": 2
  },
  "comparison": {
    "yesterday": {"revenue_minor": 110000, "delta_bps": 1364},
    "same_day_last_week": {"revenue_minor": 95000, "delta_bps": 3158}
  },
  "per_worker": [
    {"worker_id": "uuid", "name": "Ama", "revenue_minor": 65000, "count": 4}
  ],
  "per_service": [
    {"slot_id": "uuid", "name": "Haircut", "revenue_minor": 80000, "count": 6}
  ],
  "tomorrow": {
    "first_booking_at": "2026-06-12T09:00:00+00:00",
    "count": 5,
    "has_group_bookings": false
  },
  "follow_ups": [
    {"booking_id": "uuid", "reason": "confirmed_past_end", "client_name_redacted": "A***"},
    {"booking_id": "uuid", "reason": "unpaid_balance", "amount_minor": 12000}
  ],
  "generated_at": "2026-06-11T22:30:14+00:00",
  "schema_version": 1
}
```

`schema_version` lets us evolve the shape without breaking historical
snapshots. Comparison rows are NULL (not 0) when the comparison date
has zero bookings; the UI renders these as "—".

Rationale: the owner reading a 2-week-old report should see the
numbers as they were on that date, not numbers as a re-computation
would surface them today (which would exclude post-hoc status changes
or restorations).

### LD-5 — Append-only audit table

`daily_report_runs` records every generation attempt — both
cron-triggered and owner-triggered. Schema:

```sql
CREATE TABLE daily_report_runs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id UUID NULL REFERENCES shops(id) ON DELETE SET NULL,
  report_date DATE NULL,
  triggered_by TEXT NOT NULL CHECK (triggered_by IN ('cron', 'manual')),
  triggered_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  outcome TEXT NOT NULL CHECK (outcome IN ('created', 'updated', 'skipped_zero_bookings', 'failed')),
  error_code TEXT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

UPDATE and DELETE are revoked from all roles (including service_role)
via explicit REVOKE in the migration. Only INSERT is permitted. This
covers checklist 2.22 (append-only audit) for the [FIN]+[MUTATION]
overlap.

`shop_id` is nullable so the dispatcher can log "ran the tick, zero
shops matched" rows. `error_code` is the stable code from the
classifier (`REPORT_RPC_FAILED`, etc.) — never a free-text message.

### LD-6 — Notification routing

Push notification, in-app only (the channel we already use for
Phase 10/12 owner reminders). WhatsApp is NOT used because WhatsApp is
the anonymous-client channel, not the owner channel.

Notification body (localized via Wave 5 i18n):
- title: "Today's report is ready"
- body: "₵{revenue_major} · {booking_count} bookings"
- data payload: `{type: "daily_report", shop_id, report_date}`
- deep link: `/dashboard/{shop_id}/daily-report/{report_date}`

The notification is sent from `generate_daily_report` *after* the
JSONB row is committed. If the push fails (FCM/APNS down), the row
still exists — the owner sees a badge in the app on next open.

### LD-7 — Zero-booking skip

Shops with zero bookings today are *not* dispatched:
- They never enter the cron's matched-shops loop (selector filters
  `HAVING count(b.id) > 0` before fan-out).
- The dispatcher logs one `(shop_id=NULL, outcome='skipped_zero_bookings',
  triggered_by='cron')` row per tick when the matched set is empty,
  so we have evidence the cron ran successfully.
- An owner who manually taps "Re-generate today" on a zero-booking
  day gets a friendly empty-state in the report screen, not a server
  error. The RPC still produces a row, but with `revenue_minor = 0`
  and an empty follow-ups list.

### LD-8 — Manual re-generation

The report screen has a "Re-generate" button. It calls
`generate_daily_report(shop_id, today_local)` with the same
idempotency contract: the existing row is REPLACED, not appended.
The audit table gets a new row with `triggered_by='manual'` and
`outcome='updated'`.

Owners can re-generate any past day's report (not just today's).
There is no cooldown — the operation is idempotent, the RPC is
authz-checked, and the cost is low (one read-side aggregation).

### LD-9 — Pagination on history

`list_daily_reports(shop_id, before_date, page_size)` is the only
read RPC. `page_size` is clamped to `[10, 50]` server-side. The
default is 30 (one month's history at a glance). Pagination uses
keyset on `report_date` (no offset). The screen shows date +
revenue-at-a-glance per row; tapping opens the full snapshot.

### LD-10 — RLS + authz

- `daily_reports`: SELECT policy: owner of the parent shop only.
  INSERT/UPDATE: SECURITY DEFINER RPCs only (no client direct).
- `daily_report_runs`: SELECT policy: owner of the parent shop only
  (filtered on the nullable shop_id; NULL rows visible to
  service_role only). INSERT: SECURITY DEFINER only. UPDATE/DELETE:
  revoked from all.
- `generate_daily_report(shop_id, date)`: validates the caller owns
  `shop_id` via the same pattern as Phase 13/14 RPCs (lookup
  `shops.owner_id` and compare to `auth.uid()`). Returns HINT
  `OWNER_NOT_FOUND` (code 42501) on mismatch.
- `dispatch_daily_reports()`: callable only from the pg_cron service
  role. `REVOKE ALL FROM PUBLIC` + `REVOKE FROM authenticated` +
  `GRANT EXECUTE TO service_role`.
- `list_daily_reports(shop_id, ...)`: same owner-of-shop authz.

### LD-11 — Phase 15 hardening pattern (HINT-based errors)

All RPCs raise SQL exceptions with stable HINT codes; no string
matching. Locked HINT vocabulary:

- `OWNER_NOT_FOUND` — caller doesn't own `shop_id`
- `SHOP_NOT_FOUND` — `shop_id` doesn't exist
- `REPORT_DATE_INVALID` — date is in the future or > 365 days ago
- `REPORT_RPC_FAILED` — any unexpected failure (catch-all, logged
  with full context to `daily_report_runs.error_code`)

Repository's `_classifyReportError(PostgrestException)` switches on
`(e.code, e.hint)`. Same shape as Phase 15's classifier.

### LD-12 — Tomorrow lineup is a peek, not a forecast

The "Tomorrow" section of the report only shows three values: first
booking time, count, and a flag for any group bookings. It does NOT
project revenue. Forecasting is a different surface (Phase 6
Analytics) and not in scope here. Rationale: the owner uses tomorrow's
peek to plan their morning — they want "what time do I start" and
"is there a big group", not "what will I earn".

### LD-13 — Follow-up surfacing rules

The `follow_ups` array is computed at generation time. Inclusion rules:

- `reason='confirmed_past_end'` — `bookings.status = 'confirmed'` AND
  `bookings.end_time < now()`. Tells the owner "you forgot to mark
  these complete or no-show."
- `reason='unpaid_balance'` — `bookings.payment_status IN ('unpaid',
  'partial')` AND `bookings.end_time < now()`. The booking ran but
  payment didn't settle.
- `reason='no_show_no_action'` — `bookings.status = 'no_show'` AND
  no entry in `client_notes` referencing the booking_id (the
  Phase 12 retention engine expects owners to log a follow-up
  attempt; no log = unattended).

Each entry stores `booking_id` + `reason` + redacted client name
(first letter + asterisks, per checklist 4.4 PII glossary).
Client phone numbers and full names are NEVER in the snapshot.

### LD-14 — Comparison NULL semantics

`comparison.yesterday` and `comparison.same_day_last_week` are
`null` when the comparison date had zero bookings. The UI renders
these as "—" (em dash). Computing `delta_bps` against zero is
explicitly undefined; we surface "no data" instead of `Infinity` or
`null` masquerading as a number.

### LD-15 — Soak / load tests skipped (documented)

Per the Algorithm Quality Checklist v3.1 §6.10 (24h soak) and §6.11
(2x load test) — both **skipped with documented justification**:

> At current platform scale (< 100 shops), the 22:30 cron processes
> at most ~50 shops in a single fan-out and ~5 manual re-generations
> per day. The cron's load profile is bounded by the number of
> shops, not by user traffic. A 24h soak and 2x-peak load test are
> not proportionate to the actual production workload. Re-evaluate
> if shop count exceeds 1000 OR cron processing time exceeds 30s.

This skip is recorded in the SPEC (here) and again in the PLAN's
verification matrix.

## Out of scope

- **Owner timezone editor**: `shops.timezone` ships with a default;
  no UI to change it in this phase. Future phase.
- **CSV / PDF export of reports**: owners on phones rarely export.
  Add when a real owner asks.
- **Weekly / monthly rollups**: same data, different aggregation. Add
  when 3+ owners ask for it.
- **Per-section toggles**: every section is always rendered. No
  preference UI.
- **Notification scheduling preferences**: owner cannot change 22:30
  in this phase. Defer.
- **Multi-tz shops**: not supported. One timezone per shop.
- **Forecast / predictive analytics in the report**: tomorrow's
  section is a *peek*, not a forecast.

## Success criteria

The phase is considered shipped when all of these are observable
end-to-end:

1. **SC-1** A shop in Africa/Accra with 5 completed bookings on
   2026-06-11 receives a push notification at 22:30 ± 1 min local
   time on that date.
2. **SC-2** Tapping the notification opens `DailyReportScreen` with
   today's date and the 5 bookings reflected in `bookings.completed`.
3. **SC-3** Revenue computed on the server in kobo equals the sum of
   `booking_services.price_at_booking` for those 5 bookings, in kobo.
4. **SC-4** Yesterday's comparison row shows the previous day's
   numbers if that day had bookings; renders "—" if zero.
5. **SC-5** Same-day-last-week comparison row works the same way.
6. **SC-6** Per-worker breakdown sums to the revenue total.
7. **SC-7** Per-service breakdown sums to the revenue total.
8. **SC-8** Tomorrow section shows first booking time + count for
   2026-06-12 if bookings exist; renders empty state otherwise.
9. **SC-9** A `confirmed` booking past its `end_time` appears in the
   `follow_ups` array with `reason='confirmed_past_end'`.
10. **SC-10** A `no_show` booking with no `client_notes` entry
    appears with `reason='no_show_no_action'`.
11. **SC-11** Manually tapping "Re-generate" overwrites the snapshot;
    a new row appears in `daily_report_runs` with
    `triggered_by='manual'`.
12. **SC-12** A duplicate cron tick (same minute, same shop) is a
    no-op — the JSONB does not change, no new INSERT happens.
13. **SC-13** A shop with zero bookings today is NOT dispatched; no
    push notification fires; `daily_reports` has no row for that day.
14. **SC-14** An owner attempting to call `generate_daily_report` for
    a shop they don't own gets a typed `ReportAccessDenied` exception
    (HINT `OWNER_NOT_FOUND`), not a generic 500.
15. **SC-15** A future-dated report request raises `REPORT_DATE_INVALID`.
16. **SC-16** A report for a date > 365 days ago raises
    `REPORT_DATE_INVALID`.
17. **SC-17** `list_daily_reports(shop_id, before_date, page_size)`
    returns paginated results, oldest-first, with `page_size` clamped
    to [10, 50].
18. **SC-18** Adding a `shops.timezone` value of `'Asia/Kolkata'`
    (IST `+05:30`) on a test shop with bookings causes the dispatch
    tick to fire at 22:30 IST (= 17:00 UTC), within the ±7.5 min
    window.

## Algorithm Quality Checklist coverage

Phase 16 brushes [ASYNC] (cron), [SERVICE] (RPCs), [MUTATION]
(report write), [UI] + [MOBILE] (Flutter screen), and [FIN]
(revenue math). The PLAN.md maps each task to the relevant checklist
items. Summary by priority:

- **P0-U blockers** addressed in the plan: 1.4 (authz at every
  access), 1.5 (auth verified), 2.1 (input sanitization on date +
  page_size params), 2.2 (no string-concat SQL), 2.4 (sanitized
  errors via HINT codes), 2.5 (page_size + history range limits),
  2.10 (transactional cleanup in RPC), 4.4 (PII redaction in
  follow_ups), 5.5 (no internal IDs in UI errors), 2.19 (minor
  units throughout).
- **P1 (merge gate)**: 1.1 idempotency (compound PK + ON CONFLICT),
  1.10 compensating cleanup (manual re-generate path), 2.13 cron
  RPC timeout (10s budget), 2.16 concurrent re-generation protected
  by ON CONFLICT, 2.18 idempotent RPCs, 3.10 don't retry on auth
  fail, 6.1 edge cases (DST boundary, zero-booking comparison,
  exactly-22:30 race), 6.3 race tests, 2.22 audit append-only.
- **P2 (production gate)**: 1.7 stateless RPCs, 1.8 Big-O
  documented, 3.1 pagination, 3.3 indexes (EXPLAIN attached to
  PR), 4.1 structured logs, 4.6 RED metrics on cron, 4.11
  configurable thresholds, 5.1 actionable errors, 5.2 ≤200ms first
  paint on report screen, 6.7 ≥90% branch coverage on
  report-builder, 6.2 failure scenarios (push fail → row persists),
  6.13 documentation.
- **Skipped with justification**: 6.10 (24h soak), 6.11 (2x load) —
  see LD-15.

---

## SPEC Amendments — 2026-06-11 (post-RESEARCH)

The RESEARCH phase surfaced three live-schema conflicts with the original SPEC. The
following amendments are LOCKED and supersede the corresponding text above. The original
LD blocks are kept as-is for diff-traceability; the amendments below are authoritative.

### AMEND-1 — `payment_status` enum (supersedes LD-13 `reason='unpaid_balance'`)

The live `bookings.payment_status` enum is `('unpaid', 'paid', 'refunded', 'failed')`.
`'partial'` does not exist. LD-13's `reason='unpaid_balance'` rule is re-stated:

> `reason='unpaid_balance'` — `bookings.payment_status IN ('unpaid', 'failed')` AND
> `bookings.end_time < now()`.

Rationale: `'failed'` is the operational equivalent of "owner needs to chase money."
Re-introducing a `'partial'` enum value is out of scope for Phase 16.

### AMEND-2 — `client_notes.booking_id` column added in Wave 1 (supersedes LD-13 `reason='no_show_no_action'`)

`client_notes` currently has no `booking_id` column — it is keyed `(shop_id, client_identity)`,
one note per client per shop. LD-13's `no_show_no_action` rule as written is unimplementable.

Wave 1 adds:

```sql
ALTER TABLE public.client_notes
  ADD COLUMN booking_id UUID NULL REFERENCES public.bookings(id) ON DELETE SET NULL;

CREATE INDEX idx_client_notes_booking_id
  ON public.client_notes (booking_id)
  WHERE booking_id IS NOT NULL;
```

The Phase 12 retention-engine RPCs are NOT modified — they continue to upsert on
`(shop_id, client_identity)` and leave `booking_id` NULL. This is a forward-compatible
addition: future surfaces can write `booking_id` when logging a per-booking follow-up.

LD-13 is re-stated:

> `reason='no_show_no_action'` — `bookings.status = 'no_show'` AND no
> `client_notes` row exists with `booking_id = bookings.id`.

### AMEND-3 — `shops.user_id` (clarification, not a re-open)

Throughout LD-10 and elsewhere where the SPEC refers to `shops.owner_id`, read
`shops.user_id`. The live column is `user_id UUID NOT NULL REFERENCES auth.users`.
The HINT code `OWNER_NOT_FOUND` (LD-11) remains semantically correct — the column
naming difference is implementation detail.

### AMEND-4 — Cron architecture (locks the Option B path)

LD-2's cron registration uses **direct SQL invocation**, not the Edge Function hop:

```sql
PERFORM cron.schedule(
  'dispatch-daily-reports',
  '*/15 * * * *',
  $cron$ SELECT public.dispatch_daily_reports(); $cron$
);
```

Rationale: `dispatch_daily_reports()` is pure SQL. It selects shops, calls
`generate_daily_report` per shop, which INSERTs into `scheduled_notifications`.
The existing `process-scheduled-notifications` Edge Function + its own per-minute
cron handles OneSignal delivery. No new Edge Function for Phase 16.

The unschedule-first defensive idempotency from precedent
([20260602150000_schedule_notifications_cron.sql:55-69]) is preserved:

```sql
PERFORM cron.unschedule('dispatch-daily-reports')
WHERE EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'dispatch-daily-reports');
```

### AMEND-5 — `daily_reports` PK shape (clarification, not a re-open)

`daily_reports` uses `id UUID PRIMARY KEY DEFAULT gen_random_uuid()` plus a
`UNIQUE (shop_id, report_date)` constraint. This matches the codebase convention
(every table has an `id UUID`) while preserving idempotency via the unique pair.

### AMEND-6 — `bookings.booking_date` is `timestamptz`, not `date`

LD-2's dispatch selector and any "today's bookings" query MUST use the index-friendly
half-open range form (RESEARCH §3.2), not `booking_date::date = today_local`:

```sql
WHERE b.booking_date >= ((sl.local_date::timestamp) AT TIME ZONE sl.tz)
  AND b.booking_date <  (((sl.local_date + 1)::timestamp) AT TIME ZONE sl.tz)
```

Rationale: wrapping `booking_date` in `::date` defeats `idx_bookings_shop_date_status`.
The half-open range uses the index directly.

### AMEND-7 — Wave 1 pre-flight check (new requirement)

Wave 1 includes a pre-flight check that REPORTS but does not BLOCK:

```sql
DO $$
DECLARE
  v_cron_present BOOLEAN;
  v_net_present  BOOLEAN;
  v_archived_col BOOLEAN;
BEGIN
  SELECT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron')
    INTO v_cron_present;
  SELECT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_net')
    INTO v_net_present;
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'shops' AND column_name = 'archived_at'
  ) INTO v_archived_col;

  RAISE NOTICE 'Phase 16 pre-flight: pg_cron=%, pg_net=%, shops.archived_at=%',
    v_cron_present, v_net_present, v_archived_col;

  IF NOT v_cron_present THEN
    RAISE NOTICE 'pg_cron missing — dispatcher will not fire. Enable via Supabase Dashboard before merging.';
  END IF;
END $$;
```

The dispatcher selector accommodates the `shops.archived_at` finding from the pre-flight:
if the column does not exist, the selector falls back to no archive filter. The planner
picks the concrete predicate based on what the pre-flight reports.

---

*Phase: 16-daily-closeout*
*SPEC locked: 2026-06-11 (amendments AMEND-1 through AMEND-7 added 2026-06-11)*
