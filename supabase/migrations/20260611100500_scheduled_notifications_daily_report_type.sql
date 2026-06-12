-- Phase 16 Wave 1 Task 1.5 — Extend notification_type enum for 'daily_report'.
--
-- Pre-flight (Task 1.0) confirmed notification_type is a real PG enum type
-- (precedent: 20260605130000_add_phase12_notification_types.sql adds
-- 'rebook_nudge', 'review_request', 'recovery_checkin'; Phase 14 adds
-- 'marketing_broadcast'). Phase 16 follows the same one-line pattern.
--
-- Note: ALTER TYPE ... ADD VALUE cannot run inside a transaction block,
-- and Supabase migrations are auto-wrapped in a transaction. The
-- IF NOT EXISTS clause + Supabase's `supabase db push` handles this
-- correctly (the migration is committed before the next migration starts).

ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'daily_report';
