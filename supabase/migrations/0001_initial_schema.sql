-- BADDEL initial schema. Apply through Supabase SQL Editor or Supabase CLI.
-- Review policies before production. No payment processing is included in this release.

create extension if not exists pgcrypto;

create type public.user_role as enum ('user', 'moderator', 'support', 'admin');
create type public.listing_kind as enum ('sale', 'exchange', 'both');
create type public.listing_status as enum ('pending', 'active', 'reserved', 'sold', 'exchanged', 'rejected', 'expired', 'removed');
create type public.product_condition as enum ('new', 'like_new', 'good', 'fair', 'for_parts');
create type public.offer_status as enum ('pending', 'accepted', 'rejected', 'cancelled', 'completed');
create type public.report_status as enum ('open', 'reviewing', 'resolved', 'dismissed');

create table public.wilayas (
  id smallint primary key,
  name_ar text not null,
  name_fr text,
  is_active boolean not null default true
);

create table public.communes (
  id bigint generated always as identity primary key,
  wilaya_id smallint not null references public.wilayas(id) on delete restrict,
  name_ar text not null,
  name_fr text,
  unique (wilaya_id, name_ar)
);

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  parent_id uuid references public.categories(id) on delete set null,
  name_ar text not null,
  name_fr text,
  slug text not null unique,
  icon text,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (char_length(display_name) between 2 and 60),
  avatar_path text,
  phone text,
  wilaya_id smallint references public.wilayas(id),
  commune_id bigint references public.communes(id),
  bio text check (bio is null or char_length(bio) <= 500),
  role public.user_role not null default 'user',
  is_suspended boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.listings (
  id uuid primary key default gen_random_uuid(),
  seller_id uuid not null references public.profiles(id) on delete restrict,
  category_id uuid not null references public.categories(id),
  wilaya_id smallint not null references public.wilayas(id),
  commune_id bigint references public.communes(id),
  title text not null check (char_length(title) between 5 and 100),
  description text not null check (char_length(description) between 10 and 5000),
  kind public.listing_kind not null,
  price_dzd bigint check (price_dzd is null or price_dzd >= 0),
  condition public.product_condition not null,
  status public.listing_status not null default 'pending',
  views_count integer not null default 0 check (views_count >= 0),
  is_featured boolean not null default false,
  published_at timestamptz,
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint sale_requires_price check (kind = 'exchange' or price_dzd is not null),
  constraint exchange_has_no_required_price check (kind <> 'exchange' or price_dzd is null)
);

create index listings_public_search_idx on public.listings(status, category_id, wilaya_id, published_at desc);
create index listings_seller_idx on public.listings(seller_id, created_at desc);
create index listings_title_search_idx on public.listings using gin (to_tsvector('simple', title));

create table public.listing_images (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null references public.listings(id) on delete cascade,
  storage_path text not null unique,
  alt_text text,
  sort_order smallint not null default 0,
  created_at timestamptz not null default now()
);

create table public.favorites (
  user_id uuid not null references public.profiles(id) on delete cascade,
  listing_id uuid not null references public.listings(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, listing_id)
);

create table public.conversations (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid references public.listings(id) on delete set null,
  created_at timestamptz not null default now(),
  last_message_at timestamptz not null default now()
);

create table public.conversation_members (
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key (conversation_id, user_id)
);

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete restrict,
  body text not null check (char_length(body) between 1 and 3000),
  created_at timestamptz not null default now(),
  read_at timestamptz
);

create index messages_conversation_idx on public.messages(conversation_id, created_at desc);

create table public.exchange_offers (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null references public.listings(id) on delete restrict,
  proposer_id uuid not null references public.profiles(id) on delete restrict,
  message text check (message is null or char_length(message) <= 1000),
  cash_difference_dzd bigint not null default 0,
  status public.offer_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (listing_id, proposer_id)
);

create table public.exchange_offer_items (
  id uuid primary key default gen_random_uuid(),
  offer_id uuid not null references public.exchange_offers(id) on delete cascade,
  title text not null check (char_length(title) between 2 and 100),
  description text,
  image_path text
);

create table public.reviews (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid references public.listings(id) on delete set null,
  reviewer_id uuid not null references public.profiles(id) on delete restrict,
  reviewee_id uuid not null references public.profiles(id) on delete restrict,
  rating smallint not null check (rating between 1 and 5),
  comment text check (comment is null or char_length(comment) <= 1000),
  created_at timestamptz not null default now(),
  check (reviewer_id <> reviewee_id),
  unique (listing_id, reviewer_id, reviewee_id)
);

create table public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles(id) on delete restrict,
  target_user_id uuid references public.profiles(id) on delete set null,
  listing_id uuid references public.listings(id) on delete set null,
  reason text not null check (char_length(reason) between 5 and 1000),
  status public.report_status not null default 'open',
  moderator_note text,
  handled_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  resolved_at timestamptz,
  check (target_user_id is not null or listing_id is not null)
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  body text not null,
  href text,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  plan_code text not null,
  status text not null default 'inactive',
  starts_at timestamptz,
  ends_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.promotions (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null references public.listings(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  placement text not null,
  status text not null default 'pending',
  starts_at timestamptz,
  ends_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.transactions (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid references public.listings(id) on delete set null,
  exchange_offer_id uuid references public.exchange_offers(id) on delete set null,
  seller_id uuid not null references public.profiles(id) on delete restrict,
  buyer_id uuid references public.profiles(id) on delete restrict,
  transaction_type text not null check (transaction_type in ('sale', 'exchange')),
  agreed_price_dzd bigint check (agreed_price_dzd is null or agreed_price_dzd >= 0),
  status text not null default 'reported',
  completed_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.admin_logs (
  id bigint generated always as identity primary key,
  actor_id uuid references public.profiles(id) on delete set null,
  action text not null,
  target_table text not null,
  target_id text,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- Prevent users from granting themselves staff privileges.
create or replace function public.is_staff()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = (select auth.uid())
      and p.role in ('admin', 'moderator', 'support')
      and p.is_suspended = false
  );
$$;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = (select auth.uid())
      and p.role = 'admin'
      and p.is_suspended = false
  );
$$;

create or replace function public.is_conversation_member(target_conversation uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.conversation_members cm
    where cm.conversation_id = target_conversation
      and cm.user_id = (select auth.uid())
  );
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name)
  values (
    new.id,
    coalesce(nullif(trim(new.raw_user_meta_data ->> 'display_name'), ''), 'مستخدم جديد')
  );
  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Enable RLS on every application table.
alter table public.wilayas enable row level security;
alter table public.communes enable row level security;
alter table public.categories enable row level security;
alter table public.profiles enable row level security;
alter table public.listings enable row level security;
alter table public.listing_images enable row level security;
alter table public.favorites enable row level security;
alter table public.conversations enable row level security;
alter table public.conversation_members enable row level security;
alter table public.messages enable row level security;
alter table public.exchange_offers enable row level security;
alter table public.exchange_offer_items enable row level security;
alter table public.reviews enable row level security;
alter table public.reports enable row level security;
alter table public.notifications enable row level security;
alter table public.subscriptions enable row level security;
alter table public.promotions enable row level security;
alter table public.transactions enable row level security;
alter table public.admin_logs enable row level security;

-- Reference data is publicly readable; only admins can modify it.
create policy "active wilayas are public" on public.wilayas for select to anon, authenticated using (is_active);
create policy "active communes are public" on public.communes for select to anon, authenticated using (
  exists (select 1 from public.wilayas w where w.id = wilaya_id and w.is_active)
);
create policy "active categories are public" on public.categories for select to anon, authenticated using (is_active);
create policy "admins manage wilayas" on public.wilayas for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admins manage communes" on public.communes for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admins manage categories" on public.categories for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- Profiles: public profile fields are readable; only owner may update their own profile.
create policy "profiles readable by authenticated users" on public.profiles for select to authenticated using (true);
create policy "user updates own profile" on public.profiles for update to authenticated
using (id = (select auth.uid()) and role = 'user')
with check (id = (select auth.uid()) and role = 'user' and is_suspended = false);
create policy "staff manage profiles" on public.profiles for update to authenticated
using (public.is_staff()) with check (public.is_staff());

-- Listings: public sees active ads; owners see their own; staff can review.
create policy "public reads active listings" on public.listings for select to anon, authenticated
using (status = 'active' or seller_id = (select auth.uid()) or public.is_staff());
create policy "users create own pending listings" on public.listings for insert to authenticated
with check (seller_id = (select auth.uid()) and status = 'pending' and is_featured = false);
create policy "owners update own pending or active listings" on public.listings for update to authenticated
using (seller_id = (select auth.uid()) and status in ('pending','active','reserved'))
with check (seller_id = (select auth.uid()) and status in ('pending','active','reserved','sold','exchanged'));
create policy "staff manage listings" on public.listings for all to authenticated
using (public.is_staff()) with check (public.is_staff());

create policy "listing images readable when listing readable" on public.listing_images for select to anon, authenticated
using (exists (select 1 from public.listings l where l.id = listing_id and (l.status = 'active' or l.seller_id = (select auth.uid()) or public.is_staff())));
create policy "owners add images to own pending listing" on public.listing_images for insert to authenticated
with check (exists (select 1 from public.listings l where l.id = listing_id and l.seller_id = (select auth.uid()) and l.status = 'pending'));
create policy "owners delete own listing images" on public.listing_images for delete to authenticated
using (exists (select 1 from public.listings l where l.id = listing_id and l.seller_id = (select auth.uid())));

create policy "users manage own favorites" on public.favorites for all to authenticated
using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

-- Conversation access is membership-based.
create policy "members read conversations" on public.conversations for select to authenticated
using (public.is_conversation_member(id));
-- Conversation creation and membership are intentionally disabled in this foundation.
-- Phase 4 will add a SECURITY DEFINER RPC that validates listing owner, initiator,
-- participant pair, and duplicate conversations atomically.
create policy "members read conversation membership" on public.conversation_members for select to authenticated
using (user_id = (select auth.uid()) or public.is_conversation_member(conversation_id));
-- Direct membership inserts are intentionally disabled.
-- Only the validated conversation-creation RPC added in Phase 4 may add members.
create policy "members read messages" on public.messages for select to authenticated
using (public.is_conversation_member(conversation_id));
create policy "members send as self" on public.messages for insert to authenticated
with check (sender_id = (select auth.uid()) and public.is_conversation_member(conversation_id));

-- Exchange offers: proposer and listing owner can read; only proposer creates.
create policy "offer parties read offers" on public.exchange_offers for select to authenticated
using (
  proposer_id = (select auth.uid())
  or exists (select 1 from public.listings l where l.id = listing_id and l.seller_id = (select auth.uid()))
  or public.is_staff()
);
create policy "users create own offers" on public.exchange_offers for insert to authenticated
with check (
  proposer_id = (select auth.uid())
  and exists (select 1 from public.listings l where l.id = listing_id and l.status = 'active' and l.seller_id <> (select auth.uid()) and l.kind in ('exchange','both'))
);
create policy "offer parties update status" on public.exchange_offers for update to authenticated
using (
  proposer_id = (select auth.uid())
  or exists (select 1 from public.listings l where l.id = listing_id and l.seller_id = (select auth.uid()))
)
with check (
  proposer_id = (select auth.uid())
  or exists (select 1 from public.listings l where l.id = listing_id and l.seller_id = (select auth.uid()))
);

create policy "offer items visible to offer parties" on public.exchange_offer_items for select to authenticated
using (exists (select 1 from public.exchange_offers o where o.id = offer_id and (
  o.proposer_id = (select auth.uid()) or exists (select 1 from public.listings l where l.id = o.listing_id and l.seller_id = (select auth.uid()))
)));
create policy "proposer adds offer items" on public.exchange_offer_items for insert to authenticated
with check (exists (select 1 from public.exchange_offers o where o.id = offer_id and o.proposer_id = (select auth.uid()) and o.status = 'pending'));

-- Reviews are public to signed-in users; reviewer creates their own review.
create policy "reviews readable" on public.reviews for select to authenticated using (true);
create policy "reviewer creates own review" on public.reviews for insert to authenticated
with check (reviewer_id = (select auth.uid()) and reviewee_id <> (select auth.uid()));

create policy "reporter creates own report" on public.reports for insert to authenticated
with check (reporter_id = (select auth.uid()));
create policy "reporter and staff read reports" on public.reports for select to authenticated
using (reporter_id = (select auth.uid()) or public.is_staff());
create policy "staff updates reports" on public.reports for update to authenticated
using (public.is_staff()) with check (public.is_staff());

create policy "users read own notifications" on public.notifications for select to authenticated
using (user_id = (select auth.uid()));
create policy "users mark own notifications read" on public.notifications for update to authenticated
using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

create policy "users read own subscriptions" on public.subscriptions for select to authenticated
using (user_id = (select auth.uid()));
create policy "users read own promotions" on public.promotions for select to authenticated
using (user_id = (select auth.uid()));

create policy "transaction parties read transactions" on public.transactions for select to authenticated
using (seller_id = (select auth.uid()) or buyer_id = (select auth.uid()) or public.is_staff());

create policy "admins read admin logs" on public.admin_logs for select to authenticated
using (public.is_admin());
create policy "admins insert admin logs" on public.admin_logs for insert to authenticated
with check (public.is_admin() and actor_id = (select auth.uid()));

-- Storage: private listing media bucket. Serve through signed URLs in the app.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('listing-images', 'listing-images', false, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;

create policy "authenticated users upload to own folder"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'listing-images'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

create policy "users read only listing media linked to visible listings"
on storage.objects for select to authenticated
using (
  bucket_id = 'listing-images'
  and exists (
    select 1
    from public.listing_images li
    join public.listings l on l.id = li.listing_id
    where li.storage_path = name
      and (l.status = 'active' or l.seller_id = (select auth.uid()) or public.is_staff())
  )
);

create policy "users delete files in own folder"
on storage.objects for delete to authenticated
using (
  bucket_id = 'listing-images'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);
