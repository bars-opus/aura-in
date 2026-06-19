-- Down-migration for 20260614000000_survey_engine.sql.
--
-- ⚠️  Destructive: drops the table and all responses. Only run if you are
-- intentionally rolling the engine back. Apply via the SQL editor with the
-- service role; the migration runner does NOT pick up files in this folder.

drop policy if exists "Users update own survey responses" on public.feature_survey_responses;
drop policy if exists "Users insert own survey responses" on public.feature_survey_responses;
drop policy if exists "Users read own survey responses"   on public.feature_survey_responses;

drop trigger if exists feature_survey_responses_touch on public.feature_survey_responses;
drop function if exists public.feature_survey_responses_touch_updated_at();

drop index if exists public.feature_survey_responses_feature_key_idx;
drop table  if exists public.feature_survey_responses;
