-- Phase 15: create_pricing_override RPC.
-- Owner-only via slot→shop chain. NULL-shape + field + per-slot-cap (50)
-- validation HINT-coded for Dart-side classifier. SECURITY DEFINER.

CREATE OR REPLACE FUNCTION public.create_pricing_override(
  p_slot_id            UUID,
  p_name               TEXT,
  p_day_of_week        INT,
  p_time_window_start  TIME,
  p_time_window_end    TIME,
  p_adjustment_kind    TEXT,
  p_adjustment_value   NUMERIC,
  p_valid_from         TIMESTAMPTZ DEFAULT NULL,
  p_valid_until        TIMESTAMPTZ DEFAULT NULL
) RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
DECLARE
  v_override_id   UUID;
  v_active_count  INT;
BEGIN
  -- 1. NULL shape — required fields only. day_of_week is nullable by design.
  IF p_slot_id IS NULL OR p_name IS NULL
     OR p_time_window_start IS NULL OR p_time_window_end IS NULL
     OR p_adjustment_kind IS NULL OR p_adjustment_value IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'REQUIRED_FIELD_MISSING';
  END IF;

  -- 2. Authz FIRST. slot → shop chain. Sanitized 'not_found' on mismatch.
  IF NOT EXISTS (
    SELECT 1 FROM public.appointment_slots s
    JOIN public.shops sh ON sh.id = s.shop_id
    WHERE s.id = p_slot_id
      AND sh.user_id = auth.uid()
      AND s.archived_at IS NULL
  ) THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  -- 3. Field validation. HINT-coded for typed-exception mapping.
  IF (char_length(p_name) NOT BETWEEN 1 AND 80) THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'NAME_LENGTH_INVALID';
  END IF;
  IF p_day_of_week IS NOT NULL AND (p_day_of_week NOT BETWEEN 1 AND 7) THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'DAY_OF_WEEK_OUT_OF_RANGE';
  END IF;
  IF p_time_window_end <= p_time_window_start THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'WINDOW_NOT_ORDERED';
  END IF;
  IF p_adjustment_kind NOT IN
     ('percent_discount','percent_surcharge','fixed_discount','fixed_surcharge') THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'ADJUSTMENT_KIND_INVALID';
  END IF;
  IF p_adjustment_value <= 0 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'ADJUSTMENT_VALUE_INVALID';
  END IF;
  IF p_adjustment_kind IN ('percent_discount','percent_surcharge')
     AND p_adjustment_value > 100 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'PERCENT_OUT_OF_RANGE';
  END IF;
  IF p_valid_until IS NOT NULL
     AND p_valid_until <= COALESCE(p_valid_from, now()) THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'VALIDITY_NOT_ORDERED';
  END IF;

  -- 4. Per-slot cap. Count only active + non-archived rows on the parent slot.
  SELECT count(*) INTO v_active_count
  FROM public.pricing_overrides
  WHERE slot_id = p_slot_id
    AND is_active = TRUE
    AND archived_at IS NULL;
  IF v_active_count >= 50 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'OVERRIDE_CAP_EXCEEDED';
  END IF;

  -- 5. Insert.
  INSERT INTO public.pricing_overrides (
    slot_id, name, day_of_week,
    time_window_start, time_window_end,
    adjustment_kind, adjustment_value,
    valid_from, valid_until,
    created_by_user_id
  ) VALUES (
    p_slot_id, p_name, p_day_of_week,
    p_time_window_start, p_time_window_end,
    p_adjustment_kind, p_adjustment_value,
    COALESCE(p_valid_from, now()), p_valid_until,
    auth.uid()
  ) RETURNING id INTO v_override_id;

  RETURN v_override_id;
END;
$function$;

REVOKE ALL ON FUNCTION public.create_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.create_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.create_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ) TO authenticated;

COMMENT ON FUNCTION public.create_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ) IS
  'Phase 15: owner-only create. Authz via appointment_slots -> shops.user_id = auth.uid(). NULL-shape, field, and per-slot-cap (50) validation HINT-coded. O(1) for create + O(N) cap check where N <= 50. SECURITY DEFINER.';
