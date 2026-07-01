-- Backfill a shops row for every existing freelancer that doesn't have one.
--
-- Root cause: the freelancer creation flow inserted into workers + freelancer_details
-- but never into shops. The create-booking edge function does:
--   from('shops').eq('id', shopId).single()
-- using the worker id as shopId — so it returned "Shop not found" for every
-- freelancer booking, and the Paystack WebView never launched.
--
-- Going forward the Flutter repo now inserts the shops row on creation.
-- This migration covers the existing workers.

INSERT INTO shops (
  id,
  user_id,
  shop_name,
  shop_type,
  currency,
  currency_symbol,
  verified,
  average_rating,
  number_clients_worked,
  created_at,
  updated_at
)
SELECT
  w.id,
  w.user_id,
  COALESCE(w.name, 'Freelancer'),
  COALESCE(w.freelancer_type, 'freelancer'),
  'GHS',
  '₵',
  false,
  COALESCE(fd.rating, 0),
  COALESCE(fd.total_bookings, 0),
  w.created_at,
  NOW()
FROM workers w
LEFT JOIN freelancer_details fd ON fd.worker_id = w.id
WHERE w.is_freelancer = true
  AND NOT EXISTS (
    SELECT 1 FROM shops s WHERE s.id = w.id
  );
