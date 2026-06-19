-- Account lifecycle: deactivate, restore, and app-level deletion.
--
-- Deletion is intentionally implemented as a tombstone state on profiles.
-- Existing schema contains many auth.users(id) ON DELETE CASCADE references,
-- so physically deleting auth.users would remove business history.

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS account_status TEXT NOT NULL DEFAULT 'active'
    CHECK (account_status IN ('active', 'deactivated', 'pending_delete', 'deleted')),
  ADD COLUMN IF NOT EXISTS deactivated_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS pending_deletion_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS deletion_scheduled_for TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS account_action_reason TEXT,
  ADD COLUMN IF NOT EXISTS account_visibility_snapshot JSONB;

CREATE INDEX IF NOT EXISTS profiles_account_status_idx
  ON public.profiles (account_status);

CREATE INDEX IF NOT EXISTS profiles_deletion_scheduled_for_idx
  ON public.profiles (deletion_scheduled_for)
  WHERE account_status = 'pending_delete';

-- Public reads must not leak inactive/deleted profiles, but a user may read
-- their own inactive profile so the app can show the restore screen.
DROP POLICY IF EXISTS "profiles_select_public" ON public.profiles;
CREATE POLICY "profiles_select_public"
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (account_status = 'active' OR auth.uid() = id);

-- Public shop/worker/product reads should only expose active account owners.
DROP POLICY IF EXISTS shops_public_read ON public.shops;
CREATE POLICY shops_public_read
  ON public.shops
  FOR SELECT
  TO anon, authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.profiles p
      WHERE p.id = shops.user_id
        AND p.account_status = 'active'
    )
  );

DROP POLICY IF EXISTS workers_public_read ON public.workers;
CREATE POLICY workers_public_read
  ON public.workers
  FOR SELECT
  TO anon, authenticated
  USING (
    COALESCE(is_active, true) = true
    AND EXISTS (
      SELECT 1
      FROM public.profiles p
      WHERE p.id = workers.user_id
        AND p.account_status = 'active'
    )
    AND (
      workers.shop_id IS NULL
      OR EXISTS (
        SELECT 1
        FROM public.shops s
        JOIN public.profiles owner_profile ON owner_profile.id = s.user_id
        WHERE s.id = workers.shop_id
          AND owner_profile.account_status = 'active'
      )
    )
  );

DROP POLICY IF EXISTS products_read_active ON public.products;
CREATE POLICY products_read_active ON public.products
  FOR SELECT
  USING (
    is_active = true
    AND EXISTS (
      SELECT 1
      FROM public.shops s
      JOIN public.profiles p ON p.id = s.user_id
      WHERE s.id = products.shop_id
        AND p.account_status = 'active'
    )
  );

CREATE OR REPLACE FUNCTION public.get_account_action_blockers()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_result JSONB;
BEGIN
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'unauthorized' USING ERRCODE = '42501';
  END IF;

  SELECT jsonb_build_object(
    'active_bookings',
      (SELECT count(*)
       FROM public.bookings b
       WHERE b.user_id = v_user
         AND b.status IN ('pending', 'confirmed')),
    'owned_shop_active_bookings',
      (SELECT count(*)
       FROM public.bookings b
       JOIN public.shops s ON s.id = b.shop_id
       WHERE s.user_id = v_user
         AND b.status IN ('pending', 'confirmed')),
    'active_orders',
      (SELECT count(*)
       FROM public.orders o
       WHERE o.user_id = v_user
         AND o.status IN ('pending_confirmation', 'confirmed', 'out_for_delivery', 'disputed')),
    'owned_shop_active_orders',
      (SELECT count(*)
       FROM public.orders o
       JOIN public.shops s ON s.id = o.shop_id
       WHERE s.user_id = v_user
         AND o.status IN ('pending_confirmation', 'confirmed', 'out_for_delivery', 'disputed')),
    'active_withdrawals',
      (SELECT count(*)
       FROM public.withdrawal_requests wr
       JOIN public.shops s ON s.id = wr.shop_id
       WHERE s.user_id = v_user
         AND wr.status IN ('pending', 'processing', 'retry_scheduled'))
  ) INTO v_result;

  RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION public.account_action_has_blockers()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM jsonb_each_text(public.get_account_action_blockers()) AS blocker(key, value)
    WHERE COALESCE(value::INT, 0) > 0
  );
$$;

CREATE OR REPLACE FUNCTION public.snapshot_account_visibility(p_user UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_short_links JSONB := '[]'::jsonb;
BEGIN
  IF to_regclass('public.short_links') IS NOT NULL THEN
    EXECUTE $q$
      SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', sl.id,
        'is_active', sl.is_active
      )), '[]'::jsonb)
      FROM public.short_links sl
      WHERE sl.link_type = 'shop'
        AND sl.target_id IN (
          SELECT s.id::text FROM public.shops s WHERE s.user_id = $1
        )
    $q$
    INTO v_short_links
    USING p_user;
  END IF;

  RETURN jsonb_build_object(
    'shops',
      (SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', id,
        'show_on_explore_page', show_on_explore_page,
        'no_booking', no_booking,
        'booking_slug', booking_slug
      )), '[]'::jsonb)
       FROM public.shops
       WHERE user_id = p_user),
    'products',
      (SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', p.id,
        'is_active', p.is_active
      )), '[]'::jsonb)
       FROM public.products p
       JOIN public.shops s ON s.id = p.shop_id
       WHERE s.user_id = p_user),
    'workers',
      (SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', id,
        'is_active', is_active
      )), '[]'::jsonb)
       FROM public.workers
       WHERE user_id = p_user),
    'short_links', v_short_links
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.hide_account_public_presence(p_user UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.products p
  SET is_active = false,
      updated_at = now()
  FROM public.shops s
  WHERE p.shop_id = s.id
    AND s.user_id = p_user;

  UPDATE public.workers
  SET is_active = false,
      updated_at = now()
  WHERE user_id = p_user;

  IF to_regclass('public.short_links') IS NOT NULL THEN
    EXECUTE $q$
      UPDATE public.short_links
      SET is_active = false
      WHERE link_type = 'shop'
        AND target_id IN (
          SELECT s.id::text FROM public.shops s WHERE s.user_id = $1
        )
    $q$
    USING p_user;
  END IF;

  UPDATE public.shops
  SET show_on_explore_page = false,
      no_booking = true,
      booking_slug = null
  WHERE user_id = p_user;
END;
$$;

CREATE OR REPLACE FUNCTION public.restore_account_visibility(p_user UUID, p_snapshot JSONB)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.shops s
  SET show_on_explore_page = COALESCE(snapshot.show_on_explore_page, s.show_on_explore_page),
      no_booking = COALESCE(snapshot.no_booking, s.no_booking),
      booking_slug = snapshot.booking_slug
  FROM jsonb_to_recordset(COALESCE(p_snapshot->'shops', '[]'::jsonb))
       AS snapshot(id UUID, show_on_explore_page BOOLEAN, no_booking BOOLEAN, booking_slug TEXT)
  WHERE s.id = snapshot.id
    AND s.user_id = p_user;

  UPDATE public.products p
  SET is_active = COALESCE(snapshot.is_active, p.is_active),
      updated_at = now()
  FROM jsonb_to_recordset(COALESCE(p_snapshot->'products', '[]'::jsonb))
       AS snapshot(id UUID, is_active BOOLEAN),
       public.shops s
  WHERE p.id = snapshot.id
    AND s.id = p.shop_id
    AND s.user_id = p_user;

  UPDATE public.workers w
  SET is_active = COALESCE(snapshot.is_active, w.is_active),
      updated_at = now()
  FROM jsonb_to_recordset(COALESCE(p_snapshot->'workers', '[]'::jsonb))
       AS snapshot(id UUID, is_active BOOLEAN)
  WHERE w.id = snapshot.id
    AND w.user_id = p_user;

  IF to_regclass('public.short_links') IS NOT NULL THEN
    EXECUTE $q$
      UPDATE public.short_links sl
      SET is_active = COALESCE(snapshot.is_active, sl.is_active)
      FROM jsonb_to_recordset(COALESCE($1->'short_links', '[]'::jsonb))
           AS snapshot(id UUID, is_active BOOLEAN)
      WHERE sl.id = snapshot.id
    $q$
    USING p_snapshot;
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.deactivate_account(p_reason TEXT DEFAULT NULL)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_snapshot JSONB;
BEGIN
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'unauthorized' USING ERRCODE = '42501';
  END IF;

  IF public.account_action_has_blockers() THEN
    RETURN jsonb_build_object(
      'success', false,
      'reason', 'active_obligations',
      'blockers', public.get_account_action_blockers()
    );
  END IF;

  SELECT COALESCE(account_visibility_snapshot, public.snapshot_account_visibility(v_user))
  INTO v_snapshot
  FROM public.profiles
  WHERE id = v_user
  FOR UPDATE;

  PERFORM public.hide_account_public_presence(v_user);

  UPDATE public.profiles
  SET account_status = 'deactivated',
      deactivated_at = now(),
      pending_deletion_at = null,
      deletion_scheduled_for = null,
      deleted_at = null,
      account_action_reason = NULLIF(trim(p_reason), ''),
      account_visibility_snapshot = v_snapshot,
      updated_at = now()
  WHERE id = v_user;

  RETURN jsonb_build_object('success', true, 'status', 'deactivated');
END;
$$;

CREATE OR REPLACE FUNCTION public.request_account_deletion(p_reason TEXT DEFAULT NULL)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_snapshot JSONB;
BEGIN
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'unauthorized' USING ERRCODE = '42501';
  END IF;

  IF public.account_action_has_blockers() THEN
    RETURN jsonb_build_object(
      'success', false,
      'reason', 'active_obligations',
      'blockers', public.get_account_action_blockers()
    );
  END IF;

  SELECT COALESCE(account_visibility_snapshot, public.snapshot_account_visibility(v_user))
  INTO v_snapshot
  FROM public.profiles
  WHERE id = v_user
  FOR UPDATE;

  PERFORM public.hide_account_public_presence(v_user);

  UPDATE public.profiles
  SET account_status = 'pending_delete',
      pending_deletion_at = now(),
      deletion_scheduled_for = now() + interval '30 days',
      deactivated_at = null,
      deleted_at = null,
      account_action_reason = NULLIF(trim(p_reason), ''),
      account_visibility_snapshot = v_snapshot,
      updated_at = now()
  WHERE id = v_user;

  RETURN jsonb_build_object(
    'success', true,
    'status', 'pending_delete',
    'deletion_scheduled_for', (now() + interval '30 days')
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.restore_account()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_profile public.profiles%ROWTYPE;
BEGIN
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'unauthorized' USING ERRCODE = '42501';
  END IF;

  SELECT *
  INTO v_profile
  FROM public.profiles
  WHERE id = v_user
  FOR UPDATE;

  IF v_profile.account_status = 'deleted' THEN
    RETURN jsonb_build_object('success', false, 'reason', 'deleted');
  END IF;

  IF v_profile.account_status = 'active' THEN
    RETURN jsonb_build_object('success', true, 'status', 'active');
  END IF;

  PERFORM public.restore_account_visibility(v_user, v_profile.account_visibility_snapshot);

  UPDATE public.profiles
  SET account_status = 'active',
      deactivated_at = null,
      pending_deletion_at = null,
      deletion_scheduled_for = null,
      deleted_at = null,
      account_action_reason = null,
      account_visibility_snapshot = null,
      updated_at = now()
  WHERE id = v_user;

  RETURN jsonb_build_object('success', true, 'status', 'active');
END;
$$;

CREATE OR REPLACE FUNCTION public.finalize_due_account_deletions()
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_count INT;
BEGIN
  WITH finalized AS (
    UPDATE public.profiles
    SET account_status = 'deleted',
        username = null,
        display_name = null,
        bio = null,
        avatar_url = null,
        deleted_at = now(),
        account_action_reason = null,
        account_visibility_snapshot = null,
        updated_at = now()
    WHERE account_status = 'pending_delete'
      AND deletion_scheduled_for <= now()
    RETURNING 1
  )
  SELECT count(*) INTO v_count FROM finalized;

  RETURN v_count;
END;
$$;

REVOKE ALL ON FUNCTION public.get_account_action_blockers() FROM public;
REVOKE ALL ON FUNCTION public.account_action_has_blockers() FROM public;
REVOKE ALL ON FUNCTION public.snapshot_account_visibility(UUID) FROM public;
REVOKE ALL ON FUNCTION public.hide_account_public_presence(UUID) FROM public;
REVOKE ALL ON FUNCTION public.restore_account_visibility(UUID, JSONB) FROM public;
REVOKE ALL ON FUNCTION public.deactivate_account(TEXT) FROM public;
REVOKE ALL ON FUNCTION public.request_account_deletion(TEXT) FROM public;
REVOKE ALL ON FUNCTION public.restore_account() FROM public;
REVOKE ALL ON FUNCTION public.finalize_due_account_deletions() FROM public;

GRANT EXECUTE ON FUNCTION public.get_account_action_blockers() TO authenticated;
GRANT EXECUTE ON FUNCTION public.deactivate_account(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.request_account_deletion(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.restore_account() TO authenticated;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
    PERFORM cron.unschedule('finalize-due-account-deletions')
    WHERE EXISTS (
      SELECT 1 FROM cron.job WHERE jobname = 'finalize-due-account-deletions'
    );

    PERFORM cron.schedule(
      'finalize-due-account-deletions',
      '17 3 * * *',
      $cron$SELECT public.finalize_due_account_deletions();$cron$
    );
  ELSE
    RAISE NOTICE 'pg_cron not installed — run finalize_due_account_deletions() from an external scheduler.';
  END IF;
END $$;
