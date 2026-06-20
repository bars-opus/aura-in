-- Gate the discovery RPCs on verification_status.
--
-- get_nearby_shops / get_nearby_freelancers are SECURITY-DEFINER-style discovery
-- functions that run their own SELECTs and therefore BYPASS the row-level
-- security added in 20260620120000. Without patching them, pending/rejected
-- producers still appear on the primary map/nearby surface — defeating the
-- verification gate. This migration re-creates each with an added
-- `verification_status = 'approved'` predicate.
--
-- All three definitions below are the live bodies (dumped via pg_get_functiondef)
-- with ONLY the verification predicate added — no other logic changed. The exact
-- argument signatures are preserved so CREATE OR REPLACE updates the existing
-- functions in place rather than creating new overloads. get_nearby_freelancers
-- has TWO overloads; both are patched.

-- ───────────────────────────────────────────────────────────────────────────
-- get_nearby_freelancers (overload A: p_freelancer_type text, ...)
-- ───────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_nearby_freelancers(
  p_user_lat double precision,
  p_user_lng double precision,
  p_radius_km double precision DEFAULT 10,
  p_page_limit integer DEFAULT 20,
  p_page_offset integer DEFAULT 0,
  p_freelancer_type text DEFAULT NULL::text,
  p_min_rating numeric DEFAULT NULL::numeric,
  p_sort_by text DEFAULT 'distance'::text
)
RETURNS TABLE(worker_id uuid, name text, profile_image text, bio text, specialties text[], freelancer_type text, freelancer_types text[], tools text[], can_travel boolean, travel_radius_km integer, average_rating numeric, total_reviews integer, total_bookings integer, total_revenue numeric, distance_km double precision, base_latitude double precision, base_longitude double precision, is_identity_verified boolean, is_background_checked boolean)
LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        w.id,
        w.name,
        w.profile_image_url as profile_image,
        w.bio,
        w.specialties,
        fd.freelancer_type,
        fd.freelancer_types,
        fd.tools,
        fd.can_travel,
        fd.travel_radius_km,
        COALESCE(fd.rating, 0) as average_rating,
        COALESCE(fd.total_reviews, 0) as total_reviews,
        COALESCE(fd.total_bookings, 0) as total_bookings,
        COALESCE(fd.total_revenue, 0) as total_revenue,
        ROUND(
            (ST_Distance(
                ST_SetSRID(ST_MakePoint(p_user_lng, p_user_lat), 4326)::geography,
                ST_SetSRID(ST_MakePoint(fd.base_longitude, fd.base_latitude), 4326)::geography
            ) / 1000)::NUMERIC,
            2
        )::DOUBLE PRECISION as distance_km,
        fd.base_latitude,
        fd.base_longitude,
        COALESCE(fd.is_identity_verified, false) as is_identity_verified,
        COALESCE(fd.is_background_checked, false) as is_background_checked
    FROM workers w
    INNER JOIN freelancer_details fd ON w.id = fd.worker_id
    WHERE w.is_freelancer = true
        AND w.is_active = true
        AND w.verification_status = 'approved'  -- verification gate
        AND fd.base_latitude IS NOT NULL
        AND fd.base_longitude IS NOT NULL
        AND ST_DWithin(
            ST_SetSRID(ST_MakePoint(p_user_lng, p_user_lat), 4326)::geography,
            ST_SetSRID(ST_MakePoint(fd.base_longitude, fd.base_latitude), 4326)::geography,
            LEAST(fd.travel_radius_km, p_radius_km) * 1000
        )
        AND (p_freelancer_type IS NULL OR fd.freelancer_type = p_freelancer_type OR p_freelancer_type = ANY(fd.freelancer_types))
        AND (p_min_rating IS NULL OR COALESCE(fd.rating, 0) >= p_min_rating)
    ORDER BY
        CASE
            WHEN p_sort_by = 'distance' THEN distance_km
            WHEN p_sort_by = 'rating' THEN fd.rating
            WHEN p_sort_by = 'revenue' THEN fd.total_revenue
            ELSE distance_km
        END ASC
    LIMIT p_page_limit
    OFFSET p_page_offset;
END;
$function$;

-- ───────────────────────────────────────────────────────────────────────────
-- get_nearby_freelancers (overload B: p_freelancer_types text[], ...)
-- ───────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_nearby_freelancers(
  p_user_lat double precision,
  p_user_lng double precision,
  p_radius_km double precision DEFAULT 10,
  p_freelancer_types text[] DEFAULT NULL::text[],
  p_min_rating numeric DEFAULT NULL::numeric,
  p_sort_by text DEFAULT 'distance'::text,
  p_page_limit integer DEFAULT 20,
  p_page_offset integer DEFAULT 0
)
RETURNS TABLE(worker_id uuid, name text, profile_image text, bio text, specialties text[], freelancer_type text, freelancer_types text[], tools text[], can_travel boolean, travel_radius_km integer, average_rating numeric, total_reviews integer, total_bookings integer, total_revenue numeric, distance_km double precision, base_latitude double precision, base_longitude double precision, is_identity_verified boolean, is_background_checked boolean)
LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT
    w.id as worker_id,
    w.name,
    w.profile_image_url as profile_image,
    w.bio,
    w.specialties,
    fd.freelancer_type,
    fd.freelancer_types,
    fd.tools,
    fd.can_travel,
    fd.travel_radius_km,
    COALESCE(fd.rating, 0) as average_rating,
    COALESCE(fd.total_reviews, 0) as total_reviews,
    COALESCE(fd.total_bookings, 0) as total_bookings,
    COALESCE(fd.total_revenue, 0) as total_revenue,
    ROUND(
      (ST_Distance(
        ST_SetSRID(ST_MakePoint(p_user_lng, p_user_lat), 4326)::geography,
        ST_SetSRID(ST_MakePoint(fd.base_longitude, fd.base_latitude), 4326)::geography
      ) / 1000)::NUMERIC,
      2
    )::DOUBLE PRECISION as distance_km,
    fd.base_latitude,
    fd.base_longitude,
    COALESCE(fd.is_identity_verified, false) as is_identity_verified,
    COALESCE(fd.is_background_checked, false) as is_background_checked
  FROM workers w
  INNER JOIN freelancer_details fd ON w.id = fd.worker_id
  WHERE
    w.is_freelancer = true
    AND w.is_active = true
    AND w.verification_status = 'approved'  -- verification gate
    AND fd.base_latitude IS NOT NULL
    AND fd.base_longitude IS NOT NULL
    AND ST_DWithin(
      ST_SetSRID(ST_MakePoint(fd.base_longitude, fd.base_latitude), 4326)::geography,
      ST_SetSRID(ST_MakePoint(p_user_lng, p_user_lat), 4326)::geography,
      p_radius_km * 1000
    )
    AND (p_freelancer_types IS NULL OR fd.freelancer_type = ANY(p_freelancer_types))
    AND (p_min_rating IS NULL OR COALESCE(fd.rating, 0) >= p_min_rating)
  ORDER BY
    CASE
      WHEN p_sort_by = 'rating' THEN fd.rating
      ELSE NULL
    END DESC NULLS LAST,
    CASE
      WHEN p_sort_by = 'distance' THEN distance_km
      ELSE NULL
    END ASC NULLS LAST
  LIMIT p_page_limit
  OFFSET p_page_offset;
END;
$function$;

-- ───────────────────────────────────────────────────────────────────────────
-- get_nearby_shops
-- The `verified_only` parameter remains for backward compatibility, but the
-- verification gate is now UNCONDITIONAL: only approved shops are ever returned,
-- regardless of the caller's verified_only value.
-- ───────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_nearby_shops(
  user_lat double precision,
  user_lng double precision,
  radius_km double precision DEFAULT 2.0,
  filter_luxury_level text DEFAULT NULL::text,
  verified_only boolean DEFAULT false,
  sort_by text DEFAULT 'distance'::text,
  cursor_id text DEFAULT NULL::text,
  page_limit integer DEFAULT 20
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
    AND (cursor_id IS NULL OR s.id::TEXT > cursor_id)
  ORDER BY
    CASE WHEN sort_by = 'distance' THEN distance_km END ASC,
    CASE WHEN sort_by = 'rating' THEN s.average_rating END DESC,
    CASE WHEN sort_by = 'name' THEN s.shop_name END ASC
  LIMIT page_limit;
END;
$function$;
