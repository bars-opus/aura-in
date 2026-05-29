// aura-in-web/lib/types.ts
//
// Types mirror the JSON shapes returned by the Supabase edge functions
// deployed in Plan A. The source of truth is the function code under
// supabase/functions/{resolve-link,lookup-guest,create-booking}/index.ts —
// the keys here match the literal JSON.stringify(...) shapes those
// functions emit, NOT the underlying snake_case DB columns.
//
// Cross-checked against the deployed endpoints (2026-05). Don't change
// keys speculatively — if the API changes, update both sides together.

export type TargetType = "shop" | "freelancer";

/**
 * Shop / freelancer target as returned by resolve-link.
 *
 * Notes on field origin (see resolve-link/index.ts §6):
 *   - `name`        ← shops.shop_name
 *   - `type`        ← shops.shop_type
 *   - `logoUrl`     ← shops.shop_logo_url
 *   - `luxuryLevel` ← shops.luxury_level (numeric in DB; widened to allow string in case PostgREST stringifies numerics)
 *   - `address`, `latitude`, `longitude`, `country` come from the primary
 *     shop_locations row (falls back to shops.address when no location row).
 *
 * Currency is NOT currently returned by resolve-link (Plan A gap). When
 * Plan A is patched to surface it, add `currency: string | null` here.
 */
export interface Shop {
  id: string;
  name: string;
  type: string | null;
  logoUrl: string | null;
  luxuryLevel: number | string | null;
  verified: boolean | null;
  address: string | null;
  country: string | null;
  latitude: number | null;
  longitude: number | null;
}

/**
 * Service as returned by resolve-link.
 *
 * Backed by `appointment_slots` (the historical table name stuck — see
 * the data-model note in resolve-link/index.ts). `durationMinutes` is
 * parsed from the Postgres INTERVAL column on the server side.
 */
export interface Service {
  id: string;
  name: string;
  description: string | null;
  durationMinutes: number;
  price: number;
  slotType: string | null;
}

/**
 * Worker as returned by resolve-link (shop flow only — `workers` is `[]`
 * when targetType === "freelancer"; the public payload strips
 * freelancer_details).
 *
 * Note the camelCase `profileImageUrl` — the edge function maps the
 * snake_case DB column to camelCase before responding (see
 * resolve-link/index.ts §8). No `rating_average` or `rating` is exposed
 * on the public payload in v1.
 */
export interface Worker {
  id: string;
  name: string;
  profileImageUrl: string | null;
  specialties: string[];
}

/**
 * A single available slot as it will be returned by the (future) slots
 * endpoint. resolve-link v1 returns `availableSlots: []` and the booking
 * page resolves slots lazily after the visitor picks services — see the
 * comment in resolve-link/index.ts §5. Shape kept here so Task 4 can wire
 * the lazy fetch without re-deriving it.
 */
export interface SlotEntry {
  start_time: string; // ISO timestamp
  end_time: string;
  worker_id: string | null;
}

/**
 * Full resolve-link 200 response. The function emits these exact keys:
 *   { targetType, target, services, workers, canTravel, travelRadiusKm,
 *     availableSlots, depositFraction, platformFeeFraction }
 *
 * Error responses (`{ error: string }` at 400/404/500) are not modelled
 * here — see `resolveLink()` in api.ts for how they are translated to
 * `null` / thrown errors.
 */
export interface ResolveLinkResponse {
  targetType: TargetType;
  target: Shop;
  services: Service[];
  workers: Worker[];
  canTravel: boolean;
  travelRadiusKm: number | null;
  availableSlots: SlotEntry[]; // empty in v1
  depositFraction: number;
  platformFeeFraction: number;
}

/**
 * lookup-guest 200 body. Returned for a known phone. For unknown phones
 * the endpoint responds 200 + literal `null` (NOT 404 — see the privacy
 * comment in lookup-guest/index.ts: differential status codes would let
 * a caller enumerate which phone numbers exist).
 */
export interface LookupGuestResponse {
  name: string;
  lastServices: string[];
}

/**
 * create-booking request body. Used by both the mobile (auth) flow and
 * the web (guest) flow; the web path only ever sets the `guest*`/
 * `clientAddress*`/`deliveryChannel` fields and omits `userId`/`userEmail`.
 *
 * Shape mirrors the `BookingRequest` interface in
 * supabase/functions/create-booking/index.ts. successUrl/cancelUrl are
 * the post-checkout redirect URLs the provider should use; for web they
 * point back at /b/[slug]/success and /b/[slug]/cancelled.
 */
export interface CreateBookingRequest {
  shopId: string;
  // Guest path (web): omit userId/userEmail; provide guestName + guestPhone.
  userId?: string;
  userEmail?: string;
  services: Array<{
    slotId: string;
    workerId: string | null;
    priceAtBooking: number;
    durationMinutes: number;
    serviceName: string;
    workerName: string | null;
  }>;
  startTime: string; // ISO
  endTime: string; // ISO (slot end)
  actualEndTime: string; // ISO (after any service overrun)
  totalAmount: number;
  depositAmount: number;
  platformFee: number;
  paymentMethod: "stripe" | "paystack";
  paymentProvider: "stripe" | "paystack";
  idempotencyKey: string;
  successUrl?: string;
  cancelUrl?: string;
  // Guest mode fields (web booking path):
  guestName?: string;
  guestPhone?: string;
  clientAddress?: string;
  clientAddressLat?: number;
  clientAddressLng?: number;
  deliveryChannel?: "push" | "whatsapp";
}

/**
 * create-booking response. On success, the browser redirects to
 * `authorizationUrl` (Paystack checkout / Stripe Checkout Session URL).
 * `reference` is what the /success page polls against
 * `bookings.payment_intent_id` to detect webhook completion.
 *
 * `provider` echoes back the server-decided provider — useful for the
 * success page when the form sent "stripe" but the server downgraded to
 * "paystack" (or vice versa) based on country.
 */
export interface CreateBookingResponse {
  success: boolean;
  authorizationUrl?: string;
  reference?: string;
  paymentIntentId?: string;
  provider?: "stripe" | "paystack";
  error?: string;
}
