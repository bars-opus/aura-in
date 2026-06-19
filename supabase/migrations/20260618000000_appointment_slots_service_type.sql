-- Add service_type and description to appointment_slots.
-- service_type holds the style/variant (e.g. "Low Fade", "Balayage").
-- description is an optional freetext blurb shown to clients.
DO $$ BEGIN
  ALTER TABLE appointment_slots ADD COLUMN service_type TEXT;
EXCEPTION WHEN duplicate_column THEN NULL; END $$;

DO $$ BEGIN
  ALTER TABLE appointment_slots ADD COLUMN description TEXT;
EXCEPTION WHEN duplicate_column THEN NULL; END $$;
