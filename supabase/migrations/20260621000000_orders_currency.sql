-- supabase/migrations/20260621000000_orders_currency.sql
-- Persist the currency an order was placed in. Sourced server-side from the
-- shop (not the client). Money columns stay NUMERIC; this is additive.

alter table public.orders
  add column if not exists currency text,
  add column if not exists currency_symbol text;

-- Backfill existing orders from their shop.
update public.orders o
  set currency = s.currency,
      currency_symbol = s.currency_symbol
  from public.shops s
  where s.id = o.shop_id and o.currency is null;

-- ── Re-create create_order to source currency from the shop ──────────────────

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
BEGIN
  -- AuthN
  IF p_user_id IS NULL OR p_user_id <> auth.uid() THEN
    RAISE EXCEPTION 'unauthorized: user mismatch' USING ERRCODE = '42501';
  END IF;

  -- Idempotency: replay the previous result if the same key is seen.
  IF p_idempotency_key IS NOT NULL AND length(p_idempotency_key) > 0 THEN
    SELECT id INTO v_existing
    FROM orders
    WHERE user_id = p_user_id AND idempotency_key = p_idempotency_key;
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

  -- Fetch shop currency server-side.
  SELECT currency, currency_symbol
  INTO v_currency, v_currency_symbol
  FROM shops
  WHERE id = p_shop_id;

  -- Lock and validate items in deterministic id order.
  FOR v_item IN
    SELECT * FROM jsonb_array_elements(p_items)
    ORDER BY (value->>'product_id')::uuid
  LOOP
    v_qty := (v_item->>'quantity')::int;
    IF v_qty IS NULL OR v_qty <= 0 OR v_qty > 999 THEN
      RAISE EXCEPTION 'invalid quantity for product %', v_item->>'product_id' USING ERRCODE = '22023';
    END IF;

    SELECT * INTO v_product FROM products
    WHERE id = (v_item->>'product_id')::uuid
    FOR UPDATE;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'product % not found', v_item->>'product_id' USING ERRCODE = 'P0002';
    END IF;
    IF v_product.shop_id <> p_shop_id THEN
      RAISE EXCEPTION 'product % does not belong to shop %', v_product.id, p_shop_id USING ERRCODE = '22023';
    END IF;
    IF NOT v_product.is_active THEN
      RAISE EXCEPTION 'product % is not available', v_product.id USING ERRCODE = '22023';
    END IF;
    IF v_product.stock_quantity < v_qty THEN
      RAISE EXCEPTION 'insufficient stock for product %: requested %, available %',
        v_product.id, v_qty, v_product.stock_quantity USING ERRCODE = '22023';
    END IF;

    v_total := v_total + (v_product.price * v_qty);
  END LOOP;

  IF p_total_amount IS NOT NULL AND abs(p_total_amount - v_total) > 1 THEN
    RAISE EXCEPTION 'total mismatch: client=% server=%', p_total_amount, v_total USING ERRCODE = '22023';
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
    WHERE id = (v_item->>'product_id')::uuid;

    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
    VALUES (v_order_id, v_product.id, v_qty, v_product.price);

    UPDATE products
    SET    stock_quantity     = stock_quantity - v_qty,
           total_orders_count = total_orders_count + 1
    WHERE  id = v_product.id;
  END LOOP;

  -- Audit
  INSERT INTO marketplace_audit_log (actor_id, action, target_table, target_id, details)
  VALUES (
    p_user_id, 'order.create', 'orders', v_order_id,
    jsonb_build_object('shop_id', p_shop_id, 'total', v_total,
                       'item_count', jsonb_array_length(p_items))
  );

  RETURN v_order_id;
END;
$$;

REVOKE ALL ON FUNCTION create_order(UUID, UUID, JSONB, NUMERIC, TEXT, TEXT, TEXT, TEXT) FROM public;
GRANT EXECUTE ON FUNCTION create_order(UUID, UUID, JSONB, NUMERIC, TEXT, TEXT, TEXT, TEXT) TO authenticated;
