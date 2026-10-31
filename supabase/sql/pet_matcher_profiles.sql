-- ============================================================================
-- Smart Matching (Pet Matcher): answers saved per account
-- ============================================================================
-- Project: My Future Pet (Supabase szdjfucozmsxqjvctptv)
--
-- Stores each user's Pet Matcher quiz answers, and whether they finished or
-- skipped it, so the "first login" quiz and match scores follow the account
-- across phones.
--
-- Additive and non-destructive: creates one new table with row-level
-- security. Does not touch profiles, auth, or any existing table.
--
-- Run in: Supabase Dashboard -> SQL Editor -> New query -> Run.
-- ============================================================================

begin;

create table if not exists public.pet_matcher_profiles (
  user_id    uuid primary key default auth.uid()
             references auth.users (id) on delete cascade,
  -- {"species":"dog","home":"yard",...}; null when the user skipped the quiz.
  answers    jsonb,
  status     text not null default 'completed'
             check (status in ('completed', 'skipped')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.pet_matcher_profiles is
  'Pet Matcher (Smart Matching) quiz answers per user; shown before Home on first login until completed or skipped.';

alter table public.pet_matcher_profiles enable row level security;

-- Each signed-in user can only see and change their own row.
drop policy if exists "pet_matcher_select_own" on public.pet_matcher_profiles;
create policy "pet_matcher_select_own"
  on public.pet_matcher_profiles
  for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "pet_matcher_insert_own" on public.pet_matcher_profiles;
create policy "pet_matcher_insert_own"
  on public.pet_matcher_profiles
  for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "pet_matcher_update_own" on public.pet_matcher_profiles;
create policy "pet_matcher_update_own"
  on public.pet_matcher_profiles
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

grant select, insert, update on public.pet_matcher_profiles to authenticated;

commit;


-- ============================================================================
-- VERIFY (read-only)
-- ============================================================================
-- select user_id, status, answers, updated_at
--   from public.pet_matcher_profiles
--  order by updated_at desc
--  limit 20;


-- ============================================================================
-- ROLLBACK (removes only this table and the answers stored in it)
-- ============================================================================
-- drop table if exists public.pet_matcher_profiles;
