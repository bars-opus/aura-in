# Withdrawal Retry Queue — Operator Runbook

This runbook covers the post-migration setup for the withdrawal retry queue
introduced by `20260521000000_withdrawal_retry_queue.sql`. The migration defines
the SQL functions; this runbook configures the GUCs and schedules the cron jobs.

See `docs/superpowers/specs/2026-05-21-withdrawal-retry-queue-design.md` for
the full design.

---

## 1. Apply the migration

```bash
supabase db push
```

If `pg_cron` or `pg_net` aren't enabled, enable them via the Supabase dashboard
(Database → Extensions). The migration's `CREATE EXTENSION IF NOT EXISTS` is a
no-op in environments where superuser is required for extensions.

---

## 2. Set the GUCs (one-time, per environment)

Run in the Supabase SQL editor (NOT in a migration — these are environment-specific):

```sql
ALTER DATABASE postgres SET app.settings.process_withdrawal_url =
  'https://<project-ref>.supabase.co/functions/v1/process-withdrawal';

ALTER DATABASE postgres SET app.settings.internal_webhook_secret =
  '<value of INTERNAL_WEBHOOK_SECRET edge env>';
```

Replace `<project-ref>` with your Supabase project ref. `<value of INTERNAL_WEBHOOK_SECRET>`
is the same secret the edge function expects in the `Authorization: Bearer ...` header.

Verify:

```sql
SELECT current_setting('app.settings.process_withdrawal_url', true);
SELECT current_setting('app.settings.internal_webhook_secret', true);
```

Both should return non-NULL. If either returns NULL, the cron job will log a
warning and return 0 — no retries will fire.

---

## 3. Schedule the cron jobs

```sql
-- Every minute: pick up due retries and re-invoke process-withdrawal
SELECT cron.schedule(
  'withdrawal-retry-tick',
  '* * * * *',
  $$SELECT trigger_due_withdrawal_retries();$$
);

-- Every 5 minutes: recover withdrawals stuck in 'pending' due to lost cron→edge calls
SELECT cron.schedule(
  'withdrawal-stuck-sweep',
  '*/5 * * * *',
  $$SELECT sweep_stuck_pending_withdrawals();$$
);
```

Verify the schedules exist:

```sql
SELECT jobid, jobname, schedule FROM cron.job
WHERE jobname IN ('withdrawal-retry-tick', 'withdrawal-stuck-sweep');
```

Expected: 2 rows.

---

## 4. Deploy the edge function

```bash
supabase functions deploy process-withdrawal
```

---

## 5. Smoke-test the retry path

**Trigger a transient failure** by temporarily setting `PAYSTACK_SECRET_KEY` (or
`STRIPE_SECRET_KEY`) to a garbage value:

```bash
supabase secrets set PAYSTACK_SECRET_KEY=sk_invalid_for_testing
```

Request a small withdrawal (e.g. GHS 50) from the app. Within 30 seconds:

```sql
SELECT id, status, attempt_count, next_attempt_at, last_error
FROM withdrawal_requests
WHERE id = '<the_withdrawal_id>';
```

Expected:
- `status = 'retrying'` (NOT `'failed'`)
- `attempt_count = 1`
- `next_attempt_at ≈ now() + 1 minute`
- `last_error` populated with the provider error

**Restore the key:**

```bash
supabase secrets set PAYSTACK_SECRET_KEY=<real_key>
```

Within the next minute, the cron should pick up the row and the retry should
succeed. Verify:

```sql
SELECT id, status, attempt_count
FROM withdrawal_requests WHERE id = '<the_withdrawal_id>';
```

Expected: `status = 'completed'`, `attempt_count = 1` (the retry counter
stops incrementing on success).

---

## 6. Smoke-test the dead-letter path

Force-exhaust retries on a withdrawal:

```sql
UPDATE withdrawal_requests
SET attempt_count = 5,
    next_attempt_at = now(),
    status = 'retrying'
WHERE id = '<test_withdrawal_id>';
```

Keep `PAYSTACK_SECRET_KEY` invalid so the next attempt fails. Within ~2 minutes:

```sql
SELECT status, dead_letter_reason FROM withdrawal_requests
WHERE id = '<test_withdrawal_id>';
```

Expected:
- `status = 'dead_letter'`
- `dead_letter_reason = 'exhausted 5 retries: ...'`

Wallet should also be refunded:

```sql
SELECT balance, pending_withdrawals FROM wallets
WHERE shop_id = '<shop_id>';
```

A `notifications` row for the shop owner:

```sql
SELECT title, body FROM notifications
WHERE user_id = '<shop_owner_id>'
  AND type = 'withdrawal_dead_letter'
ORDER BY created_at DESC LIMIT 1;
```

Expected: title "Withdrawal Needs Review".

Audit-log entry:

```sql
SELECT action, outcome, context FROM payment_audit_log
WHERE action = 'withdrawal.dead_letter'
ORDER BY created_at DESC LIMIT 1;
```

---

## 7. Queue health monitoring

Current queue depth:

```sql
SELECT status, count(*) FROM withdrawal_requests
GROUP BY status ORDER BY status;
```

Retries due soon (next 5 minutes):

```sql
SELECT id, attempt_count, next_attempt_at, last_error
FROM withdrawal_requests
WHERE status = 'retrying'
  AND next_attempt_at <= now() + interval '5 minutes'
ORDER BY next_attempt_at;
```

Stuck rows (should always be 0 — sweep recovers them within 5 minutes):

```sql
SELECT count(*) FROM withdrawal_requests
WHERE status = 'pending'
  AND attempt_count > 0
  AND updated_at < now() - interval '10 minutes';
```

Recent dead-letters (operator queue):

```sql
SELECT id, shop_id, amount, dead_letter_reason, updated_at
FROM withdrawal_requests
WHERE status = 'dead_letter'
ORDER BY updated_at DESC LIMIT 20;
```

---

## 8. Manual recovery from `dead_letter`

After investigating a dead-lettered withdrawal:

- **If the provider actually succeeded** (transfer landed, our ack was lost):
  ```sql
  UPDATE withdrawal_requests
  SET status = 'completed',
      provider_transfer_id = '<actual_provider_id>',
      updated_at = now()
  WHERE id = '<withdrawal_id>';
  -- Manually re-debit the wallet since dead_letter refunded it:
  UPDATE wallets
  SET balance = balance - <amount>,
      total_withdrawn = total_withdrawn + <amount>,
      updated_at = now()
  WHERE shop_id = '<shop_id>';
  ```

- **If the provider never processed the transfer** (genuine failure, refund is correct):
  ```sql
  UPDATE withdrawal_requests
  SET status = 'refunded', updated_at = now()
  WHERE id = '<withdrawal_id>';
  -- Wallet already refunded by dead_letter_withdrawal — no further action.
  ```

Always record the manual action in `payment_audit_log`:

```sql
SELECT record_payment_audit(
  'withdrawal.manual_resolve',
  '<operator_user_id>',
  '<shop_id>',
  '<withdrawal_id>',
  'success',
  jsonb_build_object(
    'resolution', 'completed_via_manual',
    'note', 'Verified with Paystack support that transfer 1234 landed'
  )
);
```

---

## 9. Rollback

If the retry queue causes problems, you can disable it without dropping the schema:

```sql
SELECT cron.unschedule('withdrawal-retry-tick');
SELECT cron.unschedule('withdrawal-stuck-sweep');
```

`retrying` rows will sit indefinitely; `dead_letter` rows are inert. To convert
all `retrying` back to `failed` (forcing immediate refund):

```sql
-- One-shot: drain retry queue to failed (refunds wallets via fail_withdrawal RPC)
DO $$
DECLARE r RECORD;
BEGIN
  FOR r IN SELECT id FROM withdrawal_requests WHERE status = 'retrying' LOOP
    PERFORM fail_withdrawal(r.id, 'retry queue disabled — drained to failed');
  END LOOP;
END $$;
```
