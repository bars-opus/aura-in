// supabase/functions/paystack-subaccount/index.ts

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const PAYSTACK_SECRET_KEY = Deno.env.get('PAYSTACK_SECRET_KEY')!;
const PAYSTACK_BASE_URL = 'https://api.paystack.co';

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
);

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const PLATFORM_PERCENTAGE_CHARGE = '2.9';

// ============================================================================
// Ghana mobile money provider codes as returned by Paystack's /bank API.
// These are NOT valid settlement_bank values for /subaccount.
// ============================================================================
const GHANA_MOBILE_MONEY_CODES = new Set(['MTN', 'VOD', 'ATL', 'TGO']);

function isMobileMoney(bankCode: string): boolean {
  // Normalize to uppercase for comparison
  return GHANA_MOBILE_MONEY_CODES.has(bankCode.toUpperCase());
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: corsHeaders,
      });
    }

    const token = authHeader.replace('Bearer ', '');
    const { data: { user }, error: userError } = await supabase.auth.getUser(token);

    if (userError || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: corsHeaders,
      });
    }

    const body = await req.json();
    const { action } = body;

    if (action === 'fetch-banks') {
      const { currencyCode } = body;
      if (!currencyCode) {
        return new Response(JSON.stringify({ error: 'currencyCode required' }), {
          status: 400,
          headers: corsHeaders,
        });
      }
      return await fetchBanks(currencyCode);
    }

    if (action === 'create-subaccount') {
      const { shopId, businessName, bankCode, accountNumber, currencyCode } = body;

      if (!shopId || !bankCode || !accountNumber) {
        return new Response(JSON.stringify({ error: 'shopId, bankCode, and accountNumber required' }), {
          status: 400,
          headers: corsHeaders,
        });
      }

      const { data: shop, error: shopError } = await supabase
        .from('shops')
        .select('id, user_id, shop_name')
        .eq('id', shopId)
        .single();

      if (shopError || !shop) {
        return new Response(JSON.stringify({ error: 'Shop not found' }), {
          status: 404,
          headers: corsHeaders,
        });
      }

      if (shop.user_id !== user.id) {
        return new Response(JSON.stringify({ error: 'Unauthorized' }), {
          status: 403,
          headers: corsHeaders,
        });
      }

      return await createSubaccount(
        shop.id,
        businessName || shop.shop_name,
        bankCode,
        accountNumber,
        currencyCode || 'GHS'
      );
    }

    if (action === 'get-status') {
      const { shopId } = body;
      if (!shopId) {
        return new Response(JSON.stringify({ error: 'shopId required' }), {
          status: 400,
          headers: corsHeaders,
        });
      }
      return await getSubaccountStatus(shopId);
    }

    if (action === 'disconnect') {
      const { shopId } = body;
      if (!shopId) {
        return new Response(JSON.stringify({ error: 'shopId required' }), {
          status: 400,
          headers: corsHeaders,
        });
      }
      return await disconnectSubaccount(shopId);
    }

    return new Response(JSON.stringify({ error: 'Invalid action' }), {
      status: 400,
      headers: corsHeaders,
    });
  } catch (error) {
    console.error('Error:', error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: corsHeaders,
    });
  }
});

// ============================================================================
// Fetch Banks
// ============================================================================
async function fetchBanks(currencyCode: string) {
  try {
    const response = await fetch(`${PAYSTACK_BASE_URL}/bank?currency=${currencyCode}`, {
      headers: { 'Authorization': `Bearer ${PAYSTACK_SECRET_KEY}` },
    });

    const data = await response.json();

    if (!data.status) {
      return new Response(
        JSON.stringify({ error: data.message }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const banks = data.data
      .filter((bank: any) => bank.currency === currencyCode)
      .map((bank: any) => ({
        code: bank.code,
        name: bank.name,
      }));

    return new Response(
      JSON.stringify(banks),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (err) {
    console.error('fetchBanks error:', err);
    return new Response(
      JSON.stringify({ error: 'Failed to fetch banks' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
}

// ============================================================================
// Create Subaccount
//
// Two paths:
//   A) Mobile money (mtn / vod / atl / tgo)
//      → Skip /subaccount (not supported by Paystack for MoMo)
//      → Only create a transfer recipient with type "mobile_money"
//      → Store recipient_code; subaccount_code is null
//
//   B) Bank account (all other codes)
//      → Create /subaccount  (settlement_bank = bankCode)
//      → Create transfer recipient with type "ghipss"
//      → Store both codes
// ============================================================================
async function createSubaccount(
  shopId: string,
  businessName: string,
  bankCode: string,
  accountNumber: string,
  currencyCode: string,
) {

  // ADD THIS LINE:
  console.log('🔍 RAW bankCode received:', JSON.stringify(bankCode));
  console.log(`💳 isMobileMoney check:`, isMobileMoney(bankCode));

  // Guard: don't create duplicates
  const { data: existing } = await supabase
    .from('payment_settings')
    .select('paystack_subaccount_code, paystack_recipient_id')
    .eq('shop_id', shopId)
    .single();

  if (existing?.paystack_subaccount_code || existing?.paystack_recipient_id) {
    return new Response(
      JSON.stringify({ error: 'Payment details already exist for this shop. Disconnect first.' }),
      { status: 409, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }

  const mobileMoneyFlow = isMobileMoney(bankCode);
  console.log(`💳 Payment type: ${mobileMoneyFlow ? 'Mobile Money' : 'Bank Account'} (code: ${bankCode})`);

  try {
    let subaccountCode: string | null = null;
    let recipientCode: string | null = null;

    // ------------------------------------------------------------------
    // PATH A — Mobile Money
    // ------------------------------------------------------------------
    if (mobileMoneyFlow) {
      recipientCode = await createMobileMoneyRecipient({
        businessName,
        bankCode,
        accountNumber,
        currencyCode,
      });
    }
    // ------------------------------------------------------------------
    // PATH B — Bank Account
    // ------------------------------------------------------------------
    else {
      // Step 1: Create subaccount
      const subaccountBody = {
        business_name: businessName,
        settlement_bank: bankCode,
        account_number: accountNumber,
        percentage_charge: PLATFORM_PERCENTAGE_CHARGE,
      };

      console.log('📦 Creating subaccount:', JSON.stringify(subaccountBody));

      const subRes = await fetch(`${PAYSTACK_BASE_URL}/subaccount`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${PAYSTACK_SECRET_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(subaccountBody),
      });

      const subData = await subRes.json();

      if (!subData.status) {
        throw new Error(subData.message || 'Subaccount creation failed');
      }

      subaccountCode = subData.data.subaccount_code;
      console.log('✅ Subaccount created:', subaccountCode);

      // Step 2: Create transfer recipient (ghipss = Ghana Interbank Payment)
      try {
        recipientCode = await createBankRecipient({
          businessName,
          bankCode,
          accountNumber,
          currencyCode,
        });
      } catch (recipientErr) {
        // Compensate: remove the subaccount we just created so state stays clean
        console.error('❌ Transfer recipient failed, rolling back subaccount...');
        await fetch(`${PAYSTACK_BASE_URL}/subaccount/${subaccountCode}`, {
          method: 'DELETE',
          headers: { 'Authorization': `Bearer ${PAYSTACK_SECRET_KEY}` },
        });
        throw recipientErr;
      }
    }

    // ------------------------------------------------------------------
    // Step 3: Persist to database (same table, works for both paths)
    // ------------------------------------------------------------------
    await supabase
      .from('payment_settings')
      .upsert({
        shop_id: shopId,
        payment_provider: 'paystack',
        paystack_subaccount_code: subaccountCode,
        paystack_recipient_id: recipientCode,
        paystack_verified: true,
        paystack_currency: currencyCode,
        connected_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      });

    console.log('✅ Saved to payment_settings');

    return new Response(
      JSON.stringify({
        success: true,
        subaccount_code: subaccountCode,   // null for mobile money — that's fine
        recipient_code: recipientCode,
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (error) {
    console.error('❌ Error in createSubaccount:', error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
}

// ============================================================================
// Helper — Create transfer recipient for a Ghana bank account (ghipss)
// ============================================================================
async function createBankRecipient(params: {
  businessName: string;
  bankCode: string;
  accountNumber: string;
  currencyCode: string;
}): Promise<string> {
  const body = {
    type: 'ghipss',
    name: params.businessName,
    account_number: params.accountNumber,
    bank_code: params.bankCode,
    currency: params.currencyCode,
  };

  console.log('📦 Creating bank transfer recipient:', JSON.stringify(body));

  const res = await fetch(`${PAYSTACK_BASE_URL}/transferrecipient`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${PAYSTACK_SECRET_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });

  const data = await res.json();

  if (!data.status) {
    throw new Error(data.message || 'Bank transfer recipient creation failed');
  }

  console.log('✅ Bank transfer recipient created:', data.data.recipient_code);
  return data.data.recipient_code;
}

// ============================================================================
// Helper — Create transfer recipient for Ghana mobile money
//
// Paystack expects:
//   type         → "mobile_money"
//   bank_code    → the MoMo provider code  (mtn | vod | atl)
//   account_number → the subscriber's phone number  e.g. "0241234567"
//   currency     → "GHS"
// ============================================================================
async function createMobileMoneyRecipient(params: {
  businessName: string;
  bankCode: string;
  accountNumber: string;
  currencyCode: string;
}): Promise<string> {
  const body = {
    type: 'mobile_money',
    name: params.businessName,
    account_number: params.accountNumber,
    bank_code: params.bankCode,
    currency: params.currencyCode,
  };

  console.log('📦 Creating mobile money transfer recipient:', JSON.stringify(body));

  const res = await fetch(`${PAYSTACK_BASE_URL}/transferrecipient`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${PAYSTACK_SECRET_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });

  const data = await res.json();

  if (!data.status) {
    throw new Error(data.message || 'Mobile money recipient creation failed');
  }

  console.log('✅ Mobile money recipient created:', data.data.recipient_code);
  return data.data.recipient_code;
}

// ============================================================================
// Get Subaccount Status
// ============================================================================
async function getSubaccountStatus(shopId: string) {
  const { data: settings } = await supabase
    .from('payment_settings')
    .select('paystack_subaccount_code, paystack_verified, paystack_recipient_id, paystack_payment_type')
    .eq('shop_id', shopId)
    .single();

  return new Response(
    JSON.stringify({
      // For mobile money, subaccount_code is null — connected is true if recipient exists
      connected: !!(settings?.paystack_subaccount_code || settings?.paystack_recipient_id),
      verified: settings?.paystack_verified,
      has_recipient: !!settings?.paystack_recipient_id,
      payment_type: settings?.paystack_payment_type ?? null,
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}

// ============================================================================
// Disconnect Subaccount
// ============================================================================
async function disconnectSubaccount(shopId: string) {
  await supabase
    .from('payment_settings')
    .update({
      payment_provider: null,
      paystack_subaccount_code: null,
      paystack_recipient_id: null,
      paystack_verified: false,
      paystack_business_name: null,
      paystack_account_number: null,
      paystack_currency: null,
      paystack_payment_type: null,
      connected_at: null,
    })
    .eq('shop_id', shopId);

  return new Response(
    JSON.stringify({ success: true }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}