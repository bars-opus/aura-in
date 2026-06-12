-- Phase 15: archive_pricing_override RPC.
-- Idempotent soft-delete. Mirrors archive_appointment_slot (Phase 11).

CREATE OR REPLACE FUNCTION public.archive_pricing_override(
  p_override_id UUID
) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
BEGIN
  IF p_override_id IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'NULL_NOT_ALLOWED';
  END IF;

  -- Authz via slot → shop chain. Sanitized 'not_found' on mismatch.
  IF NOT EXISTS (
    SELECT 1 FROM public.pricing_overrides po
    JOIN public.appointment_slots s ON s.id = po.slot_id
    JOIN public.shops sh ON sh.id = s.shop_id
    WHERE po.id = p_override_id
      AND sh.user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  -- Idempotent: re-archiving an already-archived row is a no-op (WHERE clause
  -- filters out rows where archived_at IS NOT NULL).
  UPDATE public.pricing_overrides
     SET archived_at = now()
   WHERE id = p_override_id
     AND archived_at IS NULL;
END;
$function$;

REVOKE ALL ON FUNCTION public.archive_pricing_override(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.archive_pricing_override(UUID) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.archive_pricing_override(UUID) TO authenticated;

COMMENT ON FUNCTION public.archive_pricing_override(UUID) IS
  'Phase 15: owner-only soft-delete. Idempotent (no-op when row is already archived). Authz via pricing_overrides -> appointment_slots -> shops chain. SECURITY DEFINER.';
