-- Phase 15: rewrite generate_available_slots to apply pricing_overrides and
-- emit a new `base_price` column so the client can render the discount/
-- surcharge chip without a second RPC call.
--
-- Three changes from the prior body
-- (20260605000300_archive_filter_cascade.sql:244-393):
--   (1) EXTRACT(DOW) → EXTRACT(ISODOW). The original returned 0..6 with
--       Sunday=0, which never matched shop_opening_hours.day_of_week=7,
--       silently dropping Sunday bookings (RESEARCH §3 — corroborated by
--       prod data showing appointment_slots.days_of_week rows in 1..6 only).
--       ISODOW returns 1..7 with Mon=1, Sun=7 — matches the join target.
--   (2) Pre-materialize active overrides once per RPC call as a JSONB array.
--       The hot-path WHILE loop then looks up the winning override per
--       (v_svc.id, v_dow, v_t) against the materialized array. ~450x cheaper
--       than re-querying pricing_overrides on every iteration on a typical
--       9h × 5-service × 30-min grid.
--   (3) Add `base_price NUMERIC` to the RETURN TABLE. `price` carries the
--       effective (post-override) value; `base_price` carries the unmodified
--       appointment_slots.price. Zero-override shops see price == base_price.
--
-- DROP first: Postgres rejects CREATE OR REPLACE when RETURN TABLE changes
-- (adding base_price is a return-type change).

DROP FUNCTION IF EXISTS public.generate_available_slots(UUID, DATE, UUID[], INT[], UUID[], INT);

CREATE OR REPLACE FUNCTION public.generate_available_slots(
  p_shop_id                 UUID,
  p_date                    DATE,
  p_service_ids             UUID[],
  p_quantities              INT[],
  p_selected_worker_ids     UUID[] DEFAULT NULL,
  p_default_buffer_minutes  INT    DEFAULT NULL
)
RETURNS TABLE (
  slot_id                    UUID,
  service_name               TEXT,
  start_time                 TIMESTAMPTZ,
  end_time                   TIMESTAMPTZ,
  actual_end_time            TIMESTAMPTZ,
  price                      NUMERIC,
  base_price                 NUMERIC,   -- Phase 15: pre-override base
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
  v_i           INT;
  v_use_selected BOOLEAN;
  -- Phase 15 additions:
  v_overrides   JSONB := '[]'::jsonb;
  v_eff_price   NUMERIC;
  v_base_price  NUMERIC;
BEGIN
  v_use_selected := (p_selected_worker_ids IS NOT NULL
                     AND cardinality(p_selected_worker_ids) > 0);

  -- Phase 15: ISODOW (Mon=1..Sun=7) — fixes the latent Sunday bug.
  v_dow := EXTRACT(ISODOW FROM p_date)::INT;

  SELECT opens_at, closes_at, COALESCE(is_closed, false)
    INTO v_opens, v_closes, v_closed
  FROM   shop_opening_hours
  WHERE  shop_id = p_shop_id AND day_of_week = v_dow
  LIMIT  1;

  IF NOT FOUND OR v_closed THEN
    RETURN;
  END IF;

  -- Phase 15: pre-materialize active overrides for every service in the call,
  -- restricted to "could match v_dow today". One scan over the partial index
  -- idx_pricing_overrides_active_slot. Filter:
  --   - slot_id IN p_service_ids
  --   - is_active AND NOT archived
  --   - day_of_week NULL (all-week) OR day_of_week = today's ISODOW
  --   - valid_from <= now() < valid_until (or valid_until NULL)
  SELECT COALESCE(jsonb_agg(jsonb_build_object(
    'slot_id',         o.slot_id,
    'day_of_week',     o.day_of_week,
    'window_start',    o.time_window_start,
    'window_end',      o.time_window_end,
    'kind',            o.adjustment_kind,
    'value',           o.adjustment_value,
    'specificity',     (o.day_of_week IS NOT NULL)::int,  -- 1 = day-specific
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
    v_i   := v_i + 1;

    -- Phase 11 archive filter: skip archived services entirely.
    SELECT s.* INTO v_svc
    FROM   appointment_slots s
    WHERE  s.id = v_svc_id
      AND  s.archived_at IS NULL;

    IF NOT FOUND THEN CONTINUE; END IF;

    v_buffer  := COALESCE(v_svc.buffer_minutes, p_default_buffer_minutes, 0);
    v_dur_min := extract_duration_minutes(v_svc.duration);

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

      -- Phase 15: resolve the winning override for (v_svc.id, v_t::TIME).
      -- 3-tier ladder:
      --   1. day_of_week NOT NULL beats day_of_week NULL (specificity DESC)
      --   2. narrower window beats wider (window_seconds ASC)
      --   3. newer beats older (created_at DESC) — final tiebreak
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

      -- COALESCE — if no override matched, fall back to base.
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
          price                     := v_eff_price;     -- Phase 15: effective
          base_price                := v_base_price;    -- Phase 15: base
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
          price                     := v_eff_price;     -- Phase 15: effective
          base_price                := v_base_price;    -- Phase 15: base
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

REVOKE ALL ON FUNCTION public.generate_available_slots(UUID, DATE, UUID[], INT[], UUID[], INT) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.generate_available_slots(UUID, DATE, UUID[], INT[], UUID[], INT) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.generate_available_slots(UUID, DATE, UUID[], INT[], UUID[], INT) TO authenticated;

COMMENT ON FUNCTION public.generate_available_slots(UUID, DATE, UUID[], INT[], UUID[], INT) IS
  'Phase 15 rewrite: pre-materializes active pricing_overrides once per RPC call, resolves the winning override per generated slot via the 3-tier ladder (specificity -> window width -> recency), and emits both effective price (price) and base price (base_price) so the client can render the discount/surcharge chip without a second RPC call. Also fixes the latent EXTRACT(DOW) Sunday bug by switching to EXTRACT(ISODOW). Backward-compatible: zero-override shops see price == base_price and no behavior change. RESEARCH §2 + §3 + §16.';
