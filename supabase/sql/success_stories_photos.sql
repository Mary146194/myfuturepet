-- ============================================================================
-- Success Stories: photo uploads
-- ============================================================================
-- Project: My Future Pet (Supabase szdjfucozmsxqjvctptv)
--
-- Fixes "new row violates row-level security policy" (403) when an adopter
-- attaches a photo to a Success Story. The app uploads story photos to:
--     pet-photos/stories/<user id>_<timestamp>.jpg
-- and the existing pet-photos policies did not allow that folder.
--
-- Additive and non-destructive: adds policies on storage.objects for the
-- stories/ folder of the existing pet-photos bucket only. Does not change the
-- bucket, other folders (avatars/, uploads/), or any existing files.
--
-- Run in: Supabase Dashboard -> SQL Editor -> New query -> Run.
-- ============================================================================

begin;

-- Each signed-in user may upload only files named stories/<their id>_...
drop policy if exists "story_photos_owner_upload" on storage.objects;
create policy "story_photos_owner_upload"
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'pet-photos'
    and starts_with(name, 'stories/' || auth.uid()::text || '_')
  );

-- Owners may remove their own story photos.
drop policy if exists "story_photos_owner_delete" on storage.objects;
create policy "story_photos_owner_delete"
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'pet-photos'
    and starts_with(name, 'stories/' || auth.uid()::text || '_')
  );

-- pet-photos is a public bucket, so photos already display by URL; this keeps
-- API reads of the stories/ folder working too.
drop policy if exists "story_photos_public_read" on storage.objects;
create policy "story_photos_public_read"
  on storage.objects
  for select
  to anon, authenticated
  using (
    bucket_id = 'pet-photos'
    and starts_with(name, 'stories/')
  );

commit;


-- ============================================================================
-- VERIFY (read-only)
-- ============================================================================
-- select policyname, cmd from pg_policies
--  where schemaname = 'storage' and tablename = 'objects'
--    and policyname like 'story_photos_%';


-- ============================================================================
-- ROLLBACK (only what this script added)
-- ============================================================================
-- drop policy if exists "story_photos_owner_upload" on storage.objects;
-- drop policy if exists "story_photos_owner_delete" on storage.objects;
-- drop policy if exists "story_photos_public_read" on storage.objects;
