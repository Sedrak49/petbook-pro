-- RLS policies. Apply after 20261030_platform_foundation.sql.
do $$
declare t text;
begin
 foreach t in array array['profiles','pets','pet_relations','health_records','posts','comments','follows','listings','conversations','messages']
 loop execute format('alter table public.%I enable row level security',t); end loop;
end $$;
create or replace function public.owns_pet(p uuid) returns boolean language sql stable security definer set search_path=public as $$
 select exists(select 1 from public.pets where id=p and owner_id=(select auth.uid()))
$$;
create or replace function public.in_conversation(c uuid) returns boolean language sql stable security definer set search_path=public as $$
 select exists(select 1 from public.conversations where id=c and (member_a=(select auth.uid()) or member_b=(select auth.uid())))
$$;
create policy "profiles readable" on public.profiles for select using (true);
create policy "profile owner creates" on public.profiles for insert with check(id=(select auth.uid()) and role='member');
create policy "profile owner updates" on public.profiles for update using(id=(select auth.uid())) with check(id=(select auth.uid()));
-- Protect privileged role against self-promotion, including direct API writes.
create or replace function public.protect_profile_role() returns trigger language plpgsql security definer set search_path=public as $$
begin
 if new.role is distinct from old.role then
   if current_user <> 'postgres' and (select auth.role()) <> 'service_role' then
     raise exception 'Role changes require administrator service';
   end if;
 end if;
 return new;
end $$;
create trigger protect_profile_role before update on public.profiles for each row execute function public.protect_profile_role();
create policy "pets readable if public or owner" on public.pets for select using(visibility='public' or owner_id=(select auth.uid()));
create policy "pets insert by owner" on public.pets for insert with check(owner_id=(select auth.uid()));
create policy "pets update by owner" on public.pets for update using(owner_id=(select auth.uid())) with check(owner_id=(select auth.uid()));
create policy "pets delete by owner" on public.pets for delete using(owner_id=(select auth.uid()));
create policy "pedigree readable" on public.pet_relations for select using(public.owns_pet(pet_id) or exists(select 1 from public.pets p where p.id=pet_id and p.visibility='public'));
create policy "pedigree insert by owner" on public.pet_relations for insert with check(public.owns_pet(pet_id));
create policy "pedigree update by owner" on public.pet_relations for update using(public.owns_pet(pet_id)) with check(public.owns_pet(pet_id));
create policy "pedigree delete by owner" on public.pet_relations for delete using(public.owns_pet(pet_id));
create policy "health private to owner" on public.health_records for select using(public.owns_pet(pet_id));
create policy "health insert by owner" on public.health_records for insert with check(public.owns_pet(pet_id));
create policy "health update by owner" on public.health_records for update using(public.owns_pet(pet_id)) with check(public.owns_pet(pet_id));
create policy "health delete by owner" on public.health_records for delete using(public.owns_pet(pet_id));
create policy "posts readable" on public.posts for select using(true);
create policy "posts insert by author" on public.posts for insert with check(author_id=(select auth.uid()) and (pet_id is null or public.owns_pet(pet_id)));
create policy "posts update by author" on public.posts for update using(author_id=(select auth.uid())) with check(author_id=(select auth.uid()) and (pet_id is null or public.owns_pet(pet_id)));
create policy "posts delete by author" on public.posts for delete using(author_id=(select auth.uid()));
create policy "comments readable" on public.comments for select using(true);
create policy "comments insert by author" on public.comments for insert with check(author_id=(select auth.uid()));
create policy "comments update by author" on public.comments for update using(author_id=(select auth.uid())) with check(author_id=(select auth.uid()));
create policy "comments delete by author" on public.comments for delete using(author_id=(select auth.uid()));
create policy "follows readable" on public.follows for select using(true);
create policy "follows insert by follower" on public.follows for insert with check(follower_id=(select auth.uid()));
create policy "follows delete by follower" on public.follows for delete using(follower_id=(select auth.uid()));
create policy "active listings readable" on public.listings for select using(status='active' or owner_id=(select auth.uid()));
create policy "listing insert by owner" on public.listings for insert with check(owner_id=(select auth.uid()));
create policy "listing update by owner" on public.listings for update using(owner_id=(select auth.uid())) with check(owner_id=(select auth.uid()));
create policy "listing delete by owner" on public.listings for delete using(owner_id=(select auth.uid()));
create policy "conversations private" on public.conversations for select using(public.in_conversation(id));
create policy "conversations create member" on public.conversations for insert with check(member_a=(select auth.uid()) or member_b=(select auth.uid()));
create policy "messages private" on public.messages for select using(public.in_conversation(conversation_id));
create policy "messages insert by member" on public.messages for insert with check(sender_id=(select auth.uid()) and public.in_conversation(conversation_id));
create index if not exists pets_owner_idx on public.pets(owner_id);
create index if not exists posts_created_idx on public.posts(created_at desc);
create index if not exists messages_conversation_idx on public.messages(conversation_id,created_at desc);
create index if not exists listings_status_idx on public.listings(status,created_at desc);
