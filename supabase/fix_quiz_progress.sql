begin;

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

revoke all on function public.record_quiz_attempt(
  text,
  text,
  text,
  integer,
  integer,
  integer,
  integer,
  integer
) from public, anon;

grant execute on function public.record_quiz_attempt(
  text,
  text,
  text,
  integer,
  integer,
  integer,
  integer,
  integer
) to authenticated;

grant select on public.profiles to authenticated;
grant select on public.quiz_attempts to authenticated;

commit;
