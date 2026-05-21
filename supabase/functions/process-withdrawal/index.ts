// supabase/functions/process-withdrawal/index.ts

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";
import {
  isDebugLogging,
  redactForLog,
  sanitizeIdentifier,
} from "../_shared/sanitize.ts";
import { audit } from "../_shared/audit.ts";
import { getProvider } from "../_shared/providers/registry.ts";
import { PaymentProviderError, type PaymentProviderName } from "../_shared/providers/port.ts";

// ============================================================================
// Configuration
// ============================================================================

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
);

// Internal callers (DB webhook trigger) must include this secret in the Authorization header
const INTERNAL_WEBHOOK_SECRET = Deno.env.get('INTERNAL_WEBHOOK_SECRET');

// ============================================================================
// Main Handler
// ============================================================================

serve(async (req) => {
  // Verify internal caller secret — this endpoint is not user-facing
  if (!INTERNAL_WEBHOOK_SECRET) {
    console.error('❌ INTERNAL_WEBHOOK_SECRET not configured');
    return new Response(JSON.stringify({ error: 'Server misconfiguration' }), { status: 500 });
  }

  const authHeader = req.headers.get('Authorization');
  if (authHeader !== `Bearer ${INTERNAL_WEBHOOK_SECRET}`) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 });
  }

  try {
    const body = await req.json();
    let withdrawalId: string;
    try {
      withdrawalId = sanitizeIdentifier(body.withdrawal_id, 64);
    } catch (sanErr) {
      return new Response(
        JSON.stringify({ error: (sanErr as Error).message }),
        { status: 400 },
      );
    }

    if (!withdrawalId) {
      return new Response(
        JSON.stringify({ error: 'withdrawal_id required' }),
        { status: 400 }
      );
    }

    const result = await processWithdrawal(withdrawalId);

    return new Response(
      JSON.stringify(result),
      { headers: { 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    console.error('Error processing withdrawal:', (error as Error).message);
    if (isDebugLogging()) {
      console.error('full error:', redactForLog(error));
    }
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      { status: 500 }
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
    try {
      const provider = getProvider(withdrawal.payment_provider as PaymentProviderName);
      transferResult = await provider.processPayout({
        amount: withdrawal.net_amount ?? withdrawal.amount,
        currency: await getWalletCurrency(withdrawal.shops.id),
        destinationAccountId: withdrawal.transfer_recipient_id,
        reference: withdrawal.idempotency_key,
        reason: "Withdrawal",
      });
    } catch (e) {
      if (e instanceof PaymentProviderError) {
        throw new Error(e.message);
      }
      throw e;
    }

    // The port returns providerTransferId in the same field shape as before.
    const transferIdForCompletion = transferResult.providerTransferId;

    // 5. Complete withdrawal
    await completeWithdrawal(withdrawalId, transferIdForCompletion);

    await audit(supabase, {
      action: 'withdrawal.complete',
      actorUserId: withdrawal.shops.user_id,
      shopId: withdrawal.shops.id,
      targetId: withdrawalId,
      outcome: 'success',
      context: {
        provider: withdrawal.payment_provider,
        amount: withdrawal.amount,
        net_amount: withdrawal.net_amount,
        transfer_id: transferIdForCompletion,
      },
    });

    // 6. Send success notification (resolve currency from wallet, not hardcoded)
    const currency = await getWalletCurrency(withdrawal.shops.id);
    await sendNotification(
      withdrawal.shops.user_id,
      'success',
      withdrawal.amount,
      withdrawal.net_amount || withdrawal.amount,
      undefined,
      currency,
    );

    console.log(`✅ Withdrawal completed: ${withdrawalId}`);
    return { success: true, transfer: transferResult };

  } catch (error) {
    console.error(`❌ Withdrawal failed for ${withdrawalId}:`, error);

    // 7. Mark as failed and refund
    await failWithdrawal(withdrawalId, (error as Error).message);

    await audit(supabase, {
      action: 'withdrawal.fail',
      actorUserId: withdrawal.shops.user_id,
      shopId: withdrawal.shops.id,
      targetId: withdrawalId,
      outcome: 'failure',
      context: {
        provider: withdrawal.payment_provider,
        amount: withdrawal.amount,
        error: (error as Error).message,
      },
    });

    // 8. Send failure notification (resolve currency from wallet)
    const currency = await getWalletCurrency(withdrawal.shops.id);
    await sendNotification(
      withdrawal.shops.user_id,
      'failure',
      withdrawal.amount,
      withdrawal.net_amount || withdrawal.amount,
      (error as Error).message,
      currency,
    );

    return { success: false, error: error.message };
  }
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
  error?: string,
  currency: string = 'GHS',
) {
  try {
    const notification = {
      user_id: userId,
      type: `withdrawal_${type}`,
      title: type === 'success' ? 'Withdrawal Completed' : 'Withdrawal Failed',
      body: type === 'success'
        ? `${currency} ${amount.toFixed(2)} has been sent to your account. Net amount: ${currency} ${netAmount.toFixed(2)}`
        : `Withdrawal of ${currency} ${amount.toFixed(2)} failed: ${error?.substring(0, 200) ?? 'Unknown error'}`,
      metadata: {
        withdrawal_amount: amount,
        net_amount: netAmount,
        currency,
        error: error,
      },
      created_at: new Date().toISOString(),
    };

    await supabase.from('notifications').insert(notification);
    console.log(`📧 Notification sent to user ${userId}`);
  } catch (e) {
    console.error('Failed to send notification:', (e as Error).message);
  }
}

async function getWalletCurrency(shopId: string): Promise<string> {
  try {
    const { data } = await supabase
      .from('wallets')
      .select('currency')
      .eq('shop_id', shopId)
      .maybeSingle();
    return (data?.currency as string | undefined) ?? 'GHS';
  } catch {
    return 'GHS';
  }
}