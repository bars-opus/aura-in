# Account Lifecycle Runbook

## Purpose
Account deactivation, pending deletion, restoration, and finalization are app-level profile states. Supabase auth users are kept as tombstones so historical bookings, orders, withdrawals, and audits are not cascade-deleted.

## Invariants
- `deactivated` and `pending_delete` accounts are hidden from public profile, shop, worker, product, and booking-link surfaces.
- `request_account_deletion` is idempotent while the account is already `pending_delete`; retries must not extend `deletion_scheduled_for`.
- Deactivate/delete require a recent sign-in, currently `auth.users.last_sign_in_at` within 10 minutes.
- Optional account action reasons are capped at 1000 characters.
- `account_lifecycle_audit_log` is append-only and records actor, target, outcome, before state, after state, and context.

## Failure Modes
- `recent_auth_required`: ask the user to sign out and sign in again before retrying.
- `active_obligations`: user must resolve active bookings, orders, withdrawals, or owned-shop obligations.
- `invalid_input`: reason or confirmation payload exceeded server limits.
- `deleted`: account has passed finalization and cannot be restored.

## Operational Checks
- Query `public.account_lifecycle_daily_metrics` for spikes in denied or failed events.
- Check `public.account_lifecycle_audit_log` by `target_user_id` for a user's exact lifecycle history.
- If `pg_cron` is unavailable, schedule `SELECT public.finalize_due_account_deletions();` externally once per day.

## Smoke Tests
Run `supabase/tests/account_lifecycle_hardening.sql` against staging with the required psql variables after each migration or production rollback rehearsal.

## Rollback
Preferred rollback is a follow-up migration, not manual table edits:
- Recreate previous RPC bodies if a new server contract breaks.
- Keep `account_lifecycle_audit_log` intact; never truncate audit history.
- If finalization scheduling misbehaves, disable the cron job first:
  `SELECT cron.unschedule('finalize-due-account-deletions');`
