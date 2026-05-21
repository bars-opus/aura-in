# Withdrawal Retry Queue — Design Spec

**Date:** 2026-05-21
**Status:** Approved — ready for implementation planning
**Scope:** Phase 3, item 2 of 4 (withdrawal retry queue).

---

## Problem

When `process-withdrawal/index.ts` invokes `provider.processPayout(...)` and the provider returns a transient failure (network blip, 5xx, rate limit), the adapter retries 3 times internally via `retryFetch`. If all 3 attempts exhaust within ~7 seconds, the withdrawal is marked `failed` and the wallet is refunded immediately. Provider outages that last minutes or hours (common in practice) result in permanent failure even though the next attempt would have succeeded.

Need: a longer-horizon retry queue with backoff measured in minutes/hours, and a `dead_letter` state for permanently-failed transient withdrawals that need human review (as distinct from `failed`, which means a definitive business error like "destination account invalid").

## Goals

1. Transient provider failures retry over a ~9-hour window with exponential backoff before giving up.
2. Wallet stays debited (not refunded) while a withdrawal is in `retrying`. Refund happens only on terminal outcomes (`failed` or `dead_letter`).
3. Operator can see dead-lettered withdrawals via the existing `payment_audit_log` table.
4. No new infrastructure components — reuse `pg_cron`, `pg_net.http_post`, and the existing `INTERNAL_WEBHOOK_SECRET`.
5. Retries are idempotent at the provider — same `idempotency_key` reused; Paystack `reference` and Stripe `Idempotency-Key` header handle deduplication.

## Non-Goals

- Operator admin UI for dead-letter queue (manual DB query for now).
- Shop owner dead-letter banner in Flutter (deferred to Phase 3 item 3 — UX polish).
- Slack / email alerts on dead-letter (deferred — SMTP infra not yet configured).
- Manual recovery RPC (`manual_resolve_dead_letter`) — operator runs direct SQL for now.
- Queue health metrics / Prometheus / dashboards.

---

## Locked Decisions

| # | Decision | Rationale |
|---|---|---|
| 1 | Extend `withdrawal_requests` with new states `retrying` and `dead_letter`; add columns `attempt_count`, `next_attempt_at`, `last_error`, `dead_letter_reason` | No new tables; retry state is a property of the withdrawal |
| 2 | 1 initial attempt + 5 retry intervals: +1min, +5min, +30min, +2h, +6h (~9h elapsed before dead-letter) | Catches the common transient blip (~1min) and the multi-hour provider outage without dragging on for days. `attempt_count` tracks retries (starts at 0, increments to 5 before dead-letter). |
| 3 | `pg_cron` polls every minute for due retries, fires `pg_net.http_post` to `process-withdrawal` | Matches existing pattern (`expire_stale_pending_payments`); 60s poll jitter is invisible against minute-scale waits |
| 4 | Dead-letter notification via `notifications` table row + `payment_audit_log` entry | Reuses existing tables; no new infra; operator monitors via SQL |
| 5 | Same `idempotency_key` across all retry attempts | Paystack and Stripe both treat their idempotency primitives as deduplicating — adapter handles "already exists" gracefully |

---

## Design

### Schema (new migration)

`supabase/migrations/20260521000000_withdrawal_retry_queue.sql`

```sql
-- Extend status enum
ALTER TABLE withdrawal_requests
  DROP CONSTRAINT IF EXISTS withdrawal_requests_status_check;

ALTER TABLE withdrawal_requests
  ADD CONSTRAINT withdrawal_requests_status_check
  CHECK (status IN (
    'pending', 'processing', 'completed',
    'retrying',     -- transient failure, will be retried
    'dead_letter',  -- retries exhausted, needs manual review
    'failed',       -- permanent business failure (bad account, declined, etc.)
    'refunded'
  ));

ALTER TABLE withdrawal_requests
  ADD COLUMN IF NOT EXISTS attempt_count       INT NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS next_attempt_at     TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS last_error          TEXT,
  ADD COLUMN IF NOT EXISTS dead_letter_reason  TEXT;

CREATE INDEX IF NOT EXISTS withdrawal_requests_due_retries_idx
  ON withdrawal_requests (next_attempt_at)
  WHERE status = 'retrying';
```

### New RPCs

```sql
-- Transition pending|processing|retrying → retrying with bumped attempt count
CREATE OR REPLACE FUNCTION schedule_withdrawal_retry(
  p_withdrawal_id     UUID,
  p_next_attempt_at   TIMESTAMPTZ,
  p_last_error        TEXT
) RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  UPDATE withdrawal_requests
  SET status          = 'retrying',
      attempt_count   = attempt_count + 1,
      next_attempt_at = p_next_attempt_at,
      last_error      = p_last_error,
      updated_at      = now()
  WHERE id = p_withdrawal_id
    AND status IN ('pending','processing','retrying');
END $$;

-- Transition retrying|processing → dead_letter, refund wallet
CREATE OR REPLACE FUNCTION dead_letter_withdrawal(
  p_withdrawal_id   UUID,
  p_reason          TEXT
) RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_shop_id UUID;
  v_amount  NUMERIC;
BEGIN
  UPDATE withdrawal_requests
  SET status              = 'dead_letter',
      dead_letter_reason  = p_reason,
      updated_at          = now()
  WHERE id = p_withdrawal_id
    AND status IN ('retrying','processing')
  RETURNING shop_id, amount INTO v_shop_id, v_amount;

  IF v_shop_id IS NOT NULL THEN
    UPDATE wallets
    SET balance              = balance + v_amount,
        pending_withdrawals  = pending_withdrawals - v_amount,
        updated_at           = now()
    WHERE shop_id = v_shop_id;
  END IF;
END $$;
```

### Cron jobs

```sql
-- Find due retries, set back to 'pending', invoke process-withdrawal
CREATE OR REPLACE FUNCTION trigger_due_withdrawal_retries()
RETURNS INT LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_rec        RECORD;
  v_count      INT := 0;
  v_function_url   TEXT := current_setting('app.settings.process_withdrawal_url', true);
  v_webhook_secret TEXT := current_setting('app.settings.internal_webhook_secret', true);
BEGIN
  IF v_function_url IS NULL OR v_webhook_secret IS NULL THEN
    RAISE WARNING 'trigger_due_withdrawal_retries: missing app.settings configuration';
    RETURN 0;
  END IF;

  FOR v_rec IN
    SELECT id FROM withdrawal_requests
    WHERE status = 'retrying'
      AND next_attempt_at <= now()
    LIMIT 20   -- cap per-tick fan-out
  LOOP
    UPDATE withdrawal_requests
    SET status = 'pending', updated_at = now()
    WHERE id = v_rec.id AND status = 'retrying';

    PERFORM net.http_post(
      url     := v_function_url,
      headers := jsonb_build_object(
        'Content-Type',  'application/json',
        'Authorization', 'Bearer ' || v_webhook_secret
      ),
      body    := jsonb_build_object('withdrawal_id', v_rec.id)
    );
    v_count := v_count + 1;
  END LOOP;

  RETURN v_count;
END $$;

-- Recover from network failures between cron and process-withdrawal
CREATE OR REPLACE FUNCTION sweep_stuck_pending_withdrawals()
RETURNS INT LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE v_count INT;
BEGIN
  WITH bumped AS (
    UPDATE withdrawal_requests
    SET status          = 'retrying',
        next_attempt_at = now() + interval '1 minute',
        last_error      = COALESCE(last_error, 'stuck in pending — sweep recovered'),
        updated_at      = now()
    WHERE status = 'pending'
      AND attempt_count > 0
      AND updated_at < now() - interval '5 minutes'
    RETURNING 1
  )
  SELECT count(*) INTO v_count FROM bumped;
  RETURN v_count;
END $$;

SELECT cron.schedule('withdrawal-retry-tick', '* * * * *',
  $$SELECT trigger_due_withdrawal_retries();$$);

SELECT cron.schedule('withdrawal-stuck-sweep', '*/5 * * * *',
  $$SELECT sweep_stuck_pending_withdrawals();$$);
```

### Required GUC configuration

Before deploying the migration, set these PostgreSQL settings (one-time, via Supabase dashboard SQL editor):

```sql
ALTER DATABASE postgres SET app.settings.process_withdrawal_url =
  'https://<project-ref>.supabase.co/functions/v1/process-withdrawal';
ALTER DATABASE postgres SET app.settings.internal_webhook_secret =
  '<value of INTERNAL_WEBHOOK_SECRET edge env>';
```

If the cron job runs before these are set, `trigger_due_withdrawal_retries` logs a warning and returns 0 (no harm done).

### `process-withdrawal` changes

Two edits to `supabase/functions/process-withdrawal/index.ts`:

1. **Backoff schedule constant + helpers** (`nextAttemptAt`, `scheduleWithdrawalRetry`, `deadLetterWithdrawal`, `sendDeadLetterNotification`) added near the existing `completeWithdrawal` / `failWithdrawal` helpers.

2. **Catch block in `processWithdrawal()`** restructured to branch on error type:
   - `PaymentProviderError` with `retryable=true` + `attempt_count < 5` → `scheduleWithdrawalRetry`, audit `withdrawal.retry_scheduled`.
   - `PaymentProviderError` with `retryable=true` + `attempt_count >= 5` → `deadLetterWithdrawal`, audit `withdrawal.dead_letter`, send dead-letter notification.
   - Non-retryable `PaymentProviderError` OR any other error → existing `failWithdrawal` path (refund immediately).

Backoff schedule:
```ts
const BACKOFF_SCHEDULE_SECONDS = [60, 300, 1800, 7200, 21600];
//                               1m   5m   30m   2h    6h
```

No other handler changes. The status guard (`if (withdrawal.status !== 'pending')`) at the top of `processWithdrawal` is unchanged — the cron resets `status='pending'` before invoking, so retries reuse the existing happy path.

---

## State machine

```
   ┌─────────┐
   │ pending │ ← (initial state, or reset by retry cron)
   └────┬────┘
        │ status guard passes
        ▼
   ┌──────────────┐
   │  processing  │
   └──────┬───────┘
          │
          ├──── processPayout success ──────▶ ┌────────────┐
          │                                    │ completed  │
          │                                    └────────────┘
          │
          ├──── PaymentProviderError(retryable=true) ──┐
          │                                              │
          │                                              ▼
          │           attempt_count < 5 ?    ┌──────────────────┐
          │           ┌─────────────────────▶│    retrying      │ ──┐
          │           │                       │ next_attempt_at  │   │ cron
          │           │                       └──────────────────┘   │ resets
          │           │                                                │ to
          │           ▼ no                                            │ pending
          │     ┌──────────────┐                                       │
          │     │ dead_letter  │  + refund wallet                      │
          │     │ +reason      │                                       │
          │     └──────────────┘                                       │
          │                                                            │
          └──── PaymentProviderError(retryable=false)   ┌──────────┐  │
                OR any other Error              ─────▶  │ failed   │  │
                                                         │ +refund  │  │
                                                         └──────────┘  │
                                                                       │
                  ◀──────────────────────────────────────────────────── ┘
```

`refunded` remains a terminal state reachable from manual operator action (e.g. converting a `dead_letter` to a final refund after investigation).

---

## Operational verification

After deploy:

1. **Trigger a transient retry** — temporarily set `PAYSTACK_SECRET_KEY` to garbage, request a small Paystack withdrawal. Verify:
   - Withdrawal moves to `retrying` (not `failed`).
   - `attempt_count=1`, `next_attempt_at` ~1 minute in the future.
   - Wallet NOT refunded.
   - `payment_audit_log` has `withdrawal.retry_scheduled` entry.
2. **Wait for retry** — restore correct key. Within ~1 minute, the cron picks it up and completes the withdrawal.
3. **Trigger dead-letter** — leave key garbage for ~10 hours OR manually set `attempt_count=5` and `next_attempt_at=now()`. After the next cron tick + failure:
   - Withdrawal moves to `dead_letter`.
   - Wallet refunded.
   - Shop owner gets a `notifications` row.
   - `payment_audit_log` has `withdrawal.dead_letter` entry.
4. **Stuck-sweep** — manually `UPDATE withdrawal_requests SET status='pending', attempt_count=1, updated_at=now()-interval '10 minutes' WHERE id=...`. Within 5 minutes the sweep moves it back to `retrying`.

---

## Out of scope

- Operator admin UI for dead-letter queue (manual SQL queries for now).
- Shop owner dead-letter banner — deferred to Phase 3 item 3 (UX polish).
- Slack/email alerts on dead-letter — deferred until SMTP setup.
- Manual recovery RPC — operator uses direct SQL to convert `dead_letter` to `refunded` or `completed` after investigation.
- Queue metrics / dashboards — `SELECT count(*) FROM withdrawal_requests GROUP BY status` suffices.

## Risks

- **Cron lag during heavy queue depth.** With `LIMIT 20` per minute, a queue of 1000 due retries drains in 50 minutes. If sustained queue depth becomes an issue, raise the cap or shorten the cron interval. Mitigation: monitor `SELECT count(*) FROM withdrawal_requests WHERE status='retrying' AND next_attempt_at < now() - interval '5 minutes'`.
- **GUC misconfiguration silently disables retries.** If `app.settings.process_withdrawal_url` is unset, the cron returns 0 and logs a warning per minute. Rows pile up in `retrying`. Mitigation: include a verification query in the deploy runbook.
- **Provider that reports "already exists" on retry but with different status.** If Paystack/Stripe returns a stale "already pending" instead of the actual current state, the adapter may misclassify. Mitigation: adapters' "already exists" handling needs to fetch fresh status, not trust the duplicate-detection response. Out of scope for THIS work — verify when implementing.
