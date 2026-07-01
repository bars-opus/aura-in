-- Backfill shops.shop_logo_url for freelancers whose shops row was created
-- by the previous migration (20260630130000) which did not set shop_logo_url.
--
-- The canonical image lives in workers.profile_image_url. We copy it to
-- shops.shop_logo_url so that booking_simple (which joins shops) can return
-- it in the shop_logo_url column used by ClientCalendarBooking and
-- BookingShopInfoCard.

UPDATE shops s
SET
  shop_logo_url = w.profile_image_url,
  updated_at    = NOW()
FROM workers w
WHERE s.id = w.id
  AND w.is_freelancer = true
  AND w.profile_image_url IS NOT NULL
  AND (s.shop_logo_url IS NULL OR s.shop_logo_url = '');
