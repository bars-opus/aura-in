-- Phase 16 Wave 1 Task 1.1 — Add shops.timezone column (LD-1).
--
-- Per-shop IANA timezone. Loads the daily-report dispatcher (Wave 2) and
-- becomes load-bearing for any future timestamp-aware feature. Default
-- 'Africa/Accra' covers the current shop base; no owner-facing editor in
-- Phase 16 (deferred per SPEC § Out of scope).
--
-- The CHECK constraint validates IANA name shape (no spaces; length sane)
-- without trying to enforce the full IANA registry — Postgres validates
-- the value at AT TIME ZONE time and raises if invalid, which is a
-- defense-in-depth backstop.

ALTER TABLE public.shops
  ADD COLUMN IF NOT EXISTS timezone TEXT NOT NULL DEFAULT 'Africa/Accra';

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conrelid = 'public.shops'::regclass
      AND conname = 'shops_timezone_iana_shape'
  ) THEN
    ALTER TABLE public.shops
      ADD CONSTRAINT shops_timezone_iana_shape
      CHECK (length(timezone) BETWEEN 3 AND 64 AND timezone !~ ' ');
  END IF;
END $$;

COMMENT ON COLUMN public.shops.timezone IS
  'IANA timezone (e.g. Africa/Accra, Asia/Kolkata, Europe/London). Default Africa/Accra. Phase 16 dispatcher fires the daily-report cron at 22:30 in this zone. DST: 22:30 is never inside a DST transition window, so the dispatcher''s ±7.5 min slot is robust across spring-forward and fall-back. Owner-facing editor deferred; Phase 16 ships with default only.';
