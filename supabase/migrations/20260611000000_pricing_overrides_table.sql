-- Phase 15: pricing_overrides — owner-authored per-slot price-adjustment rules.
-- Applied at slot generation time by generate_available_slots. Snapshot-safe:
-- booking_services.price_at_booking captures the actually-charged price at
-- booking instant, so override edits never retroactively re-price history.
--
-- day_of_week LOCKED to 1..7 (Mon=1..Sun=7) matching shop_opening_hours.
-- The Phase 15 generate_available_slots patch switches EXTRACT(DOW) to
-- EXTRACT(ISODOW) so Sunday bookings finally work — see RESEARCH §3.

CREATE TABLE IF NOT EXISTS public.pricing_overrides (
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slot_id              UUID NOT NULL
                         REFERENCES public.appointment_slots(id) ON DELETE CASCADE,
  name                 TEXT NOT NULL CHECK (char_length(name) BETWEEN 1 AND 80),
  day_of_week          INT  NULL
                         CHECK (day_of_week IS NULL OR day_of_week BETWEEN 1 AND 7),
  time_window_start    TIME NOT NULL,
  time_window_end      TIME NOT NULL,
  adjustment_kind      TEXT NOT NULL CHECK (adjustment_kind IN
                         ('percent_discount','percent_surcharge',
                          'fixed_discount','fixed_surcharge')),
  adjustment_value     NUMERIC(12,2) NOT NULL CHECK (adjustment_value > 0),
  valid_from           TIMESTAMPTZ NOT NULL DEFAULT now(),
  valid_until          TIMESTAMPTZ NULL,
  is_active            BOOLEAN NOT NULL DEFAULT TRUE,
  archived_at          TIMESTAMPTZ NULL,
  created_by_user_id   UUID NOT NULL REFERENCES auth.users(id),
  created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Reject midnight-crossing windows. SPEC + planner brief locked.
  CONSTRAINT pricing_overrides_window_ordered
    CHECK (time_window_end > time_window_start),

  -- Percent values cap at 100. 100% discount → free; that's allowed.
  -- Surcharges beyond 100% are NOT allowed at the schema level.
  CONSTRAINT pricing_overrides_percent_range CHECK (
    adjustment_kind NOT IN ('percent_discount','percent_surcharge')
    OR adjustment_value BETWEEN 0.01 AND 100
  ),

  -- valid_until must not precede valid_from (NULL is OK = no expiry).
  CONSTRAINT pricing_overrides_validity_ordered CHECK (
    valid_until IS NULL OR valid_until > valid_from
  )
);

-- Hot-path index: generate_available_slots filters on
--   slot_id IN (...) AND is_active AND archived_at IS NULL
-- A partial index on (slot_id) pre-prunes inactive / archived rows.
CREATE INDEX IF NOT EXISTS idx_pricing_overrides_active_slot
  ON public.pricing_overrides (slot_id)
  WHERE is_active = TRUE AND archived_at IS NULL;

ALTER TABLE public.pricing_overrides ENABLE ROW LEVEL SECURITY;

-- SELECT-only RLS for owners via slot → shop chain. INSERT/UPDATE/DELETE flow
-- through SECURITY DEFINER RPCs. Mirrors Phase 14 broadcasts pattern + Phase 11
-- archive_appointment_slot pattern.
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies
                 WHERE policyname = 'pricing_overrides_owner_select') THEN
    CREATE POLICY pricing_overrides_owner_select ON public.pricing_overrides
      FOR SELECT TO authenticated
      USING (EXISTS (
        SELECT 1 FROM public.appointment_slots s
        JOIN public.shops sh ON sh.id = s.shop_id
        WHERE s.id = pricing_overrides.slot_id
          AND sh.user_id = auth.uid()
      ));
  END IF;
END $$;

-- Deliberately NO INSERT / UPDATE / DELETE policies. Absence on an
-- RLS-enabled table = deny-all for `authenticated`. All mutations route
-- through create_pricing_override / update_pricing_override /
-- archive_pricing_override (SECURITY DEFINER, bypasses RLS).
-- Pattern verified against broadcasts (Phase 14) + client_notes (Phase 12).

COMMENT ON TABLE public.pricing_overrides IS
  'Phase 15: per-(slot, day_of_week, time_window) price-adjustment rules. Applied at slot generation time by generate_available_slots. Snapshot-safe — price_at_booking continues to capture the actually-charged price at booking instant. Archived via archived_at (mirrors Phase 11 archive pattern). day_of_week 1..7 (Mon=1..Sun=7) — Phase 15 also fixes the latent EXTRACT(DOW) bug by switching to EXTRACT(ISODOW).';

COMMENT ON COLUMN public.pricing_overrides.day_of_week IS
  '1=Monday .. 7=Sunday matching ISO 8601 and shop_opening_hours.day_of_week. NULL = applies to every day of the week within the valid_from/valid_until window.';

COMMENT ON COLUMN public.pricing_overrides.adjustment_kind IS
  'Four enums: percent_discount (0..100% off), percent_surcharge (0..100% extra), fixed_discount (currency amount off, clamps at 0), fixed_surcharge (currency amount extra). Currency is the parent shops.currency (same convention as Phase 13 promotions.discount_value).';

COMMENT ON COLUMN public.pricing_overrides.archived_at IS
  'Soft-delete tombstone. When non-NULL, the override is dormant — generate_available_slots filters it out via the partial index. Phase 15 owner UI only Archive (no hard delete).';
