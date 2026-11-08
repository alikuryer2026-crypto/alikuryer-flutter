-- Run in Supabase SQL Editor. Repeat-safe demo data.
INSERT INTO public.restaurants (name, address, is_active)
SELECT 'Alikuryer Test Restoran', 'Namangan', true
WHERE NOT EXISTS (
  SELECT 1 FROM public.restaurants WHERE name = 'Alikuryer Test Restoran'
);

INSERT INTO public.menu_items (restaurant_id, name, price_uzs, is_available)
SELECT r.id, 'Namangan oshi', 35000, true
FROM public.restaurants r
WHERE r.name = 'Alikuryer Test Restoran'
  AND NOT EXISTS (
    SELECT 1 FROM public.menu_items m
    WHERE m.restaurant_id = r.id AND m.name = 'Namangan oshi'
  );
