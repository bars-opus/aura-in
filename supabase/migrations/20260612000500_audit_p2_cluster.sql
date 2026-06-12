-- Audit hardening — P2 cluster (F-P2-9, F-P2-11).
--
-- F-P2-9: broadcasts table relied on RLS-policy absence to deny mutations
-- from authenticated, but service_role retained full UPDATE/DELETE rights
-- — a misconfigured edge function could rewrite history. Mirror the
-- daily_report_runs pattern: schema-level REVOKE on all roles including
-- service_role.

REVOKE UPDATE, DELETE ON public.broadcasts FROM PUBLIC;
REVOKE UPDATE, DELETE ON public.broadcasts FROM authenticated;
REVOKE UPDATE, DELETE ON public.broadcasts FROM service_role;
REVOKE UPDATE, DELETE ON public.broadcasts FROM anon;

COMMENT ON TABLE public.broadcasts IS
  'Phase 14: append-only broadcast send log. UPDATE and DELETE revoked at the schema level from all roles including service_role (F-P2-9 hardening). All mutations route through send_broadcast (SECURITY DEFINER). Per-shop SELECT via owner RLS.';

-- F-P2-11: list_daily_reports raised REPORT_DATE_INVALID for a NULL
-- p_shop_id, which mis-routes in the Dart classifier to
-- ReportDateInvalidException ("That date is out of range") — wrong copy.
-- Add a distinct HINT path for the null-shop case.

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
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
DECLARE
  v_clamped_size INT;
BEGIN
  -- F-P2-11: distinct HINT for null-shopId vs. invalid-date so the Dart
  -- classifier can branch correctly.
  IF p_shop_id IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'REQUIRED_FIELD_MISSING';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.shops sh
    WHERE sh.id = p_shop_id AND sh.user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501', HINT = 'OWNER_NOT_FOUND';
  END IF;

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

COMMENT ON FUNCTION public.list_daily_reports(UUID, DATE, INT) IS
  'Phase 16: keyset-paginated read. Authz via shops.user_id = auth.uid() (LD-10 / AMEND-3). page_size clamped to [10, 50] with default 30 (LD-9). Returns rows in report_date DESC order. F-P2-11: null shop_id raises REQUIRED_FIELD_MISSING (distinct from REPORT_DATE_INVALID). STABLE; SECURITY DEFINER. HINT codes: OWNER_NOT_FOUND, REPORT_DATE_INVALID, REQUIRED_FIELD_MISSING.';
