-- Fix add_wallet_transaction: populate balance_after (and status/completed_at).
--
-- ROOT CAUSE (2026-06-28 diagnosis):
--   Production `wallet_transactions` was altered outside migrations (via the
--   Supabase dashboard) to add three columns the canonical schema never had:
--     * status        TEXT NOT NULL DEFAULT 'pending'
--     * balance_after  NUMERIC NOT NULL  (no default)
--     * completed_at   TIMESTAMPTZ NULL
--   The canonical add_wallet_transaction RPC (20260602190000) computes the
--   post-update balance into v_balance_after but never inserts it. Because
--   balance_after is NOT NULL with no default, EVERY call now fails with
--     23502: null value in column "balance_after" violates not-null constraint
--   The booking webhook swallows this error as "non-fatal" (paystack-webhook
--   line ~364), so payments silently never credit the wallet. The most recent
--   guest booking (5158f83f) is the first paid booking with no wallet_transactions
--   row — earlier rows were inserted before balance_after became NOT NULL.
--
-- This migration:
--   1. Reconciles the canonical table definition with production (so future
--      `supabase db reset` reproduces the real shape — no more drift).
--   2. Rewrites add_wallet_transaction to insert balance_after, mark deposits/
--      refunds/adjustments as 'completed' (a settled payment is final, not
--      'pending'), and stamp completed_at.
--   3. Backfills the one orphaned guest booking (5158f83f) idempotently — the
--      RPC's reference idempotency means re-running this is safe.
--
-- Checklist v3.1: 2.19 (money stays NUMERIC, no float), 2.21 (idempotent on
-- reference — webhook replays cannot double-credit), 2.22 (balance_after gives
-- the audit ledger a before/after trail).

-- 1. Bring the canonical table definition in line with production. These are
-- no-ops on the live DB (columns already exist) but keep migrations honest.
ALTER TABLE wallet_transactions
  ADD COLUMN IF NOT EXISTS status        TEXT        NOT NULL DEFAULT 'pending',
  ADD COLUMN IF NOT EXISTS balance_after NUMERIC(12,2),
  ADD COLUMN IF NOT EXISTS completed_at  TIMESTAMPTZ;

-- 2. Rewrite the RPC. Same signature, same idempotency, now sets balance_after.
CREATE OR REPLACE FUNCTION add_wallet_transaction(
  p_shop_id     UUID,
  p_amount      NUMERIC,
  p_type        TEXT,
  p_booking_id  UUID DEFAULT NULL,
  p_description TEXT DEFAULT NULL,
  p_reference   TEXT DEFAULT NULL,
  p_metadata    JSONB DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_existing_id    UUID;
  v_transaction_id UUID;
  v_balance_after  NUMERIC;
BEGIN
  IF p_amount <= 0 THEN
    RAISE EXCEPTION 'amount must be positive (use type=withdrawal for debits)';
  END IF;

  IF p_type NOT IN ('deposit', 'withdrawal', 'refund', 'adjustment') THEN
    RAISE EXCEPTION 'invalid transaction type: %', p_type;
  END IF;

  -- Idempotency: replays of the same provider event (Paystack + Stripe both
  -- replay) must not re-credit. Short-circuit on an existing (shop, reference).
  IF p_reference IS NOT NULL THEN
    SELECT id INTO v_existing_id
    FROM wallet_transactions
    WHERE shop_id = p_shop_id AND reference = p_reference
    LIMIT 1;
    IF v_existing_id IS NOT NULL THEN
      RETURN v_existing_id;
    END IF;
  END IF;

  -- Backfill a wallet for legacy shops created before the auto-create trigger.
  INSERT INTO wallets (shop_id) VALUES (p_shop_id)
    ON CONFLICT (shop_id) DO NOTHING;

  -- Atomic balance update. The row lock from UPDATE serializes concurrent
  -- credits for the same shop. RETURNING gives us the authoritative
  -- post-update balance to stamp on the ledger row (balance_after).
  UPDATE wallets
     SET balance =
           CASE p_type
             WHEN 'withdrawal' THEN balance - p_amount
             ELSE balance + p_amount
           END,
         total_earned =
           CASE p_type
             WHEN 'deposit'    THEN total_earned + p_amount
             WHEN 'refund'     THEN total_earned + p_amount
             WHEN 'adjustment' THEN total_earned + p_amount
             ELSE total_earned
           END,
         total_withdrawn =
           CASE p_type
             WHEN 'withdrawal' THEN total_withdrawn + p_amount
             ELSE total_withdrawn
           END,
         updated_at = NOW()
   WHERE shop_id = p_shop_id
   RETURNING balance INTO v_balance_after;

  IF v_balance_after IS NULL THEN
    -- The wallet row vanished between the upsert and the update (shop deleted
    -- mid-transaction). Fail loudly rather than insert a NULL balance_after.
    RAISE EXCEPTION 'wallet for shop % not found', p_shop_id;
  END IF;

  INSERT INTO wallet_transactions (
    shop_id, amount, type, status, booking_id,
    description, reference, balance_after, completed_at, metadata
  ) VALUES (
    p_shop_id, p_amount, p_type, 'completed', p_booking_id,
    p_description, p_reference, v_balance_after, NOW(), p_metadata
  )
  RETURNING id INTO v_transaction_id;

  RETURN v_transaction_id;
END;
$$;

REVOKE ALL ON FUNCTION add_wallet_transaction(UUID, NUMERIC, TEXT, UUID, TEXT, TEXT, JSONB) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION add_wallet_transaction(UUID, NUMERIC, TEXT, UUID, TEXT, TEXT, JSONB) TO service_role;

COMMENT ON FUNCTION add_wallet_transaction IS
  'Atomically credit/debit a shop wallet: updates wallets totals and appends a wallet_transactions ledger row with balance_after. Idempotent on (shop_id, reference). All booking/order webhooks depend on this for balance integrity.';

-- 3. Backfill the orphaned guest booking (5158f83f). Net = total 8.00 - fee 0.23
-- = 7.77. Idempotent: the RPC's reference guard makes a re-run a no-op. Guarded
-- by EXISTS so it only fires if the booking is still uncredited.
DO $$
DECLARE
  v_booking_id  UUID := '5158f83f-4e9a-4bc4-a70a-df056d4f0734';
  v_shop_id     UUID := '74793953-435d-43af-b6f2-91565c3382f8';
  v_reference   TEXT := 'booking_shop_74793953-435d-43af-b6f2-91565c3382f8_233501201544_1780659900000_1780436124';
BEGIN
  IF EXISTS (SELECT 1 FROM bookings WHERE id = v_booking_id)
     AND NOT EXISTS (
       SELECT 1 FROM wallet_transactions
       WHERE shop_id = v_shop_id AND reference = v_reference
     )
  THEN
    PERFORM add_wallet_transaction(
      v_shop_id,
      7.77,
      'deposit',
      v_booking_id,
      'Backfill: guest booking 5158f83f wallet credit missed due to balance_after bug',
      v_reference
    );
  END IF;
END $$;
