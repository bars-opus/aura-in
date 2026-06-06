# Phase 12 PLAN — Autonomous Retention Engine

## Goal

Wire the booking lifecycle into a self-running retention loop with zero owner configuration. A single AFTER INSERT/UPDATE trigger on `bookings` becomes the **only** writer of `booking_reminder_24h` / `booking_reminder_2h` rows; the three terminal-state RPCs (`cancel_booking`, `mark_booking_complete`, `mark_booking_no_show`) gain a one-call `cancel_and_followup(p_booking_id, p_terminal_status)` helper that cancels pending reminders and schedules the next-stage row (`recovery_checkin` at now()+7d, `review_request` at now()+2h); a nightly `enqueue_rebook_nudges()` SQL function + pg_cron schedule writes one `rebook_nudge` row per (shop, client) when last-completed + shop median gap == today; and a per-client sticky-note surface is added to `BookingDetailScreen` under `isShopOwner`. Three new WhatsApp templates ship in the same PR; the existing 6-hour `WhatsAppTemplateNotFoundError` retry covers the Meta approval window. (SPEC §Outcome lines 5–28; SPEC §"Reminder ownership (LOCKED)" lines 164–169; RESEARCH §1 lines 17–38, §4 lines 111–158, §9 lines 275–315.)

## Out of scope (locked)

Verbatim from SPEC §"Out of scope (locked)" lines 85–97:

- **Per-shop reminder cadence customization** — owners cannot pick T-48h vs T-24h. Hardcoded.
- **Per-shop message copy editing** — templates are fixed for v1. Defer to Phase 14 (broadcast / marketing).
- **Discount codes in recovery messages** — Phase 13 promo engine. Recovery is text-only in v1.
- **Birthday reminders** — DOB not collected.
- **Per-client notification preferences** — clients cannot opt out of individual categories in v1.
- **Manual "send promo to this client" UI** — Phase 14 broadcast scope.
- **Loyalty / repeat-visit rewards** — Phase 13.
- **Multi-language templates** — Phase 14.
- **Note attachments / photos** — sticky notes are TEXT only.
- **Note history / audit log** — last-write-wins. `updated_by_user_id` is the only forensic trail.
- **Per-worker notes** — notes are per-shop, not per-worker.

### Removed from scope (vs. SPEC drafts)

- **`client_for_booking(booking_id)` view** — DROPPED. Sticky-note card reads `userId` / `guestProfileId` from the already-loaded booking model on the client. One fewer migration, one fewer coupling. (SPEC §"Removed from scope" lines 181–185; RESEARCH §7 lines 203–213.)
- **`booking_reminders_enabled` worker honoring** — deferred. The gap exists for existing reminder types already and is not a Phase 12 regression. (SPEC §"Removed from scope" lines 187–188; RESEARCH §3 line 109; RESEARCH §16 lines 437–443.)
- **"Skip guest delivery" flag for unapproved templates** — DROPPED. The worker's existing 6-hour `WhatsAppTemplateNotFoundError` retry behavior covers the Meta approval window. No flag, no skip logic. (SPEC §"WhatsApp template approval" lines 172–178.)

### Out of scope (carry-over gaps explicitly NOT fixed)

- **`notification_settings.{rebook_nudge,review_request,recovery_checkin}_enabled` columns** are not consulted by the worker today. Phase 12 does not change that. The category-level booleans are dormant. New rows ride through `delivery_channel`-only branching. (RESEARCH §3 line 109; §16 lines 437–443.)
- **`booking_reminder_1h` and `booking_reminder_5min` rows** previously emitted by the registered-user paystack-webhook path stop being scheduled after the webhook diffs land. Existing rows in flight keep their delivery semantics — they just stop being created. Documented in PR; no migration to backfill the inverse since the 24h+2h pair is the new canonical cadence. (RESEARCH §1 lines 17–38.)

## Files touched

**NEW (SQL — strict timestamp order)**

- `supabase/migrations/20260605130000_add_phase12_notification_types.sql`
- `supabase/migrations/20260605130100_client_notes_table.sql`
- `supabase/migrations/20260605130200_upsert_client_note_rpc.sql`
- `supabase/migrations/20260605130300_shop_rebook_cadence_view.sql`
- `supabase/migrations/20260605130400_enqueue_booking_reminder_helper.sql`
- `supabase/migrations/20260605130500_cancel_and_followup_helper.sql`
- `supabase/migrations/20260605130600_booking_lifecycle_triggers.sql`
- `supabase/migrations/20260605130700_wire_terminal_rpcs.sql`
- `supabase/migrations/20260605130800_consolidate_reminder_scheduling_backfill.sql`
- `supabase/migrations/20260605130900_enqueue_rebook_nudges_rpc.sql`

**NEW (Dart)**

- `lib/presentation/features/shops/dashboard/data/exceptions/client_notes_exceptions.dart`
- `lib/presentation/features/shops/dashboard/data/models/client_note_dto.dart`
- `lib/presentation/features/shops/dashboard/providers/client_note_provider.dart`
- `lib/presentation/features/shops/dashboard/presentation/widgets/client_sticky_note_card.dart`
- `test/presentation/features/shops/dashboard/data/exceptions/client_notes_exceptions_test.dart`
- `test/presentation/features/shops/dashboard/data/repositories/client_notes_repository_test.dart`
- `test/presentation/features/shops/dashboard/presentation/widgets/client_sticky_note_card_test.dart`
- `.planning/phases/12-autonomous-retention-engine/sql/12_smoke_tests.sql`

**EDIT (edge functions — ship in the same release)**

- `supabase/functions/paystack-webhook/index.ts` — DELETE the guest reminder-insert block at lines 269–292 and the registered-user reminder-insert block at lines 524–543. KEEP the immediate `booking_confirmation` insert and the `booking_review_prompt` insert in both paths — those are not reminders. (RESEARCH §1 lines 33–38.)
- `supabase/functions/stripe-webhook/index.ts` — DELETE the guest reminder-insert block at lines 337–360.
- `supabase/functions/verify-payment/index.ts` — DELETE the reminder-insert block at line 298 region.
- `supabase/functions/process-scheduled-notifications/index.ts` — **no change**. Worker already branches on `delivery_channel` and dispatches WhatsApp + push for any category. (RESEARCH §3 lines 81–91; §16 lines 437–443.)

**EDIT (Dart)**

- `lib/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart` — add two abstract methods (`getClientNote`, `upsertClientNote`).
- `lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart` — implement both with typed-exception mapping.
- `lib/presentation/features/shops/booking/presentation/screens/shared/booking_detail_screen.dart` — under `if (widget.isShopOwner)` at line 131 region, render `ClientStickyNoteCard(booking: booking)`. ~5 lines.

**EDIT (Meta — out-of-band, BEFORE merge per RESEARCH §5)**

- Submit three new WhatsApp templates to Meta for approval: `rebook_nudge_v1`, `review_request_v1`, `recovery_checkin_v1`. Copy lifted from RESEARCH §10 lines 322–327. Worker's 6-hour `WhatsAppTemplateNotFoundError` defer (process-scheduled-notifications/index.ts:124-128) auto-retries pending rows until Meta approves.

## Migration plan

Ten new SQL migrations, applied in strict timestamp order. Edge-function diffs ship in the same release but are not migrations. Every RPC body follows the Phase 11 hardening template (`supabase/migrations/20260603001500_harden_dashboard_rpcs.sql` lines 29–108) byte-for-byte: `LANGUAGE plpgsql`, `SECURITY DEFINER`, `SET search_path = public`, authz ownership gate FIRST, validation second, `'not_found'` raises with `ERRCODE = '42501'`, `'invalid_*'` raises with `ERRCODE = '22023'` + `HINT = '...'`, then `REVOKE ALL ... FROM PUBLIC`, `GRANT EXECUTE ... TO authenticated`, and `COMMENT ON FUNCTION ... IS '... Big-O ...'`.

### 1. `20260605130000_add_phase12_notification_types.sql`

`notification_type` is a custom enum in the live DB (typname = `notification_type`, confirmed 2026-06-05). The defensive discovery DO block from RESEARCH §2 lines 46–69 is **not needed** — three direct `ALTER TYPE ... ADD VALUE IF NOT EXISTS` calls are sufficient. (SPEC §"Research-phase resolutions" line 259; SPEC migration #1 description lines 125–126.)

```sql
-- Phase 12: extend notification_type enum with the three new categories
-- emitted by the autonomous retention loop. Idempotent (IF NOT EXISTS).
-- Live DB confirmed enum shape 2026-06-05.

ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'rebook_nudge';
ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'review_request';
ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'recovery_checkin';
```

### 2. `20260605130100_client_notes_table.sql`

New table mirroring the wallet-owner-only RLS template verbatim. The exactly-one-of-user-or-guest constraint is enforced both as a table CHECK and again inside the RPC (defence in depth — RESEARCH §12 step 4). UNIQUE on `(shop_id, COALESCE(user_id::text, guest_profile_id::text))` is the upsert key.

```sql
CREATE TABLE IF NOT EXISTS public.client_notes (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id             UUID NOT NULL REFERENCES public.shops(id) ON DELETE CASCADE,
  user_id             UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  guest_profile_id    UUID REFERENCES public.guest_profiles(id) ON DELETE SET NULL,
  body                TEXT NOT NULL,
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_by_user_id  UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  CONSTRAINT client_notes_exactly_one_identity
    CHECK ((user_id IS NULL) <> (guest_profile_id IS NULL)),
  CONSTRAINT client_notes_body_length
    CHECK (char_length(body) <= 2000)
);

CREATE UNIQUE INDEX IF NOT EXISTS client_notes_shop_client_uk
  ON public.client_notes (
    shop_id,
    COALESCE(user_id::text, guest_profile_id::text)
  );

CREATE INDEX IF NOT EXISTS idx_client_notes_shop
  ON public.client_notes (shop_id);

ALTER TABLE public.client_notes ENABLE ROW LEVEL SECURITY;

-- Four separate policies (SELECT / INSERT / UPDATE / DELETE) per
-- RESEARCH §6 improvement 1. DELETE is denied entirely; soft-clear via
-- UPSERT-with-empty-body.

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'client_notes_select_owner') THEN
    CREATE POLICY client_notes_select_owner ON public.client_notes
      FOR SELECT
      USING (shop_id IN (SELECT id FROM public.shops WHERE user_id = auth.uid()));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'client_notes_insert_owner') THEN
    CREATE POLICY client_notes_insert_owner ON public.client_notes
      FOR INSERT
      WITH CHECK (shop_id IN (SELECT id FROM public.shops WHERE user_id = auth.uid()));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'client_notes_update_owner') THEN
    CREATE POLICY client_notes_update_owner ON public.client_notes
      FOR UPDATE
      USING (shop_id IN (SELECT id FROM public.shops WHERE user_id = auth.uid()))
      WITH CHECK (shop_id IN (SELECT id FROM public.shops WHERE user_id = auth.uid()));
  END IF;
  -- No DELETE policy. RLS default-deny applies.
END $$;

COMMENT ON TABLE public.client_notes IS
  'Per-shop / per-client sticky note. Owner-authored only; client never sees it. Last-write-wins (no history). Square parity.';
```

### 3. `20260605130200_upsert_client_note_rpc.sql`

Hardening template byte-for-byte. Authz FIRST (caller must own `p_shop_id`). Payload validation with HINT codes per RESEARCH §12 lines 363–382. Empty body is the soft-delete sentinel — allowed; only `> 2000` chars raises.

```sql
CREATE OR REPLACE FUNCTION public.upsert_client_note(
  p_shop_id          UUID,
  p_user_id          UUID,
  p_guest_profile_id UUID,
  p_body             TEXT
) RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $function$
DECLARE
  v_owns_shop BOOLEAN;
  v_note_id   UUID;
BEGIN
  -- Authz FIRST.
  SELECT EXISTS (
    SELECT 1 FROM public.shops
    WHERE id = p_shop_id AND user_id = auth.uid()
  ) INTO v_owns_shop;
  IF NOT v_owns_shop THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  -- Defence-in-depth: exactly one of user_id / guest_profile_id.
  IF (p_user_id IS NULL) = (p_guest_profile_id IS NULL) THEN
    RAISE EXCEPTION 'invalid_identity'
      USING ERRCODE = '22023', HINT = 'EXACTLY_ONE_OF_USER_OR_GUEST';
  END IF;

  IF p_body IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'BODY_NULL_NOT_ALLOWED';
  END IF;

  IF char_length(p_body) > 2000 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'NOTE_TOO_LONG';
  END IF;

  INSERT INTO public.client_notes (
    shop_id, user_id, guest_profile_id, body,
    updated_at, updated_by_user_id
  ) VALUES (
    p_shop_id, p_user_id, p_guest_profile_id, p_body,
    now(), auth.uid()
  )
  ON CONFLICT (shop_id, COALESCE(user_id::text, guest_profile_id::text))
  DO UPDATE SET
    body = EXCLUDED.body,
    updated_at = now(),
    updated_by_user_id = auth.uid()
  RETURNING id INTO v_note_id;

  RETURN v_note_id;
END;
$function$;

REVOKE ALL ON FUNCTION public.upsert_client_note(UUID, UUID, UUID, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.upsert_client_note(UUID, UUID, UUID, TEXT) TO authenticated;
COMMENT ON FUNCTION public.upsert_client_note(UUID, UUID, UUID, TEXT) IS
  'Upsert a per-shop / per-client sticky note. SECURITY DEFINER with shops.user_id=auth.uid() gate. Defence-in-depth exactly-one-of identity check. O(1) by unique index lookup.';
```

### 4. `20260605130300_shop_rebook_cadence_view.sql`

Materialized view per RESEARCH §8 lines 215–271. Floor 7d, ceiling 90d, default 30d when sample size < 5. UNIQUE index required for `REFRESH MATERIALIZED VIEW CONCURRENTLY`. Nightly pg_cron job at 03:15 UTC.

```sql
CREATE MATERIALIZED VIEW IF NOT EXISTS public.shop_rebook_cadence AS
WITH client_intervals AS (
  SELECT
    b.shop_id,
    COALESCE(b.user_id::text, b.guest_profile_id::text) AS client_id,
    b.start_time,
    EXTRACT(EPOCH FROM (
      b.start_time - LAG(b.start_time) OVER (
        PARTITION BY b.shop_id, COALESCE(b.user_id::text, b.guest_profile_id::text)
        ORDER BY b.start_time
      )
    )) / 86400.0 AS gap_days
  FROM public.bookings b
  WHERE b.status = 'completed'
),
shop_gaps AS (
  SELECT shop_id, gap_days
  FROM client_intervals
  WHERE gap_days IS NOT NULL
    AND gap_days BETWEEN 1 AND 180   -- drop outliers
)
SELECT
  s.id AS shop_id,
  CASE
    WHEN COUNT(g.gap_days) < 5 THEN 30
    ELSE GREATEST(7, LEAST(90,
      (percentile_cont(0.5) WITHIN GROUP (ORDER BY g.gap_days))::int))
  END AS median_gap_days,
  COUNT(g.gap_days) AS sample_size
FROM public.shops s
LEFT JOIN shop_gaps g ON g.shop_id = s.id
GROUP BY s.id;

CREATE UNIQUE INDEX IF NOT EXISTS shop_rebook_cadence_pk
  ON public.shop_rebook_cadence (shop_id);

COMMENT ON MATERIALIZED VIEW public.shop_rebook_cadence IS
  'Per-shop median booking gap (days). Floor 7d, ceiling 90d, default 30d when <5 samples. Recomputed nightly by pg_cron. Consumed by enqueue_rebook_nudges.';

-- Nightly refresh. Guard pg_cron extension presence (RESEARCH §14).
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
    PERFORM cron.schedule(
      'refresh-shop-rebook-cadence',
      '15 3 * * *',
      $cron$REFRESH MATERIALIZED VIEW CONCURRENTLY public.shop_rebook_cadence$cron$
    );
  ELSE
    RAISE NOTICE 'pg_cron not installed — refresh-shop-rebook-cadence not scheduled';
  END IF;
END $$;
```

### 5. `20260605130400_enqueue_booking_reminder_helper.sql`

Single channel-branching helper. Reads booking + shop + (guest_profile if needed), writes the right row shape into `scheduled_notifications`. Used by both the AFTER INSERT trigger (24h + 2h reminders) and the `cancel_and_followup` helper (review_request, recovery_checkin). Per RESEARCH §17 lines 454–527, denormalized guest fields (`bookings.guest_phone`, `bookings.guest_name`) take precedence; fall back to `guest_profiles` JOIN.

```sql
CREATE OR REPLACE FUNCTION public.enqueue_booking_reminder(
  p_booking_id    UUID,
  p_type          notification_type,
  p_scheduled_for TIMESTAMPTZ
) RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $function$
DECLARE
  v_booking     public.bookings%ROWTYPE;
  v_shop_name   TEXT;
  v_client_name TEXT;
  v_phone       TEXT;
  v_template    TEXT;
  v_channel     TEXT;
  v_notif_id    UUID;
  v_title       TEXT;
  v_body        TEXT;
BEGIN
  SELECT * INTO v_booking FROM public.bookings WHERE id = p_booking_id;
  IF NOT FOUND THEN RETURN NULL; END IF;

  SELECT name INTO v_shop_name FROM public.shops WHERE id = v_booking.shop_id;

  -- Channel branch: user_id → push, guest_profile_id → WhatsApp.
  IF v_booking.user_id IS NOT NULL THEN
    v_channel  := 'push';
    v_template := NULL;
  ELSE
    v_channel := 'whatsapp';
    v_phone   := COALESCE(v_booking.guest_phone,
                          (SELECT phone FROM public.guest_profiles
                            WHERE id = v_booking.guest_profile_id));
    v_client_name := COALESCE(v_booking.guest_name,
                              (SELECT name FROM public.guest_profiles
                                WHERE id = v_booking.guest_profile_id),
                              'there');
    v_template := p_type::text || '_v1';
  END IF;

  -- Per-category copy (RESEARCH §10 lines 322-327).
  v_title := CASE p_type
    WHEN 'booking_reminder_24h' THEN 'Appointment tomorrow'
    WHEN 'booking_reminder_2h'  THEN 'Appointment in 2 hours'
    WHEN 'rebook_nudge'         THEN 'Time for your next visit?'
    WHEN 'review_request'       THEN 'How was your visit?'
    WHEN 'recovery_checkin'     THEN 'We''d love to see you again'
    ELSE NULL
  END;

  v_body := CASE p_type
    WHEN 'booking_reminder_24h' THEN
      'Your appointment at ' || v_shop_name || ' is tomorrow.'
    WHEN 'booking_reminder_2h'  THEN
      'Your appointment at ' || v_shop_name || ' starts in 2 hours.'
    WHEN 'rebook_nudge'         THEN
      'It''s been a while since your last visit to ' || v_shop_name || '. Book again whenever you''re ready.'
    WHEN 'review_request'       THEN
      'Thanks for visiting ' || v_shop_name || '. Tap to leave a rating — takes 5 seconds.'
    WHEN 'recovery_checkin'     THEN
      'We noticed your last appointment at ' || v_shop_name || ' didn''t happen. Book a new time whenever works for you.'
    ELSE NULL
  END;

  INSERT INTO public.scheduled_notifications (
    user_id, guest_profile_id, booking_id, shop_id,
    notification_type, scheduled_for, delivery_channel,
    whatsapp_template, whatsapp_params, status, metadata
  ) VALUES (
    v_booking.user_id,
    v_booking.guest_profile_id,
    p_booking_id,
    v_booking.shop_id,
    p_type,
    p_scheduled_for,
    v_channel,
    v_template,
    CASE WHEN v_channel = 'whatsapp'
         THEN jsonb_build_object('1', v_client_name, '2', v_shop_name)
         ELSE NULL END,
    'pending',
    CASE WHEN v_channel = 'whatsapp'
         THEN jsonb_build_object('phone', v_phone, 'booking_id', p_booking_id, 'shop_name', v_shop_name)
         ELSE jsonb_build_object('title', v_title, 'body', v_body, 'booking_id', p_booking_id, 'shop_name', v_shop_name)
    END
  )
  RETURNING id INTO v_notif_id;

  RETURN v_notif_id;
END;
$function$;

REVOKE ALL ON FUNCTION public.enqueue_booking_reminder(UUID, notification_type, TIMESTAMPTZ) FROM PUBLIC;
-- Not GRANTed to authenticated. Called only from triggers / SECURITY DEFINER RPCs.
COMMENT ON FUNCTION public.enqueue_booking_reminder(UUID, notification_type, TIMESTAMPTZ) IS
  'Channel-branching writer for scheduled_notifications. Single source of metadata + whatsapp_params for the five Phase 12 categories. SECURITY DEFINER; not exposed to clients. O(1).';
```

### 6. `20260605130500_cancel_and_followup_helper.sql`

The named helper from SPEC migration #5 lines 138–140. Called inline from the three terminal-state RPCs in Migration 7. Cancels pending reminders, then enqueues the next-stage row idempotently (the partial unique index from Migration 10 enforces dedupe for `recovery_checkin`).

```sql
CREATE OR REPLACE FUNCTION public.cancel_and_followup(
  p_booking_id      UUID,
  p_terminal_status TEXT
) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $function$
BEGIN
  IF p_terminal_status NOT IN ('cancelled', 'no_show', 'completed') THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'UNKNOWN_TERMINAL_STATUS';
  END IF;

  -- 1. Cancel any pending reminders for this booking.
  PERFORM public.cancel_booking_notifications(p_booking_id);

  -- 2. Schedule the follow-up.
  IF p_terminal_status = 'completed' THEN
    PERFORM public.enqueue_booking_reminder(
      p_booking_id, 'review_request', now() + INTERVAL '2 hours'
    );
  ELSE
    -- cancelled or no_show → recovery_checkin at T+7d, guarded by the
    -- 30-day partial unique index from migration 10.
    BEGIN
      PERFORM public.enqueue_booking_reminder(
        p_booking_id, 'recovery_checkin', now() + INTERVAL '7 days'
      );
    EXCEPTION WHEN unique_violation THEN
      -- Cool-down window suppressed the new row. No-op.
      NULL;
    END;
  END IF;
END;
$function$;

REVOKE ALL ON FUNCTION public.cancel_and_followup(UUID, TEXT) FROM PUBLIC;
COMMENT ON FUNCTION public.cancel_and_followup(UUID, TEXT) IS
  'Idempotent terminal-status handler. Cancels pending reminders, schedules the next-stage row (review_request for completed; recovery_checkin for cancelled/no_show). SECURITY DEFINER; called from cancel_booking / mark_booking_complete / mark_booking_no_show. The narrowly-scoped EXCEPTION WHEN unique_violation block is the idempotency contract: re-invoking this function for the same booking (re-cancellation, double webhook fire, retry storm) is a no-op rather than a duplicate insert. All other errors propagate to the caller for transaction rollback. O(reminders for booking).';
```

### 7. `20260605130600_booking_lifecycle_triggers.sql`

ONE AFTER INSERT OR UPDATE trigger on `bookings`, scoped to `status = 'confirmed'`. Reminder scheduling only — no terminal-state handling here (that lives in the RPCs per RESEARCH §4 recommendation a). The WHEN clause filters to first-confirmed transition; the function body skips re-runs and past windows.

Verified: NO existing triggers on `bookings` (RESEARCH §15 line 430). Zero conflict surface.

```sql
CREATE OR REPLACE FUNCTION public.schedule_booking_reminders()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public AS $function$
BEGIN
  -- Re-confirmation (already-confirmed UPDATE): no-op.
  IF TG_OP = 'UPDATE' AND OLD.status = 'confirmed' THEN
    RETURN NEW;
  END IF;

  -- Past or inside the 2h window: no reminder makes sense.
  IF NEW.start_time <= now() + INTERVAL '2 hours' THEN
    RETURN NEW;
  END IF;

  -- 24h reminder.
  IF NEW.start_time > now() + INTERVAL '24 hours' THEN
    PERFORM public.enqueue_booking_reminder(
      NEW.id, 'booking_reminder_24h',
      NEW.start_time - INTERVAL '24 hours'
    );
  END IF;

  -- 2h reminder.
  PERFORM public.enqueue_booking_reminder(
    NEW.id, 'booking_reminder_2h',
    NEW.start_time - INTERVAL '2 hours'
  );

  RETURN NEW;
END;
$function$;

DROP TRIGGER IF EXISTS trg_bookings_schedule_reminders ON public.bookings;
CREATE TRIGGER trg_bookings_schedule_reminders
  AFTER INSERT OR UPDATE OF status ON public.bookings
  FOR EACH ROW
  WHEN (NEW.status = 'confirmed')
  EXECUTE FUNCTION public.schedule_booking_reminders();

COMMENT ON FUNCTION public.schedule_booking_reminders() IS
  'Phase 12: single source of booking_reminder_24h + booking_reminder_2h rows. Fires on transition INTO confirmed. Skips rebookings of an already-confirmed booking. O(1) per booking.';
```

### 8. `20260605130700_wire_terminal_rpcs.sql`

Wire `cancel_and_followup` into the three existing terminal RPCs. Per RESEARCH §4 recommendation a: simpler, more explicit, easier to test than a generic UPDATE trigger. The three RPCs are `CREATE OR REPLACE`d in full (Postgres has no partial rewrite); the executor copies each current body verbatim from `supabase/migrations/20260517020000_booking_hardening.sql` and inserts the single new `PERFORM cancel_and_followup(...)` call as the **last** statement before the audit-log INSERT.

The three surfaces:

1. **`cancel_booking`** at `20260517020000_booking_hardening.sql:393-440` (function body lines 421–426 region). Insert `PERFORM public.cancel_and_followup(p_booking_id, 'cancelled');` after the `UPDATE bookings SET status='cancelled'...` and before the audit INSERT.
2. **`mark_booking_complete`** at `20260517020000_booking_hardening.sql:447-485` (line 471 region). Insert `PERFORM public.cancel_and_followup(p_booking_id, 'completed');` after the status UPDATE.
3. **`mark_booking_no_show`** at `20260517020000_booking_hardening.sql:498-537` (line 522 region). Insert `PERFORM public.cancel_and_followup(p_booking_id, 'no_show');` after the status UPDATE.

Each rewrite ends with the standard `REVOKE ALL ... FROM PUBLIC; GRANT EXECUTE ... TO authenticated; COMMENT ON FUNCTION ... IS 'Phase 12: cancel_and_followup wired in. ...'` trio. Signatures byte-for-byte preserved. The `FOR UPDATE` row locks already present at the top of each function keep the cancel + followup atomic with the status flip (RESEARCH §4 line 126).

(Body templates omitted for length — the executor copies the current bodies verbatim and inserts the documented single-line PERFORM call.)

### 9. `20260605130800_consolidate_reminder_scheduling_backfill.sql`

One-time backfill. After the trigger is live (Migration 7) and BEFORE the webhook diffs land (Task 4), every existing `confirmed` + future booking that does NOT already have a pending `booking_reminder_24h` row gets one inserted. Idempotent — if the row exists, `ON CONFLICT DO NOTHING` skips. Safe to re-run.

The partial unique index from RESEARCH §9 lines 282–291 covers only `rebook_nudge` and `recovery_checkin`. For the backfill we use an explicit NOT EXISTS guard instead — there is no existing unique index on `(booking_id, notification_type, status)` for reminders.

```sql
-- Phase 12 backfill: ensure every confirmed + future booking has a
-- pending booking_reminder_24h row. Idempotent and safe to re-run.
--
-- Required because:
--   - Migration 7 makes the trigger the SINGLE source of reminders.
--   - The webhook diffs (Task 4, edge-fn deploy) remove three former
--     writers (paystack-webhook, stripe-webhook, verify-payment).
-- Without this backfill, bookings that were confirmed BEFORE the
-- trigger landed but AFTER the webhook write would silently lose
-- their 24h reminder.

DO $$
DECLARE
  v_booking RECORD;
BEGIN
  FOR v_booking IN
    SELECT b.id, b.start_time
    FROM public.bookings b
    WHERE b.status = 'confirmed'
      AND b.start_time > now() + INTERVAL '24 hours'
      AND NOT EXISTS (
        SELECT 1 FROM public.scheduled_notifications s
        WHERE s.booking_id = b.id
          AND s.notification_type = 'booking_reminder_24h'
          AND s.status IN ('pending', 'processing', 'sent')
      )
  LOOP
    PERFORM public.enqueue_booking_reminder(
      v_booking.id, 'booking_reminder_24h',
      v_booking.start_time - INTERVAL '24 hours'
    );
  END LOOP;

  FOR v_booking IN
    SELECT b.id, b.start_time
    FROM public.bookings b
    WHERE b.status = 'confirmed'
      AND b.start_time > now() + INTERVAL '2 hours'
      AND NOT EXISTS (
        SELECT 1 FROM public.scheduled_notifications s
        WHERE s.booking_id = b.id
          AND s.notification_type = 'booking_reminder_2h'
          AND s.status IN ('pending', 'processing', 'sent')
      )
  LOOP
    PERFORM public.enqueue_booking_reminder(
      v_booking.id, 'booking_reminder_2h',
      v_booking.start_time - INTERVAL '2 hours'
    );
  END LOOP;
END $$;
```

### 10. `20260605130900_enqueue_rebook_nudges_rpc.sql`

The nightly SQL function + pg_cron schedule. Idempotency via the partial unique index from RESEARCH §9 lines 282–291 plus the 30-day cooldown EXISTS clause from §9 lines 301–315. Defence in depth: the index handles same-day re-runs; the EXISTS handles the 30-day window explicitly.

```sql
-- Partial unique index — same-day re-run dedupe for the two cooldown
-- categories (rebook_nudge, recovery_checkin). Manual reminder
-- (booking_reminder_manual) is explicitly excluded per RESEARCH §18.
CREATE UNIQUE INDEX IF NOT EXISTS scheduled_notifications_rebook_idem
  ON public.scheduled_notifications (
    shop_id,
    COALESCE(user_id, guest_profile_id),
    notification_type,
    (scheduled_for::date)
  )
  WHERE notification_type IN ('rebook_nudge', 'recovery_checkin')
    AND status IN ('pending', 'processing');

CREATE OR REPLACE FUNCTION public.enqueue_rebook_nudges()
RETURNS INTEGER
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $function$
DECLARE
  v_inserted INTEGER := 0;
BEGIN
  WITH eligible AS (
    SELECT
      b.shop_id,
      b.user_id,
      b.guest_profile_id,
      MAX(b.start_time) AS last_completed_at
    FROM public.bookings b
    WHERE b.status = 'completed'
    GROUP BY b.shop_id, b.user_id, b.guest_profile_id
  ),
  due AS (
    SELECT e.*, c.median_gap_days
    FROM eligible e
    JOIN public.shop_rebook_cadence c USING (shop_id)
    WHERE (e.last_completed_at::date + (c.median_gap_days || ' days')::interval)::date
            = current_date
      -- No future booking already on the books.
      AND NOT EXISTS (
        SELECT 1 FROM public.bookings fb
        WHERE fb.shop_id = e.shop_id
          AND fb.start_time > now()
          AND fb.status IN ('pending', 'confirmed')
          AND (
            (fb.user_id IS NOT NULL AND fb.user_id = e.user_id)
            OR
            (fb.guest_profile_id IS NOT NULL AND fb.guest_profile_id = e.guest_profile_id)
          )
      )
      -- 30-day cooldown for rebook_nudge.
      AND NOT EXISTS (
        SELECT 1 FROM public.scheduled_notifications s
        WHERE s.shop_id = e.shop_id
          AND COALESCE(s.user_id, s.guest_profile_id)
              = COALESCE(e.user_id, e.guest_profile_id)
          AND s.notification_type = 'rebook_nudge'
          AND s.scheduled_for > now() - INTERVAL '30 days'
      )
  )
  INSERT INTO public.scheduled_notifications (
    user_id, guest_profile_id, shop_id,
    notification_type, scheduled_for, delivery_channel,
    whatsapp_template, whatsapp_params, status, metadata
  )
  SELECT
    d.user_id,
    d.guest_profile_id,
    d.shop_id,
    'rebook_nudge',
    now() + INTERVAL '1 hour',
    CASE WHEN d.user_id IS NOT NULL THEN 'push' ELSE 'whatsapp' END,
    CASE WHEN d.user_id IS NOT NULL THEN NULL ELSE 'rebook_nudge_v1' END,
    CASE WHEN d.user_id IS NOT NULL
         THEN NULL
         ELSE jsonb_build_object(
                '1', COALESCE((SELECT name FROM public.guest_profiles WHERE id = d.guest_profile_id), 'there'),
                '2', (SELECT name FROM public.shops WHERE id = d.shop_id))
    END,
    'pending',
    jsonb_build_object(
      'title', 'Time for your next visit?',
      'body',  'It''s been a while since your last visit to ' ||
               (SELECT name FROM public.shops WHERE id = d.shop_id) || '.',
      'shop_name', (SELECT name FROM public.shops WHERE id = d.shop_id)
    )
  FROM due d
  ON CONFLICT (shop_id, COALESCE(user_id, guest_profile_id), notification_type, (scheduled_for::date))
    WHERE notification_type IN ('rebook_nudge', 'recovery_checkin')
      AND status IN ('pending', 'processing')
    DO NOTHING;

  GET DIAGNOSTICS v_inserted = ROW_COUNT;
  RETURN v_inserted;
END;
$function$;

REVOKE ALL ON FUNCTION public.enqueue_rebook_nudges() FROM PUBLIC;
-- Not GRANTed to authenticated. Cron-only.
COMMENT ON FUNCTION public.enqueue_rebook_nudges() IS
  'Nightly: emit one rebook_nudge per (shop, client) where last-completed + shop median gap == today, no future booking on books, no rebook_nudge in last 30d. Idempotent via partial unique index + 30d EXISTS guard. O(completed_bookings) per shop.';

-- Schedule it nightly at 03:30 UTC (after the cadence refresh at 03:15).
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
    PERFORM cron.schedule(
      'enqueue-rebook-nudges',
      '30 3 * * *',
      $cron$SELECT public.enqueue_rebook_nudges()$cron$
    );
  ELSE
    RAISE NOTICE 'pg_cron not installed — enqueue-rebook-nudges not scheduled';
  END IF;
END $$;
```

## Tasks

Atomic. Each touches ≤ 3 files. Each maps to ≥ 1 acceptance test in the Verification matrix. Estimates in minutes.

### Wave 0 — Schema groundwork

**Task 0.1 — Add three notification_type enum values**
- File(s): `supabase/migrations/20260605130000_add_phase12_notification_types.sql` (NEW)
- Description: Per Migration Plan §1. Three `ALTER TYPE notification_type ADD VALUE IF NOT EXISTS` calls. No defensive discovery DO block — live DB confirmed enum 2026-06-05.
- Acceptance: `psql staging -c "SELECT unnest(enum_range(NULL::notification_type))"` lists `rebook_nudge`, `review_request`, `recovery_checkin`. Re-running the migration is a no-op (`IF NOT EXISTS`).
- Rollback: enum values cannot be dropped without recreating the type. Acceptable — Phase 12 rollback strategy is forward-only on the enum.
- Estimate: 10

**Task 0.2 — Create `client_notes` table + RLS + UNIQUE index**
- File(s): `supabase/migrations/20260605130100_client_notes_table.sql` (NEW)
- Description: Per Migration Plan §2. Four-policy RLS (SELECT / INSERT / UPDATE; no DELETE) per RESEARCH §6. CHECK on `(user_id IS NULL) <> (guest_profile_id IS NULL)`. CHECK on `char_length(body) <= 2000`. Partial-style UNIQUE index keyed on `(shop_id, COALESCE(user_id::text, guest_profile_id::text))`.
- Acceptance: `psql -c "\d public.client_notes"` shows the three CHECKs + the UNIQUE index. `SELECT polname FROM pg_policies WHERE tablename='client_notes'` returns exactly 3 rows (`client_notes_select_owner`, `client_notes_insert_owner`, `client_notes_update_owner`). Smoke §D (RLS-deny on another shop's owner) passes.
- Rollback: `DROP TABLE public.client_notes CASCADE`. Safe — no production data depended on it before Phase 12.
- Estimate: 30

**Task 0.3 — Create `shop_rebook_cadence` materialized view + pg_cron refresh**
- File(s): `supabase/migrations/20260605130300_shop_rebook_cadence_view.sql` (NEW)
- Description: Per Migration Plan §4. `CREATE MATERIALIZED VIEW IF NOT EXISTS` with the percentile_cont median + GREATEST(7, LEAST(90, ...)) clamping + default-30 when sample size < 5. UNIQUE index `shop_rebook_cadence_pk` for `REFRESH ... CONCURRENTLY`. `pg_cron.schedule('refresh-shop-rebook-cadence', '15 3 * * *', ...)` guarded by `IF EXISTS pg_extension WHERE extname='pg_cron'`.
- Acceptance: `SELECT shop_id, median_gap_days, sample_size FROM shop_rebook_cadence LIMIT 5` returns ≥ 1 row per shop. A shop with 1 completed booking returns `median_gap_days = 30, sample_size = 0` (default branch). `SELECT * FROM cron.job WHERE jobname='refresh-shop-rebook-cadence'` returns 1 row.
- Rollback: `DROP MATERIALIZED VIEW shop_rebook_cadence; SELECT cron.unschedule('refresh-shop-rebook-cadence')`.
- Estimate: 40

### Wave 1 — Server logic (depends on Wave 0)

**Task 1.1 — Create `upsert_client_note` RPC**
- File(s): `supabase/migrations/20260605130200_upsert_client_note_rpc.sql` (NEW)
- Description: Per Migration Plan §3. Hardening template byte-for-byte. Authz FIRST. HINT codes: `EXACTLY_ONE_OF_USER_OR_GUEST`, `BODY_NULL_NOT_ALLOWED`, `NOTE_TOO_LONG`. UPSERT on the unique-index expression `(shop_id, COALESCE(user_id::text, guest_profile_id::text))`. `REVOKE ALL FROM PUBLIC; GRANT EXECUTE TO authenticated`.
- Acceptance: Smoke §E–§H print `OK:`: §E non-owner → 42501; §F both ids → 22023 / EXACTLY_ONE_OF_USER_OR_GUEST; §G body > 2000 chars → 22023 / NOTE_TOO_LONG; §H happy path upserts then second call updates same row (id stable).
- Rollback: `DROP FUNCTION public.upsert_client_note(UUID, UUID, UUID, TEXT)`.
- Estimate: 35

**Task 1.2 — Create `enqueue_booking_reminder` helper**
- File(s): `supabase/migrations/20260605130400_enqueue_booking_reminder_helper.sql` (NEW)
- Description: Per Migration Plan §5. Channel branching: `user_id IS NOT NULL` → push (metadata.title / body, no whatsapp_template); else → WhatsApp (whatsapp_template = `<type>_v1`, whatsapp_params = `{1: client_name, 2: shop_name}`, metadata.phone). Title + body per RESEARCH §10 lines 322–327. Returns the inserted row id. Not GRANTed to `authenticated` — internal only.
- Acceptance: Helper inserts the right row shape for a registered booking (delivery_channel='push', whatsapp_template IS NULL, metadata.title + body present). Helper inserts the right shape for a guest booking (delivery_channel='whatsapp', whatsapp_template='booking_reminder_24h_v1', metadata.phone present, whatsapp_params has '1' and '2' keys). Verified via a direct SELECT after a PERFORM call in §J of the smoke SQL.
- Rollback: `DROP FUNCTION public.enqueue_booking_reminder(UUID, notification_type, TIMESTAMPTZ)`.
- Estimate: 50

**Task 1.3 — Create `cancel_and_followup` helper**
- File(s): `supabase/migrations/20260605130500_cancel_and_followup_helper.sql` (NEW)
- Description: Per Migration Plan §6. Validates `p_terminal_status IN ('cancelled', 'no_show', 'completed')`. Calls `cancel_booking_notifications(p_booking_id)` then conditionally enqueues review_request (completed, +2h) or recovery_checkin (cancelled/no_show, +7d). Wrapped in a `BEGIN ... EXCEPTION WHEN unique_violation ... END` to swallow cool-down dedupe from the partial unique index (Migration 10).
- Acceptance: Smoke §B and §C (post-Migration 7) print `OK:`. Unknown status → 22023 / UNKNOWN_TERMINAL_STATUS. Calling twice for the same `completed` booking inserts only one `review_request` (no cooldown index covers it — duplicates allowed; caller of the helper is the RPC, called once per status flip).
- Rollback: `DROP FUNCTION public.cancel_and_followup(UUID, TEXT)`.
- Estimate: 30

**Task 1.4 — Create AFTER INSERT/UPDATE trigger on `bookings`**
- File(s): `supabase/migrations/20260605130600_booking_lifecycle_triggers.sql` (NEW)
- Description: Per Migration Plan §7. ONE trigger function `schedule_booking_reminders`. `WHEN (NEW.status = 'confirmed')`. Skips re-confirmation (UPDATE where OLD.status was already 'confirmed'). Skips when `start_time <= now() + INTERVAL '2 hours'` (the 2h-or-past short-circuit from SPEC line 73). Schedules 24h reminder only if `start_time > now() + INTERVAL '24 hours'`; always schedules 2h reminder otherwise. Verified: zero existing triggers on `bookings` (RESEARCH §15 line 430) — no conflict.
- Acceptance: Smoke §A prints `OK:` (insert a confirmed booking 26h out → exactly 2 pending rows materialize). Inserting an `unconfirmed` (e.g. `pending`) booking → ZERO pending rows. Updating `status` from `pending` → `confirmed` on a 26h-out booking → 2 rows. Re-updating `confirmed` → `confirmed` (audit no-op) → 0 additional rows.
- Rollback: `DROP TRIGGER trg_bookings_schedule_reminders ON public.bookings; DROP FUNCTION public.schedule_booking_reminders()`.
- Estimate: 45

**Task 1.5 — Wire `cancel_and_followup` into `cancel_booking`, `mark_booking_complete`, `mark_booking_no_show`**
- File(s): `supabase/migrations/20260605130700_wire_terminal_rpcs.sql` (NEW)
- Description: Per Migration Plan §8. Open the new file, copy the current body of `cancel_booking` from `supabase/migrations/20260517020000_booking_hardening.sql:393-440` verbatim, and insert `PERFORM public.cancel_and_followup(p_booking_id, 'cancelled');` after the status UPDATE (around line 426) and BEFORE the audit-log INSERT. Append the REVOKE/GRANT/COMMENT trio with `'Phase 12: cancel_and_followup wired. ...'`. Repeat for `mark_booking_complete` (line 471 region — insert `PERFORM ... 'completed'`) and `mark_booking_no_show` (line 522 region — insert `PERFORM ... 'no_show'`). Signatures byte-for-byte preserved. The function-body `FOR UPDATE` row locks already at the top of each RPC keep the status flip + followup atomic with the booking row (RESEARCH §4 line 126).
- Acceptance: Smoke §B prints `OK:` (cancel a confirmed booking → 2 reminder rows flip to `cancelled` AND 1 `recovery_checkin` row appears scheduled for now()+7d). Smoke §C prints `OK:` (mark_booking_complete on a confirmed booking → reminders cancelled AND 1 `review_request` row at now()+2h). `grep -c 'cancel_and_followup' supabase/migrations/20260605130700_wire_terminal_rpcs.sql | grep -v '^--'` returns at least 3 (one per surface).
- Rollback: Ship a follow-up migration that recreates the three RPCs from their original bodies in `20260517020000_booking_hardening.sql`. Do NOT drop `cancel_and_followup` — bookings already in a terminal state would orphan their pending reminders.
- Estimate: 55

### Wave 2 — Backfill + webhook diffs (depends on Wave 1)

**Task 2.1 — One-time reminder consolidation backfill**
- File(s): `supabase/migrations/20260605130800_consolidate_reminder_scheduling_backfill.sql` (NEW)
- Description: Per Migration Plan §9. Two `DO $$ ... FOR ... LOOP ...` blocks. First loop: every `confirmed` booking with `start_time > now() + 24h` that has no pending/processing/sent `booking_reminder_24h` row gets one inserted via `enqueue_booking_reminder`. Second loop: same for `booking_reminder_2h` with `> now() + 2h` filter. NOT EXISTS guard makes it idempotent — re-running is a no-op.
- Acceptance: After migration, `SELECT COUNT(*) FROM scheduled_notifications WHERE notification_type='booking_reminder_24h' AND status='pending'` is ≥ the count of `confirmed` bookings with `start_time > now() + 24h`. Re-running the migration leaves the count unchanged (idempotent).
- Rollback: There is no clean rollback for the backfill — the inserted rows are now part of the canonical pipeline. If something goes wrong, manually `DELETE FROM scheduled_notifications WHERE notification_type IN ('booking_reminder_24h', 'booking_reminder_2h') AND status='pending' AND created_at > '<backfill-deploy-ts>'`. Document the cutoff timestamp in the PR.
- Estimate: 25

**Task 2.2 — Webhook diff: remove reminder inserts from `paystack-webhook`**
- File(s): `supabase/functions/paystack-webhook/index.ts`
- Description: DELETE the guest-path reminder-insert block at lines 269–292 (the block that inserts `booking_reminder_24h` + `booking_reminder_2h` WhatsApp rows). DELETE the registered-path reminder-insert block at lines 524–543 (the block that inserts `booking_reminder_24h` + `booking_reminder_1h` + `booking_reminder_5min` push rows). KEEP the immediate `booking_confirmation` insert in both paths — that's the confirmation message, not a reminder. KEEP the `booking_review_prompt` insert in the guest path — Phase 12's `review_request` is RPC-driven on `mark_booking_complete`; the guest-path immediate review prompt is a separate, redundant-but-harmless flow that the SPEC scope does not require removing. (RESEARCH §1 lines 33–38 — locked option (a).)
- Acceptance: `grep -n "booking_reminder_24h\|booking_reminder_2h\|booking_reminder_1h\|booking_reminder_5min" supabase/functions/paystack-webhook/index.ts | grep -v '^//'` returns 0. `grep -n "booking_confirmation" supabase/functions/paystack-webhook/index.ts` still returns ≥ 1 (kept). Deno test or local `deno check` passes.
- Rollback: `git revert` the commit. The backfill (Task 2.1) ensures no booking falls through the rollback window — even after revert, the trigger (Task 1.4) is still in place writing reminders for new confirmed bookings.
- Estimate: 30

**Task 2.3 — Webhook diff: remove reminder inserts from `stripe-webhook` and `verify-payment`**
- File(s): `supabase/functions/stripe-webhook/index.ts`, `supabase/functions/verify-payment/index.ts`
- Description: In `stripe-webhook/index.ts`: DELETE the guest-path reminder-insert block at lines 337–360. In `verify-payment/index.ts`: DELETE the `booking_reminder_24h` insert block around line 298. KEEP all `booking_confirmation` / `booking_review_prompt` inserts intact.
- Acceptance: `grep -n "booking_reminder" supabase/functions/stripe-webhook/index.ts | grep -v '^//'` returns 0. `grep -n "booking_reminder" supabase/functions/verify-payment/index.ts | grep -v '^//'` returns 0. Both files still contain `booking_confirmation` if they had it before.
- Rollback: `git revert`.
- Estimate: 20

### Wave 3 — Nightly cron (depends on Wave 0 for the view, Wave 1 for the helper)

**Task 3.1 — Create `enqueue_rebook_nudges()` SQL function + partial unique index + pg_cron schedule**
- File(s): `supabase/migrations/20260605130900_enqueue_rebook_nudges_rpc.sql` (NEW)
- Description: Per Migration Plan §10. First create the partial unique index `scheduled_notifications_rebook_idem` keyed on `(shop_id, COALESCE(user_id, guest_profile_id), notification_type, (scheduled_for::date))` WHERE `notification_type IN ('rebook_nudge', 'recovery_checkin') AND status IN ('pending', 'processing')`. Then the function: CTE `eligible` (per-client last completed start_time), join to `shop_rebook_cadence` for `median_gap_days`, filter to `(last_completed + median_gap)::date = current_date`, filter out clients with any future pending/confirmed booking on the books, filter out clients with a `rebook_nudge` row in the last 30 days, insert one row per (shop, client) with `ON CONFLICT ... DO NOTHING` against the partial unique index. Schedule via `cron.schedule('enqueue-rebook-nudges', '30 3 * * *', ...)` guarded by `IF EXISTS pg_extension WHERE extname='pg_cron'`.
- Acceptance: Smoke §I prints `OK:` (insert a completed booking N=30 days ago for a shop with default 30d cadence, no future booking; call `enqueue_rebook_nudges()` → returns 1; call again same day → returns 0; idempotency proven). `EXPLAIN ANALYZE SELECT public.enqueue_rebook_nudges()` runs in < 30s against staging.
- Rollback: `SELECT cron.unschedule('enqueue-rebook-nudges'); DROP FUNCTION public.enqueue_rebook_nudges(); DROP INDEX scheduled_notifications_rebook_idem`.
- Estimate: 60

### Wave 4 — Client surface (depends on Wave 1 for upsert RPC; can run in parallel with Wave 2–3)

**Task 4.1 — `ClientNoteDTO` data model**
- File(s): `lib/presentation/features/shops/dashboard/data/models/client_note_dto.dart` (NEW)
- Description: Simple immutable DTO. Fields: `id` (String?, nullable on first save), `shopId` (String), `userId` (String?), `guestProfileId` (String?), `body` (String), `updatedAt` (DateTime), `updatedByUserId` (String?). `fromJson(Map<String, dynamic> json)` constructor mapping snake_case → camelCase. `toJson()` for completeness. NO Equatable required — mirrored from `appointment_slot_dto.dart` shape.
- Acceptance: `dart analyze` clean. Smoke test in `client_notes_repository_test.dart` task 6.2 round-trips a JSON map through `fromJson` and asserts every field.
- Estimate: 15

**Task 4.2 — `ClientNoteException` hierarchy**
- File(s): `lib/presentation/features/shops/dashboard/data/exceptions/client_notes_exceptions.dart` (NEW)
- Description: Mirror `business_hours_exceptions.dart` byte-for-byte per RESEARCH §13 lines 386–414. Base `ClientNoteException` with `message` (logs only), `code` (default `'NOTE_GENERIC'`), `userMessage` (default `'Something went wrong. Please try again.'`). Subtypes: `NoteAccessDeniedException` (`NOTE_ACCESS_DENIED`, "You don't have access to this note."), `NotePayloadInvalidException` (`NOTE_PAYLOAD_INVALID`, "Please re-check the note."), `NoteTooLongException` (`NOTE_TOO_LONG`, "The note is too long. Please shorten it."), `NoteSaveFailedException` (`NOTE_SAVE_FAILED`, "We couldn't save the note. Please try again."). NO `e.toString()` ever flows into `userMessage`.
- Acceptance: `dart analyze` clean on the file. Unit test in Task 6.1 passes.
- Estimate: 20

**Task 4.3 — Repository abstract API + Supabase implementation with typed-exception mapping**
- File(s): `lib/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart`, `lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart`
- Description: Add two abstract methods to `DashboardRepository`:
  ```dart
  Future<ClientNoteDTO?> getClientNote({
    required String shopId,
    String? userId,
    String? guestProfileId,
  });
  Future<String> upsertClientNote({
    required String shopId,
    String? userId,
    String? guestProfileId,
    required String body,
  });
  ```
  In `SupabaseDashboardRepository`:
  - `getClientNote`: a single `.from('client_notes').select('*').eq('shop_id', shopId)` query. If `userId != null`, append `.eq('user_id', userId)`; else `.eq('guest_profile_id', guestProfileId)`. `.maybeSingle()`. Return `ClientNoteDTO.fromJson(row)` or `null`. Catch `PostgrestException` → map `'42501'` / `'P0002'` → `NoteAccessDeniedException()`; fallback → `NoteSaveFailedException()` (read-side fallback). Log via `AppLogger.warn('client_note.fetch_failed', fields: {'shop_id': shopId, 'error': e.toString()})` BEFORE throw.
  - `upsertClientNote`: `await _supabase.rpc('upsert_client_note', params: {'p_shop_id': shopId, 'p_user_id': userId, 'p_guest_profile_id': guestProfileId, 'p_body': body})`. Cast result to String (the returned `id`). Catch `PostgrestException` → map `'42501'` → `NoteAccessDeniedException()`; `'22023'` with hint `'NOTE_TOO_LONG'` → `NoteTooLongException()`; `'22023'` with hint `'EXACTLY_ONE_OF_USER_OR_GUEST'` or `'BODY_NULL_NOT_ALLOWED'` → `NotePayloadInvalidException()`; fallback → `NoteSaveFailedException()`. Log before throw.
  - NEVER interpolate `$e` into the throw message. NEVER use `e.toString().contains(...)` for branching.
- Acceptance: `grep -n "e\.toString()\.contains" lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart` returns 0 (verifies no string-matching branches). `flutter analyze` clean. Task 6.2 repository unit tests pass.
- Estimate: 45

**Task 4.4 — `clientNoteProvider` family**
- File(s): `lib/presentation/features/shops/dashboard/providers/client_note_provider.dart` (NEW)
- Description: `final clientNoteProvider = FutureProvider.family<ClientNoteDTO?, ClientNoteKey>((ref, key) async => ref.read(dashboardRepositoryProvider).getClientNote(shopId: key.shopId, userId: key.userId, guestProfileId: key.guestProfileId));`. Define `ClientNoteKey` as an immutable record-like class with `shopId`, `userId`, `guestProfileId` + `==` / `hashCode` so the family invalidates cleanly. Reason for the family key: identity is `(shopId, userId | guestProfileId)`, not `bookingId` — the same client may have multiple bookings; the note belongs to the client, not the booking.
- Acceptance: `flutter analyze` clean. `dart analyze` reports zero warnings. Provider can be invalidated via `ref.invalidate(clientNoteProvider(key))` after save.
- Estimate: 20

**Task 4.5 — `ClientStickyNoteCard` widget (explicit Save button, no debounce auto-save)**
- File(s): `lib/presentation/features/shops/dashboard/presentation/widgets/client_sticky_note_card.dart` (NEW)
- Description: `ConsumerStatefulWidget`. Constructor: `ClientStickyNoteCard({required this.booking, super.key})`. Internal state: `TextEditingController _controller`, `String? _initialBody` (snapshot from last load — NOT updated until save success). Watches `clientNoteProvider(ClientNoteKey(shopId: booking.shopId, userId: booking.userId, guestProfileId: booking.guestProfileId))`. AsyncValue switch:
  - `loading` → shrinkwrapped spinner card.
  - `error` → small `error_state.dart` retry card.
  - `data` → render a Card with:
    - Header: "Private note about this client" + helper text "Only you can see this".
    - Multi-line `TextField` (max 2000 chars enforced via `MaxLengthEnforcement.enforced` + `LengthLimitingTextInputFormatter(2000)`).
    - Below the field: char counter `"${_controller.text.length} / 2000"`.
    - **Explicit `Save` button** — NO debounce, NO auto-save (locked decision per planner brief). Button disabled when `_controller.text == _initialBody` (no change to save) OR when length > 2000 (defensive; the formatter should prevent).
    - On Save tap: `try { await repo.upsertClientNote(...); _initialBody = _controller.text; ref.invalidate(clientNoteProvider(key)); Snackbar.success(context, 'Note saved'); setState(() {}); } on ClientNoteException catch (e) { Snackbar.error(context, e.userMessage); }`. Show a small inline spinner overlay on the button while in flight.
  - Initial `_controller.text` seeded from `data?.body ?? ''`; `_initialBody` likewise. `initState` does NOT pre-populate (the AsyncValue hasn't resolved yet); seed on first non-loading `data` build instead, via a `_didSeed` flag.
- Acceptance: Widget compiles. Task 6.3 widget tests pass: (a) on first load, Save is disabled (body unchanged from server); (b) typing in the field enables Save; (c) tapping Save calls repo exactly once; (d) on save success, Save re-disables (text now matches new _initialBody); (e) on save error, Snackbar.error shows `userMessage`; (f) char counter updates as user types. `grep -n 'debounce\|Timer.periodic\|onChanged.*upsert' lib/presentation/features/shops/dashboard/presentation/widgets/client_sticky_note_card.dart` returns 0 (no auto-save).
- Estimate: 60

**Task 4.6 — Integrate `ClientStickyNoteCard` into `BookingDetailScreen`**
- File(s): `lib/presentation/features/shops/booking/presentation/screens/shared/booking_detail_screen.dart`
- Description: At line 131 region (the `if (widget.isShopOwner)` branch — verified in SPEC line 116 reference), insert a single new child widget after the existing owner-only blocks:
  ```dart
  if (widget.isShopOwner) ...[
    // existing owner-only content
    const SizedBox(height: 16),
    ClientStickyNoteCard(booking: booking),
  ],
  ```
  Add the import for `ClientStickyNoteCard`. The card reads `booking.shopId`, `booking.userId`, `booking.guestProfileId` directly from the already-loaded booking model — NO new view, NO new RPC for client identity. (SPEC line 79 + RESEARCH §7.)
- Acceptance: Booking detail screen renders the card under `isShopOwner` for both registered and guest bookings. `grep -n 'ClientStickyNoteCard' lib/presentation/features/shops/booking/presentation/screens/shared/booking_detail_screen.dart` returns 1. `flutter analyze` clean. Widget test in Task 6.3 (e) confirms the card surfaces under the owner branch.
- Estimate: 15

### Wave 5 — Tests (depends on Waves 0–4)

**Task 5.1 — `ClientNoteException` unit test**
- File(s): `test/presentation/features/shops/dashboard/data/exceptions/client_notes_exceptions_test.dart` (NEW)
- Description: Mirror `business_hours_exceptions_test.dart` shape. Tests: (a) base `ClientNoteException('boom')` has `code == 'NOTE_GENERIC'` + default `userMessage`; (b) `toString()` returns `'ClientNoteException(NOTE_GENERIC): boom'`; (c) each subtype exposes its declared `code` and `userMessage`; (d) `NoteAccessDeniedException` does NOT include shop_id / user_id in `userMessage` (PII isolation per RESEARCH §12 step 7).
- Acceptance: `flutter test test/presentation/features/shops/dashboard/data/exceptions/client_notes_exceptions_test.dart` passes.
- Estimate: 15

**Task 5.2 — `client_notes_repository_test.dart` — repo contract tests (mocktail)**
- File(s): `test/presentation/features/shops/dashboard/data/repositories/client_notes_repository_test.dart` (NEW)
- Description: Mirror `services_repository_test.dart` pattern from Phase 11. Mock `SupabaseClient` via `mocktail`. Tests:
  (a) `getClientNote` issues the right `.from('client_notes').select('*').eq('shop_id', ...).eq('user_id', ...).maybeSingle()` chain when `userId` is provided.
  (b) Same query uses `.eq('guest_profile_id', ...)` when `guestProfileId` is provided (and NOT `.eq('user_id', ...)`).
  (c) `upsertClientNote` issues exactly one `.rpc('upsert_client_note', params: {'p_shop_id': ..., 'p_user_id': ..., 'p_guest_profile_id': ..., 'p_body': ...})` call.
  (d) When `.rpc` throws `PostgrestException(code: '42501')`, caller receives `NoteAccessDeniedException`.
  (e) When `.rpc` throws `PostgrestException(code: '22023', hint: 'NOTE_TOO_LONG')`, caller receives `NoteTooLongException`.
  (f) When `.rpc` throws `PostgrestException(code: '22023', hint: 'EXACTLY_ONE_OF_USER_OR_GUEST')`, caller receives `NotePayloadInvalidException`.
  (g) When `.rpc` throws an unmapped `PostgrestException`, caller receives `NoteSaveFailedException`.
- Acceptance: `flutter test test/presentation/features/shops/dashboard/data/repositories/client_notes_repository_test.dart` passes all 7 cases. No `e.toString().contains` anywhere in the production code path (verified via grep in §Definition of done).
- Estimate: 50

**Task 5.3 — `ClientStickyNoteCard` widget test**
- File(s): `test/presentation/features/shops/dashboard/presentation/widgets/client_sticky_note_card_test.dart` (NEW)
- Description: `ProviderScope` override of `dashboardRepositoryProvider` with a fake returning a fixed `ClientNoteDTO`. Tests:
  (a) On first load, Save is disabled (text matches initial body).
  (b) Typing in the field enables Save.
  (c) Clearing the field back to the original body re-disables Save.
  (d) Tap Save → fake repo's `upsertClientNote` is called exactly once with the typed body.
  (e) After save success, Save is disabled again (the new text becomes the new baseline).
  (f) When the fake throws `NoteTooLongException`, `Snackbar.error` shows `"The note is too long. Please shorten it."`.
  (g) Char counter updates as the user types (assert via `find.text('5 / 2000')`).
- Acceptance: `flutter test test/presentation/features/shops/dashboard/presentation/widgets/client_sticky_note_card_test.dart` passes all 7 cases. The Save button's enabled/disabled state is asserted by querying the widget's `onPressed != null` predicate, not a visual property.
- Estimate: 55

**Task 5.4 — SQL smoke-test script**
- File(s): `.planning/phases/12-autonomous-retention-engine/sql/12_smoke_tests.sql` (NEW — see separate file)
- Description: Hand-runnable script against a staging branch DB. Sections per the four proof obligations in the planner brief: (A) trigger schedules exactly 2 rows for a confirmed booking 26h out; (B) status flip to cancelled cancels reminders + inserts recovery_checkin; (C) status flip to completed cancels reminders + inserts review_request; (D) sticky-note RLS denies another shop's owner; (E)–(H) `upsert_client_note` authz + payload validation; (I) `enqueue_rebook_nudges` idempotency on same-day re-run; (J) `enqueue_booking_reminder` channel branching (registered → push, guest → WhatsApp). Each section ends with `RAISE NOTICE 'OK: <case>';` and is wrapped in `SAVEPOINT ... ROLLBACK TO SAVEPOINT` for isolation. The whole script is wrapped in `BEGIN ... ROLLBACK` so it leaves no residue on staging.
- Acceptance: `psql $STAGING_DB_URL -f .planning/phases/12-autonomous-retention-engine/sql/12_smoke_tests.sql` prints `OK:` for every case (§A–§J). Re-running the same script is a no-op (the outer ROLLBACK undoes everything).
- Estimate: 90

### Wave 6 — Meta + UAT (parallel with Wave 5)

**Task 6.1 — Submit three WhatsApp templates to Meta**
- File(s): n/a — Meta Business Manager dashboard.
- Description: Submit `rebook_nudge_v1`, `review_request_v1`, `recovery_checkin_v1`. Copy lifted verbatim from RESEARCH §10 lines 322–327 (body uses `{{1}}` for `client_name`, `{{2}}` for `shop_name`; `review_request_v1` adds `{{3}}` for `review_url`). Category: MARKETING for `rebook_nudge` + `recovery_checkin`; UTILITY for `review_request`. Submission BEFORE merging the SQL migrations. The worker's existing 6-hour `WhatsAppTemplateNotFoundError` retry behavior at `supabase/functions/process-scheduled-notifications/index.ts:124-128` auto-defers pending rows until Meta approves — no flag, no skip logic required.
- Acceptance: Three templates appear in the Meta dashboard as `SUBMITTED` or `APPROVED`. Approval IDs captured in the PR description for forensic.
- Rollback: Templates can sit in `SUBMITTED` indefinitely without affecting production. The 6-hour retry simply keeps deferring.
- Estimate: 30

**Task 6.2 — Manual UAT: end-to-end retention loop on staging**
- File(s): n/a (manual).
- Description: On a real staging shop with a real test phone (or a registered test user): (1) **Create the booking through the real client booking flow with a successful test payment (Paystack test card or Stripe test card) so the webhook fires.** This is the only path that proves the trigger fires under the actual service-role UPDATE that the webhook performs (a direct `INSERT INTO bookings` from psql would skip the webhook and miss the deduplication contract we're verifying). The booking start_time must be 26 hours in the future. Verify in staging DB that `scheduled_notifications` has exactly 2 pending rows for that booking_id (`booking_reminder_24h`, `booking_reminder_2h`) and ZERO `booking_reminder_1h` / `booking_reminder_5min` rows (proves webhook diffs in Tasks 2.2 / 2.3 took effect). Capture screenshot of psql output. (2) Cancel that booking via the cancel-booking UI. Verify both rows flip to `status='cancelled'` AND a new `recovery_checkin` row appears scheduled for now()+7d. (3) Create another confirmed booking. Mark it `completed` via the worker dashboard. Verify reminders cancelled AND a `review_request` row at now()+2h. (4) Manually invoke `SELECT public.enqueue_rebook_nudges();` against staging. Then invoke it again 5 minutes later. Verify the second call returns 0 (idempotency). (5) Open `BookingDetailScreen` as the shop owner of a real client booking. Type a note, hit Save, verify success Snackbar. Open the same booking again on a fresh app launch — note persists. Open a DIFFERENT future booking by the same client — note also persists (cross-booking persistence per SPEC success criterion 7). (6) Sign in as a different shop owner. Force-navigate to the booking-detail URL of the FIRST shop's booking. Verify the sticky-note card shows empty / access-denied state (RLS holds). Capture screenshots throughout.
- Acceptance: All 6 steps observed. Steps 1–3 confirm trigger + RPC wiring. Step 4 confirms idempotency. Step 5 confirms cross-booking persistence. Step 6 confirms RLS isolation. Screenshots attached to PR.
- Estimate: 40

## Verification per task

| Task | Observable acceptance |
|------|-----------------------|
| 0.1 | `SELECT unnest(enum_range(NULL::notification_type))` includes the three new values. |
| 0.2 | `\d public.client_notes` shows CHECK constraints + UNIQUE index + 3 RLS policies. Smoke §D passes. |
| 0.3 | `SELECT * FROM shop_rebook_cadence LIMIT 5` returns rows. Shop with 0 completed bookings returns `median_gap_days=30`. Cron job exists. |
| 1.1 | Smoke §E–§H print `OK:`. |
| 1.2 | Smoke §J (channel branching) prints `OK:` — registered booking → push row, guest booking → WhatsApp row with template + params. |
| 1.3 | Helper function exists; covered indirectly by Smoke §B, §C in Task 1.5. |
| 1.4 | Smoke §A prints `OK:` — confirmed booking 26h out → exactly 2 rows. |
| 1.5 | Smoke §B + §C print `OK:`. `grep -v '^--' supabase/migrations/20260605130700_wire_terminal_rpcs.sql | grep -c 'cancel_and_followup'` ≥ 3. |
| 2.1 | Re-running the backfill leaves the row count unchanged. `SELECT COUNT(*) FROM scheduled_notifications WHERE notification_type='booking_reminder_24h' AND status='pending'` ≥ baseline. |
| 2.2 | `grep -n 'booking_reminder_24h\|booking_reminder_2h\|booking_reminder_1h\|booking_reminder_5min' supabase/functions/paystack-webhook/index.ts | grep -v '^//'` returns 0. `booking_confirmation` still present. |
| 2.3 | Same grep on stripe-webhook and verify-payment returns 0. `booking_confirmation` still present. |
| 3.1 | Smoke §I prints `OK:` — second same-day call returns 0. `EXPLAIN ANALYZE` < 30s. |
| 4.1 | `dart analyze` clean on the DTO file. |
| 4.2 | `dart analyze` clean. Task 5.1 passes. |
| 4.3 | `grep -n 'e\.toString()\.contains' lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart` returns 0. Task 5.2 passes. |
| 4.4 | `flutter analyze` clean. |
| 4.5 | Widget renders. `grep -n 'debounce\|Timer.periodic\|onChanged.*upsert' lib/.../client_sticky_note_card.dart` returns 0. Task 5.3 passes. |
| 4.6 | `grep -n 'ClientStickyNoteCard' lib/.../booking_detail_screen.dart` returns 1. Card appears under `isShopOwner`. |
| 5.1 | Test file green. |
| 5.2 | Test file green; 7 cases pass. |
| 5.3 | Test file green; 7 cases pass. Save disabled / enabled assertions are property-level, not visual. |
| 5.4 | `psql -f` prints `OK:` for §A–§J. |
| 6.1 | Templates submitted; Meta IDs in PR. |
| 6.2 | Six UAT steps observed; screenshots in PR. |

## Risk register

| ID | Risk | Severity | Mitigation in this plan |
|----|------|----------|--------------------------|
| R1 | **Reminder ownership double-fire**. If the webhook diffs (Tasks 2.2 + 2.3) ship BEFORE the trigger (Task 1.4), existing in-flight confirmed bookings lose their reminders. If they ship AFTER, registered users briefly receive duplicate reminders (5 total: 24h+1h+5min from webhook + 24h+2h from trigger). | P0 | Strict deploy order: SQL migrations first (Waves 0–3 → trigger live), then backfill (Task 2.1 catches any gap), then webhook diffs (Tasks 2.2–2.3) in the SAME release window. §Rollout step 3 documents this. The backfill is idempotent — safe to re-run if any window opens. |
| R2 | **WhatsApp template approval lag** delays guest delivery for the three new categories. | P1 | Submit templates BEFORE migrations merge (Task 6.1). Worker's existing 6-hour `WhatsAppTemplateNotFoundError` retry (process-scheduled-notifications/index.ts:124-128) auto-defers pending rows for up to 24h cumulatively — Meta's typical approval window is ≤ 6h. No flag, no skip logic. |
| R3 | **Sticky-note RLS leak** would surface another shop owner's private notes. | P0 (mitigated) | Four-policy RLS (SELECT / INSERT / UPDATE only; no DELETE) per RESEARCH §6. Smoke §D explicitly asserts a different uid sees zero rows on SELECT for another shop's note. Defence in depth: the RPC also re-checks `shops.user_id = auth.uid()` before doing anything. |
| R4 | **`enqueue_rebook_nudges` doubles up on cron retry / manual re-run**. Cron job overlap or operator-triggered backfill would otherwise insert duplicate rows. | P0 (mitigated) | Partial unique index `scheduled_notifications_rebook_idem` keyed on `(shop_id, COALESCE(user_id, guest_profile_id), notification_type, (scheduled_for::date))` blocks same-day dupes. Defence in depth: 30-day cooldown EXISTS clause inside the function. Smoke §I asserts. |
| R5 | **Trigger writes break on legacy bookings missing `guest_phone` or `guest_name`**. | M | `enqueue_booking_reminder` uses `COALESCE(booking.field, guest_profiles.field, 'there')`. Even when both are NULL, the helper still inserts (with `phone=NULL`); the worker dispatcher logs a warning on null-phone and skips delivery. Documented as Phase 12 acceptable degradation — these are pre-existing data-quality issues, not Phase 12 regressions. |
| R6 | **`shop_rebook_cadence` refresh exceeds 30s** at scale, blocking other work during the maintenance window. | M | RESEARCH §8 lines 268–273 estimates < 30s for 2M completed-booking rows. If exceeded, fallback is `SET LOCAL work_mem = '64MB'` inside the refresh transaction. Post-deploy: `EXPLAIN ANALYZE REFRESH MATERIALIZED VIEW CONCURRENTLY shop_rebook_cadence` once on prod and document timing in PR. If > 30s, ship a follow-up that drops `MATERIALIZED` and uses a snapshot table. |
| R7 | **Race between trigger and webhook update** — paystack-webhook's status UPDATE to `confirmed` fires the trigger; the trigger reads `NEW.start_time`, which is correct because the same UPDATE statement set the row. No race. | L | Verified semantics: AFTER UPDATE OF status sees the new row. No mitigation needed; documented for forensic. |
| R8 | **`cancel_and_followup` swallows unique_violation** on the partial cooldown index, but should NOT swallow other errors. | L | The exception block is narrowly scoped to `WHEN unique_violation` only. Other errors propagate up — the caller RPC's transaction rolls back. Documented in COMMENT ON FUNCTION. |
| R9 | **Stale `_initialBody` baseline in `ClientStickyNoteCard`** after save success would mis-disable the Save button. | L (mitigated) | Task 4.5 explicitly updates `_initialBody = _controller.text` AFTER the RPC succeeds and BEFORE the next `setState`. Task 5.3 (e) pins this behavior. |
| R10 | **Backfill (Task 2.1) inserts a reminder for a booking that was JUST cancelled by a concurrent transaction**. | L | The backfill filters on `status='confirmed'` — if a concurrent tx flips to `cancelled` between the SELECT and the INSERT, the cancel RPC's own `cancel_and_followup` call will catch the inserted row at the next call. Worst case: one orphan `pending` row stays around for ≤ 24h before its `scheduled_for` passes and the worker skips it as stale. Acceptable. |

## Rollout

**Strict order. Webhook diffs (Tasks 2.2–2.3) MUST land AFTER the trigger + backfill (Tasks 1.4 + 2.1).**

1. **Submit WhatsApp templates to Meta** (Task 6.1) at least 12 hours before SQL migrations land. Templates can sit in `SUBMITTED` indefinitely without affecting production.
2. **Push SQL migrations in strict timestamp order** to staging:
   - `20260605130000_add_phase12_notification_types.sql` (Task 0.1)
   - `20260605130100_client_notes_table.sql` (Task 0.2)
   - `20260605130200_upsert_client_note_rpc.sql` (Task 1.1)
   - `20260605130300_shop_rebook_cadence_view.sql` (Task 0.3)
   - `20260605130400_enqueue_booking_reminder_helper.sql` (Task 1.2)
   - `20260605130500_cancel_and_followup_helper.sql` (Task 1.3)
   - `20260605130600_booking_lifecycle_triggers.sql` (Task 1.4)
   - `20260605130700_wire_terminal_rpcs.sql` (Task 1.5)
   - `20260605130800_consolidate_reminder_scheduling_backfill.sql` (Task 2.1)
   - `20260605130900_enqueue_rebook_nudges_rpc.sql` (Task 3.1)
   Verify with smoke §A–§J against staging. Only after every `OK:` fires do we push to prod.
3. **Ship the three webhook diffs** (Tasks 2.2 + 2.3): `supabase functions deploy paystack-webhook stripe-webhook verify-payment`. After deploy, smoke-check by paying for a new test booking and watching `scheduled_notifications` — exactly 2 reminders should appear (from the trigger), zero from the webhook.
4. **Ship the Dart code** as one commit. The widget changes are additive: the new card only renders under `isShopOwner`; pre-Phase-12 builds simply don't show it.
5. **24-hour log watch**: any `AppLogger.warn` event whose `event` starts with `client_note.fetch_failed` or `client_note.save_failed`. A spike indicates an unmapped `PostgrestException` code that escaped Task 4.3. Cross-check against the worker's `WhatsAppTemplateNotFoundError` defer count — if > 100 deferrals/hour, Meta still has the templates in review; not a Phase 12 bug.
6. **Cron verification 24h after deploy**: `SELECT * FROM cron.job_run_details WHERE jobname IN ('refresh-shop-rebook-cadence', 'enqueue-rebook-nudges') ORDER BY start_time DESC LIMIT 5`. Both jobs should have at least one successful run.
7. **PR description** must explicitly call out: (a) reminder ownership consolidation — Phase 12 makes the trigger the SINGLE source of `booking_reminder_24h` + `booking_reminder_2h`; (b) the `booking_reminder_1h` + `booking_reminder_5min` categories silently sunset (no migration to backfill the inverse — new bookings use 24h+2h only); (c) `client_for_booking` view was DROPPED from scope; (d) sticky notes use explicit Save button — no debounce auto-save; (e) `notification_settings.{rebook_nudge,review_request,recovery_checkin}_enabled` columns are not yet consulted by the worker (carry-over gap, not a Phase 12 regression).

### Rollback (Tier 2)

1. **Revert the Dart commit** — sticky-note card disappears. No data loss; existing notes stay in the DB and reappear when the commit is re-landed.
2. **Revert the three webhook diffs** by redeploying the previous edge function versions: `supabase functions deploy paystack-webhook stripe-webhook verify-payment --version <prev-sha>`. The webhook reminder writers come back; the trigger is still live (because we don't roll back the SQL — see step 3); registered users briefly get duplicate reminders. Acceptable for an emergency rollback.
3. **Roll back the SQL**: ship a follow-up migration that drops the trigger first (`DROP TRIGGER trg_bookings_schedule_reminders ON public.bookings`), then re-runs the original bodies of `cancel_booking`, `mark_booking_complete`, `mark_booking_no_show` from `20260517020000_booking_hardening.sql`. **Do NOT drop the new helpers** (`cancel_and_followup`, `enqueue_booking_reminder`) — any rows already enqueued mid-rollout still depend on the helper for forensic reads. **Do NOT drop the `client_notes` table** — written notes would be lost. Leave the table; the Dart commit revert hides it from the UI.
4. **Unschedule cron jobs**: `SELECT cron.unschedule('refresh-shop-rebook-cadence'); SELECT cron.unschedule('enqueue-rebook-nudges')`.

## Plan-check criteria

This plan is internally consistent when every item below holds. Reviewer asserts each manually before approval.

- [ ] Every `<task>` ≤ 3 file paths; bigger fans (Tasks 1.5, 4.3, 4.5) are explicitly justified inline.
- [ ] Every `<task>` has an `Acceptance` line that is observable without reading the diff (grep / psql / flutter test / manual screenshot).
- [ ] Every `<task>` has a `Rollback` line OR the §Rollout §Rollback section covers it (Wave 4–5 tasks fall under the Dart revert in step 1 of Rollback; Wave 6 tasks have inline rollback notes).
- [ ] Every new RPC follows the Phase 11 hardening template (authz FIRST, HINT codes, REVOKE/GRANT, COMMENT). Verified for `upsert_client_note`, `enqueue_booking_reminder`, `cancel_and_followup`, `enqueue_rebook_nudges`, plus the three modified terminal RPCs in Task 1.5.
- [ ] Every client-side error path uses typed exceptions with HINT-based dispatch. NO `e.toString().contains(...)`. Grep gate in §Definition of done asserts.
- [ ] `client_for_booking` view does NOT appear anywhere in the plan. (Search the plan: 0 matches in task actions.)
- [ ] Sticky-note widget has explicit Save button with NO debounce / auto-save. Grep gate in §Definition of done asserts `0` matches for `debounce|Timer.periodic|onChanged.*upsert` in the widget file.
- [ ] The trigger is the SINGLE source of `booking_reminder_24h` + `booking_reminder_2h`. Webhook diffs delete those inserts. No new code path writes them outside the trigger / backfill.
- [ ] Reminder backfill is idempotent — re-running leaves row count unchanged. Asserted by Task 2.1 acceptance.
- [ ] `enqueue_rebook_nudges` idempotency uses partial unique index + 30-day EXISTS. Smoke §I asserts.
- [ ] Smoke SQL covers the four proof obligations from the planner brief: (a) trigger schedules 2 rows for a 26h-out confirmed booking — §A; (b) status flip cancels reminders + adds followup — §B + §C; (c) `enqueue_rebook_nudges` idempotent on same-day re-run — §I; (d) sticky-note RLS denies another shop's owner — §D.
- [ ] No defensive `notification_type` discovery DO block (live DB confirmed enum 2026-06-05). Migration 1 uses bare `ALTER TYPE ... ADD VALUE IF NOT EXISTS`.
- [ ] No `process-scheduled-notifications` edge-function diff (worker already branches on `delivery_channel`).
- [ ] The plan does NOT propose discount codes in `recovery_checkin` copy (Phase 13 dependency removed).
- [ ] WhatsApp template submission is in the plan (Task 6.1) but does NOT block PR merge; the worker's 6-hour retry covers the approval window.

## Definition of done

- [ ] `flutter analyze` clean on every touched Dart file (NEW + EDIT).
- [ ] All new Dart tests (Tasks 5.1–5.3) pass locally and in CI.
- [ ] `supabase db reset && supabase db push` applies the ten new migrations cleanly to a fresh DB.
- [ ] Smoke-test SQL script (Task 5.4) prints `OK:` for all of §A–§J against staging.
- [ ] UAT (Task 6.2) all 6 steps observed; screenshots in PR.
- [ ] Meta WhatsApp templates submitted (Task 6.1); template IDs documented in PR.
- [ ] Grep gates (CI step or `make verify` target — exact commands):
  - [ ] `grep -rn 'booking_reminder_24h\|booking_reminder_2h\|booking_reminder_1h\|booking_reminder_5min' supabase/functions/paystack-webhook/index.ts | grep -v '^//'` returns `0`.
  - [ ] `grep -rn 'booking_reminder' supabase/functions/stripe-webhook/index.ts | grep -v '^//'` returns `0`.
  - [ ] `grep -rn 'booking_reminder' supabase/functions/verify-payment/index.ts | grep -v '^//'` returns `0`.
  - [ ] `grep -rn 'booking_confirmation' supabase/functions/paystack-webhook/index.ts` returns at least `1` (kept intentionally).
  - [ ] `grep -rn 'client_for_booking' supabase/migrations/ lib/` returns `0` (view explicitly dropped from scope).
  - [ ] `grep -rn 'debounce\|Timer.periodic' lib/presentation/features/shops/dashboard/presentation/widgets/client_sticky_note_card.dart` returns `0`.
  - [ ] `grep -rn 'e\.toString()\.contains' lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart` returns `0`.
  - [ ] `grep -v '^--' supabase/migrations/20260605130700_wire_terminal_rpcs.sql | grep -c 'cancel_and_followup'` returns at least `3`.
  - [ ] **RPC-body drift gate**: the three terminal RPC bodies in `20260605130700_wire_terminal_rpcs.sql` are byte-for-byte the original `20260517020000_booking_hardening.sql` bodies plus EXACTLY one `PERFORM public.cancel_and_followup(...)` line each. Verify by extracting each function body, stripping the new `PERFORM` line, and `diff`-ing against the original source. Mechanical check: `for fn in cancel_booking mark_booking_complete mark_booking_no_show; do diff <(awk "/CREATE OR REPLACE FUNCTION public.$fn/,/^\\\$function\\\$;/" supabase/migrations/20260605130700_wire_terminal_rpcs.sql | grep -v 'cancel_and_followup') <(awk "/CREATE OR REPLACE FUNCTION public.$fn/,/^\\\$function\\\$;/" supabase/migrations/20260517020000_booking_hardening.sql); done` must produce ONLY the expected `+`/`-` lines for the `Phase 12:` COMMENT and no other changes.
  - [ ] `grep -n 'ClientStickyNoteCard' lib/presentation/features/shops/booking/presentation/screens/shared/booking_detail_screen.dart` returns at least `1`.
- [ ] Cron jobs verified live in `cron.job` 24h after deploy.
- [ ] PR description flags the reminder-ownership consolidation as the highest-risk delta and documents the rollback plan (per §Rollout step 7).
- [ ] PR description lists the carry-over gaps in §Out of scope (`notification_settings` category-level booleans dormant; `booking_reminder_1h` / `booking_reminder_5min` sunset).

**Estimated total effort:** 950 minutes ≈ 15.8 hours. Lands above a typical phase target. The bump is documented and load-bearing: ten SQL migrations (vs. the 5-7 typical for prior phases), three webhook diffs in three separate files, a brand-new materialized-view + nightly cron, and a per-client widget surface with full typed-exception + widget-test coverage.

## PLAN COMPLETE
