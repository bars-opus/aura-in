-- Down-migration for 20260614000100_feedback_engine.sql.
--
-- ⚠️  Destructive: drops the table and all rows, plus removes the storage
-- bucket and every file in it. Only run if you are intentionally rolling
-- the engine back. Apply via the SQL editor with the service role; the
-- migration runner does NOT pick up files in this folder.

-- Storage policies + bucket.
drop policy if exists "Feedback screenshots: own-folder read"   on storage.objects;
drop policy if exists "Feedback screenshots: own-folder insert" on storage.objects;

-- Empty + drop the bucket. `bucket_id` deletes cascade to objects only if the
-- storage backend supports it; we explicitly delete objects first.
delete from storage.objects where bucket_id = 'feedback-screenshots';
delete from storage.buckets where id        = 'feedback-screenshots';

-- Table policies + trigger.
drop policy  if exists "Users insert own feedback" on public.user_feedback;
drop policy  if exists "Users read own feedback"   on public.user_feedback;
drop trigger if exists user_feedback_touch         on public.user_feedback;
drop function if exists public.user_feedback_touch_updated_at();

-- Indexes + table.
drop index if exists public.user_feedback_idempotency_key_uidx;
drop index if exists public.user_feedback_type_idx;
drop index if exists public.user_feedback_status_idx;
drop index if exists public.user_feedback_user_id_idx;
drop table if exists public.user_feedback;
