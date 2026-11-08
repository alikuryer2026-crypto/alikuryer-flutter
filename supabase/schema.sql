-- Alikuryer initial schema. Run in Supabase SQL Editor.
create extension if not exists pgcrypto;
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 full_name text,
 phone text,
 role text not null default 'customer' check (role in ('customer','restaurant','courier','admin')),
 created_at timestamptz not null default now()
);
create table if not exists public.restaurants (
 id uuid primary key default gen_random_uuid(),
 name text not null,
 address text,
 is_active boolean not null default false,
 created_at timestamptz not null default now()
);
create table if not exists public.menu_items (
 id uuid primary key default gen_random_uuid(),
 restaurant_id uuid not null references public.restaurants(id) on delete cascade,
 name text not null,
 description text,
 price_uzs integer not null check (price_uzs >= 0),
 image_url text,
 is_available boolean not null default true
);
create table if not exists public.orders (
 id uuid primary key default gen_random_uuid(),
 customer_id uuid not null references auth.users(id),
 delivery_address text not null,
 status text not null default 'pending' check (status in ('pending','accepted','preparing','picked_up','delivered','cancelled')),
 total_uzs integer not null check (total_uzs >= 0),
 created_at timestamptz not null default now()
);
create table if not exists public.order_items (
 id uuid primary key default gen_random_uuid(),
 order_id uuid not null references public.orders(id) on delete cascade,
 menu_item_id uuid not null references public.menu_items(id),
 quantity integer not null check (quantity > 0),
 unit_price_uzs integer not null check (unit_price_uzs >= 0)
);
alter table public.profiles enable row level security;
alter table public.restaurants enable row level security;
alter table public.menu_items enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
create policy "own profile read" on public.profiles for select to authenticated using (id = auth.uid());
create policy "own profile update" on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
create policy "active restaurants public read" on public.restaurants for select to anon, authenticated using (is_active);
create policy "available menu public read" on public.menu_items for select to anon, authenticated using (is_available and exists (select 1 from public.restaurants r where r.id = restaurant_id and r.is_active));
create policy "own orders read" on public.orders for select to authenticated using (customer_id = auth.uid());
create policy "own orders create" on public.orders for insert to authenticated with check (customer_id = auth.uid() and status = 'pending');
create policy "own order items read" on public.order_items for select to authenticated using (exists (select 1 from public.orders o where o.id = order_id and o.customer_id = auth.uid()));
-- Production order submission must use a secure RPC or server function to validate item prices and totals.
