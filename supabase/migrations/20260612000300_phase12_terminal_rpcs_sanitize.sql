-- Phase 12 hardening — corrective for audit finding F-P1-3.
--
-- Issue (checklist 2.4 / P0-U / [SERVICE]):
--   `cancel_booking`, `mark_booking_complete`, `mark_booking_no_show` all
--   SELECT FROM bookings WHERE id = p_booking_id BEFORE the ownership
--   check. The NOT FOUND branch raises `'booking % not found', p_booking_id`
--   with `ERRCODE = 'P0002'`. A non-owner probing UUIDs gets:
--     * 'P0002 booking <UUID> not found' for missing rows
--     * '42501 unauthorized'              for rows that exist but aren't theirs
--   This enumerates booking-UUID existence + leaks the queried UUID in the
--   error message.
--
-- Fix:
--   Gate the SELECT with an OR-join on ownership (booking owner OR shop
--   owner). The NOT FOUND case is now indistinguishable between missing
--   and unauthorized — both raise a single sanitized HINT
--   ('BOOKING_NOT_FOUND', errcode 42501). Audit log unchanged. Status-
--   transition checks unchanged. Signatures byte-for-byte preserved.

CREATE OR REPLACE FUNCTION cancel_booking(
  p_booking_id UUID,
  p_reason     TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_booking bookings%ROWTYPE;
  v_result  JSONB;
BEGIN
  PERFORM check_rate_limit('cancel_booking', 5, 60);

  IF p_reason IS NOT NULL AND length(p_reason) > 500 THEN
    RAISE EXCEPTION 'cancellation_reason too long' USING ERRCODE = '22023';
  END IF;

  -- F-P1-3: ownership-gated SELECT. Both "missing" and "not yours"
  -- collapse to the same sanitized raise.
  SELECT b.* INTO v_booking
  FROM bookings b
  LEFT JOIN shops s ON s.id = b.shop_id
  WHERE b.id = p_booking_id
    AND (b.user_id = auth.uid() OR s.user_id = auth.uid())
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501', HINT = 'BOOKING_NOT_FOUND';
  END IF;

  IF v_booking.status NOT IN ('pending','confirmed') THEN
    RAISE EXCEPTION 'cannot cancel booking in status %', v_booking.status
      USING ERRCODE = '22023';
  END IF;

  UPDATE bookings
  SET    status              = 'cancelled',
         cancellation_reason = NULLIF(trim(coalesce(p_reason, '')), ''),
         cancelled_at        = now(),
         updated_at          = now()
  WHERE  id = p_booking_id;

  INSERT INTO booking_audit_log (actor_id, action, target_table, target_id, details)
  VALUES (auth.uid(), 'booking.cancel', 'bookings', p_booking_id,
          jsonb_build_object('from', v_booking.status));

  PERFORM public.cancel_and_followup(p_booking_id, 'cancelled');

  SELECT to_jsonb(b.*) INTO v_result FROM bookings b WHERE b.id = p_booking_id;
  RETURN v_result;
END;
$$;

COMMENT ON FUNCTION cancel_booking(UUID, TEXT) IS
  'Phase 12: cancel_and_followup wired in after the status UPDATE. F-P1-3: ownership-gated SELECT collapses missing/unauthorized into one sanitized raise (BOOKING_NOT_FOUND); booking-UUID existence is not leaked. Cancels pending reminders and schedules a recovery_checkin (T+7d) atomically with the cancellation.';


CREATE OR REPLACE FUNCTION mark_booking_complete(
  p_booking_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_booking bookings%ROWTYPE;
  v_result  JSONB;
BEGIN
  PERFORM check_rate_limit('mark_booking_complete', 60, 60);

  -- F-P1-3: shop-owner-only. Sanitized raise; booking UUID not echoed.
  SELECT b.* INTO v_booking
  FROM bookings b
  JOIN shops s ON s.id = b.shop_id
  WHERE b.id = p_booking_id
    AND s.user_id = auth.uid()
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501', HINT = 'BOOKING_NOT_FOUND';
  END IF;

  IF v_booking.status NOT IN ('confirmed','completed') THEN
    RAISE EXCEPTION 'cannot complete booking in status %', v_booking.status
      USING ERRCODE = '22023';
  END IF;

  IF v_booking.status <> 'completed' THEN
    UPDATE bookings SET status = 'completed', updated_at = now()
    WHERE  id = p_booking_id;

    INSERT INTO booking_audit_log (actor_id, action, target_table, target_id, details)
    VALUES (auth.uid(), 'booking.complete', 'bookings', p_booking_id,
            jsonb_build_object('from', v_booking.status));

    PERFORM public.cancel_and_followup(p_booking_id, 'completed');
  END IF;

  SELECT to_jsonb(b.*) INTO v_result FROM bookings b WHERE b.id = p_booking_id;
  RETURN v_result;
END;
$$;

COMMENT ON FUNCTION mark_booking_complete(UUID) IS
  'Phase 12: cancel_and_followup wired in inside the status-change branch (re-marking-as-completed remains a no-op). F-P1-3: ownership-gated SELECT collapses missing/unauthorized into one sanitized raise. Cancels pending reminders and schedules a review_request (T+2h).';


CREATE OR REPLACE FUNCTION mark_booking_no_show(
  p_booking_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_booking bookings%ROWTYPE;
  v_result  JSONB;
BEGIN
  PERFORM check_rate_limit('mark_booking_no_show', 60, 60);

  -- F-P1-3: shop-owner-only. Sanitized raise; booking UUID not echoed.
  SELECT b.* INTO v_booking
  FROM bookings b
  JOIN shops s ON s.id = b.shop_id
  WHERE b.id = p_booking_id
    AND s.user_id = auth.uid()
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501', HINT = 'BOOKING_NOT_FOUND';
  END IF;

  IF v_booking.status NOT IN ('confirmed','pending','no_show') THEN
    RAISE EXCEPTION 'cannot no-show booking in status %', v_booking.status
      USING ERRCODE = '22023';
  END IF;

  IF v_booking.start_time > now() THEN
    RAISE EXCEPTION 'cannot mark no-show before the booking start time' USING ERRCODE = '22023';
  END IF;

  IF v_booking.status <> 'no_show' THEN
    UPDATE bookings SET status = 'no_show', updated_at = now()
    WHERE  id = p_booking_id;

    INSERT INTO booking_audit_log (actor_id, action, target_table, target_id, details)
    VALUES (auth.uid(), 'booking.no_show', 'bookings', p_booking_id,
            jsonb_build_object('from', v_booking.status));

    PERFORM public.cancel_and_followup(p_booking_id, 'no_show');
  END IF;

  SELECT to_jsonb(b.*) INTO v_result FROM bookings b WHERE b.id = p_booking_id;
  RETURN v_result;
END;
$$;

COMMENT ON FUNCTION mark_booking_no_show(UUID) IS
  'Phase 12: cancel_and_followup wired in inside the status-change branch (re-marking-as-no_show remains a no-op). F-P1-3: ownership-gated SELECT collapses missing/unauthorized into one sanitized raise. Cancels pending reminders and schedules a recovery_checkin (T+7d).';
