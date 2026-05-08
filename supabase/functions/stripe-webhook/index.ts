// supabase/functions/stripe-webhook/index.ts

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import Stripe from "https://esm.sh/stripe@13.6.0";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!, {
  apiVersion: '2023-10-16',
});

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
);

const WEBHOOK_SECRET = Deno.env.get('STRIPE_WEBHOOK_SECRET')!;

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }

  const signature = req.headers.get('stripe-signature');
  if (!signature) {
    return new Response('Missing stripe-signature header', { status: 400 });
  }

  let event: Stripe.Event;

  try {
    const body = await req.text();
    // Verify the webhook signature — rejects any tampered or forged payloads
    event = await stripe.webhooks.constructEventAsync(body, signature, WEBHOOK_SECRET);
  } catch (err) {
    console.error('Webhook signature verification failed:', err.message);
    return new Response(`Webhook signature verification failed: ${err.message}`, { status: 400 });
  }

  try {
    switch (event.type) {
      case 'account.updated':
        await handleAccountUpdated(event.data.object as Stripe.Account);
        break;

      case 'account.application.deauthorized':
        // Merchant revoked access directly from their Stripe dashboard
        await handleDeauthorized(event.account!);
        break;

      default:
        // Acknowledge unhandled event types without error
        break;
    }

    return new Response(JSON.stringify({ received: true }), {
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (err) {
    console.error(`Error handling webhook event ${event.type}:`, err);
    // Return 500 so Stripe retries the webhook
    return new Response('Webhook handler error', { status: 500 });
  }
});

async function handleAccountUpdated(account: Stripe.Account) {
  // Find the shop connected to this Stripe account
  const { data: settings } = await supabase
    .from('payment_settings')
    .select('shop_id')
    .eq('stripe_account_id', account.id)
    .single();

  if (!settings) {
    // Account not in our system — could be a test account or already disconnected
    return;
  }

  await supabase
    .from('payment_settings')
    .update({
      stripe_account_status: account.charges_enabled ? 'active' : 'pending',
      stripe_charges_enabled: account.charges_enabled ?? false,
      stripe_payouts_enabled: account.payouts_enabled ?? false,
    })
    .eq('shop_id', settings.shop_id);

  console.log(`Updated account status for shop ${settings.shop_id}: charges=${account.charges_enabled}, payouts=${account.payouts_enabled}`);
}

async function handleDeauthorized(stripeAccountId: string) {
  // Merchant deauthorised the app from Stripe's side — mirror that locally
  const { data: settings } = await supabase
    .from('payment_settings')
    .select('shop_id')
    .eq('stripe_account_id', stripeAccountId)
    .single();

  if (!settings) return;

  await supabase
    .from('payment_settings')
    .update({
      payment_provider: 'none',
      stripe_account_id: null,
      stripe_account_status: null,
      stripe_charges_enabled: null,
      stripe_payouts_enabled: null,
      payout_schedule: null,
      payout_minimum: null,
      payout_currency: null,
      connected_at: null,
    })
    .eq('shop_id', settings.shop_id);

  console.log(`Shop ${settings.shop_id} deauthorised Stripe from dashboard — local record cleared`);
}