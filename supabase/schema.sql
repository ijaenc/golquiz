create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null,
  display_name text not null,
  avatar_url text,
  total_points integer not null default 0 check (total_points >= 0),
  games_played integer not null default 0 check (games_played >= 0),
  correct_answers integer not null default 0 check (correct_answers >= 0),
  incorrect_answers integer not null default 0 check (incorrect_answers >= 0),
  best_streak integer not null default 0 check (best_streak >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_username_length check (char_length(username) between 3 and 24),
  constraint profiles_display_name_length check (char_length(display_name) between 2 and 40)
);

create unique index if not exists profiles_username_lower_idx
  on public.profiles (lower(username));
create index if not exists profiles_total_points_idx
  on public.profiles (total_points desc);

create table if not exists public.quiz_attempts (
  id uuid primary key default gen_random_uuid(),
  client_attempt_id text not null unique,
  user_id uuid not null references public.profiles(id) on delete cascade,
  category_id text not null,
  difficulty text not null check (difficulty in ('easy', 'medium', 'hard')),
  question_count integer not null check (question_count in (5, 10)),
  score integer not null check (score >= 0),
  correct_answers integer not null check (correct_answers >= 0),
  incorrect_answers integer not null check (incorrect_answers >= 0),
  best_streak integer not null check (best_streak >= 0),
  completed_at timestamptz not null default now(),
  constraint quiz_attempt_answers_check
    check (correct_answers + incorrect_answers = question_count)
);

create index if not exists quiz_attempts_user_idx
  on public.quiz_attempts (user_id, completed_at desc);
create index if not exists quiz_attempts_leaderboard_idx
  on public.quiz_attempts (
    category_id,
    difficulty,
    question_count,
    score desc,
    completed_at asc
  );

create table if not exists public.friend_groups (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  description text,
  invite_code text not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint friend_groups_name_length check (char_length(name) between 3 and 40),
  constraint friend_groups_description_length
    check (description is null or char_length(description) <= 180),
  constraint friend_groups_invite_code_format
    check (invite_code ~ '^[A-Z2-9]{8}$')
);

create index if not exists friend_groups_owner_idx
  on public.friend_groups (owner_id);
create unique index if not exists friend_groups_invite_code_upper_idx
  on public.friend_groups (upper(invite_code));

create table if not exists public.group_members (
  group_id uuid not null references public.friend_groups(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role text not null default 'member' check (role in ('owner', 'member')),
  joined_at timestamptz not null default now(),
  primary key (group_id, user_id)
);

create index if not exists group_members_user_idx
  on public.group_members (user_id, joined_at desc);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists friend_groups_set_updated_at on public.friend_groups;
create trigger friend_groups_set_updated_at
before update on public.friend_groups
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, username, display_name)
  values (
    new.id,
    coalesce(nullif(new.raw_user_meta_data ->> 'username', ''), 'fan_' || left(new.id::text, 8)),
    coalesce(nullif(new.raw_user_meta_data ->> 'display_name', ''), split_part(coalesce(new.email, 'Futbolero'), '@', 1))
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

create or replace function public.add_group_owner_as_member()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.group_members (group_id, user_id, role)
  values (new.id, new.owner_id, 'owner')
  on conflict (group_id, user_id) do update set role = 'owner';
  return new;
end;
$$;

drop trigger if exists on_friend_group_created on public.friend_groups;
create trigger on_friend_group_created
after insert on public.friend_groups
for each row execute function public.add_group_owner_as_member();

create or replace function public.record_quiz_attempt(
  p_client_attempt_id text,
  p_category_id text,
  p_difficulty text,
  p_question_count integer,
  p_score integer,
  p_correct_answers integer,
  p_incorrect_answers integer,
  p_best_streak integer
)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_attempt_id uuid;
begin
  if v_user_id is null then
    raise exception 'Authentication required';
  end if;

  if not exists (
    select 1 from public.profiles where id = v_user_id
  ) then
    raise exception 'User profile not found';
  end if;

  insert into public.quiz_attempts (
    client_attempt_id,
    user_id,
    category_id,
    difficulty,
    question_count,
    score,
    correct_answers,
    incorrect_answers,
    best_streak
  ) values (
    p_client_attempt_id,
    v_user_id,
    p_category_id,
    p_difficulty,
    p_question_count,
    p_score,
    p_correct_answers,
    p_incorrect_answers,
    p_best_streak
  )
  on conflict (client_attempt_id) do nothing
  returning id into v_attempt_id;

  if v_attempt_id is null then
    return false;
  end if;

  update public.profiles
  set
    total_points = total_points + p_score,
    games_played = games_played + 1,
    correct_answers = correct_answers + p_correct_answers,
    incorrect_answers = incorrect_answers + p_incorrect_answers,
    best_streak = greatest(best_streak, p_best_streak)
  where id = v_user_id;

  return true;
end;
$$;

create or replace function public.get_quiz_leaderboard(
  p_category_id text,
  p_difficulty text,
  p_question_count integer
)
returns table (
  user_id uuid,
  username text,
  display_name text,
  avatar_url text,
  best_score integer,
  completed_at timestamptz
)
language sql
security definer
set search_path = ''
stable
as $$
  select distinct on (qa.user_id)
    qa.user_id,
    p.username,
    p.display_name,
    p.avatar_url,
    qa.score as best_score,
    qa.completed_at
  from public.quiz_attempts qa
  join public.profiles p on p.id = qa.user_id
  where auth.uid() is not null
    and qa.category_id = p_category_id
    and qa.difficulty = p_difficulty
    and qa.question_count = p_question_count
  order by qa.user_id, qa.score desc, qa.completed_at asc;
$$;

create or replace function public.join_group_by_code(p_invite_code text)
returns setof public.friend_groups
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_group public.friend_groups;
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'Authentication required';
  end if;

  select * into v_group
  from public.friend_groups
  where upper(invite_code) = upper(trim(p_invite_code));

  if v_group.id is null then
    raise exception 'Invalid invite code';
  end if;

  insert into public.group_members (group_id, user_id, role)
  values (v_group.id, v_user_id, 'member')
  on conflict (group_id, user_id) do nothing;

  return next v_group;
end;
$$;

revoke all on function public.record_quiz_attempt(text, text, text, integer, integer, integer, integer, integer) from public, anon;
grant execute on function public.record_quiz_attempt(text, text, text, integer, integer, integer, integer, integer) to authenticated;
revoke all on function public.get_quiz_leaderboard(text, text, integer) from public, anon;
grant execute on function public.get_quiz_leaderboard(text, text, integer) to authenticated;
revoke all on function public.join_group_by_code(text) from public, anon;
grant execute on function public.join_group_by_code(text) to authenticated;
