# Withdrawal Retry Queue Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transient withdrawal payout failures retry over a ~9-hour window with exponential backoff; permanently failed transient retries land in a `dead_letter` state for operator review instead of immediately refunding.

**Architecture:** Extend `withdrawal_requests` with `retrying` and `dead_letter` states plus retry-tracking columns. A `pg_cron` job polls every minute for due retries and re-invokes `process-withdrawal` via `pg_net.http_post`. The edge function's catch block branches on `PaymentProviderError.retryable` to decide retry-vs-terminal. Wallet refund deferred until terminal outcome.

**Tech Stack:** PostgreSQL + pg_cron + pg_net (Supabase extensions), Deno (TypeScript) edge functions, existing `_shared/audit.ts` and `_shared/providers/port.ts` from Phase 3.1.

---

## File Structure

**New files:**
- `supabase/migrations/20260521000000_withdrawal_retry_queue.sql` — schema extension + 4 SQL functions
- `docs/runbooks/withdrawal-retry-queue.md` — operator runbook (GUC setup, cron scheduling, verification queries)

**Modified files:**
- `supabase/functions/process-withdrawal/index.ts` — add 4 helper functions, restructure catch block to branch on `retryable`

---

## Caveats baked into this plan

- **Deno is not installed locally.** Steps that would normally run `deno test`/`deno check` are written as "skip and note" — the validation falls back to operator smoke tests after deploy.
- **`pg_cron` and `pg_net` are assumed enabled** per the spec. If they aren't, `supabase db push` will fail clearly and the runbook (Task 3) covers enabling them.
- **The current inner catch block in `processWithdrawal` (lines 133–138) re-throws `PaymentProviderError` as a plain `Error`, losing the `retryable` flag.** Task 2 fixes this — without the fix, the outer catch can't decide retry-vs-terminal.

---

# Task 1: Migration — schema, RPCs, cron functions

**Files:**
- Create: `supabase/migrations/20260521000000_withdrawal_retry_queue.sql`

- [ ] **Step 1: Create the migration file**

```sql
-- ============================================================
-- Withdrawal retry queue
-- ============================================================
--
-- Adds retry-with-backoff for transient withdrawal payout failures.
-- New states: `retrying` (will be retried later) and `dead_letter`
-- (retries exhausted — operator must review).
--
-- The wallet stays debited while a withdrawal is in `retrying`. Refund
-- happens only on terminal outcomes (`failed` or `dead_letter`).
--
-- See docs/superpowers/specs/2026-05-21-withdrawal-retry-queue-design.md
-- and docs/runbooks/withdrawal-retry-queue.md for the full design and
-- operator runbook.
-- ============================================================

-- Required extensions (no-op if already enabled)
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

-- ── Extend the status enum ──────────────────────────────────
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

-- ── Retry-tracking columns ──────────────────────────────────
ALTER TABLE withdrawal_requests
  ADD COLUMN IF NOT EXISTS attempt_count       INT NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS next_attempt_at     TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS last_error          TEXT,
  ADD COLUMN IF NOT EXISTS dead_letter_reason  TEXT;

-- Partial index for the cron job's "due retries" query
CREATE INDEX IF NOT EXISTS withdrawal_requests_due_retries_idx
  ON withdrawal_requests (next_attempt_at)
  WHERE status = 'retrying';

-- ── RPC: schedule_withdrawal_retry ──────────────────────────
-- Transition pending|processing|retrying → retrying, bump attempt_count.
CREATE OR REPLACE FUNCTION schedule_withdrawal_retry(
  p_withdrawal_id     UUID,
  p_next_attempt_at   TIMESTAMPTZ,
  p_last_error        TEXT
) RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE withdrawal_requests
  SET status          = 'retrying',
      attempt_count   = attempt_count + 1,
      next_attempt_at = p_next_attempt_at,
      last_error      = p_last_error,
      updated_at      = now()
  WHERE id = p_withdrawal_id
    AND status IN ('pending','processing','retrying');
END;
$$;

REVOKE ALL ON FUNCTION schedule_withdrawal_retry(UUID, TIMESTAMPTZ, TEXT) FROM public;

-- ── RPC: dead_letter_withdrawal ─────────────────────────────
-- Transition retrying|processing → dead_letter, refund wallet.
CREATE OR REPLACE FUNCTION dead_letter_withdrawal(
  p_withdrawal_id UUID,
  p_reason        TEXT
) RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
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

  -- Refund the wallet — same effect as fail_withdrawal's refund.
  IF v_shop_id IS NOT NULL THEN
    UPDATE wallets
    SET balance              = balance + v_amount,
        pending_withdrawals  = GREATEST(0, pending_withdrawals - v_amount),
        updated_at           = now()
    WHERE shop_id = v_shop_id;
  END IF;
END;
$$;

REVOKE ALL ON FUNCTION dead_letter_withdrawal(UUID, TEXT) FROM public;

-- ── Cron worker: trigger_due_withdrawal_retries ─────────────
-- Find due retries, set them back to 'pending', and fire process-withdrawal.
-- Caps fan-out at 20 per tick so a queue burst doesn't overwhelm the function.
CREATE OR REPLACE FUNCTION trigger_due_withdrawal_retries()
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_rec            RECORD;
  v_count          INT := 0;
  v_function_url   TEXT := current_setting('app.settings.process_withdrawal_url', true);
  v_webhook_secret TEXT := current_setting('app.settings.internal_webhook_secret', true);
BEGIN
  IF v_function_url IS NULL OR v_webhook_secret IS NULL THEN
    RAISE WARNING 'trigger_due_withdrawal_retries: missing app.settings configuration (process_withdrawal_url or internal_webhook_secret)';
    RETURN 0;
  END IF;

  FOR v_rec IN
    SELECT id FROM withdrawal_requests
    WHERE status = 'retrying'
      AND next_attempt_at <= now()
    ORDER BY next_attempt_at ASC
    LIMIT 20
  LOOP
    -- Reset to 'pending' so process-withdrawal's existing status guard accepts it.
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
END;
$$;

REVOKE ALL ON FUNCTION trigger_due_withdrawal_retries() FROM public;

-- ── Recovery: sweep_stuck_pending_withdrawals ───────────────
-- If the cron marked a row 'pending' but the HTTP call never landed (network
-- failure between cron and edge function), the row stays in 'pending' with
-- no one to pick it up. After 5 minutes, bump it back to 'retrying' for the
-- next cron tick to pick up.
CREATE OR REPLACE FUNCTION sweep_stuck_pending_withdrawals()
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_count INT;
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
END;
$$;

REVOKE ALL ON FUNCTION sweep_stuck_pending_withdrawals() FROM public;

-- ============================================================
-- Cron scheduling lives in the runbook (not the migration) — same pattern
-- as expire_stale_pending_payments. The runbook also sets the required
-- GUCs (app.settings.process_withdrawal_url, app.settings.internal_webhook_secret).
-- ============================================================
```

- [ ] **Step 2: Skip local apply** (Supabase CLI is the user's responsibility — they'll run `supabase db push` after review)

- [ ] **Step 3: Verify the file compiles as valid SQL** (syntax-only check, no execution)

Run:
```bash
grep -cE "^(CREATE|ALTER|REVOKE|DROP)" supabase/migrations/20260521000000_withdrawal_retry_queue.sql
```
Expected: a number > 10 (sanity check that the file has the expected statement count — should report ~14).

- [ ] **Step 4: Commit**

```bash
git add supabase/migrations/20260521000000_withdrawal_retry_queue.sql
git commit -m "spec(18): withdrawal retry queue — schema + RPCs + cron functions"
```

---

# Task 2: process-withdrawal — helpers + restructured catch block

**Files:**
- Modify: `supabase/functions/process-withdrawal/index.ts`

This task does three things in one commit because they're coupled (helpers without the new catch block are unused, the new catch without helpers won't compile):

1. Fix the inner catch (currently strips `PaymentProviderError` type — bug).
2. Add 4 helper functions: `nextAttemptAt`, `scheduleWithdrawalRetry`, `deadLetterWithdrawal`, `sendDeadLetterNotification`.
3. Restructure the outer catch block to branch on `error.retryable`.

- [ ] **Step 1: Read** `supabase/functions/process-withdrawal/index.ts` end-to-end and confirm:
  - Line ~125: `getProvider(...).processPayout(...)` call
  - Lines ~133–138: inner catch that re-throws `PaymentProviderError` as plain `Error` (THIS IS THE BUG)
  - Lines ~174–205: outer catch that currently always calls `failWithdrawal` + refund
  - Line ~212: `completeWithdrawal` helper
  - Line ~224: `failWithdrawal` helper

- [ ] **Step 2: Fix the inner catch — preserve `PaymentProviderError` type**

Find this block (around lines 133–138):

```ts
    } catch (e) {
      if (e instanceof PaymentProviderError) {
        throw new Error(e.message);
      }
      throw e;
    }
```

Replace with:

```ts
    } catch (e) {
      // Preserve PaymentProviderError so the outer catch can branch on
      // `retryable` to decide retry-vs-terminal. The old code re-threw as
      // plain Error which collapsed both paths to "fail immediately".
      throw e;
    }
```

(The whole inner try/catch is now a no-op pass-through, but leaving the `try` block makes the diff smaller and the next refactor easier. Don't remove the `try { ... } catch { throw e; }` wrapper.)

- [ ] **Step 3: Add the backoff schedule constant + helpers**

Insert this block after the existing helpers (after `getWalletCurrency` near the end of the file). If the file already ends with `getWalletCurrency`, append after its closing `}`:

```ts
// ============================================================================
// Retry-queue helpers
// ============================================================================

// Backoff schedule indexed by attempt_count (the number of FAILED attempts so far).
// attempt_count=0 → first retry in 1 min. attempt_count=4 → last retry in 6 h.
// attempt_count >= length → dead-letter (no more retries).
const BACKOFF_SCHEDULE_SECONDS = [
  60,      // +1 minute  (after 1st failure)
  300,     // +5 minutes (after 2nd failure)
  1800,    // +30 min    (after 3rd failure)
  7200,    // +2 hours   (after 4th failure)
  21600,   // +6 hours   (after 5th failure)
];

function nextAttemptAt(currentAttemptCount: number): Date | null {
  if (currentAttemptCount >= BACKOFF_SCHEDULE_SECONDS.length) return null;
  return new Date(
    Date.now() + BACKOFF_SCHEDULE_SECONDS[currentAttemptCount] * 1000,
  );
}

async function scheduleWithdrawalRetry(
  withdrawalId: string,
  nextRunAt: Date,
  lastError: string,
) {
  const { error } = await supabase.rpc('schedule_withdrawal_retry', {
    p_withdrawal_id:   withdrawalId,
    p_next_attempt_at: nextRunAt.toISOString(),
    p_last_error:      lastError.substring(0, 500),
  });
  if (error) {
    console.error('schedule_withdrawal_retry RPC failed:', error);
  }
}

async function deadLetterWithdrawal(withdrawalId: string, reason: string) {
  const { error } = await supabase.rpc('dead_letter_withdrawal', {
    p_withdrawal_id: withdrawalId,
    p_reason:        reason.substring(0, 500),
  });
  if (error) {
    console.error('dead_letter_withdrawal RPC failed:', error);
  }
}

async function sendDeadLetterNotification(
  userId: string,
  amount: number,
  lastError: string,
  currency: string,
) {
  try {
    await supabase.from('notifications').insert({
      user_id: userId,
      type: 'withdrawal_dead_letter',
      title: 'Withdrawal Needs Review',
      body: `Your ${currency} ${amount.toFixed(2)} withdrawal could not be processed after multiple attempts. Our team has been notified and will investigate. You will not be charged.`,
      metadata: {
        withdrawal_amount: amount,
        currency,
        last_error: lastError.substring(0, 200),
      },
      created_at: new Date().toISOString(),
    });
  } catch (e) {
    console.error('Failed to send dead-letter notification:', (e as Error).message);
  }
}
```

- [ ] **Step 4: Replace the outer catch block**

Find the outer catch (around lines 174–205):

```ts
  } catch (error) {
    console.error(`❌ Withdrawal failed for ${withdrawalId}:`, error);

    // 7. Mark as failed and refund
    await failWithdrawal(withdrawalId, (error as Error).message);

    await audit(supabase, {
      action: 'withdrawal.fail',
      actorUserId: withdrawal.shops.user_id,
      shopId: withdrawal.shops.id,
      targetId: withdrawalId,
      outcome: 'failure',
      context: {
        provider: withdrawal.payment_provider,
        amount: withdrawal.amount,
        error: (error as Error).message,
      },
    });

    // 8. Send failure notification (resolve currency from wallet)
    const currency = await getWalletCurrency(withdrawal.shops.id);
    await sendNotification(
      withdrawal.shops.user_id,
      'failure',
      withdrawal.amount,
      withdrawal.net_amount || withdrawal.amount,
      (error as Error).message,
      currency,
    );

    return { success: false, error: error.message };
  }
```

Replace with:

```ts
  } catch (error) {
    console.error(`❌ Withdrawal failed for ${withdrawalId}:`, error);

    const isProviderError = error instanceof PaymentProviderError;
    const isRetryable = isProviderError && (error as PaymentProviderError).retryable;
    const errMessage = (error as Error).message;

    if (isRetryable) {
      const nextRunAt = nextAttemptAt(withdrawal.attempt_count ?? 0);

      if (nextRunAt) {
        // Transient failure — schedule retry, leave wallet debited.
        await scheduleWithdrawalRetry(withdrawalId, nextRunAt, errMessage);
        await audit(supabase, {
          action: 'withdrawal.retry_scheduled',
          actorUserId: withdrawal.shops.user_id,
          shopId: withdrawal.shops.id,
          targetId: withdrawalId,
          outcome: 'failure',
          context: {
            provider: withdrawal.payment_provider,
            amount: withdrawal.amount,
            attempt: (withdrawal.attempt_count ?? 0) + 1,
            next_attempt_at: nextRunAt.toISOString(),
            error: errMessage,
          },
        });
        return { success: false, retrying: true, nextAttemptAt: nextRunAt.toISOString() };
      }

      // Retries exhausted — dead-letter (RPC refunds the wallet).
      const reason = `exhausted ${withdrawal.attempt_count ?? 0} retries: ${errMessage}`;
      await deadLetterWithdrawal(withdrawalId, reason);
      await audit(supabase, {
        action: 'withdrawal.dead_letter',
        actorUserId: withdrawal.shops.user_id,
        shopId: withdrawal.shops.id,
        targetId: withdrawalId,
        outcome: 'failure',
        context: {
          provider: withdrawal.payment_provider,
          amount: withdrawal.amount,
          reason,
          last_error: errMessage,
        },
      });
      const dlCurrency = await getWalletCurrency(withdrawal.shops.id);
      await sendDeadLetterNotification(
        withdrawal.shops.user_id,
        withdrawal.amount,
        errMessage,
        dlCurrency,
      );
      return { success: false, dead_letter: true };
    }

    // Non-retryable provider error OR any other Error — terminal failure + refund.
    await failWithdrawal(withdrawalId, errMessage);
    await audit(supabase, {
      action: 'withdrawal.fail',
      actorUserId: withdrawal.shops.user_id,
      shopId: withdrawal.shops.id,
      targetId: withdrawalId,
      outcome: 'failure',
      context: {
        provider: withdrawal.payment_provider,
        amount: withdrawal.amount,
        error: errMessage,
      },
    });
    const currency = await getWalletCurrency(withdrawal.shops.id);
    await sendNotification(
      withdrawal.shops.user_id,
      'failure',
      withdrawal.amount,
      withdrawal.net_amount || withdrawal.amount,
      errMessage,
      currency,
    );
    return { success: false, error: errMessage };
  }
```

- [ ] **Step 5: Verify no stale references**

```bash
grep -nE "throw new Error\(e\.message\)" supabase/functions/process-withdrawal/index.ts
```
Expected: no matches (the inner catch's plain `Error` rethrow is gone).

```bash
grep -nE "nextAttemptAt|scheduleWithdrawalRetry|deadLetterWithdrawal|sendDeadLetterNotification" supabase/functions/process-withdrawal/index.ts
```
Expected: each name appears 2x (definition + usage) — confirms helpers exist AND are called.

- [ ] **Step 6: Skip `deno check`** (Deno not installed locally)

- [ ] **Step 7: Skip deploy + smoke test** (user runs `supabase functions deploy process-withdrawal` themselves)

- [ ] **Step 8: Commit**

```bash
git add supabase/functions/process-withdrawal/index.ts
git commit -m "spec(18): process-withdrawal — retry-queue helpers + branched catch on retryable"
```

---

# Task 3: Operational runbook

**Files:**
- Create: `docs/runbooks/withdrawal-retry-queue.md`

The migration defines the SQL functions; the cron scheduling and GUC setup happen out-of-band the same way `expire_stale_pending_payments` does today. This runbook captures the exact SQL to run, the verification queries, and the rollback procedure.

- [ ] **Step 1: Confirm `docs/runbooks/` directory exists**

```bash
ls docs/runbooks/ 2>/dev/null || echo "DOES NOT EXIST"
```

If it doesn't exist, create it: `mkdir -p docs/runbooks`.

- [ ] **Step 2: Create the runbook**

```markdown
# Withdrawal Retry Queue — Operator Runbook

This runbook covers the post-migration setup for the withdrawal retry queue
introduced by `20260521000000_withdrawal_retry_queue.sql`. The migration defines
the SQL functions; this runbook configures the GUCs and schedules the cron jobs.

See `docs/superpowers/specs/2026-05-21-withdrawal-retry-queue-design.md` for
the full design.

---

## 1. Apply the migration

\`\`\`bash
supabase db push
\`\`\`

If `pg_cron` or `pg_net` aren't enabled, enable them via the Supabase dashboard
(Database → Extensions). The migration's `CREATE EXTENSION IF NOT EXISTS` is a
no-op in environments where superuser is required for extensions.

---

## 2. Set the GUCs (one-time, per environment)

Run in the Supabase SQL editor (NOT in a migration — these are environment-specific):

\`\`\`sql
ALTER DATABASE postgres SET app.settings.process_withdrawal_url =
  'https://<project-ref>.supabase.co/functions/v1/process-withdrawal';

ALTER DATABASE postgres SET app.settings.internal_webhook_secret =
  '<value of INTERNAL_WEBHOOK_SECRET edge env>';
\`\`\`

Replace `<project-ref>` with your Supabase project ref. `<value of INTERNAL_WEBHOOK_SECRET>`
is the same secret the edge function expects in the `Authorization: Bearer ...` header.

Verify:

\`\`\`sql
SELECT current_setting('app.settings.process_withdrawal_url', true);
SELECT current_setting('app.settings.internal_webhook_secret', true);
\`\`\`

Both should return non-NULL. If either returns NULL, the cron job will log a
warning and return 0 — no retries will fire.

---

## 3. Schedule the cron jobs

\`\`\`sql
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
\`\`\`

Verify the schedules exist:

\`\`\`sql
SELECT jobid, jobname, schedule FROM cron.job
WHERE jobname IN ('withdrawal-retry-tick', 'withdrawal-stuck-sweep');
\`\`\`

Expected: 2 rows.

---

## 4. Deploy the edge function

\`\`\`bash
supabase functions deploy process-withdrawal
\`\`\`

---

## 5. Smoke-test the retry path

**Trigger a transient failure** by temporarily setting `PAYSTACK_SECRET_KEY` (or
`STRIPE_SECRET_KEY`) to a garbage value:

\`\`\`bash
supabase secrets set PAYSTACK_SECRET_KEY=sk_invalid_for_testing
\`\`\`

Request a small withdrawal (e.g. GHS 50) from the app. Within 30 seconds:

\`\`\`sql
SELECT id, status, attempt_count, next_attempt_at, last_error
FROM withdrawal_requests
WHERE id = '<the_withdrawal_id>';
\`\`\`

Expected:
- `status = 'retrying'` (NOT `'failed'`)
- `attempt_count = 1`
- `next_attempt_at ≈ now() + 1 minute`
- `last_error` populated with the provider error

**Restore the key:**

\`\`\`bash
supabase secrets set PAYSTACK_SECRET_KEY=<real_key>
\`\`\`

Within the next minute, the cron should pick up the row and the retry should
succeed. Verify:

\`\`\`sql
SELECT id, status, attempt_count
FROM withdrawal_requests WHERE id = '<the_withdrawal_id>';
\`\`\`

Expected: `status = 'completed'`, `attempt_count = 1` (the retry counter
stops incrementing on success).

---

## 6. Smoke-test the dead-letter path

Force-exhaust retries on a withdrawal:

\`\`\`sql
UPDATE withdrawal_requests
SET attempt_count = 5,
    next_attempt_at = now(),
    status = 'retrying'
WHERE id = '<test_withdrawal_id>';
\`\`\`

Keep `PAYSTACK_SECRET_KEY` invalid so the next attempt fails. Within ~2 minutes:

\`\`\`sql
SELECT status, dead_letter_reason FROM withdrawal_requests
WHERE id = '<test_withdrawal_id>';
\`\`\`

Expected:
- `status = 'dead_letter'`
- `dead_letter_reason = 'exhausted 5 retries: ...'`

Wallet should also be refunded:

\`\`\`sql
SELECT balance, pending_withdrawals FROM wallets
WHERE shop_id = '<shop_id>';
\`\`\`

A `notifications` row for the shop owner:

\`\`\`sql
SELECT title, body FROM notifications
WHERE user_id = '<shop_owner_id>'
  AND type = 'withdrawal_dead_letter'
ORDER BY created_at DESC LIMIT 1;
\`\`\`

Expected: title "Withdrawal Needs Review".

Audit-log entry:

\`\`\`sql
SELECT action, outcome, context FROM payment_audit_log
WHERE action = 'withdrawal.dead_letter'
ORDER BY created_at DESC LIMIT 1;
\`\`\`

---

## 7. Queue health monitoring

Current queue depth:

\`\`\`sql
SELECT status, count(*) FROM withdrawal_requests
GROUP BY status ORDER BY status;
\`\`\`

Retries due soon (next 5 minutes):

\`\`\`sql
SELECT id, attempt_count, next_attempt_at, last_error
FROM withdrawal_requests
WHERE status = 'retrying'
  AND next_attempt_at <= now() + interval '5 minutes'
ORDER BY next_attempt_at;
\`\`\`

Stuck rows (should always be 0 — sweep recovers them within 5 minutes):

\`\`\`sql
SELECT count(*) FROM withdrawal_requests
WHERE status = 'pending'
  AND attempt_count > 0
  AND updated_at < now() - interval '10 minutes';
\`\`\`

Recent dead-letters (operator queue):

\`\`\`sql
SELECT id, shop_id, amount, dead_letter_reason, updated_at
FROM withdrawal_requests
WHERE status = 'dead_letter'
ORDER BY updated_at DESC LIMIT 20;
\`\`\`

---

## 8. Manual recovery from `dead_letter`

After investigating a dead-lettered withdrawal:

- **If the provider actually succeeded** (transfer landed, our ack was lost):
  \`\`\`sql
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
  \`\`\`

- **If the provider never processed the transfer** (genuine failure, refund is correct):
  \`\`\`sql
  UPDATE withdrawal_requests
  SET status = 'refunded', updated_at = now()
  WHERE id = '<withdrawal_id>';
  -- Wallet already refunded by dead_letter_withdrawal — no further action.
  \`\`\`

Always record the manual action in `payment_audit_log`:

\`\`\`sql
SELECT record_payment_audit(
  'withdrawal.manual_resolve',
  '<operator_user_id>',
  '<shop_id>',
  '<withdrawal_id>',
  'success',
  jsonb_build_object(
    'resolution', 'completed_via_manual',  -- or 'refunded_confirmed'
    'note', 'Verified with Paystack support that transfer 1234 landed'
  )
);
\`\`\`

---

## 9. Rollback

If the retry queue causes problems, you can disable it without dropping the schema:

\`\`\`sql
SELECT cron.unschedule('withdrawal-retry-tick');
SELECT cron.unschedule('withdrawal-stuck-sweep');
\`\`\`

`retrying` rows will sit indefinitely; `dead_letter` rows are inert. To convert
all `retrying` back to `failed` (forcing immediate refund):

\`\`\`sql
-- One-shot: drain retry queue to failed (refunds wallets via fail_withdrawal RPC)
DO $$
DECLARE r RECORD;
BEGIN
  FOR r IN SELECT id FROM withdrawal_requests WHERE status = 'retrying' LOOP
    PERFORM fail_withdrawal(r.id, 'retry queue disabled — drained to failed');
  END LOOP;
END $$;
\`\`\`
```

(In the file above: code fences inside the runbook use literal triple-backticks — the `\`\`\`` you see in this plan are escaped only for the plan's own markdown.)

- [ ] **Step 3: Commit**

```bash
git add docs/runbooks/withdrawal-retry-queue.md
git commit -m "spec(18): docs — withdrawal retry queue operator runbook"
```

---

# Verification (after all 3 tasks)

1. **Migration file looks complete:** `wc -l supabase/migrations/20260521000000_withdrawal_retry_queue.sql` reports ≥150 lines.
2. **process-withdrawal compiles** (mentally — Deno not installed): no references to removed symbols; helper names match between definitions and call sites.
3. **No stale grep matches** for `throw new Error(e.message)` in process-withdrawal.
4. **Runbook is reachable** at `docs/runbooks/withdrawal-retry-queue.md`.
5. **User deploys**: applies migration, sets GUCs, schedules cron, deploys edge function, runs Section 5 + 6 smoke tests from the runbook.

Once shipped, the next two Phase 3 items (UX polish + E2E tests) can begin. The UX polish item will add a Flutter banner that reads `withdrawal_requests` for `status='dead_letter'` and shows the shop owner — the schema lands here, the UI lands there.
