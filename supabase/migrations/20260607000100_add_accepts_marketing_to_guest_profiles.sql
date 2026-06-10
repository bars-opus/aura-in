-- Phase 14: per-guest marketing opt-out flag.
--
-- Defaults TRUE so existing guests are opted-in retroactively. Phase 14
-- reads this in send_broadcast / preview_broadcast_audience to exclude
-- opted-out guests from broadcast fan-out.
--
-- The "STOP reply flips flag" worker behavior is OUT of Phase 14 scope —
-- documented as a follow-up phase. v1 opt-out is platform-mediated only.

ALTER TABLE public.guest_profiles
  ADD COLUMN IF NOT EXISTS accepts_marketing BOOLEAN NOT NULL DEFAULT TRUE;

COMMENT ON COLUMN public.guest_profiles.accepts_marketing IS
  'Per-guest marketing opt-out flag. Defaults TRUE on first booking. Phase 14 reads this in send_broadcast / preview_broadcast_audience to exclude opted-out guests from fan-out. STOP-reply worker behavior is a follow-up phase (out of Phase 14 scope).';
