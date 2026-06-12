-- Phase 11 hardening — corrective for audit finding F-P1-1.
--
-- Issue (checklist 2.4 / P0-U):
--   `rebuild_shop_opening_hours` raised distinct HINTs for two paths:
--     - `SHOP_NOT_FOUND`  when the row was absent
--     - `NOT_SHOP_OWNER`  when the row existed but the caller did not own it
--   A probing caller could enumerate which shop UUIDs exist by branching
--   on the HINT. Other Phase 11 RPCs collapse both to a single sanitized
--   raise; mirror that pattern.
--
-- Fix:
--   Single raise. HINT `NOT_SHOP_OWNER` (kept as the canonical name for
--   the Dart side — the existing classifier branches on errcode 42501
--   regardless of HINT, so no client change is needed). Body otherwise
--   identical to the prior definition; rest of validation + parse is
--   unchanged.

CREATE OR REPLACE FUNCTION public.rebuild_shop_opening_hours(
  p_shop_id UUID,
  p_hours   JSONB
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $function$
DECLARE
  v_owner UUID;
  v_count INT;
BEGIN
  -- Authz: caller must own the shop. F-P1-1: single sanitized raise so
  -- absence and unauthorized are indistinguishable to the caller.
  SELECT user_id INTO v_owner FROM public.shops WHERE id = p_shop_id;
  IF v_owner IS NULL OR v_owner <> auth.uid() THEN
    RAISE EXCEPTION 'not_found'
      USING ERRCODE = '42501', HINT = 'NOT_SHOP_OWNER';
  END IF;

  -- Shape: must be a JSON array.
  IF p_hours IS NULL OR jsonb_typeof(p_hours) <> 'array' THEN
    RAISE EXCEPTION 'invalid_payload'
      USING ERRCODE = '22023', HINT = 'PAYLOAD_NOT_ARRAY';
  END IF;

  -- Shape: exactly 7 rows.
  SELECT jsonb_array_length(p_hours) INTO v_count;
  IF v_count <> 7 THEN
    RAISE EXCEPTION 'invalid_payload'
      USING ERRCODE = '22023', HINT = 'EXACTLY_7_DAYS_REQUIRED';
  END IF;

  -- Shape: every day_of_week must be in [0, 7].
  IF EXISTS (
    SELECT 1
    FROM jsonb_array_elements(p_hours) AS elem
    WHERE (elem->>'day_of_week')::INT NOT BETWEEN 0 AND 7
  ) THEN
    RAISE EXCEPTION 'invalid_payload'
      USING ERRCODE = '22023', HINT = 'DAY_OF_WEEK_OUT_OF_RANGE';
  END IF;

  DELETE FROM public.shop_opening_hours WHERE shop_id = p_shop_id;

  INSERT INTO public.shop_opening_hours (
    shop_id, day_of_week, opens_at, closes_at, is_closed
  )
  SELECT
    p_shop_id,
    (elem->>'day_of_week')::INT,
    CASE
      WHEN COALESCE((elem->>'is_closed')::BOOLEAN, false) THEN '00:00'::time
      WHEN elem->>'opens_at' ~* '\s(AM|PM)\s*$'
        THEN to_timestamp(elem->>'opens_at', 'HH12:MI AM')::time
      ELSE to_timestamp(elem->>'opens_at', 'HH24:MI')::time
    END,
    CASE
      WHEN COALESCE((elem->>'is_closed')::BOOLEAN, false) THEN '00:00'::time
      WHEN elem->>'closes_at' ~* '\s(AM|PM)\s*$'
        THEN to_timestamp(elem->>'closes_at', 'HH12:MI AM')::time
      ELSE to_timestamp(elem->>'closes_at', 'HH24:MI')::time
    END,
    COALESCE((elem->>'is_closed')::BOOLEAN, false)
  FROM jsonb_array_elements(p_hours) AS elem;
END;
$function$;

REVOKE ALL ON FUNCTION public.rebuild_shop_opening_hours(UUID, JSONB) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.rebuild_shop_opening_hours(UUID, JSONB) TO authenticated;

COMMENT ON FUNCTION public.rebuild_shop_opening_hours(UUID, JSONB) IS
  'Atomic rebuild of a shop weekly opening hours. DELETE + INSERT in one tx — DO NOT split. SECURITY DEFINER with shops.user_id=auth.uid() gate. F-P1-1: absence and unauthorized collapse to one sanitized HINT (NOT_SHOP_OWNER); existence is not leaked. Accepts day_of_week BETWEEN 0 AND 7 to tolerate legacy 0-indexed rows. opens_at/closes_at parsed from 12h ("09:00 AM") or 24h ("09:00") strings into PG time. Closed days store 00:00 placeholders (column is NOT NULL; consumers check is_closed first). O(1) — bounded at 7 rows per call.';
