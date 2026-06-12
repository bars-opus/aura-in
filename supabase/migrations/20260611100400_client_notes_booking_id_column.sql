-- Phase 16 Wave 1 Task 1.4 — Add client_notes.booking_id column (AMEND-2).
--
-- Forward-compatible nullable column. Phase 12 retention RPCs are NOT
-- modified — they continue upserting on (shop_id, client_identity) and
-- leave booking_id NULL. Phase 16's generate_daily_report consumes this
-- column for the no_show_no_action follow-up rule.

ALTER TABLE public.client_notes
  ADD COLUMN IF NOT EXISTS booking_id UUID NULL
  REFERENCES public.bookings(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_client_notes_booking_id
  ON public.client_notes (booking_id)
  WHERE booking_id IS NOT NULL;

COMMENT ON COLUMN public.client_notes.booking_id IS
  'Phase 16: optional linkage to the booking this note was logged against. NULL preserved by Phase 12 retention RPCs (they upsert on shop_id/client_identity and never set booking_id). Phase 16''s generate_daily_report uses this column to compute the no_show_no_action follow-up reason: a no_show booking is flagged for follow-up iff NO client_notes row exists with booking_id = bookings.id.';
