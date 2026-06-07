-- Ship 2 part B: client 5-min WhatsApp reminder.
--
-- Routes booking_reminder_5min through the existing
-- enqueue_booking_reminder helper. Same param shape as the 24h/2h
-- v2 templates so callers don't need a new branch.
--
-- The trigger now enqueues five reminders per confirmed booking:
--   * 24h client WhatsApp (or push for registered users)
--   *  2h client WhatsApp (or push)
--   *  5min client WhatsApp (or push)            <-- NEW
--   * 30min shop-owner push
--   *  5min shop-owner push
--
-- Each is gated by "appointment is still that far in the future" so a
-- booking made 1h before the appointment correctly schedules only the
-- 5-min client + 30/5-min owner rows.

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
  v_shop_owner  UUID;
  v_client_name TEXT;
  v_phone       TEXT;
  v_template    TEXT;
  v_channel     TEXT;
  v_recipient   UUID;
  v_notif_id    UUID;
  v_title       TEXT;
  v_body        TEXT;
  v_params      JSONB;
  v_booking_url TEXT;
  v_time_str    TEXT;
  v_is_owner    BOOLEAN;
BEGIN
  IF p_scheduled_for < NOW() - INTERVAL '10 minutes' THEN
    RETURN NULL;
  END IF;

  SELECT * INTO v_booking FROM public.bookings WHERE id = p_booking_id;
  IF NOT FOUND THEN RETURN NULL; END IF;

  SELECT sh.shop_name, sh.user_id INTO v_shop_name, v_shop_owner
    FROM public.shops sh WHERE sh.id = v_booking.shop_id;

  v_is_owner := p_type::text IN ('booking_owner_30min', 'booking_owner_5min');
  v_booking_url := 'https://aurain.barsopus.com/booking/' || p_booking_id::text;
  v_time_str := to_char(v_booking.start_time AT TIME ZONE 'UTC', 'FMHH12:MIam');

  IF v_is_owner THEN
    v_recipient := v_shop_owner;
    v_channel   := 'push';
    v_template  := NULL;
    IF v_recipient IS NULL THEN RETURN NULL; END IF;
  ELSIF v_booking.user_id IS NOT NULL THEN
    v_recipient := v_booking.user_id;
    v_channel   := 'push';
    v_template  := NULL;
  ELSE
    v_channel := 'whatsapp';
    v_phone   := COALESCE(v_booking.guest_phone,
                          (SELECT gp.phone FROM public.guest_profiles gp
                            WHERE gp.id = v_booking.guest_profile_id));
    v_client_name := COALESCE(v_booking.guest_name,
                              (SELECT gp.name FROM public.guest_profiles gp
                                WHERE gp.id = v_booking.guest_profile_id),
                              'there');
    v_template := CASE
      WHEN p_type::text IN (
        'booking_reminder_24h',
        'booking_reminder_2h',
        'booking_reminder_5min'
      ) THEN p_type::text || '_v2'
      ELSE p_type::text || '_v1'
    END;
  END IF;

  v_params := CASE
    WHEN v_channel <> 'whatsapp' THEN NULL
    WHEN p_type::text IN (
      'booking_reminder_24h',
      'booking_reminder_2h',
      'booking_reminder_5min'
    ) THEN
      jsonb_build_object('1', v_shop_name, '2', v_time_str, '3', v_booking_url)
    ELSE jsonb_build_object('1', v_client_name, '2', v_shop_name)
  END;

  v_title := CASE p_type::text
    WHEN 'booking_reminder_24h'  THEN 'Appointment tomorrow'
    WHEN 'booking_reminder_2h'   THEN 'Appointment in 2 hours'
    WHEN 'booking_reminder_5min' THEN 'Appointment in 5 minutes'
    WHEN 'booking_owner_30min'   THEN 'Next appointment in 30 min'
    WHEN 'booking_owner_5min'    THEN 'Next appointment in 5 min'
    WHEN 'rebook_nudge'          THEN 'Time for your next visit?'
    WHEN 'review_request'        THEN 'How was your visit?'
    WHEN 'recovery_checkin'      THEN 'We''d love to see you again'
    ELSE NULL
  END;

  v_body := CASE p_type::text
    WHEN 'booking_reminder_24h'  THEN
      'Your appointment at ' || v_shop_name || ' is tomorrow.'
    WHEN 'booking_reminder_2h'   THEN
      'Your appointment at ' || v_shop_name || ' starts in 2 hours.'
    WHEN 'booking_reminder_5min' THEN
      'Your appointment at ' || v_shop_name || ' starts in 5 minutes.'
    WHEN 'booking_owner_30min'   THEN
      COALESCE(v_booking.guest_name,
               (SELECT p.display_name FROM profiles p WHERE p.id = v_booking.user_id),
               'A client')
      || ' arrives at ' || v_time_str || '. Tap to view.'
    WHEN 'booking_owner_5min'    THEN
      COALESCE(v_booking.guest_name,
               (SELECT p.display_name FROM profiles p WHERE p.id = v_booking.user_id),
               'A client')
      || ' arrives in 5 minutes (' || v_time_str || ').'
    WHEN 'rebook_nudge'          THEN
      'It''s been a while since your last visit to ' || v_shop_name || '. Book again whenever you''re ready.'
    WHEN 'review_request'        THEN
      'Thanks for visiting ' || v_shop_name || '. Tap to leave a rating — takes 5 seconds.'
    WHEN 'recovery_checkin'      THEN
      'We noticed your last appointment at ' || v_shop_name || ' didn''t happen. Book a new time whenever works for you.'
    ELSE NULL
  END;

  INSERT INTO public.scheduled_notifications (
    user_id, guest_profile_id, booking_id, shop_id,
    notification_type, scheduled_for, delivery_channel,
    whatsapp_template, whatsapp_params, status, metadata
  ) VALUES (
    v_recipient,
    CASE WHEN v_is_owner THEN NULL ELSE v_booking.guest_profile_id END,
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
         ELSE jsonb_build_object(
                'title', v_title,
                'body',  v_body,
                'booking_id', p_booking_id,
                'shop_name',  v_shop_name,
                'shop_id',    v_booking.shop_id,
                'type',       p_type::text
              )
    END
  )
  RETURNING id INTO v_notif_id;

  RETURN v_notif_id;
END;
$function$;

-- Extend the trigger to enqueue the client 5-min reminder.
CREATE OR REPLACE FUNCTION public.schedule_booking_reminders()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_temp
AS $function$
BEGIN
  IF TG_OP = 'UPDATE' AND OLD.status = 'confirmed' THEN
    RETURN NEW;
  END IF;

  IF NEW.start_time <= now() THEN
    RETURN NEW;
  END IF;

  -- Client reminders ----------------------------------------------------
  IF NEW.start_time > now() + INTERVAL '24 hours' THEN
    PERFORM public.enqueue_booking_reminder(
      NEW.id, 'booking_reminder_24h',
      NEW.start_time - INTERVAL '24 hours'
    );
  END IF;

  IF NEW.start_time > now() + INTERVAL '2 hours' THEN
    PERFORM public.enqueue_booking_reminder(
      NEW.id, 'booking_reminder_2h',
      NEW.start_time - INTERVAL '2 hours'
    );
  END IF;

  IF NEW.start_time > now() + INTERVAL '5 minutes' THEN
    PERFORM public.enqueue_booking_reminder(
      NEW.id, 'booking_reminder_5min',
      NEW.start_time - INTERVAL '5 minutes'
    );
  END IF;

  -- Shop-owner reminders ------------------------------------------------
  IF NEW.start_time > now() + INTERVAL '30 minutes' THEN
    PERFORM public.enqueue_booking_reminder(
      NEW.id, 'booking_owner_30min',
      NEW.start_time - INTERVAL '30 minutes'
    );
  END IF;

  IF NEW.start_time > now() + INTERVAL '5 minutes' THEN
    PERFORM public.enqueue_booking_reminder(
      NEW.id, 'booking_owner_5min',
      NEW.start_time - INTERVAL '5 minutes'
    );
  END IF;

  RETURN NEW;
END;
$function$;
