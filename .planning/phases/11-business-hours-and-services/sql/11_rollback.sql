-- Phase 11 emergency rollback
-- Run ONLY if migrations cause a regression in prod.
-- Safe to run partially — each block is independent.
--
-- The migrations are:
--   20260605000050 — adds archived_at column      (REVERSIBLE)
--   20260605000100 — adds rebuild_shop_opening_hours RPC (REVERSIBLE, pure additive)
--   20260605000200 — adds archive_appointment_slot RPC   (REVERSIBLE, pure additive)
--   20260605000300 — rewrites 3 booking RPCs to filter   (REVERSIBLE — restore prior bodies)
--
-- For 50/100/200: drop the new artifacts (no data loss).
-- For 300: restoring requires having the OLD RPC bodies. The prior bodies
--   live at supabase/migrations/20260517020000_booking_hardening.sql.
--   Copy them verbatim into a new migration named e.g. 20260606_revert_300.sql
--   and run that — DO NOT manually CREATE OR REPLACE here unless you have
--   the exact pre-300 source open.

BEGIN;

-- === Step A: drop the two new RPCs (safe, additive only) ===
DROP FUNCTION IF EXISTS public.rebuild_shop_opening_hours(UUID, JSONB);
DROP FUNCTION IF EXISTS public.archive_appointment_slot(UUID);

-- === Step B: restore the 3 booking RPCs from their pre-Phase-11 bodies ===
-- !!! DO NOT execute this section unless you have copied the bodies from
-- !!! 20260517020000_booking_hardening.sql verbatim. Leave the section
-- !!! commented and either ship a revert migration via `supabase db push`
-- !!! or paste the original bodies inline before uncommenting.
--
-- CREATE OR REPLACE FUNCTION public.create_booking_with_conflict_check(...) ...
-- CREATE OR REPLACE FUNCTION public.check_slot_availability(...) ...
-- CREATE OR REPLACE FUNCTION public.generate_available_slots(...) ...

-- === Step C: drop the archived_at column (LAST — data destructive in one direction) ===
-- This drops the soft-delete column. Any rows already archived become unarchived
-- (visible again to booking flows). Only run if you're certain no production
-- archives have happened yet, OR you've exported the archived_at values first.
--
-- ALTER TABLE public.appointment_slots DROP COLUMN IF EXISTS archived_at;

COMMIT;
