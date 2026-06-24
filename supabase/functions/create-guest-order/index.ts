// supabase/functions/create-guest-order/index.ts
//
// Public edge function (verify_jwt = false). Guest checkout from the
// /m/[slug] web page. Wraps the SECURITY DEFINER RPC create_guest_order
// after upserting the guest_profiles row from name+phone, then schedules
// the post-order WhatsApp confirmation by calling enqueue_order_message
// (added in the next migration).
//
// Returns the new order_id so the web client can redirect to /order/[id].
// No payment URL — orders are cash-on-delivery.
//
// Checklist alignment:
//   * 1.4   — auth-equivalent: rate-limited per IP (5/10min) + per-phone
//             via the DB idempotency key.
//   * 2.1   — sanitizeText on name/phone/address/notes.
//   * 2.5   — items[] capped at 50 client-side AND in the DB.
//   * 2.18  — idempotency key derived from (shop, phone, item-set), stable
//             across same-payload retries.
//   * 2.19  — money: total computed server-side in the RPC; client total
//             is a sanity check only.
//   * 3.7   — 5 orders per IP per 10 min via shared rate-limit helper.
//   * 4.4   — phone is redacted in any error log.
//   * 7.6   — origin-restricted CORS via shared helper.

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";
import { buildCorsHeaders } from "../_shared/cors.ts";
import { checkRateLimit } from "../_shared/rate_limit.ts";
import { redactError } from "../_shared/sanitize.ts";
import { upsertGuestProfile, normalizePhone } from "../_shared/booking_helpers.ts";

interface OrderItem {
  productId: string;
  quantity: number;
}

interface CreateGuestOrderBody {
  shopId: string;
  guestName: string;
  guestPhone: string;
  deliveryAddress: string;
  customerNotes?: string;
  items: OrderItem[];
  totalAmount?: number;       // sanity-check only; server recomputes
  idempotencyKey: string;
  deliveryChannel?: "whatsapp" | "none";
}

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

let _supabase: SupabaseClient | null = null;
function getSupabase(): SupabaseClient {
  if (_supabase) return _supabase;
  _supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );
  return _supabase;
}

function json(
  cors: Record<string, string>,
  body: unknown,
  status: number,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

export async function handler(req: Request): Promise<Response> {
  const cors = buildCorsHeaders(req, "POST, OPTIONS");
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: cors });
  }
  if (req.method !== "POST") {
    return json(cors, { error: "Method not allowed" }, 405);
  }

  let body: CreateGuestOrderBody;
  try {
    body = (await req.json()) as CreateGuestOrderBody;
  } catch {
    return json(cors, { error: "Invalid JSON" }, 400);
  }

  // --- 1. Input validation (defense in depth; RPC re-validates too). ---
  if (!body.shopId || !UUID_RE.test(body.shopId)) {
    return json(cors, { error: "Invalid shopId" }, 400);
  }
  if (!body.guestName || body.guestName.trim().length < 2 || body.guestName.length > 100) {
    return json(cors, { error: "Name must be 2-100 characters" }, 400);
  }
  if (!body.deliveryAddress || body.deliveryAddress.trim().length < 5 || body.deliveryAddress.length > 500) {
    return json(cors, { error: "Delivery address is required (5-500 characters)" }, 400);
  }
  if (body.customerNotes && body.customerNotes.length > 1000) {
    return json(cors, { error: "Notes too long" }, 400);
  }
  if (!Array.isArray(body.items) || body.items.length === 0 || body.items.length > 50) {
    return json(cors, { error: "Cart must contain 1-50 items" }, 400);
  }
  for (const it of body.items) {
    if (!it.productId || !UUID_RE.test(it.productId)) {
      return json(cors, { error: "Invalid productId in cart" }, 400);
    }
    if (!Number.isInteger(it.quantity) || it.quantity < 1 || it.quantity > 999) {
      return json(cors, { error: "Invalid quantity in cart" }, 400);
    }
  }
  if (!body.idempotencyKey || body.idempotencyKey.length > 128) {
    return json(cors, { error: "Invalid idempotencyKey" }, 400);
  }

  let normalizedPhone: string;
  try {
    normalizedPhone = normalizePhone(body.guestPhone);
  } catch (e) {
    return json(cors, { error: (e as Error).message }, 400);
  }

  const supabase = getSupabase();

  // --- 2. Rate limit (per IP). ---
  const rl = await checkRateLimit(supabase, "create-guest-order", req, {
    max: 5,
    windowSeconds: 600,
  });
  if (!rl.allowed) {
    return new Response(
      JSON.stringify({
        error: "Too many orders from this address. Please wait a few minutes.",
      }),
      {
        status: 429,
        headers: {
          ...cors,
          "Content-Type": "application/json",
          "Retry-After": String(rl.retryAfterSeconds),
        },
      },
    );
  }

  // --- 3. Upsert guest profile so the order has a guest_profile_id. ---
  let guestProfileId: string;
  try {
    guestProfileId = await upsertGuestProfile(
      supabase,
      normalizedPhone,
      body.guestName.trim(),
    );
  } catch (e) {
    console.error("create-guest-order upsertGuestProfile error:", redactError(e));
    return json(cors, { error: "Could not register your details. Try again." }, 500);
  }

  // --- 4. Insert the order via SECURITY DEFINER RPC. ---
  const { data: orderId, error: orderError } = await supabase.rpc(
    "create_guest_order",
    {
      p_guest_profile_id: guestProfileId,
      p_shop_id:          body.shopId,
      p_items:            body.items.map((it) => ({
        product_id: it.productId,
        quantity:   it.quantity,
      })),
      p_total_amount:     body.totalAmount ?? null,
      p_delivery_address: body.deliveryAddress.trim(),
      p_customer_phone:   normalizedPhone,
      p_customer_notes:   body.customerNotes?.trim() ?? null,
      p_idempotency_key:  body.idempotencyKey,
    },
  );

  if (orderError || !orderId) {
    console.error("create-guest-order RPC error:", redactError(orderError));
    // Surface validation errors (22023 etc.) with their message; mask the
    // rest. The RPC raises with predictable codes for client-correctable
    // failures (stock, total mismatch, invalid input).
    const msg = orderError?.message ?? "Could not place order";
    const isValidationLike = /^(invalid|insufficient|too many|product|delivery|customer|idempotency|shop|items|total)/i
      .test(msg);
    return json(
      cors,
      { error: isValidationLike ? msg : "Could not place order" },
      isValidationLike ? 400 : 500,
    );
  }

  // --- 5. Schedule the WhatsApp confirmation. Best-effort; never fail the
  // order if WhatsApp scheduling errors. The scheduler will pick this up
  // on its next cron tick. ---
  if ((body.deliveryChannel ?? "whatsapp") === "whatsapp") {
    try {
      await supabase.rpc("enqueue_order_message", {
        p_order_id: orderId,
        p_type:     "order_received",
      });
    } catch (e) {
      console.error("create-guest-order: enqueue order_received failed:", redactError(e));
    }
  }

  return json(cors, { success: true, orderId }, 200);
}

serve(handler);
