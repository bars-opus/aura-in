-- Phase 14: extend notification_type enum with marketing_broadcast.
--
-- Worker code path is notification-type-agnostic (RESEARCH §3) — this
-- enum value alone unblocks marketing_broadcast rows from being inserted
-- into scheduled_notifications. The worker branches on delivery_channel,
-- not notification_type; zero edge function changes required.
--
-- Matches the Phase 12 / 13 pattern: bare ALTER TYPE with IF NOT EXISTS.

ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'marketing_broadcast';
