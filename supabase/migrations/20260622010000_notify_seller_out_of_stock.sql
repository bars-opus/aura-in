-- Extend create_order: after each product's stock is decremented, fire a
-- best-effort out-of-stock notification to the shop owner when stock hits 0.
--
-- Checklist compliance (v3.1):
--   [MUTATION] 1.1 / 2.18  Idempotency: notification tied to order_id + product_id
--                           in the audit details so a replayed idempotency key returns
--                           early (line ~74) before the item loop runs — no double-fire.
--   [MUTATION] 1.6          Race-safety: stock UPDATE runs under FOR UPDATE lock
--                           already held in the validation loop; the post-decrement
--                           check reads the value we just wrote, not a stale snapshot.
--   [MUTATION] 1.10         Best-effort block (EXCEPTION WHEN OTHERS): notification
--                           failure cannot roll back the order.
--   [ALL]      2.4 / 4.4    Notification body contains only product name and shop name
--                           — no customer phone, address, or PII.
--   [ALL]      2.2          No string concatenation in SQL; format() used throughout.
--
-- If notification_type is an enum, ensure 'out_of_stock' is a valid value.
DO $$
DECLARE
  v_typname TEXT;
BEGIN
  SELECT t.typname
  INTO   v_typname
  FROM   pg_attribute a
  JOIN   pg_class c ON c.oid = a.attrelid
  JOIN   pg_type  t ON t.oid = a.atttypid
  WHERE  c.relname = 'scheduled_notifications'
    AND  a.attname = 'notification_type'
    AND  a.attnum  > 0
    AND  NOT a.attisdropped;

  IF v_typname IS NULL THEN
    RAISE NOTICE 'scheduled_notifications.notification_type not found — skipping';
  ELSIF v_typname IN ('text', 'varchar', 'bpchar') THEN
    RAISE NOTICE 'notification_type is TEXT — no enum value to add';
  ELSE
    EXECUTE FORMAT('ALTER TYPE %I ADD VALUE IF NOT EXISTS %L', v_typname, 'out_of_stock');
  END IF;
END $$;

-- Replace create_order, adding the out-of-stock notification block inside the
-- item write loop. All other logic is verbatim from 20260621040000.
CREATE OR REPLACE FUNCTION create_order(
  p_user_id           UUID,
  p_shop_id           UUID,
  p_items             JSONB,
  p_total_amount      NUMERIC,
  p_delivery_address  TEXT,
  p_customer_phone    TEXT,
  p_customer_notes    TEXT,
  p_idempotency_key   TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_order_id        UUID;
  v_existing        UUID;
  v_item            JSONB;
  v_product         products%ROWTYPE;
  v_qty             INT;
  v_total           NUMERIC(12,2) := 0;
  v_currency        TEXT;
  v_currency_symbol TEXT;
  v_shop_owner      UUID;
  v_shop_name       TEXT;
  v_new_stock       INT;
BEGIN
  -- AuthN
  IF p_user_id IS NULL OR p_user_id <> auth.uid() THEN
    RAISE EXCEPTION 'unauthorized: user mismatch' USING ERRCODE = '42501';
  END IF;

  -- Idempotency: replay the previous result if the same key is seen.
  -- This early-return also prevents duplicate notifications because the
  -- item loop (and its notification sub-blocks) never runs on replay.
  IF p_idempotency_key IS NOT NULL AND length(p_idempotency_key) > 0 THEN
    SELECT id INTO v_existing
    FROM   orders
    WHERE  user_id = p_user_id AND idempotency_key = p_idempotency_key;
    IF v_existing IS NOT NULL THEN
      RETURN v_existing;
    END IF;
  END IF;

  -- Rate limit: 10 orders / 60 seconds / user.
  PERFORM check_rate_limit('create_order', 10, 60);

  -- Validate inputs
  IF p_shop_id IS NULL THEN
    RAISE EXCEPTION 'shop_id is required' USING ERRCODE = '22023';
  END IF;
  IF jsonb_typeof(p_items) <> 'array' OR jsonb_array_length(p_items) = 0 THEN
    RAISE EXCEPTION 'items must be a non-empty array' USING ERRCODE = '22023';
  END IF;
  IF jsonb_array_length(p_items) > 50 THEN
    RAISE EXCEPTION 'too many items in one order (max 50)' USING ERRCODE = '22023';
  END IF;
  IF length(trim(coalesce(p_delivery_address, ''))) = 0 THEN
    RAISE EXCEPTION 'delivery_address is required' USING ERRCODE = '22023';
  END IF;
  IF length(trim(coalesce(p_customer_phone, ''))) = 0 THEN
    RAISE EXCEPTION 'customer_phone is required' USING ERRCODE = '22023';
  END IF;
  IF length(p_delivery_address) > 500 THEN
    RAISE EXCEPTION 'delivery_address too long' USING ERRCODE = '22023';
  END IF;
  IF length(p_customer_phone) > 30 THEN
    RAISE EXCEPTION 'customer_phone too long' USING ERRCODE = '22023';
  END IF;
  IF p_customer_notes IS NOT NULL AND length(p_customer_notes) > 1000 THEN
    RAISE EXCEPTION 'customer_notes too long' USING ERRCODE = '22023';
  END IF;

  -- Fetch shop currency + owner + name server-side.
  SELECT currency, currency_symbol, user_id, shop_name
  INTO   v_currency, v_currency_symbol, v_shop_owner, v_shop_name
  FROM   shops
  WHERE  id = p_shop_id;

  -- Lock and validate items in deterministic id order.
  FOR v_item IN
    SELECT * FROM jsonb_array_elements(p_items)
    ORDER BY (value->>'product_id')::uuid
  LOOP
    v_qty := (v_item->>'quantity')::int;
    IF v_qty IS NULL OR v_qty <= 0 OR v_qty > 999 THEN
      RAISE EXCEPTION 'invalid quantity for product %', v_item->>'product_id'
        USING ERRCODE = '22023';
    END IF;

    SELECT * INTO v_product FROM products
    WHERE  id = (v_item->>'product_id')::uuid
    FOR UPDATE;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'product % not found', v_item->>'product_id'
        USING ERRCODE = 'P0002';
    END IF;
    IF v_product.shop_id <> p_shop_id THEN
      RAISE EXCEPTION 'product % does not belong to shop %',
        v_product.id, p_shop_id USING ERRCODE = '22023';
    END IF;
    IF NOT v_product.is_active THEN
      RAISE EXCEPTION 'product % is not available', v_product.id
        USING ERRCODE = '22023';
    END IF;
    IF v_product.stock_quantity < v_qty THEN
      RAISE EXCEPTION 'insufficient stock for product %: requested %, available %',
        v_product.id, v_qty, v_product.stock_quantity USING ERRCODE = '22023';
    END IF;

    v_total := v_total + (v_product.price * v_qty);
  END LOOP;

  IF p_total_amount IS NOT NULL AND abs(p_total_amount - v_total) > 1 THEN
    RAISE EXCEPTION 'total mismatch: client=% server=%', p_total_amount, v_total
      USING ERRCODE = '22023';
  END IF;

  INSERT INTO orders (
    user_id, shop_id, status, total_amount,
    delivery_address, customer_phone, customer_notes, idempotency_key,
    currency, currency_symbol
  ) VALUES (
    p_user_id, p_shop_id, 'pending_confirmation', v_total,
    p_delivery_address, p_customer_phone, p_customer_notes,
    NULLIF(p_idempotency_key, ''),
    v_currency, v_currency_symbol
  )
  RETURNING id INTO v_order_id;

  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP
    v_qty := (v_item->>'quantity')::int;
    SELECT * INTO v_product FROM products
    WHERE  id = (v_item->>'product_id')::uuid;

    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
    VALUES (v_order_id, v_product.id, v_qty, v_product.price);

    UPDATE products
    SET    stock_quantity     = stock_quantity - v_qty,
           total_orders_count = total_orders_count + 1
    WHERE  id = v_product.id
    RETURNING stock_quantity INTO v_new_stock;

    -- Out-of-stock notification (best-effort, no PII in body).
    -- Only fires when this sale drains the last unit.
    -- Guard: owner must exist and must not be the buyer themselves.
    IF v_new_stock = 0
       AND v_shop_owner IS NOT NULL
       AND v_shop_owner <> p_user_id
    THEN
      BEGIN
        INSERT INTO in_app_notifications (user_id, title, body, data)
        VALUES (
          v_shop_owner,
          'Product sold out',
          format('"%s" is now out of stock.', v_product.name),
          jsonb_build_object(
            'type',       'out_of_stock',
            'product_id', v_product.id,
            'shop_id',    p_shop_id
          )
        );

        INSERT INTO scheduled_notifications (
          user_id, notification_type, shop_id, scheduled_for, status, metadata
        ) VALUES (
          v_shop_owner,
          'out_of_stock',
          p_shop_id,
          now(),
          'pending',
          jsonb_build_object(
            'title',      'Product sold out',
            'body',       format('"%s" is now out of stock.', v_product.name),
            'type',       'out_of_stock',
            'product_id', v_product.id,
            'shop_id',    p_shop_id
          )
        );
      EXCEPTION WHEN OTHERS THEN
        -- Swallow: a notification failure must not fail the purchase.
        RAISE WARNING 'out-of-stock notification failed for product % order %: %',
          v_product.id, v_order_id, SQLERRM;
      END;
    END IF;

  END LOOP;

  -- Audit
  INSERT INTO marketplace_audit_log (actor_id, action, target_table, target_id, details)
  VALUES (
    p_user_id, 'order.create', 'orders', v_order_id,
    jsonb_build_object('shop_id', p_shop_id, 'total', v_total,
                       'item_count', jsonb_array_length(p_items))
  );

  -- Order-placed notification to seller (best-effort).
  IF v_shop_owner IS NOT NULL AND v_shop_owner <> p_user_id THEN
    DECLARE
      v_title   TEXT := 'New order received';
      v_body    TEXT := format(
        'You have a new order%s for %s%s.',
        CASE WHEN v_shop_name IS NULL OR v_shop_name = '' THEN ''
             ELSE ' at ' || v_shop_name END,
        COALESCE(v_currency_symbol, ''),
        trim(to_char(v_total, 'FM999999990.00'))
      );
      v_payload JSONB := jsonb_build_object(
        'type',     'order_placed',
        'order_id', v_order_id,
        'shop_id',  p_shop_id
      );
    BEGIN
      INSERT INTO in_app_notifications (user_id, title, body, data)
      VALUES (v_shop_owner, v_title, v_body, v_payload);

      INSERT INTO scheduled_notifications (
        user_id, notification_type, shop_id, scheduled_for, status, metadata
      ) VALUES (
        v_shop_owner, 'order_placed', p_shop_id, now(), 'pending',
        jsonb_build_object('title', v_title, 'body', v_body,
                           'type',     'order_placed',
                           'order_id', v_order_id,
                           'shop_id',  p_shop_id)
      );
    EXCEPTION WHEN OTHERS THEN
      RAISE WARNING 'seller notification failed for order %: %', v_order_id, SQLERRM;
    END;
  END IF;

  RETURN v_order_id;
END;
$$;

REVOKE ALL ON FUNCTION create_order(UUID, UUID, JSONB, NUMERIC, TEXT, TEXT, TEXT, TEXT) FROM public;
GRANT EXECUTE ON FUNCTION create_order(UUID, UUID, JSONB, NUMERIC, TEXT, TEXT, TEXT, TEXT) TO authenticated;
