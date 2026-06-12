-- Phase 15: update_pricing_override RPC.
-- Partial update. NULL params leave fields unchanged. Cross-field checks
-- (window order, percent range, validity order) run against MERGED post-update
-- values so the owner can change one half of a pair without the other being
-- treated as the new baseline.
--
-- v1 LIMITATION: day_of_week and valid_until cannot be CLEARED via this RPC
-- — NULL is the "unchanged" sentinel. Owner workaround: archive + recreate.
-- v2 will add explicit clear sentinels.

CREATE OR REPLACE FUNCTION public.update_pricing_override(
  p_override_id        UUID,
  p_name               TEXT DEFAULT NULL,
  p_day_of_week        INT  DEFAULT NULL,
  p_time_window_start  TIME DEFAULT NULL,
  p_time_window_end    TIME DEFAULT NULL,
  p_adjustment_kind    TEXT DEFAULT NULL,
  p_adjustment_value   NUMERIC DEFAULT NULL,
  p_valid_from         TIMESTAMPTZ DEFAULT NULL,
  p_valid_until        TIMESTAMPTZ DEFAULT NULL,
  p_is_active          BOOLEAN DEFAULT NULL
) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
DECLARE
  v_existing  RECORD;
  v_new_start TIME;
  v_new_end   TIME;
  v_new_kind  TEXT;
  v_new_value NUMERIC;
  v_new_from  TIMESTAMPTZ;
  v_new_until TIMESTAMPTZ;
BEGIN
  IF p_override_id IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'NULL_NOT_ALLOWED';
  END IF;

  -- Authz via slot → shop. Also pulls existing field values for merge.
  SELECT po.* INTO v_existing
  FROM public.pricing_overrides po
  JOIN public.appointment_slots s ON s.id = po.slot_id
  JOIN public.shops sh ON sh.id = s.shop_id
  WHERE po.id = p_override_id
    AND sh.user_id = auth.uid()
    AND po.archived_at IS NULL;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  -- Compute the post-update merged values for cross-field checks.
  v_new_start := COALESCE(p_time_window_start, v_existing.time_window_start);
  v_new_end   := COALESCE(p_time_window_end,   v_existing.time_window_end);
  v_new_kind  := COALESCE(p_adjustment_kind,   v_existing.adjustment_kind);
  v_new_value := COALESCE(p_adjustment_value,  v_existing.adjustment_value);
  v_new_from  := COALESCE(p_valid_from,        v_existing.valid_from);
  v_new_until := COALESCE(p_valid_until,       v_existing.valid_until);

  -- Same field validation as create — run against merged values.
  IF p_name IS NOT NULL AND (char_length(p_name) NOT BETWEEN 1 AND 80) THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'NAME_LENGTH_INVALID';
  END IF;
  IF p_day_of_week IS NOT NULL AND (p_day_of_week NOT BETWEEN 1 AND 7) THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'DAY_OF_WEEK_OUT_OF_RANGE';
  END IF;
  IF v_new_end <= v_new_start THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'WINDOW_NOT_ORDERED';
  END IF;
  IF v_new_kind NOT IN
     ('percent_discount','percent_surcharge','fixed_discount','fixed_surcharge') THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'ADJUSTMENT_KIND_INVALID';
  END IF;
  IF v_new_value <= 0 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'ADJUSTMENT_VALUE_INVALID';
  END IF;
  IF v_new_kind IN ('percent_discount','percent_surcharge') AND v_new_value > 100 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'PERCENT_OUT_OF_RANGE';
  END IF;
  IF v_new_until IS NOT NULL AND v_new_until <= v_new_from THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'VALIDITY_NOT_ORDERED';
  END IF;

  -- Apply. COALESCE leaves unchanged fields untouched.
  -- NOTE: day_of_week and valid_until cannot be CLEARED via this RPC — passing
  -- NULL is the "unchanged" sentinel. v1 owner workaround: archive + recreate.
  UPDATE public.pricing_overrides SET
    name              = COALESCE(p_name,               name),
    day_of_week       = CASE WHEN p_day_of_week IS NULL THEN day_of_week ELSE p_day_of_week END,
    time_window_start = COALESCE(p_time_window_start,  time_window_start),
    time_window_end   = COALESCE(p_time_window_end,    time_window_end),
    adjustment_kind   = COALESCE(p_adjustment_kind,    adjustment_kind),
    adjustment_value  = COALESCE(p_adjustment_value,   adjustment_value),
    valid_from        = COALESCE(p_valid_from,         valid_from),
    valid_until       = CASE WHEN p_valid_until IS NULL THEN valid_until ELSE p_valid_until END,
    is_active         = COALESCE(p_is_active,          is_active),
    updated_at        = now()
  WHERE id = p_override_id;
END;
$function$;

REVOKE ALL ON FUNCTION public.update_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ, BOOLEAN) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.update_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ, BOOLEAN) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.update_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ, BOOLEAN) TO authenticated;

COMMENT ON FUNCTION public.update_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ, BOOLEAN) IS
  'Phase 15: owner-only partial update. Authz via pricing_overrides -> appointment_slots -> shops chain. NULL params leave fields unchanged (day_of_week / valid_until cannot be cleared in v1 — workaround is archive + recreate). Cross-field checks run on merged values. SECURITY DEFINER.';
