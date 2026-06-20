-- supabase/migrations/20260620140000_discover_rpcs.sql
-- Discovery RPCs with per-session seeded ordering. Default mode shuffles by
-- md5(id || seed) so a fixed seed gives a stable permutation across offset
-- pages; explicit sorts take precedence. All keep the verification gate.

-- ── discover_shops ──────────────────────────────────────────────────────────
-- NOTE: shops_with_cover is a live-DB view that does NOT expose
-- verification_status. We join the base shops table solely for the gate,
-- and select display columns (including cover_image_url) from the view.
create or replace function public.discover_shops(
  p_seed int default 0,
  p_search text default null,
  p_shop_type text default null,
  p_luxury_level text default null,
  p_min_rating numeric default null,
  p_sort_by text default null,
  p_limit int default 20,
  p_offset int default 0
)
returns table(
  id uuid, shop_name text, average_rating numeric,
  number_clients_worked integer, luxury_level text, verified boolean,
  shop_type text, cover_image_url text
)
language plpgsql
as $function$
declare
  v_limit int := least(greatest(coalesce(p_limit, 20), 1), 50);
  v_offset int := greatest(coalesce(p_offset, 0), 0);
begin
  return query
  select s.id, s.shop_name, s.average_rating, s.number_clients_worked,
         s.luxury_level, s.verified, s.shop_type, s.cover_image_url
  from public.shops_with_cover s
  join public.shops base on base.id = s.id
  where base.verification_status = 'approved'
    and (p_search is null or p_search = '' or s.shop_name ilike '%' || p_search || '%')
    and (p_shop_type is null or p_shop_type = '' or s.shop_type = p_shop_type)
    and (p_luxury_level is null or p_luxury_level = '' or s.luxury_level = p_luxury_level)
    and (p_min_rating is null or s.average_rating >= p_min_rating)
  order by
    case when p_sort_by = 'rating' then s.average_rating end desc nulls last,
    case when p_sort_by = 'name'   then s.shop_name end asc nulls last,
    -- default (and final tie-break): seeded shuffle
    md5(s.id::text || p_seed::text)
  limit v_limit offset v_offset;
end;
$function$;

-- ── discover_products ───────────────────────────────────────────────────────
-- Returns product columns + the embedded shop fields ProductModel.fromJson
-- reads. Gate: product active AND its shop approved (mirrors products_read_active).
-- ProductModel.fromJson reads json['shops'] as a nested map with keys:
-- shop_name, verified (and optionally luxury_level, average_rating).
-- We embed these via to_jsonb(p) || jsonb_build_object('shops', ...) so the
-- RPC returns a single `product` jsonb column matching the DTO shape exactly.
create or replace function public.discover_products(
  p_seed int default 0,
  p_category text default null,
  p_min_price numeric default null,
  p_max_price numeric default null,
  p_sort_by text default null,
  p_limit int default 20,
  p_offset int default 0
)
returns table(product jsonb)
language plpgsql
as $function$
declare
  v_limit int := least(greatest(coalesce(p_limit, 20), 1), 50);
  v_offset int := greatest(coalesce(p_offset, 0), 0);
begin
  return query
  select to_jsonb(p) || jsonb_build_object(
           'shops', jsonb_build_object(
             'id', s.id, 'shop_name', s.shop_name, 'verified', s.verified,
             'luxury_level', s.luxury_level, 'average_rating', s.average_rating
           )
         ) as product
  from public.products p
  join public.shops s on s.id = p.shop_id
  join public.profiles pr on pr.id = s.user_id
  where p.is_active = true
    and pr.account_status = 'active'
    and s.verification_status = 'approved'
    and (p_category is null or p_category = '' or p.category = p_category)
    and (p_min_price is null or p.price >= p_min_price)
    and (p_max_price is null or p.price <= p_max_price)
  order by
    case when p_sort_by = 'price_low'  then p.price end asc nulls last,
    case when p_sort_by = 'price_high' then p.price end desc nulls last,
    case when p_sort_by = 'popular'    then p.total_orders_count end desc nulls last,
    case when p_sort_by = 'recent'     then p.created_at end desc nulls last,
    md5(p.id::text || p_seed::text)
  limit v_limit offset v_offset;
end;
$function$;
