# Phase 14 — Owner Broadcast Messaging

## Outcome

Give shop owners a **single composable surface** to send one-off
messages to their clients via the channels NanoEmbryo already runs
(push for registered users, WhatsApp for guests, in-app notification
for everyone). Owners write a message, pick an audience, optionally
attach a Phase 13 promo code, and send. The Phase 12 notification
pipeline fans out one row per recipient; the worker delivers.

Use cases this unlocks:
- Operational: "Closed Friday for renovations"
- Marketing: "20% off next week — code FRIDAY20" (Phase 13 code attached)
- Announcement: "New stylist Maria joining us Monday"
- Relationship: "Thanks for supporting us this year"

The waitlist concept from earlier roadmap sketches is **dropped**
entirely. NanoEmbryo has no booking queue model; "waitlist" was
never a clean fit.

## Why this matters

- **Owner retention**: Fresha, Booksy, Square all ship owner-driven
  marketing. Without this, NanoEmbryo's owner-side surface caps at
  "respond to bookings" — passive. Broadcasts unlock proactive owner
  workflows.
- **Activates Phase 13 promo codes**: a code with `usage_limit=100`
  and no way to tell clients about it is worthless. Phase 14 is the
  distribution channel.
- **Activates Phase 12 reminder infrastructure**: the
  `scheduled_notifications` table + worker already deliver to both
  channels. Phase 14 is one more producer on the same pipe.
- **Re-engages lapsed clients**: the "Lapsed" audience preset is
  the cheapest churn-prevention tool to build because all the
  identity + history is already in `bookings`.

## Definitions

- **Broadcast** — a single owner-authored message with: `subject`
  (push title), `body` (≤ 800 chars for push, ≤ 1024 for WhatsApp),
  `audience_type` (one of 4 presets), `audience_param` (service id
  for "by service", null otherwise), optional `promotion_id`,
  `delivered_at`, `created_by_user_id`, `recipient_count`.
- **Audience** — the resolved set of (user_id | guest_profile_id)
  for a given (shop_id, audience_type, audience_param). Computed at
  send time from `bookings` history.
- **Audience presets** (v1):
  - `all_clients`: every distinct client who has any non-cancelled
    booking at this shop.
  - `recent`: last booking within 30 days.
  - `lapsed`: last booking 60+ days ago, never cancelled the whole
    relationship (any non-cancelled booking exists).
  - `by_service`: clients who have booked a specific service. Owner
    picks one `appointment_slots.id` from their active services.
- **Rate limit** — at most 1 broadcast per shop per UTC day. Server
  enforced. Owner sees a clear error when they hit it.
- **Marketing opt-in** — registered users always receive (they can
  silence via OS notification settings). Guests receive only when
  `guest_profiles.accepts_marketing = TRUE`. Default at first
  booking: TRUE. Opt-out path: WhatsApp reply with "STOP" → worker
  flips the flag (worker behavior; Phase 14 only adds the column +
  flag check).
- **Promo attachment** — optional. Owner picks an active,
  non-archived promo from their shop. Server validates the code is
  still active at send time; broadcasts a stale code raises.

## In scope

| Surface | Scope |
|---------|-------|
| **New table** `broadcasts` | One row per broadcast. Columns: `id`, `shop_id`, `subject`, `body`, `audience_type` (CHECK in 4 presets), `audience_param` (UUID, nullable), `promotion_id` (UUID, nullable, FK promotions), `created_by_user_id`, `created_at`, `delivered_at`, `recipient_count`, `status` (`pending` / `delivering` / `delivered` / `failed`). RLS: owner-only SELECT/INSERT (no UPDATE/DELETE — broadcasts are immutable once sent). |
| **New column** `guest_profiles.accepts_marketing BOOLEAN NOT NULL DEFAULT TRUE` | Per-guest opt-out flag. Defaults TRUE; worker flips on "STOP" reply (worker-side, out of Phase 14 server scope but documented). |
| **New RPC** `send_broadcast(p_shop_id, p_subject, p_body, p_audience_type, p_audience_param, p_promotion_id)` | Owner-only. SECURITY DEFINER. Authz first (shops.user_id = auth.uid()). Takes `pg_try_advisory_xact_lock(hashtext(shop_id::text))` to prevent double-tap race. Validates: rate limit (1/UTC day), audience param matches type, promo (if provided) belongs to shop AND `is_active = TRUE` AND `archived_at IS NULL` AND `(valid_to IS NULL OR valid_to > now())` AND **`source = 'owner_defined'`** (Research §6 — silent loyalty / recovery codes cannot be broadcast). Resolves audience inline via 4 SQL CTEs (lapsed uses `status IN ('confirmed','completed')` per locked decision). Enforces 1000-recipient cap server-side — raises `BROADCAST_CAP_EXCEEDED` if audience > 1000. Inserts the `broadcasts` row. Then fans out one `scheduled_notifications` row per recipient (dedup via `COALESCE(user_id::text, guest_profile_id::text)`) with `notification_type = 'marketing_broadcast'`, `scheduled_for = now()`, `delivery_channel` per recipient identity, WhatsApp template `marketing_broadcast_v1`, params `{{1}}=shop_name, {{2}}=body`. Returns `broadcast_id + recipient_count`. |
| **New enum value** `marketing_broadcast` | Added to `notification_type`. |
| **Notification worker (no change required)** | The existing `process-scheduled-notifications` worker already routes by `delivery_channel` (Phase 12 §3). It will deliver `marketing_broadcast` rows automatically. WhatsApp template `marketing_broadcast_v1` needs Meta submission as part of Wave 6. |
| **New screen** `BroadcastsScreen` | Tools tab card #8. Lists past broadcasts (descending by `created_at`), shows recipient_count + delivered_at + audience badge. Tap a row → read-only detail view (cannot edit/resend). Floating-action-button → `CreateBroadcastScreen`. |
| **New screen** `CreateBroadcastScreen` | Form: subject input (≤ 100 chars), body multi-line input (≤ 800 chars, char counter), audience-type segmented picker, audience_param dropdown (only shown when type = `by_service`), optional promo-code dropdown (loaded from `getPromotions(activeOnly: true)`, filters out archived). Live recipient-count preview computed server-side via a read-only RPC `preview_broadcast_audience`. Send button — disabled until subject + body filled. Confirmation dialog before send shows: audience preset, recipient count, attached promo (if any), "This will send to N people. This cannot be undone." |
| **New RPC** `preview_broadcast_audience(p_shop_id, p_audience_type, p_audience_param)` | Read-only. Returns `recipient_count` for the given audience. Used by the form's live preview. Same SQL CTEs as `send_broadcast` but no inserts. |
| **New typed exception hierarchy** `BroadcastException` | Subtypes: `BroadcastRateLimitException` (1/day hit), `BroadcastInvalidAudienceException` (audience_param missing for by_service), `BroadcastPromoInvalidException` (promo expired/archived/wrong shop), `BroadcastSaveFailedException` (fallback). |
| **New Dart DTO** `BroadcastDTO` + repository methods + provider | `getBroadcasts(shopId)`, `previewBroadcastAudience(...)`, `sendBroadcast(...)`. HINT-based exception mapping. |

## Out of scope (locked)

- **Waitlist of any kind.** Dropped. NanoEmbryo has no booking queue model.
- **Scheduled broadcasts** ("send Tuesday at 10am"). v1 is send-now only. Scheduling adds a cron concept and an editable draft state.
- **Multi-step campaigns / drip sequences.** Single-shot only.
- **A/B testing.**
- **Edit / resend an existing broadcast.** Broadcasts are immutable; owner composes a new one if they want a follow-up.
- **Cancel a sent broadcast.** Once `send_broadcast` returns, the rows are in the worker queue. No recall.
- **Per-client targeting** (pick John Doe and message just him). The `client_notes` UI gives owners private context per client but is NOT a messaging surface. Targeted DMs are future scope; v1 is audience-based broadcast only.
- **Email / SMS-direct.** NanoEmbryo doesn't use these channels. WhatsApp + push + in-app only.
- **Owner-facing delivery analytics** beyond `recipient_count`. No "X% opened" / "X% clicked" in v1.
- **Translation of the audience presets / form copy.** Phase 14 ships EN keys only (same pattern as Phase 13.1).
- **Broadcast templates** ("here's a template for a holiday closure"). Owner writes free-form.
- **Rich content** (images, attachments, formatted text). Plain text body only.
- **Audience size cap.** A shop with 10,000 clients can broadcast to all of them in one call. We rely on the rate limit (1/day) for spam protection; raw fan-out is unbounded.
- **Phase 13 promo code creation from inside broadcast flow.** Owner must create the code first via PromotionsScreen, then attach. No inline create.

## Data sources / infrastructure already in place

- `scheduled_notifications` table + `process-scheduled-notifications` worker — Phase 12.
- `delivery_channel` branching in the worker (push vs WhatsApp) — Phase 12 §3.
- `promotions` table with `is_active` + `archived_at` — Phase 13 Wave 0.
- `bookings` with `user_id` / `guest_profile_id` identity + `status` — Phase 10.
- `guest_profiles.phone` + denormalized `bookings.guest_phone` — Phase 12 §17.
- `shops.user_id = auth.uid()` ownership pattern — every prior phase.
- Hardening template (authz first, HINT codes, REVOKE/GRANT, COMMENT ON FUNCTION) — Phase 11.
- Typed-exception client pattern (HINT → exception subtype, no string matching) — Phase 11, 12, 13.
- LoyaltyRuleScreen precedent for owner-form UX (explicit Save, dirty-check, error toasts) — Phase 13.
- Tools tab card pattern — Phase 11, 12, 13.

## Server changes (high-level)

| Migration | Purpose |
|-----------|---------|
| `add_marketing_broadcast_notification_type.sql` | `ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'marketing_broadcast'` |
| `add_accepts_marketing_to_guest_profiles.sql` | `ALTER TABLE guest_profiles ADD COLUMN IF NOT EXISTS accepts_marketing BOOLEAN NOT NULL DEFAULT TRUE` |
| `broadcasts_table.sql` | New table + RLS (owner SELECT, owner INSERT, no UPDATE / no DELETE) + index on `(shop_id, created_at DESC)` |
| `preview_broadcast_audience_rpc.sql` | Read-only count for the form's live preview. Authz first. |
| `send_broadcast_rpc.sql` | The hot path. Authz first → rate-limit check → audience-param validation → promo validation → audience resolution → broadcasts insert → fan-out into scheduled_notifications → return id + count. |

## Client changes

| File | Change |
|------|--------|
| `lib/presentation/features/shops/dashboard/data/models/broadcast_dto.dart` (NEW) | DTO |
| `lib/presentation/features/shops/dashboard/data/exceptions/broadcast_exceptions.dart` (NEW) | Typed hierarchy |
| `lib/presentation/features/shops/dashboard/data/repositories/promotions_repository.dart` | Add `getBroadcasts`, `previewBroadcastAudience`, `sendBroadcast` methods. Existing file matches Phase 13 pattern. |
| `lib/presentation/features/shops/dashboard/providers/broadcasts_provider.dart` (NEW) | `FutureProvider.family<List<BroadcastDTO>, String>` keyed by shopId |
| `lib/presentation/features/shops/dashboard/presentation/screens/broadcasts_screen.dart` (NEW) | List view |
| `lib/presentation/features/shops/dashboard/presentation/screens/create_broadcast_screen.dart` (NEW) | Compose form |
| `lib/presentation/features/shops/dashboard/presentation/screens/tools_screen.dart` | Add card #7 (or whichever index is next) routing to BroadcastsScreen |
| `lib/i10n/app_en.arb` | ~25 new keys for the two screens + exception userMessages |

## Non-functional requirements

- **Atomicity:** the broadcast row insert + fan-out happen inside a single RPC. If fan-out partially fails, the whole call rolls back. Owner sees a clean error; no half-sent broadcasts.
- **Idempotency:** the rate-limit check is the de facto idempotency guard. An owner who taps Send twice within a second gets the second call rejected by the 1/day limit (assuming the first succeeded). For race conditions inside the same second, the broadcasts insert is protected by an advisory lock on `shop_id` during the RPC.
- **Authz:** every owner-facing RPC checks `shops.user_id = auth.uid()`. `preview_broadcast_audience` is owner-only too — clients don't get to count their fellow customers.
- **Performance:** audience resolution must complete in <500ms for a shop with 5000 clients. Verified via EXPLAIN ANALYZE in the plan.
- **Observability:** AppLogger fields on every Dart-side RPC call (`shop_id`, `audience_type`, `recipient_count`, `error_code`).
- **No PII leakage:** `scheduled_notifications.metadata` includes only `{title, body, broadcast_id, shop_name}`. NO recipient phone numbers in metadata (worker reads phone from `bookings.guest_phone` or `guest_profiles.phone` directly at delivery time).
- **WhatsApp template:** `marketing_broadcast_v1` template needs Meta submission as Wave 6. Variables: `{{1}}` = `shop_name`, `{{2}}` = `body`. Existing 6h `WhatsAppTemplateNotFoundError` retry covers the approval window (same pattern as Phase 12 / 13).

## Success criteria

1. Owner navigates Tools → Broadcasts → tap "+". Form opens.
2. Owner types subject + body. Audience picker defaults to "All clients". Live preview shows the recipient count (>0 for a shop with bookings).
3. Owner picks "By service" — service dropdown appears, populated with their active services.
4. Owner picks "Lapsed (60+ days)" — count updates accordingly. Returns 0 for a fresh shop with only recent bookings.
5. Owner attaches a Phase 13 promo code from the dropdown. Confirmation dialog shows "with code SUMMER10".
6. Owner taps Send. Broadcast appears in the list with `delivered_at` populated and the correct `recipient_count`.
7. Owner taps Send again within the same UTC day — error: "You've already sent a broadcast today. Try again tomorrow."
8. Owner attaches an expired/archived promo and taps Send — error: "This code is no longer valid. Pick another or remove the code."
9. The matching `scheduled_notifications` rows exist with `status='pending'`, `notification_type='marketing_broadcast'`, and correct `delivery_channel` per recipient (push for registered, whatsapp for guests with `accepts_marketing=true`, skipped for opted-out guests).
10. A guest with `accepts_marketing = FALSE` does NOT appear in `recipient_count` and does NOT get a `scheduled_notifications` row.

## Research-phase resolutions (all answered 2026-06-07)

- **`shops.timezone` doesn't exist** in the codebase (Research §1). UTC day rate limit is locked because shop-local TZ isn't an available primitive. Edge case (8pm PDT broadcast + 8:01pm PDT crosses UTC midnight) documented and accepted.
- **`enqueue_booking_reminder` cannot be reused** (Research §2). It requires booking_id. Phase 14 writes `scheduled_notifications` rows directly inside the send_broadcast fan-out CTE.
- **Worker requires ZERO code changes** (Research §3). Verified by worker source read: branches purely on `delivery_channel`, no notification_type allowlist.
- **`bookings.status` is exactly 5 values**: `('pending','confirmed','cancelled','completed','no_show')`. "All clients" predicate = `status != 'pending'` (excludes incomplete checkout attempts; includes everyone else).
- **`scheduled_notifications` supports broadcast fan-out as-is** (Research §3). booking_id is nullable; broadcast rows carry NULL.
- **AUDIENCE SIZE CAP — LOCKED 1000.** Meta's WhatsApp tier system: a single shop fanning out 10k messages burns the platform's whole-portfolio tier. 1000 matches the next-up Meta tier and protects every other shop's deliverability. Shops with >1000 clients can broadcast across multiple days.
- **PROMO TYPE LOCKED — owner_defined only.** `send_broadcast` rejects promos with `source IN ('loyalty', 'recovery')` to preserve the silent-loyalty contract from Phase 13.
- **LAPSED LOCKED — STRICT.** Lapsed audience = clients whose most recent **confirmed OR completed** booking is 60+ days ago. Cancelled-only relationships are excluded as not meaningfully engageable.
- **WhatsApp template body LOCKED** — includes "Reply STOP to opt out of marketing messages." per Meta marketing-category rules. Template `marketing_broadcast_v1` body: `"{{1}}: {{2}} Reply STOP to opt out of marketing messages."` where {{1}} = shop_name, {{2}} = body.
- **Status='delivering' UX LOCKED** — list shows the 4 statuses (pending/delivering/delivered/failed). Tooltip on delivering rows shows "Awaiting WhatsApp template approval — auto-retrying every 6h." for up to 24h.
- **Subject cap LOCKED 100 chars** (standard push title length).
- **EXPLAIN check deferred** — dev DB is empty; revisit when prod has data.
- **Guest opt-out UI deferred** — v1 platform-mediated only. STOP-reply worker behavior is a separate follow-up phase.

## Risk register

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Fan-out is slow for shops with 10k+ clients | M | EXPLAIN ANALYZE gate; if >500ms, add a partial index on bookings. Worst case: fan-out runs in background via a `pending` broadcast status the worker advances. |
| WhatsApp marks the platform's number spammy after marketing wave | H | 1/day rate limit; guest opt-in default-true but trivially reversible via STOP reply; Meta-approved template format. |
| Owner broadcasts a code they thought was unused but already expired | M | `send_broadcast` re-validates `promotions.is_active = TRUE AND archived_at IS NULL AND valid_to > now()` before fan-out. Raises typed exception with hint `PROMO_NOT_VALID`. |
| Owner accidentally broadcasts to "All clients" thinking they picked "Recent" | M | Confirmation dialog explicitly shows audience preset + recipient_count + "cannot be undone" before send. |
| `marketing_broadcast` notification_type collides with future enum addition | L | Same defensive pattern as Phase 12 / 13: `ALTER TYPE ... ADD VALUE IF NOT EXISTS`. |
| Duplicate fan-out under retry storm (owner taps Send twice in same second) | L | RPC takes a `pg_try_advisory_xact_lock(hashtext(shop_id::text))` at the top; second call returns "rate limited" before any insert. |
| Race between two owner sessions composing different broadcasts | L | Same advisory lock + 1/day rate limit. Only one wins. |
| Lapsed audience count is misleading if shop has zero history | L | Live preview shows 0; the form allows Send with 0 (degenerates to a row with `recipient_count=0` and no fan-out — owner sees the audit row but nothing happened). Documented. |
| `accepts_marketing` flag drift between guests with multiple profile rows | L | Phone is UNIQUE on `guest_profiles` (Phase 12 §17). One flag per phone. |
| Owner-side polling on the broadcasts list mid-fan-out shows incomplete `recipient_count` | L | Status starts as `delivering`; RPC sets `delivered` only after fan-out completes. List view shows the status badge. |
| WhatsApp template approval blocks Phase 14 PR | M | Same as Phase 12 / 13 — submit during Wave 0, worker auto-retries with 6h backoff until approved. PR merges without approval. |

## Phase boundary

Phase 14 ships:
- Server: 5 migrations (enum add, opt-in column, broadcasts table, preview RPC, send RPC).
- No edge function changes — worker handles `marketing_broadcast` automatically via `delivery_channel` branching from Phase 12.
- Client: 2 new screens, 1 DTO, 1 exception hierarchy, 3 repository methods, 1 provider, tools_screen card add, ~25 i18n keys.
- 1 new Meta WhatsApp template (`marketing_broadcast_v1`).

Phase 14 does NOT ship:
- Worker behavior to flip `accepts_marketing` on STOP reply (separate follow-up).
- Scheduled / drip broadcasts (future phase).
- Per-client direct messaging UI (out of scope; client_notes is read-only owner memory).
- Email / SMS-direct (architecture doesn't support).
- Broadcast analytics beyond recipient_count.
- Translations of new strings beyond EN.
