-- PetBook Pro foundation. Run in the PetBook Pro Supabase SQL editor.
create extension if not exists pgcrypto;
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 display_name text not null default '',
 bio text not null default '',
 avatar_url text,
 role text not null default 'member' check(role in ('member','breeder','vet','admin')),
 created_at timestamptz not null default now()
);
create table if not exists public.pets (
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null references public.profiles(id) on delete cascade,
 name text not null check(length(name) between 1 and 120),
 species text not null,
 breed text, birth_date date, sex text check(sex in ('male','female','unknown')),
 description text, photo_url text,
 visibility text not null default 'public' check(visibility in ('public','private')),
 created_at timestamptz not null default now()
);
create table if not exists public.pet_relations (
 pet_id uuid not null references public.pets(id) on delete cascade,
 parent_id uuid not null references public.pets(id) on delete cascade,
 relation text not null check(relation in ('mother','father')),
 primary key(pet_id,relation),
 check(pet_id <> parent_id)
);
create table if not exists public.health_records (
 id uuid primary key default gen_random_uuid(),
 pet_id uuid not null references public.pets(id) on delete cascade,
 category text not null check(category in ('vaccination','visit','medication','other')),
 title text not null, notes text, occurred_on date not null,
 next_due_on date, created_at timestamptz not null default now()
);
create table if not exists public.posts (
 id uuid primary key default gen_random_uuid(),
 author_id uuid not null references public.profiles(id) on delete cascade,
 pet_id uuid references public.pets(id) on delete set null,
 body text not null check(length(body) between 1 and 5000),
 created_at timestamptz not null default now()
);
create table if not exists public.comments (
 id uuid primary key default gen_random_uuid(),
 post_id uuid not null references public.posts(id) on delete cascade,
 author_id uuid not null references public.profiles(id) on delete cascade,
 body text not null check(length(body) between 1 and 2000),
 created_at timestamptz not null default now()
);
create table if not exists public.follows (
 follower_id uuid not null references public.profiles(id) on delete cascade,
 following_id uuid not null references public.profiles(id) on delete cascade,
 created_at timestamptz not null default now(),
 primary key(follower_id,following_id),
 check(follower_id <> following_id)
);
create table if not exists public.listings (
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null references public.profiles(id) on delete cascade,
 category text not null check(category in ('adoption','sale','service','other')),
 title text not null, description text not null,
 city text, price numeric(12,2) check(price >= 0),
 currency text default 'AMD',
 status text not null default 'active' check(status in ('active','closed','hidden')),
 created_at timestamptz not null default now()
);
create table if not exists public.conversations (
 id uuid primary key default gen_random_uuid(),
 member_a uuid not null references public.profiles(id) on delete cascade,
 member_b uuid not null references public.profiles(id) on delete cascade,
 created_at timestamptz not null default now(),
 check(member_a <> member_b),
 unique(member_a,member_b)
);
create table if not exists public.messages (
 id uuid primary key default gen_random_uuid(),
 conversation_id uuid not null references public.conversations(id) on delete cascade,
 sender_id uuid not null references public.profiles(id) on delete cascade,
 body text not null check(length(body) between 1 and 5000),
 created_at timestamptz not null default now()
);
