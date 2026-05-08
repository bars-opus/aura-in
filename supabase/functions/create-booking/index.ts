// supabase/functions/create-booking/payment-intent/index.ts

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import Stripe from "https://esm.sh/stripe@13.6.0";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

// ============================================================================
// INITIALIZATION
// ============================================================================

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!, {
  apiVersion: '2023-10-16',
});

const PAYSTACK_SECRET_KEY = Deno.env.get('PAYSTACK_SECRET_KEY')!;
const PAYSTACK_BASE_URL = 'https://api.paystack.co';

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
    const body = await req.json() as BookingRequest;
    
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


// After fetching shop details, add this debug log
console.log('🔍 SHOP DEBUG:', {
  shopId: body.shopId,
  rawCountry: shop.country,
  trimmedCountry: shop.country?.trim(),
  lowerCaseCountry: shop.country?.toLowerCase().trim(),
  shopData: shop
});

const shopCountry = shop.country?.toLowerCase().trim() || '';
console.log('🔍 shopCountry:', shopCountry);
async function processPaystackPayment(
  req: BookingRequest
): Promise<{ success: boolean; paymentIntentId?: string; authorizationUrl?: string; reference?: string; error?: string }> {
  try {
    const reference = `booking_${req.shopId}_${Date.now()}_${req.idempotencyKey.slice(0, 8)}`;
    const successUrl = `nanoembryo://payment-success?reference=${reference}`;

    console.log('💰 Initializing Paystack transaction:', {
      amount: req.depositAmount,
      email: req.userEmail,
      reference: reference,
      callback_url: successUrl
    });

    const response = await fetch(`${PAYSTACK_BASE_URL}/transaction/initialize`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${PAYSTACK_SECRET_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        amount: Math.round(req.depositAmount * 100),
        email: req.userEmail,
        currency: 'GHS',
        reference: reference,
        callback_url: successUrl,
        metadata: {
          shop_id: req.shopId,
          user_id: req.userId,
          total_amount: req.totalAmount,
          deposit_amount: req.depositAmount,
          platform_fee: req.platformFee,
          services: req.services.map(s => s.serviceName).join(', '),
          idempotency_key: req.idempotencyKey,
        },
      }),
    });

    const data = await response.json();
    
    console.log('📦 Paystack response status:', response.status);
    console.log('📦 Paystack response data:', JSON.stringify(data, null, 2));

    if (!response.ok || !data.status) {
      return { 
        success: false, 
        error: data.message || `HTTP ${response.status}: Paystack error` 
      };
    }
    
    return {
      success: true,
      paymentIntentId: reference,
      authorizationUrl: data.data.authorization_url,
      reference: reference,
    };
  } catch (error) {
    console.error('Paystack error:', error);
    return { success: false, error: error.message };
  }
}

const isAfrican = africanCountries.some(country => 
  shopCountry === country || 
  shopCountry.includes(country)
);
console.log('🔍 isAfrican:', isAfrican);
console.log('🔍 provider:', isAfrican ? 'paystack' : 'stripe');

const provider = isAfrican ? 'paystack' : 'stripe';

console.log(`Shop country: ${shop.country}, normalized: ${shopCountry}, isAfrican: ${isAfrican}, using provider: ${provider}`);





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
    // STEP 4: PROCESS PAYMENT BASED ON PROVIDER
    // ========================================================================
    
  let paymentResult;
if (provider === 'stripe') {
  paymentResult = await processStripePayment(body);
} else {
  paymentResult = await processPaystackPayment(body);
}

    if (!paymentResult.success) {
      return new Response(
        JSON.stringify({ success: false, error: paymentResult.error }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // ========================================================================
    // STEP 5: STORE PENDING PAYMENT
    // ========================================================================
    
    await supabase
      .from('pending_payments')
      .upsert({
        idempotency_key: body.idempotencyKey,
        shop_id: body.shopId,
        user_id: body.userId,
        amount: body.totalAmount,
        payment_intent_id: paymentResult.paymentIntentId,
        payment_provider: body.paymentProvider,
        status: 'pending',
        booking_data: body,
        created_at: new Date().toISOString(),
        expires_at: new Date(Date.now() + 30 * 60 * 1000).toISOString(), // 30 min expiry
      });

    // ========================================================================
    // STEP 6: RETURN PAYMENT URL FOR WEBVIEW
    // ========================================================================
    
    return new Response(
      JSON.stringify({
        success: true,
        paymentIntentId: paymentResult.paymentIntentId,
        authorizationUrl: paymentResult.authorizationUrl,
        reference: paymentResult.reference,
        provider: body.paymentProvider,
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (error) {
    console.error('Payment error:', error);
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

  // Validate time slot is still available
  const { data: conflictBookings } = await supabase
    .from('bookings')
    .select('id')
    .eq('shop_id', req.shopId)
    .eq('status', 'confirmed')
    .gte('start_time', req.startTime)
    .lte('end_time', req.endTime);

  if (conflictBookings && conflictBookings.length > 0) {
    errors.push('Time slot is no longer available');
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
// STRIPE PAYMENT PROCESSING
// ============================================================================

async function processStripePayment(
  req: BookingRequest
): Promise<{ success: boolean; paymentIntentId?: string; authorizationUrl?: string; reference?: string; error?: string }> {
  try {
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [
        {
          price_data: {
            currency: 'usd',
            product_data: {
              name: 'Booking Deposit',
              description: `${req.services.length} service(s) booked`,
            },
            unit_amount: Math.round(req.depositAmount * 100),
          },
          quantity: 1,
        },
      ],
      mode: 'payment',
      success_url: req.successUrl || `${Deno.env.get('APP_URL')}/payment-success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: req.cancelUrl || `${Deno.env.get('APP_URL')}/payment-cancelled`,
      metadata: {
        shop_id: req.shopId,
        user_id: req.userId,
        total_amount: req.totalAmount.toString(),
        deposit_amount: req.depositAmount.toString(),
        platform_fee: req.platformFee.toString(),
        idempotency_key: req.idempotencyKey,
      },
      // Remove transfer_data if no destination account
      // payment_intent_data: {
      //   application_fee_amount: Math.round(req.platformFee * 100),
      //   transfer_data: {
      //     destination: paymentSettings.stripe_account_id,
      //   },
      // },
    });

    return {
      success: true,
      paymentIntentId: session.id,
      authorizationUrl: session.url,
      reference: session.id,
    };
  } catch (error) {
    console.error('Stripe error:', error);
    return { success: false, error: error.message };
  }
}

// ============================================================================
// PAYSTACK PAYMENT PROCESSING
// ============================================================================

async function processPaystackPayment(
  req: BookingRequest
): Promise<{ success: boolean; paymentIntentId?: string; authorizationUrl?: string; reference?: string; error?: string }> {
  try {
    const reference = `booking_${req.shopId}_${Date.now()}_${req.idempotencyKey.slice(0, 8)}`;

    const response = await fetch(`${PAYSTACK_BASE_URL}/transaction/initialize`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${PAYSTACK_SECRET_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        amount: Math.round(req.depositAmount * 100),
        email: req.userEmail,
        currency: 'GHS', // Hardcode or get from shop's currency
        reference: reference,
        metadata: {
          shop_id: req.shopId,
          user_id: req.userId,
          total_amount: req.totalAmount,
          deposit_amount: req.depositAmount,
          platform_fee: req.platformFee,
          services: req.services.map(s => s.serviceName).join(', '),
          idempotency_key: req.idempotencyKey,
        },
        // No subaccount needed for now – money goes to platform
      }),
    });

    const data = await response.json();
    if (!data.status) {
      return { success: false, error: data.message };
    }
    return {
      success: true,
      paymentIntentId: reference,
      authorizationUrl: data.data.authorization_url,
      reference: reference,
    };
  } catch (error) {
    console.error('Paystack error:', error);
    return { success: false, error: error.message };
  }
}