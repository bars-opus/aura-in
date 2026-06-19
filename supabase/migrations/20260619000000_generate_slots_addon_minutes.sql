-- Add per-service add-on minutes to generate_available_slots.
--
-- Clients can attach optional add-ons (e.g. "+30 min Deep Condition") to a
-- service at booking time. Those minutes extend the real appointment length, so
-- the slot engine must reserve them — otherwise the next client can be booked
-- too early and the worker runs over.
--
-- New param: p_extra_minutes INT[] — parallel to p_service_ids. Each element is
-- the total selected add-on minutes for the service at the same index. NULL or a
-- missing element is treated as 0. Buffers are unchanged (still per-slot).
--
-- This is a superset of the previous 6-arg signature: p_extra_minutes defaults
-- to NULL, so existing callers that don't pass it keep working unchanged.

CREATE OR REPLACE FUNCTION public.generate_available_slots(
  p_shop_id                 UUID,
  p_date                    DATE,
  p_service_ids             UUID[],
  p_quantities              INT[],
  p_selected_worker_ids     UUID[] DEFAULT NULL,
  p_default_buffer_minutes  INT    DEFAULT NULL,
  p_extra_minutes           INT[]  DEFAULT NULL
)
RETURNS TABLE (
  slot_id                    UUID,
  service_name               TEXT,
  start_time                 TIMESTAMPTZ,
  end_time                   TIMESTAMPTZ,
  actual_end_time            TIMESTAMPTZ,
  price                      NUMERIC,
  base_price                 NUMERIC,
  available_workers          JSONB,
  remaining_spots            INT,
  requires_worker_selection  BOOLEAN,
  buffer_minutes             INT
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_dow         INT;
  v_opens       TIME;
  v_closes      TIME;
  v_closed      BOOLEAN;
  v_svc         RECORD;
  v_svc_id      UUID;
  v_qty         INT;
  v_t           TIMESTAMPTZ;
  v_end         TIMESTAMPTZ;
  v_actual_end  TIMESTAMPTZ;
  v_buffer      INT;
  v_workers     JSONB;
  v_capacity    INT;
  v_taken       INT;
  v_dur_min     INT;
  v_extra_min   INT;
  v_i           INT;
  v_use_selected BOOLEAN;
  v_overrides   JSONB := '[]'::jsonb;
  v_eff_price   NUMERIC;
  v_base_price  NUMERIC;
BEGIN
  v_use_selected := (p_selected_worker_ids IS NOT NULL
                     AND cardinality(p_selected_worker_ids) > 0);

  v_dow := EXTRACT(ISODOW FROM p_date)::INT;

  SELECT opens_at, closes_at, COALESCE(is_closed, false)
    INTO v_opens, v_closes, v_closed
  FROM   shop_opening_hours
  WHERE  shop_id = p_shop_id AND day_of_week = v_dow
  LIMIT  1;

  IF NOT FOUND OR v_closed THEN
    RETURN;
  END IF;

  SELECT COALESCE(jsonb_agg(jsonb_build_object(
    'slot_id',         o.slot_id,
    'day_of_week',     o.day_of_week,
    'window_start',    o.time_window_start,
    'window_end',      o.time_window_end,
    'kind',            o.adjustment_kind,
    'value',           o.adjustment_value,
    'specificity',     (o.day_of_week IS NOT NULL)::int,
    'window_seconds',  EXTRACT(EPOCH FROM (o.time_window_end - o.time_window_start)),
    'created_at',      o.created_at
  )), '[]'::jsonb) INTO v_overrides
  FROM pricing_overrides o
  WHERE o.slot_id = ANY(p_service_ids)
    AND o.is_active = TRUE
    AND o.archived_at IS NULL
    AND (o.day_of_week IS NULL OR o.day_of_week = v_dow)
    AND o.valid_from <= now()
    AND (o.valid_until IS NULL OR o.valid_until > now());

  v_i := 1;
  FOREACH v_svc_id IN ARRAY p_service_ids LOOP
    v_qty := COALESCE(p_quantities[v_i], 1);
    -- Per-service add-on minutes at the same index. Guard against a shorter or
    -- NULL array so callers can omit it entirely.
    v_extra_min := COALESCE(
      CASE
        WHEN p_extra_minutes IS NOT NULL
             AND v_i <= cardinality(p_extra_minutes)
        THEN p_extra_minutes[v_i]
        ELSE 0
      END, 0);
    v_i := v_i + 1;

    SELECT s.* INTO v_svc
    FROM   appointment_slots s
    WHERE  s.id = v_svc_id
      AND  s.archived_at IS NULL;

    IF NOT FOUND THEN CONTINUE; END IF;

    v_buffer  := COALESCE(v_svc.buffer_minutes, p_default_buffer_minutes, 0);
    -- Effective service length = base duration + selected add-on minutes.
    v_dur_min := extract_duration_minutes(v_svc.duration) + GREATEST(v_extra_min, 0);

    v_t := (p_date + v_opens)::TIMESTAMPTZ;
    WHILE v_t::TIME <= v_closes - (v_dur_min || ' minutes')::INTERVAL LOOP
      v_end        := v_t + (v_dur_min || ' minutes')::INTERVAL;
      v_actual_end := v_end + (v_buffer || ' minutes')::INTERVAL;

      IF v_use_selected THEN
        SELECT COALESCE(jsonb_agg(jsonb_build_object(
          'id',                w.id,
          'name',              w.name,
          'bio',               w.bio,
          'profile_image_url', w.profile_image_url,
          'specialties',       COALESCE(w.specialties, ARRAY[]::TEXT[]),
          'rating_average',    NULL,
          'is_active',         w.is_active
        )), '[]'::jsonb) INTO v_workers
        FROM workers w
        WHERE w.id = ANY(p_selected_worker_ids)
          AND COALESCE(w.is_active, true) = true;
      ELSE
        SELECT COALESCE(jsonb_agg(w), '[]'::jsonb) INTO v_workers
        FROM (
          SELECT * FROM get_available_workers(
            ARRAY(
              SELECT swa.worker_id
              FROM   slot_worker_assignments swa
              WHERE  swa.slot_id = v_svc.id
            ),
            v_t, v_end
          ) AS w
        ) AS w;
      END IF;

      v_base_price := COALESCE(v_svc.price, 0);
      v_eff_price  := NULL;

      WITH ranked AS (
        SELECT
          (o->>'kind')                          AS kind,
          ((o->>'value')::NUMERIC)              AS value,
          ((o->>'specificity')::INT)            AS specificity,
          ((o->>'window_seconds')::NUMERIC)     AS window_seconds,
          (o->>'created_at')::TIMESTAMPTZ       AS created_at
        FROM jsonb_array_elements(v_overrides) o
        WHERE (o->>'slot_id')::UUID = v_svc.id
          AND v_t::TIME >= (o->>'window_start')::TIME
          AND v_t::TIME <  (o->>'window_end')::TIME
      )
      SELECT
        CASE kind
          WHEN 'percent_discount'  THEN GREATEST(v_base_price * (1 - value/100.0), 0)
          WHEN 'percent_surcharge' THEN v_base_price * (1 + value/100.0)
          WHEN 'fixed_discount'    THEN GREATEST(v_base_price - value, 0)
          WHEN 'fixed_surcharge'   THEN v_base_price + value
        END
      INTO v_eff_price
      FROM ranked
      ORDER BY specificity DESC, window_seconds ASC, created_at DESC
      LIMIT 1;

      v_eff_price := COALESCE(v_eff_price, v_base_price);

      IF v_svc.slot_type = 'group' THEN
        SELECT count(*) INTO v_taken
        FROM   booking_services bs
        JOIN   bookings b ON b.id = bs.booking_id
        WHERE  bs.slot_id = v_svc.id
          AND  bs.start_time = v_t
          AND  b.status NOT IN ('cancelled', 'no_show');

        v_capacity := COALESCE(v_svc.max_clients, 1);
        IF v_capacity - v_taken >= v_qty THEN
          slot_id                   := v_svc.id;
          service_name              := v_svc.service_name;
          start_time                := v_t;
          end_time                  := v_end;
          actual_end_time           := v_actual_end;
          price                     := v_eff_price;
          base_price                := v_base_price;
          available_workers         := v_workers;
          remaining_spots           := v_capacity - v_taken;
          requires_worker_selection := COALESCE(v_svc.select_preferred_worker, false);
          buffer_minutes            := v_buffer;
          RETURN NEXT;
        END IF;
      ELSE
        IF jsonb_array_length(v_workers) > 0
           OR COALESCE(v_svc.select_preferred_worker, false) = false THEN
          slot_id                   := v_svc.id;
          service_name              := v_svc.service_name;
          start_time                := v_t;
          end_time                  := v_end;
          actual_end_time           := v_actual_end;
          price                     := v_eff_price;
          base_price                := v_base_price;
          available_workers         := v_workers;
          remaining_spots           := NULL;
          requires_worker_selection := COALESCE(v_svc.select_preferred_worker, false);
          buffer_minutes            := v_buffer;
          RETURN NEXT;
        END IF;
      END IF;

      v_t := v_t + INTERVAL '15 minutes';
    END LOOP;
  END LOOP;
END;
$$;

REVOKE ALL ON FUNCTION public.generate_available_slots(UUID, DATE, UUID[], INT[], UUID[], INT, INT[]) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.generate_available_slots(UUID, DATE, UUID[], INT[], UUID[], INT, INT[]) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.generate_available_slots(UUID, DATE, UUID[], INT[], UUID[], INT, INT[]) TO authenticated;
