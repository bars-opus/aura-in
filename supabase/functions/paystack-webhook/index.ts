import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
);

const PAYSTACK_WEBHOOK_SECRET = Deno.env.get('PAYSTACK_WEBHOOK_SECRET');

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

async function verifyPaystackSignature(
  payload: string,
  signature: string | null,
  secret: string
): Promise<boolean> {
  if (!signature) return false;

  const encoder = new TextEncoder();
  const cryptoKey = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-512' },
    false,
    ['sign']
  );

  const signatureBuffer = await crypto.subtle.sign(
    'HMAC',
    cryptoKey,
    encoder.encode(payload)
  );

  const computedSignature = Array.from(new Uint8Array(signatureBuffer))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');

  return computedSignature === signature;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const payload = await req.text();
    const signature = req.headers.get('x-paystack-signature');

    if (PAYSTACK_WEBHOOK_SECRET) {
      const isValid = await verifyPaystackSignature(
        payload,
        signature,
        PAYSTACK_WEBHOOK_SECRET
      );
      if (!isValid) {
        console.error('❌ Invalid webhook signature');
        return new Response(
          JSON.stringify({ error: 'Invalid signature' }),
          { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
      }
      console.log('✅ Webhook signature verified');
    } else {
      console.warn('⚠️ PAYSTACK_WEBHOOK_SECRET not set - skipping verification');
    }

    const event = JSON.parse(payload);
    console.log('📨 Webhook event:', event.event);

    switch (event.event) {
      case 'charge.success':
        await handlePaymentSuccess(event.data);
        break;
      case 'charge.failed':
        await handlePaymentFailure(event.data);
        break;
      case 'transfer.success':
        await handleTransferSuccess(event.data);
        break;
      default:
        console.log('Unhandled event type:', event.event);
    }

    // Always return 200 quickly — Paystack retries if you don't
    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('Webhook error:', error);
    // Still return 200 to prevent Paystack from retrying on our bugs
    return new Response(
      JSON.stringify({ received: true, error: error.message }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});

async function handlePaymentSuccess(transaction: any) {
  const reference = transaction.reference;
  const amount = transaction.amount / 100;

  console.log('💰 Payment successful:', { reference, amount });

  // Idempotency check — don't create booking twice
  const { data: existing } = await supabase
    .from('bookings')
    .select('id')
    .eq('payment_intent_id', reference)
    .maybeSingle();

  if (existing) {
    console.log('⚠️ Already processed:', reference);
    return;
  }

  // Load pending payment (contains full booking data)
  const { data: pending, error: pendingError } = await supabase
    .from('pending_payments')
    .select('*')
    .eq('payment_intent_id', reference)
    .maybeSingle();

  if (pendingError || !pending) {
    console.error('❌ No pending payment found:', reference);
    return;
  }

  const bookingData = pending.booking_data;

  // Create the booking
  const { data: booking, error: bookingError } = await supabase
    .from('bookings')
    .insert({
      shop_id: pending.shop_id,
      user_id: pending.user_id,
      payment_intent_id: reference,
      payment_provider: pending.payment_provider,
      payment_status: 'paid',
      status: 'confirmed',
      total_amount: pending.amount,
      deposit_amount: bookingData.depositAmount,
      platform_fee: bookingData.platformFee,
      start_time: bookingData.startTime,
      end_time: bookingData.endTime,
      actual_end_time: bookingData.actualEndTime,
      services: bookingData.services,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })
    .select()
    .single();

  if (bookingError || !booking) {
    console.error('❌ Failed to create booking:', bookingError);
    return;
  }

  console.log('✅ Booking created:', booking.id);

  // Mark pending payment as completed
  await supabase
    .from('pending_payments')
    .update({
      status: 'completed',
      booking_id: booking.id,
      completed_at: new Date().toISOString(),
    })
    .eq('payment_intent_id', reference);

  // Add wallet transaction
  const { error: walletError } = await supabase.rpc('add_wallet_transaction', {
    p_shop_id: pending.shop_id,
    p_amount: amount,
    p_type: 'deposit',
    p_booking_id: booking.id,
    p_description: `Payment for booking ${booking.id.substring(0, 8)}`,
    p_reference: reference,
  });

  if (walletError) {
    console.error('⚠️ Wallet transaction failed (non-fatal):', walletError);
  }

  // Notify shop owner
  await supabase.from('notifications').insert({
    shop_id: pending.shop_id,
    type: 'payment_received',
    title: 'New Booking Confirmed',
    message: `New booking confirmed. Payment of GHS ${amount} received.`,
    read: false,
    created_at: new Date().toISOString(),
  });
}

async function handlePaymentFailure(transaction: any) {
  const reference = transaction.reference;
  console.log('❌ Payment failed:', { reference });

  await supabase
    .from('pending_payments')
    .update({
      status: 'failed',
      updated_at: new Date().toISOString(),
    })
    .eq('payment_intent_id', reference);
}

async function handleTransferSuccess(transfer: any) {
  console.log('💸 Transfer successful:', {
    reference: transfer.reference,
    amount: transfer.amount / 100,
  });

  await supabase
    .from('withdrawal_requests')
    .update({
      status: 'completed',
      processed_at: new Date().toISOString(),
    })
    .eq('reference', transfer.reference);
}