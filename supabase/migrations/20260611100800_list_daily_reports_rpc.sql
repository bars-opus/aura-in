-- Phase 16 Wave 2 Task 2.3 — Create list_daily_reports keyset-paginated read.
--
-- Path A per RESEARCH §6.2 — introduce the first list_X RPC pattern so
-- page_size clamp + authz + sort-direction policy live in one server-side
-- guarantee. Owner authz via shops.user_id = auth.uid() (AMEND-3).
-- page_size clamped to [10, 50] with default 30 (LD-9).
-- Sort: report_date DESC. Cursor: p_before_date (NULL = first page).

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
