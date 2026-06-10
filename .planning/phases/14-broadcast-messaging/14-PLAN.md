# Phase 14 PLAN — Owner Broadcast Messaging

## Goal

Give shop owners a single composable surface to broadcast one-off messages to their existing clients across the channels NanoEmbryo already runs: push for registered users, WhatsApp for guests, in-app notification for everyone. Phase 14 ADDS one new enum value (`marketing_broadcast`); ADDS one new column (`guest_profiles.accepts_marketing BOOLEAN NOT NULL DEFAULT TRUE`); CREATES one new immutable audit table (`broadcasts`) with SELECT-only RLS; CREATES two new owner-facing RPCs (`preview_broadcast_audience` and `send_broadcast`), both authz-first SECURITY DEFINER with HINT-coded raises mirroring Phase 11/12/13 hardening; EXTENDS the existing `PromotionsRepository` (NOT a new file) with three methods (`getBroadcasts`, `previewBroadcastAudience`, `sendBroadcast`) plus a HINT-driven `_classifyBroadcastError`; ADDS one new typed exception hierarchy (`BroadcastException`) in its own file; ADDS one new DTO (`BroadcastDTO`); ADDS one new Riverpod provider (`broadcastsProvider`); ADDS two new screens (`BroadcastsScreen` list + `CreateBroadcastScreen` compose form, the latter modelled on `LoyaltyRuleScreen`); ADDS one new card (#8) on `tools_screen.dart` routing to `BroadcastsScreen`; ADDS ~25 EN keys to `app_en.arb`. The notification worker is NOT touched — it already branches on `delivery_channel` (RESEARCH §3 — verified by grep against `process-scheduled-notifications/index.ts`). The WhatsApp `marketing_broadcast_v1` template is submitted to Meta in Wave 5 (out-of-band; existing 6h `WhatsAppTemplateNotFoundError` retry covers the approval window per Phase 12/13 precedent). Broadcasts are immutable — no INSERT/UPDATE/DELETE RLS policies on `broadcasts`; all mutations flow through `send_broadcast` (SECURITY DEFINER bypasses RLS). The 1000-recipient cap is server-enforced; `BROADCAST_CAP_EXCEEDED` is raised before any fan-out row is written. The 1-broadcast-per-shop-per-UTC-day rate limit is server-enforced via a `count(*)` against `date_trunc('day', now() AT TIME ZONE 'UTC')`. A `pg_try_advisory_xact_lock(hashtext(shop_id::text))` at the top of `send_broadcast` prevents same-second double-tap races. Recipient dedup uses `COALESCE(user_id::text, guest_profile_id::text)` per locked decision. The fan-out writes `scheduled_notifications` rows directly (does NOT call `enqueue_booking_reminder` — broadcasts have no booking_id, RESEARCH §2). Promo attachment validation rejects anything outside `source = 'owner_defined'` (silent loyalty / recovery codes cannot be broadcast — RESEARCH §6).

(SPEC §Outcome lines 3–47; SPEC §"Research-phase resolutions" lines 159–174; RESEARCH §1 lines 7–11 corrections, §4 lines 175–397 send_broadcast structure, §6 lines 416–449 promo predicate, §7 lines 451–463 dedup, §8 lines 465–494 template, §9 lines 496–547 immutability, §10 lines 549–632 preview RPC, §11 lines 634–662 size cap, §13 lines 682–725 list rows, §14 lines 727–812 exception hierarchy, §15 lines 814–826 hardening parity, §17 lines 844–854 enum add, §18 lines 856–871 accepts_marketing column.)

## Out of scope (locked)

Verbatim from SPEC §"Out of scope (locked)" lines 83–98:

- **Waitlist of any kind.** Dropped. NanoEmbryo has no booking queue model.
- **Scheduled broadcasts** ("send Tuesday at 10am"). v1 is send-now only.
- **Multi-step campaigns / drip sequences.** Single-shot only.
- **A/B testing.**
- **Edit / resend an existing broadcast.** Broadcasts are immutable; compose a new one.
- **Cancel a sent broadcast.** Once `send_broadcast` returns, rows are in the worker queue.
- **Per-client targeting** (pick John Doe and message just him). Targeted DMs are future scope.
- **Email / SMS-direct.** WhatsApp + push + in-app only.
- **Owner-facing delivery analytics** beyond `recipient_count`. No "X% opened" / "X% clicked" in v1.
- **Translation of the audience presets / form copy.** EN keys only (Phase 13.1 pattern).
- **Broadcast templates.** Owner writes free-form.
- **Rich content** (images, attachments, formatted text). Plain text body only.
- **Phase 13 promo code creation from inside broadcast flow.** Owner creates the code first via PromotionsScreen, then attaches.

### Out of scope (locked-in design decisions vs. SPEC drafts)

- **"No audience cap" position from SPEC §86** — OVERRIDDEN by the locked decision in the planner brief. A 1000-recipient cap is server-enforced (RESEARCH §11). Owners with >1000 clients can broadcast across multiple days.
- **`shops.timezone`-based rate limit** — DROPPED. Column doesn't exist in this codebase (RESEARCH §1). UTC day is the locked semantic; PDT-near-midnight edge case documented and accepted.
- **Reusing `enqueue_booking_reminder` for fan-out** — DROPPED. Helper requires `booking_id`; broadcasts have none (RESEARCH §2). Phase 14 writes `scheduled_notifications` rows directly inside a single `INSERT INTO ... SELECT FROM filtered` for atomicity (RESEARCH §4 lines 341–373, §16 lines 828–842).
- **Separate `pending_template` status** — DROPPED. The 4-status enum stays at `(pending, delivering, delivered, failed)`. The `delivering` UX includes a tooltip on rows older than 6h (RESEARCH §13 line 725; SPEC line 170).
- **Worker code changes for `marketing_broadcast`** — DROPPED. Worker branches purely on `delivery_channel`; zero hardcoded notification_type allowlist (RESEARCH §3 lines 11). Phase 14 ships zero edge-function diffs.
- **STOP-reply opt-out worker behavior** — DEFERRED to a follow-up phase. Phase 14 adds the `accepts_marketing` column and reads it; the worker flipping it on STOP reply is out of scope (SPEC line 200; RESEARCH §18 lines 868–869).
- **Explicit REVOKE on the `broadcasts` table for authenticated UPDATE/DELETE** — DROPPED. The deny-all default for unprivileged operations on an RLS-enabled table without matching policies achieves the same outcome (RESEARCH §9 lines 543–547). Pattern matches `client_notes` (Phase 12).
- **Guest opt-out UI** — DEFERRED. v1 is platform-mediated only (manual support intervention). Documented.
- **EXPLAIN ANALYZE gate against the largest prod shop** — DEFERRED. Dev DB is empty; the verification runs in Wave 5 UAT, not as a merge gate (SPEC line 172).

### Carry-over gaps explicitly NOT fixed

- **`notification_settings` per-category opt-out** — registered users opt out at the OS level (Phase 12 RESEARCH §3 line 109 carry-over). Phase 14 does not change that; `marketing_broadcast` rides the same `delivery_channel` branching.
- **Cross-identity duplicate broadcasts** — a guest who later registers under the same phone may receive two broadcasts during the v1 window (RESEARCH §7 lines 457–461). Acceptable; documented in PR.
- **Per-recipient frequency cap across senders** — Meta's ~2 marketing messages per recipient per day is enforced server-side by Meta. v1 does not surface failures to the owner; delivery failures stay in worker logs (RESEARCH §11 line 648 carry-over).

## Files touched

**NEW (SQL — strict timestamp order)**

- `supabase/migrations/20260607000000_add_marketing_broadcast_notification_type.sql`
- `supabase/migrations/20260607000100_add_accepts_marketing_to_guest_profiles.sql`
- `supabase/migrations/20260607000200_broadcasts_table.sql`
- `supabase/migrations/20260607000300_preview_broadcast_audience_rpc.sql`
- `supabase/migrations/20260607000400_send_broadcast_rpc.sql`

**NEW (Dart)**

- `lib/presentation/features/shops/dashboard/data/models/broadcast_dto.dart`
- `lib/presentation/features/shops/dashboard/data/exceptions/broadcast_exceptions.dart`
- `lib/presentation/features/shops/dashboard/providers/broadcasts_provider.dart`
- `lib/presentation/features/shops/dashboard/presentation/screens/broadcasts_screen.dart`
- `lib/presentation/features/shops/dashboard/presentation/screens/create_broadcast_screen.dart`
- `test/presentation/features/shops/dashboard/data/exceptions/broadcast_exceptions_test.dart`
- `test/presentation/features/shops/dashboard/data/repositories/broadcast_repository_test.dart`
- `test/presentation/features/shops/dashboard/presentation/screens/create_broadcast_screen_test.dart`
- `.planning/phases/14-broadcast-messaging/sql/14_smoke_tests.sql`

**EDIT (Dart)**

- `lib/presentation/features/shops/dashboard/data/repositories/promotions_repository.dart` — append three methods (`getBroadcasts`, `previewBroadcastAudience`, `sendBroadcast`) and one private `_classifyBroadcastError(PostgrestException)` mirroring the existing `_classifyPromotionError` helper. NO new repository file (SPEC line 129 + planner brief locked).
- `lib/presentation/features/shops/dashboard/presentation/screens/tools_screen.dart` — add card #8 ("Broadcasts") next to the existing Promotions / Loyalty cards. Icon + label + route push.
- `lib/i10n/app_en.arb` — add ~25 new keys (screen titles, audience labels, status labels, form labels + helper text, confirmation dialog copy, exception userMessages). EN only.

**EDIT (Meta — out-of-band, BEFORE merge per RESEARCH §8)**

- Submit `marketing_broadcast_v1` WhatsApp template to Meta for approval. Two variables: `{{1}}` = shop_name, `{{2}}` = body. Body text LOCKED: `"{{1}}: {{2}} Reply STOP to opt out of marketing messages."`. Marketing category. Worker's 6h `WhatsAppTemplateNotFoundError` defer ([process-scheduled-notifications/index.ts:124-128](../../../supabase/functions/process-scheduled-notifications/index.ts#L124-L128)) covers the approval window automatically — broadcasts can be sent immediately after merge; guest WhatsApp rows defer to the next 6h tick until approval lands. Push delivery to registered users is unaffected.

**NOT TOUCHED**

- `supabase/functions/process-scheduled-notifications/index.ts` — zero changes. Worker is notification-type-agnostic (RESEARCH §3 lines 11). The new `marketing_broadcast` rows flow through the existing push / whatsapp branches as soon as the migration adds the enum value.
- Any payment / webhook code path. Broadcasts have no payment or booking lifecycle entanglement.

## Pre-flight checks (BLOCKING — run before Wave 0)

These run once on the production DB. Any unexpected output blocks the PR from merging.

```sql
-- (1) Confirm notification_type is the enum we patched in Phase 12. The
--     Phase 14 ALTER TYPE ADD VALUE assumes enum, not TEXT.
SELECT t.typname, t.typcategory, n.nspname
FROM pg_type t JOIN pg_namespace n ON n.oid = t.typnamespace
WHERE t.typname = 'notification_type' AND n.nspname = 'public';
-- Expected: ONE row with typcategory = 'E' (enum). If absent or typcategory='S'
-- (TEXT domain), STOP and reconsider — Phase 12 RESEARCH §2 already proved this
-- as enum, but verify on prod before deploy.

-- (2) Confirm scheduled_notifications.booking_id is nullable. The fan-out
--     INSERT writes NULL there.
SELECT column_name, is_nullable, data_type FROM information_schema.columns
WHERE table_name = 'scheduled_notifications' AND column_name = 'booking_id';
-- Expected: is_nullable = 'YES'.

-- (3) Confirm guest_profiles.accepts_marketing does NOT already exist.
--     Phase 14 Wave 0 adds it; if pre-existing with a different default
--     or NOT NULL constraint, the IF NOT EXISTS migration is a silent no-op.
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'guest_profiles' AND column_name = 'accepts_marketing';
-- Expected: zero rows. If a row returns, audit the column shape against
-- the migration and reconcile before deploy.

-- (4) Confirm shops table has no `timezone` column. SPEC §161 locks this.
--     If a future phase adds it, Phase 14's UTC-day rate limit becomes a
--     refactor candidate — flag for Phase 15+.
SELECT column_name FROM information_schema.columns
WHERE table_name = 'shops' AND column_name = 'timezone';
-- Expected: zero rows.

-- (5) Confirm zero direct Dart callers of `broadcasts` table or new RPCs
--     (Phase 14 is greenfield — no prior callers should exist).
-- Run locally:
--   grep -rn "from('broadcasts')" lib/
--   grep -rn 'send_broadcast\|preview_broadcast_audience' lib/
-- Expected: zero hits before Wave 2.

-- (6) Verify Meta template submission status (out-of-band).
--     Open Meta Business Manager → Message Templates → search
--     'marketing_broadcast_v1'. Status should be at least Submitted.
--     If Pending or Approved, fine. If Rejected, fix copy before merge.
```

The pre-flight script is also pasted at the top of the smoke SQL file so the executor sees it before running anything against staging.

## Migration plan

Five new SQL migrations. Strict timestamp order. Every RPC follows the Phase 11 hardening template ([20260603001500_harden_dashboard_rpcs.sql](../../../supabase/migrations/20260603001500_harden_dashboard_rpcs.sql) lines 29–108) byte-for-byte: `LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp`, authz ownership gate FIRST, null-shape validation BEFORE side effects, `'not_found'` raises with `ERRCODE = '42501'`, `'invalid_*'` raises with `ERRCODE = '22023'` + `HINT = '...'`, `'rate_limited'` raises with `ERRCODE = '55P03'` + `HINT = '...'`, then `REVOKE ALL ON FUNCTION ... FROM PUBLIC`, `REVOKE ALL ON FUNCTION ... FROM authenticated` (defensive per Phase 13 hotfix learning), `GRANT EXECUTE ... TO authenticated`, and `COMMENT ON FUNCTION ... IS '... Big-O ... Phase 14.'`.

### 1. `20260607000000_add_marketing_broadcast_notification_type.sql`

One line. Phase 12 confirmed `notification_type` as an enum in prod. Idempotent.

```sql
-- Phase 14: extend notification_type enum with marketing_broadcast.
-- Worker code path is notification-type-agnostic (RESEARCH §3) — this
-- enum value alone unblocks marketing_broadcast rows from being inserted
-- into scheduled_notifications.

ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'marketing_broadcast';
```

No DO block, no defensive discovery — matches the Phase 12 / 13 pattern (RESEARCH §17).

### 2. `20260607000100_add_accepts_marketing_to_guest_profiles.sql`

Column add. DEFAULT TRUE means existing rows materialize the value on read; no UPDATE pass needed for backfill.

```sql
ALTER TABLE public.guest_profiles
  ADD COLUMN IF NOT EXISTS accepts_marketing BOOLEAN NOT NULL DEFAULT TRUE;

COMMENT ON COLUMN public.guest_profiles.accepts_marketing IS
  'Per-guest marketing opt-out flag. Defaults TRUE on first booking. Phase 14 reads this in send_broadcast / preview_broadcast_audience to exclude opted-out guests from fan-out. STOP-reply worker behavior is a follow-up phase (out of Phase 14 scope).';
```

### 3. `20260607000200_broadcasts_table.sql`

Immutable audit table. RLS-enabled with SELECT-only policy; no INSERT / UPDATE / DELETE policies (per RESEARCH §9 — absence is deny-all for `authenticated`). All mutations flow through `send_broadcast` SECURITY DEFINER.

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
  CONSTRAINT broadcasts_audience_param_check CHECK (
    (audience_type = 'by_service' AND audience_param IS NOT NULL) OR
    (audience_type <> 'by_service' AND audience_param IS NULL)
  )
);

CREATE INDEX IF NOT EXISTS broadcasts_shop_created_idx
  ON public.broadcasts (shop_id, created_at DESC);

ALTER TABLE public.broadcasts ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'broadcasts_owner_select') THEN
    CREATE POLICY broadcasts_owner_select ON public.broadcasts
      FOR SELECT TO authenticated
      USING (EXISTS (SELECT 1 FROM public.shops s
                     WHERE s.id = broadcasts.shop_id AND s.user_id = auth.uid()));
  END IF;
END $$;

-- Deliberately NO INSERT / UPDATE / DELETE policies. Absence on an
-- RLS-enabled table = deny-all for `authenticated`. All mutations route
-- through send_broadcast (SECURITY DEFINER, bypasses RLS).
-- Pattern verified against client_notes (Phase 12).

COMMENT ON TABLE public.broadcasts IS
  'Phase 14: append-only audit of owner-sent broadcasts. One row per send. Mutations flow through send_broadcast SECURITY DEFINER only — direct authenticated INSERT / UPDATE / DELETE is RLS-denied by policy absence. Immutable once written.';
COMMENT ON COLUMN public.broadcasts.status IS
  'pending (pre-send), delivering (fan-out in flight / template-pending), delivered (fan-out complete), failed (RPC raise before INSERT — actual fan-out failures roll back). Owner UI surfaces tooltip on delivering rows >6h old explaining WhatsApp template approval.';
COMMENT ON COLUMN public.broadcasts.recipient_count IS
  'Set by send_broadcast after the fan-out INSERT...SELECT returns its row count. Reflects actual scheduled_notifications rows written (post guest opt-out filtering, post-dedup), not the raw audience size.';
```

### 4. `20260607000300_preview_broadcast_audience_rpc.sql`

Owner-only read-side count for the form's live preview. STABLE; safe to call in form-edit hot path. Same CTEs as `send_broadcast` minus the writes — including the `accepts_marketing` gate so the preview matches the eventual fan-out count.

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
  -- NULL shape (no side effects; precedes authz).
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
  IF p_audience_type <> 'by_service' AND p_audience_param IS NOT NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'AUDIENCE_PARAM_FORBIDDEN';
  END IF;

  -- Authz FIRST. Sanitized 'not_found' for cross-shop calls.
  IF NOT EXISTS (SELECT 1 FROM public.shops
                 WHERE id = p_shop_id AND user_id = auth.uid()) THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  WITH client_identities AS (
    SELECT b.user_id,
           b.guest_profile_id,
           COALESCE(b.user_id::text, b.guest_profile_id::text) AS dedup_key,
           MAX(b.start_time) FILTER (WHERE b.status <> 'pending') AS last_at
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
REVOKE ALL ON FUNCTION public.preview_broadcast_audience(UUID, TEXT, UUID) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.preview_broadcast_audience(UUID, TEXT, UUID) TO authenticated;

COMMENT ON FUNCTION public.preview_broadcast_audience(UUID, TEXT, UUID) IS
  'Phase 14 owner-only read-side audience count. Used by CreateBroadcastScreen live preview. Same CTEs as send_broadcast minus inserts. accepts_marketing gate applied so the preview matches the eventual fan-out count. Authz first; sanitized not_found for non-owners. O(shop_client_count). Phase 14.';
```

### 5. `20260607000400_send_broadcast_rpc.sql`

The hot path. Eleven discrete steps in body order: (1) advisory lock; (2) NULL shape; (3) length caps (subject ≤ 100, body ≤ 800); (4) audience-type whitelist + audience_param XOR; (5) authz; (6) UTC-day rate limit; (7) promo validation (mirrors `validate_and_apply_promo`'s manual-entry branch, including `source = 'owner_defined'`); (8) shop name fetch; (9) `broadcasts` row insert with status='delivering'; (10) audience CTE → filtered CTE (accepts_marketing gate) → 1000-cap check → `INSERT INTO scheduled_notifications ... SELECT` with CASE expression splitting push vs whatsapp shape; (11) UPDATE `broadcasts` status='delivered', delivered_at=now(), recipient_count=v_recipient_cnt. The whole RPC runs in a single implicit transaction — failure anywhere rolls back the `broadcasts` row too.

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
  v_today_count    INT;
  v_audience_size  INT;
BEGIN
  -- 1. Advisory lock — same-second double-tap guard. xact-scoped; auto-released.
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

  -- 3. Length caps. Subject = push title (100 chars). Body floor of
  --    push (800) vs WhatsApp (1024) — enforce 800.
  IF char_length(p_subject) > 100 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'SUBJECT_TOO_LONG';
  END IF;
  IF char_length(p_body) > 800 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'BODY_TOO_LONG';
  END IF;

  -- 4. Audience-type whitelist + XOR.
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

  -- 5. Authz. Sanitized 'not_found' for cross-shop access.
  IF NOT EXISTS (SELECT 1 FROM public.shops
                 WHERE id = p_shop_id AND user_id = auth.uid()) THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  -- 6. UTC-day rate limit. Long-term guard; advisory lock covers
  --    same-second races. Counts rows in the current UTC day.
  SELECT count(*) INTO v_today_count
  FROM public.broadcasts
  WHERE shop_id = p_shop_id
    AND created_at >= date_trunc('day', now() AT TIME ZONE 'UTC')
    AND created_at <  date_trunc('day', now() AT TIME ZONE 'UTC') + INTERVAL '1 day';
  IF v_today_count > 0 THEN
    RAISE EXCEPTION 'rate_limited'
      USING ERRCODE = '55P03', HINT = 'BROADCAST_DAILY_LIMIT';
  END IF;

  -- 7. Promo re-validation. Predicate mirrors validate_and_apply_promo's
  --    manual-entry branch (RESEARCH §6). Adds source='owner_defined' to
  --    block silent loyalty/recovery codes (RESEARCH §6 lines 441-444).
  IF p_promotion_id IS NOT NULL THEN
    IF NOT EXISTS (
      SELECT 1 FROM public.promotions
      WHERE id = p_promotion_id
        AND shop_id = p_shop_id
        AND archived_at IS NULL
        AND is_active = TRUE
        AND (valid_to IS NULL OR valid_to > now())
        AND source = 'owner_defined'
    ) THEN
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

  -- 10a. Audience size pre-check against 1000 cap. We compute the
  --      filtered count BEFORE the fan-out INSERT so the cap raises a
  --      clean BROADCAST_CAP_EXCEEDED (with the broadcasts row rolled
  --      back by the implicit transaction) rather than a partial insert.
  WITH client_identities AS (
    SELECT b.user_id, b.guest_profile_id,
           COALESCE(b.user_id::text, b.guest_profile_id::text) AS dedup_key,
           MAX(b.start_time) FILTER (WHERE b.status <> 'pending') AS last_at
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
  SELECT count(*) INTO v_audience_size
  FROM audience a
  LEFT JOIN public.guest_profiles gp ON gp.id = a.guest_profile_id
  WHERE a.user_id IS NOT NULL OR COALESCE(gp.accepts_marketing, TRUE) = TRUE;

  IF v_audience_size > 1000 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'BROADCAST_CAP_EXCEEDED';
  END IF;

  -- 10b. Fan-out. Single INSERT...SELECT for atomicity. CASE expression
  --      splits push vs whatsapp shape. Phone for whatsapp rows pulled
  --      directly from guest_profiles (no booking_id available).
  WITH client_identities AS (
    SELECT b.user_id, b.guest_profile_id,
           COALESCE(b.user_id::text, b.guest_profile_id::text) AS dedup_key,
           MAX(b.start_time) FILTER (WHERE b.status <> 'pending') AS last_at
    FROM public.bookings b
    WHERE b.shop_id = p_shop_id AND b.status <> 'pending'
    GROUP BY b.user_id, b.guest_profile_id
  ),
  audience AS (
    SELECT ci.user_id, ci.guest_profile_id, ci.dedup_key
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
  ),
  filtered AS (
    SELECT a.user_id, a.guest_profile_id
    FROM audience a
    LEFT JOIN public.guest_profiles gp ON gp.id = a.guest_profile_id
    WHERE a.user_id IS NOT NULL OR COALESCE(gp.accepts_marketing, TRUE) = TRUE
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
      NULL,
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

  -- 11. Flip broadcasts row to delivered.
  UPDATE public.broadcasts
  SET status = 'delivered',
      delivered_at = now(),
      recipient_count = v_recipient_cnt
  WHERE id = v_broadcast_id;

  RETURN QUERY SELECT v_broadcast_id, v_recipient_cnt;
END;
$function$;

REVOKE ALL ON FUNCTION public.send_broadcast(UUID, TEXT, TEXT, TEXT, UUID, UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.send_broadcast(UUID, TEXT, TEXT, TEXT, UUID, UUID) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.send_broadcast(UUID, TEXT, TEXT, TEXT, UUID, UUID) TO authenticated;

COMMENT ON FUNCTION public.send_broadcast(UUID, TEXT, TEXT, TEXT, UUID, UUID) IS
  'Phase 14 owner-only broadcast send. Advisory lock + UTC-day rate limit + 1000-recipient cap + promo (owner_defined-only) re-validation. Resolves audience, applies accepts_marketing gate, fans out one scheduled_notifications row per recipient atomically. Returns (broadcast_id, recipient_count). O(shop_client_count). Phase 14.';
```

## Client architecture

### `BroadcastDTO`

Plain model. JSON shape matches the `broadcasts` table columns 1:1 + a `BroadcastAudience` enum + a `BroadcastStatus` enum. Locale-neutral (no Intl formatting inside the DTO; that's the screen's job).

```dart
// lib/presentation/features/shops/dashboard/data/models/broadcast_dto.dart
enum BroadcastAudience { allClients, recent, lapsed, byService }
enum BroadcastStatus { pending, delivering, delivered, failed }

class BroadcastDTO {
  final String id;
  final String shopId;
  final String subject;
  final String body;
  final BroadcastAudience audienceType;
  final String? audienceParam;     // slot_id when by_service
  final String? promotionId;
  final String createdByUserId;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final int recipientCount;
  final BroadcastStatus status;

  const BroadcastDTO({...});

  factory BroadcastDTO.fromJson(Map<String, dynamic> json) => ...;
  Map<String, dynamic> toJson() => ...;
}
```

`BroadcastAudience` and `BroadcastStatus` carry `fromString` / `name` round-trip helpers matching the SQL CHECK strings exactly.

### `BroadcastException` hierarchy

Mirrors `PromotionException`'s shape (same `code` + `userMessage` pattern). Six subtypes from RESEARCH §14 lines 740–786:

```dart
// lib/presentation/features/shops/dashboard/data/exceptions/broadcast_exceptions.dart
class BroadcastException implements Exception {
  final String message;
  final String code;
  final String userMessage;
  BroadcastException(this.message, {required this.code, required this.userMessage});
  @override String toString() => 'BroadcastException($code): $message';
}

class BroadcastRateLimitException extends BroadcastException { ... }
class BroadcastInFlightException extends BroadcastException { ... }
class BroadcastInvalidAudienceException extends BroadcastException { ... }
class BroadcastPromoInvalidException extends BroadcastException { ... }
class BroadcastCapExceededException extends BroadcastException { ... }
class BroadcastSaveFailedException extends BroadcastException { ... }
```

`userMessage` strings come from `app_en.arb` (added in Wave 3) via a lookup the screen does — the exception itself carries an EN fallback to keep the DTO testable in isolation, matching `PromotionException` precedent.

### `_classifyBroadcastError` in `PromotionsRepository`

Added next to the existing `_classifyPromotionError`. HINT-driven, no string matching on `e.message`. Maps:

| Postgres `errcode` | HINT | Dart exception |
|--------------------|------|----------------|
| 55P03 | BROADCAST_DAILY_LIMIT | `BroadcastRateLimitException` |
| 55P03 | BROADCAST_IN_FLIGHT | `BroadcastInFlightException` |
| 22023 | AUDIENCE_TYPE_INVALID / AUDIENCE_PARAM_REQUIRED / AUDIENCE_PARAM_FORBIDDEN | `BroadcastInvalidAudienceException` |
| 22023 | PROMO_NOT_VALID | `BroadcastPromoInvalidException` |
| 22023 | BROADCAST_CAP_EXCEEDED | `BroadcastCapExceededException` |
| 22023 | SUBJECT_TOO_LONG / BODY_TOO_LONG / REQUIRED_FIELD_MISSING | `BroadcastSaveFailedException` |
| 42501 | (any — sanitized) | `BroadcastSaveFailedException` |
| (any other) | (any) | `BroadcastSaveFailedException` |

### Three new repository methods

Extend `PromotionsRepository` in place (SPEC line 129; planner brief locked):

```dart
// (additions to lib/.../data/repositories/promotions_repository.dart)

Future<List<BroadcastDTO>> getBroadcasts(String shopId) async {
  try {
    final rows = await _client
      .from('broadcasts')
      .select()
      .eq('shop_id', shopId)
      .order('created_at', ascending: false);
    return (rows as List).map((r) => BroadcastDTO.fromJson(r)).toList();
  } on PostgrestException catch (e) {
    AppLogger.error('getBroadcasts failed', e, error_code: e.code);
    throw _classifyBroadcastError(e);
  }
}

Future<int> previewBroadcastAudience({
  required String shopId,
  required BroadcastAudience audienceType,
  String? audienceParam,
}) async {
  try {
    final res = await _client.rpc('preview_broadcast_audience', params: {
      'p_shop_id': shopId,
      'p_audience_type': audienceType.name,
      'p_audience_param': audienceParam,
    });
    return (res as int?) ?? 0;
  } on PostgrestException catch (e) {
    AppLogger.error('previewBroadcastAudience failed', e,
      shop_id: shopId, audience_type: audienceType.name, error_code: e.code);
    throw _classifyBroadcastError(e);
  }
}

Future<({String broadcastId, int recipientCount})> sendBroadcast({
  required String shopId,
  required String subject,
  required String body,
  required BroadcastAudience audienceType,
  String? audienceParam,
  String? promotionId,
}) async {
  try {
    final res = await _client.rpc('send_broadcast', params: {
      'p_shop_id': shopId,
      'p_subject': subject,
      'p_body': body,
      'p_audience_type': audienceType.name,
      'p_audience_param': audienceParam,
      'p_promotion_id': promotionId,
    });
    // RPC returns a one-row TABLE — Supabase returns a List<Map>.
    final row = (res as List).first as Map<String, dynamic>;
    return (
      broadcastId: row['broadcast_id'] as String,
      recipientCount: row['recipient_count'] as int,
    );
  } on PostgrestException catch (e) {
    AppLogger.error('sendBroadcast failed', e,
      shop_id: shopId, audience_type: audienceType.name, error_code: e.code);
    throw _classifyBroadcastError(e);
  }
}
```

Each method uses the existing `AppLogger` fields per SPEC line 142 (`shop_id`, `audience_type`, `error_code`). `recipient_count` is logged on success in the calling screen — not in the repo, to keep the repo independent of UI surfaces.

### Provider

```dart
// lib/.../providers/broadcasts_provider.dart
@riverpod
Future<List<BroadcastDTO>> broadcasts(BroadcastsRef ref, String shopId) async {
  return ref.read(promotionsRepositoryProvider).getBroadcasts(shopId);
}
```

`FutureProvider.family<List<BroadcastDTO>, String>` keyed by `shopId`. Invalidated after a successful `sendBroadcast` (the create screen calls `ref.invalidate(broadcastsProvider(shopId))` before popping).

### `BroadcastsScreen`

List view. Mirrors `PromotionsScreen` skeleton. Two states:

| State | Body |
|-------|------|
| Loading (`AsyncLoading`) | Centred CircularProgressIndicator. |
| Error (`AsyncError`) | Empty state with reload button. Error message via `BroadcastException.userMessage` if applicable, else generic. |
| Data, empty | Empty state: "No broadcasts yet. Tap + to send your first." with a hint about the 1/day cap and 1000-recipient ceiling. |
| Data, non-empty | `ListView.separated` of `_BroadcastRow` widgets. Pull-to-refresh invalidates the provider. |

FAB → push `CreateBroadcastScreen`. After it pops with a `({String id, int count})` result, show a SnackBar: `"Sent to N people."`.

`_BroadcastRow` (RESEARCH §13 lines 689–725) — three regions:
- Leading: status badge (color from `_statusColor`, text from `_statusLabel`).
- Center: subject (max lines 1, ellipsis) + first 80 chars of body (max lines 2).
- Trailing: `recipientCount` (with people icon) + relative time (`timeago` package — existing dependency).

Tap row → push a read-only detail dialog (full subject + body + audience + promo + delivered_at + recipient_count + status). No edit. No resend.

Status badge color helper:

| Status | Material color |
|--------|----------------|
| `pending` | `colorScheme.outline` |
| `delivering` | `colorScheme.tertiary` |
| `delivered` | `colorScheme.primary` |
| `failed` | `colorScheme.error` |

Tooltip on `delivering` rows older than 6h: `loc.broadcastDeliveringTooltip` — "WhatsApp template approval is pending. This usually resolves within 24h." (RESEARCH §13 line 725, §8 line 492; SPEC line 170).

### `CreateBroadcastScreen`

LoyaltyRuleScreen is the precedent — explicit Save, dirty-check, error toasts. Form fields (top to bottom):

1. **Subject** — `TextField`, maxLength 100, counter. Validator: non-empty after trim.
2. **Body** — `TextField`, multi-line (minLines 4, maxLines 10), maxLength 800, counter. Validator: non-empty after trim.
3. **Audience type** — `SegmentedButton<BroadcastAudience>` with four segments. Default `allClients`.
4. **Audience param (service)** — `DropdownButtonFormField<String>` of the shop's active appointment slots. Shown ONLY when `audienceType == byService`. Populated by reading `appointmentSlotsProvider(shopId)` (existing). Validator: non-null when shown.
5. **Promo code (optional)** — `DropdownButtonFormField<String?>` populated by `promotionsRepository.getPromotions(shopId, activeOnly: true)` filtered client-side to `source == 'owner_defined'` and `archived_at == null`. First entry: "None" (null). Helper text below: "Only your own promo codes can be attached. Loyalty and recovery codes aren't shown."
6. **Recipient preview row** — read-only. Calls `previewBroadcastAudience` with debounce (500ms after the last edit to audience type/param). Renders `"This will send to N people."` with a `CircularProgressIndicator` while in-flight, and the cap warning when N > 1000: `"Audience exceeds the 1000-recipient cap. Try a narrower preset."`. Disables Send when the cap is exceeded.
7. **Send button** — `FilledButton`. Disabled until subject + body non-empty AND audience param valid AND preview ≤ 1000.

Tap Send → `AlertDialog` confirmation:
- Title: "Send broadcast?"
- Body: `"Send to {N} {audienceLabel} clients? This cannot be undone."` + optional `"With code {CODE}."` when promo attached.
- Buttons: Cancel + Send.

On confirm: disable button, show inline progress. Call `sendBroadcast`. On success: invalidate `broadcastsProvider(shopId)`, pop with the result. On `BroadcastException`: show toast with `e.userMessage`. On other: show generic save-failed toast and remain on screen.

State management: a `StateNotifier` (`CreateBroadcastController`) holding form state + preview state + sending state. Provider scoped to screen lifetime via `autoDispose`. Dirty check via comparing the current state hash to the initial empty hash — back-button intercept asks "Discard?" when dirty.

### `tools_screen.dart` card

Add card #8 next to existing Promotions / LoyaltyRule cards. The Tools tab uses a `GridView.count` (existing) with each card being a `_ToolsCard(icon, label, onTap)`. Phase 14 adds:

```dart
_ToolsCard(
  icon: Icons.campaign_outlined,
  label: AppLocalizations.of(context)!.broadcastsTitle,
  onTap: () => context.push('/dashboard/${shop.id}/broadcasts'),
),
```

GoRouter route added:

```dart
GoRoute(
  path: 'broadcasts',
  builder: (context, state) => BroadcastsScreen(shopId: state.pathParameters['shopId']!),
  routes: [
    GoRoute(
      path: 'compose',
      builder: (context, state) => CreateBroadcastScreen(shopId: state.pathParameters['shopId']!),
    ),
  ],
),
```

(Exact router file path the executor confirms via grep — `app_router.dart` per project layout.)

## i18n keys (Wave 3)

Add to `lib/i10n/app_en.arb` only. EN only. Final inventory (25 keys):

| Key | Value (EN) |
|-----|------------|
| `broadcastsTitle` | "Broadcasts" |
| `broadcastsToolsCardLabel` | "Broadcasts" |
| `broadcastsEmptyTitle` | "No broadcasts yet" |
| `broadcastsEmptyBody` | "Tap + to send your first. You can broadcast once per day to up to 1000 clients." |
| `broadcastsFabTooltip` | "New broadcast" |
| `broadcastCreateTitle` | "New broadcast" |
| `broadcastSubjectLabel` | "Subject" |
| `broadcastSubjectHelper` | "Shown as the push notification title." |
| `broadcastBodyLabel` | "Message" |
| `broadcastBodyHelper` | "Plain text only. WhatsApp recipients also see your shop name and an opt-out line." |
| `broadcastAudienceLabel` | "Audience" |
| `broadcastAudienceAllClients` | "All clients" |
| `broadcastAudienceRecent` | "Recent (30 days)" |
| `broadcastAudienceLapsed` | "Lapsed (60+ days)" |
| `broadcastAudienceByService` | "By service" |
| `broadcastServiceLabel` | "Service" |
| `broadcastPromoLabel` | "Attach a promo code (optional)" |
| `broadcastPromoHelper` | "Only your own promo codes can be attached. Loyalty and recovery codes aren't shown." |
| `broadcastPreviewCount` | "This will send to {count} people." |
| `broadcastPreviewCapWarning` | "Audience exceeds the 1000-recipient cap. Try a narrower preset." |
| `broadcastSendButton` | "Send" |
| `broadcastConfirmTitle` | "Send broadcast?" |
| `broadcastConfirmBody` | "Send to {count} {audience} clients? This cannot be undone." |
| `broadcastConfirmBodyWithPromo` | "Send to {count} {audience} clients with code {code}? This cannot be undone." |
| `broadcastSentToast` | "Sent to {count} people." |
| `broadcastStatusPending` | "Pending" |
| `broadcastStatusDelivering` | "Sending" |
| `broadcastStatusDelivered` | "Sent" |
| `broadcastStatusFailed` | "Failed" |
| `broadcastDeliveringTooltip` | "WhatsApp template approval is pending. This usually resolves within 24h." |
| `broadcastRateLimitMessage` | "You've already sent a broadcast today. Try again tomorrow." |
| `broadcastInFlightMessage` | "Another broadcast is being processed. Please wait a moment." |
| `broadcastInvalidAudienceMessage` | "Please pick a valid audience and (if 'By service') a service." |
| `broadcastPromoInvalidMessage` | "This code is no longer valid. Pick another or remove the code." |
| `broadcastCapExceededMessage` | "This audience is larger than the 1000-recipient cap. Try a narrower audience." |
| `broadcastSaveFailedMessage` | "Could not send broadcast. Please try again." |

(Final tally is 32 keys — overshoot tolerated; "~25" in the prompt is approximate.)

## Tasks

Atomic. Each touches ≤ 3 files unless explicitly justified inline. Each maps to ≥ 1 acceptance test in the Verification matrix. Estimates in minutes.

### Wave 0 — Schema + Meta submission (pre-flight gated)

**Task 0.0 — Run pre-flight checks**
- File(s): n/a (operational, staging then prod).
- Description: Execute the six pre-flight SELECTs against staging then prod. Capture output in PR description. **BLOCK migration deployment if check (3) returns a pre-existing `accepts_marketing` row with a different shape, or check (1) reports non-enum `notification_type`.**
- Acceptance: All six checks return expected shape. Outputs pasted into PR description.
- Estimate: 10

**Task 0.1 — Submit `marketing_broadcast_v1` to Meta**
- File(s): n/a (operational; Meta Business Manager).
- Description: Submit the marketing-category WhatsApp template. Variables: `{{1}}` = shop_name (literal example: "Curls and Co"), `{{2}}` = body (literal example: "20% off all services this Friday"). Body LOCKED: `"{{1}}: {{2}} Reply STOP to opt out of marketing messages."`. Category: MARKETING. Language: en. Submission UID + screenshot pasted in PR description per Phase 12/13 precedent.
- Acceptance: Status = Submitted (or higher) in Meta dashboard. Approval is NOT a merge gate — worker's 6h deferral covers the gap.
- Rollback: n/a (template deletion in Meta).
- Estimate: 15

**Task 0.2 — Add `marketing_broadcast` to `notification_type`**
- File(s): `supabase/migrations/20260607000000_add_marketing_broadcast_notification_type.sql` (NEW)
- Description: Per Migration Plan §1. One-line idempotent ALTER TYPE.
- Acceptance: `SELECT unnest(enum_range(NULL::notification_type))` returns a row for `marketing_broadcast`. Re-running the migration is a no-op (verified by `IF NOT EXISTS`).
- Rollback: Enum value removal in Postgres requires table swap. NOT supported; revert by leaving the value present and dropping Phase 14 callers. Documented in PR.
- Estimate: 5

**Task 0.3 — Add `accepts_marketing` column to `guest_profiles`**
- File(s): `supabase/migrations/20260607000100_add_accepts_marketing_to_guest_profiles.sql` (NEW)
- Description: Per Migration Plan §2. `ADD COLUMN IF NOT EXISTS` with DEFAULT TRUE NOT NULL. No backfill needed.
- Acceptance: `\d public.guest_profiles` shows `accepts_marketing` BOOLEAN NOT NULL DEFAULT true. Existing rows return TRUE when selected. Re-run is no-op.
- Rollback: `ALTER TABLE public.guest_profiles DROP COLUMN accepts_marketing;`. Safe — no production read depended on it before Phase 14.
- Estimate: 10

**Task 0.4 — Create `broadcasts` table + RLS**
- File(s): `supabase/migrations/20260607000200_broadcasts_table.sql` (NEW)
- Description: Per Migration Plan §3. Table + index on `(shop_id, created_at DESC)` + RLS-enabled + SELECT-only owner policy. NO INSERT / UPDATE / DELETE policies. Two `CHECK` constraints (audience_type whitelist + audience_param XOR).
- Acceptance: `\d public.broadcasts` shows all 12 columns + the two CHECKs. `SELECT polname FROM pg_policies WHERE tablename='broadcasts'` returns exactly 1 row (`broadcasts_owner_select`). Smoke §K (RLS owner-only SELECT) and §L (immutability) both pass.
- Rollback: `DROP TABLE public.broadcasts CASCADE`. Safe.
- Estimate: 25

### Wave 1 — Server logic (depends on Wave 0)

**Task 1.1 — Create `preview_broadcast_audience` RPC**
- File(s): `supabase/migrations/20260607000300_preview_broadcast_audience_rpc.sql` (NEW)
- Description: Per Migration Plan §4. STABLE function; authz first; same CTEs as send_broadcast minus inserts; accepts_marketing gate applied so preview matches eventual fan-out count. HINT codes: `REQUIRED_FIELD_MISSING`, `AUDIENCE_TYPE_INVALID`, `AUDIENCE_PARAM_REQUIRED`, `AUDIENCE_PARAM_FORBIDDEN`.
- Acceptance: Smoke §A (recipient_count > 0 for shop with bookings) and §B (all 4 audience types resolve correctly) both pass. Non-owner caller raises `42501 not_found`. `SELECT preview_broadcast_audience(shop_a, 'lapsed', NULL)` against a fresh shop returns 0.
- Rollback: `DROP FUNCTION public.preview_broadcast_audience(UUID, TEXT, UUID)`.
- Estimate: 35

**Task 1.2 — Create `send_broadcast` RPC**
- File(s): `supabase/migrations/20260607000400_send_broadcast_rpc.sql` (NEW)
- Description: Per Migration Plan §5. Eleven steps documented inline. Advisory lock at the top. UTC-day rate limit. 1000-recipient cap raised BEFORE fan-out so the broadcasts row rolls back cleanly. Single `INSERT INTO scheduled_notifications ... SELECT FROM filtered` for atomic fan-out. HINT codes: `BROADCAST_IN_FLIGHT`, `BROADCAST_DAILY_LIMIT`, `BROADCAST_CAP_EXCEEDED`, `REQUIRED_FIELD_MISSING`, `SUBJECT_TOO_LONG`, `BODY_TOO_LONG`, `AUDIENCE_TYPE_INVALID`, `AUDIENCE_PARAM_REQUIRED`, `AUDIENCE_PARAM_FORBIDDEN`, `PROMO_NOT_VALID`.
- Acceptance: Smoke §C (promo source restriction), §D (promo expired/archived rejection), §E (happy path — broadcasts row + scheduled_notifications rows), §F (UTC-day rate limit), §G (advisory lock), §H (1000-cap), §I (dedup on COALESCE identity), §J (accepts_marketing=FALSE excluded) all pass. `flutter test test/.../broadcast_repository_test.dart` HINT classifier cases pass.
- Rollback: `DROP FUNCTION public.send_broadcast(UUID, TEXT, TEXT, TEXT, UUID, UUID)`.
- Estimate: 85

### Wave 2 — Client surface (depends on Wave 1)

**Task 2.1 — Create `BroadcastDTO` + `BroadcastException` hierarchy**
- File(s): `lib/.../data/models/broadcast_dto.dart` (NEW), `lib/.../data/exceptions/broadcast_exceptions.dart` (NEW)
- Description: DTO with `BroadcastAudience` + `BroadcastStatus` enums and `fromString`/`name` round-trip helpers. Exception hierarchy with six subtypes per RESEARCH §14 lines 740–786. Each exception carries an EN fallback `userMessage` (the screen swaps to `app_en.arb` lookup, but the fallback keeps tests independent).
- Acceptance: `flutter analyze` clean. `flutter test test/.../broadcast_exceptions_test.dart` cases for each subtype (`code` + `userMessage` assertions) pass.
- Rollback: Delete both files.
- Estimate: 25

**Task 2.2 — Extend `PromotionsRepository` with three broadcast methods + classifier**
- File(s): `lib/.../data/repositories/promotions_repository.dart` (EDIT)
- Description: Append `getBroadcasts`, `previewBroadcastAudience`, `sendBroadcast` methods and `_classifyBroadcastError` private helper. HINT-driven mapping per the table in §"Client architecture > _classifyBroadcastError in PromotionsRepository" above. AppLogger fields on every method call (`shop_id`, `audience_type`, `error_code`).
- Acceptance: `flutter analyze` clean. `flutter test test/.../broadcast_repository_test.dart` table tests for all eight HINT → exception mappings (including default-to-`BroadcastSaveFailedException`) pass. Existing `PromotionsRepository` callers still compile (no signature changes on existing methods).
- Rollback: Revert the file diff.
- Estimate: 45

**Task 2.3 — Create `broadcastsProvider` + `BroadcastsScreen`**
- File(s): `lib/.../providers/broadcasts_provider.dart` (NEW), `lib/.../presentation/screens/broadcasts_screen.dart` (NEW)
- Description: `FutureProvider.family<List<BroadcastDTO>, String>` over `getBroadcasts`. `BroadcastsScreen` with the four states described in §"Client architecture > BroadcastsScreen" above. `_BroadcastRow` mirrors `_PromotionRow` (RESEARCH §13). Status badge + tooltip on delivering > 6h. FAB → push `CreateBroadcastScreen`. Tap row → read-only detail dialog (subject + body + audience + promo + delivered_at + recipient_count + status). Pull-to-refresh invalidates the provider.
- Acceptance: `flutter analyze` clean. Widget test renders empty / loading / data / error states correctly. Tap FAB pushes the create screen (mock GoRouter navigation). Delivering-row older than 6h shows the tooltip.
- Rollback: Delete both files and the i18n keys.
- Estimate: 65

**Task 2.4 — Create `CreateBroadcastScreen` + state controller**
- File(s): `lib/.../presentation/screens/create_broadcast_screen.dart` (NEW)
- Description: Form per §"Client architecture > CreateBroadcastScreen" above. `StateNotifier` for form state + preview debounce (500ms) + sending state. Service dropdown sourced from `appointmentSlotsProvider(shopId)`. Promo dropdown sourced from `promotionsRepository.getPromotions(shopId, activeOnly: true)` filtered to `source == 'owner_defined' && archived_at == null` client-side. Recipient preview row with cap warning. Confirmation dialog on Send. On success: invalidate `broadcastsProvider(shopId)`, pop with `(broadcastId, recipientCount)`. On `BroadcastException`: toast with `e.userMessage`. Back-button intercepts when dirty.
- Acceptance: `flutter analyze` clean. Widget test: subject + body validation; segmented audience picker; service dropdown shown ONLY when by_service; promo dropdown excludes archived + non-owner_defined; preview debounce calls RPC once per audience change; Send disabled until valid; confirmation dialog shows correct counts + audience label; success path pops; rate-limit toast on `BroadcastRateLimitException`; cap toast on `BroadcastCapExceededException`. Smoke §H proves the cap RPC-side; this widget test covers the client-side rendering of the warning.
- Rollback: Delete the file.
- Estimate: 90

**Task 2.5 — Add Tools tab card #8 + GoRouter route**
- File(s): `lib/.../presentation/screens/tools_screen.dart` (EDIT), `lib/app/routing/app_router.dart` (EDIT)
- Description: One new `_ToolsCard` with `Icons.campaign_outlined` + `broadcastsToolsCardLabel`. GoRouter sub-routes under `/dashboard/:shopId/`: `broadcasts` → `BroadcastsScreen`, `broadcasts/compose` → `CreateBroadcastScreen`. Confirm via grep that the router file path matches the project layout before editing.
- Acceptance: `flutter analyze` clean. Tools tab renders 8 cards in order. Tapping Broadcasts navigates to `BroadcastsScreen`. Tapping the FAB inside navigates to `CreateBroadcastScreen`. Existing 7 cards still navigate to their existing destinations (no regression).
- Rollback: Revert both file diffs.
- Estimate: 20

### Wave 3 — i18n (depends on Wave 2 wiring)

**Task 3.1 — Add EN keys to `app_en.arb`**
- File(s): `lib/i10n/app_en.arb` (EDIT)
- Description: Add the 32 keys listed in §"i18n keys (Wave 3)" above. Plural-aware on `broadcastPreviewCount` and `broadcastSentToast` and `broadcastConfirmBody*` via Flutter's ICU plural syntax: `"{count, plural, =1{1 person} other{{count} people}}"`. Run `flutter gen-l10n` to regenerate `AppLocalizations` getters.
- Acceptance: `flutter gen-l10n` exits 0. `flutter analyze` clean (no missing-key warnings from the screens). All UI strings in BroadcastsScreen + CreateBroadcastScreen route through `AppLocalizations.of(context)!` getters (verified via grep — no string literals remain in the screen files).
- Rollback: Revert the diff; `flutter gen-l10n` again.
- Estimate: 25

### Wave 4 — Tests (depends on all prior waves)

**Task 4.1 — Write `broadcast_exceptions_test.dart`**
- File(s): `test/.../data/exceptions/broadcast_exceptions_test.dart` (NEW)
- Description: One test per subtype asserting `code` and `userMessage` are the locked strings. Round-trip toString().
- Acceptance: `flutter test test/.../broadcast_exceptions_test.dart` exits 0; six test cases.
- Estimate: 15

**Task 4.2 — Write `broadcast_repository_test.dart`**
- File(s): `test/.../data/repositories/broadcast_repository_test.dart` (NEW)
- Description: Mock `SupabaseClient` via mocktail. Table tests for `_classifyBroadcastError`: feed it a synthetic `PostgrestException` for each (errcode, HINT) pair and assert the resulting Dart subtype. Also test the three repository methods' happy paths: `getBroadcasts` returns parsed `BroadcastDTO`s; `previewBroadcastAudience` returns the int; `sendBroadcast` returns `(broadcastId, recipientCount)`.
- Acceptance: `flutter test test/.../broadcast_repository_test.dart` exits 0; at least 14 cases (8 classifier + 3 happy paths + 3 error-propagation).
- Estimate: 35

**Task 4.3 — Write `create_broadcast_screen_test.dart`**
- File(s): `test/.../presentation/screens/create_broadcast_screen_test.dart` (NEW)
- Description: Widget tests with overridden Riverpod providers. Cases: (a) Send disabled until subject + body filled; (b) Audience picker default = All clients; (c) "By service" reveals service dropdown, dropdown items match overridden `appointmentSlotsProvider`; (d) Promo dropdown excludes loyalty/recovery sources and archived rows; (e) Preview calls RPC with debounce — verify exactly one call after 500ms of stable state; (f) Cap warning renders + Send disabled when preview > 1000; (g) Confirmation dialog shows correct count + audience label; (h) Successful send invalidates `broadcastsProvider` and pops with result; (i) `BroadcastRateLimitException` shows the locked toast string; (j) `BroadcastPromoInvalidException` shows the locked toast string.
- Acceptance: `flutter test test/.../create_broadcast_screen_test.dart` exits 0; at least 10 cases.
- Estimate: 70

**Task 4.4 — Author `14_smoke_tests.sql`**
- File(s): `.planning/phases/14-broadcast-messaging/sql/14_smoke_tests.sql` (NEW)
- Description: Hand-runnable SQL smoke per Phase 13 precedent. BEGIN/ROLLBACK wrapper with SAVEPOINTs per section. `RAISE NOTICE 'OK: ...'` on success. Twelve sections (§A–§L) covering the 10 SPEC success criteria + the cap check + the RLS immutability check. Reference UUIDs inlined at the top of the file.
- Acceptance: `psql -f .planning/phases/14-broadcast-messaging/sql/14_smoke_tests.sql` against a staging branch prints exactly twelve `OK:` lines and `ROLLBACK` at the end. No `FAIL:` lines.
- Estimate: 60

### Wave 5 — Meta + manual UAT (after Wave 4 merges to staging)

**Task 5.1 — Verify Meta template approval**
- File(s): n/a (operational).
- Description: Poll Meta Business Manager → Message Templates → `marketing_broadcast_v1`. If `APPROVED`: paste screenshot in PR description. If `PENDING` >24h: investigate (most likely body-text rejection). If `REJECTED`: revise body wording within the locked semantic ("identify sender + body + opt-out instructions") and resubmit; re-paste in PR.
- Acceptance: Template status = APPROVED in Meta dashboard before final staging UAT.
- Estimate: variable (10–60 over the approval window)

**Task 5.2 — Manual UAT on staging**
- File(s): n/a (UAT script).
- Description: Run the 10 SPEC success criteria end-to-end on staging. Detailed script:
  1. Sign in as a shop owner with ≥3 bookings (some confirmed, some completed, some lapsed >60d).
  2. Open Tools tab → tap Broadcasts card → land on `BroadcastsScreen` (empty for fresh owner — verify empty state copy).
  3. Tap FAB → land on `CreateBroadcastScreen` → verify default audience = "All clients" and preview count > 0.
  4. Switch to "By service" → service dropdown appears, populated with the owner's active slots → pick one → preview updates.
  5. Switch to "Lapsed" → verify count goes to 0 (or expected lapsed count from the seed data).
  6. Type subject ("Test broadcast") + body ("Hello from staging UAT") → preview steady.
  7. Open promo dropdown → verify only owner_defined active codes appear (loyalty/recovery codes absent). Attach a known active code.
  8. Tap Send → confirmation dialog shows the right count + audience + code. Confirm.
  9. `BroadcastsScreen` shows the new row with status badge progressing pending → delivering → delivered → recipient_count populated.
  10. Tap Send again on a new draft same UTC day → verify `BroadcastRateLimitException` toast.
  11. Insert a guest with `accepts_marketing = FALSE` via Supabase SQL editor; verify next-day broadcast skips them (recipient_count = N-1).
- Acceptance: All 10 SPEC criteria observed. Screenshot evidence pasted in PR.
- Estimate: 60

## Verification matrix

Maps SPEC success criteria → test type → command → status.

| SC | SPEC text | Test type | Command / location | Status |
|----|-----------|-----------|--------------------|--------|
| 1 | Owner navigates Tools → Broadcasts → tap "+". Form opens. | Widget test | `flutter test test/.../create_broadcast_screen_test.dart` (case "renders form") | Wave 4 Task 4.3 |
| 2 | Subject + body + audience preview shows count >0. | Widget test | same file, case "preview RPC fires" | Wave 4 Task 4.3 |
| 3 | "By service" reveals service dropdown. | Widget test | same file, case "by_service reveals dropdown" | Wave 4 Task 4.3 |
| 4 | "Lapsed" returns 0 for fresh shop. | SQL smoke | `14_smoke_tests.sql §B` | Wave 4 Task 4.4 |
| 5 | Attach promo dropdown filters archived + non-owner_defined. | Widget test + SQL smoke | `create_broadcast_screen_test.dart` (case "promo filter") + `14_smoke_tests.sql §C, §D` | Wave 4 Tasks 4.3, 4.4 |
| 6 | Send → broadcasts row with delivered_at + recipient_count. | SQL smoke | `14_smoke_tests.sql §E` | Wave 4 Task 4.4 |
| 7 | Send twice in same UTC day → rate limit. | SQL smoke | `14_smoke_tests.sql §F` | Wave 4 Task 4.4 |
| 8 | Attach expired/archived promo → PROMO_NOT_VALID. | SQL smoke | `14_smoke_tests.sql §D` | Wave 4 Task 4.4 |
| 9 | scheduled_notifications rows with correct channel per recipient. | SQL smoke | `14_smoke_tests.sql §E, §I` | Wave 4 Task 4.4 |
| 10 | `accepts_marketing = FALSE` guest excluded from recipient_count + fan-out. | SQL smoke | `14_smoke_tests.sql §J` | Wave 4 Task 4.4 |
| (cap) | Audience > 1000 → BROADCAST_CAP_EXCEEDED. | SQL smoke | `14_smoke_tests.sql §H` | Wave 4 Task 4.4 |
| (race) | Same-second double-tap → BROADCAST_IN_FLIGHT. | SQL smoke | `14_smoke_tests.sql §G` | Wave 4 Task 4.4 |
| (immutable) | UPDATE / DELETE on broadcasts denied for authenticated. | SQL smoke | `14_smoke_tests.sql §L` | Wave 4 Task 4.4 |
| (RLS) | Different owner cannot SELECT broadcasts. | SQL smoke | `14_smoke_tests.sql §K` | Wave 4 Task 4.4 |

## Risk register (delta from SPEC)

| Risk | Likelihood | Mitigation in this plan |
|------|-----------|-------------------------|
| Audience size cap regresses to "no cap" via a future SPEC edit | L | The 1000 cap is a SQL CHECK + the `BROADCAST_CAP_EXCEEDED` raise + the client-side warning. Three layers; SPEC drift cannot silently disable any one. |
| Promo source restriction bypassed via direct RPC call (web inspector) | L | Server-side `source = 'owner_defined'` predicate is the gate; the dropdown filter is a UX hint only. |
| Owner toggles `accepts_marketing` from FALSE → TRUE via SQL editor and re-broadcasts | L | Acceptable — owner is acting within their authority. Worker-side STOP-reply flip (future phase) re-establishes guest control. |
| Meta template rejection blocks PR merge | M | Approval is NOT a merge gate. Worker's 6h defer covers the gap. PR ships; guests get the broadcast as soon as Meta approves. |
| Worker silently fails on the new enum value before migration runs | L | Wave 0 migration runs before any send_broadcast call (the RPC is in Wave 1; the screen is in Wave 2). Enum is in place before the first row is written. |
| Same-second double-tap defeats the rate limit | L | Advisory lock at the top of `send_broadcast` is the same-second guard; UTC-day count is the long-term guard. Both required (RESEARCH §16 line 842). |
| Cross-identity duplicates (one human, two profiles) | L | Documented in PR; acceptable. Future identity-unification work is out of scope. |
| Empty fresh shop broadcast (count=0) writes an audit row with zero fan-out | L | Acceptable per SPEC risk register line 186. Documented. |

## Phase boundary

Phase 14 ships:
- Server: 5 migrations (enum extend, opt-in column, broadcasts table + RLS, preview RPC, send RPC).
- No edge function changes — worker handles `marketing_broadcast` automatically via existing `delivery_channel` branching.
- Client: 2 new screens (BroadcastsScreen, CreateBroadcastScreen), 1 DTO, 1 exception hierarchy, 3 new repository methods + 1 classifier, 1 provider, 1 tools_screen card, 2 GoRouter sub-routes, 32 i18n keys.
- Tests: 3 new test files + 1 SQL smoke file (12 sections).
- 1 new Meta WhatsApp template (`marketing_broadcast_v1`).

Phase 14 does NOT ship:
- Worker behavior to flip `accepts_marketing` on STOP reply (separate follow-up phase).
- Scheduled / drip broadcasts (future phase).
- Per-client direct messaging UI (`client_notes` is read-only owner memory).
- Email / SMS-direct channels.
- Broadcast analytics beyond `recipient_count`.
- Translations beyond EN.
- `BROADCAST_CAP_EXCEEDED` raised at the client side before the RPC trip (the warning + disabled-Send is a UX hint; server enforcement is the contract).
