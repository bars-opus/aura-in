-- Reconciliation surface for failed wallet credits.
--
-- WHY (checklist v3.1 2.23 reconciliation + 4.14 dead-letter):
--   The booking/order webhooks treat a failed add_wallet_transaction as
--   "non-fatal" and only console.error it — so a payment can succeed while the
--   shop's wallet is silently never credited, with no surface to detect or
--   replay it (exactly how guest booking 5158f83f was lost). This table is the
--   dead-letter queue for [FIN] credits: every failed credit lands here with
--   enough context to retry, and `retry_wallet_credit_failures` replays them.
--
-- The webhooks insert here when the RPC errors. A daily cron (or manual run)
-- calls retry_wallet_credit_failures() to settle anything recoverable; rows
-- that keep failing stay visible for manual review.

CREATE TABLE IF NOT EXISTS wallet_credit_failures (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id       UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
  booking_id    UUID,
  amount        NUMERIC(12,2) NOT NULL,
  type          TEXT NOT NULL,
  reference     TEXT,
  description   TEXT,
  error_message TEXT,
  resolved_at   TIMESTAMPTZ,            -- set when a retry finally credits it
  attempts      INT NOT NULL DEFAULT 1,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- One open failure per (shop, reference): a webhook replay must not enqueue
-- duplicates. Partial index so multiple resolved rows are allowed but only one
-- unresolved row per reference.
CREATE UNIQUE INDEX IF NOT EXISTS wallet_credit_failures_open_ref_idx
  ON wallet_credit_failures (shop_id, reference)
  WHERE resolved_at IS NULL AND reference IS NOT NULL;

CREATE INDEX IF NOT EXISTS wallet_credit_failures_unresolved_idx
  ON wallet_credit_failures (created_at)
  WHERE resolved_at IS NULL;

ALTER TABLE wallet_credit_failures ENABLE ROW LEVEL SECURITY;
-- No policies: service_role (webhooks, cron) bypasses RLS; nobody else reads it.

-- Replay unresolved failures. Calls the (now-fixed) RPC for each; the RPC's
-- reference idempotency means a credit that actually succeeded earlier is a
-- no-op. Marks rows resolved on success, bumps attempts on continued failure.
CREATE OR REPLACE FUNCTION retry_wallet_credit_failures()
RETURNS TABLE (resolved INT, still_failing INT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  r              wallet_credit_failures%ROWTYPE;
  v_resolved     INT := 0;
  v_failing      INT := 0;
BEGIN
  FOR r IN
    SELECT * FROM wallet_credit_failures
    WHERE resolved_at IS NULL
    ORDER BY created_at
  LOOP
    BEGIN
      PERFORM add_wallet_transaction(
        r.shop_id, r.amount, r.type, r.booking_id, r.description, r.reference
      );
      UPDATE wallet_credit_failures
         SET resolved_at = NOW(), updated_at = NOW()
       WHERE id = r.id;
      v_resolved := v_resolved + 1;
    EXCEPTION WHEN OTHERS THEN
      UPDATE wallet_credit_failures
         SET attempts = attempts + 1,
             error_message = SQLERRM,
             updated_at = NOW()
       WHERE id = r.id;
      v_failing := v_failing + 1;
    END;
  END LOOP;

  RETURN QUERY SELECT v_resolved, v_failing;
END;
$$;

REVOKE ALL ON FUNCTION retry_wallet_credit_failures() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION retry_wallet_credit_failures() TO service_role;

COMMENT ON TABLE wallet_credit_failures IS
  'Dead-letter queue for failed wallet credits. Webhooks insert here when add_wallet_transaction errors; retry_wallet_credit_failures() replays them. Unresolved rows = money owed to a shop that has not landed.';
