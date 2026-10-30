-- MVP social interactions; run after platform foundation and RLS migrations.
create table if not exists public.post_likes (
 post_id uuid not null references public.posts(id) on delete cascade,
 user_id uuid not null references public.profiles(id) on delete cascade,
 created_at timestamptz not null default now(),
 primary key(post_id,user_id)
);
create table if not exists public.pet_friendships (
 pet_a uuid not null references public.pets(id) on delete cascade,
 pet_b uuid not null references public.pets(id) on delete cascade,
 requested_by uuid not null references public.profiles(id) on delete cascade,
 status text not null default 'pending' check(status in ('pending','accepted')),
 created_at timestamptz not null default now(),
 primary key(pet_a,pet_b),
 check(pet_a < pet_b)
);
alter table public.post_likes enable row level security;
alter table public.pet_friendships enable row level security;
create policy "likes visible with posts" on public.post_likes for select using(exists(select 1 from public.posts where id=post_id));
create policy "like own" on public.post_likes for insert with check(user_id=(select auth.uid()) and exists(select 1 from public.posts where id=post_id));
create policy "unlike own" on public.post_likes for delete using(user_id=(select auth.uid()));
create policy "friendships visible to owners or public pets" on public.pet_friendships for select using (
 exists(select 1 from public.pets p where p.id=pet_a and (p.visibility='public' or p.owner_id=(select auth.uid())))
 and exists(select 1 from public.pets p where p.id=pet_b and (p.visibility='public' or p.owner_id=(select auth.uid())))
);
create policy "request friendship as pet owner" on public.pet_friendships for insert with check (
 status='pending' and requested_by=(select auth.uid())
 and exists(select 1 from public.pets p where p.id=pet_a and p.owner_id=(select auth.uid()))
 and exists(select 1 from public.pets p where p.id=pet_b and p.owner_id<>(select auth.uid()) and p.visibility='public')
 or
 status='pending' and requested_by=(select auth.uid())
 and exists(select 1 from public.pets p where p.id=pet_b and p.owner_id=(select auth.uid()))
 and exists(select 1 from public.pets p where p.id=pet_a and p.owner_id<>(select auth.uid()) and p.visibility='public')
);
create policy "accept received friendship" on public.pet_friendships for update using (
 status='pending' and requested_by<>(select auth.uid())
 and (public.owns_pet(pet_a) or public.owns_pet(pet_b))
) with check (
 status='accepted' and requested_by<>(select auth.uid())
 and (public.owns_pet(pet_a) or public.owns_pet(pet_b))
);
create policy "remove own pet friendship" on public.pet_friendships for delete using(public.owns_pet(pet_a) or public.owns_pet(pet_b));
create index if not exists pet_friendships_b_idx on public.pet_friendships(pet_b);
create index if not exists post_likes_user_idx on public.post_likes(user_id);
