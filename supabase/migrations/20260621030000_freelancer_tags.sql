-- supabase/migrations/20260621030000_freelancer_tags.sql
-- Freelancer tags = workers.specialties text[]. Adds a tag-count RPC for the
-- discover chip row, and a p_tags overlap filter on get_nearby_freelancers
-- overload B (the text[] + paged overload the Dart repo calls).

-- ───────────────────────────────────────────────────────────────────────────
-- 1) Distinct tags + counts among discoverable freelancers within radius.
-- ───────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.freelancer_tags_with_counts(
  p_user_lat double precision DEFAULT NULL,
  p_user_lng double precision DEFAULT NULL,
  p_radius_km double precision DEFAULT NULL,
  p_limit int DEFAULT 40
)
RETURNS TABLE(tag text, count bigint)
LANGUAGE sql STABLE
AS $$
  SELECT t.tag, count(*)::bigint AS count
  FROM public.workers w
  INNER JOIN public.freelancer_details fd ON w.id = fd.worker_id
  CROSS JOIN LATERAL unnest(w.specialties) AS t(tag)
  WHERE w.is_freelancer = true
    AND w.is_active = true
    AND w.verification_status = 'approved'
    AND (
      p_user_lat IS NULL OR p_user_lng IS NULL OR p_radius_km IS NULL
      OR (
        fd.base_latitude IS NOT NULL AND fd.base_longitude IS NOT NULL
        AND ST_DWithin(
          ST_SetSRID(ST_MakePoint(fd.base_longitude, fd.base_latitude), 4326)::geography,
          ST_SetSRID(ST_MakePoint(p_user_lng, p_user_lat), 4326)::geography,
          p_radius_km * 1000
        )
      )
    )
  GROUP BY t.tag
  ORDER BY count DESC, t.tag ASC
  LIMIT least(greatest(coalesce(p_limit, 40), 1), 100);
$$;

-- ───────────────────────────────────────────────────────────────────────────
-- 2) Drop the exact prior overload-B signature, then recreate with p_tags.
--    DROP-before-CREATE avoids PGRST203 ambiguity from a new overload.
--    Overload A (p_freelancer_type text, singular) is NOT touched.
-- ───────────────────────────────────────────────────────────────────────────
DROP FUNCTION IF EXISTS public.get_nearby_freelancers(
  double precision,
  double precision,
  double precision,
  text[],
  numeric,
  text,
  integer,
  integer,
  int
);

CREATE OR REPLACE FUNCTION public.get_nearby_freelancers(
  p_user_lat double precision,
  p_user_lng double precision,
  p_radius_km double precision DEFAULT 10,
  p_freelancer_types text[] DEFAULT NULL::text[],
  p_min_rating numeric DEFAULT NULL::numeric,
  p_sort_by text DEFAULT 'distance'::text,
  p_page_limit integer DEFAULT 20,
  p_page_offset integer DEFAULT 0,
  p_seed int DEFAULT 0,
  p_tags text[] DEFAULT NULL::text[]
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
    AND (p_tags IS NULL OR array_length(p_tags, 1) IS NULL
         OR w.specialties && p_tags)
  ORDER BY
    CASE WHEN p_sort_by = 'rating' THEN fd.rating END DESC NULLS LAST,
    CASE WHEN p_sort_by NOT IN ('rating') THEN floor(
      ROUND(
        (ST_Distance(
          ST_SetSRID(ST_MakePoint(p_user_lng, p_user_lat), 4326)::geography,
          ST_SetSRID(ST_MakePoint(fd.base_longitude, fd.base_latitude), 4326)::geography
        ) / 1000)::NUMERIC,
        2
      ) / 2.0
    ) END ASC NULLS LAST,
    CASE WHEN p_sort_by NOT IN ('rating') THEN md5(w.id::text || p_seed::text) END ASC NULLS LAST
  LIMIT p_page_limit
  OFFSET p_page_offset;
END;
$function$;
