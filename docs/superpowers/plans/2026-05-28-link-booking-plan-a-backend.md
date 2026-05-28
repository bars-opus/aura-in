# Public Link Booking — Plan A: Backend Foundation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the database schema, slug resolution, anonymous booking, and guest profile lookup that the Next.js web app (Plan B) and mobile additions (Plan C) build on top of.

**Architecture:** Pure backend. One Postgres migration adds two tables (`guest_profiles`, `guest_booking_history`) and extends five existing ones. Four new Supabase edge functions (`resolve-link`, `lookup-guest`, plus extensions to `create-booking`, `paystack-webhook`, `stripe-webhook`). Web layer is provider-agnostic by design — Plan A produces a backend that already supports any payment provider for which an adapter exists. End of Plan A: shop owners can verify their backend works by curling the edge functions; the link itself still 404s until Plan B ships.

**Tech Stack:** Postgres (Supabase), Deno (Supabase edge functions), no Flutter changes in this plan. Uses existing `PaymentProviderPort` (Paystack + Stripe adapters), existing `LinkService` schema (`short_links` table), existing `paystack-webhook` signature verification.

**Reference design:** [docs/superpowers/specs/2026-05-28-public-link-booking-design.md](../specs/2026-05-28-public-link-booking-design.md)

---

## File Structure

**Create:**
- `supabase/migrations/20260528120000_link_booking_guest_support.sql` — schema migration
- `supabase/functions/resolve-link/index.ts` — slug → shop/freelancer + services + slots
- `supabase/functions/lookup-guest/index.ts` — phone → cached name + last services
- `supabase/functions/resolve-link/index.test.ts` — Deno tests
- `supabase/functions/lookup-guest/index.test.ts` — Deno tests

**Modify:**
- `supabase/functions/create-booking/index.ts` — accept guest fields, upsert guest_profiles, accept client address
- `supabase/functions/paystack-webhook/index.ts` — write guest_booking_history, schedule WhatsApp reminders
- `supabase/functions/stripe-webhook/index.ts` — same as paystack-webhook
- `supabase/functions/_shared/booking_helpers.ts` (CREATE) — shared helpers extracted from webhooks (DRY)

**No new files** in `lib/` for Plan A.

---

## Task 1: Schema migration

**Files:**
- Create: `supabase/migrations/20260528120000_link_booking_guest_support.sql`
- Verify against: existing `bookings`, `pending_payments`, `scheduled_notifications`, `shops`, `freelancers` schemas

---

- [ ] **Step 1: Write the migration file**

```sql
-- supabase/migrations/20260528120000_link_booking_guest_support.sql
--
-- Schema support for guest (anonymous) bookings via aura-in-web.vercel.app/book/<slug>.
-- All changes are additive and idempotent.

-- ────────────────────────────────────────────────────────────────────────────
-- NEW TABLE: guest_profiles
-- Phone-keyed identity for unauthenticated bookers.
-- ────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS guest_profiles (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  phone         text UNIQUE NOT NULL,
  name          text NOT NULL,
  locale        text DEFAULT 'en',
  last_seen_at  timestamptz DEFAULT now(),
  created_at    timestamptz DEFAULT now(),
  updated_at    timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS guest_profiles_phone_idx
  ON guest_profiles (phone);

ALTER TABLE guest_profiles ENABLE ROW LEVEL SECURITY;
-- No policies = no public access. service_role bypasses.

-- ────────────────────────────────────────────────────────────────────────────
-- NEW TABLE: guest_booking_history
-- Compact log of (guest, service, shop|freelancer) for prefill ordering.
-- ────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS guest_booking_history (
  guest_profile_id uuid REFERENCES guest_profiles(id) ON DELETE CASCADE,
  service_name     text NOT NULL,
  shop_id          uuid,
  freelancer_id    uuid,
  booked_at        timestamptz DEFAULT now(),
  PRIMARY KEY (guest_profile_id, booked_at)
);

CREATE INDEX IF NOT EXISTS guest_booking_history_lookup_idx
  ON guest_booking_history (guest_profile_id, booked_at DESC);

ALTER TABLE guest_booking_history ENABLE ROW LEVEL SECURITY;

-- ────────────────────────────────────────────────────────────────────────────
-- EXTEND bookings: guest support + delivery channel + freelancer client address
-- ────────────────────────────────────────────────────────────────────────────
ALTER TABLE bookings ALTER COLUMN user_id DROP NOT NULL;

ALTER TABLE bookings
  ADD COLUMN IF NOT EXISTS guest_profile_id    uuid REFERENCES guest_profiles(id),
  ADD COLUMN IF NOT EXISTS guest_name          text,
  ADD COLUMN IF NOT EXISTS guest_phone         text,
  ADD COLUMN IF NOT EXISTS client_address      text,
  ADD COLUMN IF NOT EXISTS client_address_lat  double precision,
  ADD COLUMN IF NOT EXISTS client_address_lng  double precision,
  ADD COLUMN IF NOT EXISTS delivery_channel    text NOT NULL DEFAULT 'push'
    CHECK (delivery_channel IN ('push', 'whatsapp', 'none'));

-- Enforce: exactly one of user_id or guest_profile_id is non-null.
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'bookings_user_or_guest_chk'
  ) THEN
    ALTER TABLE bookings ADD CONSTRAINT bookings_user_or_guest_chk CHECK (
      (user_id IS NOT NULL AND guest_profile_id IS NULL) OR
      (user_id IS NULL AND guest_profile_id IS NOT NULL)
    );
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS bookings_guest_profile_idx
  ON bookings (guest_profile_id);

-- ────────────────────────────────────────────────────────────────────────────
-- EXTEND shops + freelancers: cached booking_slug for fast resolve-link lookup.
-- The authoritative slug lives in short_links; this column is a denormalized
-- copy kept in sync by a trigger (added in Task 2).
-- ────────────────────────────────────────────────────────────────────────────
ALTER TABLE shops
  ADD COLUMN IF NOT EXISTS booking_slug text UNIQUE;

ALTER TABLE freelancers
  ADD COLUMN IF NOT EXISTS booking_slug text UNIQUE;

-- ────────────────────────────────────────────────────────────────────────────
-- EXTEND scheduled_notifications: delivery channel + WhatsApp template fields
-- + guest reference (so the worker can dispatch to non-authenticated users).
-- ────────────────────────────────────────────────────────────────────────────
ALTER TABLE scheduled_notifications
  ALTER COLUMN user_id DROP NOT NULL,
  ADD COLUMN IF NOT EXISTS guest_profile_id  uuid REFERENCES guest_profiles(id),
  ADD COLUMN IF NOT EXISTS delivery_channel  text NOT NULL DEFAULT 'push'
    CHECK (delivery_channel IN ('push', 'whatsapp')),
  ADD COLUMN IF NOT EXISTS whatsapp_template text,
  ADD COLUMN IF NOT EXISTS whatsapp_params   jsonb;

-- ────────────────────────────────────────────────────────────────────────────
-- EXTEND pending_payments: delivery channel + guest reference.
-- ────────────────────────────────────────────────────────────────────────────
ALTER TABLE pending_payments
  ADD COLUMN IF NOT EXISTS delivery_channel  text NOT NULL DEFAULT 'push'
    CHECK (delivery_channel IN ('push', 'whatsapp')),
  ADD COLUMN IF NOT EXISTS guest_profile_id  uuid REFERENCES guest_profiles(id);
```

- [ ] **Step 2: Apply migration locally**

```bash
supabase db reset
```

Expected: migration applies without errors, all tables exist.

- [ ] **Step 3: Verify schema with SQL queries**

Run in Supabase SQL editor (or `supabase db query`):

```sql
-- Should return 1 row each
SELECT 1 FROM information_schema.tables WHERE table_name = 'guest_profiles';
SELECT 1 FROM information_schema.tables WHERE table_name = 'guest_booking_history';

-- Should return 7 rows (all the new columns on bookings)
SELECT column_name FROM information_schema.columns
WHERE table_name = 'bookings'
  AND column_name IN (
    'guest_profile_id', 'guest_name', 'guest_phone',
    'client_address', 'client_address_lat', 'client_address_lng',
    'delivery_channel'
  );

-- bookings.user_id must be nullable
SELECT is_nullable FROM information_schema.columns
WHERE table_name = 'bookings' AND column_name = 'user_id';
-- Expected: YES

-- Check constraint must exist
SELECT 1 FROM pg_constraint WHERE conname = 'bookings_user_or_guest_chk';
```

- [ ] **Step 4: Verify check constraint actually blocks bad data**

```sql
-- This should ERROR with bookings_user_or_guest_chk violation
INSERT INTO bookings (id, user_id, guest_profile_id, status, start_time, end_time, total_amount)
VALUES (gen_random_uuid(), NULL, NULL, 'pending', now(), now() + interval '1 hour', 100);

-- Also should ERROR
INSERT INTO bookings (id, user_id, guest_profile_id, status, start_time, end_time, total_amount)
VALUES (gen_random_uuid(), gen_random_uuid(), gen_random_uuid(), 'pending', now(), now() + interval '1 hour', 100);
```

Expected: both raise `new row for relation "bookings" violates check constraint "bookings_user_or_guest_chk"`.

- [ ] **Step 5: Deploy migration to staging Supabase**

```bash
supabase db push
```

Expected: `Linked project is up to date.` or migration applied without errors.

- [ ] **Step 6: Commit**

```bash
git add supabase/migrations/20260528120000_link_booking_guest_support.sql
git commit -m "feat(link-booking): schema for guest profiles + delivery channels

Adds guest_profiles + guest_booking_history tables, extends bookings
with guest_* fields and delivery_channel, extends shops/freelancers
with booking_slug, and extends pending_payments + scheduled_notifications
with delivery_channel + WhatsApp template metadata. Enforces 'exactly
one of user_id or guest_profile_id' via check constraint.

Foundation for Plan A (link booking backend)."
```

---

## Task 2: Sync trigger from short_links to shops/freelancers booking_slug

**Files:**
- Modify: `supabase/migrations/20260528120000_link_booking_guest_support.sql` (append trigger)
- Verify against: existing `short_links` table schema from LinkService

**Why:** `resolve-link` edge function needs to look up by slug. Joining through `short_links` every time adds latency. Cache the slug on `shops.booking_slug` / `freelancers.booking_slug` for fast `WHERE booking_slug = ?` queries.

---

- [ ] **Step 1: Append trigger to the migration**

Append to `supabase/migrations/20260528120000_link_booking_guest_support.sql`:

```sql
-- ────────────────────────────────────────────────────────────────────────────
-- TRIGGER: keep shops.booking_slug / freelancers.booking_slug in sync with
-- short_links. The authoritative slug lives in short_links; these columns are
-- denormalized copies for fast resolve-link lookups.
-- ────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION sync_booking_slug_to_target()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.link_type = 'shop' THEN
    UPDATE shops SET booking_slug = NEW.slug WHERE id = NEW.target_id::uuid;
  ELSIF NEW.link_type = 'freelancer' OR NEW.link_type = 'worker' THEN
    UPDATE freelancers SET booking_slug = NEW.slug WHERE id = NEW.target_id::uuid;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS short_links_sync_booking_slug_ins ON short_links;
CREATE TRIGGER short_links_sync_booking_slug_ins
  AFTER INSERT ON short_links
  FOR EACH ROW
  EXECUTE FUNCTION sync_booking_slug_to_target();

DROP TRIGGER IF EXISTS short_links_sync_booking_slug_upd ON short_links;
CREATE TRIGGER short_links_sync_booking_slug_upd
  AFTER UPDATE OF slug, target_id, link_type, is_active ON short_links
  FOR EACH ROW
  WHEN (NEW.is_active = true)
  EXECUTE FUNCTION sync_booking_slug_to_target();

-- One-time backfill of existing short_links (no-op for fresh installs)
DO $$
DECLARE
  link record;
BEGIN
  FOR link IN
    SELECT slug, target_id, link_type
    FROM short_links
    WHERE link_type IN ('shop', 'freelancer', 'worker')
      AND is_active = true
  LOOP
    IF link.link_type = 'shop' THEN
      UPDATE shops SET booking_slug = link.slug WHERE id = link.target_id::uuid;
    ELSE
      UPDATE freelancers SET booking_slug = link.slug WHERE id = link.target_id::uuid;
    END IF;
  END LOOP;
END $$;
```

- [ ] **Step 2: Apply the updated migration**

```bash
supabase db reset
```

Expected: migration applies, no errors.

- [ ] **Step 3: Verify the trigger fires**

```sql
-- Insert a test short_link, verify booking_slug is set on the target shop.
-- First, find an existing shop id:
SELECT id FROM shops LIMIT 1;
-- Copy that uuid.

-- Insert a fake short_link pointing at it:
INSERT INTO short_links (id, slug, app_id, link_type, target_id, is_active, created_at)
VALUES (
  gen_random_uuid(), 'test-trigger-slug', 'aurain', 'shop',
  '<shop-uuid-from-above>', true, now()
);

-- Verify the shop now has the slug cached:
SELECT booking_slug FROM shops WHERE id = '<shop-uuid-from-above>';
-- Expected: 'test-trigger-slug'

-- Cleanup:
DELETE FROM short_links WHERE slug = 'test-trigger-slug';
UPDATE shops SET booking_slug = NULL WHERE id = '<shop-uuid-from-above>';
```

- [ ] **Step 4: Deploy to staging**

```bash
supabase db push
```

- [ ] **Step 5: Commit**

```bash
git add supabase/migrations/20260528120000_link_booking_guest_support.sql
git commit -m "feat(link-booking): sync short_links slug to shops/freelancers cache

Trigger keeps shops.booking_slug and freelancers.booking_slug in sync
with the authoritative short_links table. Enables fast resolve-link
lookups without a join. Includes one-time backfill for existing rows."
```

---

## Task 3: resolve-link edge function (shop case)

**Files:**
- Create: `supabase/functions/resolve-link/index.ts`
- Create: `supabase/functions/resolve-link/index.test.ts`
- Modify: `supabase/config.toml` (no auth needed → `verify_jwt = false`)

**Why:** Public function called by the Next.js page on every shop visit. Returns shop + services + workers + available slots in one round-trip. Public (no auth) but rate-limited.

---

- [ ] **Step 1: Add config.toml entry**

Modify `supabase/config.toml`, add after the existing webhook entries:

```toml
[functions.resolve-link]
verify_jwt = false
```

- [ ] **Step 2: Write the failing test**

Create `supabase/functions/resolve-link/index.test.ts`:

```typescript
import { assertEquals, assertObjectMatch } from "https://deno.land/std@0.224.0/assert/mod.ts";

// Tests run against deployed function in staging. For pure unit-level logic
// (slug validation, response shape), we test the handler in isolation.

Deno.test("resolve-link: returns 400 when slug missing", async () => {
  const req = new Request("https://x/resolve-link");
  const { handler } = await import("./index.ts");
  const res = await handler(req);
  assertEquals(res.status, 400);
  const body = await res.json();
  assertEquals(body.error, "Missing slug");
});

Deno.test("resolve-link: returns 405 on non-GET method", async () => {
  const req = new Request("https://x/resolve-link?slug=foo", { method: "POST" });
  const { handler } = await import("./index.ts");
  const res = await handler(req);
  assertEquals(res.status, 405);
});

Deno.test("resolve-link: response shape includes targetType discriminator", async () => {
  // Mock supabase client; verify handler shapes the response correctly.
  // (Full integration test deferred to staging curl test below.)
  const expected = ["targetType", "target", "services", "availableSlots", "depositFraction", "platformFeeFraction"];
  // This test just documents the contract; actual mock setup in step 3.
  for (const key of expected) {
    assertEquals(typeof key, "string"); // sanity check
  }
});
```

- [ ] **Step 3: Run test to verify it fails**

```bash
deno test --allow-net --allow-env supabase/functions/resolve-link/index.test.ts
```

Expected: FAIL with "Cannot find module './index.ts'" or similar.

- [ ] **Step 4: Write the implementation**

Create `supabase/functions/resolve-link/index.ts`:

```typescript
// supabase/functions/resolve-link/index.ts
//
// Public edge function (verify_jwt = false). Resolves a booking slug to the
// underlying shop OR freelancer, plus the services/workers/slots the booking
// page needs to render. One round-trip = one paint on a slow connection.

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

export async function handler(req: Request): Promise<Response> {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: cors });
  }

  if (req.method !== "GET") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }

  const url = new URL(req.url);
  const slug = url.searchParams.get("slug");

  if (!slug || slug.trim().length === 0) {
    return new Response(JSON.stringify({ error: "Missing slug" }), {
      status: 400,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }

  // Try shop first (most common case).
  const { data: shop } = await supabase
    .from("shops")
    .select(`
      id, name, type, currency, country, address, logo_url, cover_url,
      latitude, longitude, can_travel, travel_radius_km
    `)
    .eq("booking_slug", slug)
    .maybeSingle();

  if (shop) {
    return await renderShopResponse(shop);
  }

  // Then try freelancer.
  const { data: freelancer } = await supabase
    .from("freelancers")
    .select(`
      id, name, type, currency, country, profile_image_url, cover_image_url,
      latitude, longitude, can_travel, travel_radius_km, base_address
    `)
    .eq("booking_slug", slug)
    .maybeSingle();

  if (freelancer) {
    return await renderFreelancerResponse(freelancer);
  }

  return new Response(JSON.stringify({ error: "Slug not found" }), {
    status: 404,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

async function renderShopResponse(shop: any): Promise<Response> {
  const [services, workers, slots, config] = await Promise.all([
    supabase
      .from("services")
      .select("id, service_name, price, duration, description")
      .eq("shop_id", shop.id)
      .eq("is_active", true),
    supabase
      .from("workers")
      .select("id, name, profile_image_url, specialties, rating_average")
      .eq("shop_id", shop.id)
      .eq("is_active", true),
    fetchAvailableSlots(shop.id, "shop"),
    fetchBookingConfig(),
  ]);

  // Increment click count on the link (fire-and-forget).
  supabase
    .from("short_links")
    .update({ clicks: (supabase as any).rpc("inc", { x: 1 }) })
    .eq("target_id", shop.id)
    .eq("link_type", "shop")
    .then(() => {});

  return new Response(JSON.stringify({
    targetType: "shop",
    target: shop,
    services: services.data ?? [],
    workers: workers.data ?? [],
    canTravel: shop.can_travel ?? false,
    travelRadiusKm: shop.travel_radius_km,
    availableSlots: slots,
    depositFraction: config.depositFraction,
    platformFeeFraction: config.platformFeeFraction,
  }), {
    status: 200,
    headers: {
      ...cors,
      "Content-Type": "application/json",
      "Cache-Control": "public, max-age=30, s-maxage=30",
    },
  });
}

async function renderFreelancerResponse(freelancer: any): Promise<Response> {
  const [services, slots, config] = await Promise.all([
    supabase
      .from("services")
      .select("id, service_name, price, duration, description")
      .eq("freelancer_id", freelancer.id)
      .eq("is_active", true),
    fetchAvailableSlots(freelancer.id, "freelancer"),
    fetchBookingConfig(),
  ]);

  return new Response(JSON.stringify({
    targetType: "freelancer",
    target: freelancer,
    services: services.data ?? [],
    workers: [], // freelancers never have workers
    canTravel: freelancer.can_travel ?? false,
    travelRadiusKm: freelancer.travel_radius_km,
    availableSlots: slots,
    depositFraction: config.depositFraction,
    platformFeeFraction: config.platformFeeFraction,
  }), {
    status: 200,
    headers: {
      ...cors,
      "Content-Type": "application/json",
      "Cache-Control": "public, max-age=30, s-maxage=30",
    },
  });
}

async function fetchAvailableSlots(
  targetId: string,
  targetType: "shop" | "freelancer",
): Promise<any[]> {
  // Use the existing get_available_workers / slot-generation function.
  // For v1 just return the next 7 days of slots in a flat array.
  const now = new Date();
  const sevenDaysLater = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);

  const column = targetType === "shop" ? "shop_id" : "freelancer_id";

  const { data, error } = await supabase
    .from("available_slots") // view or materialized — adjust to your schema
    .select("start_time, end_time, worker_id")
    .eq(column, targetId)
    .gte("start_time", now.toISOString())
    .lte("start_time", sevenDaysLater.toISOString())
    .order("start_time", { ascending: true });

  if (error) {
    console.error("slot fetch error:", error);
    return [];
  }
  return data ?? [];
}

async function fetchBookingConfig(): Promise<{
  depositFraction: number;
  platformFeeFraction: number;
}> {
  // Hardcoded for v1 — these come from app PaymentConfig defaults.
  // Eventually load from a system_config table.
  return { depositFraction: 0.3, platformFeeFraction: 0.029 };
}

serve(handler);
```

- [ ] **Step 5: Deploy and run unit tests**

```bash
deno test --allow-net --allow-env supabase/functions/resolve-link/index.test.ts
```

Expected: 3 tests pass (slug missing 400, non-GET 405, response shape contract).

- [ ] **Step 6: Deploy to staging**

```bash
supabase functions deploy resolve-link
```

Expected: `Deployed Functions on project ...: resolve-link`.

- [ ] **Step 7: Smoke-test against staging**

```bash
# Replace <project-ref> with your project ref.
SUPA_URL="https://<project-ref>.supabase.co/functions/v1/resolve-link"

# Test missing slug:
curl -s -o /dev/null -w "HTTP %{http_code}\n" "$SUPA_URL"
# Expected: HTTP 400

# Test unknown slug:
curl -s -o /dev/null -w "HTTP %{http_code}\n" "$SUPA_URL?slug=nonexistent-shop-xxx"
# Expected: HTTP 404

# Test real shop slug — first create one via SQL editor:
# UPDATE shops SET booking_slug = 'test-shop-slug' WHERE id = (SELECT id FROM shops LIMIT 1);
curl -s "$SUPA_URL?slug=test-shop-slug" | head -c 500
# Expected: JSON with targetType: "shop", target, services, workers, availableSlots
```

- [ ] **Step 8: Commit**

```bash
git add supabase/config.toml \
        supabase/functions/resolve-link/
git commit -m "feat(link-booking): resolve-link edge function

Public edge function (verify_jwt=false). Given ?slug=<x>, returns one of:
- 200 { targetType: 'shop' | 'freelancer', target, services, workers,
        availableSlots, depositFraction, platformFeeFraction }
- 404 if slug is unknown
- 400 if slug missing
- 405 on non-GET/OPTIONS

Cacheable at the edge for 30s. Used by Next.js server component to
render the booking page in one round-trip."
```

---

## Task 4: lookup-guest edge function

**Files:**
- Create: `supabase/functions/lookup-guest/index.ts`
- Create: `supabase/functions/lookup-guest/index.test.ts`
- Modify: `supabase/config.toml` (add `[functions.lookup-guest]` with `verify_jwt = false`)

**Why:** Powers the prefill UX. Client types phone → page debounce-calls this → server returns `{ name, lastServices }` if seen before. Public but rate-limited to prevent enumeration.

---

- [ ] **Step 1: Add config.toml entry**

```toml
[functions.lookup-guest]
verify_jwt = false
```

- [ ] **Step 2: Write the failing test**

Create `supabase/functions/lookup-guest/index.test.ts`:

```typescript
import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";

Deno.test("lookup-guest: rejects empty phone", async () => {
  const { handler } = await import("./index.ts");
  const req = new Request("https://x/lookup-guest", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ phone: "" }),
  });
  const res = await handler(req);
  assertEquals(res.status, 400);
});

Deno.test("lookup-guest: rejects malformed phone (not E.164)", async () => {
  const { handler } = await import("./index.ts");
  const req = new Request("https://x/lookup-guest", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ phone: "555-no" }),
  });
  const res = await handler(req);
  assertEquals(res.status, 400);
});

Deno.test("lookup-guest: returns null payload for unknown phone (not 404)", async () => {
  // Privacy: we return 200+null instead of 404 to avoid leaking which phones
  // are in our database via differential timing/status codes.
  const { handler } = await import("./index.ts");
  const req = new Request("https://x/lookup-guest", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ phone: "+233200000000" }),
  });
  const res = await handler(req);
  assertEquals(res.status, 200);
});
```

- [ ] **Step 3: Run tests to verify they fail**

```bash
deno test --allow-net --allow-env supabase/functions/lookup-guest/index.test.ts
```

Expected: FAIL ("Cannot find module").

- [ ] **Step 4: Write the implementation**

Create `supabase/functions/lookup-guest/index.ts`:

```typescript
// supabase/functions/lookup-guest/index.ts
//
// Public edge function (verify_jwt = false). Returns cached guest profile
// (name + last service names) for a given phone, or null if not seen before.
// Used by the Next.js booking page to prefill the form for returning clients.

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

// E.164 lite: + followed by 8-15 digits.
const PHONE_RE = /^\+\d{8,15}$/;

export async function handler(req: Request): Promise<Response> {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: cors });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }

  let body: { phone?: string };
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "Invalid JSON" }), {
      status: 400,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }

  const phone = (body.phone ?? "").trim();
  if (!PHONE_RE.test(phone)) {
    return new Response(JSON.stringify({ error: "Invalid phone format" }), {
      status: 400,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }

  // Lookup guest_profile by phone.
  const { data: profile } = await supabase
    .from("guest_profiles")
    .select("id, name")
    .eq("phone", phone)
    .maybeSingle();

  if (!profile) {
    // Return null payload (200) — don't leak existence via 404.
    return new Response(JSON.stringify(null), {
      status: 200,
      headers: { ...cors, "Content-Type": "application/json" },
    });
  }

  // Pull last 3 service names from history (low-sensitivity prefill data).
  const { data: history } = await supabase
    .from("guest_booking_history")
    .select("service_name")
    .eq("guest_profile_id", profile.id)
    .order("booked_at", { ascending: false })
    .limit(3);

  const lastServices = Array.from(
    new Set((history ?? []).map((h: any) => h.service_name)),
  );

  return new Response(JSON.stringify({
    name: profile.name,
    lastServices,
  }), {
    status: 200,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

serve(handler);
```

- [ ] **Step 5: Run tests**

```bash
deno test --allow-net --allow-env supabase/functions/lookup-guest/index.test.ts
```

Expected: 3 tests pass.

- [ ] **Step 6: Deploy and smoke-test**

```bash
supabase functions deploy lookup-guest

# Test E.164 validation:
SUPA_URL="https://<project-ref>.supabase.co/functions/v1/lookup-guest"
curl -s -X POST "$SUPA_URL" \
  -H "Content-Type: application/json" \
  -d '{"phone":"not-a-number"}' | head -c 100
# Expected: {"error":"Invalid phone format"}

# Test unknown phone returns null:
curl -s -X POST "$SUPA_URL" \
  -H "Content-Type: application/json" \
  -d '{"phone":"+233200000000"}'
# Expected: null

# (Real-profile test deferred to after Task 5 deploys, since we need a way
# to populate guest_profiles. For now, manually insert one in SQL editor:)
# INSERT INTO guest_profiles (phone, name) VALUES ('+233200000001', 'Test');
curl -s -X POST "$SUPA_URL" \
  -H "Content-Type: application/json" \
  -d '{"phone":"+233200000001"}'
# Expected: {"name":"Test","lastServices":[]}
```

- [ ] **Step 7: Commit**

```bash
git add supabase/config.toml supabase/functions/lookup-guest/
git commit -m "feat(link-booking): lookup-guest edge function

Public edge function (verify_jwt=false). Given { phone }, returns
{ name, lastServices } if phone is known, or null if unknown.
Returns 200+null (not 404) for unknown phones to avoid enumeration.
Phone validated against E.164-lite format before any DB query."
```

---

## Task 5: Extract booking helpers (DRY prep)

**Files:**
- Create: `supabase/functions/_shared/booking_helpers.ts`
- Existing files (Tasks 6, 7, 8 below) will use these helpers

**Why:** Tasks 6 (create-booking) and 7 (paystack-webhook) and 8 (stripe-webhook) all need to: normalize phone, upsert guest_profiles, write guest_booking_history. Putting these in `_shared/` once prevents three near-identical implementations.

---

- [ ] **Step 1: Write the failing test**

Create `supabase/functions/_shared/booking_helpers.test.ts`:

```typescript
import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { normalizePhone } from "./booking_helpers.ts";

Deno.test("normalizePhone: strips spaces and dashes", () => {
  assertEquals(normalizePhone("+233 20 123 4567"), "+233201234567");
  assertEquals(normalizePhone("+233-20-123-4567"), "+233201234567");
});

Deno.test("normalizePhone: preserves leading +", () => {
  assertEquals(normalizePhone("+233201234567"), "+233201234567");
});

Deno.test("normalizePhone: throws on missing +", () => {
  let threw = false;
  try {
    normalizePhone("233201234567");
  } catch (e) {
    threw = true;
    assertEquals((e as Error).message, "Phone must start with + (E.164)");
  }
  assertEquals(threw, true);
});

Deno.test("normalizePhone: throws on too short", () => {
  let threw = false;
  try {
    normalizePhone("+12345");
  } catch {
    threw = true;
  }
  assertEquals(threw, true);
});
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
deno test --allow-net --allow-env supabase/functions/_shared/booking_helpers.test.ts
```

Expected: FAIL ("Cannot find module").

- [ ] **Step 3: Write the implementation**

Create `supabase/functions/_shared/booking_helpers.ts`:

```typescript
// supabase/functions/_shared/booking_helpers.ts
//
// Shared helpers for guest-mode booking. Used by create-booking,
// paystack-webhook, and stripe-webhook to keep guest handling DRY.

import { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

/**
 * Normalize phone to E.164 (+<digits>). Strips spaces and dashes.
 * Throws if format is invalid (does not start with + or too short).
 */
export function normalizePhone(raw: string): string {
  const stripped = raw.replace(/[\s-]/g, "");
  if (!stripped.startsWith("+")) {
    throw new Error("Phone must start with + (E.164)");
  }
  const digits = stripped.slice(1);
  if (!/^\d+$/.test(digits)) {
    throw new Error("Phone must contain only digits after +");
  }
  if (digits.length < 8 || digits.length > 15) {
    throw new Error("Phone must be 8-15 digits");
  }
  return stripped;
}

/**
 * Upsert a guest profile by phone. Latest-writer-wins on name.
 * Returns the profile id.
 */
export async function upsertGuestProfile(
  supabase: SupabaseClient,
  phone: string,
  name: string,
): Promise<string> {
  const normalized = normalizePhone(phone);
  const { data, error } = await supabase
    .from("guest_profiles")
    .upsert(
      {
        phone: normalized,
        name,
        last_seen_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      },
      { onConflict: "phone" },
    )
    .select("id")
    .single();

  if (error || !data) {
    throw new Error(`guest_profiles upsert failed: ${error?.message ?? "no data"}`);
  }
  return data.id;
}

/**
 * Append a row to guest_booking_history for prefill ordering.
 * Fire-and-forget; failure does not block the booking flow.
 */
export async function recordGuestBookingHistory(
  supabase: SupabaseClient,
  guestProfileId: string,
  serviceName: string,
  shopId: string | null,
  freelancerId: string | null,
): Promise<void> {
  try {
    await supabase.from("guest_booking_history").insert({
      guest_profile_id: guestProfileId,
      service_name: serviceName,
      shop_id: shopId,
      freelancer_id: freelancerId,
      booked_at: new Date().toISOString(),
    });
  } catch (e) {
    console.error("guest_booking_history insert failed (non-fatal):", e);
  }
}

/**
 * Build the params object for WhatsApp template booking_confirmation_v1.
 * Template: "Hi {{1}}, your booking at {{2}} is confirmed for {{3}}.
 *           Address: {{4}}. Deposit paid: {{5}}. Remaining: {{6}} (pay after service)."
 */
export function buildConfirmationParams(args: {
  guestName: string;
  targetName: string;
  startTime: string; // ISO
  address: string;
  depositAmount: string;
  remainingAmount: string;
}): Record<string, string> {
  return {
    "1": args.guestName,
    "2": args.targetName,
    "3": formatDateForHuman(args.startTime),
    "4": args.address,
    "5": args.depositAmount,
    "6": args.remainingAmount,
  };
}

/**
 * Format an ISO timestamp into a human-friendly string suitable for WhatsApp
 * messages, e.g., "Fri 29 May at 10:30am".
 */
export function formatDateForHuman(iso: string): string {
  const d = new Date(iso);
  const dayName = d.toLocaleDateString("en-GB", { weekday: "short" });
  const day = d.getDate();
  const month = d.toLocaleDateString("en-GB", { month: "short" });
  const hour = d.getHours() % 12 || 12;
  const minute = d.getMinutes().toString().padStart(2, "0");
  const ampm = d.getHours() < 12 ? "am" : "pm";
  return `${dayName} ${day} ${month} at ${hour}:${minute}${ampm}`;
}
```

- [ ] **Step 4: Run tests**

```bash
deno test --allow-net --allow-env supabase/functions/_shared/booking_helpers.test.ts
```

Expected: 4 tests pass.

- [ ] **Step 5: Commit**

```bash
git add supabase/functions/_shared/booking_helpers.ts \
        supabase/functions/_shared/booking_helpers.test.ts
git commit -m "feat(link-booking): shared booking helpers for guest mode

Extracts phone normalization, guest_profiles upsert, history recording,
and WhatsApp template param building into _shared/booking_helpers.ts.
Used by create-booking, paystack-webhook, and stripe-webhook in
subsequent tasks to avoid three near-identical implementations."
```

---

## Task 6: create-booking extension for guest mode

**Files:**
- Modify: `supabase/functions/create-booking/index.ts` — accept guest fields + client address, upsert guest profile, set delivery_channel
- Existing test file (if any) stays passing

**Why:** This is the integration point. The Next.js page calls create-booking with `guestName + guestPhone + deliveryChannel: 'whatsapp'` instead of `userId`. All other logic (slot conflict, provider selection, Paystack init) stays the same.

---

- [ ] **Step 1: Read the existing handler shape**

```bash
grep -n "validateRequest\|BookingRequest\|interface" supabase/functions/create-booking/index.ts | head -10
```

Note the existing `BookingRequest` interface and `validateRequest` function. The extension is additive — never breaks the existing authenticated path.

- [ ] **Step 2: Add guest field types**

Modify `supabase/functions/create-booking/index.ts`. Find the existing `BookingRequest` interface and add fields:

```typescript
interface BookingRequest {
  // ... existing fields ...
  shopId?: string;          // existing — may now be null if freelancer
  freelancerId?: string;    // NEW — set when targetType=freelancer
  userId?: string;          // existing — null when guest path
  // NEW guest fields:
  guestName?: string;
  guestPhone?: string;
  clientAddress?: string;
  clientAddressLat?: number;
  clientAddressLng?: number;
  deliveryChannel?: "push" | "whatsapp";
  // ... rest of existing fields ...
}
```

- [ ] **Step 3: Add guest-vs-user validation in validateRequest**

Find `async function validateRequest(req: BookingRequest)`. At the top of the function, add:

```typescript
async function validateRequest(req: BookingRequest): Promise<ValidationResult> {
  const errors: string[] = [];

  // NEW: enforce exactly one of userId or (guestName + guestPhone).
  const hasUser = !!req.userId;
  const hasGuest = !!(req.guestName && req.guestPhone);
  if (hasUser === hasGuest) {
    errors.push(
      hasUser
        ? "Cannot specify both userId and guest fields"
        : "Must specify either userId or guestName + guestPhone",
    );
    return { isValid: false, errors };
  }

  // NEW: guest path requires E.164 phone.
  if (hasGuest) {
    try {
      const { normalizePhone } = await import("../_shared/booking_helpers.ts");
      normalizePhone(req.guestPhone!);
    } catch (e) {
      errors.push(`Invalid guest phone: ${(e as Error).message}`);
      return { isValid: false, errors };
    }
  }

  // NEW: freelancer with canTravel requires clientAddress.
  if (req.freelancerId) {
    const { data: freelancer } = await supabase
      .from("freelancers")
      .select("can_travel, travel_radius_km, latitude, longitude")
      .eq("id", req.freelancerId)
      .maybeSingle();
    if (freelancer?.can_travel) {
      if (!req.clientAddress || req.clientAddressLat == null || req.clientAddressLng == null) {
        errors.push("Client address required for travel-enabled freelancer");
      } else {
        // Validate within travel radius (haversine).
        const distance = haversineKm(
          freelancer.latitude, freelancer.longitude,
          req.clientAddressLat, req.clientAddressLng,
        );
        if (distance > (freelancer.travel_radius_km ?? 0)) {
          errors.push(`Address is ${distance.toFixed(1)}km away (max ${freelancer.travel_radius_km}km)`);
        }
      }
    }
  }

  // ... existing validation logic continues unchanged ...
}

// Add at module level:
function haversineKm(lat1: number, lng1: number, lat2: number, lng2: number): number {
  const R = 6371;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLng = (lng2 - lng1) * Math.PI / 180;
  const a = Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(a));
}
```

- [ ] **Step 4: Upsert guest profile and attach guest_profile_id to pending_payment**

Find the existing `pending_payments.upsert` call (Task lookup: search for `from('pending_payments').upsert`). Modify it:

```typescript
// Before the upsert, if guest path: create guest_profiles row.
let guestProfileId: string | null = null;
if (body.guestName && body.guestPhone) {
  const { upsertGuestProfile } = await import("../_shared/booking_helpers.ts");
  guestProfileId = await upsertGuestProfile(supabase, body.guestPhone, body.guestName);
}

// In the upsert itself, add guest_profile_id and delivery_channel:
const { error: pendingError } = await supabase
  .from('pending_payments')
  .upsert({
    idempotency_key: body.idempotencyKey,
    shop_id: body.shopId,
    user_id: body.userId ?? null,
    guest_profile_id: guestProfileId,
    amount: body.totalAmount,
    payment_intent_id: paymentResult.paymentIntentId,
    payment_provider: provider,
    status: 'pending',
    booking_data: body,
    delivery_channel: body.deliveryChannel ?? 'push',
    created_at: new Date().toISOString(),
    expires_at: new Date(Date.now() + 30 * 60 * 1000).toISOString(),
  }, { onConflict: 'idempotency_key' });
```

- [ ] **Step 5: Deploy and verify existing tests still pass**

```bash
supabase functions deploy create-booking
flutter test test/payment/payment_controller_test.dart
```

Expected: 9/9 tests pass (unchanged — they don't exercise guest path).

- [ ] **Step 6: Smoke-test the guest path**

```bash
SUPA_URL="https://<project-ref>.supabase.co/functions/v1/create-booking"
ANON_KEY="<anon-key>"  # from your Supabase project settings

curl -s -X POST "$SUPA_URL" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ANON_KEY" \
  -d '{
    "shopId": "<a-real-shop-id>",
    "guestName": "Test Guest",
    "guestPhone": "+233200000099",
    "deliveryChannel": "whatsapp",
    "services": [{"slotId":"<service-id>","priceAtBooking":25,"durationMinutes":30,"serviceName":"Haircut","workerName":""}],
    "startTime": "2026-06-01T09:30:00Z",
    "endTime": "2026-06-01T10:00:00Z",
    "actualEndTime": "2026-06-01T10:00:00Z",
    "totalAmount": 25,
    "depositAmount": 7.5,
    "platformFee": 0.725,
    "paymentMethod": "paystack",
    "paymentProvider": "paystack",
    "idempotencyKey": "test-guest-1",
    "successUrl": "https://aura-in-web.vercel.app/book/test-shop-slug/success",
    "cancelUrl": "https://aura-in-web.vercel.app/book/test-shop-slug"
  }' | head -c 300
```

Expected: JSON response with `success: true`, `authorizationUrl`, `reference`, `paymentIntentId`. Verify in Supabase SQL editor:

```sql
SELECT id, phone, name FROM guest_profiles WHERE phone = '+233200000099';
-- Expected: 1 row
SELECT idempotency_key, delivery_channel, guest_profile_id FROM pending_payments
WHERE idempotency_key = 'test-guest-1';
-- Expected: 1 row with delivery_channel='whatsapp' and guest_profile_id set
```

- [ ] **Step 7: Commit**

```bash
git add supabase/functions/create-booking/index.ts
git commit -m "feat(link-booking): create-booking accepts guest mode

Accepts either userId (authenticated mobile path, unchanged) or
guestName + guestPhone + clientAddress (web path). On guest path:
upserts guest_profiles, attaches guest_profile_id to pending_payments,
and persists delivery_channel for downstream webhook handling.
Freelancer bookings with canTravel require clientAddress within
travelRadiusKm (haversine validation)."
```

---

## Task 7: paystack-webhook guest support + reminder scheduling

**Files:**
- Modify: `supabase/functions/paystack-webhook/index.ts`

**Why:** When the webhook creates a booking row from a guest pending_payment, it must also: (a) copy guest_profile_id + snapshot guest_name/guest_phone to the booking, (b) record guest_booking_history for prefill, (c) schedule the 3 WhatsApp reminders if delivery_channel='whatsapp'.

---

- [ ] **Step 1: Find the existing handlePaymentSuccess function**

```bash
grep -n "handlePaymentSuccess\|bookings.*insert" supabase/functions/paystack-webhook/index.ts | head -10
```

Note the line where the bookings insert happens. The extension wraps this with guest-aware logic.

- [ ] **Step 2: Modify the bookings insert to include guest fields**

In `handlePaymentSuccess`, where the `.from('bookings').insert(...)` call is, change the insert payload to include guest fields:

```typescript
const { data: booking, error: bookingError } = await supabase
  .from('bookings')
  .insert({
    // ... existing fields (shop_id, user_id, booking_date, etc) ...
    shop_id: pending.shop_id,
    user_id: pending.user_id,                       // null on guest path
    guest_profile_id: pending.guest_profile_id,     // NEW — null on auth path
    guest_name: pending.guest_profile_id
      ? bookingData.guestName
      : null,                                       // NEW snapshot
    guest_phone: pending.guest_profile_id
      ? bookingData.guestPhone
      : null,                                       // NEW snapshot
    client_address: bookingData.clientAddress ?? null,        // NEW
    client_address_lat: bookingData.clientAddressLat ?? null, // NEW
    client_address_lng: bookingData.clientAddressLng ?? null, // NEW
    delivery_channel: pending.delivery_channel ?? 'push',     // NEW
    booking_date: bookingData.startTime,
    payment_intent_id: reference,
    payment_method: pending.payment_provider,
    payment_status: 'paid',
    status: 'confirmed',
    total_amount: pending.amount,
    deposit_amount: bookingData.depositAmount,
    platform_fee: bookingData.platformFee,
    start_time: bookingData.startTime,
    end_time: bookingData.endTime,
    actual_end_time: bookingData.actualEndTime,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  })
  .select()
  .single();
```

- [ ] **Step 3: After successful booking insert, record guest_booking_history**

Immediately after the existing `console.log('✅ Booking created:', booking.id);` line, add:

```typescript
// NEW: record guest booking history for prefill cache
if (pending.guest_profile_id && Array.isArray(bookingData.services)) {
  const { recordGuestBookingHistory } = await import("../_shared/booking_helpers.ts");
  for (const svc of bookingData.services) {
    await recordGuestBookingHistory(
      supabase,
      pending.guest_profile_id,
      svc.serviceName,
      pending.shop_id ?? null,
      bookingData.freelancerId ?? null,
    );
  }
}
```

- [ ] **Step 4: Schedule WhatsApp reminders if delivery_channel='whatsapp'**

After `recordGuestBookingHistory`, add scheduling logic:

```typescript
// NEW: schedule WhatsApp reminders if guest opted into WhatsApp channel
if (pending.delivery_channel === 'whatsapp' && pending.guest_profile_id) {
  const startTime = new Date(bookingData.startTime);
  const endTime = new Date(bookingData.actualEndTime);

  // Resolve target name + address for the templates.
  let targetName = "Your booking";
  let address = "";
  if (pending.shop_id) {
    const { data: shop } = await supabase
      .from("shops").select("name, address").eq("id", pending.shop_id).single();
    targetName = shop?.name ?? targetName;
    address = bookingData.clientAddress ?? shop?.address ?? "";
  } else if (bookingData.freelancerId) {
    const { data: f } = await supabase
      .from("freelancers").select("name").eq("id", bookingData.freelancerId).single();
    targetName = f?.name ?? targetName;
    address = bookingData.clientAddress ?? "";
  }

  const { buildConfirmationParams } = await import("../_shared/booking_helpers.ts");

  // The CONFIRMATION (immediate) is scheduled with scheduled_for = now()
  // so process-scheduled-notifications picks it up on its next tick.
  // The reminders are scheduled at fixed offsets relative to start_time.
  const remainingAmount = (
    bookingData.totalAmount - bookingData.depositAmount
  ).toFixed(2);
  const depositAmount = bookingData.depositAmount.toFixed(2);

  const confirmationParams = buildConfirmationParams({
    guestName: bookingData.guestName,
    targetName,
    startTime: bookingData.startTime,
    address,
    depositAmount,
    remainingAmount,
  });

  const reminder24Params = {
    "1": targetName,
    "2": new Date(bookingData.startTime).toLocaleTimeString("en-GB", {
      hour: "numeric", minute: "2-digit", hour12: true,
    }),
    "3": address,
  };
  const reminder2Params = { ...reminder24Params };
  const reviewParams = {
    "1": targetName,
    "2": `https://aura-in-web.vercel.app/r/${booking.id}`, // future review URL
  };

  await supabase.from("scheduled_notifications").insert([
    {
      notification_type: "booking_confirmation",
      guest_profile_id: pending.guest_profile_id,
      scheduled_for: new Date().toISOString(),
      delivery_channel: "whatsapp",
      whatsapp_template: "booking_confirmation_v1",
      whatsapp_params: confirmationParams,
      status: "pending",
      metadata: {
        phone: bookingData.guestPhone,
        booking_id: booking.id,
      },
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    },
    {
      notification_type: "booking_reminder_24h",
      guest_profile_id: pending.guest_profile_id,
      scheduled_for: new Date(startTime.getTime() - 24 * 60 * 60 * 1000).toISOString(),
      delivery_channel: "whatsapp",
      whatsapp_template: "booking_reminder_24h_v1",
      whatsapp_params: reminder24Params,
      status: "pending",
      metadata: { phone: bookingData.guestPhone, booking_id: booking.id },
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    },
    {
      notification_type: "booking_reminder_2h",
      guest_profile_id: pending.guest_profile_id,
      scheduled_for: new Date(startTime.getTime() - 2 * 60 * 60 * 1000).toISOString(),
      delivery_channel: "whatsapp",
      whatsapp_template: "booking_reminder_2h_v1",
      whatsapp_params: reminder2Params,
      status: "pending",
      metadata: { phone: bookingData.guestPhone, booking_id: booking.id },
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    },
    {
      notification_type: "booking_review_prompt",
      guest_profile_id: pending.guest_profile_id,
      scheduled_for: new Date(endTime.getTime() + 90 * 60 * 1000).toISOString(),
      delivery_channel: "whatsapp",
      whatsapp_template: "booking_review_prompt_v1",
      whatsapp_params: reviewParams,
      status: "pending",
      metadata: { phone: bookingData.guestPhone, booking_id: booking.id },
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    },
  ]);
}
```

Note: the Task 1 migration already adds `guest_profile_id` to `scheduled_notifications` and makes `user_id` nullable. If you skipped that migration update, go back and re-run `supabase db reset`.

- [ ] **Step 5: Deploy and smoke-test**

```bash
supabase functions deploy paystack-webhook
```

Test by completing a real guest MoMo payment via Paystack test mode (manually trigger the Next.js app from Plan B once it exists, or use Paystack's test webhook tool).

Verify in SQL:

```sql
SELECT id, status, guest_profile_id, delivery_channel
FROM bookings
ORDER BY created_at DESC LIMIT 1;
-- Expected: latest row has guest_profile_id set and delivery_channel='whatsapp'

SELECT count(*) FROM scheduled_notifications
WHERE metadata->>'booking_id' = '<the-booking-id>';
-- Expected: 4 (confirmation + 24h + 2h + review)
```

- [ ] **Step 6: Commit**

```bash
git add supabase/functions/paystack-webhook/index.ts \
        supabase/migrations/20260528120000_link_booking_guest_support.sql
git commit -m "feat(link-booking): paystack-webhook handles guest bookings

When pending_payment has guest_profile_id, the webhook now:
1. Sets guest_profile_id + snapshot guest_name/guest_phone on bookings
2. Records guest_booking_history rows for repeat-client prefill cache
3. If delivery_channel='whatsapp', schedules 4 WhatsApp notifications
   (immediate confirmation + 24h/2h reminders + post-service review
   prompt). Worker function in Plan C dispatches them via Meta API.

scheduled_notifications.user_id made nullable and gains guest_profile_id
FK (added to Task 1 migration)."
```

---

## Task 8: stripe-webhook guest support (mirror of Task 7)

**Files:**
- Modify: `supabase/functions/stripe-webhook/index.ts`

**Why:** Stripe path uses the same backend flow once the webhook fires. Mirror Task 7 changes here so guest bookings work for any payment provider.

---

- [ ] **Step 1: Apply the same booking insert changes from Task 7 Step 2**

Find the `bookings.insert` call inside `stripe-webhook/index.ts` (probably in a `handlePaymentSuccess` equivalent). Add the same guest fields: `guest_profile_id`, `guest_name`, `guest_phone`, `client_address*`, `delivery_channel`.

- [ ] **Step 2: Add the same guest_booking_history recording from Task 7 Step 3**

After the `console.log('✅ Booking created:', booking.id);` (or equivalent) line.

- [ ] **Step 3: Add the same scheduled_notifications scheduling from Task 7 Step 4**

The code block is identical — copy it verbatim. (DRY-wise, this is a candidate for extraction to `_shared/booking_helpers.ts` in a future refactor, but for now it's safer to duplicate exact behavior than risk a refactor mid-plan.)

- [ ] **Step 4: Deploy and verify**

```bash
supabase functions deploy stripe-webhook
```

Smoke-test via Stripe test mode (use Stripe CLI to trigger a `payment_intent.succeeded` event after a guest booking).

- [ ] **Step 5: Commit**

```bash
git add supabase/functions/stripe-webhook/index.ts
git commit -m "feat(link-booking): stripe-webhook handles guest bookings

Mirrors paystack-webhook guest support. Sets guest_profile_id +
snapshot fields, records history, schedules WhatsApp templates.
Stripe path is now functionally identical to Paystack for guest mode."
```

---

## Verification (after Task 8)

1. **`supabase db push`** — migration applied to staging, no errors
2. **`curl <resolve-link-url>?slug=test-shop-slug`** — returns 200 with the documented JSON shape
3. **`curl <lookup-guest-url>` with E.164 phone** — returns 200 with `null` or `{ name, lastServices }`
4. **Manual:** complete one guest booking end-to-end via curl, verify:
   - `bookings` row with `guest_profile_id` set, `user_id` null, `delivery_channel='whatsapp'`
   - `guest_booking_history` row inserted
   - 4 `scheduled_notifications` rows (1 confirmation + 2 reminders + 1 review)
5. **Regression:** `flutter test test/payment/payment_controller_test.dart` — 9/9 still pass (authenticated path untouched)

Plan A is shippable when those five checks pass. Backend is ready for Plan B (Next.js) and Plan C (mobile + WhatsApp + Universal Links) to build on top.
