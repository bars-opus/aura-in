-- Feedback engine — user_feedback table + RLS + feedback-screenshots bucket.
--
-- Stores one row per user-submitted feedback (bug report, suggestion, etc.).
-- See architecture/FEEDBACK_ENGINE.md for the integration guide.

create table if not exists public.user_feedback (
  id              uuid        primary key default gen_random_uuid(),
  user_id         uuid        not null references auth.users(id) on delete cascade,
  -- type is config-driven on the client; constrain both length and charset so
  -- a buggy or malicious caller can't write garbage.
  type            text        not null
    check (char_length(type) between 1 and 64)
    check (type ~ '^[a-z0-9_]+$'),
  title           text        not null check (char_length(title)       between 1 and 100),
  description     text        not null check (char_length(description) between 1 and 5000),
  screenshot_urls text[]      not null default '{}'
    check (array_length(screenshot_urls, 1) is null
           or array_length(screenshot_urls, 1) <= 10),
  app_version     text        not null default '',
  device_info     jsonb,
  status          text        not null default 'pending'
                              check (status in ('pending','reviewed','implemented','rejected')),
  -- Client-generated UUID per submission. Lets the repo retry without
  -- creating duplicate rows: the second insert hits the unique constraint
  -- and the controller treats `23505` as "already submitted, all good".
  idempotency_key uuid,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- Add the column on existing installs that pre-date this migration.
alter table public.user_feedback
  add column if not exists idempotency_key uuid;

create unique index if not exists user_feedback_idempotency_key_uidx
  on public.user_feedback (user_id, idempotency_key)
  where idempotency_key is not null;

create index if not exists user_feedback_user_id_idx
  on public.user_feedback (user_id, created_at desc);

create index if not exists user_feedback_status_idx
  on public.user_feedback (status, created_at desc);

create index if not exists user_feedback_type_idx
  on public.user_feedback (type);

-- Keep updated_at fresh on update.
create or replace function public.user_feedback_touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists user_feedback_touch on public.user_feedback;
create trigger user_feedback_touch
  before update on public.user_feedback
  for each row execute function public.user_feedback_touch_updated_at();

-- RLS — users insert/read their own feedback. Updates are reserved for
-- staff/admins (via service role); the client never updates rows directly.
alter table public.user_feedback enable row level security;

drop policy if exists "Users read own feedback"  on public.user_feedback;
create policy "Users read own feedback"
  on public.user_feedback
  for select
  using (auth.uid() = user_id);

drop policy if exists "Users insert own feedback" on public.user_feedback;
create policy "Users insert own feedback"
  on public.user_feedback
  for insert
  with check (auth.uid() = user_id);

-- ── Storage bucket for screenshots ───────────────────────────────────────────
-- ⚠️  Privacy note: bucket is intentionally `public = true` so the resolved
-- `getPublicUrl` works for in-app rendering without signing every read. This
-- means anyone WITH THE URL can fetch the file, even outside RLS.
--
-- That's an accepted trade-off:
--   • The URL only ever lives inside `user_feedback.screenshot_urls`, which is
--     itself RLS-gated to own-user reads, so the URL doesn't leak through the
--     public API surface.
--   • The Storage policies below still gate writes/reads via the Storage API
--     itself to own-folder.
--
-- If screenshots ever start carrying sensitive content (PII, customer photos,
-- IDs), switch the bucket to `public = false` and have the client mint signed
-- URLs at render time instead.

insert into storage.buckets (id, name, public)
values ('feedback-screenshots', 'feedback-screenshots', true)
on conflict (id) do nothing;

-- Authenticated users may upload to their own folder.
drop policy if exists "Feedback screenshots: own-folder insert"
  on storage.objects;
create policy "Feedback screenshots: own-folder insert"
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'feedback-screenshots'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Authenticated users may read their own files (bucket is "public" so the
-- read policy is permissive — but we still scope it to own-folder to keep
-- service-role surface area small).
drop policy if exists "Feedback screenshots: own-folder read"
  on storage.objects;
create policy "Feedback screenshots: own-folder read"
  on storage.objects
  for select
  to authenticated
  using (
    bucket_id = 'feedback-screenshots'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
