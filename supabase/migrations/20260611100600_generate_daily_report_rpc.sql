-- Phase 16 Wave 2 Task 2.1 — Create generate_daily_report RPC.
--
-- Keystone RPC. Builds the JSONB snapshot for (p_shop_id, p_report_date),
-- INSERTs / ON CONFLICT UPDATEs into daily_reports (idempotent), emits a
-- push notification via scheduled_notifications, and writes a
-- daily_report_runs audit row.
--
-- HINT vocabulary (LD-11): OWNER_NOT_FOUND, REPORT_DATE_INVALID,
-- SHOP_NOT_FOUND, REPORT_RPC_FAILED.
--
-- Money math (LD-3 / RESEARCH §5): NUMERIC(12,2) × 100 → bigint kobo,
-- exact decimal arithmetic. Comparison delta_bps is NULL when comparison
-- date had zero bookings (LD-14). Follow-ups redact client names per
-- checklist 4.4 (LD-13). All booking_date queries use the half-open
-- range form per AMEND-6 to keep idx_bookings_shop_date_status hot.
--
-- Exception block (REV-1 fix): captures PG_EXCEPTION_HINT via GET STACKED
-- DIAGNOSTICS; never writes SQLERRM into error_code; preserves the
-- originating HINT through the re-raise so SC-14/SC-15/SC-16 work.

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
  -- the cron context (auth.uid() IS NULL = trusted SECURITY DEFINER path).
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
  -- Group identity comes from appointment_slots.slot_type='group' (booking_services
  -- references slot_id; we left-join the slot to surface the slot_type).
  SELECT
    MIN(b.start_time),
    COUNT(DISTINCT b.id)::int,
    BOOL_OR(COALESCE(aps.slot_type = 'group', false))
  INTO v_tomorrow_first, v_tomorrow_count, v_tomorrow_group
  FROM public.bookings b
  LEFT JOIN public.booking_services bs ON bs.booking_id = b.id
  LEFT JOIN public.appointment_slots aps ON aps.id = bs.slot_id
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
        COALESCE(
          LEFT(NULLIF(TRIM(COALESCE(
            b.guest_name,
            (SELECT gp.name FROM public.guest_profiles gp WHERE gp.id = b.guest_profile_id),
            (SELECT p.display_name FROM public.profiles p WHERE p.id = b.user_id),
            ''
          )), ''), 1),
          'A'
        ) || '***'
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
        COALESCE(
          LEFT(NULLIF(TRIM(COALESCE(
            b.guest_name,
            (SELECT gp.name FROM public.guest_profiles gp WHERE gp.id = b.guest_profile_id),
            (SELECT p.display_name FROM public.profiles p WHERE p.id = b.user_id),
            ''
          )), ''), 1),
          'A'
        ) || '***'
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
        COALESCE(
          LEFT(NULLIF(TRIM(COALESCE(
            b.guest_name,
            (SELECT gp.name FROM public.guest_profiles gp WHERE gp.id = b.guest_profile_id),
            (SELECT p.display_name FROM public.profiles p WHERE p.id = b.user_id),
            ''
          )), ''), 1),
          'A'
        ) || '***'
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

  -- LD-7 zero-booking handling. If the cron called us with an empty shop,
  -- log a defensive skip and return NULL (the cron-side selector already
  -- filters zero-booking shops out before invoking us).
  IF (v_count_completed + v_count_no_show + v_count_cancelled + v_count_past_end) = 0
     AND v_today_rev = 0 AND auth.uid() IS NULL THEN
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

  -- Idempotent INSERT / UPDATE. Compound UNIQUE handles concurrent ticks.
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

  -- Push notification. Components in metadata so the edge function can
  -- format at delivery time (RESEARCH §4.5 path b). EN-only v1.
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
    -- REV-1: capture HINT + SQLSTATE via GET STACKED DIAGNOSTICS. Never
    -- write SQLERRM into error_code. Preserve the originating HINT on
    -- re-raise so OWNER_NOT_FOUND / REPORT_DATE_INVALID reach the client.
    DECLARE
      v_hint     TEXT := '';
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
