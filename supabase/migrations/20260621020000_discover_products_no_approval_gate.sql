-- Remove the shop approval gate from discover_products so that products
-- from any active shop are discoverable. The 'verified' flag embedded in
-- the shops JSON lets the UI show a trust badge; gating on approval was
-- too strict and caused the marketplace to show nothing for new shops.
create or replace function public.discover_products(
  p_seed int default 0,
  p_category text default null,
  p_min_price numeric default null,
  p_max_price numeric default null,
  p_sort_by text default null,
  p_user_lat double precision default null,
  p_user_lng double precision default null,
  p_radius_km double precision default null,
  p_shop_types text[] default null,
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
  select to_jsonb(p)
         || jsonb_build_object(
              'shops', jsonb_build_object(
                'id', s.id, 'shop_name', s.shop_name, 'verified', s.verified,
                'luxury_level', s.luxury_level, 'average_rating', s.average_rating,
                'currency', s.currency, 'currency_symbol', s.currency_symbol
              ),
              'distance_km',
              case
                when p_user_lat is null or p_user_lng is null
                     or sl.latitude is null or sl.longitude is null then null
                else round(
                  (ST_Distance(
                    ST_SetSRID(ST_MakePoint(p_user_lng, p_user_lat), 4326)::geography,
                    ST_SetSRID(ST_MakePoint(sl.longitude, sl.latitude), 4326)::geography
                  ) / 1000)::numeric, 2)
              end
            ) as product
  from public.products p
  join public.shops s on s.id = p.shop_id
  join public.profiles pr on pr.id = s.user_id
  left join public.shop_locations sl on sl.shop_id = s.id and sl.is_primary = true
  where p.is_active = true
    and pr.account_status = 'active'
    and (p_category is null or p_category = '' or p.category = p_category)
    and (p_min_price is null or p.price >= p_min_price)
    and (p_max_price is null or p.price <= p_max_price)
    and (p_shop_types is null or array_length(p_shop_types, 1) is null
         or p.shop_types && p_shop_types)
    and (
      p_user_lat is null or p_user_lng is null or p_radius_km is null
      or (
        sl.latitude is not null and sl.longitude is not null
        and ST_DWithin(
          ST_SetSRID(ST_MakePoint(sl.longitude, sl.latitude), 4326)::geography,
          ST_SetSRID(ST_MakePoint(p_user_lng, p_user_lat), 4326)::geography,
          p_radius_km * 1000
        )
      )
    )
  order by
    case when p_sort_by = 'price_low'  then p.price end asc nulls last,
    case when p_sort_by = 'price_high' then p.price end desc nulls last,
    case when p_sort_by = 'popular'    then p.total_orders_count end desc nulls last,
    case when p_sort_by = 'recent'     then p.created_at end desc nulls last,
    md5(p.id::text || p_seed::text)
  limit v_limit offset v_offset;
end;
$function$;
