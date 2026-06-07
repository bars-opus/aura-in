-- Extend get_booking_detail with shop coordinates + contacts so the
-- /booking/[id] web page can offer "Open in Maps" and "Call shop"
-- actions, matching the affordances clients have in the mobile app.
--
-- Joins:
--   * shop_locations (primary row only) → latitude/longitude
--   * shop_contacts (phone + whatsapp, primary first) → phone CTAs
--
-- Email is intentionally omitted from the public payload — clients don't
-- need it to act, and exposing it would let the page be scraped for
-- shop email lists.

CREATE OR REPLACE FUNCTION get_booking_detail(p_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_booking   RECORD;
  v_shop      RECORD;
  v_location  RECORD;
  v_services  JSONB;
  v_phone     TEXT;
  v_whatsapp  TEXT;
BEGIN
  SELECT * INTO v_booking FROM bookings WHERE id = p_id AND status = 'confirmed' LIMIT 1;
  IF v_booking.id IS NULL THEN RETURN NULL; END IF;

  SELECT shop_name, shop_type, shop_logo_url, address, country
    INTO v_shop
    FROM shops
   WHERE id = v_booking.shop_id;

  -- Coordinates: prefer the row flagged is_primary, fall back to any.
  SELECT latitude, longitude, address
    INTO v_location
    FROM shop_locations
   WHERE shop_id = v_booking.shop_id
   ORDER BY is_primary DESC NULLS LAST, created_at ASC
   LIMIT 1;

  -- Contact numbers. shop_contacts has rows per (type, value) — pick the
  -- primary one for each type if multiple exist.
  SELECT value INTO v_phone
    FROM shop_contacts
   WHERE shop_id = v_booking.shop_id AND contact_type = 'phone'
   ORDER BY is_primary DESC NULLS LAST
   LIMIT 1;

  SELECT value INTO v_whatsapp
    FROM shop_contacts
   WHERE shop_id = v_booking.shop_id AND contact_type = 'whatsapp'
   ORDER BY is_primary DESC NULLS LAST
   LIMIT 1;

  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'name', bs.service_name,
        'duration_minutes', bs.duration_minutes,
        'price', bs.price_at_booking,
        'worker_name', bs.worker_name,
        'start_time', bs.start_time
      ) ORDER BY bs.start_time NULLS LAST
    ),
    '[]'::jsonb
  ) INTO v_services
  FROM booking_services bs
  WHERE bs.booking_id = p_id;

  RETURN jsonb_build_object(
    'id',              v_booking.id,
    'status',          v_booking.status::text,
    'start_time',      v_booking.start_time,
    'end_time',        v_booking.end_time,
    'total_amount',    v_booking.total_amount,
    'deposit_amount',  v_booking.deposit_amount,
    'platform_fee',    v_booking.platform_fee,
    'guest_name',      v_booking.guest_name,
    'guest_phone_masked',
      CASE
        WHEN v_booking.guest_phone IS NULL THEN NULL
        WHEN length(v_booking.guest_phone) < 6 THEN '[REDACTED]'
        ELSE substr(v_booking.guest_phone, 1, 4) ||
             '****' ||
             right(v_booking.guest_phone, 4)
      END,
    'client_address',  v_booking.client_address,
    'shop', CASE WHEN v_shop.shop_name IS NULL THEN NULL ELSE jsonb_build_object(
      'name',      v_shop.shop_name,
      'type',      v_shop.shop_type,
      'logo_url',  v_shop.shop_logo_url,
      -- Prefer the more-detailed location address; fall back to shops.address.
      'address',   COALESCE(v_location.address, v_shop.address),
      'country',   v_shop.country,
      'latitude',  v_location.latitude,
      'longitude', v_location.longitude,
      'phone',     v_phone,
      'whatsapp',  v_whatsapp
    ) END,
    'services', v_services
  );
END;
$$;
