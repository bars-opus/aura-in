-- Add SHOP columns to booking_simple.
--
-- The view exposed client + service fields but never joined `shops`, so the
-- client calendar card (ClientCalendarBooking.fromJson reads a nested `shop`
-- object) and the BookingDetailScreen's BookingShopInfoCard showed empty shop
-- name / type / logo. supabase_booking_repository.getClientBookings already
-- builds `shop: { shop_name, shop_type, shop_logo_url, ... }` from these
-- columns — they were simply NULL because the view didn't select them.
--
-- DROP first: CREATE OR REPLACE VIEW can't add/reorder columns on an existing
-- view of a different shape.

DROP VIEW IF EXISTS booking_simple CASCADE;

CREATE VIEW booking_simple AS
SELECT
  b.id                          AS booking_id,
  b.shop_id                     AS shop_id,
  b.user_id                     AS user_id,
  b.guest_profile_id            AS guest_profile_id,
  b.start_time                  AS start_time,
  b.end_time                    AS end_time,
  b.actual_end_time             AS actual_end_time,
  b.booking_date                AS booking_date,
  b.status::text                AS status,
  b.payment_status::text        AS payment_status,
  b.payment_method              AS payment_method,
  b.total_amount                AS total_amount,
  b.deposit_amount              AS deposit_amount,
  b.platform_fee                AS platform_fee,
  b.payment_intent_id           AS payment_intent_id,
  b.cancellation_reason         AS cancellation_reason,
  b.cancelled_at                AS cancelled_at,
  b.created_at                  AS booking_created_at,
  b.updated_at                  AS booking_updated_at,
  b.created_at                  AS created_at,
  -- Client identity (logged-in user, else the guest snapshot).
  COALESCE(p.display_name, b.guest_name, 'Guest')   AS client_display_name,
  p.username                                          AS client_username,
  p.avatar_url                                        AS client_avatar_url,
  -- Shop identity — NEW. Drives the client calendar card + shop info card.
  s.shop_name                   AS shop_name,
  s.shop_type                   AS shop_type,
  s.shop_logo_url               AS shop_logo_url,
  s.currency                    AS currency,
  -- Per-service join.
  bs.id                         AS booking_service_id,
  bs.slot_id                    AS service_id,
  bs.service_name               AS service_name,
  bs.worker_id                  AS worker_id,
  bs.worker_name                AS worker_name,
  bs.price_at_booking           AS price_at_booking,
  bs.duration_minutes           AS duration_minutes,
  bs.start_time                 AS service_start_time
FROM bookings b
LEFT JOIN profiles p          ON p.id = b.user_id
LEFT JOIN shops s             ON s.id = b.shop_id
LEFT JOIN booking_services bs ON bs.booking_id = b.id;

GRANT SELECT ON booking_simple TO authenticated, service_role;
