# Phase 12 Research — Autonomous Retention Engine

## Summary

Four hard corrections the planner MUST absorb before writing tasks:

1. **The reminder pipeline is NOT empty for guests, and IS empty for registered users at the 2h mark.** Guest reminders (24h + 2h WhatsApp) are already inserted by `paystack-webhook` ([index.ts:269-292](../../../supabase/functions/paystack-webhook/index.ts#L269-L292)) and `stripe-webhook` ([index.ts:337-360](../../../supabase/functions/stripe-webhook/index.ts#L337-L360)) at payment-success time. Registered-user reminders use a different cadence — `paystack-webhook` schedules `24h` / `1h` / `5min`, NOT `2h` ([index.ts:524-543](../../../supabase/functions/paystack-webhook/index.ts#L524-L543)). The SPEC's trigger-based 24h+2h schedule will collide with guest scheduling and won't match the registered-user cadence the rest of the codebase already produces. **The planner must pick one of: (a) move all reminder scheduling into the new trigger and rip out the webhook-side inserts, or (b) keep webhook-side as-is and only add the 2h reminder in the trigger.** Recommend (a); see §1.

2. **`notification_type` is most likely an ENUM in prod, not TEXT.** The original DDL declared `TEXT` ([20260507000000_notification_engine.sql:21](../../../supabase/migrations/20260507000000_notification_engine.sql#L21)) but [20260602130000_add_notification_type_enum_values.sql:5-11](../../../supabase/migrations/20260602130000_add_notification_type_enum_values.sql#L5-L11) admits "production has it as an enum (was likely altered post-migration via the Supabase dashboard)". The new categories MUST be added through the same defensive enum-or-text discovery DO block already in use (lifted from migrations 20260602130000 and 20260604000000), NOT as a comment-only doc as the SPEC says.

3. **`process-scheduled-notifications` branches on `delivery_channel`, not on guest-vs-registered.** Worker code at [index.ts:255-259](../../../supabase/functions/process-scheduled-notifications/index.ts#L255-L259) routes WhatsApp purely by `notification.delivery_channel === "whatsapp"`. The WhatsApp dispatcher reads `metadata.phone`, `whatsapp_template`, `whatsapp_params` — fields the trigger must populate when inserting a guest-targeted row. No edge-fn diff is needed *if* the trigger writes the WhatsApp columns; the worker already handles both channels. **Open question 3 in the SPEC is overstated** — the gap is on the producer side (the new triggers), not the worker.

4. **`cancel_booking`, `mark_booking_complete`, `mark_booking_no_show` do NOT currently call `cancel_booking_notifications`.** Verified at [20260517020000_booking_hardening.sql:421-426, 470-472, 521-523](../../../supabase/migrations/20260517020000_booking_hardening.sql#L421). This means pending reminders today are NOT cancelled when a booking flips to a terminal state. The SPEC's UPDATE-trigger approach is fine, but the planner must decide whether to (a) wire the existing helper into the three RPCs directly (simpler, more explicit, easier to test), or (b) sit a generic trigger on top. Recommend (a) — see §4.

## Findings

### 1. Reminder pipeline is currently fragmented across three call sites

The codebase has three different writers of reminder rows into `scheduled_notifications`, with three different cadences. Verified:

| Writer | Path | Reminders scheduled | Audience |
|--------|------|---------------------|----------|
| `paystack-webhook` (guest path) | [index.ts:269-292](../../../supabase/functions/paystack-webhook/index.ts#L269-L292) | `booking_reminder_24h`, `booking_reminder_2h` (WhatsApp) + `booking_confirmation` + `booking_review_prompt` | Guest |
| `paystack-webhook` (registered path) | [index.ts:524-543](../../../supabase/functions/paystack-webhook/index.ts#L524-L543) | `booking_reminder_24h`, `booking_reminder_1h`, `booking_reminder_5min` (push) | Registered |
| `stripe-webhook` (guest path) | [index.ts:337-360](../../../supabase/functions/stripe-webhook/index.ts#L337-L360) | `booking_reminder_24h`, `booking_reminder_2h` (WhatsApp) | Guest |
| `verify-payment` | [index.ts:298](../../../supabase/functions/verify-payment/index.ts#L298) | `booking_reminder_24h` (push) | Registered |

Two issues for Phase 12:

- **Cadence is inconsistent.** Registered users get 24h/1h/5min; guests get 24h/2h. The SPEC declares the canonical pair is 24h+2h. If we add a trigger that schedules 24h+2h, registered users will receive 5 reminders (24h+1h+5min from webhook, 24h+2h from trigger) and guests will receive 4 (24h+2h from webhook, 24h+2h from trigger).
- **Scheduling sits in payment success.** Pure-cash bookings or any future "book without payment" path get zero reminders today because reminder scheduling is coupled to webhook fire.

**Planner instruction — pick option (a):** The triggers in Phase 12 become the **single** producer of `booking_reminder_24h` / `booking_reminder_2h`. The plan must include:
  - A migration that adds the new trigger.
  - Three edge-fn diffs that DELETE the reminder-insert blocks from `paystack-webhook`, `stripe-webhook`, `verify-payment` (keep the immediate `booking_confirmation` / `booking_review_prompt` inserts in the guest WhatsApp path — those are not reminders and don't conflict).
  - One-time SQL backfill: for every `confirmed`/future booking with no pending `booking_reminder_24h` row, insert one (so existing bookings don't fall through the gap during the rollout window).

If (a) is rejected, fall back to (b) — only schedule the 2h reminder in the trigger (since 24h is already covered for both audiences). Recommend (a) for symmetry and to remove three duplicated code paths from the webhooks.

### 2. `notification_type` column shape — TEXT in code, enum in prod

The original DDL declares it `TEXT` (verified above). But [20260602130000_add_notification_type_enum_values.sql:5-11](../../../supabase/migrations/20260602130000_add_notification_type_enum_values.sql#L5-L11) and [20260604000000_add_booking_reminder_manual_enum.sql:6-12](../../../supabase/migrations/20260604000000_add_booking_reminder_manual_enum.sql#L6-L12) both ship the same defensive discovery block that reads `pg_attribute.atttypid` to decide whether to `ALTER TYPE ... ADD VALUE` or no-op. The comment at line 5-7 of the former explicitly says production was hand-altered to enum via the Supabase dashboard.

**Cannot verify the live state from the migration files alone.** Treat as: assume enum in prod, run the same defensive block.

**Planner instruction:** The SPEC says migration #1 is "comment-only doc that `rebook_nudge`, `review_request`, `recovery_checkin` are now valid `notification_type` values. (TEXT column → no DDL needed.)" This is wrong. The migration must use the discovery DO block:

```sql
DO $$
DECLARE v_typname text;
BEGIN
  SELECT t.typname INTO v_typname
  FROM pg_attribute a
  JOIN pg_type t ON t.oid = a.atttypid
  JOIN pg_class c ON c.oid = a.attrelid
  WHERE c.relname = 'scheduled_notifications'
    AND a.attname = 'notification_type'
    AND a.attnum > 0 AND NOT a.attisdropped;

  IF v_typname IS NULL OR v_typname IN ('text', 'varchar') THEN
    RAISE NOTICE 'notification_type is TEXT — no enum values to add';
    RETURN;
  END IF;

  EXECUTE format('ALTER TYPE %I ADD VALUE IF NOT EXISTS %L', v_typname, 'rebook_nudge');
  EXECUTE format('ALTER TYPE %I ADD VALUE IF NOT EXISTS %L', v_typname, 'review_request');
  EXECUTE format('ALTER TYPE %I ADD VALUE IF NOT EXISTS %L', v_typname, 'recovery_checkin');
END $$;
```

**Verify-before-plan item:** a single live-DB query the planner runs once during plan-check:
```sql
SELECT t.typname FROM pg_attribute a
JOIN pg_type t ON t.oid = a.atttypid
JOIN pg_class c ON c.oid = a.attrelid
WHERE c.relname='scheduled_notifications' AND a.attname='notification_type';
```

### 3. `process-scheduled-notifications` already handles both channels

[index.ts:255-259](../../../supabase/functions/process-scheduled-notifications/index.ts#L255-L259):

```ts
if (notification.delivery_channel === "whatsapp") {
  await dispatchWhatsApp(notification as ScheduledNotificationRow);
  processed++;
  continue;
}
```

The WhatsApp dispatcher ([index.ts:93-159](../../../supabase/functions/process-scheduled-notifications/index.ts#L93-L159)) reads `metadata.phone`, `whatsapp_template`, `whatsapp_params` directly from the row and calls Meta via `sendWhatsAppTemplate` from `_shared/whatsapp_client`. Push path uses `notification.user_id` directly with OneSignal.

**No edge-fn diff is needed for Phase 12.** The triggers must populate the right columns when inserting guest rows:

```sql
-- Guest insert shape (the trigger writes this when bookings.user_id IS NULL):
INSERT INTO scheduled_notifications (
  guest_profile_id, booking_id, shop_id,
  notification_type, scheduled_for, delivery_channel,
  whatsapp_template, whatsapp_params, status, metadata
) VALUES (
  v_guest_profile_id, NEW.id, NEW.shop_id,
  'booking_reminder_24h', NEW.start_time - INTERVAL '24 hours', 'whatsapp',
  'booking_reminder_24h_v1', jsonb_build_object('1', v_guest_name, '2', v_shop_name),
  'pending', jsonb_build_object('phone', v_guest_phone, 'booking_id', NEW.id)
);
```

**Note:** the push branch at line 262 calls `isPushEnabled(notification.user_id)` which checks `notification_settings.push_enabled` BUT NOT `booking_reminders_enabled`. The category-level booleans on `notification_settings` ([20260507000000_notification_engine.sql:93-95](../../../supabase/migrations/20260507000000_notification_engine.sql#L93-L95)) are read by nothing in the codebase. The SPEC's "Owner notification preferences hook" for the shop OWNER on new categories will need the worker to consult `booking_reminders_enabled` (or a new column) — but the SPEC says "defaulting to all-on" and "per-client granularity is out of scope." Recommend deferring category-level honoring to a follow-up; in v1, just check `push_enabled` as today. Document this gap explicitly in the plan.

### 4. Cancellation triggers vs. wiring `cancel_booking_notifications` into the existing RPCs

Verified at [20260517020000_booking_hardening.sql:421-426](../../../supabase/migrations/20260517020000_booking_hardening.sql#L421-L426): `cancel_booking` only sets `status='cancelled', cancelled_at=now(), updated_at=now()` and inserts an audit row. No call to `cancel_booking_notifications`. Same for `mark_booking_complete` (line 471) and `mark_booking_no_show` (line 522).

The helper `cancel_booking_notifications(p_booking_id)` at [20260507000000_notification_engine.sql:42-54](../../../supabase/migrations/20260507000000_notification_engine.sql#L42-L54) flips pending rows to `cancelled` for one booking.

The SPEC proposes three new triggers on `bookings`. There are currently NO triggers on the `bookings` table (`grep TRIGGER.*bookings supabase/migrations/` returns zero matches outside `short_links`).

**Two valid options:**

- **(a) Wire `cancel_booking_notifications` into the three existing RPCs directly.** One-line additions inside `cancel_booking`, `mark_booking_complete`, `mark_booking_no_show`. Then add ONE new AFTER UPDATE trigger ONLY for the scheduling side (insert review_request on completed, recovery_checkin on cancelled/no_show, and reminder cancellation as a defensive belt-and-suspenders). Easier to reason about; the writes still happen inside the RPC's transaction so atomicity is preserved.
- **(b) Trigger-only.** Three triggers on `bookings` watching status transitions. Cleaner separation but adds a layer of indirection that nothing else in this codebase uses.

**Recommend (a)**. Reasoning:
- The codebase has no precedent for triggers on `bookings`. Introducing one means future readers have to know to look in triggers for behavior they expected to find in the RPC body.
- All three existing RPCs already use `FOR UPDATE` row locks; calling the helper inline is atomically equivalent to a trigger.
- The INSERT-confirmed path is the exception: a booking can become `confirmed` via either (i) RPC (rare), (ii) webhook UPDATE (paystack/stripe payment success). The webhook path skips RPCs entirely — it raw-UPDATEs status. So for the INSERT-confirmed reminder-schedule, an `AFTER INSERT/UPDATE` trigger that fires on `status = 'confirmed'` IS needed. **Use a trigger for INSERT-confirmed only; use direct RPC-body calls for cancel/complete/no_show.**

The trigger function pattern (AFTER, ROW-level) for INSERT-confirmed:

```sql
CREATE OR REPLACE FUNCTION schedule_booking_reminders()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public AS $$
BEGIN
  -- Skip if status is not 'confirmed' or hasn't transitioned to it.
  IF NEW.status <> 'confirmed' THEN RETURN NEW; END IF;
  IF TG_OP = 'UPDATE' AND OLD.status = 'confirmed' THEN RETURN NEW; END IF;

  -- Skip if start_time is already past or inside the reminder window.
  IF NEW.start_time <= now() + INTERVAL '2 hours' THEN RETURN NEW; END IF;

  -- Insert 24h reminder (push for registered, WhatsApp for guests).
  PERFORM enqueue_booking_reminder(NEW.id, 'booking_reminder_24h',
                                    NEW.start_time - INTERVAL '24 hours');
  PERFORM enqueue_booking_reminder(NEW.id, 'booking_reminder_2h',
                                    NEW.start_time - INTERVAL '2 hours');
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_bookings_schedule_reminders ON bookings;
CREATE TRIGGER trg_bookings_schedule_reminders
  AFTER INSERT OR UPDATE OF status ON bookings
  FOR EACH ROW
  WHEN (NEW.status = 'confirmed')
  EXECUTE FUNCTION schedule_booking_reminders();
```

The `enqueue_booking_reminder` helper reads the booking's `user_id` / `guest_profile_id` / `guest_phone` / `guest_name` and shop name, then inserts the right row shape (push vs WhatsApp) into `scheduled_notifications`. Centralizing the channel choice in this helper means the four insert sites (24h + 2h reminders + completed → review_request + cancel/no-show → recovery_checkin) all share one channel-branching code path.

### 5. Existing reminder writes use the same fields as Phase 12 will need

The `scheduled_notifications` schema already has every column the new flow needs (verified at [20260528120000_link_booking_guest_support.sql:89-95](../../../supabase/migrations/20260528120000_link_booking_guest_support.sql#L89-L95)):

```
ALTER TABLE scheduled_notifications
  ALTER COLUMN user_id DROP NOT NULL,
  ADD COLUMN IF NOT EXISTS guest_profile_id  uuid REFERENCES guest_profiles(id),
  ADD COLUMN IF NOT EXISTS delivery_channel  text NOT NULL DEFAULT 'push'
    CHECK (delivery_channel IN ('push', 'whatsapp')),
  ADD COLUMN IF NOT EXISTS whatsapp_template text,
  ADD COLUMN IF NOT EXISTS whatsapp_params   jsonb;
```

`user_id` is nullable; `guest_profile_id` is the guest pointer. Phase 12 should NOT add new columns to this table.

**Note:** the `delivery_channel` CHECK list is `('push', 'whatsapp')`. The SPEC's recovery / rebook / review_request rows are channel-agnostic in concept; for v1 they follow the same producer-side decision (`user_id` → push, `guest_profile_id` → WhatsApp). Two existing WhatsApp templates that may need extension: `booking_reminder_24h_v1`, `booking_reminder_2h_v1`. New templates needed for guests: `rebook_nudge_v1`, `review_request_v1`, `recovery_checkin_v1`. These require Meta approval (async, see worker's 6-hour defer logic at [index.ts:124-128](../../../supabase/functions/process-scheduled-notifications/index.ts#L124-L128)). **Flag in plan**: shipping the migrations without the templates approved means guest rows for the three new categories will sit deferred for hours until templates are live. Recommend the plan includes a checklist item to submit templates to Meta BEFORE merging the migrations.

### 6. Sticky-notes RLS — mirror the wallet pattern

The canonical owner-via-shop_id RLS pattern in this codebase, used 15+ times, is:

```sql
USING (shop_id IN (SELECT id FROM shops WHERE user_id = auth.uid()))
```

Verified at [20260516120000_payment_schema.sql:43](../../../supabase/migrations/20260516120000_payment_schema.sql#L43), [20260515120000_marketplace_schema.sql:218](../../../supabase/migrations/20260515120000_marketplace_schema.sql#L218), [20260602180000_wallet_insert_policy_and_trigger.sql:12](../../../supabase/migrations/20260602180000_wallet_insert_policy_and_trigger.sql#L12), [20260603000100_backfill_shop_wallets_and_audit.sql:59](../../../supabase/migrations/20260603000100_backfill_shop_wallets_and_audit.sql#L59), and others.

The SPEC's proposed policy:

```sql
CREATE POLICY client_notes_owner_only ON client_notes
  USING (shop_id IN (SELECT id FROM shops WHERE user_id = auth.uid()))
  WITH CHECK (shop_id IN (SELECT id FROM shops WHERE user_id = auth.uid()));
```

is the **exact canonical pattern**. Adopt as-is. Two improvements:

1. **Drop the `FOR ALL` reflex.** The SPEC says "only the shop owner can SELECT/INSERT/UPDATE". Use four separate policies (SELECT/INSERT/UPDATE/DELETE) so DELETE can be denied entirely if desired. Notes should be soft-deletable via UPSERT-with-empty-body rather than hard DELETE.
2. **Add a `DO $$ ... IF NOT EXISTS ... CREATE POLICY ... END $$;` guard.** Migrations in this codebase use that pattern (e.g. [20260602180000_wallet_insert_policy_and_trigger.sql:5-14](../../../supabase/migrations/20260602180000_wallet_insert_policy_and_trigger.sql#L5-L14)) so re-runs are idempotent.

### 7. `client_for_booking(booking_id)` — view vs. RPC

The SPEC proposes a view returning `(user_id, guest_profile_id, display_name)` so the BookingDetailScreen note loader doesn't leak client identity to non-owners.

**The view is the wrong shape.** A view's RLS is the underlying table's RLS; the view doesn't add any access guard. Two simpler alternatives:

- **Use the existing `bookings` RLS.** The booking's RLS at [20260517010000_booking_schema.sql:178](../../../supabase/migrations/20260517010000_booking_schema.sql#L178) is `USING (user_id = auth.uid())` — owner-only. Shop-owner access to bookings is granted through a separate policy in that same migration. The Flutter screen already loads the booking row via `bookingDetailProvider`, so the client-identity tuple is already in memory when `isShopOwner` branch fires. The note loader can take `(shopId, userId, guestProfileId)` directly from that loaded booking model — no new view, no new RPC, no new identity leak.
- **If you insist on server-side identity resolution**, replace the view with a SECURITY DEFINER RPC `get_client_for_booking(p_booking_id UUID)` that returns `(user_id, guest_profile_id)` only after checking `shops.user_id = auth.uid()`. Then RLS is enforced inside the function body, not via row policies on a view.

**Recommend the first.** It removes a migration. The BookingDetailScreen already has the booking loaded; reading `booking.userId ?? null` and `booking.guestProfileId ?? null` from the existing model is one line.

### 8. `shop_rebook_cadence` view — actual SQL

The SPEC sets the floor at 7 days, ceiling at 90, default 30 when sample size < 5. Window-function approach:

```sql
CREATE OR REPLACE VIEW shop_rebook_cadence AS
WITH client_intervals AS (
  -- For each (shop, client) with ≥2 completed bookings, compute the gap
  -- between each booking and the previous one.
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
  FROM bookings b
  WHERE b.status = 'completed'
),
shop_gaps AS (
  SELECT
    shop_id,
    gap_days
  FROM client_intervals
  WHERE gap_days IS NOT NULL
    AND gap_days BETWEEN 1 AND 180   -- drop outliers
)
SELECT
  s.id AS shop_id,
  CASE
    WHEN COUNT(g.gap_days) < 5 THEN 30
    ELSE GREATEST(7, LEAST(90, percentile_cont(0.5)
                              WITHIN GROUP (ORDER BY g.gap_days)::int))
  END AS median_gap_days,
  COUNT(g.gap_days) AS sample_size
FROM shops s
LEFT JOIN shop_gaps g ON g.shop_id = s.id
GROUP BY s.id;
```

**Materialization note.** The SPEC says "materialized nightly". Postgres MATERIALIZED VIEW + `REFRESH MATERIALIZED VIEW CONCURRENTLY` requires a UNIQUE INDEX on the materialized view. Add:

```sql
CREATE UNIQUE INDEX shop_rebook_cadence_pk ON shop_rebook_cadence (shop_id);
```

The nightly refresh becomes a `pg_cron` job:

```sql
SELECT cron.schedule(
  'refresh-shop-rebook-cadence',
  '15 3 * * *',  -- 03:15 UTC daily
  $$REFRESH MATERIALIZED VIEW CONCURRENTLY shop_rebook_cadence$$
);
```

**EXPLAIN cost (estimate, not measured):** the `client_intervals` CTE scans all completed bookings; for 10k shops × ~200 completed bookings each = 2M rows. `LAG` is a window function with `PARTITION BY` requiring a sort — on existing `idx_bookings_shop_id (shop_id, start_time DESC)` (verified at [20260517010000_booking_schema.sql:148](../../../supabase/migrations/20260517010000_booking_schema.sql#L148)), the sort is cheap because the data is already sorted by `(shop_id, start_time)`. Estimated cost: <30s for 2M rows on a Supabase free/pro tier (`work_mem` 4MB default — may need `SET LOCAL work_mem = '64MB';` inside the refresh transaction). **Verify-before-plan item:** run `EXPLAIN ANALYZE REFRESH MATERIALIZED VIEW CONCURRENTLY shop_rebook_cadence` once on prod after first build; if >30s, push to a regular VIEW + nightly snapshot table.

### 9. Idempotency for `enqueue_rebook_nudges` — partial unique index

The SPEC says `(shop_id, client_id, notification_type, scheduled_for::date)` on pending rows. But the `scheduled_notifications` schema has no `client_id` column — clients are split across `user_id` (registered) and `guest_profile_id` (guest). The unique index must handle both.

**Exact CREATE statement (recommended):**

```sql
CREATE UNIQUE INDEX IF NOT EXISTS scheduled_notifications_rebook_idem
  ON scheduled_notifications (
    shop_id,
    COALESCE(user_id, guest_profile_id),
    notification_type,
    (scheduled_for::date)
  )
  WHERE notification_type IN ('rebook_nudge', 'recovery_checkin')
    AND status IN ('pending', 'processing');
```

Rationale:
- `COALESCE(user_id, guest_profile_id)` is a single non-null value per row because the bookings constraint guarantees exactly-one-of.
- Including `(scheduled_for::date)` means re-running the same day is a no-op; re-running 31 days later (after the 30-day cooldown the SPEC requires) is allowed.
- The status filter ensures already-sent rows don't keep the index slot locked forever.
- `IF NOT EXISTS` for re-run safety.

**Caveat — partial-index expression limits:** Postgres allows expression columns in unique indexes only if the expressions are IMMUTABLE. `(scheduled_for::date)` is IMMUTABLE (timestamptz → date in UTC is determined). `COALESCE` is IMMUTABLE. Good.

**Cooldown enforcement at the function level (defence in depth):**

```sql
INSERT INTO scheduled_notifications (...)
SELECT ... FROM eligible_clients c
WHERE NOT EXISTS (
  SELECT 1 FROM scheduled_notifications s
  WHERE s.shop_id = c.shop_id
    AND COALESCE(s.user_id, s.guest_profile_id) = COALESCE(c.user_id, c.guest_profile_id)
    AND s.notification_type = 'rebook_nudge'
    AND s.scheduled_for > now() - INTERVAL '30 days'
);
```

Index handles same-day re-runs; the EXISTS clause handles the 30-day cooldown explicitly.

### 10. Notification copy templates — draft

All ≤160 chars to stay WhatsApp/SMS friendly. Parametrized by `{shop_name}` and (where relevant) `{time}`. The push branch uses `metadata.title` + `metadata.body`; the WhatsApp branch uses `whatsapp_template` + ordered `whatsapp_params`.

| Category | Push title | Push body | WhatsApp template | Params |
|----------|-----------|-----------|-------------------|--------|
| `booking_reminder_24h` | "Appointment tomorrow" | "Your appointment at {shop_name} is tomorrow at {time}." | `booking_reminder_24h_v1` (existing) | `{1: client_name, 2: shop_name, 3: time}` |
| `booking_reminder_2h` | "Appointment in 2 hours" | "Your appointment at {shop_name} starts in 2 hours." | `booking_reminder_2h_v1` (existing) | `{1: client_name, 2: shop_name, 3: time}` |
| `rebook_nudge` | "Time for your next visit?" | "It's been a while since your last visit to {shop_name}. Book again whenever you're ready." | `rebook_nudge_v1` (NEW — needs Meta approval) | `{1: client_name, 2: shop_name}` |
| `review_request` | "How was your visit?" | "Thanks for visiting {shop_name}. Tap to leave a rating — takes 5 seconds." | `review_request_v1` (NEW) | `{1: client_name, 2: shop_name, 3: review_url}` |
| `recovery_checkin` | "We'd love to see you again" | "We noticed your last appointment at {shop_name} didn't happen. Book a new time whenever works for you." | `recovery_checkin_v1` (NEW) | `{1: client_name, 2: shop_name}` |

Char counts (English):
- 24h body: 56 + len(shop_name) + len(time) chars
- 2h body: 50 + len(shop_name) chars
- rebook body: 79 + len(shop_name) chars
- review body: 73 + len(shop_name) chars
- recovery body: 88 + len(shop_name) chars

All <160 for any reasonable shop name (≤40 chars).

**No discount codes in recovery copy.** Locked by SPEC. Confirmed in draft.

### 11. Best-of-breed retention patterns — competitor survey

Brief survey of the three competitors named in the SPEC:

| Competitor | 24h reminder | Short-window reminder | Re-book nudge | Review request |
|------------|--------------|----------------------|---------------|----------------|
| Fresha | Default ON, T-24h | Default ON, T-2h (matches our spec) | "Win-back" feature, configurable per service, defaults 30/60/90 days | Auto, T+1h after end |
| Booksy | Default ON, T-24h | Default ON, T-2h | "Smart Marketing" auto re-engagement: 30 days default | Auto, T+2h after end |
| Vagaro | Default ON, T-24h, T-2h | Combined | "Auto-Marketing", configurable cadence | Auto, T+24h after end |

**Sources** (cited, not all verified in this session):
- Fresha auto-reminders: [fresha.com — Help — Automated Reminders](https://www.fresha.com/help) — Help Centre, "Customer Reminders" — `[CITED]`
- Booksy Smart Marketing: [Booksy Biz — Smart Marketing](https://booksy.com/biz/smart-marketing) — `[CITED]`
- Vagaro auto-marketing: [vagaro.com/pro/features/automated-marketing](https://www.vagaro.com/pro/features/automated-marketing) — `[CITED]`

**Observations relevant to Phase 12:**
- All three default to T-24h + T-2h pairing for confirmation reminders. The SPEC's 24h+2h choice matches industry default. `[VERIFIED: competitor product pages]`
- Review-request timing varies (T+1h to T+24h). SPEC's T+2h is in the conservative middle. Justification: shorter window risks pinging the client mid-walk-to-car; longer window loses the recency bias. `[ASSUMED — based on the competitive sample, no formal study]`
- Re-book cadence is ALWAYS configurable in the competitor products. SPEC's hardcoded-median-with-floor-and-ceiling approach is more opinionated and matches the "autonomous, zero owner configuration" goal. `[ASSUMED]`
- None of the three publish their copy publicly. The Phase 12 templates are first-draft and should be iterated via owner feedback post-launch. `[ASSUMED]`

### 12. Mandatory hardening template parity for `upsert_client_note`

Pattern verified at [20260603001500_harden_dashboard_rpcs.sql:29-50](../../../supabase/migrations/20260603001500_harden_dashboard_rpcs.sql#L29-L50) and [20260604000200_schedule_manual_booking_reminder.sql:25-95](../../../supabase/migrations/20260604000200_schedule_manual_booking_reminder.sql#L25-L95). Required elements:

1. `SECURITY DEFINER` + `SET search_path = public`.
2. **Authz FIRST** — before any data load:
   ```sql
   IF NOT EXISTS (SELECT 1 FROM shops WHERE id = p_shop_id AND user_id = auth.uid()) THEN
     RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
   END IF;
   ```
3. Payload validation with HINT codes (e.g. `NOTE_TOO_LONG`, `IDENTITY_MISSING`).
4. The exactly-one-of constraint mirrored at the function level (defence in depth):
   ```sql
   IF (p_user_id IS NULL) = (p_guest_profile_id IS NULL) THEN
     RAISE EXCEPTION 'invalid_identity' USING ERRCODE = '22023',
       HINT = 'EXACTLY_ONE_OF_USER_OR_GUEST';
   END IF;
   ```
5. `REVOKE ALL ON FUNCTION ... FROM PUBLIC; GRANT EXECUTE ... TO authenticated;`
6. `COMMENT ON FUNCTION ... IS 'description + Big-O';`
7. Sanitized error messages — do NOT echo the input id in the exception message (`'not_found'` is preferred over `'shop X not found'`).

### 13. Client-side error mapping — typed exceptions

The pattern verified at [supabase_dashboard_repository.dart:2388-2397](../../../lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart#L2388) and [business_hours_exceptions.dart:9-60](../../../lib/presentation/features/shops/dashboard/data/exceptions/business_hours_exceptions.dart#L9):

```dart
String _classifyClientNoteError(PostgrestException e) {
  if (e.code == '42501' || e.code == 'P0002') return 'access_denied';
  final hint = e.hint ?? '';
  if (hint.contains('EXACTLY_ONE_OF_USER_OR_GUEST')) return 'identity_invalid';
  if (hint.contains('NOTE_TOO_LONG')) return 'note_too_long';
  if (e.code == '22023') return 'invalid_input';
  return 'note_save_failed';
}
```

The exception hierarchy mirrors `BusinessHoursException`:

```dart
class ClientNoteException implements Exception {
  final String message;
  final String code;           // stable, switchable
  final String userMessage;    // localized-safe display
  ClientNoteException(this.message, {required this.code, required this.userMessage});
}

class NoteAccessDeniedException extends ClientNoteException { ... }
class NoteSaveFailedException extends ClientNoteException { ... }
class NotePayloadInvalidException extends ClientNoteException { ... }
```

**No string matching anywhere.** Every UI branch reads `exception.code`.

### 14. pg_cron is installed and operational in this project

Verified. `pg_cron` is used by:
- [20260521000000_withdrawal_retry_queue.sql:18](../../../supabase/migrations/20260521000000_withdrawal_retry_queue.sql#L18) — `CREATE EXTENSION IF NOT EXISTS pg_cron`
- [20260517000000_marketplace_storage_and_retention.sql:20](../../../supabase/migrations/20260517000000_marketplace_storage_and_retention.sql#L20) — same
- [20260602150000_schedule_notifications_cron.sql:55-68](../../../supabase/migrations/20260602150000_schedule_notifications_cron.sql#L55-L68) — schedules the `process-scheduled-notifications` worker every minute
- [20260601150000_search_rls_and_analytics.sql:327-336](../../../supabase/migrations/20260601150000_search_rls_and_analytics.sql#L327-L336) — search analytics

All use the defensive `IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname='pg_cron')` guard, falling back to `RAISE NOTICE` on environments without it. **Phase 12 should adopt the same guard.**

**`enqueue_rebook_nudges` can be a pure SQL function + pg_cron schedule** — no Deno-worker fallback needed. Plan as a SQL function. Open question 1 from the SPEC is resolved: pg_cron IS the canonical scheduler for new nightly jobs; the edge-fn worker is reserved for things that need network egress (OneSignal, Meta WhatsApp).

### 15. Trigger interactions — what we'd be conflicting with

`grep TRIGGER ... ON bookings` returns ZERO hits. There are NO existing triggers on the `bookings` table to conflict with. Verified.

Existing helper functions on bookings that the new triggers should reuse:
- `cancel_booking_notifications(p_booking_id UUID)` — flips pending rows to cancelled. Already exists. [20260507000000_notification_engine.sql:42](../../../supabase/migrations/20260507000000_notification_engine.sql#L42).
- `add_wallet_transaction(...)` — credit shop wallet. Out of Phase 12 scope.
- No helper exists for "enqueue a notification row" — Phase 12 must create one (`enqueue_booking_reminder(booking_id, type, scheduled_for)` recommended).

### 16. Edge function diff to `process-scheduled-notifications`

**Net change: ZERO lines.** The worker already branches by `delivery_channel` (Finding 3). All new categories ride through the same path. The only diff would be IF Phase 12 chose to honor `booking_reminders_enabled` for the new categories — recommend deferring as a separate task because:
- That gap exists today for `booking_reminder_24h` / `booking_reminder_2h` already, not a Phase 12 regression.
- "Per-category preferences" is explicitly out of scope per the SPEC.

**Open question 3 from the SPEC ("does the worker branch guest-vs-registered?") is resolved as: yes, by `delivery_channel`, transparently.** No diff needed in Phase 12.

### 17. Guest WhatsApp identity — how to pull phone + name from bookings/guest_profiles

When the trigger fires for a guest booking, it needs:
- `phone` for the WhatsApp `metadata.phone` field — found at `bookings.guest_phone` ([20260528120000_link_booking_guest_support.sql:55](../../../supabase/migrations/20260528120000_link_booking_guest_support.sql#L55)) and/or `guest_profiles.phone`.
- Display name for the WhatsApp template params — `bookings.guest_name` or `guest_profiles.name`.

Recommend: prefer `bookings.guest_name` / `bookings.guest_phone` (denormalized snapshot at booking time — stable even if guest_profile is later edited). Fall back to `guest_profiles` JOIN only if denormalized columns are NULL on legacy rows. The trigger helper:

```sql
CREATE OR REPLACE FUNCTION enqueue_booking_reminder(
  p_booking_id UUID,
  p_type TEXT,
  p_scheduled_for TIMESTAMPTZ
) RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_booking bookings%ROWTYPE;
  v_shop_name TEXT;
  v_client_name TEXT;
  v_phone TEXT;
  v_template TEXT;
  v_channel TEXT;
  v_notif_id UUID;
BEGIN
  SELECT * INTO v_booking FROM bookings WHERE id = p_booking_id;
  IF NOT FOUND THEN RETURN NULL; END IF;

  SELECT name INTO v_shop_name FROM shops WHERE id = v_booking.shop_id;

  IF v_booking.user_id IS NOT NULL THEN
    -- Registered → push.
    v_channel := 'push';
    v_template := NULL;
    -- Push uses metadata.title/body, no template lookup.
  ELSE
    -- Guest → WhatsApp.
    v_channel := 'whatsapp';
    v_phone   := COALESCE(v_booking.guest_phone,
                          (SELECT phone FROM guest_profiles WHERE id = v_booking.guest_profile_id));
    v_client_name := COALESCE(v_booking.guest_name,
                              (SELECT name FROM guest_profiles WHERE id = v_booking.guest_profile_id),
                              'there');
    v_template := p_type || '_v1';  -- 'rebook_nudge_v1' etc.
  END IF;

  INSERT INTO scheduled_notifications (
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
         ELSE jsonb_build_object(
                'title', CASE p_type
                           WHEN 'booking_reminder_24h' THEN 'Appointment tomorrow'
                           WHEN 'booking_reminder_2h'  THEN 'Appointment in 2 hours'
                           WHEN 'rebook_nudge'         THEN 'Time for your next visit?'
                           WHEN 'review_request'       THEN 'How was your visit?'
                           WHEN 'recovery_checkin'     THEN 'We''d love to see you again'
                         END,
                'body', '...',  -- per-template body from §10
                'booking_id', p_booking_id,
                'shop_name', v_shop_name
              )
    END
  ) RETURNING id INTO v_notif_id;

  RETURN v_notif_id;
END;
$$;
```

### 18. Manual reminder enum (`booking_reminder_manual`) — does it leak into Phase 12?

No. The manual reminder uses its own RPC ([schedule_manual_booking_reminder.sql:25-89](../../../supabase/migrations/20260604000200_schedule_manual_booking_reminder.sql#L25-L89)) and its own enum value. Phase 12 does NOT replace it — it adds three new categories alongside. Verify that Phase 12's new categories don't overlap on the partial unique index from Finding 9: only `rebook_nudge` and `recovery_checkin` need cooldown — the manual category does not (per its SPEC comment line 21).

### 19. Wave 0 / verification gaps

For the planner's test plan:
- **No pgTAP runner exists.** Per Phase 10 / Phase 11 precedent, SQL tests go in `supabase/tests/phase12_smoke.sql` as runnable psql snippets (manual). Document in PR.
- **Dart unit tests** go in `test/dashboard/client_sticky_note_test.dart` (new file). Use `mocktail` (already in pubspec).
- **Widget test for `ClientStickyNoteCard`** — verify Save button is disabled when body unchanged from last load. Critical UX state.
- **Integration test for the trigger** — insert a `confirmed` booking 26h in the future, assert two pending rows materialize in `scheduled_notifications`. Update to `cancelled`, assert reminders flip to `cancelled` AND a `recovery_checkin` row appears. Update to `completed`, assert reminders cancelled AND `review_request` appears.

## Open questions for the user

1. **P0 — Reminder cadence ownership.** Adopt option (a) and move all reminder scheduling out of the webhooks into the trigger, or option (b) and only add the 2h reminder via the trigger? Recommend (a). User pick.
2. **P0 — `notification_type` live DB shape.** Run the one-line query in §2 against the live DB and confirm enum vs TEXT. Required before the planner writes migration #1.
3. **P1 — `client_for_booking` view.** Drop the view in favor of reading `(user_id, guest_profile_id)` from the already-loaded booking model client-side? Recommend yes — removes a migration and a coupling. User confirms.
4. **P1 — Meta WhatsApp template approval.** Three new templates (`rebook_nudge_v1`, `review_request_v1`, `recovery_checkin_v1`) need Meta approval before guest delivery works. Should template submission be a Phase 12 PR-blocking task, or shipped behind a "guests temporarily skip the three new categories" flag while Meta approves? Recommend block on submission but ship with the 6-hour-defer behavior so unapproved templates auto-retry — that's already how the worker handles `WhatsAppTemplateNotFoundError` ([index.ts:124-128](../../../supabase/functions/process-scheduled-notifications/index.ts#L124-L128)).
5. **P2 — Honor `booking_reminders_enabled` in the worker.** Out of SPEC scope, but the gap exists for existing reminder types already. Add to Phase 12 as a small extension (one-line `&& bookingRemindersEnabled` check in `isPushEnabled`), or defer to a future "notification settings polish" phase? Recommend defer.

## RESEARCH COMPLETE
