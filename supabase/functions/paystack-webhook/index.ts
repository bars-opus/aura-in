import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";
import { isDebugLogging, redactForLog } from "../_shared/sanitize.ts";
import { getProvider } from "../_shared/providers/registry.ts";

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
);

// Webhooks are server-to-server only — no browser-initiated CORS needed.
// Locking this down reduces attack surface.

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }

  try {
    const payload = await req.text();
    const signature = req.headers.get('x-paystack-signature') ?? '';

    const provider = getProvider('paystack');
    const isValid = await provider.verifyWebhookSignature({
      rawBody: payload,
      signatureHeader: signature,
    });
    if (!isValid) {
      console.error('❌ Invalid webhook signature');
      return new Response(
        JSON.stringify({ error: 'Invalid signature' }),
        { status: 401, headers: { 'Content-Type': 'application/json' } }
      );
    }
    console.log('✅ Webhook signature verified');

    const event = JSON.parse(payload);
    console.log('📨 Webhook event:', event.event);
    if (isDebugLogging()) {
      console.log('📦 Webhook payload:', redactForLog(event));
    }

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
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('Webhook error:', error);
    // Still return 200 to prevent Paystack from retrying on our bugs
    return new Response(
      JSON.stringify({ received: true, error: error.message }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
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
    .eq('status', 'pending')
    .maybeSingle();

  if (pendingError || !pending) {
    console.error('❌ No pending payment found:', reference);
    return;
  }

  // Guard against payments that arrive after the 30-minute booking window.
  // The slot may have already been rebooked — safer to reject than double-book.
  if (pending.expires_at && new Date(pending.expires_at) < new Date()) {
    console.error('❌ Pending payment expired for reference:', reference);
    await supabase
      .from('pending_payments')
      .update({ status: 'expired', updated_at: new Date().toISOString() })
      .eq('payment_intent_id', reference);
    return;
  }

  const bookingData = pending.booking_data;

  // Create the booking
  const { data: booking, error: bookingError } = await supabase
    .from('bookings')
    .insert({
      shop_id: pending.shop_id,
      user_id: pending.user_id,
      booking_date: bookingData.startTime,
      payment_intent_id: reference,
      payment_method: pending.payment_provider,
      payment_status: 'paid',
      status: 'confirmed',
      total_amount: pending.amount,
      deposit_amount: bookingData.depositAmount,
      platform_fee: bookingData.platformFee,
      start_time: bookingData.startTime,
      end_time: bookingData.endTime,
      actual_end_time: bookingData.actualEndTime,
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

  // Insert booking_services rows
  if (Array.isArray(bookingData.services) && bookingData.services.length > 0) {
    const serviceRows = (bookingData.services as any[]).map((s: any) => ({
      booking_id: booking.id,
      slot_id: s.slotId,
      worker_id: s.workerId ?? null,
      price_at_booking: s.priceAtBooking,
      duration_minutes: s.durationMinutes,
      service_name: s.serviceName,
      worker_name: s.workerName ?? null,
      start_time: bookingData.startTime,
      created_at: new Date().toISOString(),
    }));
    const { error: servicesError } = await supabase.from('booking_services').insert(serviceRows);
    if (servicesError) console.error('⚠️ booking_services insert failed (non-fatal):', servicesError);
  }

  // Mark pending payment as completed
  await supabase
    .from('pending_payments')
    .update({
      status: 'completed',
      booking_id: booking.id,
      completed_at: new Date().toISOString(),
    })
    .eq('payment_intent_id', reference);

  // Credit shop wallet with the net amount (deposit minus platform fee)
  const platformFee = bookingData.platformFee ?? 0;
  const netAmount = amount - platformFee;
  const { error: walletError } = await supabase.rpc('add_wallet_transaction', {
    p_shop_id: pending.shop_id,
    p_amount: netAmount,
    p_type: 'deposit',
    p_booking_id: booking.id,
    p_description: `Payment for booking ${booking.id.substring(0, 8)}`,
    p_reference: reference,
  });

  if (walletError) {
    console.error('⚠️ Wallet transaction failed (non-fatal):', walletError);
  }

  // Shop dashboard notification (business-level event log)
  await supabase.from('notifications').insert({
    shop_id: pending.shop_id,
    type: 'payment_received',
    title: 'New Booking Confirmed',
    message: `New booking confirmed. Payment of GHS ${amount} received.`,
    read: false,
    created_at: new Date().toISOString(),
  });

  // Push notification + in-app inbox entries + all booking reminders.
  // Non-fatal — booking creation must not be rolled back if notifications fail.
  await scheduleBookingNotifications(booking, bookingData, pending.shop_id, pending.user_id);
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

  // Look up the withdrawal request by its idempotency_key (matches transfer reference)
  const { data: withdrawal } = await supabase
    .from('withdrawal_requests')
    .select('id, status')
    .eq('idempotency_key', transfer.reference)
    .maybeSingle();

  if (!withdrawal) {
    console.error('❌ No withdrawal request found for reference:', transfer.reference);
    return;
  }

  if (withdrawal.status === 'completed') {
    console.log('⚠️ Withdrawal already completed:', transfer.reference);
    return;
  }

  // Use the same RPC as process-withdrawal so wallet balance and total_withdrawn stay consistent
  const { error } = await supabase.rpc('complete_withdrawal', {
    p_withdrawal_id: withdrawal.id,
    p_provider_transfer_id: transfer.transfer_code || transfer.id,
  });

  if (error) {
    console.error('❌ Failed to complete withdrawal via RPC:', error);
  } else {
    console.log('✅ Withdrawal completed and wallet debited:', withdrawal.id);
  }
}

// ============================================================================
// scheduleBookingNotifications
//
// Called after a booking is confirmed. Writes to three places in one shot:
//   1. in_app_notifications  — client's notification bell (instant inbox entry)
//   2. in_app_notifications  — shop owner's notification bell
//   3. scheduled_notifications (type: 'immediate') — triggers OneSignal push
//      to the client via the process-scheduled-notifications cron (~1 min delay)
//   4. scheduled_notifications (future) — 24 h / 1 h / 5 min reminders for
//      the client, shop owner's 15-min heads-up, and post-appointment review ask
//
// Entirely non-fatal: a notification failure must never roll back the booking.
// ============================================================================
async function scheduleBookingNotifications(
  booking: { id: string },
  bookingData: any,
  shopId: string,
  clientUserId: string,
): Promise<void> {
  try {
    const now = new Date();
    const startTime = new Date(bookingData.startTime);
    const endTime = new Date(bookingData.actualEndTime ?? bookingData.endTime);

    const serviceNames = (bookingData.services as Array<{ serviceName: string }>)
      .map((s) => s.serviceName)
      .join(', ');

    const formattedTime = startTime.toLocaleString('en-GB', {
      weekday: 'short',
      day: 'numeric',
      month: 'short',
      hour: '2-digit',
      minute: '2-digit',
    });

    // Fetch shop owner's user_id so we can send them reminders too
    const { data: shop } = await supabase
      .from('shops')
      .select('user_id')
      .eq('id', shopId)
      .single();
    const shopOwnerId: string | null = shop?.user_id ?? null;

    // ── 1 & 2. In-app inbox entries (instant, no cron needed) ─────────────────
    const inAppRows: any[] = [
      {
        user_id: clientUserId,
        title: 'Booking Confirmed ✅',
        body: `Your ${serviceNames} appointment on ${formattedTime} is confirmed.`,
        data: { type: 'booking_confirmed', booking_id: booking.id, shop_id: shopId },
        is_read: false,
        created_at: now.toISOString(),
      },
    ];

    if (shopOwnerId) {
      inAppRows.push({
        user_id: shopOwnerId,
        title: 'New Booking',
        body: `New booking confirmed for ${serviceNames} on ${formattedTime}.`,
        data: { type: 'new_booking_shop', booking_id: booking.id, shop_id: shopId },
        is_read: false,
        created_at: now.toISOString(),
      });
    }

    const { error: inAppError } = await supabase
      .from('in_app_notifications')
      .insert(inAppRows);
    if (inAppError) console.error('⚠️ in_app_notifications insert failed:', inAppError);

    // ── 3 & 4. Scheduled notifications (push + reminders) ────────────────────
    const scheduledRows: any[] = [
      // Immediate push to client — cron picks this up within ~1 min and sends
      // via OneSignal even if the user is not in the app.
      {
        user_id: clientUserId,
        notification_type: 'immediate',
        booking_id: booking.id,
        shop_id: shopId,
        scheduled_for: now.toISOString(),
        status: 'pending',
        metadata: {
          title: 'Booking Confirmed ✅',
          body: `Your ${serviceNames} appointment on ${formattedTime} is confirmed.`,
          type: 'booking_confirmed',
          booking_id: booking.id,
        },
        created_at: now.toISOString(),
        updated_at: now.toISOString(),
      },
    ];

    // Client reminders — only schedule if the time is still in the future
    const clientReminders = [
      {
        type: 'booking_reminder_24h',
        offsetMs: -24 * 60 * 60 * 1000,
        title: 'Appointment Tomorrow',
        body: `Your ${serviceNames} appointment is tomorrow at ${formattedTime}.`,
      },
      {
        type: 'booking_reminder_1h',
        offsetMs: -60 * 60 * 1000,
        title: 'Appointment in 1 Hour',
        body: `Your ${serviceNames} appointment starts in 1 hour.`,
      },
      {
        type: 'booking_reminder_5min',
        offsetMs: -5 * 60 * 1000,
        title: 'Appointment Starting Soon',
        body: `Your ${serviceNames} appointment starts in 5 minutes!`,
      },
    ];

    for (const { type, offsetMs, title, body } of clientReminders) {
      const scheduledFor = new Date(startTime.getTime() + offsetMs);
      if (scheduledFor > now) {
        scheduledRows.push({
          user_id: clientUserId,
          notification_type: type,
          booking_id: booking.id,
          shop_id: shopId,
          scheduled_for: scheduledFor.toISOString(),
          status: 'pending',
          metadata: { title, body, booking_id: booking.id },
          created_at: now.toISOString(),
          updated_at: now.toISOString(),
        });
      }
    }

    // Review request 30 min after appointment ends
    const tReview = new Date(endTime.getTime() + 30 * 60 * 1000);
    if (tReview > now) {
      scheduledRows.push({
        user_id: clientUserId,
        notification_type: 'review_request',
        booking_id: booking.id,
        shop_id: shopId,
        scheduled_for: tReview.toISOString(),
        status: 'pending',
        metadata: {
          title: 'How was your appointment?',
          body: `Leave a review for your recent ${serviceNames} appointment.`,
          booking_id: booking.id,
          shop_id: shopId,
        },
        created_at: now.toISOString(),
        updated_at: now.toISOString(),
      });
    }

    // Shop owner reminder 15 min before
    if (shopOwnerId) {
      const t15min = new Date(startTime.getTime() - 15 * 60 * 1000);
      if (t15min > now) {
        scheduledRows.push({
          user_id: shopOwnerId,
          notification_type: 'shop_reminder_15min',
          booking_id: booking.id,
          shop_id: shopId,
          scheduled_for: t15min.toISOString(),
          status: 'pending',
          metadata: {
            title: 'Client Arriving Soon',
            body: `A client arrives in 15 minutes for ${serviceNames}.`,
            booking_id: booking.id,
          },
          created_at: now.toISOString(),
          updated_at: now.toISOString(),
        });
      }
    }

    const { error: schedError } = await supabase
      .from('scheduled_notifications')
      .insert(scheduledRows);
    if (schedError) console.error('⚠️ scheduled_notifications insert failed:', schedError);

    console.log(`📬 Scheduled ${scheduledRows.length} notifications for booking ${booking.id}`);
  } catch (err) {
    console.error('⚠️ scheduleBookingNotifications failed (non-fatal):', err);
  }
}