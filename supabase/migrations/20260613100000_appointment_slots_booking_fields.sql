-- Migration: extend appointment_slots with booking-control fields
--
-- buffer_before_minutes  — prep/setup time before the service starts
-- is_online_booking_enabled — when false the slot is hidden from the
--   client booking flow (owner can still create manual bookings from
--   the dashboard). Defaults true so existing rows keep current behaviour.

DO $$ BEGIN
  ALTER TABLE appointment_slots ADD COLUMN buffer_before_minutes INT NOT NULL DEFAULT 0;
  EXCEPTION WHEN duplicate_column THEN NULL;
END $$;

DO $$ BEGIN
  ALTER TABLE appointment_slots ADD COLUMN is_online_booking_enabled BOOLEAN NOT NULL DEFAULT true;
  EXCEPTION WHEN duplicate_column THEN NULL;
END $$;

-- Index to make the client-facing slot query fast when filtering by
-- is_online_booking_enabled (most slots will be true, so partial index
-- on false rows keeps it lean).
CREATE INDEX IF NOT EXISTS idx_appointment_slots_online_booking
  ON appointment_slots (shop_id)
  WHERE is_online_booking_enabled = true;

-- Filter the client-facing slot query so disabled services are invisible.
-- The generate_slots RPC reads appointment_slots directly by id (caller
-- passes slot ids), so we gate it at the repository SELECT layer instead.
-- This comment documents the contract: any SELECT that feeds the client
-- booking UI must include  .eq('is_online_booking_enabled', true).
