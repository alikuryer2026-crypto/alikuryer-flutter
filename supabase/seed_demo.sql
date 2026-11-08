-- Safe to run more than once: creates or updates one demonstration restaurant and dish.
with restaurant as (
  insert into public.restaurants (name, address, is_active)
  select 'Alikuryer Test Restoran', 'Namangan', true
  where not exists (
    select 1 from public.restaurants where name = 'Alikuryer Test Restoran'
  )
  returning id
), selected_restaurant as (
  select id from restaurant
  union all
  select id from public.restaurants where name = 'Alikuryer Test Restoran'
)
insert into public.menu_items (restaurant_id, name, price_uzs, is_available)
select id, 'Namangan oshi', 35000, true
from selected_restaurant r
where not exists (
  select 1 from public.menu_items m
  where m.restaurant_id = r.id and m.name = 'Namangan oshi'
);
