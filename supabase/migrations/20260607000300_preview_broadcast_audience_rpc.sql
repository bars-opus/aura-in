-- Phase 14: preview_broadcast_audience RPC.
--
-- Owner-only read-side count for the CreateBroadcastScreen live
-- preview. STABLE; safe to call in the form-edit hot path. Same CTEs
-- as send_broadcast minus the writes — including the accepts_marketing
-- gate so the preview count matches the eventual fan-out count.
--
-- Authz first. Returns 'not_found' (42501) for cross-shop calls to
-- avoid client enumeration of other shops' audience sizes.
--
-- Defensive REVOKE FROM authenticated before GRANT EXECUTE per the
-- Phase 13 hotfix learning (REVOKE FROM PUBLIC alone is insufficient
-- when Supabase's default policy grants EXECUTE).

CREATE OR REPLACE FUNCTION public.preview_broadcast_audience(
  p_shop_id        UUID,
  p_audience_type  TEXT,
  p_audience_param UUID DEFAULT NULL
) RETURNS INT
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
DECLARE v_count INT;
BEGIN
  -- NULL shape (no side effects; precedes authz).
  IF p_shop_id IS NULL OR p_audience_type IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'REQUIRED_FIELD_MISSING';
  END IF;
  IF p_audience_type NOT IN ('all_clients','recent','lapsed','by_service') THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'AUDIENCE_TYPE_INVALID';
  END IF;
  IF p_audience_type = 'by_service' AND p_audience_param IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'AUDIENCE_PARAM_REQUIRED';
  END IF;
  IF p_audience_type <> 'by_service' AND p_audience_param IS NOT NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'AUDIENCE_PARAM_FORBIDDEN';
  END IF;

  -- Authz FIRST. Sanitized 'not_found' for cross-shop calls.
  IF NOT EXISTS (SELECT 1 FROM public.shops
                 WHERE id = p_shop_id AND user_id = auth.uid()) THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  WITH client_identities AS (
    SELECT b.user_id,
           b.guest_profile_id,
           COALESCE(b.user_id::text, b.guest_profile_id::text) AS dedup_key,
           MAX(b.start_time) FILTER (WHERE b.status <> 'pending') AS last_at
    FROM public.bookings b
    WHERE b.shop_id = p_shop_id AND b.status <> 'pending'
    GROUP BY b.user_id, b.guest_profile_id
  ),
  audience AS (
    SELECT ci.user_id, ci.guest_profile_id
    FROM client_identities ci
    WHERE
      CASE p_audience_type
        WHEN 'all_clients' THEN TRUE
        WHEN 'recent'      THEN ci.last_at >= now() - INTERVAL '30 days'
        WHEN 'lapsed'      THEN ci.last_at <  now() - INTERVAL '60 days'
                                AND EXISTS (
                                  SELECT 1 FROM public.bookings b2
                                  WHERE b2.shop_id = p_shop_id
                                    AND b2.status IN ('confirmed','completed')
                                    AND COALESCE(b2.user_id::text, b2.guest_profile_id::text) = ci.dedup_key)
        WHEN 'by_service'  THEN EXISTS (
                                  SELECT 1 FROM public.bookings b2
                                  JOIN public.booking_services bs ON bs.booking_id = b2.id
                                  WHERE b2.shop_id = p_shop_id
                                    AND b2.status <> 'pending'
                                    AND bs.slot_id = p_audience_param
                                    AND COALESCE(b2.user_id::text, b2.guest_profile_id::text) = ci.dedup_key)
      END
  )
  SELECT count(*) INTO v_count
  FROM audience a
  LEFT JOIN public.guest_profiles gp ON gp.id = a.guest_profile_id
  WHERE a.user_id IS NOT NULL OR COALESCE(gp.accepts_marketing, TRUE) = TRUE;

  RETURN v_count;
END;
$function$;

REVOKE ALL ON FUNCTION public.preview_broadcast_audience(UUID, TEXT, UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.preview_broadcast_audience(UUID, TEXT, UUID) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.preview_broadcast_audience(UUID, TEXT, UUID) TO authenticated;

COMMENT ON FUNCTION public.preview_broadcast_audience(UUID, TEXT, UUID) IS
  'Phase 14 owner-only read-side audience count. Used by CreateBroadcastScreen live preview. Same CTEs as send_broadcast minus inserts. accepts_marketing gate applied so the preview matches the eventual fan-out count. Authz first; sanitized not_found for non-owners. O(shop_client_count). Phase 14.';
