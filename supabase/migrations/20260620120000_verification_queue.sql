-- supabase/migrations/20260620120000_verification_queue.sql
-- Manual document verification workflow. Producer entities (shops, workers)
-- carry a verification_status that gates public visibility. Only the service
-- role (via review-verification / submit-verification edge functions) may write
-- the verification_* columns; a guard trigger enforces this so producers
-- cannot self-approve.

-- 1. Status columns on shops + workers
alter table public.shops
  add column if not exists verification_status text not null default 'pending',
  add column if not exists verification_submitted_at timestamptz,
  add column if not exists verification_reviewed_by uuid,
  add column if not exists verification_reviewed_at timestamptz,
  add column if not exists verification_rejection_reason text;

alter table public.workers
  add column if not exists verification_status text not null default 'pending',
  add column if not exists verification_submitted_at timestamptz,
  add column if not exists verification_reviewed_by uuid,
  add column if not exists verification_reviewed_at timestamptz,
  add column if not exists verification_rejection_reason text;

do $$ begin
  alter table public.shops
    add constraint shops_verification_status_chk
    check (verification_status in ('pending','approved','rejected'));
exception when duplicate_object then null; end $$;

do $$ begin
  alter table public.workers
    add constraint workers_verification_status_chk
    check (verification_status in ('pending','approved','rejected'));
exception when duplicate_object then null; end $$;

-- 2. Backfill: existing producers are grandfathered as already approved so the
-- new gating RLS does not hide live data on deploy.
-- Shops that were previously verified → approved.
update public.shops
  set verification_status = 'approved'
  where verified = true and verification_status <> 'approved';
-- All other existing shops (created before this feature) are grandfathered too,
-- so currently-live unverified shops are not suddenly removed from discovery.
-- New shops created after this migration still default to 'pending' via the
-- column default + submit-on-create flow.
update public.shops
  set verification_status = 'approved'
  where created_at < now() and verification_status = 'pending';
-- Existing workers/freelancers have no prior verified flag; grandfather all
-- pre-existing rows to approved so they remain discoverable.
update public.workers
  set verification_status = 'approved'
  where created_at < now() and verification_status = 'pending';

-- 3. Admin allowlist
create table if not exists public.app_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.app_admins enable row level security;
-- Admins can read the allowlist (to self-check); only service role writes it.
drop policy if exists app_admins_self_read on public.app_admins;
create policy app_admins_self_read on public.app_admins
  for select to authenticated
  using (user_id = auth.uid());

-- 4. Guard: verification_* columns (and shops.verified) are service-role-only.
create or replace function public.guard_verification_columns()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.role() <> 'service_role' then
    if tg_op = 'INSERT' then
      if new.verification_status is distinct from 'pending'
         or new.verification_submitted_at is not null
         or new.verification_reviewed_by is not null
         or new.verification_reviewed_at is not null
         or new.verification_rejection_reason is not null then
        raise exception 'verification columns are read-only for clients';
      end if;
    else
      if new.verification_status is distinct from old.verification_status
         or new.verification_submitted_at is distinct from old.verification_submitted_at
         or new.verification_reviewed_by is distinct from old.verification_reviewed_by
         or new.verification_reviewed_at is distinct from old.verification_reviewed_at
         or new.verification_rejection_reason is distinct from old.verification_rejection_reason then
        raise exception 'verification columns are read-only for clients';
      end if;
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_guard_verification_cols on public.shops;
create trigger trg_guard_verification_cols
  before insert or update on public.shops
  for each row execute function public.guard_verification_columns();

-- shops.verified is now a derived column, always computed from verification_status
-- by the sync trigger below. No separate client-write guard is needed: clients
-- cannot change verification_status (guarded above), so verified is effectively
-- protected and always consistent.

drop trigger if exists trg_guard_shop_verified on public.shops;
drop function if exists public.guard_shop_verified_column();

-- Sync trigger: keep shops.verified = (verification_status = 'approved') always.
-- Named trg_zsync_* so it fires AFTER the guard triggers (alphabetical BEFORE order).
create or replace function public.sync_shop_verified_column()
returns trigger
language plpgsql
as $$
begin
  new.verified := (new.verification_status = 'approved');
  return new;
end;
$$;
drop trigger if exists trg_zsync_shop_verified on public.shops;
create trigger trg_zsync_shop_verified
  before insert or update on public.shops
  for each row execute function public.sync_shop_verified_column();

drop trigger if exists trg_guard_verification_cols on public.workers;
create trigger trg_guard_verification_cols
  before insert or update on public.workers
  for each row execute function public.guard_verification_columns();

-- 5. RLS: public sees only approved entities; owner + admins see all.
drop policy if exists shops_public_read on public.shops;
create policy shops_public_read on public.shops
  for select to anon, authenticated
  using (
    (
      verification_status = 'approved'
      and exists (
        select 1 from public.profiles p
        where p.id = shops.user_id and p.account_status = 'active'
      )
    )
    or auth.uid() = shops.user_id
    or exists (select 1 from public.app_admins a where a.user_id = auth.uid())
  );

drop policy if exists workers_public_read on public.workers;
create policy workers_public_read on public.workers
  for select to anon, authenticated
  using (
    (
      verification_status = 'approved'
      and coalesce(is_active, true) = true
      and exists (
        select 1 from public.profiles p
        where p.id = workers.user_id and p.account_status = 'active'
      )
      and (
        workers.shop_id is null
        or exists (
          select 1 from public.shops s
          join public.profiles owner_profile on owner_profile.id = s.user_id
          where s.id = workers.shop_id
            and owner_profile.account_status = 'active'
        )
      )
    )
    or auth.uid() = workers.user_id
    or exists (select 1 from public.app_admins a where a.user_id = auth.uid())
  );

-- 6. Products gated through their shop's verification.
drop policy if exists products_read_active on public.products;
create policy products_read_active on public.products
  for select to anon, authenticated
  using (
    is_active = true
    and exists (
      select 1 from public.shops s
      join public.profiles p on p.id = s.user_id
      where s.id = products.shop_id
        and p.account_status = 'active'
        and s.verification_status = 'approved'
    )
  );

-- 7. Indexes for verification_status lookups (RLS + admin queries).
create index if not exists idx_shops_verification_status
  on public.shops (verification_status);
create index if not exists idx_workers_verification_status
  on public.workers (verification_status);
