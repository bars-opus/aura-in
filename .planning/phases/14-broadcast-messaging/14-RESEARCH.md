# Phase 14 Research — Owner Broadcast Messaging

## Summary

Seven hard corrections + clarifications the planner MUST absorb before writing tasks. The first three rewrite assumptions baked into the SPEC.

1. **`shops.timezone` does NOT exist in this codebase.** SPEC line 167 cites it as "exists (Phase 11 RESEARCH §1)". Grep across all migrations: zero hits for any `timezone` column on `shops`. Verified by `grep -rn "ALTER TABLE shops\|CREATE TABLE.*shops\b" supabase/migrations/` — the only ALTER on shops is [20260528120000_link_booking_guest_support.sql:82](../../../supabase/migrations/20260528120000_link_booking_guest_support.sql#L82) adding `booking_slug`. The SPEC's "trade-off: keep UTC vs compute in shop timezone via `at time zone shops.timezone`" is moot — option (b) requires a schema add Phase 14 doesn't include. **UTC day is locked not because we chose simplicity, but because shop-local TZ isn't an available primitive.** Document the edge case (8pm PDT broadcast + 8:01pm PDT crosses UTC midnight → second broadcast accepted) and accept it. See §5.

2. **`enqueue_booking_reminder` is unusable for broadcasts.** The Phase 12 helper signature ([20260605130400:27-31](../../../supabase/migrations/20260605130400_enqueue_booking_reminder_helper.sql#L27-L31)) is `(p_booking_id UUID, p_type notification_type, p_scheduled_for TIMESTAMPTZ)`. It SELECTs `bookings %ROWTYPE` from the booking_id, then derives user_id / guest_profile_id / phone / name / shop_id from that row. Broadcast fan-out has no booking_id. Phase 14 writes scheduled_notifications rows DIRECTLY inside the fan-out CTE — does NOT call enqueue_booking_reminder, does NOT add a new helper. The shape to write is documented in §4. The hard constraint from the prompt ("New send_broadcast doesn't call enqueue_booking_reminder — different shape") is correct.

3. **Worker requires zero code changes for `marketing_broadcast` — verified.** [process-scheduled-notifications/index.ts:255-259](../../../supabase/functions/process-scheduled-notifications/index.ts#L255-L259) branches purely on `delivery_channel === "whatsapp"`. Zero hardcoded notification_type allowlist anywhere in the file. The WhatsApp dispatcher ([index.ts:93-159](../../../supabase/functions/process-scheduled-notifications/index.ts#L93-L159)) reads `metadata.phone`, `whatsapp_template`, `whatsapp_params` directly — does not switch on notification_type. The push path ([index.ts:262-282](../../../supabase/functions/process-scheduled-notifications/index.ts#L262-L282)) reads `metadata.title` + `metadata.body` — also notification-type-agnostic. **SPEC §16 worker-no-change claim is correct.** What IS gated: `isPushEnabled` ([index.ts:55-64](../../../supabase/functions/process-scheduled-notifications/index.ts#L55-L64)) reads `notification_settings.push_enabled`. Owner-side per-category opt-out doesn't exist; registered users opt out at OS level — locked by SPEC.

4. **`bookings.status` enum is exactly 5 values. Cancelled IS the right inclusion for "all clients."** Verified at [20260517010000_booking_schema.sql:113-117](../../../supabase/migrations/20260517010000_booking_schema.sql#L113-L117): CHECK constraint locks status to `('pending','confirmed','cancelled','completed','no_show')`. SPEC locked default ("cancelled counts toward 'all clients'") translates to `WHERE status != 'pending'` (excludes incomplete checkout attempts; includes everyone else). Exact predicate in §1.

5. **`scheduled_notifications` already supports broadcast fan-out without schema changes.** Verified at [20260528120000_link_booking_guest_support.sql:89-95](../../../supabase/migrations/20260528120000_link_booking_guest_support.sql#L89-L95): `user_id` nullable, `guest_profile_id` nullable, `delivery_channel` CHECK in (`push`, `whatsapp`), `whatsapp_template` TEXT, `whatsapp_params` JSONB. The booking_id column is also nullable — no CHECK constraint requires it. Broadcast rows carry `booking_id = NULL` and the worker doesn't read it for non-reminder types. See §3.

6. **Promo re-validation predicate must mirror `validate_and_apply_promo`'s manual-entry branch.** Verified at [20260606000300_validate_and_apply_promo_rpc.sql:96-116](../../../supabase/migrations/20260606000300_validate_and_apply_promo_rpc.sql#L96-L116): the canonical "is this promo usable" check is `shop_id = p_shop_id AND UPPER(code) = UPPER(p_code) AND archived_at IS NULL AND is_active = TRUE AND (valid_from IS NULL OR valid_from <= now()) AND (valid_to IS NULL OR valid_to > now())`. `send_broadcast` re-validates the SPEC-named `promotion_id` with the SAME predicate (minus the code lookup — we have the id). Critical: **also exclude `source IN ('loyalty','recovery')`** — owner cannot attach a silent client-targeted code as a broadcast attachment. SPEC implies but doesn't lock this. Recommend lock; see §6.

7. **Audience size cap discussion: SPEC's "no cap" is risky for the platform's WhatsApp number quality rating.** Meta enforces a per-recipient cap of ~2 marketing messages per day across all senders ([WhatsApp Business marketing rate limits, 2026](https://www.uptail.ai/blog/how-many-messages-can-you-send-on-whatsapp-business-limits-explained-for-2026)) AND a per-Business-Portfolio 24h unique-contact ceiling that starts at 250, climbs to 1k → 10k → 100k → unlimited based on quality rating. A single shop fanning out 10k WhatsApp messages from NanoEmbryo's number burns the platform's tier — affecting every other shop's deliverability. The 1/day per-shop rate limit does not save us when 5 shops each broadcast to 2,000 guests on the same UTC day. **Recommend a per-broadcast cap of 1,000 recipients in v1** (matches the next-up Meta tier), with a hard 250 floor before Business Verification is complete. SPEC locked "no cap" — flag for user decision in Open Questions. See §11.

## Findings

### 1. `bookings.status` enum + "All clients" predicate

Source of truth: [20260517010000_booking_schema.sql:113-117](../../../supabase/migrations/20260517010000_booking_schema.sql#L113-L117):

```sql
ADD CONSTRAINT bookings_status_valid CHECK (
  status IN ('pending','confirmed','cancelled','completed','no_show')
)
```

The "pending" status is the pre-payment hold — a booking that exists in the database but the payment webhook hasn't fired. These bookings disappear within 30 min via `pending_payments_cleanup` ([20260516130000_pending_payments_cleanup.sql](../../../supabase/migrations/20260516130000_pending_payments_cleanup.sql)). Including them in an audience would broadcast to people who abandoned checkout — wrong.

**All four audience predicates, exactly as the send_broadcast / preview_broadcast_audience CTEs should encode:**

```sql
-- Common subquery: every "real" client identity at this shop.
-- The COALESCE-into-text dedup is the same pattern Phase 12 §9 uses for
-- rebook_nudge idempotency. (CITED: 12-RESEARCH.md §9.)
WITH client_identities AS (
  SELECT DISTINCT
    b.user_id,
    b.guest_profile_id,
    COALESCE(b.user_id::text, b.guest_profile_id::text) AS dedup_key,
    MAX(b.start_time) FILTER (
      WHERE b.status <> 'pending'
    ) AS last_booking_at
  FROM public.bookings b
  WHERE b.shop_id = p_shop_id
    AND b.status <> 'pending'
  GROUP BY b.user_id, b.guest_profile_id
)
-- all_clients:
SELECT user_id, guest_profile_id FROM client_identities;

-- recent: last booking within 30 days
SELECT user_id, guest_profile_id FROM client_identities
WHERE last_booking_at >= now() - INTERVAL '30 days';

-- lapsed: last booking 60+ days ago. Note "never cancelled the whole
-- relationship" from the SPEC reduces to "has at least one non-cancelled
-- booking" — already guaranteed by status <> 'pending' if we want loose
-- semantics; if we want strict ("has at least one confirmed/completed"),
-- add a second filter. Recommend strict.
SELECT user_id, guest_profile_id FROM client_identities ci
WHERE last_booking_at < now() - INTERVAL '60 days'
  AND EXISTS (
    SELECT 1 FROM public.bookings b
    WHERE b.shop_id = p_shop_id
      AND b.status IN ('confirmed','completed')
      AND COALESCE(b.user_id::text, b.guest_profile_id::text) = ci.dedup_key
  );

-- by_service: clients who have booked a specific appointment_slots.id.
-- Joins booking_services for the slot filter. Status filter the same.
SELECT DISTINCT b.user_id, b.guest_profile_id
FROM public.bookings b
JOIN public.booking_services bs ON bs.booking_id = b.id
WHERE b.shop_id = p_shop_id
  AND b.status <> 'pending'
  AND bs.slot_id = p_audience_param;
```

**Lapsed strict-vs-loose decision.** The SPEC's definition (line 52-53) is "last booking 60+ days ago, never cancelled the whole relationship (any non-cancelled booking exists)". The CTE above implements strict (must have ≥1 confirmed/completed). Recommend strict — loose semantics could re-engage someone whose only history is a no-show, which is more spam than retention. Document.

### 2. Audience resolution index strategy

Existing indexes on `bookings` ([20260517010000_booking_schema.sql:147-155](../../../supabase/migrations/20260517010000_booking_schema.sql#L147-L155)):

| Index | Definition |
|-------|------------|
| `idx_bookings_user_id` | `(user_id, start_time DESC)` |
| `idx_bookings_shop_id` | `(shop_id, start_time DESC)` |
| `idx_bookings_status` | `(status)` |
| `idx_bookings_booking_date` | `(booking_date)` |
| `idx_bookings_created_at` | `(created_at DESC)` |
| `idx_bookings_shop_date_status` | `(shop_id, booking_date, status)` |
| `bookings_guest_profile_idx` | `(guest_profile_id)` ([20260528120000:73-74](../../../supabase/migrations/20260528120000_link_booking_guest_support.sql#L73-L74)) |

**EXPLAIN reasoning, per audience CTE:**

| CTE | Hot path | Existing index hit | New index needed? |
|-----|----------|-------------------|-------------------|
| `all_clients` | `WHERE shop_id = X AND status <> 'pending' GROUP BY (user_id, guest_profile_id)` | `idx_bookings_shop_id (shop_id, start_time DESC)` covers the leading equality + ordering; status filter is a post-scan boolean | **No new index.** ~5000-row scan for shop_id=X is sub-100ms |
| `recent` | adds `MAX(start_time) >= now() - 30d` filter | Same — start_time is already the secondary key | No |
| `lapsed` | adds `MAX(start_time) < now() - 60d AND EXISTS (...)` | Same scan, EXISTS reuses idx_bookings_shop_id | No |
| `by_service` | JOINs `booking_services bs ON bs.booking_id = b.id WHERE bs.slot_id = Y` | `idx_booking_services_slot_id` ([20260517010000:158](../../../supabase/migrations/20260517010000_booking_schema.sql#L158)) is `(slot_id)`; booking PK is the join key | No |

**Recommendation: ZERO new indexes for Phase 14.** The existing six indexes cover every audience CTE. The `idx_bookings_shop_date_status` composite is *not* used because the audience CTEs scan all dates — a partial index `WHERE status <> 'pending'` would shave maybe 10ms on a 5k-row shop, not worth the write-amplification on every booking insert.

**Verify-before-plan item.** Run once during plan-check on the largest shop in prod:
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT DISTINCT user_id, guest_profile_id
FROM bookings
WHERE shop_id = '<largest shop>' AND status <> 'pending';
```
If `Execution Time > 500ms`, add `CREATE INDEX idx_bookings_shop_status_nopending ON bookings (shop_id, user_id, guest_profile_id) WHERE status <> 'pending';` — but only then. Premature index = wasted write IO.

### 3. `scheduled_notifications` row shape for broadcast fan-out

Schema verified at [20260528120000_link_booking_guest_support.sql:88-95](../../../supabase/migrations/20260528120000_link_booking_guest_support.sql#L88-L95) + [20260507000000_notification_engine.sql](../../../supabase/migrations/20260507000000_notification_engine.sql):

```
ALTER TABLE scheduled_notifications
  ALTER COLUMN user_id DROP NOT NULL,
  ADD COLUMN guest_profile_id  uuid REFERENCES guest_profiles(id),
  ADD COLUMN delivery_channel  text NOT NULL DEFAULT 'push'
    CHECK (delivery_channel IN ('push', 'whatsapp')),
  ADD COLUMN whatsapp_template text,
  ADD COLUMN whatsapp_params   jsonb;
```

`booking_id` is nullable (no NOT NULL constraint). `shop_id` is nullable on the original DDL but the SPEC and Phase 12 helpers always set it — Phase 14 sets it. Phase 14 broadcast rows are:

```sql
-- Registered-user row (push):
INSERT INTO public.scheduled_notifications (
  user_id, guest_profile_id, booking_id, shop_id,
  notification_type, scheduled_for, delivery_channel,
  whatsapp_template, whatsapp_params, status, metadata
) VALUES (
  v_user_id, NULL, NULL, v_shop_id,
  'marketing_broadcast', now(), 'push',
  NULL, NULL, 'pending',
  jsonb_build_object(
    'title', v_subject,
    'body', v_body,
    'broadcast_id', v_broadcast_id,
    'shop_name', v_shop_name
  )
);

-- Guest row (whatsapp):
INSERT INTO public.scheduled_notifications (...) VALUES (
  NULL, v_guest_profile_id, NULL, v_shop_id,
  'marketing_broadcast', now(), 'whatsapp',
  'marketing_broadcast_v1', jsonb_build_object('1', v_shop_name, '2', v_body),
  'pending',
  jsonb_build_object(
    'phone', v_guest_phone,
    'broadcast_id', v_broadcast_id,
    'shop_name', v_shop_name
  )
);
```

The fan-out writes BOTH shapes in a single statement via a CASE expression — `INSERT INTO scheduled_notifications SELECT ... FROM resolved_audience`. See §4 for the full INSERT.

**No new schema fields on scheduled_notifications.** Confirms SPEC Phase boundary line 188 ("Server: 5 migrations") is correct on the worker side.

**`metadata.phone` source.** Phase 12's helper uses `COALESCE(bookings.guest_phone, guest_profiles.phone)` ([20260605130400:56-58](../../../supabase/migrations/20260605130400_enqueue_booking_reminder_helper.sql#L56-L58)). For broadcasts there is no booking row, so phone comes directly from `guest_profiles.phone`. Phone is UNIQUE on `guest_profiles` ([20260528120000:16](../../../supabase/migrations/20260528120000_link_booking_guest_support.sql#L16)) — one phone, one flag, no drift.

### 4. The `send_broadcast` RPC — full structure

Mandatory pattern (mirrors Phase 11 hardening + Phase 12 patterns):

```sql
CREATE OR REPLACE FUNCTION public.send_broadcast(
  p_shop_id         UUID,
  p_subject         TEXT,
  p_body            TEXT,
  p_audience_type   TEXT,
  p_audience_param  UUID,
  p_promotion_id    UUID DEFAULT NULL
) RETURNS TABLE (broadcast_id UUID, recipient_count INT)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
DECLARE
  v_broadcast_id   UUID;
  v_shop_name      TEXT;
  v_recipient_cnt  INT;
  v_promo_code     TEXT;
  v_today_count    INT;
BEGIN
  -- 1. Advisory lock — same-second double-tap guard.
  --    SPEC §non-functional / risk: "race between two owner sessions".
  --    Lock is xact-scoped; released at COMMIT or ROLLBACK.
  IF NOT pg_try_advisory_xact_lock(hashtext(p_shop_id::text)) THEN
    RAISE EXCEPTION 'rate_limited'
      USING ERRCODE = '55P03', HINT = 'BROADCAST_IN_FLIGHT';
  END IF;

  -- 2. NULL shape (no side effects).
  IF p_shop_id IS NULL OR p_subject IS NULL OR p_body IS NULL
     OR p_audience_type IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'REQUIRED_FIELD_MISSING';
  END IF;

  -- 3. Length caps — match SPEC line 41-42 (push 800, WhatsApp 1024).
  --    Subject is the push title only; 100 chars is the cap.
  IF char_length(p_subject) > 100 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'SUBJECT_TOO_LONG';
  END IF;
  IF char_length(p_body) > 800 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'BODY_TOO_LONG';
  END IF;

  -- 4. Audience-type validation. The four presets are locked by SPEC.
  IF p_audience_type NOT IN ('all_clients','recent','lapsed','by_service') THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'AUDIENCE_TYPE_INVALID';
  END IF;
  IF p_audience_type = 'by_service' AND p_audience_param IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'AUDIENCE_PARAM_REQUIRED';
  END IF;
  IF p_audience_type <> 'by_service' AND p_audience_param IS NOT NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'AUDIENCE_PARAM_FORBIDDEN';
  END IF;

  -- 5. Authz. Mirror Phase 11 hardening — ownership check, sanitized
  --    "not_found" message.
  IF NOT EXISTS (SELECT 1 FROM public.shops
                 WHERE id = p_shop_id AND user_id = auth.uid()) THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  -- 6. UTC-day rate limit. Long-term guard; advisory lock is the
  --    same-second guard.
  SELECT count(*) INTO v_today_count
  FROM public.broadcasts
  WHERE shop_id = p_shop_id
    AND created_at >= date_trunc('day', now() AT TIME ZONE 'UTC')
    AND created_at <  date_trunc('day', now() AT TIME ZONE 'UTC') + INTERVAL '1 day';
  IF v_today_count > 0 THEN
    RAISE EXCEPTION 'rate_limited'
      USING ERRCODE = '55P03', HINT = 'BROADCAST_DAILY_LIMIT';
  END IF;

  -- 7. Promo validation, only if attached. Predicate mirrors
  --    validate_and_apply_promo's manual-entry branch (Finding 6).
  --    Also rejects silent codes — owners can't attach a client-
  --    targeted loyalty/recovery code as a broadcast attachment.
  IF p_promotion_id IS NOT NULL THEN
    SELECT code INTO v_promo_code
    FROM public.promotions
    WHERE id = p_promotion_id
      AND shop_id = p_shop_id           -- cross-shop attach blocked
      AND archived_at IS NULL
      AND is_active = TRUE
      AND (valid_from IS NULL OR valid_from <= now())
      AND (valid_to   IS NULL OR valid_to   >  now())
      AND source = 'owner_defined';      -- silent codes can't be attached
    IF NOT FOUND THEN
      RAISE EXCEPTION 'invalid_input'
        USING ERRCODE = '22023', HINT = 'PROMO_NOT_VALID';
    END IF;
  END IF;

  -- 8. Shop name (for metadata + WhatsApp param 1).
  SELECT shop_name INTO v_shop_name FROM public.shops WHERE id = p_shop_id;

  -- 9. Insert the broadcasts row with status='delivering'.
  INSERT INTO public.broadcasts (
    shop_id, subject, body, audience_type, audience_param,
    promotion_id, created_by_user_id, status
  ) VALUES (
    p_shop_id, p_subject, p_body, p_audience_type, p_audience_param,
    p_promotion_id, auth.uid(), 'delivering'
  ) RETURNING id INTO v_broadcast_id;

  -- 10. Fan-out. Resolve audience inline, deduplicate, respect the
  --     accepts_marketing flag on guests, write scheduled_notifications
  --     in a single INSERT...SELECT for atomicity.
  WITH client_identities AS (
    SELECT DISTINCT
      b.user_id,
      b.guest_profile_id,
      COALESCE(b.user_id::text, b.guest_profile_id::text) AS dedup_key,
      MAX(b.start_time) FILTER (WHERE b.status <> 'pending') AS last_at
    FROM public.bookings b
    WHERE b.shop_id = p_shop_id AND b.status <> 'pending'
    GROUP BY b.user_id, b.guest_profile_id
  ),
  audience AS (
    SELECT user_id, guest_profile_id, dedup_key
    FROM client_identities ci
    WHERE
      CASE p_audience_type
        WHEN 'all_clients' THEN TRUE
        WHEN 'recent'      THEN last_at >= now() - INTERVAL '30 days'
        WHEN 'lapsed'      THEN last_at <  now() - INTERVAL '60 days'
                                AND EXISTS (
                                  SELECT 1 FROM public.bookings b2
                                  WHERE b2.shop_id = p_shop_id
                                    AND b2.status IN ('confirmed','completed')
                                    AND COALESCE(b2.user_id::text, b2.guest_profile_id::text) = ci.dedup_key
                                )
        WHEN 'by_service'  THEN EXISTS (
                                  SELECT 1 FROM public.bookings b2
                                  JOIN public.booking_services bs ON bs.booking_id = b2.id
                                  WHERE b2.shop_id = p_shop_id
                                    AND b2.status <> 'pending'
                                    AND bs.slot_id = p_audience_param
                                    AND COALESCE(b2.user_id::text, b2.guest_profile_id::text) = ci.dedup_key
                                )
      END
  ),
  -- Dedup is implicit via client_identities (DISTINCT user_id,
  -- guest_profile_id GROUP BY). The dedup_key column makes this
  -- explicit for the (rare) case of a client with both a user_id
  -- and a legacy guest_profile_id at the same shop — they get one
  -- row, not two. SPEC line 164 locks COALESCE(user_id::text,
  -- guest_profile_id::text); the GROUP BY achieves equivalent.
  filtered AS (
    -- Guest opt-out gate. accepts_marketing defaults TRUE; a row with
    -- accepts_marketing=FALSE is excluded entirely (no row in
    -- scheduled_notifications, doesn't count toward recipient_count).
    SELECT a.user_id, a.guest_profile_id
    FROM audience a
    LEFT JOIN public.guest_profiles gp ON gp.id = a.guest_profile_id
    WHERE a.user_id IS NOT NULL
       OR COALESCE(gp.accepts_marketing, TRUE) = TRUE
  ),
  inserted AS (
    INSERT INTO public.scheduled_notifications (
      user_id, guest_profile_id, booking_id, shop_id,
      notification_type, scheduled_for, delivery_channel,
      whatsapp_template, whatsapp_params, status, metadata
    )
    SELECT
      f.user_id,
      f.guest_profile_id,
      NULL,                              -- broadcasts have no booking
      p_shop_id,
      'marketing_broadcast'::notification_type,
      now(),
      CASE WHEN f.user_id IS NOT NULL THEN 'push' ELSE 'whatsapp' END,
      CASE WHEN f.user_id IS NULL THEN 'marketing_broadcast_v1' ELSE NULL END,
      CASE WHEN f.user_id IS NULL
           THEN jsonb_build_object('1', v_shop_name, '2', p_body)
           ELSE NULL END,
      'pending',
      CASE WHEN f.user_id IS NULL
           THEN jsonb_build_object(
                  'phone', (SELECT phone FROM public.guest_profiles WHERE id = f.guest_profile_id),
                  'broadcast_id', v_broadcast_id,
                  'shop_name', v_shop_name)
           ELSE jsonb_build_object(
                  'title', p_subject,
                  'body', p_body,
                  'broadcast_id', v_broadcast_id,
                  'shop_name', v_shop_name)
      END
    FROM filtered f
    RETURNING 1
  )
  SELECT count(*) INTO v_recipient_cnt FROM inserted;

  -- 11. Flip broadcasts.status to 'delivered' and stamp delivered_at +
  --     recipient_count. Worker advances per-row to 'sent', but the
  --     parent row is now closed for this RPC's purposes.
  UPDATE public.broadcasts
  SET status = 'delivered',
      delivered_at = now(),
      recipient_count = v_recipient_cnt
  WHERE id = v_broadcast_id;

  RETURN QUERY SELECT v_broadcast_id, v_recipient_cnt;
END;
$function$;

REVOKE ALL ON FUNCTION public.send_broadcast(UUID, TEXT, TEXT, TEXT, UUID, UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.send_broadcast(UUID, TEXT, TEXT, TEXT, UUID, UUID) TO authenticated;
COMMENT ON FUNCTION public.send_broadcast(UUID, TEXT, TEXT, TEXT, UUID, UUID) IS
  'Owner-only broadcast send: validates rate limit + promo, resolves audience, fans out to scheduled_notifications. Atomic within one RPC. O(n) on shop client count. Phase 14.';
```

**Why `recipient_count` is computed from `inserted` (not from `filtered`).** Defensive: a partial-failure scenario where some rows hit a CHECK or RLS deny would silently drop them. Counting the actual INSERT count gives the owner the truth.

**Atomicity.** The whole function runs in one implicit transaction (PL/pgSQL functions are atomic unless they include explicit BEGIN/COMMIT). A failure in fan-out rolls back the broadcasts row too — no half-sent broadcasts (SPEC §non-functional / atomicity).

### 5. UTC day vs shop timezone — locked default UTC, edge case documented

The SPEC's open question is moot — `shops.timezone` doesn't exist (Correction §1). Locked default UTC stands.

**Edge case to document in PR:**
- Owner in PDT (UTC-7) sends a broadcast at 4:59pm PDT (23:59 UTC, Monday).
- Owner sends another at 5:01pm PDT (00:01 UTC, Tuesday).
- Both pass the 1/day check because they're on different UTC days.
- Recipients get two broadcasts ~2 minutes apart.

The mitigation choices are:
- (a) **Accept it.** This is the cheapest path. Document. Recommend.
- (b) Compute the window in a hardcoded "platform timezone" (e.g. UTC-5). Doesn't help PDT owners.
- (c) Add `shops.timezone` and compute `at time zone shops.timezone`. Phase 15+ work; out of scope per SPEC.

**The PDT-owner-broadcasting-at-5pm scenario is rare** (most marketing sends are 10am-12pm or 6-8pm local time, away from UTC midnight in every US timezone). The 2-broadcast-in-2-minutes failure mode is also self-correcting: the second send is annoying to recipients but not catastrophic. Accept.

### 6. Promo re-validation predicate

Canonical predicate at [20260606000300_validate_and_apply_promo_rpc.sql:96-117](../../../supabase/migrations/20260606000300_validate_and_apply_promo_rpc.sql#L96-L117):

```sql
WHERE p.shop_id = p_shop_id
  AND UPPER(p.code) = UPPER(trim(p_code))
  AND p.archived_at IS NULL
-- then checked in code:
IF v_promo.is_active IS FALSE THEN ... CODE_NOT_FOUND
IF valid_from > now() OR valid_to <= now() THEN ... CODE_EXPIRED
```

`send_broadcast` doesn't have the code text — it has the `promotion_id` (a UUID from the owner's dropdown). The equivalent predicate, fused into one WHERE:

```sql
WHERE id = p_promotion_id
  AND shop_id = p_shop_id
  AND archived_at IS NULL
  AND is_active = TRUE
  AND (valid_from IS NULL OR valid_from <= now())
  AND (valid_to   IS NULL OR valid_to   >  now())
  AND source = 'owner_defined';
```

**`AND source = 'owner_defined'`** is the addition I'm calling out. The SPEC doesn't mention it; it's necessary because:
- Loyalty and recovery codes have `target_user_id` / `target_guest_profile_id` set (Phase 13 schema).
- Attaching a target-restricted code to an "all clients" broadcast doesn't make sense — only the targeted client could redeem it.
- A malicious owner inspecting the network tab could send a broadcast attaching another shop's silent code if we don't gate on shop_id, but the `shop_id = p_shop_id` already covers that. The `source = 'owner_defined'` guard is about preventing UI-level confusion (owner attaches their own loyalty code by accident, recipients see a code that only one client can redeem).

**The CODE_NOT_FOUND vs PROMO_NOT_VALID HINT split.** Phase 13 uses `CODE_NOT_FOUND` for is_active=false (treats it as "doesn't exist" to avoid enumeration). Phase 14 uses `PROMO_NOT_VALID` because the owner sees their own codes in a dropdown — there's no enumeration leak risk. The HINT difference flows into different Dart exception subtypes:

- Phase 13 manual entry → `PromotionNotFoundException` (user-facing: "we couldn't find that code")
- Phase 14 attach failure → `BroadcastPromoInvalidException` (user-facing: "This code is no longer valid. Pick another or remove the code.")

### 7. Recipient deduplication

SPEC line 164 locks `COALESCE(user_id::text, guest_profile_id::text)` as the dedup key. The implementation in §4 achieves this via `GROUP BY user_id, guest_profile_id` in `client_identities`. Two semantic notes:

1. **`DISTINCT user_id, guest_profile_id` is equivalent to `GROUP BY user_id, guest_profile_id`** because the `bookings_user_or_guest_chk` constraint ([20260528120000:66-71](../../../supabase/migrations/20260528120000_link_booking_guest_support.sql#L66-L71)) enforces exactly-one-of. Each row has exactly one identity column non-null. DISTINCT collapses duplicates of the *same* identity.

2. **The cross-identity case** (a single human with two booking histories: one as a registered user, one as a guest with a different phone) results in TWO rows in `client_identities`. They have different `dedup_key` values (`user_id::text` ≠ `guest_profile_id::text`). They get two broadcasts.

   This is the correct behavior given the codebase has no way to know they're the same person. The SPEC's locked dedup key doesn't claim to dedupe across identity types; it dedupes within a single identity (e.g. if the same user_id appears in 5 bookings, we get 1 row in the audience).

   Document this in PR: "cross-identity duplicates are not deduplicated. A guest who later registers under the same phone may receive two broadcasts during the v1 rollout window." This is acceptable.

3. **The `filtered` CTE in §4** applies the `accepts_marketing` gate AFTER deduplication, which is correct: a guest_profile with accepts_marketing=FALSE is excluded; a registered user (user_id NOT NULL) always passes (only OS-level mute).

### 8. WhatsApp `marketing_broadcast_v1` template — Meta constraints

Meta's marketing-category templates have stricter content rules than utility templates ([Meta template categorization](https://developers.facebook.com/documentation/business-messaging/whatsapp/templates/template-categorization), [Infobip compliance docs](https://www.infobip.com/docs/whatsapp/compliance/template-compliance)). The `marketing_broadcast_v1` template body MUST:

1. **Identify the sender.** First variable `{{1}} = shop_name` satisfies this.
2. **Include opt-out instructions.** Required for marketing-category. Recommend appending: "Reply STOP to opt out." — fixed text, not a variable. The SPEC's "STOP reply flips flag" is a worker-side follow-up (out of Phase 14 scope), but the opt-out language MUST be in the template body or Meta rejects.
3. **Not impersonate a person/brand.** `{{1}}` is the shop's own name; safe.
4. **Not include misleading discount language.** If the broadcast attaches a Phase 13 promo, the body text is owner-authored — owner liability, not template liability. Meta reviews the TEMPLATE; the body text variable `{{2}}` is the slot they review.
5. **Use a clear "call to action" or relevance to recipient.** The shop's existing client relationship satisfies this.

**Recommended template body (English):**

```
Hi from {{1}}! 

{{2}}

Reply STOP to opt out of marketing messages.
```

`{{1}}` = shop_name, `{{2}}` = the owner-authored body (≤800 chars). Total max length: 800 + ~70 chars boilerplate + shop_name. Well under Meta's 1024 char body cap.

**Approval timeline.** Meta's marketing-category review SLA:
- Automated check: 15 min - 1h (typical) [CITED]
- Human review on flag: a few minutes to 24h, occasionally 48h for marketing category specifically (Meta has stricter review for marketing vs utility per April 2025 enforcement changes — [Wati.io approval guide](https://support.wati.io/en/articles/12320234-understanding-meta-s-latest-updates-on-template-approval)) [CITED]
- After Business Verification: usually immediate; without: up to 24h [CITED]

**SPEC's 6h retry coverage analysis.** The worker's `WhatsAppTemplateNotFoundError` handler ([process-scheduled-notifications/index.ts:124-128](../../../supabase/functions/process-scheduled-notifications/index.ts#L124-L128)) defers for 6h and retries. If approval takes 24h, the broadcast row sits at `delivering` with 4 retry deferrals before delivery. **Acceptable for v1, but the broadcasts.status badge will show 'delivering' for up to 24h** — owner sees a "stuck" state. Recommend the BroadcastsScreen surface a tooltip on status='delivering' rows older than 6h: "WhatsApp template approval is pending. This usually resolves within 24h."

**Submission gate.** Same as Phase 12 / 13: submit template via Meta Business Manager during Wave 0, ship migrations regardless of approval, let the worker's 6h backoff cover the gap.

### 9. `broadcasts` table immutability — RLS pattern

SPEC locks "no UPDATE, no DELETE — broadcasts are immutable once sent." The canonical pattern in this codebase: omit the policies entirely. Verified by negative inspection:

- [20260603001600_enforce_audit_immutability.sql](../../../supabase/migrations/20260603001600_enforce_audit_immutability.sql) demonstrates the explicit "deny UPDATE/DELETE" pattern via REVOKE — but this is for the audit log, where the table is service-role-only and SECURITY DEFINER triggers control all writes.
- The Phase 13 `promotions` table allows owner UPDATE/DELETE for `source = 'owner_defined'` ([20260606000000:140-154](../../../supabase/migrations/20260606000000_extend_promotions_for_phase13.sql#L140-L154)).
- The Phase 12 `client_notes` table allows UPDATE via `upsert_client_note` RPC ([20260605130200_upsert_client_note_rpc.sql](../../../supabase/migrations/20260605130200_upsert_client_note_rpc.sql)) but disallows direct UPDATE policies.

For broadcasts, the simpler pattern is to declare ONLY a SELECT policy. Direct INSERT/UPDATE/DELETE on `broadcasts` from authenticated is impossible without an INSERT policy. The `send_broadcast` RPC is SECURITY DEFINER and bypasses RLS, so it inserts; the `send_broadcast` UPDATE at the end (to flip status to 'delivered') also runs as the function owner.

```sql
CREATE TABLE IF NOT EXISTS public.broadcasts (
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id              UUID NOT NULL REFERENCES public.shops(id) ON DELETE CASCADE,
  subject              TEXT NOT NULL CHECK (char_length(subject) <= 100),
  body                 TEXT NOT NULL CHECK (char_length(body) <= 800),
  audience_type        TEXT NOT NULL CHECK (audience_type IN
                         ('all_clients','recent','lapsed','by_service')),
  audience_param       UUID,
  promotion_id         UUID REFERENCES public.promotions(id) ON DELETE SET NULL,
  created_by_user_id   UUID NOT NULL REFERENCES auth.users(id),
  created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  delivered_at         TIMESTAMPTZ,
  recipient_count      INT NOT NULL DEFAULT 0 CHECK (recipient_count >= 0),
  status               TEXT NOT NULL DEFAULT 'pending'
                         CHECK (status IN ('pending','delivering','delivered','failed')),
  -- Mirror the bookings audience_param XOR: by_service requires a param;
  -- the other three forbid it.
  CONSTRAINT broadcasts_audience_param_check CHECK (
    (audience_type = 'by_service' AND audience_param IS NOT NULL) OR
    (audience_type <> 'by_service' AND audience_param IS NULL)
  )
);

CREATE INDEX IF NOT EXISTS broadcasts_shop_created_idx
  ON public.broadcasts (shop_id, created_at DESC);

-- Rate-limit support index: count rows in current UTC day for this shop.
-- The shop_created_idx above already covers this; no additional index.

ALTER TABLE public.broadcasts ENABLE ROW LEVEL SECURITY;

CREATE POLICY broadcasts_owner_select ON public.broadcasts
  FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.shops s
                 WHERE s.id = broadcasts.shop_id AND s.user_id = auth.uid()));

-- No INSERT / UPDATE / DELETE policies. Mutations only through
-- send_broadcast (SECURITY DEFINER, which bypasses RLS).
```

**Why no explicit REVOKE.** Postgres default GRANT for TO authenticated on a table is empty unless granted; the only way for an authenticated client to write is through a policy. Absence of INSERT/UPDATE/DELETE policies on an RLS-enabled table is a deny-all on those operations for `authenticated`. Confirmed pattern: [20260605130100_client_notes_table.sql:43-56](../../../supabase/migrations/20260605130100_client_notes_table.sql#L43-L56) declares only SELECT + uses RPC for writes.

### 10. `preview_broadcast_audience` RPC — owner-only, no enumeration

SPEC §non-functional: "owner-only too — clients don't get to count their fellow customers." The simpler version of `send_broadcast` minus the writes:

```sql
CREATE OR REPLACE FUNCTION public.preview_broadcast_audience(
  p_shop_id        UUID,
  p_audience_type  TEXT,
  p_audience_param UUID DEFAULT NULL
) RETURNS INT
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
DECLARE v_count INT;
BEGIN
  -- NULL shape.
  IF p_shop_id IS NULL OR p_audience_type IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'REQUIRED_FIELD_MISSING';
  END IF;
  IF p_audience_type NOT IN ('all_clients','recent','lapsed','by_service') THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'AUDIENCE_TYPE_INVALID';
  END IF;
  IF p_audience_type = 'by_service' AND p_audience_param IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'AUDIENCE_PARAM_REQUIRED';
  END IF;

  -- Authz first.
  IF NOT EXISTS (SELECT 1 FROM public.shops
                 WHERE id = p_shop_id AND user_id = auth.uid()) THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  -- Same CTEs as send_broadcast, with accepts_marketing gate applied
  -- (count matches the actual fan-out count).
  WITH client_identities AS (
    SELECT DISTINCT b.user_id, b.guest_profile_id,
           MAX(b.start_time) FILTER (WHERE b.status <> 'pending') AS last_at,
           COALESCE(b.user_id::text, b.guest_profile_id::text) AS dedup_key
    FROM public.bookings b
    WHERE b.shop_id = p_shop_id AND b.status <> 'pending'
    GROUP BY b.user_id, b.guest_profile_id
  ),
  audience AS (
    SELECT ci.user_id, ci.guest_profile_id
    FROM client_identities ci
    WHERE
      CASE p_audience_type
        WHEN 'all_clients' THEN TRUE
        WHEN 'recent'      THEN ci.last_at >= now() - INTERVAL '30 days'
        WHEN 'lapsed'      THEN ci.last_at <  now() - INTERVAL '60 days'
                                AND EXISTS (
                                  SELECT 1 FROM public.bookings b2
                                  WHERE b2.shop_id = p_shop_id
                                    AND b2.status IN ('confirmed','completed')
                                    AND COALESCE(b2.user_id::text, b2.guest_profile_id::text) = ci.dedup_key)
        WHEN 'by_service'  THEN EXISTS (
                                  SELECT 1 FROM public.bookings b2
                                  JOIN public.booking_services bs ON bs.booking_id = b2.id
                                  WHERE b2.shop_id = p_shop_id
                                    AND b2.status <> 'pending'
                                    AND bs.slot_id = p_audience_param
                                    AND COALESCE(b2.user_id::text, b2.guest_profile_id::text) = ci.dedup_key)
      END
  )
  SELECT count(*) INTO v_count
  FROM audience a
  LEFT JOIN public.guest_profiles gp ON gp.id = a.guest_profile_id
  WHERE a.user_id IS NOT NULL OR COALESCE(gp.accepts_marketing, TRUE) = TRUE;

  RETURN v_count;
END;
$function$;

REVOKE ALL ON FUNCTION public.preview_broadcast_audience(UUID, TEXT, UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.preview_broadcast_audience(UUID, TEXT, UUID) TO authenticated;
COMMENT ON FUNCTION public.preview_broadcast_audience(UUID, TEXT, UUID) IS
  'Owner-only read-side count of an audience preset. Used by CreateBroadcastScreen for live preview. Same CTEs as send_broadcast minus inserts. STABLE; safe to call in form-edit hot path. Phase 14.';
```

**Authz analysis.** A non-owner authenticated user calling this RPC for a shop they don't own gets `not_found` (42501) — same as Phase 11. The error is uniform regardless of whether the shop exists. **The `GRANT EXECUTE TO authenticated` is the SPEC-mandated minimum** because the owner's client app needs to call it. The authz check is the gate, not the GRANT.

**The prompt asks: "should non-owners ever call this RPC?"** No. **Recommend NOT GRANT EXECUTE TO authenticated, only owner-RPC pattern.** The function would then be unreachable from any client and need to be called via a service-role RPC wrapper. **But the Phase 11 hardened pattern is GRANT + authz-in-body** ([20260603001500:105-108](../../../supabase/migrations/20260603001500_harden_dashboard_rpcs.sql#L105-L108) for `get_booking_heatmap`). Match Phase 11. The authz-in-body is the canonical guard. Don't introduce a new pattern.

### 11. Audience size cap — recommend a cap despite SPEC saying "no cap"

SPEC §86 locks "no cap in v1." [WhatsApp Business 2026 messaging limits](https://www.uptail.ai/blog/how-many-messages-can-you-send-on-whatsapp-business-limits-explained-for-2026):

| Account tier | Unique contacts / 24h (per Business Portfolio, since Oct 2025) |
|--------------|-----------------------------------------------------------------|
| Unverified | 250 |
| After Business Verification | 1,000 |
| Tier 2 | 10,000 |
| Tier 3 | 100,000 |
| Unlimited | (gradual graduation; ~6h re-evaluation) |

[CITED — verified June 2026]

**Per-recipient frequency cap:** Meta enforces ~2 marketing messages per recipient per day across all senders. A recipient already at quota will receive a delivery failure code (worker logs it; v1 doesn't surface to owner — flag for follow-up).

**Throughput:** ~80 MPS (messages per second) standard; up to 1,000 MPS for unlimited tier. A 10,000-recipient broadcast at 80 MPS = ~2 minutes wall-clock to dispatch. Worker batches 50 rows per cron tick ([process-scheduled-notifications/index.ts:15](../../../supabase/functions/process-scheduled-notifications/index.ts#L15) `BATCH_LIMIT = 50`), one tick per minute ([20260602150000_schedule_notifications_cron.sql](../../../supabase/migrations/20260602150000_schedule_notifications_cron.sql)). 10,000 rows / 50 / minute = **~200 minutes (3.3h) to drain a single 10k broadcast.**

**The v1 risks the SPEC's "no cap" creates:**
1. A single shop with 10k clients fans out 10k WhatsApp messages. NanoEmbryo's Business Portfolio is presumably Tier 2 or Tier 3 at this point. The broadcast eats the entire daily WhatsApp budget for the portfolio. Every other shop's bookings + broadcasts + reminders that day are throttled.
2. Tier-1 NanoEmbryo (most likely state at launch): broadcasts >250 fail entirely after the first 250. The worker's incrementWhatsAppRetryOrFail ([index.ts:198-224](../../../supabase/functions/process-scheduled-notifications/index.ts#L198-L224)) retries 3x with backoff, then marks failed — the owner sees `recipient_count = 10000` but actual delivered messages = 250.

**Recommend:**
- Add `MAX_BROADCAST_RECIPIENTS = 1000` constant in v1 (matches verified-account tier 1).
- Enforce in `send_broadcast` after audience resolution: if `count(*) FROM filtered > 1000`, raise `RECIPIENT_CAP_EXCEEDED` HINT.
- BroadcastsScreen surfaces the cap in the audience preview ("Recipient cap: 1,000 per broadcast in v1").
- Phase 15+ can raise the cap once we know which portfolio tier NanoEmbryo is on.

**This contradicts SPEC §86's locked decision.** Flag for the user to confirm in Open Questions §1. If the user holds "no cap", document the WhatsApp Business Portfolio tier risk explicitly in PR and accept the failure mode.

### 12. WhatsApp deliverability — competitive surface

Quick survey of how the four named competitors ship broadcast / owner-driven marketing:

| Product | Surface | Audience presets | Rate limit | Channels |
|---------|---------|------------------|------------|----------|
| Fresha | "Send Marketing Campaigns" ([fresha.com/help-center](https://www.fresha.com/help-center)) | All / Recent (30d) / Inactive (90d) / By Service / Custom segment | Soft limit; per-account quota | Email primary, SMS opt-in, push to app users |
| Booksy | "Smart Marketing" ([booksy.com/biz/smart-marketing](https://booksy.com/biz/smart-marketing)) | All / Recent / Inactive / Custom (filter by tag, service) | "Sending limits based on plan" — undocumented | Email + SMS + push |
| Vagaro | "Automated Marketing" + "Email Marketing" ([vagaro.com/pro/features/automated-marketing](https://www.vagaro.com/pro/features/automated-marketing)) | Time-since-last-visit thresholds (configurable) | Subscription-tier based | Email + SMS + push |
| Square Appointments | "Square Marketing" | Recency segments + custom audiences | Tier-based caps on subscriber count | Email + SMS |

**Observations relevant to Phase 14:**

- **NONE of the four use WhatsApp as a marketing channel.** They use email + SMS. WhatsApp marketing is an emerging-market pattern (Brazil, Ghana, India, Nigeria) — NanoEmbryo's WhatsApp-first strategy is a differentiator, not parity. `[CITED — competitor product pages]`
- **All four expose a "Recent / Inactive / All" preset triad.** Phase 14's 4-preset (`all_clients / recent / lapsed / by_service`) matches the industry default. SPEC's choice is sound. `[VERIFIED]`
- **All four enforce some daily / monthly cap.** Vagaro and Square tie caps to subscription tier. Fresha caps based on plan. Booksy is opaque. Phase 14's "1/day per shop" is more conservative than competitors — none cap to a single send per day. The 1/day cap is defensible as a v1 spam-prevention guard but may feel restrictive to owners migrating from competitors. Recommend documenting "v1 limit; will increase in Phase 15+ based on WhatsApp tier graduation." `[CITED]`
- **None publish their template copy.** All four use first-party (email, SMS) where they own the deliverability surface, so they don't have a Meta-approval gate to navigate. NanoEmbryo's `marketing_broadcast_v1` Meta-template gate is unique to the WhatsApp choice. `[ASSUMED]`

### 13. `BroadcastsScreen` list rows — mirror Phase 13.1 `_PromotionRow`

[promotions_screen.dart:249-335](../../../lib/presentation/features/shops/dashboard/presentation/screens/promotions_screen.dart#L249-L335) is the precedent. The `_PromotionRow` wraps a `PromotionCard` with a leading badge (`_badgeColor` + `_badgeText` switching on `promotion.source`).

For Phase 14's BroadcastsScreen, mirror the pattern with a `_BroadcastRow`:

```dart
class _BroadcastRow extends StatelessWidget {
  final BroadcastDTO broadcast;
  const _BroadcastRow({required this.broadcast});

  Color _statusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (broadcast.status) {
      case BroadcastStatus.pending:    return scheme.outline;
      case BroadcastStatus.delivering: return scheme.tertiary;
      case BroadcastStatus.delivered:  return scheme.primary;
      case BroadcastStatus.failed:     return scheme.error;
    }
  }

  String _audienceLabel(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    switch (broadcast.audienceType) {
      case BroadcastAudience.allClients: return loc.broadcastAudienceAllClients;
      case BroadcastAudience.recent:     return loc.broadcastAudienceRecent;
      case BroadcastAudience.lapsed:     return loc.broadcastAudienceLapsed;
      case BroadcastAudience.byService:  return loc.broadcastAudienceByService;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Two-column: [status badge + audience label] on left,
    // [recipient_count + delivered_at] on right. Tap → read-only detail
    // view. NO edit/delete (broadcasts are immutable per SPEC).
    ...
  }
}
```

**The Phase 13.1 isSystemGenerated → null-callbacks pattern doesn't apply here** because broadcasts have no "edit" affordance at all — every row is read-only.

**Status badge tooltip on 'delivering' rows older than 6h** (per Finding §8): "WhatsApp template approval is pending. This usually resolves within 24h."

### 14. `BroadcastException` hierarchy + `_classifyBroadcastError`

Mirror [promotion_exceptions.dart](../../../lib/presentation/features/shops/dashboard/data/exceptions/promotion_exceptions.dart) — same `code` + `userMessage` pattern, same HINT-driven classifier. Phase 14 adds:

```dart
class BroadcastException implements Exception {
  final String message;
  final String code;
  final String userMessage;
  BroadcastException(this.message, {required this.code, required this.userMessage});
  @override String toString() => 'BroadcastException($code): $message';
}

class BroadcastRateLimitException extends BroadcastException {
  BroadcastRateLimitException() : super(
    'Rate limit hit (1/UTC day)',
    code: 'BROADCAST_RATE_LIMIT',
    userMessage: "You've already sent a broadcast today. Try again tomorrow.",
  );
}

class BroadcastInFlightException extends BroadcastException {
  BroadcastInFlightException() : super(
    'Advisory lock held; another send in flight',
    code: 'BROADCAST_IN_FLIGHT',
    userMessage: 'Another broadcast is being processed. Please wait a moment.',
  );
}

class BroadcastInvalidAudienceException extends BroadcastException {
  BroadcastInvalidAudienceException() : super(
    'Audience param missing or invalid',
    code: 'BROADCAST_AUDIENCE_INVALID',
    userMessage: 'Please pick a valid audience and (if "By service") a service.',
  );
}

class BroadcastPromoInvalidException extends BroadcastException {
  BroadcastPromoInvalidException() : super(
    'Attached promo is archived / expired / cross-shop / silent',
    code: 'BROADCAST_PROMO_INVALID',
    userMessage: 'This code is no longer valid. Pick another or remove the code.',
  );
}

class BroadcastRecipientCapExceededException extends BroadcastException {
  BroadcastRecipientCapExceededException() : super(
    'Audience exceeds the v1 recipient cap',
    code: 'BROADCAST_RECIPIENT_CAP',
    userMessage: 'This audience is larger than the current cap. Try a narrower audience.',
  );
}

class BroadcastSaveFailedException extends BroadcastException {
  BroadcastSaveFailedException() : super(
    'Server save failed',
    code: 'BROADCAST_SAVE_FAILED',
    userMessage: 'Could not send broadcast. Please try again.',
  );
}
```

**Classifier (in PromotionsRepository — SPEC line 129 says reuse it):**

```dart
BroadcastException _classifyBroadcastError(PostgrestException e) {
  final hint = e.hint ?? '';
  if (e.code == '55P03') {
    if (hint.contains('BROADCAST_DAILY_LIMIT')) return BroadcastRateLimitException();
    if (hint.contains('BROADCAST_IN_FLIGHT'))   return BroadcastInFlightException();
  }
  if (e.code == '22023') {
    if (hint.contains('AUDIENCE_TYPE_INVALID'))     return BroadcastInvalidAudienceException();
    if (hint.contains('AUDIENCE_PARAM_REQUIRED'))   return BroadcastInvalidAudienceException();
    if (hint.contains('AUDIENCE_PARAM_FORBIDDEN'))  return BroadcastInvalidAudienceException();
    if (hint.contains('PROMO_NOT_VALID'))           return BroadcastPromoInvalidException();
    if (hint.contains('RECIPIENT_CAP_EXCEEDED'))    return BroadcastRecipientCapExceededException();
    if (hint.contains('SUBJECT_TOO_LONG') ||
        hint.contains('BODY_TOO_LONG') ||
        hint.contains('REQUIRED_FIELD_MISSING'))    return BroadcastSaveFailedException();
  }
  return BroadcastSaveFailedException();
}
```

**No string matching on `e.message`.** Locked by Phase 11 / 12 / 13 precedent.

### 15. Hardening template parity checklist

Every Phase 14 RPC follows the pattern at [20260603001500_harden_dashboard_rpcs.sql:29-108](../../../supabase/migrations/20260603001500_harden_dashboard_rpcs.sql#L29-L108) — verified in the Finding §4 / §10 RPC bodies above. Required elements:

1. ✅ `LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp`. The `pg_temp` addition is the Phase 12+ pattern ([20260605130400:32](../../../supabase/migrations/20260605130400_enqueue_booking_reminder_helper.sql#L32)).
2. ✅ NULL shape validation before authz (no side effects, prevents NULLs from masking authz failures — Phase 13 §18 pattern).
3. ✅ **Authz FIRST** (before any data load that could leak existence). The `not_found` USING ERRCODE='42501' message is the canonical sanitized response.
4. ✅ Payload validation after authz with HINT codes (`AUDIENCE_TYPE_INVALID`, `BODY_TOO_LONG`, etc.).
5. ✅ `REVOKE ALL ON FUNCTION ... FROM PUBLIC; GRANT EXECUTE ... TO authenticated;` for `send_broadcast` + `preview_broadcast_audience` (both owner-callable).
6. ✅ `COMMENT ON FUNCTION ... IS '... Phase 14.'` with Big-O claim.
7. ✅ Sanitized error messages — no `'shop X not found'`, just `'not_found'`.

**Difference from Phase 12 helpers:** `send_broadcast` and `preview_broadcast_audience` ARE granted to authenticated (owner calls them from app). Phase 12's `enqueue_booking_reminder` is NOT granted because it's called only from triggers / SECURITY DEFINER RPCs. Phase 14 has no helper functions; both RPCs are caller-facing.

### 16. Bulk INSERT performance — `INSERT ... SELECT` is the canonical pattern

Phase 12's `enqueue_booking_reminder` writes ONE row per call ([20260605130400:90-112](../../../supabase/migrations/20260605130400_enqueue_booking_reminder_helper.sql#L90-L112)). Phase 14 needs to write N rows in one call (potentially up to the §11 recipient cap of 1000).

The single-statement `INSERT INTO scheduled_notifications SELECT ... FROM filtered` in Finding §4 is the canonical bulk-insert pattern. Postgres handles it as a single statement-level operation:
- One round-trip to the database (no app-side N+1).
- One transaction commit at function end.
- WAL-batched (a single COMMIT writes the WAL for all N rows).
- Constraint checks happen per-row but in C; ~10µs per row.

**Estimated cost for 1000-row fan-out:** ~50ms total RPC wall-clock on Supabase Pro tier (this is the §non-functional performance budget; SPEC says <500ms for 5000 clients). With the §11 cap of 1000 recipients, we have ~10x headroom.

**`pg_try_advisory_xact_lock(hashtext(shop_id::text))`** at function entry. xact-scoped lock; auto-released on COMMIT / ROLLBACK. Returns FALSE if another transaction holds it. The `hashtext` cast is necessary because advisory_xact_lock takes BIGINT — `hashtext(uuid::text)` is the standard hashing pattern. The lock prevents the same-second double-tap race (two RPCs in parallel; the second gets `BROADCAST_IN_FLIGHT` before any insert).

The 1/day rate-limit check at step 6 (count of broadcasts today) is the long-term guard. The advisory lock is the within-RPC race guard. Both are needed — the rate limit alone doesn't protect against a parallel race where both transactions read count=0, both insert.

### 17. `notification_type` enum extension — same defensive pattern

Phase 12 confirmed enum-in-prod ([20260605130000:3-7](../../../supabase/migrations/20260605130000_add_phase12_notification_types.sql#L3-L7)). Bare `ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'marketing_broadcast'` is idempotent and matches the Phase 12 / 13 pattern. **No defensive DO block needed** (Phase 12 RESEARCH §2's concern about TEXT-vs-enum was resolved when prod was verified as enum).

Migration shape:
```sql
-- 20260607000000_add_marketing_broadcast_notification_type.sql
ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'marketing_broadcast';
```

One line. No DO block, no discovery, no fallback. Matches the established post-Phase-12 pattern.

### 18. `guest_profiles.accepts_marketing` column add

Add column + zero data migration (DEFAULT TRUE means existing rows materialize the value on read; no UPDATE pass needed for backfill):

```sql
-- 20260607000100_add_accepts_marketing_to_guest_profiles.sql
ALTER TABLE public.guest_profiles
  ADD COLUMN IF NOT EXISTS accepts_marketing BOOLEAN NOT NULL DEFAULT TRUE;

COMMENT ON COLUMN public.guest_profiles.accepts_marketing IS
  'Per-guest opt-out flag. Defaults TRUE on first booking. Phase 14 reads this in send_broadcast / preview_broadcast_audience to exclude opted-out guests from fan-out. STOP-reply opt-out is a worker-side follow-up (out of Phase 14 scope).';
```

**Defaults-to-TRUE is a deliberate choice per SPEC.** A guest who books once and never opts out remains broadcastable. The cost: a guest who didn't expect marketing receives a marketing message and must STOP-reply. The STOP-flip behavior is OUT of Phase 14 scope (SPEC line 165) — flagged for follow-up.

**Phase 14 reads the flag** in the §4 / §10 `filtered` CTE. The worker doesn't read it — the row is either inserted (passes the gate) or never written.

### 19. Runtime State Inventory

Rename / refactor section is N/A — Phase 14 is greenfield additive. No runtime state to migrate.

### 20. Environment Availability

External dependencies and availability:

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Supabase Postgres 15+ | All migrations | ✓ | prod | — |
| `pg_cron` extension | Notification worker (existing) | ✓ | [20260602150000](../../../supabase/migrations/20260602150000_schedule_notifications_cron.sql) | — |
| `gen_random_uuid()` | broadcasts PK default | ✓ | pgcrypto in core | — |
| `pg_try_advisory_xact_lock` | Race guard in send_broadcast | ✓ | core PG | — |
| `hashtext()` | uuid → bigint for advisory_xact_lock | ✓ | core PG | — |
| Meta WhatsApp template `marketing_broadcast_v1` | Guest fan-out | ✗ | needs submission | Worker auto-defers 6h until approved ([process-scheduled-notifications/index.ts:124-128](../../../supabase/functions/process-scheduled-notifications/index.ts#L124-L128)). Push delivery to registered users works unaffected. |
| OneSignal push delivery | Registered fan-out | ✓ | existing infra | — |
| Flutter `flutter_test` + `mocktail` | Wave 0 tests | ✓ | pubspec | — |

**Missing dependencies with no blocking fallback:** None.
**Missing with viable fallback:** `marketing_broadcast_v1` Meta template — guest WhatsApp delivery defers gracefully. Submit Wave 0.

### 21. Validation Architecture

`nyquist_validation` enabled (config absent or true).

**Test framework**

| Property | Value |
|----------|-------|
| Framework | Flutter `flutter_test` + `mocktail` (existing) |
| SQL tests | `supabase/tests/phase14_smoke.sql` (manual psql per Phase 10-13 precedent — no pgTAP runner) |
| Quick run | `flutter test test/dashboard/broadcasts_test.dart -p chrome --no-coverage` |
| Full suite | `flutter test` |

**Phase requirements → test map** (SPEC §success criteria 1-10)

| SC | Behavior | Test type | Command | Exists? |
|----|----------|-----------|---------|---------|
| 1 | Owner navigates Tools → Broadcasts → +. Form opens. | Dart widget | `flutter test test/dashboard/broadcasts_screen_test.dart` | ❌ Wave 0 |
| 2 | Subject + body + audience preview shows count | Dart widget | `create_broadcast_screen_test.dart` | ❌ Wave 0 |
| 3 | "By service" reveals service dropdown | Dart widget | `create_broadcast_screen_test.dart` | ❌ Wave 0 |
| 4 | "Lapsed" returns 0 for fresh shop | SQL smoke | `phase14_smoke.sql:audience_lapsed_empty` | ❌ Wave 0 |
| 5 | Attach promo dropdown filters archived | Dart widget | `create_broadcast_screen_test.dart` | ❌ Wave 0 |
| 6 | Send → broadcasts row with delivered_at | SQL smoke | `phase14_smoke.sql:send_broadcast_happy_path` | ❌ Wave 0 |
| 7 | Send twice in same UTC day → rate limit | SQL smoke | `phase14_smoke.sql:send_broadcast_rate_limit` | ❌ Wave 0 |
| 8 | Attach expired promo → PROMO_NOT_VALID | SQL smoke | `phase14_smoke.sql:promo_validation_at_send_time` | ❌ Wave 0 |
| 9 | scheduled_notifications rows with correct channel | SQL smoke | `phase14_smoke.sql:fanout_channel_split` | ❌ Wave 0 |
| 10 | accepts_marketing=FALSE guest excluded | SQL smoke | `phase14_smoke.sql:accepts_marketing_gate` | ❌ Wave 0 |

**Sampling rate**

- Per task commit: `flutter test test/dashboard/broadcasts_screen_test.dart`
- Per wave merge: `flutter test test/dashboard/`
- Phase gate: full `flutter test` + `psql -f supabase/tests/phase14_smoke.sql` clean exit

**Wave 0 gaps**

- [ ] `supabase/tests/phase14_smoke.sql` — covers SC 4, 6, 7, 8, 9, 10
- [ ] `test/dashboard/broadcasts_screen_test.dart` — covers SC 1
- [ ] `test/dashboard/create_broadcast_screen_test.dart` — covers SC 2, 3, 5
- [ ] `test/dashboard/broadcast_repository_test.dart` — HINT classifier table tests

### 22. Security Domain (security_enforcement enabled)

| ASVS | Applies | Standard Control |
|------|---------|------------------|
| V2 Authentication | yes | Supabase `auth.uid()` in every RPC |
| V3 Session | n/a | Supabase JWT |
| V4 Access Control | yes | RLS SELECT-only on broadcasts; RPC body authz on send + preview; advisory lock on send |
| V5 Input Validation | yes | char_length caps; audience_type whitelist; HINT-coded rejections |
| V6 Cryptography | n/a | No new secrets |
| V7 Error Handling | yes | sanitized `'not_found'` for cross-shop access; no message echoing of inputs |
| V8 Data Protection | yes | `scheduled_notifications.metadata` carries phone for WhatsApp rows only; never echoed to push metadata. Owner-side preview never enumerates recipient identities — only count. |
| V9 Communications | n/a | Supabase HTTPS |

**Known threat patterns for Phase 14:**

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Cross-shop broadcast attempt (owner of A broadcasts to clients of B) | Tampering | `shop_id` authz check in send_broadcast + preview_broadcast_audience; uniform `'not_found'` response |
| Owner attaches another shop's promo code | Tampering | `shop_id = p_shop_id` predicate on promo re-validation |
| Owner attaches a silent (loyalty/recovery) code as a broadcast | Tampering | `source = 'owner_defined'` predicate on promo re-validation (this research's Correction §6) |
| Non-owner enumerates audience sizes by calling preview_broadcast_audience | Information disclosure | Authz-in-body; uniform `'not_found'` for any non-owner call |
| Same-second double-tap → two broadcasts | Tampering | `pg_try_advisory_xact_lock(hashtext(shop_id::text))` at RPC entry |
| Spam-prevention bypass via small batches | Tampering | 1/UTC day rate limit at row level — no per-call escape |
| Guest who opted out receives broadcast | Privacy / opt-out compliance | `accepts_marketing` gate in `filtered` CTE; row never inserted |
| Recipient enumeration via timing of preview_broadcast_audience | Information disclosure | Authz-first means non-owners never reach the count step |
| Owner broadcasts profanity / spam content | Reputation (Meta side) | Meta-approval gate on `marketing_broadcast_v1` template body shape; opt-out language required (Finding §8) |
| WhatsApp Business Portfolio tier exhaustion | Availability (for other shops) | §11 recommended recipient cap (1000/broadcast) |

## Open questions for the user (verify before plan)

1. **P0 — Audience size cap.** SPEC locks "no cap in v1." This research recommends a 1,000-recipient cap to protect NanoEmbryo's WhatsApp Business Portfolio tier from a single shop exhausting the 24h daily limit. WhatsApp tiers documented in §11. User confirms: hold "no cap" (and accept failure mode where any shop with >250-1000 guests has partial delivery), or adopt the 1000-cap recommendation.

2. **P0 — Promo source restriction.** This research recommends `send_broadcast` reject attaching promos with `source IN ('loyalty', 'recovery')` (Finding §6). SPEC doesn't address. Locking adds the predicate `AND source = 'owner_defined'` to the promo re-validation. User confirms.

3. **P0 — Lapsed strict-vs-loose.** SPEC line 52-53 says "last booking 60+ days ago, never cancelled the whole relationship (any non-cancelled booking exists)." Loose interpretation: any booking with status != 'pending' counts as "ever booked here". Strict interpretation: must have ≥1 confirmed/completed booking. This research recommends strict (Finding §1). User confirms.

4. **P1 — Template body opt-out language.** Meta's marketing-category rules require opt-out instructions in the template body (Finding §8). Recommended template body in §8 includes "Reply STOP to opt out of marketing messages." User confirms template wording before Wave 0 submission to Meta Business Manager.

5. **P1 — Status='delivering' UX after 6h.** If the `marketing_broadcast_v1` template approval takes >6h, broadcast rows stay at `delivering` for up to 24h while the worker auto-retries. BroadcastsScreen should surface a tooltip explaining the pending state. User confirms acceptable UX or wants a separate "pending_template" status.

6. **P1 — Subject char cap.** SPEC line 41 says "subject (push title), body ≤ 800 chars for push, ≤ 1024 for WhatsApp." SPEC doesn't lock a subject cap. This research uses 100 chars (push titles standard cap). User confirms 100 chars is right, or wants a different cap.

7. **P2 — Verify-before-plan: largest-shop audience query EXPLAIN.** Single live-DB sanity check (Finding §2):
   ```sql
   EXPLAIN (ANALYZE, BUFFERS)
   SELECT DISTINCT user_id, guest_profile_id
   FROM bookings
   WHERE shop_id = '<largest shop in prod>' AND status <> 'pending';
   ```
   If Execution Time > 500ms, plan a partial index. Otherwise no new indexes.

8. **P2 — `guest_profiles.accepts_marketing` UI exposure.** Phase 14 adds the column and reads it in the broadcast fan-out. The SPEC doesn't add any UI to let the guest see / flip it themselves. STOP-reply flip is OUT of Phase 14 scope (SPEC line 165). For v1, the only opt-out path is through the platform (manual support intervention) — document.

## Sources

Primary (HIGH confidence — codebase verification):
- [bookings status enum](../../../supabase/migrations/20260517010000_booking_schema.sql#L113-L117)
- [scheduled_notifications schema](../../../supabase/migrations/20260528120000_link_booking_guest_support.sql#L88-L95)
- [process-scheduled-notifications worker](../../../supabase/functions/process-scheduled-notifications/index.ts)
- [enqueue_booking_reminder helper signature](../../../supabase/migrations/20260605130400_enqueue_booking_reminder_helper.sql#L27-L31)
- [validate_and_apply_promo predicate](../../../supabase/migrations/20260606000300_validate_and_apply_promo_rpc.sql#L96-L117)
- [Phase 11 hardening template](../../../supabase/migrations/20260603001500_harden_dashboard_rpcs.sql)
- [promotions extended schema](../../../supabase/migrations/20260606000000_extend_promotions_for_phase13.sql)
- [tools_screen pattern](../../../lib/presentation/features/shops/dashboard/presentation/screens/tools_screen.dart)
- [_PromotionRow precedent](../../../lib/presentation/features/shops/dashboard/presentation/screens/promotions_screen.dart#L249-L335)
- [LoyaltyRuleScreen owner-form precedent](../../../lib/presentation/features/shops/dashboard/presentation/screens/loyalty_rule_screen.dart)
- [PromotionsRepository typed-exception pattern](../../../lib/presentation/features/shops/dashboard/data/repositories/promotions_repository.dart)
- [promotion_exceptions.dart hierarchy](../../../lib/presentation/features/shops/dashboard/data/exceptions/promotion_exceptions.dart)
- [Phase 12 RESEARCH worker-channel branching](../../12-autonomous-retention-engine/12-RESEARCH.md)
- [Phase 13 RESEARCH `promotions` schema notes](../../13-promo-engine-and-silent-loyalty/13-RESEARCH.md)

Secondary (MEDIUM confidence — official docs):
- [Meta WhatsApp template categorization](https://developers.facebook.com/documentation/business-messaging/whatsapp/templates/template-categorization)
- [Meta WhatsApp messaging limits + tiers](https://developers.facebook.com/docs/whatsapp/messaging-limits/)
- [Wati.io 2025 Meta approval rules update](https://support.wati.io/en/articles/12320234-understanding-meta-s-latest-updates-on-template-approval)
- [Infobip WhatsApp marketing compliance](https://www.infobip.com/docs/whatsapp/compliance/template-compliance)
- [Postgres `pg_try_advisory_xact_lock` docs](https://www.postgresql.org/docs/current/explicit-locking.html#ADVISORY-LOCKS)

Tertiary (LOW confidence — WebSearch only; competitor surfaces):
- [Uptail — WhatsApp Business 2026 messaging limits](https://www.uptail.ai/blog/how-many-messages-can-you-send-on-whatsapp-business-limits-explained-for-2026) `[CITED]`
- [Fresha help center](https://www.fresha.com/help-center) `[CITED]`
- [Booksy Smart Marketing](https://booksy.com/biz/smart-marketing) `[CITED]`
- [Vagaro automated marketing](https://www.vagaro.com/pro/features/automated-marketing) `[CITED]`

## RESEARCH COMPLETE
