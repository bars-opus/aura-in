-- Bump enqueue_booking_reminder to v2 reminder templates with the URL param.
--
-- Two bugs in the original (20260605130400):
--   1. Reminder body params were {1: client_name, 2: shop_name} but the
--      approved templates (v1 and v2 alike) expect {1: shop, 2: time, …}.
--      No reminder message would have rendered correctly even on v1.
--   2. Template suffix was hardcoded to "_v1"; we want booking_reminder_*
--      to use _v2 (with the booking URL as {{3}}). Other categories
--      (rebook_nudge, review_request, recovery_checkin) stay on _v1
--      because we haven't submitted v2 versions of those.
--
-- v2 template bodies (Meta-approved 2026-06):
--   booking_reminder_24h_v2: "Reminder: your booking at {{1}} is tomorrow at {{2}}. View details: {{3}}"
--   booking_reminder_2h_v2 : "Heads up: your appointment at {{1}} is in 2 hours, at {{2}}. View details: {{3}}"

CREATE OR REPLACE FUNCTION public.enqueue_booking_reminder(
  p_booking_id    UUID,
  p_type          notification_type,
  p_scheduled_for TIMESTAMPTZ
) RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
DECLARE
  v_booking     public.bookings%ROWTYPE;
  v_shop_name   TEXT;
  v_client_name TEXT;
  v_phone       TEXT;
  v_template    TEXT;
  v_channel     TEXT;
  v_notif_id    UUID;
  v_title       TEXT;
  v_body        TEXT;
  v_params      JSONB;
  v_booking_url TEXT;
  v_time_str    TEXT;
BEGIN
  SELECT * INTO v_booking FROM public.bookings WHERE id = p_booking_id;
  IF NOT FOUND THEN RETURN NULL; END IF;

  SELECT sh.shop_name INTO v_shop_name FROM public.shops sh WHERE sh.id = v_booking.shop_id;

  v_booking_url := 'https://aurain.barsopus.com/booking/' || p_booking_id::text;
  v_time_str := to_char(v_booking.start_time AT TIME ZONE 'UTC', 'FMHH12:MIam');

  -- Channel branch: user_id → push, guest_profile_id → WhatsApp.
  IF v_booking.user_id IS NOT NULL THEN
    v_channel  := 'push';
    v_template := NULL;
  ELSE
    v_channel := 'whatsapp';
    v_phone   := COALESCE(v_booking.guest_phone,
                          (SELECT gp.phone FROM public.guest_profiles gp
                            WHERE gp.id = v_booking.guest_profile_id));
    v_client_name := COALESCE(v_booking.guest_name,
                              (SELECT gp.name FROM public.guest_profiles gp
                                WHERE gp.id = v_booking.guest_profile_id),
                              'there');
    -- Booking reminders use v2 (with URL); other categories stay on v1.
    v_template := CASE
      WHEN p_type IN ('booking_reminder_24h', 'booking_reminder_2h')
        THEN p_type::text || '_v2'
      ELSE p_type::text || '_v1'
    END;
  END IF;

  -- Per-category WhatsApp params. Must match each template's {{N}} order.
  v_params := CASE
    WHEN v_channel <> 'whatsapp' THEN NULL
    WHEN p_type = 'booking_reminder_24h' THEN
      jsonb_build_object('1', v_shop_name, '2', v_time_str, '3', v_booking_url)
    WHEN p_type = 'booking_reminder_2h' THEN
      jsonb_build_object('1', v_shop_name, '2', v_time_str, '3', v_booking_url)
    -- v1 fallbacks for rebook_nudge / review_request / recovery_checkin:
    -- existing shapes (we didn't change those templates).
    ELSE jsonb_build_object('1', v_client_name, '2', v_shop_name)
  END;

  -- Per-category copy (RESEARCH §10).
  v_title := CASE p_type
    WHEN 'booking_reminder_24h' THEN 'Appointment tomorrow'
    WHEN 'booking_reminder_2h'  THEN 'Appointment in 2 hours'
    WHEN 'rebook_nudge'         THEN 'Time for your next visit?'
    WHEN 'review_request'       THEN 'How was your visit?'
    WHEN 'recovery_checkin'     THEN 'We''d love to see you again'
    ELSE NULL
  END;

  v_body := CASE p_type
    WHEN 'booking_reminder_24h' THEN
      'Your appointment at ' || v_shop_name || ' is tomorrow.'
    WHEN 'booking_reminder_2h'  THEN
      'Your appointment at ' || v_shop_name || ' starts in 2 hours.'
    WHEN 'rebook_nudge'         THEN
      'It''s been a while since your last visit to ' || v_shop_name || '. Book again whenever you''re ready.'
    WHEN 'review_request'       THEN
      'Thanks for visiting ' || v_shop_name || '. Tap to leave a rating — takes 5 seconds.'
    WHEN 'recovery_checkin'     THEN
      'We noticed your last appointment at ' || v_shop_name || ' didn''t happen. Book a new time whenever works for you.'
    ELSE NULL
  END;

  INSERT INTO public.scheduled_notifications (
    user_id, guest_profile_id, booking_id, shop_id,
    notification_type, scheduled_for, delivery_channel,
    whatsapp_template, whatsapp_params, status, metadata
  ) VALUES (
    v_booking.user_id,
    v_booking.guest_profile_id,
    p_booking_id,
    v_booking.shop_id,
    p_type,
    p_scheduled_for,
    v_channel,
    v_template,
    v_params,
    'pending',
    CASE WHEN v_channel = 'whatsapp'
         THEN jsonb_build_object('phone', v_phone, 'booking_id', p_booking_id, 'shop_name', v_shop_name)
         ELSE jsonb_build_object('title', v_title, 'body', v_body, 'booking_id', p_booking_id, 'shop_name', v_shop_name)
    END
  )
  RETURNING id INTO v_notif_id;

  RETURN v_notif_id;
END;
$function$;

REVOKE ALL ON FUNCTION public.enqueue_booking_reminder(UUID, notification_type, TIMESTAMPTZ) FROM PUBLIC;
