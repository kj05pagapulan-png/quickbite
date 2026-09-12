-- QuickBite production schema for Supabase.
create extension if not exists pgcrypto;

create table if not exists restaurants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text,
  description text,
  image_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists dishes (
  id uuid primary key default gen_random_uuid(),
  restaurant_id uuid not null references restaurants(id) on delete cascade,
  name text not null,
  description text,
  price numeric(12,2) not null check (price >= 0),
  image_url text,
  is_available boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists orders (
  id uuid primary key default gen_random_uuid(),
  order_number text unique not null,
  order_type text not null check (order_type in ('food','pabili')),
  customer_name text not null,
  customer_phone text not null,
  delivery_address text not null,
  landmark text,
  notes text,
  subtotal numeric(12,2) not null default 0,
  service_fee numeric(12,2) not null default 0,
  delivery_fee numeric(12,2) not null default 0,
  total numeric(12,2) not null default 0,
  payment_method text not null default 'cod',
  payment_status text not null default 'pending',
  order_status text not null default 'pending',
  pabili_store text,
  pabili_list text,
  pabili_budget numeric(12,2),
  pabili_photo_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  dish_id uuid references dishes(id) on delete set null,
  dish_name text not null,
  quantity integer not null check (quantity > 0),
  unit_price numeric(12,2) not null check (unit_price >= 0),
  subtotal numeric(12,2) generated always as (quantity * unit_price) stored
);

create table if not exists pabili_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  item_name text not null,
  quantity_text text,
  preferred_brand text,
  notes text,
  estimated_price numeric(12,2),
  actual_price numeric(12,2),
  item_status text not null default 'requested'
);

create table if not exists order_status_history (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  status text not null,
  changed_at timestamptz not null default now()
);

create table if not exists payments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  method text not null,
  amount numeric(12,2) not null default 0,
  reference_number text,
  proof_url text,
  status text not null default 'pending',
  created_at timestamptz not null default now()
);

-- Public customer access:
alter table restaurants enable row level security;
alter table dishes enable row level security;
alter table orders enable row level security;
alter table order_items enable row level security;
alter table order_status_history enable row level security;

drop policy if exists "public read active restaurants" on restaurants;
create policy "public read active restaurants" on restaurants for select using (is_active = true);

drop policy if exists "public read available dishes" on dishes;
create policy "public read available dishes" on dishes for select using (is_available = true);

drop policy if exists "public create orders" on orders;
create policy "public create orders" on orders for insert with check (true);

drop policy if exists "public read orders by order number" on orders;
create policy "public read orders by order number" on orders for select using (true);

drop policy if exists "public create order items" on order_items;
create policy "public create order items" on order_items for insert with check (true);

drop policy if exists "public read order status history" on order_status_history;
create policy "public read order status history" on order_status_history for select using (true);

drop policy if exists "public create order status history" on order_status_history;
create policy "public create order status history" on order_status_history for insert with check (true);

-- Admin writes should be protected with Supabase Auth in the next security-hardening step.
-- Do NOT expose a service-role/secret key in index.html.
