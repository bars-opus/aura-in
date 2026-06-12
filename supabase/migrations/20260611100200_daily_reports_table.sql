-- Phase 16 Wave 1 Task 1.2 — Create daily_reports table + RLS (LD-4, LD-10, AMEND-5).
--
-- Persisted JSONB snapshot. One row per (shop_id, report_date). UNIQUE
-- constraint provides idempotency for INSERT ... ON CONFLICT DO UPDATE
-- in generate_daily_report. Snapshot semantics: late edits to bookings
-- do NOT re-price historical reports.
--
-- RLS-enabled. SELECT policy: owner of parent shop only. NO insert /
-- update / delete policies — absence = deny-all for authenticated. All
-- mutations route through SECURITY DEFINER generate_daily_report RPC
-- in Wave 2 (Phase 14 pattern).

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

-- The UNIQUE constraint above creates a b-tree on (shop_id, report_date).
-- That index serves both: (a) single-row lookup by composite key, and
-- (b) list_daily_reports keyset on (shop_id, report_date DESC).

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

-- Deliberately NO INSERT / UPDATE / DELETE policies.
-- RLS-enabled + policy-absence = deny-all for authenticated.

COMMENT ON TABLE public.daily_reports IS
  'Phase 16: persisted JSONB snapshot of one shop''s metrics for one calendar date in the shop''s local timezone. UNIQUE (shop_id, report_date) → idempotency. Snapshot semantics: LATE EDITS to bookings (status flips, refunds, restorations) do NOT re-price historical reports — owners reading a 2-week-old report see the numbers as they were on that date. Manual re-generation via generate_daily_report REPLACES the snapshot. schema_version 1.';

COMMENT ON COLUMN public.daily_reports.payload IS
  'JSONB blob shape: { revenue_minor (bigint), currency (text), bookings: {completed, no_show, cancelled, confirmed_past_end}, comparison: {yesterday, same_day_last_week}, per_worker[], per_service[], tomorrow: {first_booking_at, count, has_group_bookings}, follow_ups[], generated_at, schema_version }. Money fields are bigint kobo (minor units). Comparison rows are null when comparison date had zero bookings (LD-14). Client names in follow_ups are redacted (LD-13 / checklist 4.4).';
