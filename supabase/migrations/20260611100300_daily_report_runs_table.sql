-- Phase 16 Wave 1 Task 1.3 — Create daily_report_runs audit table (LD-5).
--
-- Append-only audit of every daily-report generation attempt (cron + manual).
-- shop_id nullable so the dispatcher can log "ran the tick, zero shops
-- matched" heartbeat rows. error_code is a stable HINT code — never
-- free-text (REV-1 fix in Task 2.1).
--
-- Checklist 2.22 (P1 [FIN][MUTATION]): UPDATE and DELETE revoked from
-- ALL roles including service_role at the schema level — append-only is
-- a database-level invariant, not a code convention.

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
  'Phase 16: append-only audit of every daily-report generation attempt (cron + manual). UPDATE and DELETE are revoked from ALL roles at the schema level — checklist 2.22 (P1 [FIN][MUTATION]). shop_id is nullable so the dispatcher can log "ran the tick, zero shops matched" rows. error_code is a stable HINT code (REPORT_RPC_FAILED, OWNER_NOT_FOUND, REPORT_DATE_INVALID) — never free-text. SELECT visible only to the parent shop owner; service_role sees all (including NULL-shop dispatcher heartbeats).';
