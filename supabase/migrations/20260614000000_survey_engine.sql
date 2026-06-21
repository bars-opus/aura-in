-- Survey engine — feature_survey_responses table + RLS.
--
-- Stores one row per (user, feature_key) capturing 👍/👎 sentiment.
-- See architecture/SURVEY_ENGINE.md for the integration guide.

create table if not exists public.feature_survey_responses (
  user_id      uuid        not null references auth.users(id) on delete cascade,
  feature_key  text        not null
    check (char_length(feature_key) between 1 and 64)
    check (feature_key ~ '^[a-z0-9_]+$'),
  sentiment    text        not null check (sentiment in ('like', 'dislike')),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  primary key (user_id, feature_key)
);

create index if not exists feature_survey_responses_feature_key_idx
  on public.feature_survey_responses (feature_key);

-- Keep updated_at fresh on upsert/update.
create or replace function public.feature_survey_responses_touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists feature_survey_responses_touch
  on public.feature_survey_responses;

create trigger feature_survey_responses_touch
  before update on public.feature_survey_responses
  for each row execute function public.feature_survey_responses_touch_updated_at();

-- RLS — each user reads and writes only their own rows. No DELETE policy:
-- responses are append-only / upsert-only from the client.
alter table public.feature_survey_responses enable row level security;

drop policy if exists "Users read own survey responses"
  on public.feature_survey_responses;
create policy "Users read own survey responses"
  on public.feature_survey_responses
  for select
  using (auth.uid() = user_id);

drop policy if exists "Users insert own survey responses"
  on public.feature_survey_responses;
create policy "Users insert own survey responses"
  on public.feature_survey_responses
  for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users update own survey responses"
  on public.feature_survey_responses;
create policy "Users update own survey responses"
  on public.feature_survey_responses
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
