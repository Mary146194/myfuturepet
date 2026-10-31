-- ============================================================================
-- Success Stories: only alumni adopters (and shelter staff) may post them
-- ============================================================================
-- Project: My Future Pet (Supabase szdjfucozmsxqjvctptv)
--
-- Additive and non-destructive:
--   * creates one helper function and two RESTRICTIVE policies
--   * does not drop, alter or replace any existing policy, table or row
--
-- A RESTRICTIVE policy is ANDed with the table's existing (permissive)
-- policies, so all current rules (e.g. author_id = auth.uid()) keep applying,
-- and this adds one more condition on top:
--
--   category is not 'Success Stories'
--   OR the poster is shelter staff / admin
--   OR pet_id is a pet the poster adopted
--      (their adoption_applications row is 'approved' AND the pet is 'adopted')
--
-- Tips, Announcements and posts with no category are unaffected.
--
-- Run in: Supabase Dashboard -> SQL Editor -> New query -> Run.
-- ============================================================================

begin;

-- 1. Helper: may the signed-in user post a Success Story about this pet?
--    SECURITY DEFINER so the check can read adoption_applications / pets
--    regardless of their own RLS; search_path is pinned for safety.
create or replace function public.can_post_success_story(p_pet_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select
    -- Shelter staff and admins may post stories on an adopter's behalf.
    exists (
      select 1
      from public.profiles pr
      where pr.id = auth.uid()
        and pr.role in ('shelter_staff', 'admin')
    )
    or (
      p_pet_id is not null
      and exists (
        select 1
        from public.adoption_applications a
        join public.pets p on p.id = a.pet_id
        where a.applicant_id = auth.uid()
          and a.pet_id = p_pet_id
          and a.status = 'approved'
          and p.status = 'adopted'
      )
    );
$$;

revoke all on function public.can_post_success_story(uuid) from public;
grant execute on function public.can_post_success_story(uuid) to authenticated;

-- 2a. New posts: Success Stories need an alumni pet.
drop policy if exists "success_stories_alumni_only_insert" on public.community_posts;
create policy "success_stories_alumni_only_insert"
  on public.community_posts
  as restrictive
  for insert
  to authenticated
  with check (
    category is distinct from 'Success Stories'
    or public.can_post_success_story(pet_id)
  );

-- 2b. Edits: a post can't be switched into a Success Story (or re-tagged to
--     someone else's pet) to get around 2a. USING (true) leaves which rows
--     may be edited to the existing policies.
drop policy if exists "success_stories_alumni_only_update" on public.community_posts;
create policy "success_stories_alumni_only_update"
  on public.community_posts
  as restrictive
  for update
  to authenticated
  using (true)
  with check (
    category is distinct from 'Success Stories'
    or public.can_post_success_story(pet_id)
  );

commit;


-- ============================================================================
-- 3. OPTIONAL: story photo uploads
-- ============================================================================
-- The app uploads story photos to bucket 'pet-photos' at
--   stories/<user id>_<timestamp>.jpg
-- Run this ONLY if a real upload from the app fails with a permission error
-- (avatars already upload to the same bucket under avatars/). It is additive:
-- it lets each user upload only into their own stories/<their id>_ prefix.
--
-- drop policy if exists "story_photos_owner_upload" on storage.objects;
-- create policy "story_photos_owner_upload"
--   on storage.objects
--   for insert
--   to authenticated
--   with check (
--     bucket_id = 'pet-photos'
--     and starts_with(name, 'stories/' || auth.uid()::text || '_')
--   );


-- ============================================================================
-- 4. VERIFY (read-only)
-- ============================================================================
-- Both new policies should be listed with permissive = 'RESTRICTIVE':
--
-- select policyname, permissive, cmd, with_check
-- from pg_policies
-- where schemaname = 'public' and tablename = 'community_posts'
-- order by policyname;
--
-- Then in the app:
--   * account WITHOUT an adopted pet -> posting a Success Story is refused
--   * adopter whose pet is marked adopted -> the story posts
--   * posting a Tip works for everyone as before


-- ============================================================================
-- 5. ROLLBACK (if ever needed) - removes only what this script added
-- ============================================================================
-- drop policy if exists "success_stories_alumni_only_insert" on public.community_posts;
-- drop policy if exists "success_stories_alumni_only_update" on public.community_posts;
-- drop function if exists public.can_post_success_story(uuid);
