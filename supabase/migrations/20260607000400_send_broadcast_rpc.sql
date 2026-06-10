-- Phase 14: send_broadcast RPC — the hot path.
--
-- Eleven discrete steps in body order:
--   1. Advisory lock — same-second double-tap guard
--   2. NULL shape validation
--   3. Length caps (subject ≤ 100, body ≤ 800)
--   4. Audience-type whitelist + audience_param XOR
--   5. Authz (sanitized not_found for cross-shop)
--   6. UTC-day rate limit
--   7. Promo re-validation (mirrors validate_and_apply_promo manual-entry
--      branch + source = 'owner_defined' to block silent loyalty/recovery
--      codes from broadcast attachment)
--   8. Shop name fetch
--   9. broadcasts row insert with status='delivering'
--  10a. Audience size pre-check vs 1000 cap (BEFORE fan-out so the cap
--       raise rolls back the broadcasts row cleanly)
--  10b. INSERT ... SELECT fan-out into scheduled_notifications
--       (single statement; atomic; CASE expression splits push vs
--       whatsapp shape)
--  11. UPDATE broadcasts row to status='delivered'
--
-- The whole RPC runs in a single implicit transaction — failure anywhere
-- (advisory lock, validation, fan-out) rolls back the broadcasts row too.
-- No half-sent broadcasts.
--
-- enqueue_booking_reminder is NOT reused: broadcasts have no booking_id;
-- this RPC writes scheduled_notifications rows directly.

CREATE OR REPLACE FUNCTION public.send_broadcast(
  p_shop_id         UUID,
  p_subject         TEXT,
  p_body            TEXT,
  p_audience_type   TEXT,
  p_audience_param  UUID,
  p_promotion_id    UUID DEFAULT NULL
) RETURNS TABLE (broadcast_id UUID, recipient_count INT)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
DECLARE
  v_broadcast_id   UUID;
  v_shop_name      TEXT;
  v_recipient_cnt  INT;
  v_today_count    INT;
  v_audience_size  INT;
BEGIN
  -- 1. Advisory lock — same-second double-tap guard. xact-scoped;
  -- auto-released on commit/rollback.
  IF NOT pg_try_advisory_xact_lock(hashtext(p_shop_id::text)) THEN
    RAISE EXCEPTION 'rate_limited'
      USING ERRCODE = '55P03', HINT = 'BROADCAST_IN_FLIGHT';
  END IF;

  -- 2. NULL shape (no side effects).
  IF p_shop_id IS NULL OR p_subject IS NULL OR p_body IS NULL
     OR p_audience_type IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'REQUIRED_FIELD_MISSING';
  END IF;

  -- 3. Length caps. Subject = push title (100 chars). Body floor of
  -- push (800) vs WhatsApp (1024) — enforce 800.
  IF char_length(p_subject) > 100 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'SUBJECT_TOO_LONG';
  END IF;
  IF char_length(p_body) > 800 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'BODY_TOO_LONG';
  END IF;

  -- 4. Audience-type whitelist + XOR.
  IF p_audience_type NOT IN ('all_clients','recent','lapsed','by_service') THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'AUDIENCE_TYPE_INVALID';
  END IF;
  IF p_audience_type = 'by_service' AND p_audience_param IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'AUDIENCE_PARAM_REQUIRED';
  END IF;
  IF p_audience_type <> 'by_service' AND p_audience_param IS NOT NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'AUDIENCE_PARAM_FORBIDDEN';
  END IF;

  -- 5. Authz. Sanitized 'not_found' for cross-shop access.
  IF NOT EXISTS (SELECT 1 FROM public.shops
                 WHERE id = p_shop_id AND user_id = auth.uid()) THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  -- 6. UTC-day rate limit. Long-term guard; advisory lock covers
  -- same-second races. Counts rows in the current UTC day.
  SELECT count(*) INTO v_today_count
  FROM public.broadcasts
  WHERE shop_id = p_shop_id
    AND created_at >= date_trunc('day', now() AT TIME ZONE 'UTC')
    AND created_at <  date_trunc('day', now() AT TIME ZONE 'UTC') + INTERVAL '1 day';
  IF v_today_count > 0 THEN
    RAISE EXCEPTION 'rate_limited'
      USING ERRCODE = '55P03', HINT = 'BROADCAST_DAILY_LIMIT';
  END IF;

  -- 7. Promo re-validation. Predicate mirrors validate_and_apply_promo's
  -- manual-entry branch. Adds source='owner_defined' to block silent
  -- loyalty/recovery codes (preserves the Phase 13 silent-loyalty
  -- contract — silent codes are client-targeted and not broadcastable).
  IF p_promotion_id IS NOT NULL THEN
    IF NOT EXISTS (
      SELECT 1 FROM public.promotions
      WHERE id = p_promotion_id
        AND shop_id = p_shop_id
        AND archived_at IS NULL
        AND is_active = TRUE
        AND (valid_to IS NULL OR valid_to > now())
        AND source = 'owner_defined'
    ) THEN
      RAISE EXCEPTION 'invalid_input'
        USING ERRCODE = '22023', HINT = 'PROMO_NOT_VALID';
    END IF;
  END IF;

  -- 8. Shop name (for metadata + WhatsApp param 1).
  SELECT shop_name INTO v_shop_name FROM public.shops WHERE id = p_shop_id;

  -- 9. Insert the broadcasts row with status='delivering'.
  INSERT INTO public.broadcasts (
    shop_id, subject, body, audience_type, audience_param,
    promotion_id, created_by_user_id, status
  ) VALUES (
    p_shop_id, p_subject, p_body, p_audience_type, p_audience_param,
    p_promotion_id, auth.uid(), 'delivering'
  ) RETURNING id INTO v_broadcast_id;

  -- 10a. Audience size pre-check against 1000 cap. We compute the
  -- filtered count BEFORE the fan-out INSERT so the cap raises a clean
  -- BROADCAST_CAP_EXCEEDED (with the broadcasts row rolled back by the
  -- implicit transaction) rather than a partial insert.
  WITH client_identities AS (
    SELECT b.user_id, b.guest_profile_id,
           COALESCE(b.user_id::text, b.guest_profile_id::text) AS dedup_key,
           MAX(b.start_time) FILTER (WHERE b.status <> 'pending') AS last_at
    FROM public.bookings b
    WHERE b.shop_id = p_shop_id AND b.status <> 'pending'
    GROUP BY b.user_id, b.guest_profile_id
  ),
  audience AS (
    SELECT ci.user_id, ci.guest_profile_id
    FROM client_identities ci
    WHERE
      CASE p_audience_type
        WHEN 'all_clients' THEN TRUE
        WHEN 'recent'      THEN ci.last_at >= now() - INTERVAL '30 days'
        WHEN 'lapsed'      THEN ci.last_at <  now() - INTERVAL '60 days'
                                AND EXISTS (
                                  SELECT 1 FROM public.bookings b2
                                  WHERE b2.shop_id = p_shop_id
                                    AND b2.status IN ('confirmed','completed')
                                    AND COALESCE(b2.user_id::text, b2.guest_profile_id::text) = ci.dedup_key)
        WHEN 'by_service'  THEN EXISTS (
                                  SELECT 1 FROM public.bookings b2
                                  JOIN public.booking_services bs ON bs.booking_id = b2.id
                                  WHERE b2.shop_id = p_shop_id
                                    AND b2.status <> 'pending'
                                    AND bs.slot_id = p_audience_param
                                    AND COALESCE(b2.user_id::text, b2.guest_profile_id::text) = ci.dedup_key)
      END
  )
  SELECT count(*) INTO v_audience_size
  FROM audience a
  LEFT JOIN public.guest_profiles gp ON gp.id = a.guest_profile_id
  WHERE a.user_id IS NOT NULL OR COALESCE(gp.accepts_marketing, TRUE) = TRUE;

  IF v_audience_size > 1000 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'BROADCAST_CAP_EXCEEDED';
  END IF;

  -- 10b. Fan-out. Single INSERT ... SELECT for atomicity. CASE expression
  -- splits push vs whatsapp shape. Phone for whatsapp rows pulled
  -- directly from guest_profiles (no booking_id available).
  WITH client_identities AS (
    SELECT b.user_id, b.guest_profile_id,
           COALESCE(b.user_id::text, b.guest_profile_id::text) AS dedup_key,
           MAX(b.start_time) FILTER (WHERE b.status <> 'pending') AS last_at
    FROM public.bookings b
    WHERE b.shop_id = p_shop_id AND b.status <> 'pending'
    GROUP BY b.user_id, b.guest_profile_id
  ),
  audience AS (
    SELECT ci.user_id, ci.guest_profile_id, ci.dedup_key
    FROM client_identities ci
    WHERE
      CASE p_audience_type
        WHEN 'all_clients' THEN TRUE
        WHEN 'recent'      THEN ci.last_at >= now() - INTERVAL '30 days'
        WHEN 'lapsed'      THEN ci.last_at <  now() - INTERVAL '60 days'
                                AND EXISTS (
                                  SELECT 1 FROM public.bookings b2
                                  WHERE b2.shop_id = p_shop_id
                                    AND b2.status IN ('confirmed','completed')
                                    AND COALESCE(b2.user_id::text, b2.guest_profile_id::text) = ci.dedup_key)
        WHEN 'by_service'  THEN EXISTS (
                                  SELECT 1 FROM public.bookings b2
                                  JOIN public.booking_services bs ON bs.booking_id = b2.id
                                  WHERE b2.shop_id = p_shop_id
                                    AND b2.status <> 'pending'
                                    AND bs.slot_id = p_audience_param
                                    AND COALESCE(b2.user_id::text, b2.guest_profile_id::text) = ci.dedup_key)
      END
  ),
  filtered AS (
    SELECT a.user_id, a.guest_profile_id
    FROM audience a
    LEFT JOIN public.guest_profiles gp ON gp.id = a.guest_profile_id
    WHERE a.user_id IS NOT NULL OR COALESCE(gp.accepts_marketing, TRUE) = TRUE
  ),
  inserted AS (
    INSERT INTO public.scheduled_notifications (
      user_id, guest_profile_id, booking_id, shop_id,
      notification_type, scheduled_for, delivery_channel,
      whatsapp_template, whatsapp_params, status, metadata
    )
    SELECT
      f.user_id,
      f.guest_profile_id,
      NULL,
      p_shop_id,
      'marketing_broadcast'::notification_type,
      now(),
      CASE WHEN f.user_id IS NOT NULL THEN 'push' ELSE 'whatsapp' END,
      CASE WHEN f.user_id IS NULL THEN 'marketing_broadcast_v1' ELSE NULL END,
      CASE WHEN f.user_id IS NULL
           THEN jsonb_build_object('1', v_shop_name, '2', p_body)
           ELSE NULL END,
      'pending',
      CASE WHEN f.user_id IS NULL
           THEN jsonb_build_object(
                  'phone', (SELECT phone FROM public.guest_profiles WHERE id = f.guest_profile_id),
                  'broadcast_id', v_broadcast_id,
                  'shop_name', v_shop_name)
           ELSE jsonb_build_object(
                  'title', p_subject,
                  'body', p_body,
                  'broadcast_id', v_broadcast_id,
                  'shop_name', v_shop_name)
      END
    FROM filtered f
    RETURNING 1
  )
  SELECT count(*) INTO v_recipient_cnt FROM inserted;

  -- 11. Flip broadcasts row to delivered.
  UPDATE public.broadcasts
  SET status = 'delivered',
      delivered_at = now(),
      recipient_count = v_recipient_cnt
  WHERE id = v_broadcast_id;

  RETURN QUERY SELECT v_broadcast_id, v_recipient_cnt;
END;
$function$;

REVOKE ALL ON FUNCTION public.send_broadcast(UUID, TEXT, TEXT, TEXT, UUID, UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.send_broadcast(UUID, TEXT, TEXT, TEXT, UUID, UUID) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.send_broadcast(UUID, TEXT, TEXT, TEXT, UUID, UUID) TO authenticated;

COMMENT ON FUNCTION public.send_broadcast(UUID, TEXT, TEXT, TEXT, UUID, UUID) IS
  'Phase 14 owner-only broadcast send. Atomic: advisory lock → validation → broadcasts row → audience pre-check (1000 cap) → fan-out INSERT...SELECT into scheduled_notifications → flip to delivered. Full rollback on any failure. Worker delivers from scheduled_notifications. Returns (broadcast_id, recipient_count). Phase 14.';
