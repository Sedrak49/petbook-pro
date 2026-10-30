-- Pet profile avatar and cover images. Apply after platform foundation.
alter table public.pets add column if not exists cover_url text;
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values ('pet-images','pet-images',true,5242880,array['image/jpeg','image/png','image/webp'])
on conflict(id) do update set public=true,file_size_limit=5242880,allowed_mime_types=array['image/jpeg','image/png','image/webp'];
create policy "public pet image reads" on storage.objects for select using(bucket_id='pet-images');
create policy "owner uploads pet images" on storage.objects for insert to authenticated
with check(bucket_id='pet-images' and (storage.foldername(name))[1]=(select auth.uid())::text
 and exists(select 1 from public.pets p where p.id::text=(storage.foldername(name))[2] and p.owner_id=(select auth.uid())));
create policy "owner deletes pet images" on storage.objects for delete to authenticated
using(bucket_id='pet-images' and (storage.foldername(name))[1]=(select auth.uid())::text
 and exists(select 1 from public.pets p where p.id::text=(storage.foldername(name))[2] and p.owner_id=(select auth.uid())));
