-- Phase 13 hardening — corrective for audit finding F-P2-3.
--
-- Issue (checklist 1.10 / 2.18 / [FIN][MUTATION]):
--   When `redeem_promotion` was widened to accept `guest_profile_id` in
--   20260606000200, the FOR UPDATE row-lock + usage_limit check from the
--   original 4-arg version was dropped. The widened function relies on
--   `validate_and_apply_promo` (the read-side) to enforce the cap.
--   That holds for the booking happy path, but `redeem_promotion` is
--   also callable from the success-webhook directly — a webhook misfire
--   (or a manual replay) bypasses the cap check entirely.
--
-- Fix:
--   Restore the FOR UPDATE + usage_limit check pre-insert. Keeps the
--   ON CONFLICT idempotency intact: if the redemption already exists
--   the cap check is skipped (we're about to RETURN the existing id
--   anyway). The lock holds until commit, so concurrent webhook
--   replays serialise around the same promotion row.

CREATE OR REPLACE FUNCTION public.redeem_promotion(
  p_promotion_id     UUID,
  p_booking_id       UUID,
  p_user_id          UUID,
  p_discount_amount  NUMERIC,
  p_guest_profile_id UUID DEFAULT NULL
) RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
DECLARE
  v_redemption_id   UUID;
  v_usage_count     INT;
  v_usage_limit     INT;
  v_already_present BOOLEAN;
BEGIN
  IF p_promotion_id IS NULL OR p_booking_id IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'PROMOTION_OR_BOOKING_NULL';
  END IF;

  IF p_user_id IS NOT NULL AND p_guest_profile_id IS NOT NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'AT_MOST_ONE_OF_USER_OR_GUEST';
  END IF;

  -- F-P2-3: short-circuit on idempotent replay so the cap check does not
  -- inadvertently reject a legitimate retry of an already-counted
  -- redemption.
  SELECT TRUE INTO v_already_present FROM public.promotion_redemptions
  WHERE promotion_id = p_promotion_id AND booking_id = p_booking_id;
  IF v_already_present THEN
    SELECT id INTO v_redemption_id FROM public.promotion_redemptions
    WHERE promotion_id = p_promotion_id AND booking_id = p_booking_id;
    RETURN v_redemption_id;
  END IF;

  -- F-P2-3: lock the promotion row and check the cap. Serialises
  -- concurrent webhook replays.
  SELECT COALESCE(usage_count, 0), usage_limit
    INTO v_usage_count, v_usage_limit
  FROM public.promotions WHERE id = p_promotion_id
  FOR UPDATE;

  IF v_usage_limit IS NOT NULL AND v_usage_count >= v_usage_limit THEN
    RAISE EXCEPTION 'limit_reached'
      USING ERRCODE = 'P0001', HINT = 'PROMO_LIMIT_REACHED';
  END IF;

  INSERT INTO public.promotion_redemptions (
    promotion_id, booking_id, user_id, guest_profile_id, discount_amount, redeemed_at
  ) VALUES (
    p_promotion_id, p_booking_id, p_user_id, p_guest_profile_id, p_discount_amount, now()
  )
  ON CONFLICT (promotion_id, booking_id) DO NOTHING
  RETURNING id INTO v_redemption_id;

  IF v_redemption_id IS NULL THEN
    -- Race: another tx inserted between our pre-check and our INSERT.
    SELECT id INTO v_redemption_id FROM public.promotion_redemptions
    WHERE promotion_id = p_promotion_id AND booking_id = p_booking_id;
    RETURN v_redemption_id;
  END IF;

  UPDATE public.promotions
  SET usage_count = COALESCE(usage_count, 0) + 1
  WHERE id = p_promotion_id;

  RETURN v_redemption_id;
END;
$function$;

REVOKE ALL ON FUNCTION public.redeem_promotion(UUID, UUID, UUID, NUMERIC, UUID) FROM PUBLIC;
-- Intentionally NOT GRANTed to authenticated.

COMMENT ON FUNCTION public.redeem_promotion(UUID, UUID, UUID, NUMERIC, UUID) IS
  'Phase 13: widened to accept guest_profile_id. Idempotent insert + counter bump. F-P2-3: restored FOR UPDATE + usage_limit cap check pre-insert so direct webhook replays cannot bypass the cap. SECURITY DEFINER; service_role-only. O(1).';
