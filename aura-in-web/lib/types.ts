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
 *   - `currency`    ← shops.currency (3-letter ISO: GHS, NGN, USD, EUR, ...)
 *                     Nullable defensively — older shops may have NULL.
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
  currency: string | null;
}

/**
 * Service as returned by resolve-link.
 *
 * Backed by `appointment_slots` (the historical table name stuck — see
 * the data-model note in resolve-link/index.ts). `durationMinutes` is
 * parsed from the Postgres INTERVAL column on the server side.
 */
/** An optional extra a client can add to a service (service_addons row). */
export interface Addon {
  id: string;
  name: string;
  /** Minor units (int kobo/pesewas). Convert to major only at display. */
  priceMinor: number;
  /** Extra minutes this add-on adds to the appointment; null = none. */
  durationMinutes: number | null;
}

export interface Service {
  id: string;
  name: string;
  description: string | null;
  durationMinutes: number;
  /** Minor units (int kobo/pesewas). Convert to major only at display. */
  priceMinor: number;
  slotType: string | null;
  /** Group-booking capacity for this service (appointment_slots.max_clients). */
  maxClients: number;
  /** Optional add-ons available for this service. */
  addons: Addon[];
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
 * A single available slot as returned by the get-slots edge function.
 *
 * Keys are camelCased to match get-slots' JSON output (the function
 * normalises the snake_case RPC return shape into this contract). Note
 * resolve-link's `availableSlots` field still types as `SlotEntry[]` but
 * is always `[]` in v1 — the booking page calls getSlots() explicitly
 * after the visitor picks services. See resolve-link/index.ts §5.
 */
export interface SlotEntry {
  /** The service (appointment_slots id) this slot belongs to. Null for legacy
   *  single-service responses; required for combined multi-service slots. */
  slotId?: string | null;
  startTime: string; // ISO timestamp
  endTime: string;
  workerId: string | null;
}

/**
 * get-slots request body. `quantities` defaults to `[1, 1, ...]` server-side
 * if omitted or length-mismatched. `workerIds` narrows the slot search to
 * specific worker(s); omit/null for "any available worker". `days` caps the
 * search window (server clamps to [1, 30]; default 7).
 */
export interface GetSlotsRequest {
  shopId: string;
  serviceIds: string[];
  quantities: number[];
  workerIds?: string[] | null;
  days?: number;
  /** Per-service add-on minutes, parallel to serviceIds. Extends each slot's
   *  length so the appointment window fits the service + its add-ons. */
  extraMinutes?: number[];
}

/**
 * get-slots response. `slots` may be empty (no availability in the window,
 * shop closed all 7 days, RPC failed for every date, etc.) — callers should
 * render a "no slots" state rather than treating it as an error.
 */
export interface GetSlotsResponse {
  slots: SlotEntry[];
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
    // Canonical int-kobo price (incl. add-ons). create-booking prefers *Minor.
    priceAtBookingMinor: number;
    durationMinutes: number;
    serviceName: string;
    workerName: string | null;
    addons?: Array<{
      id: string;
      name: string;
      priceMinor: number;
      durationMinutes: number | null;
    }>;
  }>;
  startTime: string; // ISO
  endTime: string; // ISO (slot end)
  actualEndTime: string; // ISO (after any service overrun)
  // Canonical int-kobo amounts. create-booking reads these directly without
  // re-multiplying, so no float round-trip (checklist 2.19).
  totalAmountMinor: number;
  depositAmountMinor: number;
  platformFeeMinor: number;
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

/**
 * Shape returned by get_booking_detail RPC. Used by the /booking/[id] page
 * accessible from the WhatsApp confirmation link. Phone is server-redacted.
 */
// ────────────────────────────────────────────────────────────────────────
// Products / orders (link-products feature)
// ────────────────────────────────────────────────────────────────────────

export interface ShopProductsTarget {
  id: string;
  name: string;
  type: string | null;
  logo_url: string | null;
  address: string | null;
  country: string | null;
  currency: string | null;
  currency_symbol: string | null;
  latitude: number | null;
  longitude: number | null;
  phone: string | null;
  whatsapp: string | null;
}

export interface ShopProduct {
  id: string;
  name: string;
  description: string | null;
  price: number;
  images: string[] | null;
  category: string | null;
  stock_quantity: number;
  average_rating: number | null;
  review_count: number | null;
}

export interface ShopProductsResponse {
  shop: ShopProductsTarget;
  products: ShopProduct[];
}

export interface OrderItem {
  product_id: string;
  name: string | null;
  image: string | null;
  quantity: number;
  unit_price: number;
  subtotal: number;
}

export interface OrderReview {
  id: string;
  rating: number;
  comment: string | null;
  shop_response?: string | null;
  shop_response_at?: string | null;
  created_at: string;
  updated_at?: string;
  already_submitted?: boolean;
}

export interface OrderDetail {
  id: string;
  status:
    | "pending_confirmation"
    | "confirmed"
    | "out_for_delivery"
    | "delivered"
    | "cancelled"
    | "disputed";
  total_amount: number;
  currency: string | null;
  currency_symbol: string | null;
  delivery_address: string;
  customer_phone_masked: string | null;
  customer_notes: string | null;
  shop_notes: string | null;
  created_at: string;
  confirmed_at: string | null;
  dispatched_at: string | null;
  delivered_at: string | null;
  cancelled_at: string | null;
  shop: ShopProductsTarget | null;
  items: OrderItem[];
}

export interface CreateGuestOrderRequest {
  shopId: string;
  guestName: string;
  guestPhone: string;
  deliveryAddress: string;
  customerNotes?: string;
  items: Array<{ productId: string; quantity: number }>;
  totalAmount: number;
  idempotencyKey: string;
  deliveryChannel?: "whatsapp" | "none";
}

export interface CreateGuestOrderResponse {
  success: boolean;
  orderId?: string;
  error?: string;
}

export interface BookingReview {
  id: string;
  rating: number;
  review: string | null;
  shop_response?: string | null;
  responded_at?: string | null;
  created_at: string;
  updated_at?: string;
  already_submitted?: boolean;
}

export interface BookingDetail {
  id: string;
  status: string;
  start_time: string;
  end_time: string | null;
  total_amount: number;
  deposit_amount: number;
  platform_fee: number;
  guest_name: string | null;
  guest_phone_masked: string | null;
  client_address: string | null;
  shop: {
    name: string;
    type: string | null;
    logo_url: string | null;
    address: string | null;
    country: string | null;
    latitude: number | null;
    longitude: number | null;
    phone: string | null;
    whatsapp: string | null;
  } | null;
  services: Array<{
    name: string;
    duration_minutes: number;
    price: number;
    worker_name: string | null;
    start_time: string | null;
  }>;
}
