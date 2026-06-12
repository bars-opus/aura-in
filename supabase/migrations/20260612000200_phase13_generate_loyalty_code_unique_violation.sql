-- Phase 13 hardening — corrective for audit finding F-P1-2.
--
-- Issue (checklist 1.6 / 2.16 / P1 / [ASYNC][MUTATION]):
--   `generate_loyalty_code` does a non-atomic "is there an unredeemed
--   loyalty code for this client?" check followed by an INSERT. If two
--   bookings flip to status='completed' in the same instant, both
--   trigger the helper, both pass the SELECT, both attempt the INSERT,
--   and the partial UNIQUE index `promotions_silent_target_uniq` fires
--   `unique_violation` (errcode 23505) on the loser. The exception
--   propagates back through the AFTER UPDATE trigger and rolls back
--   the booking status flip — the user's booking silently goes back
--   to 'confirmed' and the owner has no idea.
--
-- Fix:
--   Wrap the INSERT in a savepoint with `EXCEPTION WHEN unique_violation
--   THEN` that re-reads the now-extant code. This converts the race
--   into a no-op — the loser sees the winner's code and returns it.

CREATE OR REPLACE FUNCTION public.generate_loyalty_code(
  p_shop_id          UUID,
  p_user_id          UUID,
  p_guest_profile_id UUID
) RETURNS TEXT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
DECLARE
  v_rule_type  TEXT;
  v_rule_value NUMERIC;
  v_existing   TEXT;
  v_new_code   TEXT;
BEGIN
  IF p_user_id IS NULL AND p_guest_profile_id IS NULL THEN
    RETURN NULL;
  END IF;

  SELECT discount_type, discount_value
  INTO v_rule_type, v_rule_value
  FROM public.loyalty_rules
  WHERE shop_id = p_shop_id AND is_active = TRUE;
  IF NOT FOUND THEN
    RETURN NULL;
  END IF;

  SELECT code INTO v_existing FROM public.promotions
  WHERE shop_id = p_shop_id
    AND source = 'loyalty'
    AND archived_at IS NULL
    AND COALESCE(target_user_id, target_guest_profile_id)
        = COALESCE(p_user_id, p_guest_profile_id)
    AND NOT EXISTS (
      SELECT 1 FROM public.promotion_redemptions r
      WHERE r.promotion_id = promotions.id
    )
  ORDER BY created_at DESC LIMIT 1;
  IF FOUND THEN
    RETURN v_existing;
  END IF;

  v_new_code := upper('LOYAL' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 6));

  -- F-P1-2: race-safe INSERT. The partial UNIQUE index on
  -- (shop_id, COALESCE(target_user_id, target_guest_profile_id), source)
  -- WHERE source IN ('loyalty','recovery') protects us; on conflict, we
  -- re-read the winner's code so the trigger that fired us does not
  -- get a `unique_violation` bubbling back through the booking UPDATE.
  BEGIN
    INSERT INTO public.promotions (
      shop_id, name, code, discount_type, discount_value,
      valid_from, valid_to, usage_limit, is_active,
      source, target_user_id, target_guest_profile_id, per_client_max
    ) VALUES (
      p_shop_id, 'Loyalty reward', v_new_code,
      v_rule_type, v_rule_value,
      now(), now() + INTERVAL '10 years', 1, TRUE,
      'loyalty', p_user_id, p_guest_profile_id, 1
    );
  EXCEPTION WHEN unique_violation THEN
    SELECT code INTO v_new_code FROM public.promotions
    WHERE shop_id = p_shop_id
      AND source = 'loyalty'
      AND archived_at IS NULL
      AND COALESCE(target_user_id, target_guest_profile_id)
          = COALESCE(p_user_id, p_guest_profile_id)
    ORDER BY created_at DESC
    LIMIT 1;
  END;

  RETURN v_new_code;
END;
$function$;

REVOKE ALL ON FUNCTION public.generate_loyalty_code(UUID, UUID, UUID) FROM PUBLIC;

COMMENT ON FUNCTION public.generate_loyalty_code(UUID, UUID, UUID) IS
  'Phase 13 internal helper. Issues a one-shot loyalty promo code for a (shop, client) pair using the shop active loyalty_rule. Idempotent (reuses existing unredeemed code; race-safe via F-P1-2 unique_violation handler). TTL is the no-expiry sentinel (now()+10y). SECURITY DEFINER; trigger-only. O(1).';
