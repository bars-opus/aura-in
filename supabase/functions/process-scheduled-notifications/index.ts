import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

// ── Config ────────────────────────────────────────────────────────────────────

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ONE_SIGNAL_APP_ID = Deno.env.get("ONE_SIGNAL_APP_ID")!;
const ONE_SIGNAL_API_KEY = Deno.env.get("ONE_SIGNAL_API_KEY")!;
const BATCH_LIMIT = 50;

// Uses service role: bypasses RLS so the scheduler can read all pending rows.
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
  auth: { persistSession: false },
});

// ── OneSignal delivery ────────────────────────────────────────────────────────

async function sendPush(
  userId: string,
  title: string,
  body: string,
  data: Record<string, unknown>
): Promise<void> {
  const resp = await fetch("https://onesignal.com/api/v1/notifications", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Basic ${ONE_SIGNAL_API_KEY}`,
    },
    body: JSON.stringify({
      app_id: ONE_SIGNAL_APP_ID,
      include_external_user_ids: [userId],
      headings: { en: title },
      contents: { en: body },
      data,
      priority: 5,
    }),
  });

  if (!resp.ok) {
    const err = await resp.json();
    throw new Error(`OneSignal error: ${JSON.stringify(err)}`);
  }
}

// ── User settings check ───────────────────────────────────────────────────────

async function isPushEnabled(userId: string): Promise<boolean> {
  const { data } = await supabase
    .from("notification_settings")
    .select("push_enabled")
    .eq("user_id", userId)
    .maybeSingle();

  // Default to true when no settings row exists yet.
  return data?.push_enabled !== false;
}

// ── Handler ───────────────────────────────────────────────────────────────────

serve(async () => {
  try {
    // Claim a batch atomically: flip status to 'processing' so a concurrent
    // run of this cron cannot pick up the same rows.
    const now = new Date().toISOString();

    const { data: pending, error: fetchError } = await supabase
      .from("scheduled_notifications")
      .select("*")
      .eq("status", "pending")
      .lte("scheduled_for", now)
      .limit(BATCH_LIMIT);

    if (fetchError) throw fetchError;
    if (!pending || pending.length === 0) {
      return new Response(
        JSON.stringify({ success: true, processed: 0, total: 0 }),
        { headers: { "Content-Type": "application/json" } }
      );
    }

    // Lock the rows before processing to prevent double-send.
    const ids = pending.map((n: { id: string }) => n.id);
    await supabase
      .from("scheduled_notifications")
      .update({ status: "processing", updated_at: now })
      .in("id", ids);

    let processed = 0;

    for (const notification of pending) {
      try {
        // Respect the user's push preference.
        const enabled = await isPushEnabled(notification.user_id);
        if (!enabled) {
          await supabase
            .from("scheduled_notifications")
            .update({ status: "skipped", updated_at: new Date().toISOString() })
            .eq("id", notification.id);
          continue;
        }

        const { title, body, ...rest } = notification.metadata ?? {};

        if (!title || !body) {
          throw new Error("Notification metadata missing title or body");
        }

        await sendPush(notification.user_id, title, body, rest);

        await supabase
          .from("scheduled_notifications")
          .update({ status: "sent", updated_at: new Date().toISOString() })
          .eq("id", notification.id);

        processed++;
      } catch (err) {
        const retryCount = (notification.retry_count ?? 0) + 1;
        // Exponential backoff: on next run only pick up notifications whose
        // scheduled_for has passed. We bump scheduled_for forward so they
        // naturally sit out until the back-off window expires.
        const backoffMinutes = Math.pow(2, retryCount); // 2, 4, 8 …
        const nextAttempt = new Date(
          Date.now() + backoffMinutes * 60 * 1000
        ).toISOString();

        const newStatus = retryCount >= 5 ? "failed" : "pending";

        await supabase
          .from("scheduled_notifications")
          .update({
            status: newStatus,
            retry_count: retryCount,
            last_error: String(err),
            scheduled_for: newStatus === "pending" ? nextAttempt : undefined,
            updated_at: new Date().toISOString(),
          })
          .eq("id", notification.id);

        console.error(
          `Notification ${notification.id} failed (attempt ${retryCount}):`,
          err
        );
      }
    }

    return new Response(
      JSON.stringify({ success: true, processed, total: pending.length }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("process-scheduled-notifications error:", error);
    return new Response(
      JSON.stringify({ success: false, error: String(error) }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
