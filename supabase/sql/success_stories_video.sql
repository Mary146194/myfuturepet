-- ============================================================================
-- Success Stories: video support
-- ============================================================================
-- Project: My Future Pet (Supabase szdjfucozmsxqjvctptv)
--
-- Additive and non-destructive:
--   * adds a nullable column community_posts.video_url (existing rows untouched)
--   * creates a public storage bucket 'story-videos' (skipped if it exists)
--   * adds upload/read policies for that bucket only
--
-- Run in: Supabase Dashboard -> SQL Editor -> New query -> Run.
-- Run AFTER (or independently of) success_stories_alumni_only.sql; the
-- alumni-only policies already cover video posts, since they check category
-- and pet_id, not the media type.
-- ============================================================================

begin;

-- 1. Where a story's video lives. image_url stays as the poster/thumbnail.
alter table public.community_posts
  add column if not exists video_url text;

comment on column public.community_posts.video_url is
  'Public URL of a Success Story video (story-videos bucket). image_url is its poster.';

-- 2. Public bucket for story videos: 50 MB cap, video types only.
--    (50 MB is also the Supabase free-plan per-file maximum.)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'story-videos',
  'story-videos',
  true,
  52428800,
  array['video/mp4', 'video/quicktime', 'video/webm', 'video/3gpp']
)
on conflict (id) do nothing;

-- 3. Each signed-in user may upload only into their own prefix:
--      story-videos/<user id>/<file>
drop policy if exists "story_videos_owner_upload" on storage.objects;
create policy "story_videos_owner_upload"
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'story-videos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Owners may remove their own videos (e.g. if a post is deleted).
drop policy if exists "story_videos_owner_delete" on storage.objects;
create policy "story_videos_owner_delete"
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'story-videos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Public bucket URLs are readable without a policy; this keeps listing/reads
-- working for the API as well.
drop policy if exists "story_videos_public_read" on storage.objects;
create policy "story_videos_public_read"
  on storage.objects
  for select
  to anon, authenticated
  using (bucket_id = 'story-videos');

commit;


-- ============================================================================
-- VERIFY (read-only)
-- ============================================================================
-- select column_name, data_type from information_schema.columns
--  where table_schema = 'public' and table_name = 'community_posts'
--    and column_name = 'video_url';
--
-- select id, public, file_size_limit, allowed_mime_types
--   from storage.buckets where id = 'story-videos';


-- ============================================================================
-- ROLLBACK (only what this script added; deleting the bucket requires it to
-- be empty, and dropping the column deletes stored video links)
-- ============================================================================
-- drop policy if exists "story_videos_owner_upload" on storage.objects;
-- drop policy if exists "story_videos_owner_delete" on storage.objects;
-- drop policy if exists "story_videos_public_read" on storage.objects;
-- delete from storage.buckets where id = 'story-videos';
-- alter table public.community_posts drop column if exists video_url;
