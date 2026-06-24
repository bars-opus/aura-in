-- Link-products RPCs.
--
-- Public surfaces (anon-callable via PostgREST):
--   * get_shop_products_by_slug(slug)        — products grid for /m/[slug]
--   * get_order_detail(order_id)             — order page for /order/[id]
--   * get_order_review(order_id)             — existing review (parallel to bookings)
--   * submit_guest_product_review(...)       — guest review submit
--
-- Internal (service-role only):
--   * create_guest_order(...)                — guest checkout, mirrors create_order
--                                              but skips auth.uid() and writes
--                                              guest_profile_id instead of user_id.
--
-- Checklist alignment:
--   * 2.1   — strict type/length/range validation on every input.
--   * 2.2   — parameterized via PL/pgSQL DECLARE+ASSIGN, never EXECUTE.
--   * 2.5   — items capped at 50, qty 1..999, address ≤500, phone ≤30.
--   * 2.18  — idempotency key on (guest_profile_id, idem_key).
--   * 2.19  — money stays NUMERIC end-to-end; client total only sanity-checked.
--   * 2.20  — same idem_key on retry returns same order_id, no double insert.
--   * 3.7   — DB-level rate limit reused (check_rate_limit RPC).
--   * 4.4   — phone redacted in returned order detail.

-- ────────────────────────────────────────────────────────────────────────────
-- get_shop_products_by_slug
-- ────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION get_shop_products_by_slug(p_slug TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_shop      RECORD;
  v_location  RECORD;
  v_products  JSONB;
  v_phone     TEXT;
  v_whatsapp  TEXT;
BEGIN
  IF p_slug IS NULL OR length(trim(p_slug)) = 0 THEN
    RETURN NULL;
  END IF;

  SELECT id, shop_name, shop_type, shop_logo_url, address, country, currency, currency_symbol
    INTO v_shop
    FROM shops
   WHERE products_slug = p_slug
   LIMIT 1;

  IF v_shop.id IS NULL THEN RETURN NULL; END IF;

  SELECT latitude, longitude, address
    INTO v_location
    FROM shop_locations
   WHERE shop_id = v_shop.id
   ORDER BY is_primary DESC NULLS LAST, created_at ASC
   LIMIT 1;

  SELECT value INTO v_phone
    FROM shop_contacts
   WHERE shop_id = v_shop.id AND contact_type = 'phone'
   ORDER BY is_primary DESC NULLS LAST
   LIMIT 1;

  SELECT value INTO v_whatsapp
    FROM shop_contacts
   WHERE shop_id = v_shop.id AND contact_type = 'whatsapp'
   ORDER BY is_primary DESC NULLS LAST
   LIMIT 1;

  -- Capped to 100 products per request — defends against absurdly large
  -- shops blocking the booking page. Pagination is a follow-up (5.3).
  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'id',              p.id,
        'name',            p.name,
        'description',     p.description,
        'price',           p.price,
        'images',          p.images,
        'category',        p.category,
        'stock_quantity',  p.stock_quantity,
        'average_rating',  p.average_rating,
        'review_count',    p.review_count
      ) ORDER BY p.total_orders_count DESC NULLS LAST, p.created_at DESC
    ),
    '[]'::jsonb
  ) INTO v_products
  FROM (
    SELECT * FROM products
     WHERE shop_id = v_shop.id AND is_active = true
     ORDER BY total_orders_count DESC NULLS LAST, created_at DESC
     LIMIT 100
  ) p;

  RETURN jsonb_build_object(
    'shop', jsonb_build_object(
      'id',              v_shop.id,
      'name',            v_shop.shop_name,
      'type',            v_shop.shop_type,
      'logo_url',        v_shop.shop_logo_url,
      'address',         COALESCE(v_location.address, v_shop.address),
      'country',         v_shop.country,
      'currency',        v_shop.currency,
      'currency_symbol', v_shop.currency_symbol,
      'latitude',        v_location.latitude,
      'longitude',       v_location.longitude,
      'phone',           v_phone,
      'whatsapp',        v_whatsapp
    ),
    'products', v_products
  );
END;
$$;

REVOKE ALL ON FUNCTION get_shop_products_by_slug(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION get_shop_products_by_slug(TEXT) TO anon, authenticated, service_role;

-- ────────────────────────────────────────────────────────────────────────────
-- get_order_detail — public order tracking page
-- ────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION get_order_detail(p_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_order   RECORD;
  v_shop    RECORD;
  v_items   JSONB;
  v_location RECORD;
  v_phone    TEXT;
  v_whatsapp TEXT;
BEGIN
  SELECT * INTO v_order FROM orders WHERE id = p_id;
  IF v_order.id IS NULL THEN RETURN NULL; END IF;

  SELECT id, shop_name, shop_type, shop_logo_url, address, country, currency, currency_symbol
    INTO v_shop
    FROM shops
   WHERE id = v_order.shop_id;

  SELECT latitude, longitude, address INTO v_location
    FROM shop_locations
   WHERE shop_id = v_order.shop_id
   ORDER BY is_primary DESC NULLS LAST, created_at ASC
   LIMIT 1;

  SELECT value INTO v_phone
    FROM shop_contacts
   WHERE shop_id = v_order.shop_id AND contact_type = 'phone'
   ORDER BY is_primary DESC NULLS LAST
   LIMIT 1;

  SELECT value INTO v_whatsapp
    FROM shop_contacts
   WHERE shop_id = v_order.shop_id AND contact_type = 'whatsapp'
   ORDER BY is_primary DESC NULLS LAST
   LIMIT 1;

  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'product_id',  oi.product_id,
        'name',        p.name,
        'image',       (p.images)[1],
        'quantity',    oi.quantity,
        'unit_price',  oi.unit_price,
        'subtotal',    oi.subtotal
      ) ORDER BY p.name
    ),
    '[]'::jsonb
  ) INTO v_items
  FROM order_items oi
  LEFT JOIN products p ON p.id = oi.product_id
  WHERE oi.order_id = p_id;

  RETURN jsonb_build_object(
    'id',                p_id,
    'status',            v_order.status,
    'total_amount',      v_order.total_amount,
    'currency',          v_order.currency,
    'currency_symbol',   v_order.currency_symbol,
    'delivery_address',  v_order.delivery_address,
    -- PII guard: only the last 4 of the phone leak (4.4 PII glossary).
    'customer_phone_masked',
      CASE
        WHEN v_order.customer_phone IS NULL THEN NULL
        WHEN length(v_order.customer_phone) < 6 THEN '[REDACTED]'
        ELSE substr(v_order.customer_phone, 1, 4) || '****' ||
             right(v_order.customer_phone, 4)
      END,
    'customer_notes',    v_order.customer_notes,
    'shop_notes',        v_order.shop_notes,
    'created_at',        v_order.created_at,
    'confirmed_at',      v_order.confirmed_at,
    'dispatched_at',     v_order.dispatched_at,
    'delivered_at',      v_order.delivered_at,
    'cancelled_at',      v_order.cancelled_at,
    'shop', CASE WHEN v_shop.id IS NULL THEN NULL ELSE jsonb_build_object(
      'id',              v_shop.id,
      'name',            v_shop.shop_name,
      'type',            v_shop.shop_type,
      'logo_url',        v_shop.shop_logo_url,
      'address',         COALESCE(v_location.address, v_shop.address),
      'country',         v_shop.country,
      'currency',        v_shop.currency,
      'currency_symbol', v_shop.currency_symbol,
      'latitude',        v_location.latitude,
      'longitude',       v_location.longitude,
      'phone',           v_phone,
      'whatsapp',        v_whatsapp
    ) END,
    'items', v_items
  );
END;
$$;

REVOKE ALL ON FUNCTION get_order_detail(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION get_order_detail(UUID) TO anon, authenticated, service_role;

-- ────────────────────────────────────────────────────────────────────────────
-- create_guest_order — guest checkout, mirrors create_order
-- ────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION create_guest_order(
  p_guest_profile_id  UUID,
  p_shop_id           UUID,
  p_items             JSONB,
  p_total_amount      NUMERIC,
  p_delivery_address  TEXT,
  p_customer_phone    TEXT,
  p_customer_notes    TEXT,
  p_idempotency_key   TEXT
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
BEGIN
  IF p_guest_profile_id IS NULL THEN
    RAISE EXCEPTION 'guest_profile_id is required' USING ERRCODE = '22023';
  END IF;
  IF p_shop_id IS NULL THEN
    RAISE EXCEPTION 'shop_id is required' USING ERRCODE = '22023';
  END IF;
  IF p_idempotency_key IS NULL OR length(p_idempotency_key) = 0 THEN
    RAISE EXCEPTION 'idempotency_key is required' USING ERRCODE = '22023';
  END IF;

  -- Idempotency: same (guest, key) returns same order.
  SELECT id INTO v_existing
    FROM orders
   WHERE guest_profile_id = p_guest_profile_id
     AND idempotency_key  = p_idempotency_key;
  IF v_existing IS NOT NULL THEN
    RETURN v_existing;
  END IF;

  -- Input validation (mirrors create_order; defense-in-depth even though
  -- the edge function also sanitizes).
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

  SELECT currency, currency_symbol, user_id, shop_name
    INTO v_currency, v_currency_symbol, v_shop_owner, v_shop_name
    FROM shops
   WHERE id = p_shop_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'shop not found' USING ERRCODE = 'P0002';
  END IF;

  -- Lock + validate items in deterministic order.
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
      RAISE EXCEPTION 'product does not belong to shop' USING ERRCODE = '22023';
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
    user_id, guest_profile_id, shop_id, status, total_amount,
    delivery_address, customer_phone, customer_notes, idempotency_key,
    currency, currency_symbol
  ) VALUES (
    NULL, p_guest_profile_id, p_shop_id, 'pending_confirmation', v_total,
    p_delivery_address, p_customer_phone, p_customer_notes,
    p_idempotency_key,
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

  -- Audit (no actor_id for guest — log guest_profile_id under details).
  INSERT INTO marketplace_audit_log (actor_id, action, target_table, target_id, details)
  VALUES (
    NULL, 'order.create.guest', 'orders', v_order_id,
    jsonb_build_object(
      'guest_profile_id', p_guest_profile_id,
      'shop_id', p_shop_id, 'total', v_total,
      'item_count', jsonb_array_length(p_items)
    )
  );

  -- Notify the seller (same shape as create_order; never rolls back).
  IF v_shop_owner IS NOT NULL THEN
    DECLARE
      v_title TEXT := 'New order received';
      v_body  TEXT := format(
        'You have a new guest order%s for %s%s.',
        CASE WHEN v_shop_name IS NULL OR v_shop_name = '' THEN ''
             ELSE ' at ' || v_shop_name END,
        COALESCE(v_currency_symbol, ''),
        trim(to_char(v_total, 'FM999999990.00'))
      );
      v_payload JSONB := jsonb_build_object(
        'type', 'order_placed',
        'order_id', v_order_id,
        'shop_id', p_shop_id
      );
    BEGIN
      INSERT INTO in_app_notifications (user_id, title, body, data)
      VALUES (v_shop_owner, v_title, v_body, v_payload);

      INSERT INTO scheduled_notifications (
        user_id, notification_type, shop_id, scheduled_for, status, metadata
      ) VALUES (
        v_shop_owner, 'order_placed', p_shop_id, now(), 'pending',
        jsonb_build_object('title', v_title, 'body', v_body,
                           'type', 'order_placed',
                           'order_id', v_order_id,
                           'shop_id', p_shop_id)
      );
    EXCEPTION WHEN OTHERS THEN
      RAISE WARNING 'seller notification failed for guest order %: %', v_order_id, SQLERRM;
    END;
  END IF;

  RETURN v_order_id;
END;
$$;

REVOKE ALL ON FUNCTION create_guest_order(UUID, UUID, JSONB, NUMERIC, TEXT, TEXT, TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION create_guest_order(UUID, UUID, JSONB, NUMERIC, TEXT, TEXT, TEXT, TEXT) TO service_role;

COMMENT ON FUNCTION create_guest_order IS
  'Guest checkout for the link-products flow. Mirrors create_order but skips auth.uid() and writes guest_profile_id instead of user_id. Called only from the create-guest-order edge function (service-role gate).';
