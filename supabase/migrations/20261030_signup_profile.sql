-- Provision a member profile on confirmed or unconfirmed sign-up.
create or replace function public.create_member_profile()
returns trigger language plpgsql security definer set search_path=public as $$
begin
 insert into public.profiles(id,display_name,role)
 values(new.id,coalesce(new.raw_user_meta_data->>'display_name',''),'member')
 on conflict(id) do nothing;
 return new;
end $$;
drop trigger if exists on_auth_user_created_petbook on auth.users;
create trigger on_auth_user_created_petbook after insert on auth.users
for each row execute function public.create_member_profile();
insert into public.profiles(id,display_name,role)
select id,coalesce(raw_user_meta_data->>'display_name',''),'member'
from auth.users on conflict(id) do nothing;
