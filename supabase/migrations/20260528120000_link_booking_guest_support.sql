-- supabase/migrations/20260528120000_link_booking_guest_support.sql
--
-- Schema support for guest (anonymous) bookings via aura-in-web.vercel.app/book/<slug>.
-- All changes are additive and idempotent.
--
-- Freelancers note: "freelancer" is not a separate table; it is workers.is_freelancer.
-- All booking targets are shops. The web layer renders the freelancer flow when the
-- resolved shop has a freelancer worker (queried at resolve time).

-- ────────────────────────────────────────────────────────────────────────────
-- NEW TABLE: guest_profiles
-- Phone-keyed identity for unauthenticated bookers.
-- ────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS guest_profiles (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  phone         text UNIQUE NOT NULL,
  name          text NOT NULL,
  locale        text DEFAULT 'en',
  last_seen_at  timestamptz DEFAULT now(),
  created_at    timestamptz DEFAULT now(),
  updated_at    timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS guest_profiles_phone_idx
  ON guest_profiles (phone);

ALTER TABLE guest_profiles ENABLE ROW LEVEL SECURITY;
-- No policies = no public access. service_role bypasses.

-- ────────────────────────────────────────────────────────────────────────────
-- NEW TABLE: guest_booking_history
-- Compact log of (guest, service, shop) for prefill ordering.
-- ────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS guest_booking_history (
  guest_profile_id uuid REFERENCES guest_profiles(id) ON DELETE CASCADE,
  service_name     text NOT NULL,
  shop_id          uuid,
  booked_at        timestamptz DEFAULT now(),
  PRIMARY KEY (guest_profile_id, booked_at)
);

CREATE INDEX IF NOT EXISTS guest_booking_history_lookup_idx
  ON guest_booking_history (guest_profile_id, booked_at DESC);

ALTER TABLE guest_booking_history ENABLE ROW LEVEL SECURITY;

-- ────────────────────────────────────────────────────────────────────────────
-- EXTEND bookings: guest support + delivery channel + freelancer client address
-- ────────────────────────────────────────────────────────────────────────────
ALTER TABLE bookings ALTER COLUMN user_id DROP NOT NULL;

ALTER TABLE bookings
  ADD COLUMN IF NOT EXISTS guest_profile_id    uuid REFERENCES guest_profiles(id),
  ADD COLUMN IF NOT EXISTS guest_name          text,
  ADD COLUMN IF NOT EXISTS guest_phone         text,
  ADD COLUMN IF NOT EXISTS client_address      text,
  ADD COLUMN IF NOT EXISTS client_address_lat  double precision,
  ADD COLUMN IF NOT EXISTS client_address_lng  double precision,
  ADD COLUMN IF NOT EXISTS delivery_channel    text NOT NULL DEFAULT 'push'
    CHECK (delivery_channel IN ('push', 'whatsapp', 'none'));

-- Enforce: exactly one of user_id or guest_profile_id is non-null.
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'bookings_user_or_guest_chk'
  ) THEN
    ALTER TABLE bookings ADD CONSTRAINT bookings_user_or_guest_chk CHECK (
      (user_id IS NOT NULL AND guest_profile_id IS NULL) OR
      (user_id IS NULL AND guest_profile_id IS NOT NULL)
    );
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS bookings_guest_profile_idx
  ON bookings (guest_profile_id);

-- ────────────────────────────────────────────────────────────────────────────
-- EXTEND shops: cached booking_slug for fast resolve-link lookup.
-- (No freelancers table — all booking targets are shops.)
-- ────────────────────────────────────────────────────────────────────────────
ALTER TABLE shops
  ADD COLUMN IF NOT EXISTS booking_slug text UNIQUE;

-- ────────────────────────────────────────────────────────────────────────────
-- EXTEND scheduled_notifications: delivery channel + WhatsApp template fields
-- + guest reference.
-- ────────────────────────────────────────────────────────────────────────────
ALTER TABLE scheduled_notifications
  ALTER COLUMN user_id DROP NOT NULL,
  ADD COLUMN IF NOT EXISTS guest_profile_id  uuid REFERENCES guest_profiles(id),
  ADD COLUMN IF NOT EXISTS delivery_channel  text NOT NULL DEFAULT 'push'
    CHECK (delivery_channel IN ('push', 'whatsapp')),
  ADD COLUMN IF NOT EXISTS whatsapp_template text,
  ADD COLUMN IF NOT EXISTS whatsapp_params   jsonb;

-- ────────────────────────────────────────────────────────────────────────────
-- EXTEND pending_payments: delivery channel + guest reference.
-- ────────────────────────────────────────────────────────────────────────────
ALTER TABLE pending_payments
  ADD COLUMN IF NOT EXISTS delivery_channel  text NOT NULL DEFAULT 'push'
    CHECK (delivery_channel IN ('push', 'whatsapp')),
  ADD COLUMN IF NOT EXISTS guest_profile_id  uuid REFERENCES guest_profiles(id);
