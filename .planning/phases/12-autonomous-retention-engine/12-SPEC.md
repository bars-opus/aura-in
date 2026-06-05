# Phase 12 — Autonomous Retention Engine

## Outcome

Convert the booking flow's "fire-and-forget" lifecycle into an
**autonomous, data-driven retention loop**. Every booking now
triggers a multi-stage notification schedule and a per-client memory
surface, with zero shop-owner configuration. Specifically:

1. **Multi-stage reminders** — every confirmed booking auto-schedules
   `booking_reminder_24h` and `booking_reminder_2h` rows in
   `scheduled_notifications`. Cancellation/reschedule cancels them.
2. **Re-book nudge** — N days after the last `completed` booking
   (where N = the shop's median booking-gap), the client gets a
   "Time to book again?" message. N is recomputed nightly per shop.
3. **Review request** — T+2h after a booking is marked `completed`,
   the client gets a one-tap rating prompt.
4. **Recovery check-in** — when a booking flips to `cancelled` or
   `no_show`, the client gets a soft re-engagement message after 7
   days. No discount code (those wait for Phase 13's promo engine).
5. **Client-sticky notes** — owners can write a private per-client
   note that surfaces on every future `BookingDetailScreen` for that
   client. Square parity. Client never sees them.

All five rules are **autonomous**: zero owner toggles, zero manual
sends, zero client opt-in screens. The owner can disable a category
globally in shop settings (out-of-scope for v1 — defer to 12.5 if
needed).

## Why this matters

- Phase 10 just gave us cancellation/no-show data. Phase 11 just made
  the shop's services/hours editable. Both feed into retention but
  neither closes the loop. Phase 12 is what turns the platform from
  "appointment system" into "client-relationship engine."
- Competitor parity gap: Fresha, Booksy, and Vagaro all auto-send
  reminders + review requests out-of-the-box. Owners expect it.
- The autonomy constraint matters because **most owners on this
  platform are solo operators** (barbers, individual stylists,
  freelancers). They will not configure retention rules. The system
  must run itself.
- Square's stickiest owner-retention feature is the per-client note
  surface ("Ama prefers no fringe"). NanoEmbryo's existing
  per-booking requirements feature is the wrong shape — it doesn't
  persist across visits. Sticky notes close that gap.

## Definitions

- **Notification target identity** — for registered users, the
  recipient is `auth.users.id`. For guest bookings (`bookings.user_id
  IS NULL AND guest_profile_id IS NOT NULL`), the recipient is the
  WhatsApp phone on `guest_profiles.phone`. Phase 12 extends the
  notification pipeline to handle both.
- **Booking-gap median** — for a given shop, the median of
  `start_time(i+1) - start_time(i)` across all `completed` bookings
  for each repeat client, computed across all clients of that shop.
  Floors at 7 days, ceilings at 90 days. Defaults to 30 days when the
  shop has fewer than 5 repeat-client samples.
- **Recovery window** — 7 days. Hardcoded. Not configurable in v1.
- **Sticky note** — a single TEXT body (≤2000 chars) keyed on
  `(shop_id, client_identity)` where client_identity is either
  `user_id` or `guest_profile_id`. Owner-authored only; client never
  reads it.
- **Notification category** — one of:
  `booking_reminder_24h`, `booking_reminder_2h`, `rebook_nudge`,
  `review_request`, `recovery_checkin`. The first two already exist
  in the enum; Phase 12 adds the last three.

## In scope

| Surface | Scope |
|---------|-------|
| `bookings INSERT` trigger | After a booking row hits status `confirmed`, schedule `booking_reminder_24h` (at start_time - 24h) and `booking_reminder_2h` (at start_time - 2h). Skip if start_time is already inside that window. |
| `bookings UPDATE` trigger | When status flips to `cancelled` or `no_show`: cancel pending reminders via existing `cancel_booking_notifications`, then schedule `recovery_checkin` for now()+7d. When status flips to `completed`: cancel pending reminders, then schedule `review_request` for now()+2h. |
| **New nightly cron** `enqueue_rebook_nudges()` | SECURITY DEFINER function. For every (shop, client) pair where (a) last_completed_booking + shop_median_gap == today and (b) no booking exists in the future and (c) no `rebook_nudge` row has been sent for this client in the last 30d, insert a `scheduled_notifications` row. Idempotent via UNIQUE partial index. |
| **New view** `shop_rebook_cadence` | Per-shop median gap. Materialized nightly. Floors at 7, ceilings at 90, default 30. |
| **New table** `client_notes` | `(id, shop_id, user_id NULLABLE, guest_profile_id NULLABLE, body TEXT, updated_at, updated_by_user_id)`. CHECK: exactly one of user_id/guest_profile_id is non-null. UNIQUE on `(shop_id, COALESCE(user_id::text, guest_profile_id::text))`. RLS: only the shop owner can SELECT/INSERT/UPDATE. |
| **New RPC** `upsert_client_note(p_shop_id, p_user_id, p_guest_profile_id, p_body)` | Authz: shop owner only. Upsert by the unique key. HINT codes per hardening template. |
| ~~`client_for_booking(booking_id)` view~~ | REMOVED — sticky-note card reads identity from the already-loaded booking model on the client. |
| `BookingDetailScreen` | Under `if (widget.isShopOwner)`, render a `ClientStickyNoteCard` that loads from `client_notes` keyed on the booking's client identity. Inline TextField + Save button. Loads via FutureProvider, saves via RPC. |
| **Notification delivery edge fn** | Extend the existing `process-scheduled-notifications` worker to dispatch to guest WhatsApp numbers when `booking_id` resolves to a guest booking. The worker already calls OneSignal for push and WhatsApp for guests in the link-booking flow — wire the same path here. |
| **Notification copy** | Hardcoded English templates in v1 (i18n is Phase 14+ scope). Each category has one template parametrized by shop name + (optional) start_time. |
| **Owner notification preferences hook** | Read `notification_settings` (existing table) for the SHOP OWNER's preference on the new categories, defaulting to all-on. Per-client granularity is out of scope. |

## Out of scope (locked)

- **Per-shop reminder cadence customization** — owners cannot pick T-48h vs T-24h. Hardcoded.
- **Per-shop message copy editing** — the templates are fixed for v1. Defer to Phase 14 (broadcast/marketing).
- **Discount codes in recovery messages** — depends on Phase 13's promo engine. Recovery is text-only in v1.
- **Birthday reminders** — we don't collect DOB. Locked out unless/until a separate collection flow ships.
- **Per-client notification preferences** — clients cannot opt out of individual categories in v1. They can disable all notifications via system OS settings or via the WhatsApp opt-out reply.
- **Manual "send promo to this client" UI** — no manual sends in Phase 12. Phase 14 broadcast scope.
- **Loyalty / repeat-visit rewards** — Phase 13.
- **Multi-language templates** — Phase 14.
- **Note attachments / photos** — sticky notes are TEXT only.
- **Note history / audit log** — last-write-wins. We track `updated_by_user_id` for forensic only; no separate audit table.
- **Per-worker notes** ("Ama prefers Worker X") — notes are per-shop, not per-worker. Owners can write the worker preference into the body.

## Data sources / infrastructure already in place

- `scheduled_notifications` table — verified at
  [20260507000000_notification_engine.sql:18-32](../../../supabase/migrations/20260507000000_notification_engine.sql#L18-L32). `notification_type` is TEXT (not enum) so adding new categories is a one-line metadata change.
- `cancel_booking_notifications(p_booking_id)` — already cancels
  pending rows by booking. Used directly by the new UPDATE trigger.
- `process-scheduled-notifications` edge fn — existing cron worker.
  Already dispatches to OneSignal + WhatsApp.
- Existing `booking_reminder_24h` notification_type — verified at
  [20260602130000_add_notification_type_enum_values.sql](../../../supabase/migrations/20260602130000_add_notification_type_enum_values.sql).
- `notification_settings` table — exists, used for owner-level
  toggles.
- `guest_profiles` table — has phone (UNIQUE), name, locale. Verified
  at [20260528120000_link_booking_guest_support.sql:11-55](../../../supabase/migrations/20260528120000_link_booking_guest_support.sql#L11-L55).
- `bookings.status` column with cancel/no_show/completed values —
  Phase 10 work already canonicalized these.
- `BookingDetailScreen.isShopOwner` branching — verified at
  [booking_detail_screen.dart:131](../../../lib/presentation/features/shops/booking/presentation/screens/shared/booking_detail_screen.dart#L131).
- Pattern for hardened RPCs — Phase 11 template
  ([20260603001500_harden_dashboard_rpcs.sql](../../../supabase/migrations/20260603001500_harden_dashboard_rpcs.sql)).
  Authz-first ordering, HINT codes, REVOKE/GRANT, COMMENT ON
  FUNCTION.

## Server changes

### Migrations (in order)

1. `add_phase12_notification_types.sql` — `ALTER TYPE notification_type ADD VALUE IF NOT EXISTS` for `rebook_nudge`, `review_request`, `recovery_checkin`. **Live DB confirmed `notification_type` is a custom enum** (query result 2026-06-05: `typname = notification_type`).
2. `client_notes_table.sql` — new table + RLS + UNIQUE index + check
   constraint. RLS mirrors the `wallets` / `payment_schema` owner-only
   template verbatim; idempotent `CREATE POLICY IF NOT EXISTS`.
3. `upsert_client_note_rpc.sql` — SECURITY DEFINER, hardened per the
   Phase 11 template.
4. `shop_rebook_cadence_view.sql` — materialized view + nightly
   refresh via pg_cron (confirmed installed). Floor 7d, ceiling 90d,
   default 30d for shops with <5 repeat-client samples.
5. `booking_lifecycle_triggers.sql` — AFTER INSERT (on confirmed) on
   `bookings` schedules 24h + 2h reminders. UPDATE-to-cancelled /
   no_show / completed is handled inside the existing `cancel_booking`,
   `mark_booking_no_show`, `mark_booking_complete` RPCs by calling a
   new `cancel_and_followup(p_booking_id, p_terminal_status)` helper —
   simpler than a generic trigger and easier to test. (Research §4.)
6. `consolidate_reminder_scheduling.sql` — one-time backfill: for
   every confirmed/future booking with no pending
   `booking_reminder_24h` row, insert one. Required because the next
   step removes the webhook-side scheduling.
7. `enqueue_rebook_nudges_rpc.sql` — the nightly SQL function (pg_cron
   confirmed) + cron entry. Guarded by partial unique index on
   `(shop_id, COALESCE(user_id::text, guest_profile_id::text),
   notification_type, scheduled_for::date)` WHERE status='pending'.
8. **Edge-fn diffs (NOT migrations, captured in the PR):**
   - `paystack-webhook` — DELETE reminder-insert blocks at
     [index.ts:269-292](../../../supabase/functions/paystack-webhook/index.ts#L269-L292)
     (guest path) and
     [index.ts:524-543](../../../supabase/functions/paystack-webhook/index.ts#L524-L543)
     (registered path). Keep `booking_confirmation` / `booking_review_prompt`
     immediate inserts.
   - `stripe-webhook` — DELETE reminder-insert block at
     [index.ts:337-360](../../../supabase/functions/stripe-webhook/index.ts#L337-L360).
   - `verify-payment` — DELETE reminder-insert block at
     [index.ts:298](../../../supabase/functions/verify-payment/index.ts#L298).
   - `process-scheduled-notifications` — **no change needed**. Worker
     already branches on `delivery_channel`; trigger writes the right
     columns.

### Reminder ownership (LOCKED)

The new INSERT trigger on `bookings` is the **single source** of
`booking_reminder_24h` and `booking_reminder_2h` rows. All three
webhook call sites lose their reminder inserts in the same PR.
Pure-cash / non-webhook bookings now get reminders for free.

### WhatsApp template approval

Three new Meta WhatsApp templates ship with this PR:
`rebook_nudge_v1`, `review_request_v1`, `recovery_checkin_v1`.
Templates submitted as part of the Phase 12 PR. Worker's existing
6-hour `WhatsAppTemplateNotFoundError` retry behavior covers the
approval window — unapproved templates auto-retry until Meta
approves; no flag, no skip logic.

### Removed from scope

- `client_for_booking(booking_id)` view — REMOVED. The sticky-note
  card reads `user_id` / `guest_profile_id` from the
  already-loaded booking model on the client. One fewer migration,
  one fewer coupling. (Research §7.)
- Honoring `booking_reminders_enabled` in the worker — deferred to a
  future "notification settings polish" phase. The gap exists for
  existing reminder types already and doesn't worsen with Phase 12.

### Authz model

- All new RPCs (`upsert_client_note`) check `auth.uid() = shops.user_id` for the target shop, raise `INSUFFICIENT_PRIVILEGE` (42501) otherwise.
- `enqueue_rebook_nudges` runs as the cron user (service role); not exposed to clients.
- `client_notes` RLS:
  ```sql
  CREATE POLICY client_notes_owner_only ON client_notes
    USING (shop_id IN (SELECT id FROM shops WHERE user_id = auth.uid()))
    WITH CHECK (shop_id IN (SELECT id FROM shops WHERE user_id = auth.uid()));
  ```

## Client changes

| File | Change |
|------|--------|
| `lib/presentation/features/shops/booking/presentation/screens/shared/booking_detail_screen.dart` | Add `ClientStickyNoteCard` under the `isShopOwner` branch. ~30 lines. |
| `lib/presentation/features/shops/dashboard/presentation/widgets/client_sticky_note_card.dart` | New widget. TextField + explicit Save button (no debounce auto-save). Loads via `clientNoteProvider(bookingId)`, saves via repo RPC. Disables Save when body is unchanged from last load. |
| `lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart` | Add `getClientNote`, `upsertClientNote` methods. Error-map via typed exceptions. |
| `lib/presentation/features/shops/dashboard/data/exceptions/client_notes_exceptions.dart` | New typed exception hierarchy (NoteAccessDenied, NoteSaveFailed, NotePayloadInvalid). |
| `lib/presentation/features/shops/dashboard/providers/client_note_provider.dart` | `FutureProvider.family<ClientNoteDTO?, String bookingId>`. |
| `lib/presentation/features/shops/dashboard/data/models/client_note_dto.dart` | DTO. |

**No client work for the notification rules** — they're fully
server-side. The Flutter app already renders `in_app_notifications`
and `scheduled_notifications` → push, so once the triggers fire, the
existing pipelines deliver.

## Non-functional requirements

- **Atomicity**: booking-status-change must schedule/cancel
  notifications in the same transaction. A status update that
  succeeded but failed to cancel pending reminders is a bug.
- **Idempotency**: re-running `enqueue_rebook_nudges` on the same
  day must not double-schedule. Enforced by `(shop_id, client_id,
  notification_type, scheduled_for::date)` partial unique index on
  pending rows.
- **Authz**: enforced server-side. Client trust = 0.
- **Observability**: AppLogger fields on every client-side RPC call
  (`shop_id`, `booking_id`, `rpc`, `error_code`).
- **Performance**: `enqueue_rebook_nudges` must complete in <30s for
  10k active shops. Verified via EXPLAIN ANALYZE in the plan.
- **No PII leakage**: notification metadata (the `metadata` JSONB
  column) contains only `{title, body, shop_name}`. No phone numbers,
  no email addresses, no booking amount in the row.

## Success criteria

1. Creating a `confirmed` booking 26h in the future inserts exactly 2
   pending rows in `scheduled_notifications` (24h + 2h reminders).
2. Cancelling that booking flips both reminder rows to `cancelled`
   and inserts 1 `recovery_checkin` row scheduled for now()+7d.
3. Marking the booking `completed` cancels reminders and inserts 1
   `review_request` row scheduled for now()+2h.
4. After running `enqueue_rebook_nudges()` once: re-running it the
   same day produces ZERO new rows.
5. A shop with only 1 completed booking gets the default 30-day
   cadence (verified via the view).
6. A shop owner sees the sticky note card on a booking they own; a
   different owner sees an error/empty state when forced into the
   same screen.
7. The note persists across all future bookings by the same client at
   the same shop (verified with a 2nd booking for the same
   user_id/guest_profile_id).
8. Guest bookings (no `user_id`, only `guest_profile_id`) receive the
   same multi-stage reminder flow via WhatsApp.

## Research-phase resolutions (all answered 2026-06-05)

- **pg_cron**: installed and operational. `enqueue_rebook_nudges` is a SQL function + pg_cron schedule. No Deno fallback needed. (Research §14.)
- **`notification_type` shape**: custom enum `notification_type` (live DB confirmed). Migration #1 uses `ALTER TYPE ... ADD VALUE IF NOT EXISTS`.
- **`process-scheduled-notifications` channel branching**: worker branches on `delivery_channel` already. Zero edge-fn diff for delivery; the gap is on the producer side (the new trigger must populate `delivery_channel`, `whatsapp_template`, `whatsapp_params`, `metadata.phone` for guest rows). (Research §3.)
- **Booking median gap**: not measured on live data yet — view's defaults (floor 7d, ceiling 90d, default 30d) absorb the unknowns. The materialized view recomputes nightly so the system self-tunes.

## Risk register

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Trigger writes break on legacy bookings missing fields | M | Wrap helpers in defensive NULL checks; smoke-test against an old completed booking. |
| pg_cron not available → no nightly refresh | M | Fallback to Deno cron worker (already exists for `process-scheduled-notifications`). |
| Notification spam after a status flip-flop (confirmed→cancel→confirmed) | L | Triggers always cancel-first-then-schedule; idempotent on rebookings. |
| Sticky notes leak via mis-scoped RLS | H | Plan-check gate: explicit RLS test in the smoke SQL. Note loader uses `client_for_booking` view, not raw column. |
| Recovery message spams a client who cancels often | M | Cooldown: max 1 `recovery_checkin` per client per shop per 30d (same partial unique pattern as rebook nudge). |
| WhatsApp dispatch for guests fails silently | M | Edge-fn changes land with structured logging on dispatch outcome. |

## Phase boundary

Phase 12 ships:
- Server: 6 migrations + 1 edge-function diff.
- Client: 1 widget, 1 provider, 1 DTO, 1 exception file, 2 repo
  methods.

Phase 12 does NOT ship:
- The owner-settings screen for category-level toggles (defer).
- The promo engine that recovery_checkin will eventually use (Phase 13).
- The broadcast/marketing surface (Phase 14).
