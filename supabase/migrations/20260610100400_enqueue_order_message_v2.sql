-- enqueue_order_message v2:
--   * adds buyer name + item summary as body params
--   * stores the order UUID under reserved key `button_url_suffix` so the
--     scheduler can pass it as a Meta URL-button param (template URL is
--     `https://aurain.barsopus.com/order/{{1}}`, base static).
--
-- New WhatsApp body param shape (4 params):
--   {1: buyer name, 2: item summary, 3: shop name, 4: total}
--
-- Item summary: first product name + " + N more" when multi-item, else
-- just the product name. Falls back to "your items" when nothing resolves
-- (defense: a deleted product shouldn't blank the message).

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
  v_buyer_name   TEXT;
  v_channel      TEXT;
  v_template     TEXT;
  v_recipient    UUID;
  v_guest_pid    UUID;
  v_url          TEXT;
  v_title        TEXT;
  v_body         TEXT;
  v_params       JSONB;
  v_notif_id     UUID;
  v_first_item   TEXT;
  v_item_count   INT;
  v_item_summary TEXT;
BEGIN
  SELECT * INTO v_order FROM public.orders WHERE id = p_order_id;
  IF NOT FOUND THEN RETURN NULL; END IF;

  SELECT shop_name, user_id, currency_symbol
    INTO v_shop_name, v_shop_owner, v_currency_sym
    FROM public.shops WHERE id = v_order.shop_id;

  v_url := 'https://aurain.barsopus.com/order/' || p_order_id::text;
  v_total_str := COALESCE(v_currency_sym, '') ||
                 trim(to_char(v_order.total_amount, 'FM999999990.00'));

  -- Item summary: first product (by name asc for stability) + "+N more".
  -- Joined via products for the name; subquery so we can both pick the
  -- first row and count without a window function on the array.
  SELECT
    (SELECT COALESCE(p.name, 'an item')
       FROM order_items oi
       LEFT JOIN products p ON p.id = oi.product_id
      WHERE oi.order_id = p_order_id
      ORDER BY COALESCE(p.name, '') ASC
      LIMIT 1),
    (SELECT count(*) FROM order_items WHERE order_id = p_order_id)
    INTO v_first_item, v_item_count;

  v_item_summary := CASE
    WHEN v_item_count IS NULL OR v_item_count <= 1 THEN COALESCE(v_first_item, 'your items')
    ELSE COALESCE(v_first_item, 'your items') || ' + ' || (v_item_count - 1)::text || ' more'
  END;

  -- Recipient + channel routing
  IF v_order.guest_profile_id IS NOT NULL THEN
    v_recipient := NULL;
    v_guest_pid := v_order.guest_profile_id;
    v_channel   := 'whatsapp';
    v_phone     := COALESCE(v_order.customer_phone,
                            (SELECT phone FROM guest_profiles WHERE id = v_guest_pid));
    v_buyer_name := COALESCE(
                       (SELECT name FROM guest_profiles WHERE id = v_guest_pid),
                       'there');
    v_template := p_type || '_v1';
  ELSE
    v_recipient := v_order.user_id;
    v_guest_pid := NULL;
    v_channel   := 'push';
    v_template  := NULL;
    SELECT COALESCE(display_name, 'there') INTO v_buyer_name
      FROM profiles WHERE id = v_order.user_id;
  END IF;

  -- WhatsApp template params (4 body + 1 button suffix).
  IF v_channel = 'whatsapp' THEN
    v_params := jsonb_build_object(
      '1', v_buyer_name,
      '2', v_item_summary,
      '3', COALESCE(v_shop_name, 'the shop'),
      '4', v_total_str,
      'button_url_suffix', p_order_id::text
    );
  ELSE
    v_params := NULL;
  END IF;

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
      'Your order of ' || v_item_summary || ' from ' || v_shop_name || ' is received.'
    WHEN 'order_confirmed'        THEN
      v_shop_name || ' confirmed your order of ' || v_item_summary || '. Pay on delivery.'
    WHEN 'order_out_for_delivery' THEN
      'Your order of ' || v_item_summary || ' from ' || v_shop_name || ' is on the way.'
    WHEN 'order_delivered'        THEN
      'Order from ' || v_shop_name || ' delivered. Tap to review.'
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
    NULL,
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
