-- Guest order reviews — write path for the /order/[id] inline review form.
--
-- product_reviews originally required user_id NOT NULL. Make it nullable
-- and add guest_profile_id with a CHECK enforcing exactly one of the two,
-- mirroring the same pattern we used for bookings + orders.
--
-- Strategy for a multi-item order: write ONE product_reviews row for the
-- order, attached to the order's first product (by name). The customer
-- rates their ORDER experience; we just store it under one representative
-- product because the schema requires product_id. Avoids confusion of
-- duplicate rows across all products in the order.

ALTER TABLE product_reviews
  ALTER COLUMN user_id DROP NOT NULL,
  ADD COLUMN IF NOT EXISTS guest_profile_id UUID
    REFERENCES guest_profiles(id) ON DELETE SET NULL;

ALTER TABLE product_reviews
  DROP CONSTRAINT IF EXISTS product_reviews_user_or_guest_chk;
ALTER TABLE product_reviews
  ADD CONSTRAINT product_reviews_user_or_guest_chk
  CHECK (
    (user_id IS NOT NULL AND guest_profile_id IS NULL) OR
    (user_id IS NULL     AND guest_profile_id IS NOT NULL)
  );

-- Old UNIQUE (order_id, product_id, user_id) treats NULL user_id as
-- distinct (Postgres standard) so guest rows would slip past. Replace
-- with two partial unique indexes that cover both cases tightly.
ALTER TABLE product_reviews
  DROP CONSTRAINT IF EXISTS product_reviews_order_id_product_id_user_id_key;

CREATE UNIQUE INDEX IF NOT EXISTS product_reviews_user_one_per_order_product
  ON product_reviews (order_id, product_id, user_id)
  WHERE user_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS product_reviews_guest_one_per_order_product
  ON product_reviews (order_id, product_id, guest_profile_id)
  WHERE guest_profile_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS product_reviews_guest_profile_idx
  ON product_reviews (guest_profile_id)
  WHERE guest_profile_id IS NOT NULL;

-- ────────────────────────────────────────────────────────────────────────
-- get_order_review — public lookup of the order-scoped review (if any)
-- ────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION get_order_review(p_order_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_review RECORD;
BEGIN
  SELECT id, rating, comment, shop_response, shop_response_at, created_at, updated_at
    INTO v_review
    FROM product_reviews
   WHERE order_id = p_order_id
   ORDER BY created_at ASC
   LIMIT 1;

  IF v_review.id IS NULL THEN RETURN NULL; END IF;

  RETURN jsonb_build_object(
    'id',               v_review.id,
    'rating',           v_review.rating,
    'comment',          v_review.comment,
    'shop_response',    v_review.shop_response,
    'shop_response_at', v_review.shop_response_at,
    'created_at',       v_review.created_at,
    'updated_at',       v_review.updated_at
  );
END;
$$;

REVOKE ALL ON FUNCTION get_order_review(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION get_order_review(UUID) TO anon, authenticated, service_role;

-- ────────────────────────────────────────────────────────────────────────
-- submit_guest_order_review — write a review for a guest order
-- ────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION submit_guest_order_review(
  p_order_id UUID,
  p_rating   INT,
  p_comment  TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_order      RECORD;
  v_product_id UUID;
  v_existing   RECORD;
  v_new        RECORD;
BEGIN
  IF p_rating < 1 OR p_rating > 5 THEN
    RAISE EXCEPTION 'rating must be between 1 and 5';
  END IF;

  SELECT id, shop_id, status, guest_profile_id, user_id
    INTO v_order
    FROM orders WHERE id = p_order_id;

  IF v_order.id IS NULL THEN
    RAISE EXCEPTION 'order not found';
  END IF;
  IF v_order.guest_profile_id IS NULL THEN
    RAISE EXCEPTION 'this RPC only handles guest orders' USING ERRCODE = '42501';
  END IF;
  IF v_order.status::text <> 'delivered' THEN
    RAISE EXCEPTION 'cannot review a % order', v_order.status::text;
  END IF;

  -- Pick the representative product: first by name. Same choice the
  -- item_summary builder uses, so the review attaches to whatever the
  -- WhatsApp message named.
  SELECT oi.product_id INTO v_product_id
    FROM order_items oi
    LEFT JOIN products p ON p.id = oi.product_id
   WHERE oi.order_id = p_order_id
   ORDER BY COALESCE(p.name, '') ASC
   LIMIT 1;

  IF v_product_id IS NULL THEN
    RAISE EXCEPTION 'order has no items to review';
  END IF;

  -- Idempotency: a second submit returns the existing review.
  SELECT id, rating, comment, created_at INTO v_existing
    FROM product_reviews
   WHERE order_id = p_order_id
     AND product_id = v_product_id
     AND guest_profile_id = v_order.guest_profile_id
   LIMIT 1;

  IF v_existing.id IS NOT NULL THEN
    RETURN jsonb_build_object(
      'id',         v_existing.id,
      'rating',     v_existing.rating,
      'comment',    v_existing.comment,
      'created_at', v_existing.created_at,
      'already_submitted', true
    );
  END IF;

  INSERT INTO product_reviews (
    product_id, order_id, user_id, guest_profile_id, rating, comment
  ) VALUES (
    v_product_id, p_order_id, NULL, v_order.guest_profile_id,
    p_rating, NULLIF(btrim(p_comment), '')
  )
  RETURNING id, rating, comment, created_at INTO v_new;

  RETURN jsonb_build_object(
    'id',         v_new.id,
    'rating',     v_new.rating,
    'comment',    v_new.comment,
    'created_at', v_new.created_at,
    'already_submitted', false
  );
END;
$$;

REVOKE ALL ON FUNCTION submit_guest_order_review(UUID, INT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION submit_guest_order_review(UUID, INT, TEXT) TO anon, authenticated, service_role;
