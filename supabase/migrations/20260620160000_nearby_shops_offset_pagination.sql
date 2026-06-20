-- Convert get_nearby_shops from KEYSET (cursor_id) to OFFSET pagination.
--
-- The keyset predicate `s.id::TEXT > cursor_id` is uncorrelated with the
-- band-blend ORDER BY (floor(distance_km/2), md5(id||seed)), so pages 2+
-- skip/duplicate rows. OFFSET pagination matches the other discover_* RPCs.
--
-- Changes:
--   1. Add trailing `p_page_offset int DEFAULT 0` param.
--   2. Remove the keyset WHERE predicate; cursor_id param kept (unused) for
--      backward-compat with any callers that still pass it.
--   3. Add `OFFSET greatest(coalesce(p_page_offset,0),0)` after LIMIT.
--   4. Append `, s.id` stable tiebreak to every ORDER BY branch.

CREATE OR REPLACE FUNCTION public.get_nearby_shops(
  user_lat double precision,
  user_lng double precision,
  radius_km double precision DEFAULT 2.0,
  filter_luxury_level text DEFAULT NULL::text,
  verified_only boolean DEFAULT false,
  sort_by text DEFAULT 'distance'::text,
  cursor_id text DEFAULT NULL::text,
  page_limit integer DEFAULT 20,
  p_seed int DEFAULT 0,
  p_page_offset int DEFAULT 0
)
RETURNS TABLE(id uuid, shop_name text, cover_image_url text, average_rating numeric, number_clients_worked integer, luxury_level text, verified boolean, shop_type text, distance_km double precision)
LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT
    s.id,
    s.shop_name,
    (SELECT url FROM shop_media
     WHERE shop_id = s.id
     AND media_type = 'professional'
     ORDER BY is_cover DESC, sort_order ASC
     LIMIT 1) as cover_image_url,
    s.average_rating,
    s.number_clients_worked,
    s.luxury_level,
    s.verified,
    s.shop_type,
    ROUND(
      (ST_Distance(
        ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography,
        ST_SetSRID(ST_MakePoint(sl.longitude, sl.latitude), 4326)::geography
      ) / 1000)::NUMERIC,
      2
    )::DOUBLE PRECISION as distance_km
  FROM shops s
  LEFT JOIN shop_locations sl ON s.id = sl.shop_id AND sl.is_primary = true
  WHERE
    sl.latitude IS NOT NULL
    AND sl.longitude IS NOT NULL
    AND s.verification_status = 'approved'  -- verification gate (unconditional)
    AND ST_DWithin(
      ST_SetSRID(ST_MakePoint(sl.longitude, sl.latitude), 4326)::geography,
      ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography,
      radius_km * 1000
    )
    AND (filter_luxury_level IS NULL OR s.luxury_level = filter_luxury_level)
    AND (verified_only = FALSE OR (verified_only = TRUE AND s.verified = TRUE))
    -- NOTE: keyset predicate removed; cursor_id param retained for compat only
  ORDER BY
    CASE WHEN sort_by = 'rating' THEN s.average_rating END DESC NULLS LAST,
    CASE WHEN sort_by = 'rating' THEN s.id::text         END ASC  NULLS LAST,
    CASE WHEN sort_by = 'name'   THEN s.shop_name        END ASC  NULLS LAST,
    CASE WHEN sort_by = 'name'   THEN s.id::text         END ASC  NULLS LAST,
    CASE WHEN sort_by NOT IN ('rating', 'name') THEN floor(
      ROUND(
        (ST_Distance(
          ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography,
          ST_SetSRID(ST_MakePoint(sl.longitude, sl.latitude), 4326)::geography
        ) / 1000)::NUMERIC,
        2
      ) / 2.0
    ) END ASC NULLS LAST,
    CASE WHEN sort_by NOT IN ('rating', 'name') THEN md5(s.id::text || p_seed::text) END ASC NULLS LAST,
    CASE WHEN sort_by NOT IN ('rating', 'name') THEN s.id::text END ASC NULLS LAST
  LIMIT page_limit
  OFFSET greatest(coalesce(p_page_offset, 0), 0);
END;
$function$;
