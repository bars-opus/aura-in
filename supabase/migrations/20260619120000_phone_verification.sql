-- supabase/migrations/20260619120000_phone_verification.sql
-- Adds one-time phone verification fields to profiles. These columns gate the
-- freelancer / shop / product-seller flows and are written ONLY by the
-- phone-verify-check edge function (service role). Client writes are rejected
-- by the guard trigger below so the gate cannot be spoofed.

alter table public.profiles
  add column if not exists phone_e164 text,
  add column if not exists phone_verified_at timestamptz;

create or replace function public.guard_phone_verification_columns()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- auth.role() is 'service_role' for service-role JWTs, 'authenticated' for users.
  -- Only the phone-verify-check edge function (service role) may write these
  -- columns. Both UPDATE and INSERT are guarded: profiles are created
  -- client-side, and the INSERT RLS policy checks only the row id — without an
  -- INSERT guard a client could create its row with phone_verified_at pre-set
  -- and bypass the gate with no Twilio interaction.
  if auth.role() <> 'service_role' then
    if tg_op = 'INSERT' then
      -- On INSERT there is no OLD row; reject any non-null verification value.
      if new.phone_e164 is not null or new.phone_verified_at is not null then
        raise exception 'phone verification columns are read-only for clients';
      end if;
    else
      if new.phone_e164 is distinct from old.phone_e164
         or new.phone_verified_at is distinct from old.phone_verified_at then
        raise exception 'phone verification columns are read-only for clients';
      end if;
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_guard_phone_verification on public.profiles;
create trigger trg_guard_phone_verification
  before insert or update on public.profiles
  for each row
  execute function public.guard_phone_verification_columns();
