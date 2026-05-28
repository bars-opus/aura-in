# Public Link Booking — Browser Flow for Guest Clients

## Problem

Aura-In's mobile app handles shop/freelancer booking end-to-end for authenticated users, but the value chain breaks at the client side: clients have to download the app to book. Most don't, walk in anyway, and shop owners lose the structure and insight that booking provides.

The fix is to remove the "download an app" step entirely. Shop owners and freelancers get a shareable link (`aura-in-web.vercel.app/book/<slug>`) that opens directly in any mobile browser. Clients book in under 2 minutes, pay a deposit via the same payment infrastructure the app uses, and the booking lands in the owner's existing dashboard.

## Goal

Ship a public, anonymous, mobile-browser booking flow that:

- Loads in <3s on simulated 3G
- Requires only a phone number and name from the client (no account, no OTP)
- Reuses the existing payment infrastructure (Paystack + Stripe via the existing `PaymentProviderPort`)
- Sends WhatsApp confirmation + reminders to the guest
- Lands the booking in the same `bookings` table as authenticated bookings — same realtime, same push notification to the shop owner
- Supports both shops and freelancers (with conditional worker / address steps)
- Zero changes to the existing mobile wizard

## Non-Goals (deferred)

- Client-side cancellation + refund (v2)
- Inbound WhatsApp agent for booking via chat (Spec 4)
- Flutterwave + Razorpay provider adapters (separate specs)
- Extraction of the linking engine into a plug-and-play package (Spec 1)
- Custom shop branding on the booking page (v2)
- Multi-service bundle / group bookings via web (v2)

## Locked Decisions

These were chosen during brainstorming on 2026-05-28; they are inputs to the plan, not open questions.

1. **Web stack: Next.js 14** on Vercel. Server-rendered HTML with a single client component for slot interactivity. Tailwind, no UI library. Reason: hard <3s requirement on slow Ghanaian connections rules out Flutter Web (~5MB bundle) and requires the lightest framework that still gives us interactivity and proper routing.

2. **Guest identity: phone-based server lookup.** No OTP. No forced registration. `phone` is the identity key. Repeat clients are recognized by phone and prefilled. Privacy tradeoff accepted: only low-sensitivity fields (name + last service categories) are returned.

3. **Schema: `guest_profiles` table + nullable `user_id` on bookings.** Snapshot columns (`guest_name`, `guest_phone`) on bookings preserve booking integrity even if the profile updates. Check constraint enforces exactly one of `user_id` or `guest_profile_id`.

4. **Paystack flow: hosted-page redirect.** Same as the mobile WebView path. The Next.js page calls `create-booking`, gets back an `authorizationUrl`, redirects. The page itself never loads Paystack JS. Webhook path is identical to the mobile flow.

5. **Worker selection: optional step shown for shops** (matching mobile wizard behavior). Skipped entirely for freelancers.

6. **Page layout: single-page scroll.** All sections visible at once. No multi-step wizard on web (multi-step works on mobile because page transitions are native; on web each transition is a round-trip).

7. **Universal Links enabled.** iOS App Site Association + Android assetlinks.json served from the Next.js app. Installed-app users get deep-linked into the existing booking flow; uninstalled users get the web flow. Web is the fallback and the source of truth.

8. **Shop slug: auto-generated from name, editable by owner.** Slugified shop name, suffix-on-collision, reserved-slug check (existing in `AuraInLinkConfig`). Owner can edit later in shop settings.

9. **WhatsApp provider: Meta Cloud API direct.** Cheapest at scale, supports the user's longer-term plan to build a WhatsApp booking agent. Templates approved through Meta directly.

10. **WhatsApp message scope: all four templates.** Confirmation (immediate), 24h reminder, 2h reminder, post-appointment review prompt.

11. **Cancellation: not in v1.** Deposit is non-refundable. Shop owner manually cancels in the mobile app if needed.

12. **Payment provider scope: Paystack + Stripe only.** Web layer is provider-agnostic (just redirects to whatever URL `create-booking` returns). Flutterwave + Razorpay added in separate specs once they have adapters.

## Architecture

```
┌─────────────────────────────────┐     ┌──────────────────────────────┐
│  WhatsApp / Instagram bio       │     │  Aura-In mobile app          │
│  shares a link                  │     │  (Flutter, existing)         │
└────────────┬────────────────────┘     └──────────────┬───────────────┘
             │                                          │
             ▼                                          ▼
   ┌─────────────────────┐              ┌──────────────────────────┐
   │  Next.js app on     │              │  Universal Link detects  │
   │  aura-in-web        │  ◄───────►   │  installed app → opens   │
   │  .vercel.app        │  fallback    │  app at shop screen       │
   │  /book/<slug>       │              │  (existing wizard flow)  │
   └─────────┬───────────┘              └──────────────┬───────────┘
             │                                          │
             └────────────── Same backend ─────────────┘
                                  │
                                  ▼
              ┌─────────────────────────────────────┐
              │  Supabase                           │
              │  ├─ resolve-link (NEW)              │
              │  ├─ lookup-guest (NEW)              │
              │  ├─ create-booking (extended)       │
              │  ├─ paystack-webhook (extended)     │
              │  ├─ stripe-webhook (extended)       │
              │  ├─ whatsapp-send (NEW)             │
              │  ├─ whatsapp-webhook (NEW)          │
              │  ├─ process-scheduled-notifications │
              │  │  (extended: WhatsApp channel)   │
              │  └─ bookings + guest_profiles +     │
              │     guest_booking_history           │
              └─────────────────────────────────────┘
```

Core design principle: **one system with two thin presentation layers over a shared backend**. The mobile wizard is untouched. The web flow is a separate, single-page UI that talks to the same `create-booking` edge function with guest fields instead of `userId`. Both converge at the database.

## Components

### New components

**1. `aura-in-web/` — Next.js 14 app on Vercel**
- `app/book/[slug]/page.tsx` — server component, single round-trip to `resolve-link`
- `app/book/[slug]/success/page.tsx` — confirmation page with reference polling
- `app/book/[slug]/error/page.tsx` — graceful error page
- One client component (`SlotPicker`) for slot interactivity
- Tailwind, no UI library
- Mapbox JS geocoder lazy-loaded only on freelancer-with-canTravel pages

**2. `resolve-link` edge function**
- Public, no auth
- Input: `?slug=<x>`
- Output: `{ targetType: 'shop' | 'freelancer', target, services, workers?, canTravel?, travelRadiusKm?, slots, depositFraction, platformFeeFraction }`
- Increments LinkService click counter
- Returns 404 if slug doesn't exist, 410 if expired
- Cacheable at the edge for ~30s

**3. `lookup-guest` edge function**
- Public, no auth, rate-limited
- Input: `{ phone }`
- Output: `{ name?, lastServices? }` or `null`
- Returns only low-sensitivity fields

**4. `whatsapp-send` edge function (service-role only)**
- Wraps Meta WhatsApp Cloud API
- Input: `{ to, template, params }` → POSTs to graph.facebook.com
- Used by paystack-webhook/stripe-webhook (confirmation) and process-scheduled-notifications (reminders)

**5. `whatsapp-webhook` edge function**
- Public with Meta signature verification
- Handles delivery receipts (status updates to `scheduled_notifications`)
- Inbound messages logged but not processed in v1 (foundation for Spec 4 agent)
- `verify_jwt = false` in config.toml (same as Paystack webhook fix)

### Schema

```sql
-- guest_profiles: phone-keyed identity
CREATE TABLE guest_profiles (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  phone        text UNIQUE NOT NULL,
  name         text NOT NULL,
  locale       text DEFAULT 'en',
  last_seen_at timestamptz DEFAULT now(),
  created_at   timestamptz DEFAULT now(),
  updated_at   timestamptz DEFAULT now()
);
CREATE INDEX guest_profiles_phone_idx ON guest_profiles (phone);

-- guest_booking_history: compact log for prefill ordering
CREATE TABLE guest_booking_history (
  guest_profile_id uuid REFERENCES guest_profiles(id) ON DELETE CASCADE,
  service_name     text NOT NULL,
  shop_id          uuid,
  freelancer_id    uuid,
  booked_at        timestamptz DEFAULT now(),
  PRIMARY KEY (guest_profile_id, booked_at)
);
CREATE INDEX guest_booking_history_lookup_idx
  ON guest_booking_history (guest_profile_id, booked_at DESC);

-- bookings: guest support + delivery channel + freelancer address
ALTER TABLE bookings
  ALTER COLUMN user_id DROP NOT NULL,
  ADD COLUMN guest_profile_id  uuid REFERENCES guest_profiles(id),
  ADD COLUMN guest_name        text,
  ADD COLUMN guest_phone       text,
  ADD COLUMN client_address    text,
  ADD COLUMN client_address_lat double precision,
  ADD COLUMN client_address_lng double precision,
  ADD COLUMN delivery_channel  text NOT NULL DEFAULT 'push'
    CHECK (delivery_channel IN ('push', 'whatsapp', 'none')),
  ADD CONSTRAINT bookings_user_or_guest_chk CHECK (
    (user_id IS NOT NULL AND guest_profile_id IS NULL) OR
    (user_id IS NULL AND guest_profile_id IS NOT NULL)
  );
CREATE INDEX bookings_guest_profile_idx ON bookings (guest_profile_id);

-- shops + freelancers: cached booking slug
ALTER TABLE shops ADD COLUMN booking_slug text UNIQUE;
ALTER TABLE freelancers ADD COLUMN booking_slug text UNIQUE;

-- scheduled_notifications: delivery channel + WhatsApp template fields
ALTER TABLE scheduled_notifications
  ADD COLUMN delivery_channel text NOT NULL DEFAULT 'push'
    CHECK (delivery_channel IN ('push', 'whatsapp')),
  ADD COLUMN whatsapp_template text,
  ADD COLUMN whatsapp_params jsonb;

-- pending_payments: delivery channel for confirmation message + guest reference
ALTER TABLE pending_payments
  ADD COLUMN delivery_channel text NOT NULL DEFAULT 'push'
    CHECK (delivery_channel IN ('push', 'whatsapp')),
  ADD COLUMN guest_profile_id uuid REFERENCES guest_profiles(id);

-- RLS
ALTER TABLE guest_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE guest_booking_history ENABLE ROW LEVEL SECURITY;
-- No policies → no public access. service_role bypasses (used by edge functions).

-- Realtime publication: bookings already enabled (migration 20260526210000).
-- guest_profiles and guest_booking_history NOT added to supabase_realtime —
-- no client subscribes to them. Add later if a use case appears.
```

### Extended components

**6. `create-booking` edge function**
- Accepts either `userId` (mobile, unchanged) or `guestName + guestPhone` (web, NEW)
- Guest path: upserts `guest_profiles` by phone (latest writer wins on name conflict)
- Sets `guest_profile_id` on `pending_payments`
- Provider selection unchanged (currency-based: African → Paystack, else → Stripe)
- For freelancer bookings: accepts `clientAddress` + lat/lng, validates against `travelRadiusKm`

**7. `paystack-webhook` + `stripe-webhook`**
- After inserting booking row, also inserts `guest_booking_history` row if booking is guest-based
- After booking confirmation, if `delivery_channel='whatsapp'`:
  - Calls `whatsapp-send` immediately for `booking_confirmation_v1` template
  - Schedules 3 future notifications via NotificationService:
    - 24h before appointment → `booking_reminder_24h_v1`
    - 2h before appointment → `booking_reminder_2h_v1`
    - 1-2h after appointment end_time → `booking_review_prompt_v1`

**8. `NotificationService` (Flutter, generic)**
- `ScheduledNotification` entity gains `delivery_channel`, `whatsapp_template`, `whatsapp_params`
- `process-scheduled-notifications` worker:
  - `delivery_channel='push'` → existing OneSignal path (unchanged)
  - `delivery_channel='whatsapp'` → call `whatsapp-send` with template + params
- Retry up to 3x on `whatsapp-send` failure (template_not_found → defer 6h; transient → exponential backoff)

**9. Mobile app: shop/freelancer settings screens**
- New "Shareable booking link" section:
  - Shows the URL `aura-in-web.vercel.app/book/<slug>`
  - Copy button
  - System share sheet (drops into WhatsApp/IG natively)
  - "Edit slug" button (validates availability via LinkService)
- Slug auto-generation on shop/freelancer create:
  - Slugify name → check against reserved + existing → append `-2`, `-3` on collision
  - Inserts into `short_links` via `LinkService.createShopLink` / `createWorkerLink`
  - Caches the slug into `shops.booking_slug` / `freelancers.booking_slug`

**10. Universal Links setup**
- Served from Next.js app:
  - `/.well-known/apple-app-site-association` (iOS)
  - `/.well-known/assetlinks.json` (Android)
- Mobile app deep link handler: matches `/book/<slug>`, calls `LinkService.resolveLink(slug)`, navigates to existing booking screen with the resolved target

## Data Flow

### Setup (one-time, per shop/freelancer)
```
Shop save in mobile app
  → Flutter slugifies name client-side
  → LinkService.createShopLink(shopId, slug) — checks reserved + uniqueness
    via Supabase, retries with -2/-3 suffix on collision
  → trigger on short_links insert syncs the slug into shops.booking_slug
  → owner sees URL in settings, taps share
```

Slugification happens in Dart via `LinkService` (already 80% built). The mobile app drives the flow; the database enforces uniqueness via the existing `short_links.slug` unique constraint.

### Client opens link
```
WhatsApp tap aura-in-web.vercel.app/book/limit-barbershop
  ↓
Universal Link check:
  - App installed → app handles it (existing booking flow)
  - Not installed → falls through to browser
  ↓
Next.js server component:
  → calls resolve-link(slug)
  → server-renders HTML inline with all data
  → ~30KB HTML + ~50KB lazy JS
  ↓
Page paints <1s on 3G
```

### Client books
```
Picks service, optionally worker OR address, picks slot, types name + phone
  ↓
500ms after typing phone → lookup-guest(phone)
  → returns { name, lastServices } if seen before
  → name prefilled, last service moved to top of list with "Booked last time" pill
  ↓
Taps "Pay GH₵ X deposit"
  ↓
Browser POSTs to create-booking:
  {
    targetType, targetId,
    services, workerId?, address?,
    startTime, endTime,
    guestName, guestPhone,
    deliveryChannel: 'whatsapp'
  }
  ↓
create-booking:
  1. Validate (existing logic + guest field checks)
  2. Currency-based provider selection (existing)
  3. Upsert guest_profiles by phone
  4. Slot availability check (existing)
  5. getProvider(provider).initCheckout(...)
  6. Upsert pending_payments with delivery_channel + guest_profile_id
  7. Returns { authorizationUrl, reference }
  ↓
window.location = authorizationUrl
  → Paystack hosted page → client pays
  → Paystack redirects to /book/<slug>/success?reference=...
```

### Payment confirms
```
Paystack hits paystack-webhook
  → signature verified
  → loads pending_payments by reference
  → inserts bookings row with guest_profile_id + status='confirmed'
  → inserts guest_booking_history row
  ↓
Realtime publication emits → mobile app shop owner sees it
OneSignal push fires to shop owner (existing flow)
  ↓
Webhook calls whatsapp-send for booking_confirmation_v1
  ↓
Webhook schedules 3 future notifications:
  - 24h reminder (delivery_channel='whatsapp')
  - 2h reminder (delivery_channel='whatsapp')
  - Review prompt (delivery_channel='whatsapp')
```

### Success page
```
GET /book/<slug>/success?reference=<x>
  ↓
Server component polls bookings by reference every 2s for up to 60s
  → status='confirmed' → render full success page
  → still null after 60s → "Payment processing — you'll get a WhatsApp message"
```

### Reminders fire
```
process-scheduled-notifications cron:
  → SELECT * FROM scheduled_notifications WHERE scheduled_for < NOW() AND status='pending'
  → For each row:
    - delivery_channel='push' → existing OneSignal path
    - delivery_channel='whatsapp' → whatsapp-send call
  → Mark status='sent' or 'failed' (retry up to 3x)
```

## Error Handling and Edge Cases

| Scenario | Behavior |
|---|---|
| Slot stolen between page load and submit | `create-booking` returns `400 slot_unavailable`. Page shows toast, re-fetches slots via `resolve-link`, scrolls back to slot picker, preserves form data. |
| Paystack succeeds but webhook delayed | Success page polls every 2s for 60s. If still null: "Payment processing — you'll get WhatsApp when it confirms." WhatsApp still fires when webhook eventually arrives. |
| Client closes tab mid-payment | `pending_payments` stays `pending`. Existing expiry cron marks it `expired` after 30 min. No booking created. |
| Phone invalid / non-WhatsApp | Submit-time format check (E.164). Delivery failure logged in `scheduled_notifications.status='failed'`. Booking still confirmed. Copy on page: "We'll try to send confirmation on WhatsApp." |
| Freelancer client address outside travel radius | Mapbox geocode → distance check vs `travelRadiusKm`. Inline error: "Outside service area." Blocks submit. |
| Universal Link fails / app crashes | Web is source of truth. User long-press → "Open in browser" → web flow works. No detection logic web-side. |
| WhatsApp confirmation arrives before success page renders | Both are idempotent representations. No special handling. |
| Meta template not yet approved | `whatsapp-send` catches `template_not_found`, marks notification `deferred`. Auto-retry every 6h. |
| Guest profile name collision (phone reuse) | Latest writer wins on `name`. Acceptable for opportunistic prefill. |

### Rate limiting (anti-abuse)
- `create-booking`: 10/IP/hour, 5/phone/hour → 429
- `lookup-guest`: 30/IP/hour → 429
- `resolve-link`: 60/IP/min → 429

In-memory counters in v1; Redis-backed later.

### Risks explicitly accepted

- Parallel form submits from same phone may both create payment intents; Paystack accepts both, slot conflict on webhook prevents double-booking, loser refunds via Paystack auto-cancel.
- WhatsApp delivery failures beyond 3 retries are logged but not paged.
- Guests who lose their tab and don't get WhatsApp have to ask the shop. Manage-booking URL deferred to v2.

## WhatsApp Templates

All four submitted to Meta as `utility` category:

```
booking_confirmation_v1
  "Hi {{1}}, your booking at {{2}} is confirmed for {{3}}.
   Address: {{4}}.
   Deposit paid: {{5}}.
   Remaining: {{6}} (pay after service)."

booking_reminder_24h_v1
  "Reminder: your booking at {{1}} is tomorrow at {{2}}.
   {{3}}"

booking_reminder_2h_v1
  "Heads up: your appointment at {{1}} is in 2 hours, at {{2}}.
   {{3}}"

booking_review_prompt_v1
  "How was your visit to {{1}}?
   Tap to rate: {{2}}"
```

Template approval is parallel to dev work. Templates submitted at sprint start; coded fallback (defer-and-retry on `template_not_found`) means launch isn't blocked by approval delay.

## Success Criteria (v1 done)

1. Slug-to-booking ≤ 5 minutes for a first-time guest on 3G
2. First paint <3s on Lighthouse Slow 3G profile
3. WhatsApp confirmation arrives ≤ 10s after payment in 95% of cases
4. Repeat guest's name pre-filled within 800ms of finishing their phone number
5. Zero regressions in the mobile booking wizard (existing test suite passes unchanged)
6. Mobile app changes confined to: shop/freelancer settings screen + universal link handler. No other UI churn.

## Files Affected

### New
- `aura-in-web/` — entire new Next.js project (separate repo or `web-app/` subdirectory)
- `supabase/functions/resolve-link/index.ts`
- `supabase/functions/lookup-guest/index.ts`
- `supabase/functions/whatsapp-send/index.ts`
- `supabase/functions/whatsapp-webhook/index.ts`
- `supabase/migrations/20260528_link_booking_guest_support.sql` (timestamp assigned at plan time)

### Modified
- `supabase/functions/create-booking/index.ts` — accept guest fields
- `supabase/functions/paystack-webhook/index.ts` — guest_booking_history + WhatsApp dispatch + reminder scheduling
- `supabase/functions/stripe-webhook/index.ts` — same as above
- `supabase/functions/process-scheduled-notifications/index.ts` — WhatsApp channel
- `supabase/config.toml` — add `verify_jwt = false` for `whatsapp-webhook`
- `lib/core/notifications/domain/entities/scheduled_notification.dart` — add channel + template fields
- `lib/core/notifications/data/repositories/notification_repository_impl.dart` — serialize new fields
- `lib/presentation/features/shops/.../shop_settings_screen.dart` — add Shareable Link section
- `lib/presentation/features/freelancer/.../freelancer_settings_screen.dart` — same
- `lib/app/routing/app_router.dart` — add `/book/:slug` deep link route
- `ios/Runner/Info.plist` — Universal Links domain
- `android/app/src/main/AndroidManifest.xml` — App Links intent filter
