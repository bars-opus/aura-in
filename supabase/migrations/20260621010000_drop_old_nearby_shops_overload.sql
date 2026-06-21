-- Fix PGRST203 ambiguity on get_nearby_shops.
--
-- Migration 20260620160000 added a `p_page_offset` parameter to
-- get_nearby_shops. Because CREATE OR REPLACE only replaces a function with an
-- IDENTICAL argument signature, the new param produced a SECOND overload
-- instead of replacing the prior one (from 20260620150000). With both overloads
-- present and every parameter defaulted, PostgREST cannot choose between them
-- and returns PGRST203 ("Could not choose the best candidate function").
--
-- Drop the OLD overload (the one WITHOUT p_page_offset). The offset version
-- (…, page_limit integer, p_seed int, p_page_offset int) is the one the Dart
-- caller targets and is kept.

drop function if exists public.get_nearby_shops(
  user_lat double precision,
  user_lng double precision,
  radius_km double precision,
  filter_luxury_level text,
  verified_only boolean,
  sort_by text,
  cursor_id text,
  page_limit integer,
  p_seed integer
);
