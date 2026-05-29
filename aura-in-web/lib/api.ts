// aura-in-web/lib/api.ts
//
// Typed wrappers around the Supabase edge functions deployed in Plan A.
//
// Usage split:
//   - resolveLink: called from a Server Component on /b/[slug]; cached
//     at the Vercel edge for 30s (matches the function's own
//     Cache-Control: s-maxage=30 from resolve-link/index.ts).
//   - lookupGuest, createBooking: called client-side from the booking form.
//   - fetchBookingByReference: called from the /success page (server or
//     client) to poll while the webhook finalizes the booking.

import type {
  ResolveLinkResponse,
  LookupGuestResponse,
  CreateBookingRequest,
  CreateBookingResponse,
} from "./types";

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL;
const ANON_KEY = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

// Fail fast at module load — every API call needs these. We throw rather
// than `!`-asserting so the error message is obvious instead of "fetch
// failed: invalid URL" on first call.
if (!SUPABASE_URL || !ANON_KEY) {
  throw new Error(
    "Supabase env vars missing — set NEXT_PUBLIC_SUPABASE_URL and " +
      "NEXT_PUBLIC_SUPABASE_ANON_KEY in .env.local (see .env.local.example).",
  );
}

const FUNCTIONS_BASE = `${SUPABASE_URL}/functions/v1`;
const REST_BASE = `${SUPABASE_URL}/rest/v1`;

/**
 * Resolve a slug to shop + services + workers + metadata. The edge
 * function returns 404 with `{ error: "Slug not found" }` for unknown
 * slugs; we translate that to `null` so the caller can render notFound().
 *
 * Other non-2xx responses throw — they indicate the function is broken,
 * not that the slug is unknown.
 */
export async function resolveLink(
  slug: string,
): Promise<ResolveLinkResponse | null> {
  const url = `${FUNCTIONS_BASE}/resolve-link?slug=${encodeURIComponent(slug)}`;
  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${ANON_KEY}` },
    // Edge-cache parity with the function's own Cache-Control header.
    next: { revalidate: 30 },
  });
  if (res.status === 404) return null;
  if (!res.ok) {
    throw new Error(`resolve-link failed: ${res.status} ${res.statusText}`);
  }
  return (await res.json()) as ResolveLinkResponse;
}

/**
 * Look up a guest profile by phone for prefill on returning visitors.
 *
 * Contract (from lookup-guest/index.ts):
 *   - 200 + `null` body → unknown phone (intentional: avoids
 *     enumeration via differential status codes).
 *   - 200 + `{ name, lastServices }` → known phone.
 *   - 400 → malformed phone (treat as no-match; don't surface to user).
 *   - 5xx → server error (treat as no-match; the form still works
 *     without prefill).
 *
 * We collapse all non-success cases to `null` so the caller has one
 * branch to handle.
 */
export async function lookupGuest(
  phone: string,
): Promise<LookupGuestResponse | null> {
  const url = `${FUNCTIONS_BASE}/lookup-guest`;
  let res: Response;
  try {
    res = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${ANON_KEY}`,
      },
      body: JSON.stringify({ phone }),
    });
  } catch {
    // Network failure — fall back silently. Prefill is a nice-to-have.
    return null;
  }
  if (!res.ok) return null;
  const body = (await res.json().catch(() => null)) as
    | LookupGuestResponse
    | null;
  return body; // either null or { name, lastServices }
}

/**
 * Submit a booking and receive the payment provider's authorization URL
 * to redirect the browser to.
 *
 * Always returns a `CreateBookingResponse` — non-2xx responses are
 * mapped to `{ success: false, error }` so the form has a single error
 * surface. Network failures throw (the caller's outer try/catch will
 * show a generic "couldn't reach the server" message).
 */
export async function createBooking(
  req: CreateBookingRequest,
): Promise<CreateBookingResponse> {
  const url = `${FUNCTIONS_BASE}/create-booking`;
  const res = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${ANON_KEY}`,
    },
    body: JSON.stringify(req),
  });
  if (!res.ok) {
    const errBody = (await res.json().catch(() => null)) as
      | { error?: string }
      | null;
    return {
      success: false,
      error: errBody?.error ?? `HTTP ${res.status} ${res.statusText}`,
    };
  }
  return (await res.json()) as CreateBookingResponse;
}

/**
 * Poll bookings by payment reference to detect webhook completion. The
 * /success page calls this every few seconds until either the row
 * appears as `confirmed` or a timeout elapses.
 *
 * We query PostgREST directly (no edge function needed) because the
 * `bookings` table has an RLS policy that lets anyone read a confirmed
 * booking by `payment_intent_id` (the reference is unguessable). If RLS
 * blocks the read, this returns null and the success page keeps polling.
 */
export async function fetchBookingByReference(
  reference: string,
): Promise<{ id: string; status: string } | null> {
  const url =
    `${REST_BASE}/bookings` +
    `?payment_intent_id=eq.${encodeURIComponent(reference)}` +
    `&select=id,status&status=eq.confirmed&limit=1`;
  const res = await fetch(url, {
    headers: {
      apikey: ANON_KEY as string,
      Authorization: `Bearer ${ANON_KEY}`,
    },
    cache: "no-store",
  });
  if (!res.ok) return null;
  const rows = (await res.json().catch(() => [])) as Array<{
    id: string;
    status: string;
  }>;
  return rows[0] ?? null;
}
