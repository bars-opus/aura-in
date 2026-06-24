-- Order WhatsApp/push enqueue helper + status-change trigger.
-- Must follow the enum-add migration so the values are committed first.

CREATE OR REPLACE FUNCTION public.enqueue_order_message(
  p_order_id UUID,
  p_type     TEXT
) RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_order        public.orders%ROWTYPE;
  v_shop_name    TEXT;
  v_shop_owner   UUID;
  v_currency_sym TEXT;
  v_total_str    TEXT;
  v_phone        TEXT;
  v_client_name  TEXT;
  v_channel      TEXT;
  v_template     TEXT;
  v_recipient    UUID;
  v_guest_pid    UUID;
  v_url          TEXT;
  v_title        TEXT;
  v_body         TEXT;
  v_params       JSONB;
  v_notif_id     UUID;
BEGIN
  SELECT * INTO v_order FROM public.orders WHERE id = p_order_id;
  IF NOT FOUND THEN RETURN NULL; END IF;

  SELECT shop_name, user_id, currency_symbol
    INTO v_shop_name, v_shop_owner, v_currency_sym
    FROM public.shops WHERE id = v_order.shop_id;

  v_url := 'https://aurain.barsopus.com/order/' || p_order_id::text;
  v_total_str := COALESCE(v_currency_sym, '') ||
                 trim(to_char(v_order.total_amount, 'FM999999990.00'));

  -- Recipient + channel routing
  IF v_order.guest_profile_id IS NOT NULL THEN
    v_recipient := NULL;
    v_guest_pid := v_order.guest_profile_id;
    v_channel   := 'whatsapp';
    v_phone     := COALESCE(v_order.customer_phone,
                            (SELECT phone FROM guest_profiles WHERE id = v_guest_pid));
    v_client_name := COALESCE(
                       (SELECT name FROM guest_profiles WHERE id = v_guest_pid),
                       'there');
    v_template := p_type || '_v1';
  ELSE
    v_recipient := v_order.user_id;
    v_guest_pid := NULL;
    v_channel   := 'push';
    v_template  := NULL;
  END IF;

  -- WhatsApp template params (single shape across all order_* templates):
  --   {1: shop, 2: total, 3: order_url}
  IF v_channel = 'whatsapp' THEN
    v_params := jsonb_build_object(
      '1', COALESCE(v_shop_name, 'Your order'),
      '2', v_total_str,
      '3', v_url
    );
  ELSE
    v_params := NULL;
  END IF;

  -- Per-type push copy (used when delivering via push to logged-in users).
  v_title := CASE p_type
    WHEN 'order_received'         THEN 'Order placed'
    WHEN 'order_confirmed'        THEN 'Order confirmed'
    WHEN 'order_out_for_delivery' THEN 'Out for delivery'
    WHEN 'order_delivered'        THEN 'Delivered'
    WHEN 'order_cancelled'        THEN 'Order cancelled'
    ELSE NULL
  END;

  v_body := CASE p_type
    WHEN 'order_received'         THEN
      'Your order at ' || v_shop_name || ' is received. We''ll confirm shortly.'
    WHEN 'order_confirmed'        THEN
      v_shop_name || ' has confirmed your order. You''ll pay on delivery.'
    WHEN 'order_out_for_delivery' THEN
      'Your order is on the way from ' || v_shop_name || '.'
    WHEN 'order_delivered'        THEN
      'Order from ' || v_shop_name || ' delivered. Tap to leave a review.'
    WHEN 'order_cancelled'        THEN
      'Your order at ' || v_shop_name || ' was cancelled.'
    ELSE NULL
  END;

  INSERT INTO public.scheduled_notifications (
    user_id, guest_profile_id, booking_id, shop_id,
    notification_type, scheduled_for, delivery_channel,
    whatsapp_template, whatsapp_params, status, metadata
  ) VALUES (
    v_recipient,
    v_guest_pid,
    NULL,                                      -- not a booking
    v_order.shop_id,
    p_type::notification_type,
    NOW(),
    v_channel,
    v_template,
    v_params,
    'pending',
    CASE WHEN v_channel = 'whatsapp'
         THEN jsonb_build_object('phone', v_phone, 'order_id', p_order_id, 'shop_name', v_shop_name)
         ELSE jsonb_build_object(
                'title', v_title,
                'body',  v_body,
                'order_id', p_order_id,
                'shop_id',  v_order.shop_id,
                'type', p_type
              )
    END
  )
  RETURNING id INTO v_notif_id;

  RETURN v_notif_id;
END;
$$;

REVOKE ALL ON FUNCTION public.enqueue_order_message(UUID, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.enqueue_order_message(UUID, TEXT) TO service_role;

-- ────────────────────────────────────────────────────────────────────────────
-- Trigger: enqueue the right message on every status transition.
-- ────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.fire_order_status_message()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_type TEXT;
BEGIN
  -- Map new status to message type.
  v_type := CASE NEW.status
    WHEN 'confirmed'        THEN 'order_confirmed'
    WHEN 'out_for_delivery' THEN 'order_out_for_delivery'
    WHEN 'delivered'        THEN 'order_delivered'
    WHEN 'cancelled'        THEN 'order_cancelled'
    ELSE NULL
  END;

  IF v_type IS NULL THEN
    RETURN NEW;
  END IF;

  -- Fire-and-forget; never roll back a status change because of notifications.
  BEGIN
    PERFORM public.enqueue_order_message(NEW.id, v_type);
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'enqueue_order_message % failed for order %: %', v_type, NEW.id, SQLERRM;
  END;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_orders_status_message ON public.orders;
CREATE TRIGGER trg_orders_status_message
  AFTER UPDATE OF status ON public.orders
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION public.fire_order_status_message();
