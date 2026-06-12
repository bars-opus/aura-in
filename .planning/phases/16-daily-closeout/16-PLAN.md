# Phase 16 PLAN — Daily Close-Out Report

## Outcome (verbatim from SPEC)

At **22:30 in each shop's local timezone**, every shop with ≥ 1 booking on that
calendar day receives an in-app push notification linking to a **persisted
Daily Report** screen. The report shows: today's revenue (minor units stored,
major units displayed) + booking counts by status (completed / no-show /
cancelled) + paid vs unpaid balances; comparison vs. yesterday and vs. same
day last week (NULL when comparison date had zero bookings); per-worker
breakdown (revenue + count); per-service breakdown (revenue per
appointment_slot); tomorrow's lineup (first booking time, count, group flag);
follow-ups (confirmed past end_time, unpaid/failed balances past end_time,
no_show with no client_notes booking linkage).

Owners can scroll prior reports (paginated history), manually re-generate any
day's report (idempotent INSERT ... ON CONFLICT DO UPDATE), and deep-link from
the notification straight to the screen.

Snapshots are JSONB rows on `daily_reports` keyed `UNIQUE (shop_id,
report_date)`. The platform fan-out is **idempotent**: duplicate cron tick =
no-op; manual re-generate = single statement REPLACE.

(SPEC §Outcome lines 3–35; SPEC §Definitions lines 52–70; SPEC §LD-1..LD-15
lines 76–333; SPEC §AMEND-1..AMEND-7 lines 425–550.)

## Locked-in design decisions (delta from SPEC drafts vs RESEARCH)

The SPEC's LDs are LOCKED. AMEND-1 through AMEND-7 supersede the corresponding
LD text. Re-stated below for plan readability:

- **AMEND-1** (supersedes LD-13): `reason='unpaid_balance'` matches
  `bookings.payment_status IN ('unpaid','failed')` AND `bookings.end_time <
  now()`. `'partial'` does not exist in the live enum (RESEARCH §1.2:119).
- **AMEND-2** (supersedes LD-13): Wave 1 ADDS `client_notes.booking_id UUID
  NULL` column + partial index. `reason='no_show_no_action'` matches
  `bookings.status='no_show'` AND no `client_notes` row with `booking_id =
  bookings.id`. Phase 12 RPCs untouched (forward-compatible).
- **AMEND-3** (clarification): Throughout LD-10/LD-11, read `shops.user_id`
  (not `shops.owner_id`). HINT code `OWNER_NOT_FOUND` stays semantically
  correct.
- **AMEND-4** (locks Option B): Cron uses direct SQL invocation. No Edge
  Function hop. Cron body is `SELECT public.dispatch_daily_reports();`.
- **AMEND-5** (clarification): `daily_reports` has `id UUID PRIMARY KEY
  DEFAULT gen_random_uuid()` + `UNIQUE (shop_id, report_date)`. Codebase
  convention.
- **AMEND-6** (locks the half-open range): Dispatch selector and any
  "today's bookings" query MUST use `b.booking_date >= ((local_date::timestamp)
  AT TIME ZONE tz) AND b.booking_date < (((local_date+1)::timestamp) AT TIME
  ZONE tz)`. Index-friendly form preserving `idx_bookings_shop_date_status`.
- **AMEND-7** (Wave 1 pre-flight): Reports `pg_cron`, `pg_net`,
  `shops.archived_at`. Does NOT block — the planner picks the concrete
  `archived_at` predicate from the pre-flight finding. If pg_cron is missing,
  surface to user before merging.

### Carry-over gaps explicitly NOT fixed

- **Owner timezone editor**: out of scope. `shops.timezone` defaults to
  `'Africa/Accra'`. No UI to change. (SPEC §Out of scope.)
- **CSV/PDF export**: out of scope.
- **Weekly/monthly rollups**: out of scope.
- **Notification scheduling preferences**: owner cannot change 22:30 in this
  phase.
- **Multi-tz shops**: not supported. One timezone per shop.
- **Forecast in tomorrow section**: peek only, not a forecast (LD-12).

## Files touched

**NEW (SQL — strict timestamp order)**

- `supabase/migrations/20260611100000_phase16_preflight.sql` — AMEND-7 DO block (reports, never blocks).
- `supabase/migrations/20260611100100_shops_timezone_column.sql` — LD-1 column add + backfill + CHECK + COMMENT.
- `supabase/migrations/20260611100200_daily_reports_table.sql` — LD-4 table + RLS owner-only SELECT + indexes.
- `supabase/migrations/20260611100300_daily_report_runs_table.sql` — LD-5 audit table + RLS + REVOKE UPDATE/DELETE.
- `supabase/migrations/20260611100400_client_notes_booking_id_column.sql` — AMEND-2 column add + partial index.
- `supabase/migrations/20260611100500_scheduled_notifications_daily_report_type.sql` — §4.3 enum/CHECK extension.
- `supabase/migrations/20260611100600_generate_daily_report_rpc.sql` — LD-2/LD-3/LD-6/LD-10/LD-11 RPC.
- `supabase/migrations/20260611100700_dispatch_daily_reports_rpc.sql` — LD-2/LD-7 fan-out RPC.
- `supabase/migrations/20260611100800_list_daily_reports_rpc.sql` — LD-9 paginated read RPC.
- `supabase/migrations/20260611100900_schedule_dispatch_daily_reports_cron.sql` — AMEND-4 cron registration.

**NEW (Dart)**

- `lib/presentation/features/shops/dashboard/data/models/daily_report_dto.dart`
- `lib/presentation/features/shops/dashboard/data/exceptions/daily_report_exceptions.dart`
- `lib/presentation/features/shops/dashboard/providers/daily_report_provider.dart`
- `lib/presentation/features/shops/dashboard/presentation/screens/daily_report_screen.dart`
- `lib/presentation/features/shops/dashboard/presentation/screens/daily_report_history_screen.dart`
- `test/presentation/features/shops/dashboard/data/exceptions/daily_report_exceptions_test.dart`
- `test/presentation/features/shops/dashboard/data/repositories/daily_report_repository_test.dart`
- `test/presentation/features/shops/dashboard/presentation/screens/daily_report_screen_test.dart`
- `.planning/phases/16-daily-closeout/sql/16_smoke_tests.sql`

**EDIT (Dart)**

- `lib/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart` — append three abstract methods: `getDailyReport`, `listDailyReports`, `regenerateDailyReport`.
- `lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart` — implement the three abstract methods + add `_classifyReportError(PostgrestException)` HINT-driven classifier.
- `lib/app/routing/app_router.dart` — register `/dashboard/:shopId/daily-report/:reportDate` + `/dashboard/:shopId/daily-report/history`.
- `lib/main.dart:266-298` — add `case 'daily_report':` arm to `_handleNotificationNavigation`.
- `lib/i10n/app_en.arb` — add ~30 EN keys.

**NOT TOUCHED**

- `supabase/functions/process-scheduled-notifications/` — existing edge function drains `scheduled_notifications` and dispatches via OneSignal. Phase 16 INSERTs into the same queue with `notification_type='daily_report'`. The edge function reads `metadata.title` / `metadata.body` already (verify by grep before Wave 4) — no edge function change needed.
- Any payment / chat / Sendbird / Paystack / Stripe code path.
- Phase 12 retention RPCs writing to `client_notes` — AMEND-2 column add is backward-compatible (NULL default).

## Pre-flight checks (REPORTS — does not block; AMEND-7)

Wave 1 Task 1.0 executes the AMEND-7 DO block (lines 522–545 of SPEC). The
block reports the following and writes RAISE NOTICE lines; does not raise:

1. `pg_cron` extension present.
2. `pg_net` extension present.
3. `shops.archived_at` column present.

Additional manual pre-flight (run once against staging then prod; capture
output in PR description):

```sql
-- (1) Confirm shops table exists with user_id column (AMEND-3).
SELECT column_name FROM information_schema.columns
WHERE table_schema='public' AND table_name='shops'
  AND column_name IN ('id','user_id','currency','archived_at');
-- Expected: id, user_id, currency present. archived_at = present or absent
-- (dispatcher selector adapts based on AMEND-7 finding).

-- (2) Confirm bookings.payment_status enum is ('unpaid','paid','refunded','failed').
SELECT pg_get_constraintdef(oid) FROM pg_constraint
WHERE conrelid='public.bookings'::regclass
  AND contype='c' AND conname LIKE '%payment_status%';
-- Expected: CHECK constraint listing the 4 values. NO 'partial'. AMEND-1.

-- (3) Confirm bookings.booking_date is timestamptz (AMEND-6).
SELECT data_type FROM information_schema.columns
WHERE table_schema='public' AND table_name='bookings' AND column_name='booking_date';
-- Expected: 'timestamp with time zone'. If 'date', the half-open range form
-- needs adjusting.

-- (4) Confirm client_notes lacks booking_id (AMEND-2 precondition).
SELECT column_name FROM information_schema.columns
WHERE table_schema='public' AND table_name='client_notes'
  AND column_name='booking_id';
-- Expected: 0 rows. If 1 row, AMEND-2 migration is a no-op (use IF NOT EXISTS).

-- (5) Confirm scheduled_notifications.notification_type constraint shape.
SELECT pg_get_constraintdef(oid) FROM pg_constraint
WHERE conrelid='public.scheduled_notifications'::regclass
  AND contype='c' AND conname LIKE '%notification_type%';
-- Expected: either a CHECK constraint (extend it in Wave 1 task 1.5) or
-- unconstrained TEXT (no migration needed; harmless to add CHECK).

-- (6) Confirm workers table exists (not shop_workers) — RESEARCH §1.4.
SELECT count(*) FROM information_schema.tables
WHERE table_schema='public' AND table_name='workers';
-- Expected: 1.

-- (7) Confirm zero direct Dart callers of daily_reports / daily_report_runs / new RPCs.
-- Run locally:
--   grep -rn "from('daily_reports')\|from('daily_report_runs')" lib/
--   grep -rn 'generate_daily_report\|dispatch_daily_reports\|list_daily_reports' lib/
-- Expected: zero hits before Wave 3.

-- (8) Confirm daily_reports / daily_report_runs do NOT already exist.
SELECT count(*) FROM information_schema.tables
WHERE table_schema='public' AND table_name IN ('daily_reports','daily_report_runs');
-- Expected: 0.
```

Pre-flight outputs are pasted at the top of the smoke SQL file so the
executor sees them before running anything.

## Wave breakdown

| Wave | Scope summary | Parallelism notes | Depends on |
|------|---------------|-------------------|------------|
| **1** | Migrations: AMEND-7 pre-flight DO block, `shops.timezone` column add, `daily_reports` table + RLS, `daily_report_runs` table + RLS + REVOKE UPDATE/DELETE, `client_notes.booking_id` column add (AMEND-2), `scheduled_notifications.notification_type` extension, cron registration. | Serial within wave (strict timestamp order). | none |
| **2** | RPCs: `generate_daily_report`, `dispatch_daily_reports`, `list_daily_reports`. All HINT-coded per LD-11. | (a) and (b) serial (b depends on a). (c) parallelizable with (a)/(b). | Wave 1 |
| **3** | Dart data layer: `DailyReportDTO` + `DailyReportSummaryDTO`, `DailyReportException` hierarchy, `_classifyReportError`, three repo methods, `DailyReportKey` + two providers. | Within wave: DTO/exception → repo → provider serial. | Wave 2 |
| **4** | Owner UI: `DailyReportScreen`, `DailyReportHistoryScreen`, deep-link route registration in `app_router.dart`, `case 'daily_report':` arm in `main.dart`. | Screens serial after Wave 3; router/main.dart edits serial after screens. | Wave 3 |
| **5** | i18n: ~30 EN keys in `lib/i10n/app_en.arb`. | **Parallel with Wave 3** (disjoint files). | Wave 1 |
| **6** | Tests + SQL smoke: exception unit tests, repo HINT-classifier tests, widget tests, `16_smoke_tests.sql` (§A–§L) covering SC-1 through SC-18 + IST shop dispatch timing. | Test files mutually independent — parallel within wave. | Waves 4 + 5 |
| **7** | Manual UAT — batched at end of all phases per user's instruction. NOT buildable in this PR. | Sequential by nature. | All prior waves |

**Wave-level parallelism opportunities:**
- Waves 3 and 5 touch disjoint files (`lib/presentation/features/shops/dashboard/` vs `lib/i10n/app_en.arb`) — can run in parallel.
- Wave 2's (c) `list_daily_reports` is independent of (a)/(b) — author in parallel.
- Wave 6 test files are mutually independent — fan out to multiple executors.

---

## Wave 1 — Migrations (serial)

### Task 1.0 — AMEND-7 pre-flight DO block (reports, does not block)

- File(s): `supabase/migrations/20260611100000_phase16_preflight.sql` (NEW)
- Read first: SPEC AMEND-7 (lines 518–550), RESEARCH §2.1 (lines 96–112).
- Description: Run the exact DO block from SPEC AMEND-7 verbatim. Reports `pg_cron`, `pg_net`, `shops.archived_at` via RAISE NOTICE. If `pg_cron` is missing, raises a separate NOTICE instructing the user to enable via Supabase Dashboard before merge. Does NOT raise an exception. The output of this migration is captured in the PR description so the planner of Wave 1 Task 1.6 (cron registration) and Task 2.2 (`dispatch_daily_reports` archived_at predicate) can branch on the finding.
- Acceptance:
  - Migration applies idempotently (DO block is anonymous; re-running is safe).
  - `psql` output contains the line `Phase 16 pre-flight: pg_cron=<bool>, pg_net=<bool>, shops.archived_at=<bool>`.
  - PR description records the three boolean findings.
- Rollback: No-op — the migration writes no schema. Discard the migration file.
- Estimate: 15 min

### Task 1.1 — Add `shops.timezone` column (LD-1)

- File(s): `supabase/migrations/20260611100100_shops_timezone_column.sql` (NEW)
- Read first: SPEC LD-1 (lines 77–88), RESEARCH §1.6 (lines 80–83).
- Description: Add `shops.timezone TEXT NOT NULL DEFAULT 'Africa/Accra'`. Backfill existing rows with the default (the DEFAULT handles this automatically for new INSERTs; the ALTER TABLE adds the default to existing rows in one pass). Add CHECK constraint validating IANA name shape: `CHECK (length(timezone) BETWEEN 3 AND 64 AND timezone !~ ' ')`. Add COMMENT documenting IANA tz database, DST behavior per RESEARCH §3.3, and the locked default rationale (current shop base is in West Africa). Document the DST behaviour explicitly: "Owner-facing UI to change `timezone` deferred; SPEC §Out of scope. DST: 22:30 local is never inside a DST transition window for any IANA zone, so the ±7.5 min dispatch window stays correct year-round (RESEARCH §3.3)."

```sql
ALTER TABLE public.shops
  ADD COLUMN IF NOT EXISTS timezone TEXT NOT NULL DEFAULT 'Africa/Accra';

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public.shops'::regclass
      AND conname = 'shops_timezone_iana_shape'
  ) THEN
    ALTER TABLE public.shops
      ADD CONSTRAINT shops_timezone_iana_shape
      CHECK (length(timezone) BETWEEN 3 AND 64 AND timezone !~ ' ');
  END IF;
END $$;

COMMENT ON COLUMN public.shops.timezone IS
  'IANA timezone (e.g. Africa/Accra, Asia/Kolkata, Europe/London). Default Africa/Accra. Phase 16 dispatcher fires the daily-report cron at 22:30 in this zone. DST: 22:30 is never inside a DST transition window, so the dispatcher''s ±7.5 min slot is robust across spring-forward and fall-back. Owner-facing editor deferred; Phase 16 ships with default only.';
```

- Acceptance:
  - `\d public.shops` shows `timezone TEXT NOT NULL DEFAULT 'Africa/Accra'` + CHECK constraint.
  - `SELECT count(*) FROM shops WHERE timezone IS NULL` returns 0.
  - `SELECT count(DISTINCT timezone) FROM shops` returns 1 (every existing row defaulted to Africa/Accra).
  - Smoke §B passes.
- Rollback: `ALTER TABLE public.shops DROP COLUMN timezone;`
- Estimate: 20 min

### Task 1.2 — Create `daily_reports` table + RLS owner-only SELECT (LD-4, LD-10, AMEND-5)

- File(s): `supabase/migrations/20260611100200_daily_reports_table.sql` (NEW)
- Read first: SPEC LD-4 (lines 129–174), LD-10 (lines 252–266), AMEND-5 (lines 499–504), RESEARCH §6.2 (lines 408–462), Phase 15 RLS pattern at [supabase/migrations/20260611000000_pricing_overrides_table.sql:276-299] (Phase 15 PLAN.md inline).
- Description: Greenfield table with `id UUID PK + UNIQUE (shop_id, report_date)` (AMEND-5). RLS-enabled with **SELECT-only** owner policy via `shops.user_id = auth.uid()` chain (AMEND-3). NO INSERT / UPDATE / DELETE policies (Phase 14 pattern — absence = deny-all for `authenticated`). All mutations flow through SECURITY DEFINER RPCs in Wave 2. The JSONB column is named `payload` (RESEARCH §6.2 picked this for clarity). Composite key idempotency relies on the UNIQUE constraint.

```sql
CREATE TABLE IF NOT EXISTS public.daily_reports (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id       UUID NOT NULL REFERENCES public.shops(id) ON DELETE CASCADE,
  report_date   DATE NOT NULL,
  payload       JSONB NOT NULL,
  generated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT daily_reports_shop_date_unique UNIQUE (shop_id, report_date)
);

-- Hot-path: list_daily_reports keyset on (shop_id, report_date DESC).
-- The UNIQUE constraint above already creates a b-tree index covering
-- (shop_id, report_date), reusable as the keyset index.
-- Single-row lookup by (shop_id, report_date) → uses the same index.

ALTER TABLE public.daily_reports ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies
                 WHERE policyname = 'daily_reports_owner_select') THEN
    CREATE POLICY daily_reports_owner_select ON public.daily_reports
      FOR SELECT TO authenticated
      USING (EXISTS (
        SELECT 1 FROM public.shops sh
        WHERE sh.id = daily_reports.shop_id
          AND sh.user_id = auth.uid()
      ));
  END IF;
END $$;

-- Deliberately NO INSERT / UPDATE / DELETE policies. RLS-enabled table with
-- policy absence = deny-all for authenticated. All mutations route through
-- generate_daily_report (SECURITY DEFINER, bypasses RLS). Phase 14 pattern.

COMMENT ON TABLE public.daily_reports IS
  'Phase 16: persisted JSONB snapshot of one shop''s metrics for one calendar date in the shop''s local timezone. Keyed UNIQUE (shop_id, report_date) → idempotency. Snapshot semantics: LATE EDITS to bookings (status flips, refunds, restorations) do NOT re-price historical reports — owners reading a 2-week-old report see the numbers as they were on that date. Manual re-generation via generate_daily_report REPLACES the snapshot. schema_version 1.';

COMMENT ON COLUMN public.daily_reports.payload IS
  'JSONB blob shape: { revenue_minor (bigint), currency (text), bookings: {completed, no_show, cancelled, confirmed_past_end}, comparison: {yesterday, same_day_last_week}, per_worker[], per_service[], tomorrow: {first_booking_at, count, has_group_bookings}, follow_ups[], generated_at, schema_version }. Money fields are bigint kobo (minor units). Comparison rows are null when comparison date had zero bookings (LD-14). Client names in follow_ups are redacted (LD-13 / checklist 4.4).';
```

- Acceptance:
  - `\d public.daily_reports` shows 7 columns + UNIQUE constraint.
  - `SELECT polname FROM pg_policies WHERE tablename='daily_reports'` returns exactly 1 row (`daily_reports_owner_select`).
  - Smoke §A (RLS owner-only verify, cross-shop SELECT denied) passes.
- Rollback: `DROP TABLE public.daily_reports CASCADE;`
- Estimate: 25 min

### Task 1.3 — Create `daily_report_runs` audit table + REVOKE UPDATE/DELETE (LD-5)

- File(s): `supabase/migrations/20260611100300_daily_report_runs_table.sql` (NEW)
- Read first: SPEC LD-5 (lines 176–201), RESEARCH §8.1 LD-5 row (line 540), Algorithm Quality Checklist §2.22 (P1 [FIN][MUTATION]).
- Description: Greenfield append-only audit table. Schema verbatim from SPEC LD-5. RLS-enabled. SELECT policy: owner of parent shop only (`shop_id IS NOT NULL AND EXISTS ...` — NULL shop_id rows are invisible to authenticated, visible to service_role only). INSERT policy: deny-all by absence (SECURITY DEFINER bypasses). **UPDATE and DELETE explicitly REVOKEd from all roles including service_role** — schema-level enforcement that this is append-only.

```sql
CREATE TABLE IF NOT EXISTS public.daily_report_runs (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id        UUID NULL REFERENCES public.shops(id) ON DELETE SET NULL,
  report_date    DATE NULL,
  triggered_by   TEXT NOT NULL CHECK (triggered_by IN ('cron', 'manual')),
  triggered_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  outcome        TEXT NOT NULL
                   CHECK (outcome IN
                     ('created','updated','skipped_zero_bookings','failed')),
  error_code     TEXT NULL,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_daily_report_runs_shop_triggered
  ON public.daily_report_runs (shop_id, triggered_at DESC)
  WHERE shop_id IS NOT NULL;

ALTER TABLE public.daily_report_runs ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies
                 WHERE policyname = 'daily_report_runs_owner_select') THEN
    CREATE POLICY daily_report_runs_owner_select ON public.daily_report_runs
      FOR SELECT TO authenticated
      USING (
        shop_id IS NOT NULL
        AND EXISTS (
          SELECT 1 FROM public.shops sh
          WHERE sh.id = daily_report_runs.shop_id
            AND sh.user_id = auth.uid()
        )
      );
  END IF;
END $$;

-- Schema-level append-only enforcement. Even service_role cannot UPDATE / DELETE.
REVOKE UPDATE, DELETE ON public.daily_report_runs FROM PUBLIC;
REVOKE UPDATE, DELETE ON public.daily_report_runs FROM authenticated;
REVOKE UPDATE, DELETE ON public.daily_report_runs FROM service_role;
REVOKE UPDATE, DELETE ON public.daily_report_runs FROM anon;

COMMENT ON TABLE public.daily_report_runs IS
  'Phase 16: append-only audit of every daily-report generation attempt (cron + manual). UPDATE and DELETE are revoked from ALL roles at the schema level — checklist 2.22 (P1 [FIN][MUTATION]). shop_id is nullable so the dispatcher can log "ran the tick, zero shops matched" rows. error_code is a stable HINT code (REPORT_RPC_FAILED, etc.) — never free-text. SELECT visible only to the parent shop owner; service_role sees all (including NULL-shop dispatcher heartbeats).';
```

- Acceptance:
  - `\d public.daily_report_runs` shows 8 columns + 2 CHECK constraints + 1 partial index.
  - `\dp public.daily_report_runs` shows UPDATE and DELETE absent from every grantee.
  - `SELECT polname FROM pg_policies WHERE tablename='daily_report_runs'` returns exactly 1 row.
  - Smoke §H (UPDATE attempt as service_role raises permission-denied) passes.
- Rollback: `DROP TABLE public.daily_report_runs;`
- Estimate: 25 min

### Task 1.4 — Add `client_notes.booking_id` column (AMEND-2)

- File(s): `supabase/migrations/20260611100400_client_notes_booking_id_column.sql` (NEW)
- Read first: SPEC AMEND-2 (lines 442–466), RESEARCH §1.5 (lines 72–77), Open Q2 (lines 584–597).
- Description: Add nullable `booking_id UUID NULL REFERENCES public.bookings(id) ON DELETE SET NULL` column + partial index `WHERE booking_id IS NOT NULL`. Phase 12 retention RPCs are NOT modified — they continue upserting on `(shop_id, client_identity)` and leave `booking_id` NULL. This is a forward-compatible addition consumed only by `generate_daily_report` for the `no_show_no_action` lookup.

```sql
ALTER TABLE public.client_notes
  ADD COLUMN IF NOT EXISTS booking_id UUID NULL
  REFERENCES public.bookings(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_client_notes_booking_id
  ON public.client_notes (booking_id)
  WHERE booking_id IS NOT NULL;

COMMENT ON COLUMN public.client_notes.booking_id IS
  'Phase 16: optional linkage to the booking this note was logged against. NULL preserved by Phase 12 retention RPCs (they upsert on shop_id/client_identity and never set booking_id). Phase 16''s generate_daily_report uses this column to compute the no_show_no_action follow-up reason: a no_show booking is flagged for follow-up iff NO client_notes row exists with booking_id = bookings.id.';
```

- Acceptance:
  - `\d public.client_notes` shows the new column + FK + partial index.
  - Existing Phase 12 RPC inserts still succeed (no NOT NULL on the new column).
  - Smoke §F (no_show_no_action rule honors the new column) passes.
- Rollback: `DROP INDEX IF EXISTS public.idx_client_notes_booking_id; ALTER TABLE public.client_notes DROP COLUMN IF EXISTS booking_id;`
- Estimate: 15 min

### Task 1.5 — Extend `scheduled_notifications.notification_type` for `'daily_report'` (LD-6, RESEARCH §4.3)

- File(s): `supabase/migrations/20260611100500_scheduled_notifications_daily_report_type.sql` (NEW)
- Read first: SPEC LD-6 (lines 203–217), RESEARCH §4.3 (lines 306–316). Run AMEND-7 pre-flight query first to determine whether `notification_type` is governed by a CHECK constraint or unconstrained TEXT.
- Description: Branches on the pre-flight finding:
  - **If CHECK constraint exists** (`pg_constraint.conname LIKE '%notification_type%'`): drop and recreate the CHECK adding `'daily_report'` to the allowed values. Use a DO block to read the existing definition and append the value.
  - **If unconstrained TEXT**: emit a NOTICE saying "notification_type is unconstrained TEXT; no migration needed for 'daily_report'" and add a defensive CHECK constraint listing all known types including `'daily_report'`.

```sql
DO $$
DECLARE
  v_constraint_name TEXT;
  v_constraint_def  TEXT;
BEGIN
  SELECT conname, pg_get_constraintdef(oid)
    INTO v_constraint_name, v_constraint_def
  FROM pg_constraint
  WHERE conrelid = 'public.scheduled_notifications'::regclass
    AND contype = 'c'
    AND conname LIKE '%notification_type%'
  LIMIT 1;

  IF v_constraint_name IS NOT NULL THEN
    RAISE NOTICE 'Existing notification_type CHECK: % — %', v_constraint_name, v_constraint_def;
    EXECUTE format('ALTER TABLE public.scheduled_notifications DROP CONSTRAINT %I', v_constraint_name);
    -- Reconstruct with daily_report appended. The executor reads the existing
    -- definition (printed above) and adds 'daily_report' to the IN-list. The
    -- new CHECK is written verbatim here against the known set as of Phase 16.
    -- If the existing list differs from what the executor sees, the executor
    -- updates the list before running this migration.
    ALTER TABLE public.scheduled_notifications
      ADD CONSTRAINT scheduled_notifications_notification_type_check
      CHECK (notification_type IN (
        'booking_owner_30min', 'booking_owner_5min',
        'booking_client_24h', 'booking_client_5min',
        'broadcast', 'promo', 'manual',
        'daily_report'
      ));
  ELSE
    RAISE NOTICE 'notification_type is unconstrained TEXT — adding defensive CHECK with daily_report included';
    ALTER TABLE public.scheduled_notifications
      ADD CONSTRAINT scheduled_notifications_notification_type_check
      CHECK (notification_type IN (
        'booking_owner_30min', 'booking_owner_5min',
        'booking_client_24h', 'booking_client_5min',
        'broadcast', 'promo', 'manual',
        'daily_report'
      ));
  END IF;
END $$;
```

- Executor note: Before running, the executor MUST run the pre-flight query `SELECT pg_get_constraintdef(oid) FROM pg_constraint WHERE conrelid='public.scheduled_notifications'::regclass AND contype='c' AND conname LIKE '%notification_type%';` and reconcile the IN-list above against the live values. If a value is missing from the new list, the executor adds it before applying.
- Acceptance:
  - `INSERT INTO scheduled_notifications (... notification_type ...) VALUES (... 'daily_report' ...)` succeeds.
  - Existing notification_type values (`booking_owner_30min`, etc.) still INSERT successfully.
  - Migration migration output prints either "Existing notification_type CHECK: ..." or "notification_type is unconstrained TEXT — ...".
- Rollback: `ALTER TABLE public.scheduled_notifications DROP CONSTRAINT scheduled_notifications_notification_type_check;` then restore the prior CHECK by hand from the migration output.
- Estimate: 25 min

### Task 1.6 — Register `dispatch-daily-reports` pg_cron job (AMEND-4)

- File(s): `supabase/migrations/20260611100900_schedule_dispatch_daily_reports_cron.sql` (NEW — timestamp ordered AFTER Wave 2 RPC migrations because cron body invokes the RPC; placed in Wave 1 by file naming but executed last among Wave 1 migrations conceptually. Real apply order matches timestamp so this migration MUST land after Task 2.2 creates `dispatch_daily_reports`.)
- Read first: SPEC LD-2 (lines 90–113), AMEND-4 (lines 475–497), RESEARCH §2.2 (lines 115–140), §2.3 (lines 143–158), §2.5 (line 179).
- Description: Register the cron job per AMEND-4 (direct SQL invocation, no Edge Function). Defensive unschedule-first per RESEARCH §2.2 precedent at [supabase/migrations/20260602150000_schedule_notifications_cron.sql:55-69]. Wrapped in `IF EXISTS (SELECT 1 FROM pg_extension WHERE extname='pg_cron')` graceful skip per RESEARCH §2.1 precedent — does NOT block migration if pg_cron is absent (the AMEND-7 pre-flight already surfaced this).

```sql
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
    RAISE NOTICE 'pg_cron extension not installed — skipping dispatch-daily-reports cron registration. Enable pg_cron via Supabase Dashboard and re-run this migration.';
    RETURN;
  END IF;

  -- Defensive idempotency: unschedule existing job first.
  PERFORM cron.unschedule('dispatch-daily-reports')
  WHERE EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'dispatch-daily-reports');

  -- AMEND-4: direct SQL invocation, no Edge Function hop.
  PERFORM cron.schedule(
    'dispatch-daily-reports',
    '*/15 * * * *',
    $cron$ SELECT public.dispatch_daily_reports(); $cron$
  );

  RAISE NOTICE 'Scheduled dispatch-daily-reports at */15 * * * *';
END $$;

COMMENT ON FUNCTION public.dispatch_daily_reports() IS
  'Phase 16: pg_cron-invoked fan-out. Scheduled via */15 * * * *. Idempotent (LD-2: duplicate tick = no-op via daily_reports UNIQUE constraint). Direct SQL invocation (AMEND-4) — no Edge Function. Rollback: PERFORM cron.unschedule(''dispatch-daily-reports'');';
```

- Acceptance:
  - `SELECT jobname, schedule, command FROM cron.job WHERE jobname='dispatch-daily-reports';` returns 1 row when `pg_cron` is enabled.
  - When `pg_cron` is missing, migration applies without error and emits the skip NOTICE.
  - Smoke §I (cron job presence check) passes when `pg_cron` is enabled.
- Rollback: `SELECT cron.unschedule('dispatch-daily-reports');`
- Estimate: 25 min

---

## Wave 2 — RPCs

### Task 2.1 — Create `generate_daily_report(p_shop_id, p_report_date)` RPC (LD-2, LD-3, LD-4, LD-6, LD-7, LD-8, LD-10, LD-11, LD-13, LD-14, AMEND-1, AMEND-2, AMEND-6)

- File(s): `supabase/migrations/20260611100600_generate_daily_report_rpc.sql` (NEW)
- Read first: SPEC LD-2 through LD-14, AMEND-1, AMEND-2, AMEND-6, RESEARCH §1.2-§1.5 (table schemas), §3 (timezone math), §4.1 (notification insert), §5 (minor units math), §8.1 LD-2/LD-3/LD-4/LD-13/LD-14 rows. Phase 15 RPC template at [15-PLAN.md:328-433] for the SECURITY DEFINER + HINT + REVOKE/GRANT/COMMENT shape.
- Description: The keystone RPC. Computes the JSONB snapshot for `(p_shop_id, p_report_date)` and INSERTs into `daily_reports` with `ON CONFLICT (shop_id, report_date) DO UPDATE SET payload = EXCLUDED.payload, generated_at = now(), updated_at = now()`. Idempotent. Emits the push notification via INSERT into `scheduled_notifications`. Writes a `daily_report_runs` audit row with `outcome IN ('created','updated','skipped_zero_bookings','failed')`. HINT-coded errors per LD-11.
- Authz FIRST per LD-10: verify `shops.user_id = auth.uid()` OR caller is service_role (cron context). Raises `OWNER_NOT_FOUND` (errcode 42501) on mismatch.
- Date validation per LD-11: `p_report_date > current_date_in_shop_tz` raises `REPORT_DATE_INVALID`; `p_report_date < current_date - 365` raises `REPORT_DATE_INVALID`.
- Inner aggregator is a single CTE chain — testable as one function call (checklist 6.7 ≥90% branch coverage).
- All revenue math in bigint kobo per LD-3 (RESEARCH §5.2): `SUM((bs.price_at_booking * 100)::bigint)::bigint`. NUMERIC(12,2) × 100 is exact decimal arithmetic.
- Comparison `delta_bps`: `CASE WHEN v_yesterday_rev = 0 THEN NULL ELSE ((v_today_rev - v_yesterday_rev) * 10000) / v_yesterday_rev END` — LD-14.
- Follow-up rules per LD-13 + AMEND-1 + AMEND-2: three reasons computed via UNION ALL.
- Client name redaction per LD-13 (checklist 4.4): `substring(client_name, 1, 1) || repeat('*', 3)` for `A***`.
- Notification INSERT per RESEARCH §4.1: `notification_type='daily_report'`, `delivery_channel='push'`, `user_id=shops.user_id`, `metadata.title`, `metadata.body`, `metadata.shop_id`, `metadata.report_date`, `metadata.type='daily_report'`.
- `SET LOCAL statement_timeout = '10s'` at the top (checklist 2.13).
- Catch-all: outer `EXCEPTION WHEN OTHERS THEN` writes a `daily_report_runs` row with `outcome='failed'`, `error_code='REPORT_RPC_FAILED'`, then re-raises with HINT `REPORT_RPC_FAILED`.

```sql
CREATE OR REPLACE FUNCTION public.generate_daily_report(
  p_shop_id      UUID,
  p_report_date  DATE
) RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
DECLARE
  v_shop            RECORD;
  v_today_rev       BIGINT;
  v_yesterday_rev   BIGINT;
  v_lastweek_rev    BIGINT;
  v_today_date      DATE;
  v_yesterday       DATE;
  v_last_week       DATE;
  v_tomorrow        DATE;
  v_currency        TEXT;
  v_payload         JSONB;
  v_report_id       UUID;
  v_existing        UUID;
  v_outcome         TEXT;
  v_revenue_today   BIGINT;
  v_count_completed INT;
  v_count_no_show   INT;
  v_count_cancelled INT;
  v_count_past_end  INT;
  v_per_worker      JSONB;
  v_per_service     JSONB;
  v_tomorrow_first  TIMESTAMPTZ;
  v_tomorrow_count  INT;
  v_tomorrow_group  BOOLEAN;
  v_follow_ups      JSONB;
  v_yesterday_bps   BIGINT;
  v_lastweek_bps    BIGINT;
  v_comparison      JSONB;
  v_title           TEXT;
  v_body            TEXT;
BEGIN
  SET LOCAL statement_timeout = '10s';

  IF p_shop_id IS NULL OR p_report_date IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'REPORT_DATE_INVALID';
  END IF;

  -- Authz FIRST. AMEND-3: shops.user_id. Allow caller to be the owner OR
  -- the cron context (service_role). The cron context calls via
  -- dispatch_daily_reports which is SECURITY DEFINER itself — when called
  -- from cron, auth.uid() is NULL but the caller is trusted.
  SELECT sh.id, sh.user_id, sh.timezone, sh.currency
    INTO v_shop
  FROM public.shops sh
  WHERE sh.id = p_shop_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501', HINT = 'OWNER_NOT_FOUND';
  END IF;
  IF auth.uid() IS NOT NULL AND v_shop.user_id <> auth.uid() THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501', HINT = 'OWNER_NOT_FOUND';
  END IF;

  -- Date range validation per LD-11.
  v_today_date := (now() AT TIME ZONE v_shop.timezone)::date;
  IF p_report_date > v_today_date THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'REPORT_DATE_INVALID';
  END IF;
  IF p_report_date < (v_today_date - 365) THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'REPORT_DATE_INVALID';
  END IF;

  v_yesterday  := p_report_date - 1;
  v_last_week  := p_report_date - 7;
  v_tomorrow   := p_report_date + 1;
  v_currency   := COALESCE(v_shop.currency, 'GHS');

  -- Aggregate today. Half-open range form per AMEND-6 keeps the index hot.
  SELECT
    COALESCE(SUM((bs.price_at_booking * 100)::bigint)::bigint, 0),
    COUNT(*) FILTER (WHERE b.status = 'completed'),
    COUNT(*) FILTER (WHERE b.status = 'no_show'),
    COUNT(*) FILTER (WHERE b.status = 'cancelled'),
    COUNT(*) FILTER (WHERE b.status = 'confirmed' AND b.end_time < now())
  INTO v_today_rev, v_count_completed, v_count_no_show, v_count_cancelled, v_count_past_end
  FROM public.bookings b
  LEFT JOIN public.booking_services bs ON bs.booking_id = b.id
  WHERE b.shop_id = p_shop_id
    AND b.booking_date >= ((p_report_date::timestamp) AT TIME ZONE v_shop.timezone)
    AND b.booking_date <  (((p_report_date + 1)::timestamp) AT TIME ZONE v_shop.timezone);

  -- Yesterday + same-day-last-week revenue (for delta_bps).
  SELECT COALESCE(SUM((bs.price_at_booking * 100)::bigint)::bigint, 0)
    INTO v_yesterday_rev
  FROM public.bookings b
  LEFT JOIN public.booking_services bs ON bs.booking_id = b.id
  WHERE b.shop_id = p_shop_id
    AND b.booking_date >= ((v_yesterday::timestamp) AT TIME ZONE v_shop.timezone)
    AND b.booking_date <  (((v_yesterday + 1)::timestamp) AT TIME ZONE v_shop.timezone);

  SELECT COALESCE(SUM((bs.price_at_booking * 100)::bigint)::bigint, 0)
    INTO v_lastweek_rev
  FROM public.bookings b
  LEFT JOIN public.booking_services bs ON bs.booking_id = b.id
  WHERE b.shop_id = p_shop_id
    AND b.booking_date >= ((v_last_week::timestamp) AT TIME ZONE v_shop.timezone)
    AND b.booking_date <  (((v_last_week + 1)::timestamp) AT TIME ZONE v_shop.timezone);

  -- LD-14: comparison rows are NULL when comparison date had zero bookings.
  v_yesterday_bps := CASE WHEN v_yesterday_rev = 0 THEN NULL
                          ELSE ((v_today_rev - v_yesterday_rev) * 10000) / v_yesterday_rev
                     END;
  v_lastweek_bps  := CASE WHEN v_lastweek_rev  = 0 THEN NULL
                          ELSE ((v_today_rev - v_lastweek_rev) * 10000) / v_lastweek_rev
                     END;
  v_comparison := jsonb_build_object(
    'yesterday', CASE WHEN v_yesterday_rev = 0 THEN NULL
                      ELSE jsonb_build_object(
                        'revenue_minor', v_yesterday_rev,
                        'delta_bps',     v_yesterday_bps)
                 END,
    'same_day_last_week', CASE WHEN v_lastweek_rev = 0 THEN NULL
                               ELSE jsonb_build_object(
                                 'revenue_minor', v_lastweek_rev,
                                 'delta_bps',     v_lastweek_bps)
                          END
  );

  -- Per-worker breakdown. workers (NOT shop_workers) per RESEARCH §1.4.
  -- NULL worker_id → "Unassigned".
  SELECT COALESCE(jsonb_agg(jsonb_build_object(
    'worker_id',     COALESCE(w.id::text, 'unassigned'),
    'name',          COALESCE(w.name, 'Unassigned'),
    'revenue_minor', revenue_minor,
    'count',         booking_count
  ) ORDER BY revenue_minor DESC), '[]'::jsonb) INTO v_per_worker
  FROM (
    SELECT
      bs.worker_id,
      SUM((bs.price_at_booking * 100)::bigint)::bigint AS revenue_minor,
      COUNT(DISTINCT bs.booking_id)::int               AS booking_count
    FROM public.booking_services bs
    JOIN public.bookings b ON b.id = bs.booking_id
    WHERE b.shop_id = p_shop_id
      AND b.booking_date >= ((p_report_date::timestamp) AT TIME ZONE v_shop.timezone)
      AND b.booking_date <  (((p_report_date + 1)::timestamp) AT TIME ZONE v_shop.timezone)
    GROUP BY bs.worker_id
  ) agg
  LEFT JOIN public.workers w ON w.id = agg.worker_id;

  -- Per-service breakdown. Use bs.service_name (denormalized) per RESEARCH §1.4.
  SELECT COALESCE(jsonb_agg(jsonb_build_object(
    'slot_id',       bs.slot_id,
    'name',          bs.service_name,
    'revenue_minor', SUM((bs.price_at_booking * 100)::bigint)::bigint,
    'count',         COUNT(DISTINCT bs.booking_id)::int
  ) ORDER BY SUM((bs.price_at_booking * 100)::bigint)::bigint DESC), '[]'::jsonb)
  INTO v_per_service
  FROM public.booking_services bs
  JOIN public.bookings b ON b.id = bs.booking_id
  WHERE b.shop_id = p_shop_id
    AND b.booking_date >= ((p_report_date::timestamp) AT TIME ZONE v_shop.timezone)
    AND b.booking_date <  (((p_report_date + 1)::timestamp) AT TIME ZONE v_shop.timezone)
  GROUP BY bs.slot_id, bs.service_name;

  -- Tomorrow peek (LD-12). First booking time, total count, group flag.
  SELECT
    MIN(b.start_time),
    COUNT(*)::int,
    BOOL_OR(COALESCE(b.is_group_booking, false))
  INTO v_tomorrow_first, v_tomorrow_count, v_tomorrow_group
  FROM public.bookings b
  WHERE b.shop_id = p_shop_id
    AND b.booking_date >= ((v_tomorrow::timestamp) AT TIME ZONE v_shop.timezone)
    AND b.booking_date <  (((v_tomorrow + 1)::timestamp) AT TIME ZONE v_shop.timezone)
    AND b.status NOT IN ('cancelled');

  -- Follow-ups: 3 reasons per LD-13 + AMEND-1 + AMEND-2.
  -- All entries redact client names per checklist 4.4: "A***" format.
  SELECT COALESCE(jsonb_agg(entry ORDER BY entry->>'reason'), '[]'::jsonb)
    INTO v_follow_ups
  FROM (
    -- reason='confirmed_past_end' — LD-13
    SELECT jsonb_build_object(
      'booking_id', b.id,
      'reason',     'confirmed_past_end',
      'client_name_redacted',
        COALESCE(LEFT(NULLIF(TRIM(COALESCE(b.client_name, '')), ''), 1), 'A') || '***'
    ) AS entry
    FROM public.bookings b
    WHERE b.shop_id = p_shop_id
      AND b.booking_date >= ((p_report_date::timestamp) AT TIME ZONE v_shop.timezone)
      AND b.booking_date <  (((p_report_date + 1)::timestamp) AT TIME ZONE v_shop.timezone)
      AND b.status = 'confirmed'
      AND b.end_time < now()

    UNION ALL

    -- reason='unpaid_balance' — AMEND-1 (payment_status IN ('unpaid','failed'))
    SELECT jsonb_build_object(
      'booking_id',  b.id,
      'reason',      'unpaid_balance',
      'amount_minor', ((b.total_amount - b.deposit_amount) * 100)::bigint,
      'client_name_redacted',
        COALESCE(LEFT(NULLIF(TRIM(COALESCE(b.client_name, '')), ''), 1), 'A') || '***'
    )
    FROM public.bookings b
    WHERE b.shop_id = p_shop_id
      AND b.booking_date >= ((p_report_date::timestamp) AT TIME ZONE v_shop.timezone)
      AND b.booking_date <  (((p_report_date + 1)::timestamp) AT TIME ZONE v_shop.timezone)
      AND b.payment_status IN ('unpaid', 'failed')
      AND b.end_time < now()

    UNION ALL

    -- reason='no_show_no_action' — AMEND-2 (client_notes.booking_id linkage)
    SELECT jsonb_build_object(
      'booking_id', b.id,
      'reason',     'no_show_no_action',
      'client_name_redacted',
        COALESCE(LEFT(NULLIF(TRIM(COALESCE(b.client_name, '')), ''), 1), 'A') || '***'
    )
    FROM public.bookings b
    WHERE b.shop_id = p_shop_id
      AND b.booking_date >= ((p_report_date::timestamp) AT TIME ZONE v_shop.timezone)
      AND b.booking_date <  (((p_report_date + 1)::timestamp) AT TIME ZONE v_shop.timezone)
      AND b.status = 'no_show'
      AND NOT EXISTS (
        SELECT 1 FROM public.client_notes cn
        WHERE cn.booking_id = b.id
      )
  ) t;

  -- LD-7 zero-booking handling. Total bookings today = sum of status buckets.
  -- If zero, we still INSERT a row (with revenue_minor=0 and empty arrays) when
  -- called manually (LD-7 line 227). The cron-side selector filters zero-booking
  -- shops out BEFORE this RPC is called (dispatch_daily_reports HAVING count > 0).
  IF (v_count_completed + v_count_no_show + v_count_cancelled + v_count_past_end) = 0
     AND v_today_rev = 0 AND auth.uid() IS NULL THEN
    -- Cron context (auth.uid() NULL) reaching here means dispatch_daily_reports
    -- passed an empty shop through — defensive log + skip.
    INSERT INTO public.daily_report_runs (
      shop_id, report_date, triggered_by, outcome, error_code
    ) VALUES (p_shop_id, p_report_date, 'cron', 'skipped_zero_bookings', NULL);
    RETURN NULL;
  END IF;

  -- Build the payload (LD-4 schema_version 1).
  v_payload := jsonb_build_object(
    'revenue_minor', v_today_rev,
    'currency',      v_currency,
    'bookings', jsonb_build_object(
      'completed',          v_count_completed,
      'no_show',            v_count_no_show,
      'cancelled',          v_count_cancelled,
      'confirmed_past_end', v_count_past_end
    ),
    'comparison',  v_comparison,
    'per_worker',  v_per_worker,
    'per_service', v_per_service,
    'tomorrow', jsonb_build_object(
      'first_booking_at',   v_tomorrow_first,
      'count',              COALESCE(v_tomorrow_count, 0),
      'has_group_bookings', COALESCE(v_tomorrow_group, false)
    ),
    'follow_ups',     v_follow_ups,
    'generated_at',   now(),
    'schema_version', 1
  );

  -- Idempotent INSERT / UPDATE. Compound UNIQUE key handles concurrent ticks.
  SELECT id INTO v_existing
  FROM public.daily_reports
  WHERE shop_id = p_shop_id AND report_date = p_report_date;
  v_outcome := CASE WHEN v_existing IS NULL THEN 'created' ELSE 'updated' END;

  INSERT INTO public.daily_reports (
    shop_id, report_date, payload, generated_at
  ) VALUES (
    p_shop_id, p_report_date, v_payload, now()
  )
  ON CONFLICT (shop_id, report_date) DO UPDATE
    SET payload      = EXCLUDED.payload,
        generated_at = now(),
        updated_at   = now()
  RETURNING id INTO v_report_id;

  -- Audit row.
  INSERT INTO public.daily_report_runs (
    shop_id, report_date, triggered_by, outcome, error_code
  ) VALUES (
    p_shop_id, p_report_date,
    CASE WHEN auth.uid() IS NULL THEN 'cron' ELSE 'manual' END,
    v_outcome, NULL
  );

  -- Push notification: components only, no localized strings (RESEARCH §4.5
  -- recommends path (b) — edge function formats at delivery time). Title and
  -- body are computed server-side from raw components, EN-only for v1.
  v_title := 'Today''s report is ready';
  v_body  := format('%s %s · %s bookings',
    v_currency,
    to_char((v_today_rev / 100.0)::numeric, 'FM999G999G999.00'),
    v_count_completed + v_count_no_show + v_count_cancelled);

  INSERT INTO public.scheduled_notifications (
    user_id, shop_id, notification_type, scheduled_for, delivery_channel, metadata
  ) VALUES (
    v_shop.user_id,
    p_shop_id,
    'daily_report',
    now(),
    'push',
    jsonb_build_object(
      'title',         v_title,
      'body',          v_body,
      'shop_id',       p_shop_id,
      'report_date',   p_report_date,
      'type',          'daily_report',
      'revenue_minor', v_today_rev,
      'currency',      v_currency,
      'booking_count', v_count_completed + v_count_no_show + v_count_cancelled
    )
  );

  RETURN v_report_id;

EXCEPTION
  WHEN OTHERS THEN
    -- PLAN-CHECK fix: never write SQLERRM (free-text) into error_code;
    -- never silently collapse known HINTs into REPORT_RPC_FAILED.
    -- Capture the diagnostic HINT and SQLSTATE, audit with the stable
    -- code, then re-raise preserving the originating HINT so SC-14
    -- (OWNER_NOT_FOUND), SC-15 / SC-16 (REPORT_DATE_INVALID) reach the
    -- client. Unknown errors collapse to REPORT_RPC_FAILED only when
    -- HINT was absent at the throw site.
    DECLARE
      v_hint     TEXT := COALESCE(NULLIF(current_setting('plpgsql.exception_hint', true), ''), '');
      v_sqlstate TEXT := '';
      v_code     TEXT;
    BEGIN
      GET STACKED DIAGNOSTICS
        v_hint     = PG_EXCEPTION_HINT,
        v_sqlstate = RETURNED_SQLSTATE;
      v_code := CASE
        WHEN v_hint IN ('OWNER_NOT_FOUND', 'REPORT_DATE_INVALID', 'SHOP_NOT_FOUND')
          THEN v_hint
        ELSE 'REPORT_RPC_FAILED'
      END;
      INSERT INTO public.daily_report_runs (
        shop_id, report_date, triggered_by, outcome, error_code
      ) VALUES (
        p_shop_id, p_report_date,
        CASE WHEN auth.uid() IS NULL THEN 'cron' ELSE 'manual' END,
        'failed', v_code
      );
      RAISE EXCEPTION 'report_failed'
        USING ERRCODE = v_sqlstate, HINT = v_code;
    END;
END;
$function$;

REVOKE ALL ON FUNCTION public.generate_daily_report(UUID, DATE) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.generate_daily_report(UUID, DATE) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.generate_daily_report(UUID, DATE) TO authenticated;

COMMENT ON FUNCTION public.generate_daily_report(UUID, DATE) IS
  'Phase 16: idempotent daily-report builder. INSERT ... ON CONFLICT (shop_id, report_date) DO UPDATE — duplicate cron tick = no-op; manual re-generate REPLACES. Authz: shops.user_id = auth.uid() OR auth.uid() IS NULL (cron context). Money math in bigint kobo (LD-3): NUMERIC(12,2) × 100 is exact. Comparison delta_bps is NULL when comparison date has zero bookings (LD-14). Follow-ups redact client names per checklist 4.4. Big-O: per-shop scan over today + yesterday + last-week + tomorrow ranges, each O(N) with the idx_bookings_shop_date_status index. 10s statement_timeout (checklist 2.13). HINT codes: OWNER_NOT_FOUND, REPORT_DATE_INVALID, REPORT_RPC_FAILED. SECURITY DEFINER.';
```

- Acceptance:
  - Smoke §B (happy path — owner calls, returns UUID, daily_reports row written, scheduled_notifications row written, daily_report_runs row with outcome='created').
  - Smoke §C (idempotency — same `(shop_id, report_date)` called twice: second call returns same UUID via UPDATE; daily_report_runs has two rows, second with outcome='updated').
  - Smoke §D (cross-shop authz: owner_b calling for shop_a's id raises HINT `OWNER_NOT_FOUND`, errcode 42501).
  - Smoke §E (future date raises HINT `REPORT_DATE_INVALID`).
  - Smoke §E (> 365-day-old date raises `REPORT_DATE_INVALID`).
  - Smoke §F (no_show_no_action follow-up appears for no_show booking lacking client_notes.booking_id; absent after a matching client_notes insert).
  - Smoke §G (revenue computation: 3 bookings × 50 GHS each → revenue_minor = 15000; comparison.yesterday is NULL when yesterday had zero bookings; delta_bps = 0 when today equals yesterday).
  - Client name in `payload->'follow_ups'->0->>'client_name_redacted'` matches `^[A-Z]\*\*\*$` regex.
- Rollback: `DROP FUNCTION public.generate_daily_report(UUID, DATE);`
- Estimate: 90 min

### Task 2.2 — Create `dispatch_daily_reports()` RPC (LD-2, LD-7, AMEND-6, AMEND-7)

- File(s): `supabase/migrations/20260611100700_dispatch_daily_reports_rpc.sql` (NEW)
- Read first: SPEC LD-2 (lines 92–107), LD-7 (lines 219–229), AMEND-6 (lines 506–517), AMEND-7 finding from Task 1.0 output, RESEARCH §3.2 (lines 190–225 — verbatim selector form), §2.4 (lines 162–175 — REVOKE pattern).
- Description: Cron-callable fan-out. Selects shops where local time is 22:22:30..22:37:30 AND ≥1 booking on local_date AND no daily_reports row for `(shop_id, local_date)`. For each matched shop, calls `generate_daily_report(shop_id, local_date)`. When zero shops match, writes one heartbeat row to daily_report_runs with `shop_id=NULL, outcome='skipped_zero_bookings', triggered_by='cron'` so we have evidence the cron ran (LD-7 line 222–225).
- The `shops.archived_at` predicate branches on AMEND-7 finding (Task 1.0):
  - If `shops.archived_at` column exists: `WHERE sh.archived_at IS NULL`
  - If absent: no archive filter
  - The executor reads the Task 1.0 NOTICE output and edits the migration accordingly before running.
- `SET LOCAL statement_timeout = '30s'` (cap fan-out wall clock; checklist 2.13 + 3.12).
- REVOKE ALL FROM PUBLIC + authenticated. NO GRANT (cron runs as superuser; RESEARCH §2.4 line 175). Structured log line on exit (checklist 4.6 RED metrics).

```sql
CREATE OR REPLACE FUNCTION public.dispatch_daily_reports()
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
DECLARE
  v_started_at  TIMESTAMPTZ := clock_timestamp();
  v_shop_count  INT := 0;
  v_error_count INT := 0;
  v_row         RECORD;
BEGIN
  SET LOCAL statement_timeout = '30s';

  FOR v_row IN
    WITH shop_local AS (
      SELECT
        sh.id                                                  AS shop_id,
        sh.timezone                                            AS tz,
        (now() AT TIME ZONE sh.timezone)::time                 AS local_time,
        (now() AT TIME ZONE sh.timezone)::date                 AS local_date
      FROM public.shops sh
      -- AMEND-7: executor edits this WHERE based on Task 1.0 pre-flight finding.
      -- If shops.archived_at exists: add `WHERE sh.archived_at IS NULL`.
      -- If absent: remove this comment and leave WHERE empty (or drop WHERE).
      WHERE TRUE
    )
    SELECT sl.shop_id, sl.local_date AS report_date
    FROM shop_local sl
    WHERE sl.local_time BETWEEN TIME '22:22:30' AND TIME '22:37:30'
      AND EXISTS (
        SELECT 1 FROM public.bookings b
        WHERE b.shop_id = sl.shop_id
          AND b.booking_date >= ((sl.local_date::timestamp) AT TIME ZONE sl.tz)
          AND b.booking_date <  (((sl.local_date + 1)::timestamp) AT TIME ZONE sl.tz)
      )
      AND NOT EXISTS (
        SELECT 1 FROM public.daily_reports dr
        WHERE dr.shop_id = sl.shop_id AND dr.report_date = sl.local_date
      )
  LOOP
    BEGIN
      PERFORM public.generate_daily_report(v_row.shop_id, v_row.report_date);
      v_shop_count := v_shop_count + 1;
    EXCEPTION
      WHEN OTHERS THEN
        v_error_count := v_error_count + 1;
        -- Inner exception logged by generate_daily_report's own catch-all; we
        -- continue the loop so a single shop's failure does not poison the tick.
    END;
  END LOOP;

  -- LD-7: heartbeat row when zero shops matched, so we know the cron ran.
  IF v_shop_count = 0 AND v_error_count = 0 THEN
    INSERT INTO public.daily_report_runs (
      shop_id, report_date, triggered_by, outcome, error_code
    ) VALUES (NULL, NULL, 'cron', 'skipped_zero_bookings', NULL);
  END IF;

  -- Structured RED-metric log (checklist 4.6).
  RAISE NOTICE 'daily_report.dispatch_completed shop_count=% error_count=% duration_ms=%',
    v_shop_count,
    v_error_count,
    EXTRACT(MILLISECONDS FROM clock_timestamp() - v_started_at)::int;
END;
$function$;

REVOKE ALL ON FUNCTION public.dispatch_daily_reports() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.dispatch_daily_reports() FROM authenticated;
-- No GRANT to authenticated — cron runs as superuser; LD-10 explicit deny.

COMMENT ON FUNCTION public.dispatch_daily_reports() IS
  'Phase 16: cron-only fan-out. Scheduled */15 * * * * via dispatch-daily-reports cron job. Selects shops with local time in [22:22:30, 22:37:30] AND ≥1 booking today AND no daily_reports row yet, then invokes generate_daily_report per shop. Zero-shop ticks write a heartbeat row to daily_report_runs (LD-7). 30s statement_timeout caps the fan-out wall clock (checklist 2.13). Per-shop failures are caught and counted; one failing shop never poisons sibling shops. SECURITY DEFINER. REVOKED from authenticated.';
```

- Executor note: Before running, the executor MUST consult the Task 1.0 pre-flight NOTICE output. If `shops.archived_at` exists, the executor adds `AND sh.archived_at IS NULL` to the `shop_local` CTE's WHERE clause. If absent, the executor leaves the clause as-is (the `WHERE TRUE` is a placeholder that the executor either replaces with the archive predicate or drops).
- Acceptance:
  - Smoke §I (cron job present + EXPLAIN ANALYZE on the selector uses `idx_bookings_shop_date_status` index — half-open range form per AMEND-6).
  - Smoke §J (zero-booking shop: dispatch runs, no daily_reports row, no scheduled_notifications row, daily_report_runs heartbeat row appears).
  - Smoke §K (duplicate-tick: call dispatch twice in same minute → only one daily_reports row, one scheduled_notifications row, two daily_report_runs rows but second one has outcome='skipped' because the NOT EXISTS guard excludes already-reported shops).
  - Smoke §L (IST shop: configure `shops.timezone='Asia/Kolkata'`, set the test clock to 17:00 UTC = 22:30 IST, verify the shop appears in the dispatch selector — SC-18).
- Rollback: `DROP FUNCTION public.dispatch_daily_reports();`
- Estimate: 60 min

### Task 2.3 — Create `list_daily_reports(p_shop_id, p_before_date, p_page_size)` RPC (LD-9, LD-10, RESEARCH §6.2 Path A)

- File(s): `supabase/migrations/20260611100800_list_daily_reports_rpc.sql` (NEW)
- Read first: SPEC LD-9 (lines 244–250), LD-10 (lines 252–266), LD-11 (lines 268–281), RESEARCH §6.2 (lines 408–462 — verbatim RPC body — Path A picked because page_size clamp + authz + sort-direction policy fit naturally into a single SECURITY DEFINER guarantee).
- Description: Keyset-paginated read. `page_size` clamped to [10, 50] with default 30 (LD-9). Authz via `shops.user_id = auth.uid()` per AMEND-3. Returns rows in `report_date DESC` order. `p_before_date IS NULL` returns the first page; subsequent pages pass the oldest `report_date` seen.

```sql
CREATE OR REPLACE FUNCTION public.list_daily_reports(
  p_shop_id      UUID,
  p_before_date  DATE DEFAULT NULL,
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
AS $function$
DECLARE
  v_clamped_size INT;
BEGIN
  IF p_shop_id IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'REPORT_DATE_INVALID';
  END IF;

  -- Authz FIRST per LD-10. AMEND-3: shops.user_id.
  IF NOT EXISTS (
    SELECT 1 FROM public.shops sh
    WHERE sh.id = p_shop_id AND sh.user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501', HINT = 'OWNER_NOT_FOUND';
  END IF;

  -- LD-9 clamp.
  v_clamped_size := GREATEST(10, LEAST(50, COALESCE(p_page_size, 30)));

  RETURN QUERY
    SELECT dr.shop_id,
           dr.report_date,
           (dr.payload->>'revenue_minor')::bigint,
           (dr.payload->>'currency'),
           dr.payload,
           dr.generated_at
    FROM public.daily_reports dr
    WHERE dr.shop_id = p_shop_id
      AND (p_before_date IS NULL OR dr.report_date < p_before_date)
    ORDER BY dr.report_date DESC
    LIMIT v_clamped_size;
END;
$function$;

REVOKE ALL ON FUNCTION public.list_daily_reports(UUID, DATE, INT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.list_daily_reports(UUID, DATE, INT) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.list_daily_reports(UUID, DATE, INT) TO authenticated;

COMMENT ON FUNCTION public.list_daily_reports(UUID, DATE, INT) IS
  'Phase 16: keyset-paginated read. Authz via shops.user_id = auth.uid() (LD-10 / AMEND-3). page_size clamped to [10, 50] with default 30 (LD-9). Returns rows in report_date DESC order; keyset uses (report_date < p_before_date) for next-page cursor. Big-O: index lookup on (shop_id, report_date) — uses the UNIQUE constraint b-tree. STABLE function; SECURITY DEFINER. HINT codes: OWNER_NOT_FOUND, REPORT_DATE_INVALID.';
```

- Acceptance:
  - Smoke §M (happy path — owner returns rows; non-owner raises 42501 OWNER_NOT_FOUND).
  - Smoke §M (page_size=5 → clamped to 10; page_size=100 → clamped to 50 — SC-17).
  - Smoke §M (keyset cursor: pass `p_before_date = oldest_seen_date`, returns earlier rows).
- Rollback: `DROP FUNCTION public.list_daily_reports(UUID, DATE, INT);`
- Estimate: 45 min

---

## Wave 3 — Dart data layer (parallel with Wave 5)

### Task 3.1 — Create `DailyReportDTO`, `DailyReportSummaryDTO`, `FollowUpReason` enum, and `DailyReportException` hierarchy

- File(s):
  - `lib/presentation/features/shops/dashboard/data/models/daily_report_dto.dart` (NEW)
  - `lib/presentation/features/shops/dashboard/data/exceptions/daily_report_exceptions.dart` (NEW)
- Read first: SPEC LD-4 (JSONB shape lines 132–164), LD-11 (HINT codes lines 270–281), LD-13 (follow-up reasons lines 292–308 + AMEND-1), Phase 15 [pricing_override_dto.dart] + [pricing_override_exceptions.dart] for shape.
- Description:

**`daily_report_dto.dart`** — Two DTOs + one enum:

```dart
enum FollowUpReason {
  confirmedPastEnd('confirmed_past_end'),
  unpaidBalance('unpaid_balance'),
  noShowNoAction('no_show_no_action');

  const FollowUpReason(this.dbValue);
  final String dbValue;
  static FollowUpReason fromDb(String v) =>
      values.firstWhere((r) => r.dbValue == v);
}

class FollowUpEntry {
  final String bookingId;
  final FollowUpReason reason;
  final String clientNameRedacted; // "A***"
  final int? amountMinor;          // present iff reason == unpaidBalance
  const FollowUpEntry({...});
  factory FollowUpEntry.fromJson(Map<String, dynamic> j) => ...;
}

class WorkerBreakdown {
  final String workerId; // "unassigned" sentinel possible
  final String name;
  final int revenueMinor;
  final int count;
  const WorkerBreakdown({...});
  factory WorkerBreakdown.fromJson(Map<String, dynamic> j) => ...;
}

class ServiceBreakdown {
  final String slotId;
  final String name;
  final int revenueMinor;
  final int count;
  const ServiceBreakdown({...});
  factory ServiceBreakdown.fromJson(Map<String, dynamic> j) => ...;
}

class ComparisonRow {
  final int revenueMinor;
  final int deltaBps; // basis points; can be negative
  const ComparisonRow({required this.revenueMinor, required this.deltaBps});
  factory ComparisonRow.fromJson(Map<String, dynamic> j) => ...;
}

class TomorrowPeek {
  final DateTime? firstBookingAt;
  final int count;
  final bool hasGroupBookings;
  const TomorrowPeek({...});
  factory TomorrowPeek.fromJson(Map<String, dynamic> j) => ...;
}

class BookingCounts {
  final int completed;
  final int noShow;
  final int cancelled;
  final int confirmedPastEnd;
  const BookingCounts({...});
  factory BookingCounts.fromJson(Map<String, dynamic> j) => ...;
}

class DailyReportDTO {
  final String shopId;
  final DateTime reportDate;            // local-tz date, no time component
  final int revenueMinor;               // bigint kobo
  final String currency;                // 'GHS', 'INR', etc.
  final BookingCounts bookings;
  final ComparisonRow? comparisonYesterday;       // null per LD-14
  final ComparisonRow? comparisonSameDayLastWeek; // null per LD-14
  final List<WorkerBreakdown> perWorker;
  final List<ServiceBreakdown> perService;
  final TomorrowPeek tomorrow;
  final List<FollowUpEntry> followUps;
  final DateTime generatedAt;
  final int schemaVersion;              // == 1 for Phase 16

  const DailyReportDTO({...});

  // Reads the JSONB payload as-emitted by generate_daily_report.
  factory DailyReportDTO.fromJson({
    required String shopId,
    required DateTime reportDate,
    required Map<String, dynamic> payload,
    DateTime? generatedAt,
  }) => ...;

  // Display helper: kobo → "GHS 1,250.00" formatted string. Owner-screen only.
  String formattedRevenue() => ...;
}

class DailyReportSummaryDTO {
  final String shopId;
  final DateTime reportDate;
  final int revenueMinor;
  final String currency;
  final DateTime generatedAt;
  const DailyReportSummaryDTO({...});
  factory DailyReportSummaryDTO.fromRow(Map<String, dynamic> row) => ...;
}
```

**`daily_report_exceptions.dart`** — Hierarchy mirroring `PricingOverrideException`:

```dart
class DailyReportException implements Exception {
  final String message;
  final String code;
  final String userMessage;
  DailyReportException(this.message,
      {this.code = 'REPORT_GENERIC', String? userMessage})
      : userMessage = userMessage ?? 'Something went wrong. Please try again.';
  @override String toString() => 'DailyReportException($code): $message';
}

class ReportAccessDeniedException extends DailyReportException {
  ReportAccessDeniedException()
      : super('Caller does not own the parent shop',
          code: 'REPORT_NOT_FOUND',
          userMessage: "We couldn't find that report.");
}

class ReportDateInvalidException extends DailyReportException {
  ReportDateInvalidException()
      : super('Report date is in the future or > 365 days ago',
          code: 'REPORT_DATE_INVALID',
          userMessage: 'That date is out of range.');
}

class ReportNotFoundException extends DailyReportException {
  ReportNotFoundException()
      : super('No report exists for this date',
          code: 'REPORT_NOT_FOUND',
          userMessage: "No report yet for that date.");
}

class ReportGenerationFailedException extends DailyReportException {
  ReportGenerationFailedException()
      : super('Server failed to generate the report',
          code: 'REPORT_RPC_FAILED',
          userMessage: "We couldn't build the report. Please try again.");
}
```

- Acceptance:
  - `flutter analyze` clean.
  - `flutter test test/.../daily_report_exceptions_test.dart` 4 subtype cases pass.
  - DTO `fromJson` round-trip preserves nulls on `comparisonYesterday`, `comparisonSameDayLastWeek`, `tomorrow.firstBookingAt`, `followUps[].amountMinor`.
  - DTO `fromJson` correctly parses follow-ups with `reason` strings from the DB.
- Rollback: Delete both files.
- Estimate: 35 min

### Task 3.2 — Extend `DashboardRepository` + `SupabaseDashboardRepository` with three daily-report methods + classifier

- File(s):
  - `lib/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart` (EDIT — abstract methods)
  - `lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart` (EDIT — concrete impl + `_classifyReportError`)
- Read first: Phase 15 `_classifyPricingOverrideError` pattern at [supabase_dashboard_repository.dart:2700-2895] (verify exact line via grep). SPEC LD-11 HINT vocabulary (lines 270–281).
- Description: Append three abstract methods + concrete impls + private `_classifyReportError(PostgrestException)` switch on `(e.code, e.hint)`:

```dart
// Abstract (dashboard_repository.dart):
Future<DailyReportDTO?> getDailyReport({
  required String shopId,
  required DateTime reportDate,
});

Future<List<DailyReportSummaryDTO>> listDailyReports({
  required String shopId,
  DateTime? beforeDate,
  int pageSize = 30,
});

Future<String> regenerateDailyReport({
  required String shopId,
  required DateTime reportDate,
});

// Concrete (supabase_dashboard_repository.dart):
@override
Future<DailyReportDTO?> getDailyReport({
  required String shopId,
  required DateTime reportDate,
}) async {
  try {
    final row = await _supabase
        .from('daily_reports')
        .select('shop_id, report_date, payload, generated_at')
        .eq('shop_id', shopId)
        .eq('report_date', _dateOnlyIso(reportDate))
        .maybeSingle();
    if (row == null) return null;
    return DailyReportDTO.fromJson(
      shopId: row['shop_id'] as String,
      reportDate: DateTime.parse(row['report_date'] as String),
      payload: row['payload'] as Map<String, dynamic>,
      generatedAt: DateTime.parse(row['generated_at'] as String),
    );
  } on PostgrestException catch (e) {
    AppLogger.error('getDailyReport failed', e,
      shop_id: shopId, error_code: e.code);
    throw _classifyReportError(e);
  }
}

@override
Future<List<DailyReportSummaryDTO>> listDailyReports({
  required String shopId,
  DateTime? beforeDate,
  int pageSize = 30,
}) async {
  try {
    final rows = await _supabase.rpc('list_daily_reports', params: {
      'p_shop_id':     shopId,
      'p_before_date': beforeDate == null ? null : _dateOnlyIso(beforeDate),
      'p_page_size':   pageSize,
    });
    return (rows as List)
        .map((r) => DailyReportSummaryDTO.fromRow(r as Map<String, dynamic>))
        .toList();
  } on PostgrestException catch (e) {
    AppLogger.error('listDailyReports failed', e,
      shop_id: shopId, error_code: e.code);
    throw _classifyReportError(e);
  }
}

@override
Future<String> regenerateDailyReport({
  required String shopId,
  required DateTime reportDate,
}) async {
  try {
    final id = await _supabase.rpc('generate_daily_report', params: {
      'p_shop_id':     shopId,
      'p_report_date': _dateOnlyIso(reportDate),
    });
    return id as String;
  } on PostgrestException catch (e) {
    AppLogger.error('regenerateDailyReport failed', e,
      shop_id: shopId, error_code: e.code);
    throw _classifyReportError(e);
  }
}

DailyReportException _classifyReportError(PostgrestException e) {
  // HINT-driven; no string matching on e.message.
  switch (e.hint) {
    case 'OWNER_NOT_FOUND':
      return ReportAccessDeniedException();
    case 'REPORT_DATE_INVALID':
      return ReportDateInvalidException();
    case 'REPORT_RPC_FAILED':
      return ReportGenerationFailedException();
  }
  if (e.code == '42501') return ReportAccessDeniedException();
  return ReportGenerationFailedException();
}

String _dateOnlyIso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
```

- Acceptance:
  - `flutter analyze` clean.
  - `flutter test test/.../daily_report_repository_test.dart` table tests for all 4 HINT/code mappings (`OWNER_NOT_FOUND`, `REPORT_DATE_INVALID`, `REPORT_RPC_FAILED`, default-to-`ReportGenerationFailedException`) pass.
  - Existing `DashboardRepository` callers compile (no signature changes on existing methods).
  - `getDailyReport` returns null cleanly when no row exists (does not throw).
- Rollback: Revert the two file diffs.
- Estimate: 50 min

### Task 3.3 — Create `DailyReportKey`, `dailyReportProvider`, and `dailyReportHistoryProvider`

- File(s): `lib/presentation/features/shops/dashboard/providers/daily_report_provider.dart` (NEW)
- Read first: RESEARCH §7.1 (lines 470–507 — composite-key family pattern), Phase 15 `pricingOverridesProvider` shape.
- Description: Custom `DailyReportKey` class with `==` and `hashCode` (Riverpod family keys must be equatable). Two providers:

```dart
import 'package:flutter/foundation.dart';

@immutable
class DailyReportKey {
  const DailyReportKey({required this.shopId, required this.reportDate});
  final String shopId;
  final DateTime reportDate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyReportKey &&
          shopId == other.shopId &&
          reportDate.year == other.reportDate.year &&
          reportDate.month == other.reportDate.month &&
          reportDate.day == other.reportDate.day);

  @override
  int get hashCode => Object.hash(shopId, reportDate.year, reportDate.month, reportDate.day);
}

final dailyReportProvider = FutureProvider.family
    .autoDispose<DailyReportDTO?, DailyReportKey>((ref, key) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getDailyReport(shopId: key.shopId, reportDate: key.reportDate);
});

final dailyReportHistoryProvider = FutureProvider.family
    .autoDispose<List<DailyReportSummaryDTO>, String>((ref, shopId) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.listDailyReports(shopId: shopId);
});
```

- Acceptance:
  - `flutter analyze` clean.
  - Unit test (in widget tests below): `DailyReportKey` equality holds across `DateTime` instances with identical y/m/d but different time components (the key strips time).
- Rollback: Delete the file.
- Estimate: 20 min

---

## Wave 4 — Owner UI (depends on Wave 3)

### Task 4.1 — Create `DailyReportScreen` (ConsumerWidget per RESEARCH §7.2)

- File(s): `lib/presentation/features/shops/dashboard/presentation/screens/daily_report_screen.dart` (NEW)
- Read first: SPEC §Outcome (sections to render), LD-6/LD-12/LD-13/LD-14, RESEARCH §7.2 (lines 510–516), Phase 15 [pricing_overrides_list_screen.dart:27] ConsumerWidget shape.
- Description: Read-only ConsumerWidget. Constructor takes `shopId: String, reportDate: DateTime`. Watches `dailyReportProvider(DailyReportKey(shopId, reportDate))`. Four `AsyncValue` states (loading/error/empty/data). Sections, top to bottom (each in a `Card` with section header):

1. **Headline** — Big revenue number (formatted from `revenueMinor` via `DailyReportDTO.formattedRevenue()`). Below: row of 4 chips (completed / no_show / cancelled / confirmed_past_end). Tap a chip → SnackBar with the count breakdown (no deep link in v1; see LD-12 "tomorrow is peek, not forecast" — same posture).
2. **Comparison** — Two rows: "vs yesterday" + "vs same day last week". Each row shows either `formattedDelta(deltaBps)` (e.g. "+13.6%" or "−14%") + signed icon, OR the em-dash "—" when the comparison is null (LD-14).
3. **Per-worker breakdown** — Compact list. Each row: avatar (initials) + name + `formattedRevenue(revenueMinor)` + count.
4. **Per-service breakdown** — Compact list. Each row: service name + `formattedRevenue(revenueMinor)` + count.
5. **Tomorrow's lineup** — Single row: "First booking at HH:mm · {count} bookings{ · Group flag}". Empty state: `loc.dailyReportTomorrowEmpty`.
6. **Follow-ups** — `ListView.separated` of follow-up cards. Each card shows the redacted client name (`A***`) + a localized reason badge (`loc.dailyReportFollowUpConfirmedPastEnd`, etc.). Tap card → deep-link via GoRouter to `/dashboard/{shopId}/bookings/{bookingId}` (the existing booking-detail route — verify path in `app_router.dart`).
7. **Re-generate FAB** — `FloatingActionButton.extended` with `Icons.refresh` + `loc.dailyReportRegenerate`. On tap: show confirm dialog (`loc.dailyReportRegenerateConfirmTitle` / `Body`), then call `repo.regenerateDailyReport(shopId, reportDate)`, then `ref.invalidate(dailyReportProvider(key))`. SnackBar with `loc.dailyReportRegenerated` on success; `e.userMessage` on `DailyReportException`.

Error state uses `ErrorState` widget (existing) with `e.userMessage`. Empty state (`null` DTO) shows `loc.dailyReportEmptyTitle` + `loc.dailyReportEmptyBody` + a Re-generate button calling the same path as the FAB.

- Acceptance:
  - `flutter analyze` clean.
  - Widget test (Wave 6) renders: loading state, error state with `userMessage`, empty state with Re-generate CTA, data state with all 6 sections.
  - Comparison row renders "—" when `comparisonYesterday` is null.
  - Follow-up card renders redacted name + reason badge; no full client name leaks.
  - Re-generate path invalidates provider + shows SnackBar.
- Rollback: Delete the file.
- Estimate: 75 min

### Task 4.2 — Create `DailyReportHistoryScreen` (ConsumerStatefulWidget for keyset cursor)

- File(s): `lib/presentation/features/shops/dashboard/presentation/screens/daily_report_history_screen.dart` (NEW)
- Read first: SPEC LD-9 (lines 244–250), RESEARCH §7.2 (lines 514–516 — paginated history is the case for ConsumerStatefulWidget).
- Description: ConsumerStatefulWidget. State: `List<DailyReportSummaryDTO> rows = []; DateTime? cursor; bool loading = false; bool hasMore = true;`. Initial load fetches first 30 via `repo.listDailyReports(shopId: shopId)`. ListView with `_HistoryRow` (date + revenue formatted). Pull-to-refresh resets state + reloads. Tap row → push `DailyReportScreen(shopId, reportDate: row.reportDate)`. Bottom-of-list inline loader: when user scrolls within ~200px of the bottom AND `hasMore`, dispatch `_loadMore` which calls `repo.listDailyReports(shopId, beforeDate: rows.last.reportDate)`. `hasMore` becomes false when the returned page has fewer than `pageSize` rows.

Empty state: `loc.dailyReportHistoryEmpty`. Error state: `ErrorState` with `e.userMessage`.

- Acceptance:
  - `flutter analyze` clean.
  - Widget test (Wave 6) renders: empty state when repo returns []; data state with 3 rows; pagination cursor passes the last row's report_date on _loadMore.
  - Tap row navigates via GoRouter to the day screen.
- Rollback: Delete the file.
- Estimate: 60 min

### Task 4.3 — Register routes in `app_router.dart`

- File(s): `lib/app/routing/app_router.dart` (EDIT)
- Read first: Existing `dashboard` route shape (the executor reads the file once to find the dashboard branch); SPEC LD-6 deep-link format (line 212).
- Description: Add two child routes under the dashboard branch:
  - `/dashboard/:shopId/daily-report/:reportDate` → `DailyReportScreen(shopId, reportDate: DateTime.parse(reportDate))`
  - `/dashboard/:shopId/daily-report/history` → `DailyReportHistoryScreen(shopId)`

Reuse whatever `RouteNames` pattern the existing dashboard branch uses. Add two new constants (e.g. `RouteNames.dailyReport`, `RouteNames.dailyReportHistory`) in the same file or in the constants file (find via grep).

- Acceptance:
  - `flutter analyze` clean.
  - GoRouter resolves `/dashboard/{shopId}/daily-report/2026-06-11` to `DailyReportScreen` with the parsed date.
  - GoRouter resolves the history route correctly.
- Rollback: Revert the file diff.
- Estimate: 25 min

### Task 4.4 — Add `case 'daily_report':` arm to `_handleNotificationNavigation` in `main.dart`

- File(s): `lib/main.dart` (EDIT — handler at lines 266–298 per RESEARCH §4.4)
- Read first: Existing handler shape at [main.dart:266-298]; SPEC LD-6 deep-link format.
- Description: Add a new case before the default:

```dart
case 'daily_report':
  final shopId = additionalData['shop_id'] as String?;
  final reportDate = additionalData['report_date'] as String?;
  if (shopId != null && reportDate != null) {
    router.push('/dashboard/$shopId/daily-report/$reportDate');
  } else {
    router.go(RouteNames.home);
  }
  break;
```

- Acceptance:
  - `flutter analyze` clean.
  - Unit test (in Wave 6 widget test file): synthesize a notification payload with `type='daily_report'`, `shop_id`, `report_date` → handler calls `router.push('/dashboard/.../daily-report/...')`.
  - Missing `shop_id` or `report_date` falls back to home (no crash).
- Rollback: Revert the file diff.
- Estimate: 20 min

---

## Wave 5 — i18n (parallel with Wave 3)

### Task 5.1 — Add ~30 EN keys to `lib/i10n/app_en.arb`

- File(s): `lib/i10n/app_en.arb` (EDIT)
- Read first: Phase 15 i18n table at [15-PLAN.md:1262-1306] for the format precedent. SPEC LD-6 (notification copy), LD-13 (follow-up reason labels).
- Description: Append the following EN keys. Run `flutter gen-l10n` after to regenerate `AppLocalizations` bindings.

| Key | Value (EN) |
|-----|------------|
| `dailyReportTitle` | "Today's report" |
| `dailyReportHistoryTitle` | "Past reports" |
| `dailyReportNotificationTitle` | "Today's report is ready" |
| `dailyReportNotificationBody` | "{currency} {revenue} · {count} bookings" |
| `dailyReportRevenueLabel` | "Revenue" |
| `dailyReportBookingsLabel` | "Bookings" |
| `dailyReportBookingsCompleted` | "Completed" |
| `dailyReportBookingsNoShow` | "No-show" |
| `dailyReportBookingsCancelled` | "Cancelled" |
| `dailyReportBookingsConfirmedPastEnd` | "Confirmed past end" |
| `dailyReportComparisonYesterday` | "vs yesterday" |
| `dailyReportComparisonLastWeek` | "vs same day last week" |
| `dailyReportComparisonNoData` | "—" |
| `dailyReportPerWorkerTitle` | "By staff" |
| `dailyReportPerServiceTitle` | "By service" |
| `dailyReportWorkerUnassigned` | "Unassigned" |
| `dailyReportTomorrowTitle` | "Tomorrow" |
| `dailyReportTomorrowFirstBookingAt` | "First booking at {time}" |
| `dailyReportTomorrowCount` | "{count} bookings" |
| `dailyReportTomorrowGroupFlag` | "Includes group bookings" |
| `dailyReportTomorrowEmpty` | "No bookings tomorrow." |
| `dailyReportFollowUpsTitle` | "Needs your attention" |
| `dailyReportFollowUpConfirmedPastEnd` | "Confirmed but never closed out" |
| `dailyReportFollowUpUnpaidBalance` | "Unpaid balance" |
| `dailyReportFollowUpNoShowNoAction` | "No-show — no note logged" |
| `dailyReportRegenerate` | "Re-generate" |
| `dailyReportRegenerateConfirmTitle` | "Re-generate this report?" |
| `dailyReportRegenerateConfirmBody` | "This rebuilds the report from the current data. The previous version is overwritten." |
| `dailyReportRegenerated` | "Report updated." |
| `dailyReportEmptyTitle` | "No report yet" |
| `dailyReportEmptyBody` | "No bookings recorded for this date. Tap Re-generate to build an empty report." |
| `dailyReportHistoryEmpty` | "No past reports yet." |
| `dailyReportErrorAccess` | "We couldn't find that report." |
| `dailyReportErrorDate` | "That date is out of range." |
| `dailyReportErrorGeneric` | "We couldn't build the report. Please try again." |

(Tally ~35 — overshoots planner brief's "~30" by a few; same overshoot pattern as Phase 14/15.)

- Acceptance:
  - `flutter gen-l10n` exits 0.
  - `flutter analyze` clean (no missing-key warnings from the daily-report screens).
  - All UI strings in the new screens + the notification body rendered from `metadata.title`/`metadata.body` route through `AppLocalizations.of(context)!` getters (verified via grep on the screen files: no string literals remain).
- Rollback: Revert the diff; `flutter gen-l10n` again.
- Estimate: 25 min

---

## Wave 6 — Tests + SQL smoke

### Task 6.1 — Write `daily_report_exceptions_test.dart`

- File(s): `test/presentation/features/shops/dashboard/data/exceptions/daily_report_exceptions_test.dart` (NEW)
- Read first: Phase 15 [pricing_override_exceptions_test.dart] for the pattern.
- Description: One test per subtype (4: `ReportAccessDeniedException`, `ReportDateInvalidException`, `ReportNotFoundException`, `ReportGenerationFailedException`) asserting `code` and `userMessage` are the locked strings. Round-trip `toString()` for one base case.
- Acceptance: `flutter test test/.../daily_report_exceptions_test.dart` exits 0; at least 4 cases.
- Estimate: 15 min

### Task 6.2 — Write `daily_report_repository_test.dart`

- File(s): `test/presentation/features/shops/dashboard/data/repositories/daily_report_repository_test.dart` (NEW)
- Read first: Phase 15 [pricing_overrides_repository_test.dart]; SPEC LD-11 HINT vocabulary.
- Description: Mock `SupabaseClient` via mocktail. Table tests for `_classifyReportError`: feed it a synthetic `PostgrestException` for each (`errcode`, `HINT`) pair and assert the resulting Dart subtype:
  - `(42501, 'OWNER_NOT_FOUND')` → `ReportAccessDeniedException`
  - `(22023, 'REPORT_DATE_INVALID')` → `ReportDateInvalidException`
  - `(*, 'REPORT_RPC_FAILED')` → `ReportGenerationFailedException`
  - `(42501, *)` → `ReportAccessDeniedException`
  - Any other → `ReportGenerationFailedException`

Plus happy-path tests: `getDailyReport` returns parsed DTO; `listDailyReports` returns parsed list; `regenerateDailyReport` returns UUID; `getDailyReport` returns null cleanly when `maybeSingle()` resolves to null.

- Acceptance: `flutter test test/.../daily_report_repository_test.dart` exits 0; at least 10 cases (5 classifier + 3 happy paths + 2 error-propagation).
- Estimate: 50 min

### Task 6.3 — Write `daily_report_screen_test.dart`

- File(s): `test/presentation/features/shops/dashboard/presentation/screens/daily_report_screen_test.dart` (NEW)
- Read first: Phase 15 [pricing_override_form_screen_test.dart] for the widget-test pattern with overridden Riverpod providers.
- Description: Widget tests for both `DailyReportScreen` and `DailyReportHistoryScreen`. Cases:
  - (a) Loading state shows `CircularProgressIndicator`.
  - (b) Error state shows `ErrorState` with the `DailyReportException.userMessage`.
  - (c) Data state renders all 6 sections of `DailyReportScreen` (headline, comparison, per-worker, per-service, tomorrow, follow-ups).
  - (d) Empty state (`dailyReportProvider` returns null) shows the empty CTA.
  - (e) Comparison row renders "—" when `comparisonYesterday` is null (LD-14).
  - (f) Follow-up card shows redacted client name (`A***`), not the full name.
  - (g) Tap Re-generate → confirm dialog → repo.regenerateDailyReport called → provider invalidated → SnackBar shown.
  - (h) Toast on `ReportGenerationFailedException` shows `loc.dailyReportErrorGeneric`.
  - (i) History screen: data state renders 30 rows; tap row navigates to day screen.
  - (j) History screen: pagination cursor passes the last row's report_date on `_loadMore`.
  - (k) Notification handler in `main.dart`: synthesize payload with `type='daily_report'` → handler calls `router.push('/dashboard/.../daily-report/...')`.
- Acceptance: `flutter test test/.../daily_report_screen_test.dart` exits 0; at least 10 cases.
- Estimate: 90 min

### Task 6.4 — Author `16_smoke_tests.sql`

- File(s): `.planning/phases/16-daily-closeout/sql/16_smoke_tests.sql` (NEW)
- Read first: Phase 15 [.planning/phases/15-time-based-pricing/sql/15_smoke_tests.sql] for the §A–§L pattern, SAVEPOINT/ROLLBACK wrapper, `SET LOCAL ROLE authenticated` + `SET LOCAL "request.jwt.claims"` setup, and `RAISE NOTICE 'OK: ...'` convention.
- Description: Hand-runnable SQL smoke covering SC-1 through SC-18. BEGIN/ROLLBACK wrapper with SAVEPOINTs per section. UUIDs inlined at the top. Sections:

  - **§A** — RLS owner-only verify on `daily_reports` (cross-shop SELECT denied) — SC-14
  - **§B** — `generate_daily_report` happy path: returns UUID, row in daily_reports, row in scheduled_notifications, row in daily_report_runs with outcome='created' — SC-2, SC-3, SC-11
  - **§C** — `generate_daily_report` idempotency: same `(shop_id, report_date)` twice → row UPDATEd not duplicated; second daily_report_runs row with outcome='updated' — SC-11, SC-12
  - **§D** — Authz failure: owner_b calling `generate_daily_report` for shop_a → HINT `OWNER_NOT_FOUND`, errcode 42501 — SC-14
  - **§E** — Date validation: future date → HINT `REPORT_DATE_INVALID`; > 365-day-old date → same — SC-15, SC-16
  - **§F** — Follow-ups: seed a no_show booking with no client_notes row → `payload->'follow_ups'` contains entry with `reason='no_show_no_action'` + redacted name `^[A-Z]\*\*\*$`. Insert a `client_notes` row with matching booking_id → re-run → follow-up no longer present (AMEND-2 round-trip) — SC-9, SC-10
  - **§G** — Revenue math: seed 3 bookings × 50 GHS → `payload->>'revenue_minor' = '15000'`; per-worker sum equals total; per-service sum equals total — SC-3, SC-6, SC-7
  - **§H** — Append-only audit: attempt `UPDATE public.daily_report_runs SET outcome='created'` as service_role → raises permission-denied — LD-5
  - **§I** — Cron registration: `SELECT 1 FROM cron.job WHERE jobname='dispatch-daily-reports'` returns 1 (when pg_cron enabled). EXPLAIN ANALYZE on `dispatch_daily_reports`'s shop_local CTE selector confirms `idx_bookings_shop_date_status` is used — AMEND-6
  - **§J** — Zero-booking skip: shop with 0 bookings today → `dispatch_daily_reports()` writes 1 daily_report_runs row with `shop_id=NULL, outcome='skipped_zero_bookings'`, no daily_reports row, no scheduled_notifications row — SC-13
  - **§K** — Duplicate cron tick: call `dispatch_daily_reports()` twice in same minute → exactly 1 daily_reports row, exactly 1 scheduled_notifications row for that shop — SC-12
  - **§L** — IST shop dispatch timing: configure a test shop with `timezone='Asia/Kolkata'`, set test clock to 17:00 UTC (= 22:30 IST), verify the shop appears in `dispatch_daily_reports`'s selector — SC-18
  - **§M** — `list_daily_reports`: happy path returns oldest-first DESC by report_date; page_size=5 → clamped to 10; page_size=100 → clamped to 50; keyset cursor `p_before_date` returns earlier rows — SC-17
  - **§N** — Comparison NULL semantics: today has bookings but yesterday had 0 → `payload->'comparison'->>'yesterday' = null` (LD-14) — SC-4
  - **§O** — Tomorrow peek: tomorrow has 2 bookings, first at 09:00 → `payload->'tomorrow'->>'first_booking_at'` ISO matches; count=2 — SC-8

  Each section ends with `RAISE NOTICE 'OK: <case>';` on success and an inline `RAISE EXCEPTION 'FAIL §X.Y: ...'` on assertion failure. Pre-flight queries pasted at the top.

- Acceptance: `psql -f .planning/phases/16-daily-closeout/sql/16_smoke_tests.sql` against a staging branch prints exactly 15 `OK:` lines (one per §A–§O) and `ROLLBACK` at the end. Zero `FAIL:` lines.
- Estimate: 90 min

---

## Wave 7 — Manual UAT (BATCHED at end of phases per user instruction; not buildable in this PR)

Manual end-to-end on staging. Detailed script saved here for when the user runs the batched UAT pass. Not part of the PR merge gate.

1. Sign in as owner of a shop in `Africa/Accra` with ≥5 completed bookings on 2026-06-11.
2. Wait for 22:30 local. Push notification arrives within 7.5 min (window).
3. Tap notification → `DailyReportScreen` opens for today's date.
4. Verify revenue = sum of `bs.price_at_booking * 100` for today's bookings (kobo).
5. Verify per-worker breakdown sums to total.
6. Verify per-service breakdown sums to total.
7. Verify comparison.yesterday renders correctly (or "—" when yesterday had 0 bookings).
8. Verify tomorrow's first booking time matches actual data.
9. Verify follow-ups: a `confirmed`-past-`end_time` booking appears with `reason='confirmed_past_end'`.
10. Tap Re-generate → confirm → SnackBar success → numbers unchanged (idempotent).
11. Open History → scroll → tap an older day → that day's snapshot loads (not a recomputation).
12. Verify a zero-booking-today shop: no push fires; daily_report_runs has the heartbeat row.
13. Configure a test shop with `timezone='Asia/Kolkata'` → verify dispatch fires at 17:00 UTC.

---

## Verification matrix

Maps SC-1..SC-18 to test type → command/location → Status.

| SC | SPEC text | Test type | Command / location | Status |
|----|-----------|-----------|--------------------|--------|
| SC-1 | Africa/Accra shop with 5 bookings receives push at 22:30 ± 1 min local. | Manual UAT | UAT step 2 + Smoke §I (cron registered) + §K (selector picks shop in window) | Wave 1 Task 1.6, Wave 2 Task 2.2, Wave 6 Task 6.4 §I/§K, Wave 7 |
| SC-2 | Tapping push opens `DailyReportScreen` reflecting 5 completed. | Widget test + UAT | `daily_report_screen_test.dart` cases (c,k) + Smoke §B + UAT step 3 | Wave 6 Tasks 6.3, 6.4 §B, Wave 7 |
| SC-3 | Revenue = SUM(price_at_booking) in kobo. | SQL smoke | Smoke §B + §G | Wave 6 Task 6.4 §B/§G |
| SC-4 | comparison.yesterday null when yesterday had 0 bookings. | SQL smoke + Widget | Smoke §N + `daily_report_screen_test.dart` (e) | Wave 6 Tasks 6.3, 6.4 §N |
| SC-5 | comparison.same_day_last_week same NULL semantics. | SQL smoke | Smoke §N (variant) | Wave 6 Task 6.4 §N |
| SC-6 | Per-worker breakdown sums to total. | SQL smoke | Smoke §G | Wave 6 Task 6.4 §G |
| SC-7 | Per-service breakdown sums to total. | SQL smoke | Smoke §G | Wave 6 Task 6.4 §G |
| SC-8 | Tomorrow shows first booking time + count. | SQL smoke + Widget | Smoke §O + `daily_report_screen_test.dart` (c) | Wave 6 Tasks 6.3, 6.4 §O |
| SC-9 | Confirmed-past-end booking appears with reason='confirmed_past_end'. | SQL smoke | Smoke §F | Wave 6 Task 6.4 §F |
| SC-10 | no_show booking with no client_notes booking_id linkage appears with reason='no_show_no_action'. | SQL smoke | Smoke §F (AMEND-2 round-trip) | Wave 6 Task 6.4 §F |
| SC-11 | Manual Re-generate overwrites snapshot; new daily_report_runs row with triggered_by='manual'. | SQL smoke + Widget | Smoke §B + §C + `daily_report_screen_test.dart` (g) | Wave 6 Tasks 6.3, 6.4 §B/§C |
| SC-12 | Duplicate cron tick is no-op. | SQL smoke | Smoke §C + §K | Wave 6 Task 6.4 §C/§K |
| SC-13 | Zero-booking shop not dispatched; no push fires. | SQL smoke | Smoke §J | Wave 6 Task 6.4 §J |
| SC-14 | Cross-owner call raises `ReportAccessDenied` (HINT OWNER_NOT_FOUND). | SQL smoke + repo test | Smoke §A + §D + `daily_report_repository_test.dart` classifier | Wave 6 Tasks 6.2, 6.4 §A/§D |
| SC-15 | Future date raises REPORT_DATE_INVALID. | SQL smoke | Smoke §E | Wave 6 Task 6.4 §E |
| SC-16 | > 365-day-old date raises REPORT_DATE_INVALID. | SQL smoke | Smoke §E (variant) | Wave 6 Task 6.4 §E |
| SC-17 | list_daily_reports paginated, page_size clamped [10, 50]. | SQL smoke + repo test | Smoke §M + `daily_report_repository_test.dart` happy path | Wave 6 Tasks 6.2, 6.4 §M |
| SC-18 | Asia/Kolkata shop dispatches at 17:00 UTC. | SQL smoke + Manual UAT | Smoke §L + UAT step 13 | Wave 6 Task 6.4 §L, Wave 7 |
| LD-5 audit | UPDATE/DELETE on daily_report_runs raises permission-denied. | SQL smoke | Smoke §H | Wave 6 Task 6.4 §H |
| LD-13 PII | Follow-up client_name_redacted matches `^[A-Z]\*\*\*$`. | SQL smoke + Widget | Smoke §F + `daily_report_screen_test.dart` (f) | Wave 6 Tasks 6.3, 6.4 §F |
| HINT contract | All HINT codes map to typed Dart exceptions. | Repo test | `daily_report_repository_test.dart` classifier table | Wave 6 Task 6.2 |

---

## Algorithm Quality Checklist coverage

RESEARCH §8 maps every LD to specific tasks. Honored here. Priority key:
**P0-U** = blocker, **P1** = merge gate, **P2** = production gate, **skip** = documented per LD-15.

| Checklist item | Priority | Task hook |
|----------------|----------|-----------|
| 1.1 idempotency (compound UNIQUE + ON CONFLICT) | P1 | Wave 1 Task 1.2 (UNIQUE constraint), Wave 2 Task 2.1 (ON CONFLICT DO UPDATE), Wave 6 Task 6.4 §C |
| 1.4 authz at every access | P0-U | Wave 2 Tasks 2.1, 2.2, 2.3 (authz FIRST); Wave 6 Task 6.4 §A/§D |
| 1.5 auth verified | P0-U | Wave 2 Task 2.1 + 2.3 (`shops.user_id = auth.uid()`); Wave 6 Task 6.4 §A |
| 1.7 stateless RPCs | P2 | Wave 2 Tasks 2.1–2.3 (no shared state between calls) |
| 1.8 Big-O documented | P2 | Wave 2 Tasks 2.1, 2.3 COMMENT blocks |
| 1.9 consistency model | P1 | Wave 1 Task 1.2 COMMENT (snapshot semantics: late-edits do not re-price) |
| 1.10 compensating cleanup | P1 | Wave 2 Task 2.1 EXCEPTION block (writes failed row to audit on error) |
| 1.11 PII/data assessment | P1 | Wave 1 Task 1.1 (timezone is config metadata, not PII) |
| 2.1 input sanitization on date + page_size | P0-U | Wave 2 Task 2.1 (REPORT_DATE_INVALID), Task 2.3 (clamp [10,50]) |
| 2.2 no string-concat SQL | P0-U | All RPCs use parameterized inputs only |
| 2.4 sanitized errors via HINT codes | P0-U | Wave 2 Tasks 2.1, 2.3; Wave 3 Task 3.2 classifier; Wave 6 Task 6.2 |
| 2.5 page_size + history range limits | P0-U | Wave 2 Task 2.3 clamp + Task 2.1 365-day date limit |
| 2.10 transactional cleanup | P0-U | Wave 2 Task 2.1 EXCEPTION block + audit row |
| 2.13 cron RPC timeout (10s + 30s budgets) | P1 | Wave 2 Task 2.1 (`statement_timeout = '10s'`), Task 2.2 (`'30s'`) |
| 2.16 concurrent re-gen protected by ON CONFLICT | P1 | Wave 2 Task 2.1 (UNIQUE + ON CONFLICT DO UPDATE) |
| 2.18 idempotent RPCs | P1 | Wave 2 Task 2.1 (ON CONFLICT DO UPDATE); Wave 6 Task 6.4 §C |
| 2.19 minor units throughout (no float on server) | P0-U | Wave 2 Task 2.1 (bigint kobo end-to-end); Wave 6 Task 6.4 §G |
| 2.22 audit append-only | P1 | Wave 1 Task 1.3 (REVOKE UPDATE/DELETE); Wave 6 Task 6.4 §H |
| 3.1 pagination | P2 | Wave 2 Task 2.3 keyset; Wave 4 Task 4.2 history screen |
| 3.3 indexes (EXPLAIN attached to PR) | P2 | Wave 1 Task 1.2 (UNIQUE constraint = index); Wave 6 Task 6.4 §I EXPLAIN ANALYZE |
| 3.10 don't retry on auth fail | P1 | Wave 3 Task 3.2 classifier — `ReportAccessDeniedException` is non-retryable signal |
| 3.12 graceful shutdown / cron mid-flight | P1 | Wave 2 Task 2.2 (per-shop failures caught; loop continues); Wave 6 Task 6.4 §K |
| 4.1 structured logs | P2 | Wave 2 Task 2.2 `RAISE NOTICE 'daily_report.dispatch_completed shop_count=% error_count=% duration_ms=%'` |
| 4.4 PII redaction in follow_ups (client_name "A***") | P0-U | Wave 2 Task 2.1 redaction code; Wave 6 Tasks 6.3 (f), 6.4 §F |
| 4.6 RED metrics on cron | P2 | Wave 2 Task 2.2 structured log line |
| 4.11 configurable thresholds | P2 | Per-shop `timezone` is configurable (Wave 1 Task 1.1); 22:30 is locked per SPEC (Out of scope: scheduling preferences) |
| 5.1 actionable errors | P2 | Wave 3 Task 3.1 exception `userMessage` strings; Wave 5 i18n keys |
| 5.2 ≤200ms first paint on report screen | P2 | Wave 4 Task 4.1 (data is a single DTO fetch; one provider read) — verified at UAT |
| 5.5 no internal IDs in UI errors | P0-U | Wave 3 Task 3.2 classifier emits typed exceptions only; raw HINT codes never reach the UI |
| 6.1 edge cases (DST, zero-comparison, exactly-22:30) | P1 | Wave 6 Task 6.4 §J (zero), §K (duplicate tick), §L (IST 22:30) |
| 6.2 failure scenarios (push fail → row persists) | P2 | Wave 2 Task 2.1 commits daily_reports BEFORE the scheduled_notifications INSERT; FCM/APNS failure does not roll back the row |
| 6.3 race tests | P1 | Wave 6 Task 6.4 §K (duplicate cron tick) |
| 6.7 ≥90% branch coverage on report-builder | P2 | Wave 6 Task 6.4 §B/§F/§G/§N/§O cover happy/empty/follow-up/null-comparison/tomorrow-empty branches |
| 6.10 24h soak | **skip (LD-15)** | Out-of-band section below. Re-evaluate at >1000 shops. |
| 6.11 2x load test | **skip (LD-15)** | Out-of-band section below. Re-evaluate at >1000 shops. |
| 6.13 documentation | P2 | All migration COMMENT blocks; PR description |

---

## Out-of-band items (LD-15 documented skips)

Per SPEC LD-15 (lines 319–331), verbatim justification copied here:

> At current platform scale (< 100 shops), the 22:30 cron processes at most ~50 shops in a single fan-out and ~5 manual re-generations per day. The cron's load profile is bounded by the number of shops, not by user traffic. A 24h soak and 2x-peak load test are not proportionate to the actual production workload. Re-evaluate if shop count exceeds 1000 OR cron processing time exceeds 30s.

- **6.10 — 24h soak** — SKIPPED.
- **6.11 — 2x peak load test** — SKIPPED.

The PR rollout checklist (below) includes a "re-evaluate skip at >1000 shops" reminder.

---

## Risk register (delta from SPEC)

| Risk | Likelihood | Mitigation in this plan |
|------|-----------|-------------------------|
| `pg_cron` not enabled on prod → dispatcher never fires | M | AMEND-7 pre-flight DO block in Wave 1 Task 1.0 reports presence; Wave 1 Task 1.6 gracefully skips registration when absent and emits a NOTICE. User must enable via Supabase Dashboard before merge. Verified in PR rollout checklist. |
| `shops.archived_at` column does not exist → dispatcher selector errors | M | AMEND-7 pre-flight reports column presence; Wave 2 Task 2.2 executor edits the selector predicate based on the finding before applying. |
| Push notification body shows wrong currency formatting | L | Wave 2 Task 2.1 builds the body in EN with `format('%s %s · %s bookings', currency, formatted, count)`. The edge function reads `metadata.title` / `metadata.body` directly (RESEARCH §4.5 path b). For non-Africa/Accra shops in v2, edge function will localize using metadata components. |
| Float vs bigint precision on revenue_minor at delivery | L | RESEARCH §5.5: float64 53-bit safe int is 9e15 kobo (~90 trillion GHS). Platform far from this. Migration COMMENT documents the threshold. |
| `notification_type` CHECK constraint blocks 'daily_report' INSERT | M | Wave 1 Task 1.5 branches on pre-flight finding and either extends the existing CHECK or adds a defensive CHECK. Executor reads existing definition and updates the IN-list before running. |
| Phase 12 retention RPC compatibility with `client_notes.booking_id` addition | L | AMEND-2 column is NULLABLE with default NULL. Phase 12 RPCs perform UPSERT on `(shop_id, client_identity)` — they don't touch `booking_id`, which stays NULL on their writes. Forward-compatible. |
| DST transition in `Europe/London` shifts UTC firing time | L | RESEARCH §3.3 confirms 22:30 local is never inside a DST transition window. Documented in Wave 1 Task 1.1 COMMENT. No test required. |
| Cross-tz shops not supported | L | SPEC Out of scope ("Multi-tz shops: not supported"). Documented in Wave 1 Task 1.1 COMMENT. |

---

## PR rollout / verification checklist

Run before merging the PR:

- [ ] Wave 1 Task 1.0 pre-flight NOTICE captured in PR description; `pg_cron` = true, `pg_net` = true.
- [ ] If `pg_cron` was false at pre-flight: enabled via Supabase Dashboard → Database → Extensions; Task 1.6 re-run; `SELECT 1 FROM cron.job WHERE jobname='dispatch-daily-reports'` returns 1.
- [ ] Wave 2 Task 2.2 executor reconciled `shops.archived_at` predicate against the Task 1.0 finding before applying.
- [ ] Wave 1 Task 1.5 executor reconciled the `notification_type` IN-list against the existing CHECK constraint definition.
- [ ] All 10 Wave 1 + Wave 2 migration files applied in strict timestamp order on staging; `psql` exit 0 for each.
- [ ] `flutter analyze` clean.
- [ ] `flutter test test/.../daily_report_*.dart test/.../daily_report_screen_test.dart` exits 0.
- [ ] `psql -f .planning/phases/16-daily-closeout/sql/16_smoke_tests.sql` prints 15 `OK:` lines + `ROLLBACK`; zero `FAIL:`.
- [ ] EXPLAIN ANALYZE on `dispatch_daily_reports`'s shop_local CTE selector uses `idx_bookings_shop_date_status`; total exec < 50ms on staging.
- [ ] Manual smoke: trigger `dispatch_daily_reports()` from psql in staging; verify one shop in the dispatch window gets a row in daily_reports + scheduled_notifications + daily_report_runs.
- [ ] Notification deep-link tested: tap a `daily_report` push on a staging device; `DailyReportScreen` opens with correct shopId + reportDate.
- [ ] Manual re-generate flow on staging: tap Re-generate → confirm → verify daily_report_runs row added with `triggered_by='manual'`.
- [ ] LD-15 reminder: re-evaluate 6.10/6.11 skip when shop_count > 1000 OR cron exec > 30s.
- [ ] Rollback rehearsed: `SELECT cron.unschedule('dispatch-daily-reports');` removes the cron job cleanly.

---

## Phase boundary

Phase 16 ships:
- Server: 10 migrations (1 pre-flight, 1 timezone column, 1 daily_reports table + RLS, 1 daily_report_runs table + RLS + REVOKE UPDATE/DELETE, 1 client_notes.booking_id column, 1 notification_type extension, 3 RPCs, 1 cron registration).
- Client: 2 new screens (`DailyReportScreen`, `DailyReportHistoryScreen`), 2 DTOs + 1 enum + sub-types, 1 exception hierarchy (4 subtypes), 3 new repo methods + 1 classifier, 1 `DailyReportKey` class, 2 providers, 2 GoRouter routes, `case 'daily_report':` arm in main.dart.
- i18n: ~35 EN keys in `app_en.arb`.
- Tests: 3 new test files (exceptions, repo, screen) + 1 SQL smoke file (15 sections §A–§O).

Phase 16 does NOT ship:
- Owner timezone editor.
- CSV / PDF export.
- Weekly / monthly rollups.
- Per-section toggles.
- Notification scheduling preferences.
- Multi-tz shops.
- Forecast / predictive analytics.
- 24h soak or 2x load test (LD-15 documented skip).
- Translations beyond EN.

## Plan Revisions (post plan-check)

### REV-1 — Task 2.1 EXCEPTION block (2026-06-11)

Plan-check flagged two blockers in `generate_daily_report`'s catch-all
EXCEPTION block:

1. The outer `WHEN OTHERS` was collapsing every error — including
   `OWNER_NOT_FOUND` and `REPORT_DATE_INVALID` — into `REPORT_RPC_FAILED`,
   silently breaking SC-14, SC-15, SC-16.
2. `error_code` was being populated from `SQLERRM` (free-text), violating
   the LD-5 contract that the column carries stable HINT codes only.

**Fix applied** (see Task 2.1 RPC body in this PLAN):

- Use `GET STACKED DIAGNOSTICS PG_EXCEPTION_HINT, RETURNED_SQLSTATE` to
  capture the diagnostic HINT and SQLSTATE from the original throw site.
- Map known HINTs (`OWNER_NOT_FOUND`, `REPORT_DATE_INVALID`,
  `SHOP_NOT_FOUND`) through unchanged. Anything else collapses to
  `REPORT_RPC_FAILED`.
- Write the mapped code (never `SQLERRM`) into `daily_report_runs.error_code`.
- Re-raise with the preserved code as the HINT so the Dart classifier
  (Task 3.3) routes to the correct typed exception subtype.

Wave 6 SQL smoke §C must include a test that calls
`generate_daily_report` with a wrong-owner caller and asserts the
re-raised HINT is `OWNER_NOT_FOUND`, not `REPORT_RPC_FAILED`.

## PLANNING COMPLETE
Total tasks: 19 (REV-1 applied 2026-06-11)
