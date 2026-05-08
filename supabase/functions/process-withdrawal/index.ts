// supabase/functions/process-withdrawal/index.ts

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

// ============================================================================
// Configuration
// ============================================================================

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
);

const PAYSTACK_SECRET_KEY = Deno.env.get('PAYSTACK_SECRET_KEY')!;
const PAYSTACK_BASE_URL = 'https://api.paystack.co';

const STRIPE_SECRET_KEY = Deno.env.get('STRIPE_SECRET_KEY');
const STRIPE_BASE_URL = 'https://api.stripe.com/v1';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

// ============================================================================
// Main Handler
// ============================================================================

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const { withdrawal_id } = body;

    if (!withdrawal_id) {
      return new Response(
        JSON.stringify({ error: 'withdrawal_id required' }),
        { status: 400, headers: corsHeaders }
      );
    }

    const result = await processWithdrawal(withdrawal_id);
    
    return new Response(
      JSON.stringify(result),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    console.error('Error processing withdrawal:', error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: corsHeaders }
    );
  }
});

// ============================================================================
// Main Processing Logic
// ============================================================================

async function processWithdrawal(withdrawalId: string) {
  console.log(`📦 Processing withdrawal: ${withdrawalId}`);

  // 1. Get withdrawal request with shop details
  const { data: withdrawal, error: fetchError } = await supabase
    .from('withdrawal_requests')
    .select(`
      *,
      shops!inner (
        id,
        user_id,
        shop_name
      )
    `)
    .eq('id', withdrawalId)
    .single();

  if (fetchError || !withdrawal) {
    console.error('Withdrawal not found:', fetchError);
    throw new Error('Withdrawal request not found');
  }

  console.log(`💰 Withdrawal amount: ${withdrawal.amount} ${withdrawal.payment_provider}`);

  // 2. Only process pending withdrawals
  if (withdrawal.status !== 'pending') {
    console.log(`⏭️ Withdrawal already ${withdrawal.status}, skipping`);
    return { success: false, message: `Withdrawal already ${withdrawal.status}` };
  }

  // 3. Update status to processing
  await supabase
    .from('withdrawal_requests')
    .update({ 
      status: 'processing', 
      updated_at: new Date().toISOString() 
    })
    .eq('id', withdrawalId);

  try {
    let transferResult;

    // 4. Process based on provider
    if (withdrawal.payment_provider === 'paystack') {
      transferResult = await processPaystackWithdrawal(
        withdrawal.amount,
        withdrawal.transfer_recipient_id,
        withdrawal.idempotency_key
      );
    } else if (withdrawal.payment_provider === 'stripe' && STRIPE_SECRET_KEY) {
      transferResult = await processStripeWithdrawal(
        withdrawal.amount,
        withdrawal.transfer_recipient_id,
        withdrawal.net_amount || withdrawal.amount
      );
    } else {
      throw new Error(`Unknown payment provider: ${withdrawal.payment_provider}`);
    }

    // 5. Complete withdrawal
    await completeWithdrawal(withdrawalId, transferResult.id);

    // 6. Send success notification
    await sendNotification(
      withdrawal.shops.user_id,
      'success',
      withdrawal.amount,
      withdrawal.net_amount || withdrawal.amount
    );

    console.log(`✅ Withdrawal completed: ${withdrawalId}`);
    return { success: true, transfer: transferResult };

  } catch (error) {
    console.error(`❌ Withdrawal failed for ${withdrawalId}:`, error);

    // 7. Mark as failed and refund
    await failWithdrawal(withdrawalId, error.message);

    // 8. Send failure notification
    await sendNotification(
      withdrawal.shops.user_id,
      'failure',
      withdrawal.amount,
      withdrawal.net_amount || withdrawal.amount,
      error.message
    );

    return { success: false, error: error.message };
  }
}

// ============================================================================
// Paystack Withdrawal
// ============================================================================

async function processPaystackWithdrawal(amount: number, recipientId: string, idempotencyKey: string) {
  const amountInKobo = Math.round(amount * 100);
  
  console.log(`💰 Processing Paystack withdrawal: ${amountInKobo} kobo to recipient ${recipientId}`);

  const response = await fetch(`${PAYSTACK_BASE_URL}/transfer`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${PAYSTACK_SECRET_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      source: 'balance',
      amount: amountInKobo,
      recipient: recipientId,
      reference: idempotencyKey,
      reason: 'Withdrawal from NanoEmbryo',
    }),
  });

  const data = await response.json();

  if (!data.status) {
    console.error('Paystack transfer failed:', data);
    throw new Error(data.message || 'Paystack transfer failed');
  }

  console.log(`✅ Paystack transfer created: ${data.data.transfer_code}`);
  
  return {
    id: data.data.transfer_code,
    status: data.data.status,
    reference: data.data.reference
  };
}

// ============================================================================
// Stripe Withdrawal
// ============================================================================

async function processStripeWithdrawal(amount: number, accountId: string, netAmount: number) {
  const amountInCents = Math.round(netAmount * 100);
  
  console.log(`💰 Processing Stripe withdrawal: ${amountInCents} cents to account ${accountId}`);

  const response = await fetch(`${STRIPE_BASE_URL}/payouts`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams({
      amount: amountInCents.toString(),
      currency: 'usd',
      destination: accountId,
      description: 'Withdrawal from NanoEmbryo',
    }).toString(),
  });

  const data = await response.json();

  if (!response.ok || data.error) {
    console.error('Stripe payout failed:', data);
    throw new Error(data.error?.message || 'Stripe payout failed');
  }

  console.log(`✅ Stripe payout created: ${data.id}`);
  
  return {
    id: data.id,
    status: data.status,
    reference: data.idempotency_key
  };
}

// ============================================================================
// Database Operations
// ============================================================================

async function completeWithdrawal(withdrawalId: string, providerTransferId: string) {
  const { error } = await supabase.rpc('complete_withdrawal', {
    p_withdrawal_id: withdrawalId,
    p_provider_transfer_id: providerTransferId,
  });

  if (error) {
    console.error('Failed to complete withdrawal in DB:', error);
    throw new Error('Failed to update withdrawal status');
  }
}

async function failWithdrawal(withdrawalId: string, reason: string) {
  const { error } = await supabase.rpc('fail_withdrawal', {
    p_withdrawal_id: withdrawalId,
    p_failed_reason: reason,
  });

  if (error) {
    console.error('Failed to fail withdrawal in DB:', error);
    // Don't throw - we already tried to refund
  }
}

// ============================================================================
// Notifications
// ============================================================================

async function sendNotification(
  userId: string,
  type: 'success' | 'failure',
  amount: number,
  netAmount: number,
  error?: string
) {
  try {
    const notification = {
      user_id: userId,
      type: `withdrawal_${type}`,
      title: type === 'success' ? 'Withdrawal Completed' : 'Withdrawal Failed',
      body: type === 'success' 
        ? `GHS ${amount.toFixed(2)} has been sent to your account. Net amount: GHS ${netAmount.toFixed(2)}`
        : `Withdrawal of GHS ${amount.toFixed(2)} failed: ${error?.substring(0, 200) ?? 'Unknown error'}`,
      metadata: {
        withdrawal_amount: amount,
        net_amount: netAmount,
        error: error,
      },
      created_at: new Date().toISOString(),
    };

    await supabase.from('notifications').insert(notification);
    console.log(`📧 Notification sent to user ${userId}`);
  } catch (e) {
    console.error('Failed to send notification:', e);
  }
}