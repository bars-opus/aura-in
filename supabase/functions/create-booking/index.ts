// supabase/functions/create-booking/payment-intent/index.ts

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";
import {
  sanitizeText,
  sanitizeAmount,
  sanitizeIdentifier,
  redactForLog,
  isDebugLogging,
} from "../_shared/sanitize.ts";
import { getProvider } from "../_shared/providers/registry.ts";
import { PaymentProviderError, type PaymentProviderName } from "../_shared/providers/port.ts";

// ============================================================================
// INITIALIZATION
// ============================================================================

const supabase = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
);

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

// ============================================================================
// TYPES
// ============================================================================

interface BookingRequest {
  shopId: string;
  userId: string;
  userEmail: string;
  services: Array<{
    slotId: string;
    workerId: string | null;
    priceAtBooking: number;
    durationMinutes: number;
    serviceName: string;
    workerName: string | null;
  }>;
  startTime: string;
  endTime: string;
  actualEndTime: string;
  totalAmount: number;
  depositAmount: number;
  platformFee: number;
  paymentMethod: 'stripe' | 'paystack';
  paymentProvider: 'stripe' | 'paystack';
  idempotencyKey: string;
  successUrl?: string;
  cancelUrl?: string;
}

interface ValidationResult {
  isValid: boolean;
  errors: string[];
}

// ============================================================================
// MAIN HANDLER
// ============================================================================

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Verify JWT and extract authenticated user
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ success: false, error: 'Missing authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const { data: { user: authUser }, error: authError } = await supabase.auth.getUser(
      authHeader.replace('Bearer ', '')
    );

    if (authError || !authUser) {
      return new Response(
        JSON.stringify({ success: false, error: 'Invalid or expired token' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // ========================================================================
    // RATE LIMITING — 10 payment intents per user per 10 minutes
    // Checked before parsing the body to fail fast on spammers.
    // ========================================================================
    const windowStart = new Date(Date.now() - 10 * 60 * 1000).toISOString();
    const { count: recentAttempts } = await supabase
      .from('pending_payments')
      .select('id', { count: 'exact', head: true })
      .eq('user_id', authUser.id)
      .gte('created_at', windowStart);

    if ((recentAttempts ?? 0) >= 10) {
      console.warn('🚫 Rate limit exceeded for user:', authUser.id);
      return new Response(
        JSON.stringify({ success: false, error: 'Too many payment attempts. Please wait a few minutes before trying again.' }),
        {
          status: 429,
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json',
            'Retry-After': '600',
          },
        }
      );
    }

    const rawBody = await req.json() as BookingRequest;

    // Enforce that the booking is created for the authenticated user only
    if (rawBody.userId !== authUser.id) {
      return new Response(
        JSON.stringify({ success: false, error: 'Unauthorized' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // ========================================================================
    // INPUT SANITIZATION — fail fast on malformed input at the edge.
    // ========================================================================
    let body: BookingRequest;
    try {
      body = {
        ...rawBody,
        shopId: sanitizeIdentifier(rawBody.shopId, 64),
        userId: sanitizeIdentifier(rawBody.userId, 64),
        userEmail: sanitizeText(rawBody.userEmail, { maxLength: 320, rejectHtml: true }),
        idempotencyKey: sanitizeIdentifier(rawBody.idempotencyKey, 128),
        totalAmount: sanitizeAmount(rawBody.totalAmount, { min: 0.01 }),
        depositAmount: sanitizeAmount(rawBody.depositAmount, { min: 0.01 }),
        platformFee: sanitizeAmount(rawBody.platformFee, { min: 0 }),
        services: (rawBody.services ?? []).map((s) => ({
          slotId: sanitizeIdentifier(s.slotId, 64),
          workerId: s.workerId ? sanitizeIdentifier(s.workerId, 64) : null,
          priceAtBooking: sanitizeAmount(s.priceAtBooking, { min: 0 }),
          durationMinutes: Math.max(0, Math.floor(Number(s.durationMinutes) || 0)),
          serviceName: sanitizeText(s.serviceName, { maxLength: 200 }),
          workerName: s.workerName
            ? sanitizeText(s.workerName, { maxLength: 200 })
            : null,
        })),
      };
    } catch (sanErr) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Invalid input',
          details: [(sanErr as Error).message],
        }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    // ========================================================================
    // STEP 1: VALIDATION
    // ========================================================================

    const validation = await validateRequest(body);
    if (!validation.isValid) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Validation failed',
          details: validation.errors 
        }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

 


    // ========================================================================
// STEP 2: GET SHOP DETAILS (Payment settings optional)
// ========================================================================

// Get shop details to know the country

const { data: shop, error: shopError } = await supabase
  .from('shops')
  .select('id, country, currency')
  .eq('id', body.shopId)
  .single();

if (shopError || !shop) {
  return new Response(
    JSON.stringify({ success: false, error: 'Shop not found' }),
    { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}

// ✅ IGNORE client's paymentProvider - determine from shop country
const africanCountries = [
  'ghana', 'nigeria', 'kenya', 'south africa', 'uganda', 'tanzania',
  'rwanda', 'zambia', 'botswana', 'mauritius', 'senegal', 'ivory coast',
  'cameroon', 'egypt', 'morocco', 'tunisia', 'algeria', 'angola',
  'mozambique', 'zimbabwe', 'malawi', 'namibia', 'lesotho', 'eswatini',
  'gabon', 'equatorial guinea', 'republic of the congo', 'democratic republic of the congo',
  'central african republic', 'chad', 'mali', 'burkina faso', 'niger',
  'mauritania', 'benin', 'togo', 'liberia', 'sierra leone', 'guinea',
  'guinea-bissau', 'gambia', 'senegal', 'djibouti', 'eritrea', 'ethiopia',
  'somalia', 'sudan', 'south sudan', 'comoros', 'seychelles', 'são tomé and príncipe',
  'gh', 'ng', 'ke', 'za', 'ug', 'tz', 'rw', 'zm', 'bw'
];


const shopCountry = shop.country?.toLowerCase().trim() || '';
const shopCurrency = shop.currency?.toUpperCase().trim() || 'GHS';

// Currency is the reliable fallback when shop.country is null/empty.
const africanCurrencies = new Set([
  'GHS', 'GHC', 'NGN', 'KES', 'ZAR', 'UGX', 'TZS', 'RWF', 'ZMW', 'BWP',
  'XOF', 'XAF', 'EGP', 'MAD', 'TND', 'DZD', 'ETB', 'MZN', 'AOA',
]);

const isAfrican =
  africanCountries.some(country => shopCountry === country || shopCountry.includes(country)) ||
  africanCurrencies.has(shopCurrency);

const provider = isAfrican ? 'paystack' : 'stripe';

// Gate verbose request logging behind PAYMENT_DEBUG_LOGS=true so production
// edge-function logs don't accumulate PII.
if (isDebugLogging()) {
  console.log('🔍 Provider detection:', {
    rawCountry: shop.country,
    rawCurrency: shop.currency,
    shopCountry,
    shopCurrency,
    isAfrican,
    provider,
  });
}

// Hard failsafe: if we resolved to Stripe but no Stripe key is configured,
// return a clear error instead of a cryptic Stripe auth failure.
if (provider === 'stripe' && !Deno.env.get('STRIPE_SECRET_KEY')) {
  return new Response(
    JSON.stringify({
      success: false,
      error: 'This shop is not in a supported region for the available payment provider. Please contact support.',
    }),
    { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}





// ✅ NO PAYMENT SETTINGS VALIDATION - shops add this later for withdrawals
// Proceed with payment processing

    // ========================================================================
    // STEP 3: CHECK IDEMPOTENCY (Prevent duplicate payments)
    // ========================================================================
    
    const { data: existingPayment } = await supabase
      .from('pending_payments')
      .select('*')
      .eq('idempotency_key', body.idempotencyKey)
      .maybeSingle();

    if (existingPayment && existingPayment.status === 'completed') {
      return new Response(
        JSON.stringify({ 
          success: true, 
          message: 'Payment already processed',
          booking: existingPayment.booking_data 
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // ========================================================================
    // STEP 4: INITIALIZE CHECKOUT VIA THE PROVIDER PORT
    // ========================================================================
    const callbackBase = body.successUrl ?? "nanoembryo://payment-success";

    let checkoutResult;
    try {
      checkoutResult = await getProvider(provider as PaymentProviderName).initCheckout({
        amount: body.depositAmount,
        currency: shopCurrency,
        reference: provider === "paystack"
          ? `booking_${body.shopId}_${Date.now()}_${body.idempotencyKey.slice(0, 8)}`
          : body.idempotencyKey,
        customerEmail: body.userEmail,
        callbackUrl: callbackBase,
        destinationAccountId: await resolveDestinationAccountId(body.shopId, provider),
        platformFeeAmount: body.platformFee,
        metadata: {
          shop_id: body.shopId,
          user_id: body.userId,
          total_amount: String(body.totalAmount),
          deposit_amount: String(body.depositAmount),
          platform_fee: String(body.platformFee),
          idempotency_key: body.idempotencyKey,
          services: body.services.map((s) => s.serviceName).join(", "),
        },
      });
    } catch (e) {
      if (e instanceof PaymentProviderError) {
        return new Response(
          JSON.stringify({ success: false, error: e.message }),
          { status: e.category === "invalid_request" ? 400 : 502, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }
      throw e;
    }

    const paymentResult = {
      success: true,
      paymentIntentId: checkoutResult.providerReference,
      authorizationUrl: checkoutResult.checkoutUrl,
      reference: checkoutResult.providerReference,
    };

    // ========================================================================
    // STEP 5: STORE PENDING PAYMENT (verify-payment + webhook depend on this)
    // ========================================================================
    //
    // Critical: if this fails silently, neither the webhook nor verify-payment
    // can resolve the payment — the user would pay and never see a booking.
    // We treat a missing pending_payments row as a fatal error.

    const { error: pendingError } = await supabase
      .from('pending_payments')
      .upsert({
        idempotency_key: body.idempotencyKey,
        shop_id: body.shopId,
        user_id: body.userId,
        amount: body.totalAmount,
        payment_intent_id: paymentResult.paymentIntentId,
        payment_provider: provider,
        status: 'pending',
        booking_data: body,
        created_at: new Date().toISOString(),
        expires_at: new Date(Date.now() + 30 * 60 * 1000).toISOString(),
      }, { onConflict: 'idempotency_key' });

    if (pendingError) {
      console.error('❌ Failed to persist pending_payment:', pendingError);
      return new Response(
        JSON.stringify({
          success: false,
          error:
            'Could not store payment state. Please try again — you have not been charged.',
        }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    // ========================================================================
    // STEP 6: RETURN PAYMENT URL FOR WEBVIEW
    // ========================================================================
    
    return new Response(
      JSON.stringify({
        success: true,
        paymentIntentId: paymentResult.paymentIntentId,
        authorizationUrl: paymentResult.authorizationUrl,
        reference: paymentResult.reference,
        // Return server-determined provider — defeats client tampering and
        // matches what's stored in pending_payments.
        provider,
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (error) {
    console.error('Payment error:', (error as Error).message);
    if (isDebugLogging()) {
      console.error('Payment error redacted body:', redactForLog(error));
    }
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});

// ============================================================================
// VALIDATION FUNCTIONS
// ============================================================================

async function validateRequest(req: BookingRequest): Promise<ValidationResult> {
  const errors: string[] = [];

  // Validate shop exists
  const { data: shop, error: shopError } = await supabase
    .from('shops')
    .select('id, user_id, shop_name')
    .eq('id', req.shopId)
    .single();

  if (shopError || !shop) {
    errors.push('Invalid shop');
  }

  // Validate services exist and are active
  for (const service of req.services) {
    const { data: slot, error: slotError } = await supabase
      .from('appointment_slots')
      .select('id, service_name, price, max_clients, is_active')
      .eq('id', service.slotId)
      .single();

    // if (slotError || !slot || !slot.is_active) {
    //   errors.push(`Service ${service.serviceName} is not available`);
    // }

    // Validate price matches current price (optional - prevents price tampering)
    if (slot && Math.abs(slot.price - service.priceAtBooking) > 0.01) {
      errors.push(`Price mismatch for ${service.serviceName}`);
    }
  }

  // Validate worker exists and is active (if assigned)
  for (const service of req.services) {
    if (service.workerId) {
      const { data: worker, error: workerError } = await supabase
        .from('workers')
        .select('id, name, is_active')
        .eq('id', service.workerId)
        .single();

      if (workerError || !worker || !worker.is_active) {
        errors.push(`Worker ${service.workerName} is not available`);
      }
    }
  }

  // Validate time slot availability per assigned worker (not whole shop),
  // so shops with multiple workers can serve clients concurrently.
  //
  // The `bookings` table has no JSON `services` column — worker assignments
  // live in `booking_services`. We join via the overlapping bookings.
  const workerIds = req.services
    .map(s => s.workerId)
    .filter((id): id is string => !!id);

  // Overlap: existing.start_time < req.endTime AND existing.end_time > req.startTime
  const { data: overlapping, error: overlapErr } = await supabase
    .from('bookings')
    .select('id')
    .eq('shop_id', req.shopId)
    .eq('status', 'confirmed')
    .lt('start_time', req.endTime)
    .gt('end_time', req.startTime);

  if (overlapErr) {
    // Treat a query error as conservative-block. Better to fail booking than to
    // double-book a slot.
    errors.push('Could not verify slot availability — please retry');
  } else if (overlapping && overlapping.length > 0) {
    const overlappingIds = overlapping.map((b: { id: string }) => b.id);

    if (workerIds.length > 0) {
      // Multi-worker shop: only flag if a *requested* worker is already booked
      // in this window.
      const { data: workerHits, error: bsErr } = await supabase
        .from('booking_services')
        .select('worker_id')
        .in('booking_id', overlappingIds)
        .in('worker_id', workerIds);

      if (bsErr) {
        errors.push('Could not verify worker availability — please retry');
      } else if (workerHits && workerHits.length > 0) {
        errors.push('Selected worker is not available for this time slot');
      }
    } else {
      // No specific worker requested. Check shop capacity: allow if the number
      // of overlapping confirmed bookings is less than the shop's active worker
      // count. This correctly handles both single-worker shops (1 worker, 1
      // booking → block) and multi-worker shops where the client skips worker
      // selection (3 workers, 1 booking → still 2 available → allow).
      const { data: shopWorkers, error: swErr } = await supabase
        .from('workers')
        .select('id')
        .eq('shop_id', req.shopId)
        .eq('is_active', true);

      if (swErr) {
        errors.push('Could not verify slot availability — please retry');
      } else {
        const totalWorkers = (shopWorkers ?? []).length;
        if (totalWorkers === 0 || overlapping.length >= totalWorkers) {
          errors.push('Time slot is no longer available');
        }
      }
    }
  }

  // Validate amount matches calculation
  const calculatedAmount = req.services.reduce((sum, s) => sum + s.priceAtBooking, 0);
  if (Math.abs(calculatedAmount - req.totalAmount) > 0.01) {
    errors.push('Amount mismatch');
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
}


// ============================================================================
// PROVIDER HELPERS
// ============================================================================

async function resolveDestinationAccountId(
  shopId: string,
  provider: "paystack" | "stripe",
): Promise<string | undefined> {
  const { data: settings } = await supabase
    .from("payment_settings")
    .select("paystack_subaccount_code, stripe_account_id, stripe_verified")
    .eq("shop_id", shopId)
    .maybeSingle();
  if (!settings) return undefined;
  if (provider === "paystack") return settings.paystack_subaccount_code ?? undefined;
  if (provider === "stripe") {
    return settings.stripe_verified ? (settings.stripe_account_id ?? undefined) : undefined;
  }
  return undefined;
}