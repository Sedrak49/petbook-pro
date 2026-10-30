-- Public post photos: 5MB max, image formats only. Apply after foundation migrations.
alter table public.posts add column if not exists photo_url text;
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('post-photos','post-photos',true,5242880,array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public=true,file_size_limit=5242880,allowed_mime_types=array['image/jpeg','image/png','image/webp'];
create policy "read post photos" on storage.objects for select using(bucket_id='post-photos');
create policy "upload own post photos" on storage.objects for insert to authenticated
with check(bucket_id='post-photos' and (storage.foldername(name))[1]=(select auth.uid())::text);
create policy "delete own post photos" on storage.objects for delete to authenticated
using(bucket_id='post-photos' and (storage.foldername(name))[1]=(select auth.uid())::text);
