-- Public review RPCs for the /r/[id] web page reachable from the WhatsApp
-- review prompt. The bookings RLS already restricts SELECT/INSERT on
-- booking_reviews to authenticated users, so guests have no way to leave
-- a review of their own booking without these helpers.
--
-- Both functions are SECURITY DEFINER scoped to a single booking UUID
-- (not enumerable in practice). get_booking_review returns NULL when
-- no review exists yet; submit_guest_review enforces idempotency by
-- letting the existing review row stand on a second submit.

CREATE OR REPLACE FUNCTION get_booking_review(p_booking_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_review RECORD;
BEGIN
  SELECT id, rating, review, shop_response, responded_at, created_at, updated_at
    INTO v_review
    FROM booking_reviews
   WHERE booking_id = p_booking_id
   LIMIT 1;

  IF v_review.id IS NULL THEN RETURN NULL; END IF;

  RETURN jsonb_build_object(
    'id',            v_review.id,
    'rating',        v_review.rating,
    'review',        v_review.review,
    'shop_response', v_review.shop_response,
    'responded_at',  v_review.responded_at,
    'created_at',    v_review.created_at,
    'updated_at',    v_review.updated_at
  );
END;
$$;

REVOKE ALL ON FUNCTION get_booking_review(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION get_booking_review(UUID) TO anon, authenticated, service_role;

CREATE OR REPLACE FUNCTION submit_guest_review(
  p_booking_id UUID,
  p_rating     INT,
  p_review     TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_booking  RECORD;
  v_existing RECORD;
  v_new      RECORD;
BEGIN
  IF p_rating < 1 OR p_rating > 5 THEN
    RAISE EXCEPTION 'rating must be between 1 and 5';
  END IF;

  SELECT id, shop_id, user_id, guest_profile_id, status
    INTO v_booking
    FROM bookings
   WHERE id = p_booking_id;

  IF v_booking.id IS NULL THEN
    RAISE EXCEPTION 'booking not found';
  END IF;

  IF v_booking.status::text NOT IN ('confirmed', 'completed') THEN
    RAISE EXCEPTION 'cannot review a % booking', v_booking.status::text;
  END IF;

  -- Idempotency: only one review per booking. Return the existing one on
  -- a second submit (covers guests tapping the WhatsApp link twice).
  SELECT id, rating, review, created_at INTO v_existing
    FROM booking_reviews
   WHERE booking_id = p_booking_id
   LIMIT 1;

  IF v_existing.id IS NOT NULL THEN
    RETURN jsonb_build_object(
      'id',         v_existing.id,
      'rating',     v_existing.rating,
      'review',     v_existing.review,
      'created_at', v_existing.created_at,
      'already_submitted', true
    );
  END IF;

  INSERT INTO booking_reviews (
    booking_id, user_id, shop_id, rating, review, created_at, updated_at
  ) VALUES (
    p_booking_id,
    v_booking.user_id,         -- NULL for guest bookings; column must allow NULL
    v_booking.shop_id,
    p_rating,
    NULLIF(btrim(p_review), ''),
    NOW(), NOW()
  )
  RETURNING id, rating, review, created_at INTO v_new;

  RETURN jsonb_build_object(
    'id',         v_new.id,
    'rating',     v_new.rating,
    'review',     v_new.review,
    'created_at', v_new.created_at,
    'already_submitted', false
  );
END;
$$;

REVOKE ALL ON FUNCTION submit_guest_review(UUID, INT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION submit_guest_review(UUID, INT, TEXT) TO anon, authenticated, service_role;
