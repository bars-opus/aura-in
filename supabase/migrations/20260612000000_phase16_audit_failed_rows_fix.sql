-- Phase 16 hardening — corrective for audit findings F-P0-4 + F-P1-6.
--
-- F-P0-4 (P0 / [SERVICE][ASYNC]):
--   `generate_daily_report`'s EXCEPTION block INSERTed the `outcome='failed'`
--   audit row and then RAISEd, which rolls back the entire subtransaction —
--   including the audit INSERT. Result: cron-driven failures left zero
--   forensic trace, breaking LD-7 ("ran the tick, observed failure" audit).
--   Fix: drop the audit INSERT from generate_daily_report's handler (just
--   re-raise with the preserved HINT) and write the failed-row from
--   dispatch_daily_reports' OWN handler instead (which catches without
--   re-raising — the INSERT survives).
--
-- F-P1-6 (P1 / [SERVICE][ASYNC]):
--   Same dispatcher loop, but a different failure mode: if a shop has a
--   bogus `timezone` value (out-of-set IANA name), `now() AT TIME ZONE
--   sh.timezone` raises `invalid_parameter_value` inside the SELECT CTE
--   itself, BEFORE the per-shop generate loop. That tanks every shop in
--   the tick. Fix: materialise the shop list with a guarded per-row
--   timezone resolution; bad shops fall out of the candidate set with
--   a heartbeat row written to daily_report_runs.
--
-- Both fixes preserve the existing public function signatures so no
-- callers need to change.

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

  SELECT COALESCE(jsonb_agg(entry ORDER BY entry->>'reason'), '[]'::jsonb)
    INTO v_follow_ups
  FROM (
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

  -- LD-7 zero-booking defensive skip (no change vs original).
  IF (v_count_completed + v_count_no_show + v_count_cancelled + v_count_past_end) = 0
     AND v_today_rev = 0 AND auth.uid() IS NULL THEN
    INSERT INTO public.daily_report_runs (
      shop_id, report_date, triggered_by, outcome, error_code
    ) VALUES (p_shop_id, p_report_date, 'cron', 'skipped_zero_bookings', NULL);
    RETURN NULL;
  END IF;

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

  INSERT INTO public.daily_report_runs (
    shop_id, report_date, triggered_by, outcome, error_code
  ) VALUES (
    p_shop_id, p_report_date,
    CASE WHEN auth.uid() IS NULL THEN 'cron' ELSE 'manual' END,
    v_outcome, NULL
  );

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
    -- F-P0-4 fix: do NOT INSERT into daily_report_runs here. The re-raise
    -- rolls back the surrounding subtransaction, which would erase the
    -- audit INSERT. The caller (dispatch_daily_reports for cron; the
    -- Dart client for manual) is responsible for the audit row on failure.
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
      RAISE EXCEPTION 'report_failed'
        USING ERRCODE = v_sqlstate, HINT = v_code;
    END;
END;
$function$;


CREATE OR REPLACE FUNCTION public.dispatch_daily_reports()
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
DECLARE
  v_started_at  TIMESTAMPTZ := clock_timestamp();
  v_shop_count  INT := 0;
  v_error_count INT := 0;
  v_skipped_tz  INT := 0;
  v_row         RECORD;
  v_hint        TEXT;
BEGIN
  SET LOCAL statement_timeout = '30s';

  -- F-P1-6 fix: materialise the candidate set with a per-row exception
  -- guard, so a single shop with a bogus IANA timezone falls out instead
  -- of poisoning the whole tick. Bogus rows are counted into v_skipped_tz
  -- for visibility and surface via the structured RED log line.
  CREATE TEMP TABLE IF NOT EXISTS _daily_candidates (
    shop_id     UUID NOT NULL,
    report_date DATE NOT NULL,
    tz          TEXT NOT NULL
  ) ON COMMIT DROP;
  DELETE FROM _daily_candidates;

  FOR v_row IN
    SELECT sh.id AS shop_id, sh.timezone AS tz
    FROM public.shops sh
  LOOP
    BEGIN
      IF (now() AT TIME ZONE v_row.tz)::time
           BETWEEN TIME '22:22:30' AND TIME '22:37:30' THEN
        INSERT INTO _daily_candidates(shop_id, report_date, tz)
        VALUES (v_row.shop_id,
                (now() AT TIME ZONE v_row.tz)::date,
                v_row.tz);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        v_skipped_tz := v_skipped_tz + 1;
        -- Log a heartbeat with error_code so the bad shop is debuggable.
        -- shop_id remains NULL on the audit row (visible to service_role).
        GET STACKED DIAGNOSTICS v_hint = PG_EXCEPTION_HINT;
        INSERT INTO public.daily_report_runs (
          shop_id, report_date, triggered_by, outcome, error_code
        ) VALUES (
          v_row.shop_id, NULL, 'cron', 'failed',
          COALESCE(NULLIF(v_hint, ''), 'TIMEZONE_INVALID')
        );
    END;
  END LOOP;

  FOR v_row IN
    SELECT c.shop_id, c.report_date, c.tz
    FROM _daily_candidates c
    WHERE EXISTS (
      SELECT 1 FROM public.bookings b
      WHERE b.shop_id = c.shop_id
        AND b.booking_date >= ((c.report_date::timestamp) AT TIME ZONE c.tz)
        AND b.booking_date <  (((c.report_date + 1)::timestamp) AT TIME ZONE c.tz)
    )
      AND NOT EXISTS (
      SELECT 1 FROM public.daily_reports dr
      WHERE dr.shop_id = c.shop_id AND dr.report_date = c.report_date
    )
  LOOP
    BEGIN
      PERFORM public.generate_daily_report(v_row.shop_id, v_row.report_date);
      v_shop_count := v_shop_count + 1;
    EXCEPTION
      WHEN OTHERS THEN
        v_error_count := v_error_count + 1;
        -- F-P0-4 fix: write the failed-audit row HERE, where the handler
        -- does NOT re-raise, so the INSERT survives.
        DECLARE
          v_inner_hint TEXT;
        BEGIN
          GET STACKED DIAGNOSTICS v_inner_hint = PG_EXCEPTION_HINT;
          INSERT INTO public.daily_report_runs (
            shop_id, report_date, triggered_by, outcome, error_code
          ) VALUES (
            v_row.shop_id, v_row.report_date, 'cron', 'failed',
            COALESCE(NULLIF(v_inner_hint, ''), 'REPORT_RPC_FAILED')
          );
        END;
    END;
  END LOOP;

  IF v_shop_count = 0 AND v_error_count = 0 AND v_skipped_tz = 0 THEN
    INSERT INTO public.daily_report_runs (
      shop_id, report_date, triggered_by, outcome, error_code
    ) VALUES (NULL, NULL, 'cron', 'skipped_zero_bookings', NULL);
  END IF;

  RAISE NOTICE 'daily_report.dispatch_completed shop_count=% error_count=% skipped_tz=% duration_ms=%',
    v_shop_count, v_error_count, v_skipped_tz,
    EXTRACT(MILLISECONDS FROM clock_timestamp() - v_started_at)::int;
END;
$function$;

COMMENT ON FUNCTION public.generate_daily_report(UUID, DATE) IS
  'Phase 16 (hardened 2026-06-12): idempotent daily-report builder. INSERT ... ON CONFLICT (shop_id, report_date) DO UPDATE — duplicate cron tick = no-op; manual re-generate REPLACES. Authz: shops.user_id = auth.uid() OR auth.uid() IS NULL (cron context). Money math in bigint kobo (LD-3). Comparison delta_bps NULL when comparison date has zero bookings (LD-14). Follow-ups redact client names (checklist 4.4). statement_timeout 10s. HINT codes: OWNER_NOT_FOUND, REPORT_DATE_INVALID, REPORT_RPC_FAILED. F-P0-4: EXCEPTION block re-raises only — caller writes the failed-audit row.';

COMMENT ON FUNCTION public.dispatch_daily_reports() IS
  'Phase 16 (hardened 2026-06-12): cron-only fan-out, */15 * * * *. Per-shop timezone resolution guarded against invalid IANA values — bad shops fall out of the candidate set with a logged heartbeat (F-P1-6). Per-shop generate_daily_report failures captured here and written to daily_report_runs with the preserved HINT (F-P0-4). Zero-shop ticks still emit a heartbeat row. SECURITY DEFINER. REVOKED from authenticated.';
