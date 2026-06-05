-- Phase 12 — manual SQL smoke tests.
--
-- Hand-runnable against a staging branch DB. pgTAP is intentionally
-- deferred to a future testing-foundation phase. Replace the
-- placeholders at the top with real values before running.
--
-- Wrapped in BEGIN/ROLLBACK with SAVEPOINTs per section so every test
-- rolls back automatically. Each section ends with
-- `RAISE NOTICE 'OK: <case>';` on success -- anywhere a different
-- result appears, the test failed.
--
-- Coverage maps to the four planner-brief proof obligations:
--   (a) Trigger schedules exactly 2 rows for a confirmed booking 26h out -- §A
--   (b) Status flip cancels reminders + adds followup                  -- §B, §C
--   (c) enqueue_rebook_nudges is idempotent on same-day re-run         -- §I
--   (d) Sticky-note RLS denies another shop's owner                    -- §D

BEGIN;

-- ─── placeholders ──────────────────────────────────────────────────
\set owner_uid     '''00000000-0000-0000-0000-000000000001'''
\set other_uid     '''00000000-0000-0000-0000-000000000002'''
\set shop_a        '''00000000-0000-0000-0000-000000000010'''
\set shop_b        '''00000000-0000-0000-0000-000000000011'''
\set booking_reg   '''00000000-0000-0000-0000-000000000020'''
\set booking_guest '''00000000-0000-0000-0000-000000000021'''
\set test_user     '''00000000-0000-0000-0000-000000000030'''
\set test_guest    '''00000000-0000-0000-0000-000000000040'''

-- ─── A. Trigger schedules exactly 2 rows for confirmed booking 26h out ─
-- Proof obligation (a). Insert a confirmed booking with start_time
-- 26h in the future; expect exactly 2 pending scheduled_notifications
-- rows (one booking_reminder_24h at start-24h, one booking_reminder_2h
-- at start-2h).
SAVEPOINT a_trigger_insert;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';

INSERT INTO public.bookings (
  id, shop_id, user_id, status, start_time, end_time, total_price
) VALUES (
  '00000000-0000-0000-0000-000000000020'::uuid,
  '00000000-0000-0000-0000-000000000010'::uuid,
  '00000000-0000-0000-0000-000000000030'::uuid,
  'confirmed',
  now() + interval '26 hours',
  now() + interval '27 hours',
  100
);

SELECT
  CASE WHEN COUNT(*) = 2
        AND BOOL_AND(status = 'pending')
        AND BOOL_OR(notification_type = 'booking_reminder_24h')
        AND BOOL_OR(notification_type = 'booking_reminder_2h')
       THEN 'OK: trigger inserts 2 reminder rows for 26h-out confirmed booking'
       ELSE 'FAIL: expected 2 pending reminder rows, got ' || COUNT(*)::text
  END
FROM public.scheduled_notifications
WHERE booking_id = '00000000-0000-0000-0000-000000000020'
  AND notification_type IN ('booking_reminder_24h', 'booking_reminder_2h');

ROLLBACK TO SAVEPOINT a_trigger_insert;

-- ─── B. Status flip to cancelled: cancels reminders + adds recovery_checkin ─
-- Proof obligation (b) part 1. Insert confirmed booking → 2 reminders.
-- Cancel via cancel_booking RPC → both reminders flip to 'cancelled'
-- AND a new recovery_checkin row appears scheduled for now()+7d.
SAVEPOINT b_cancel_flow;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';

INSERT INTO public.bookings (
  id, shop_id, user_id, status, start_time, end_time, total_price
) VALUES (
  '00000000-0000-0000-0000-000000000020'::uuid,
  '00000000-0000-0000-0000-000000000010'::uuid,
  '00000000-0000-0000-0000-000000000030'::uuid,
  'confirmed',
  now() + interval '26 hours',
  now() + interval '27 hours',
  100
);

-- Capture reminder ids BEFORE cancel.
SELECT id, notification_type
INTO TEMP TABLE _b_reminders_before
FROM public.scheduled_notifications
WHERE booking_id = '00000000-0000-0000-0000-000000000020'
  AND notification_type IN ('booking_reminder_24h', 'booking_reminder_2h');

-- Cancel the booking. Wires through cancel_and_followup.
SELECT public.cancel_booking(
  '00000000-0000-0000-0000-000000000020'::uuid
);

-- Assertion 1: both pre-existing reminder rows are now 'cancelled'.
SELECT
  CASE WHEN BOOL_AND(status = 'cancelled')
       THEN 'OK: cancel_booking flips reminders to cancelled'
       ELSE 'FAIL: reminders not cancelled: ' ||
            string_agg(status, ',')
  END
FROM public.scheduled_notifications s
JOIN _b_reminders_before b ON b.id = s.id;

-- Assertion 2: exactly one recovery_checkin row inserted at ~now()+7d.
SELECT
  CASE WHEN COUNT(*) = 1
        AND BOOL_AND(status = 'pending')
        AND BOOL_AND(scheduled_for BETWEEN now() + interval '6 days 23 hours'
                                       AND now() + interval '7 days 1 hour')
       THEN 'OK: cancel_booking schedules recovery_checkin at now()+7d'
       ELSE 'FAIL: recovery_checkin row missing or mistimed'
  END
FROM public.scheduled_notifications
WHERE booking_id = '00000000-0000-0000-0000-000000000020'
  AND notification_type = 'recovery_checkin';

DROP TABLE _b_reminders_before;
ROLLBACK TO SAVEPOINT b_cancel_flow;

-- ─── C. Status flip to completed: cancels reminders + adds review_request ─
-- Proof obligation (b) part 2.
SAVEPOINT c_complete_flow;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';

INSERT INTO public.bookings (
  id, shop_id, user_id, status, start_time, end_time, total_price
) VALUES (
  '00000000-0000-0000-0000-000000000020'::uuid,
  '00000000-0000-0000-0000-000000000010'::uuid,
  '00000000-0000-0000-0000-000000000030'::uuid,
  'confirmed',
  now() + interval '26 hours',
  now() + interval '27 hours',
  100
);

SELECT id INTO TEMP TABLE _c_reminders_before
FROM public.scheduled_notifications
WHERE booking_id = '00000000-0000-0000-0000-000000000020'
  AND notification_type IN ('booking_reminder_24h', 'booking_reminder_2h');

SELECT public.mark_booking_complete(
  '00000000-0000-0000-0000-000000000020'::uuid
);

-- Assertion 1: reminders cancelled.
SELECT
  CASE WHEN BOOL_AND(status = 'cancelled')
       THEN 'OK: mark_booking_complete flips reminders to cancelled'
       ELSE 'FAIL: reminders not cancelled'
  END
FROM public.scheduled_notifications s
JOIN _c_reminders_before b ON b.id = s.id;

-- Assertion 2: one review_request row at ~now()+2h.
SELECT
  CASE WHEN COUNT(*) = 1
        AND BOOL_AND(status = 'pending')
        AND BOOL_AND(scheduled_for BETWEEN now() + interval '1 hour 59 minutes'
                                       AND now() + interval '2 hours 1 minute')
       THEN 'OK: mark_booking_complete schedules review_request at now()+2h'
       ELSE 'FAIL: review_request row missing or mistimed'
  END
FROM public.scheduled_notifications
WHERE booking_id = '00000000-0000-0000-0000-000000000020'
  AND notification_type = 'review_request';

DROP TABLE _c_reminders_before;
ROLLBACK TO SAVEPOINT c_complete_flow;

-- ─── D. Sticky-note RLS denies another shop's owner ─────────────────
-- Proof obligation (d). owner_uid owns shop_a; insert a note. Then
-- switch to other_uid and SELECT -- should return zero rows under RLS.
SAVEPOINT d_rls;

-- Setup as owner_uid: insert a note via the RPC.
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
SELECT public.upsert_client_note(
  '00000000-0000-0000-0000-000000000010'::uuid,  -- shop_a (owned by owner_uid)
  '00000000-0000-0000-0000-000000000030'::uuid,  -- test_user
  NULL,
  'Prefers no fringe.'
);

-- Confirm owner can SELECT.
SELECT
  CASE WHEN COUNT(*) = 1
       THEN 'OK: client_notes RLS allows owner SELECT'
       ELSE 'FAIL: owner cannot see their own note'
  END
FROM public.client_notes
WHERE shop_id = '00000000-0000-0000-0000-000000000010';

-- Switch to other_uid -- they own shop_b, not shop_a.
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000002"}';

-- Assertion: SELECT returns 0 rows for shop_a's note.
SELECT
  CASE WHEN COUNT(*) = 0
       THEN 'OK: client_notes RLS denies another shop owner SELECT'
       ELSE 'FAIL: RLS leak -- other owner saw ' || COUNT(*)::text || ' rows'
  END
FROM public.client_notes
WHERE shop_id = '00000000-0000-0000-0000-000000000010';

-- Assertion: upsert_client_note also raises 42501 for non-owner.
DO $$ BEGIN
  BEGIN
    PERFORM public.upsert_client_note(
      '00000000-0000-0000-0000-000000000010'::uuid,
      '00000000-0000-0000-0000-000000000030'::uuid,
      NULL,
      'Trying to overwrite from another account.'
    );
    RAISE EXCEPTION 'FAIL: non-owner should have raised 42501';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'OK: upsert_client_note denies non-owner with 42501';
  END;
END $$;

ROLLBACK TO SAVEPOINT d_rls;

-- ─── E. upsert_client_note: authz (non-owner) ───────────────────────
SAVEPOINT e_upsert_authz;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000002"}';
DO $$ BEGIN
  BEGIN
    PERFORM public.upsert_client_note(
      '00000000-0000-0000-0000-000000000010'::uuid,
      '00000000-0000-0000-0000-000000000030'::uuid,
      NULL,
      'hello'
    );
    RAISE EXCEPTION 'FAIL: non-owner should have raised 42501';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'OK: upsert_client_note authz';
  END;
END $$;
ROLLBACK TO SAVEPOINT e_upsert_authz;

-- ─── F. upsert_client_note: both identities NOT NULL ────────────────
SAVEPOINT f_upsert_both_ids;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
DO $$ BEGIN
  BEGIN
    PERFORM public.upsert_client_note(
      '00000000-0000-0000-0000-000000000010'::uuid,
      '00000000-0000-0000-0000-000000000030'::uuid,
      '00000000-0000-0000-0000-000000000040'::uuid,  -- both provided -- illegal
      'hello'
    );
    RAISE EXCEPTION 'FAIL: dual identity should have raised';
  EXCEPTION WHEN data_exception THEN
    RAISE NOTICE 'OK: upsert_client_note rejects dual identity (EXACTLY_ONE_OF_USER_OR_GUEST)';
  END;
END $$;
ROLLBACK TO SAVEPOINT f_upsert_both_ids;

-- ─── G. upsert_client_note: body > 2000 chars ───────────────────────
SAVEPOINT g_upsert_too_long;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';
DO $$ BEGIN
  BEGIN
    PERFORM public.upsert_client_note(
      '00000000-0000-0000-0000-000000000010'::uuid,
      '00000000-0000-0000-0000-000000000030'::uuid,
      NULL,
      repeat('x', 2001)
    );
    RAISE EXCEPTION 'FAIL: 2001-char body should have raised';
  EXCEPTION WHEN data_exception THEN
    RAISE NOTICE 'OK: upsert_client_note rejects body > 2000 (NOTE_TOO_LONG)';
  END;
END $$;
ROLLBACK TO SAVEPOINT g_upsert_too_long;

-- ─── H. upsert_client_note: happy path + idempotent upsert ──────────
SAVEPOINT h_upsert_happy;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';

SELECT public.upsert_client_note(
  '00000000-0000-0000-0000-000000000010'::uuid,
  '00000000-0000-0000-0000-000000000030'::uuid,
  NULL,
  'Prefers no fringe.'
) AS id_first
INTO TEMP TABLE _h_first;

SELECT public.upsert_client_note(
  '00000000-0000-0000-0000-000000000010'::uuid,
  '00000000-0000-0000-0000-000000000030'::uuid,
  NULL,
  'Updated -- prefers no fringe, allergic to peroxide.'
) AS id_second
INTO TEMP TABLE _h_second;

SELECT
  CASE WHEN (SELECT id_first FROM _h_first) = (SELECT id_second FROM _h_second)
        AND EXISTS (
              SELECT 1 FROM public.client_notes
              WHERE id = (SELECT id_first FROM _h_first)
                AND body = 'Updated -- prefers no fringe, allergic to peroxide.'
            )
       THEN 'OK: upsert_client_note happy + idempotent (same id, body updated)'
       ELSE 'FAIL: id changed or body not updated'
  END;

DROP TABLE _h_first;
DROP TABLE _h_second;
ROLLBACK TO SAVEPOINT h_upsert_happy;

-- ─── I. enqueue_rebook_nudges: idempotent on same-day re-run ────────
-- Proof obligation (c). Seed a completed booking N=30 days ago for a
-- shop with default 30d cadence (no completed-booking samples means
-- shop_rebook_cadence yields 30). Call enqueue_rebook_nudges() twice.
-- First call → 1 inserted; second call → 0 inserted (partial unique
-- index on (shop_id, COALESCE(user_id, guest_profile_id),
-- notification_type, scheduled_for::date) blocks the dupe).
SAVEPOINT i_rebook_idem;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';

INSERT INTO public.bookings (
  id, shop_id, user_id, status, start_time, end_time, total_price
) VALUES (
  '00000000-0000-0000-0000-000000000022'::uuid,
  '00000000-0000-0000-0000-000000000010'::uuid,
  '00000000-0000-0000-0000-000000000030'::uuid,
  'completed',
  now() - interval '30 days',
  now() - interval '30 days' + interval '1 hour',
  100
);

-- Refresh the materialized view so the new completed booking is
-- visible to enqueue_rebook_nudges (the function reads from the view).
REFRESH MATERIALIZED VIEW public.shop_rebook_cadence;

-- First call -- expect 1 inserted.
SELECT
  CASE WHEN public.enqueue_rebook_nudges() = 1
       THEN 'OK: enqueue_rebook_nudges first call inserts 1 row'
       ELSE 'FAIL: first call did not insert exactly 1 row'
  END;

-- Second call same day -- expect 0 inserted (idempotency).
SELECT
  CASE WHEN public.enqueue_rebook_nudges() = 0
       THEN 'OK: enqueue_rebook_nudges second same-day call inserts 0 rows (idempotent)'
       ELSE 'FAIL: second call inserted rows -- idempotency broken'
  END;

-- Confirm exactly one rebook_nudge row exists for this (shop, client).
SELECT
  CASE WHEN COUNT(*) = 1
       THEN 'OK: rebook_nudge row count is 1 after two same-day calls'
       ELSE 'FAIL: expected 1 rebook_nudge row, got ' || COUNT(*)::text
  END
FROM public.scheduled_notifications
WHERE shop_id = '00000000-0000-0000-0000-000000000010'
  AND user_id = '00000000-0000-0000-0000-000000000030'
  AND notification_type = 'rebook_nudge'
  AND status IN ('pending', 'processing');

ROLLBACK TO SAVEPOINT i_rebook_idem;

-- ─── J. enqueue_booking_reminder: channel branching ─────────────────
-- Registered booking → push row (delivery_channel='push',
-- whatsapp_template IS NULL, metadata.title + body present).
-- Guest booking → WhatsApp row (delivery_channel='whatsapp',
-- whatsapp_template='booking_reminder_24h_v1', whatsapp_params has
-- '1' and '2', metadata.phone present).
SAVEPOINT j_channel_branching;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000001"}';

-- Registered booking.
INSERT INTO public.bookings (
  id, shop_id, user_id, status, start_time, end_time, total_price
) VALUES (
  '00000000-0000-0000-0000-000000000020'::uuid,
  '00000000-0000-0000-0000-000000000010'::uuid,
  '00000000-0000-0000-0000-000000000030'::uuid,
  'pending',  -- avoid trigger; we'll call the helper directly
  now() + interval '26 hours',
  now() + interval '27 hours',
  100
);

SELECT public.enqueue_booking_reminder(
  '00000000-0000-0000-0000-000000000020'::uuid,
  'booking_reminder_24h',
  now() + interval '2 hours'
);

SELECT
  CASE WHEN delivery_channel = 'push'
        AND whatsapp_template IS NULL
        AND metadata ? 'title'
        AND metadata ? 'body'
       THEN 'OK: enqueue_booking_reminder registered → push row shape'
       ELSE 'FAIL: registered row shape wrong (channel=' || delivery_channel ||
            ', template=' || COALESCE(whatsapp_template, 'NULL') || ')'
  END
FROM public.scheduled_notifications
WHERE booking_id = '00000000-0000-0000-0000-000000000020'
  AND notification_type = 'booking_reminder_24h';

-- Guest booking.
INSERT INTO public.guest_profiles (id, phone, name, locale)
VALUES (
  '00000000-0000-0000-0000-000000000040'::uuid,
  '+233000000000',
  'Test Guest',
  'en'
)
ON CONFLICT DO NOTHING;

INSERT INTO public.bookings (
  id, shop_id, user_id, guest_profile_id, guest_phone, guest_name,
  status, start_time, end_time, total_price
) VALUES (
  '00000000-0000-0000-0000-000000000021'::uuid,
  '00000000-0000-0000-0000-000000000010'::uuid,
  NULL,
  '00000000-0000-0000-0000-000000000040'::uuid,
  '+233000000000',
  'Test Guest',
  'pending',
  now() + interval '26 hours',
  now() + interval '27 hours',
  100
);

SELECT public.enqueue_booking_reminder(
  '00000000-0000-0000-0000-000000000021'::uuid,
  'booking_reminder_24h',
  now() + interval '2 hours'
);

SELECT
  CASE WHEN delivery_channel = 'whatsapp'
        AND whatsapp_template = 'booking_reminder_24h_v1'
        AND whatsapp_params ? '1'
        AND whatsapp_params ? '2'
        AND metadata ? 'phone'
        AND metadata->>'phone' = '+233000000000'
       THEN 'OK: enqueue_booking_reminder guest → WhatsApp row shape'
       ELSE 'FAIL: guest row shape wrong (channel=' || delivery_channel ||
            ', template=' || COALESCE(whatsapp_template, 'NULL') ||
            ', phone=' || COALESCE(metadata->>'phone', 'NULL') || ')'
  END
FROM public.scheduled_notifications
WHERE booking_id = '00000000-0000-0000-0000-000000000021'
  AND notification_type = 'booking_reminder_24h';

ROLLBACK TO SAVEPOINT j_channel_branching;

ROLLBACK;

-- End of script. Every section above is expected to print exactly one
-- `OK:` line (some sections print 2-3). Any `FAIL:` line is a test
-- failure -- investigate before merging the corresponding migration.
