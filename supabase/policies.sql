alter table public.profiles enable row level security;
alter table public.quiz_attempts enable row level security;
alter table public.friend_groups enable row level security;
alter table public.group_members enable row level security;

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
grant usage on schema private to authenticated;

create or replace function private.is_group_member(p_group_id uuid)
returns boolean
language sql
security definer
set search_path = ''
stable
as $$
  select exists (
    select 1
    from public.group_members gm
    where gm.group_id = p_group_id
      and gm.user_id = auth.uid()
  );
$$;

revoke all on function private.is_group_member(uuid) from public, anon;
grant execute on function private.is_group_member(uuid) to authenticated;

create or replace function private.is_group_owner(p_group_id uuid)
returns boolean
language sql
security definer
set search_path = ''
stable
as $$
  select exists (
    select 1
    from public.friend_groups fg
    where fg.id = p_group_id
      and fg.owner_id = auth.uid()
  );
$$;

revoke all on function private.is_group_owner(uuid) from public, anon;
grant execute on function private.is_group_owner(uuid) to authenticated;

drop policy if exists "Authenticated users can read profiles" on public.profiles;
create policy "Authenticated users can read profiles"
on public.profiles for select
to authenticated
using (true);

drop policy if exists "Users can insert own profile" on public.profiles;
create policy "Users can insert own profile"
on public.profiles for insert
to authenticated
with check ((select auth.uid()) = id);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
on public.profiles for update
to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

drop policy if exists "Users can read own attempts" on public.quiz_attempts;
create policy "Users can read own attempts"
on public.quiz_attempts for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "Users can insert own attempts" on public.quiz_attempts;
create policy "Users can insert own attempts"
on public.quiz_attempts for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "Members can read groups" on public.friend_groups;
create policy "Members can read groups"
on public.friend_groups for select
to authenticated
using (
  (select auth.uid()) = owner_id
  or private.is_group_member(id)
);

drop policy if exists "Users can create owned groups" on public.friend_groups;
create policy "Users can create owned groups"
on public.friend_groups for insert
to authenticated
with check ((select auth.uid()) = owner_id);

drop policy if exists "Owners can update groups" on public.friend_groups;
create policy "Owners can update groups"
on public.friend_groups for update
to authenticated
using ((select auth.uid()) = owner_id)
with check ((select auth.uid()) = owner_id);

drop policy if exists "Owners can delete groups" on public.friend_groups;
create policy "Owners can delete groups"
on public.friend_groups for delete
to authenticated
using ((select auth.uid()) = owner_id);

drop policy if exists "Members can read group members" on public.group_members;
create policy "Members can read group members"
on public.group_members for select
to authenticated
using (private.is_group_member(group_id));

drop policy if exists "Owners can remove group members" on public.group_members;
create policy "Owners can remove group members"
on public.group_members for delete
to authenticated
using (private.is_group_owner(group_id) and role <> 'owner');

grant usage on schema public to anon, authenticated;
grant select on public.profiles to authenticated;
revoke insert, update on public.profiles from authenticated;
grant insert (id, username, display_name, avatar_url) on public.profiles to authenticated;
grant update (username, display_name, avatar_url) on public.profiles to authenticated;
grant select, insert on public.quiz_attempts to authenticated;
grant select, insert, update, delete on public.friend_groups to authenticated;
grant select, delete on public.group_members to authenticated;
