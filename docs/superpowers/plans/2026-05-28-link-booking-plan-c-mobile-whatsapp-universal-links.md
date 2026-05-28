# Public Link Booking — Plan C: Mobile + WhatsApp + Universal Links

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete v1 by adding the three remaining pieces: (1) shop/freelancer slug generation + "Shareable booking link" UI in the mobile app, (2) Meta WhatsApp Cloud API integration (send + webhook + worker dispatch), (3) Universal Links so installed-app users get deep-linked into the existing booking flow.

**Architecture:** No new architectural decisions — wires up the pieces designed in Plans A and B. Mobile additions touch only shop/freelancer settings + a new deep link handler. WhatsApp integration is two new edge functions + an extension to `process-scheduled-notifications`. Universal Links is two well-known files served from the Next.js app + iOS/Android manifest config.

**Tech Stack:** Flutter + Riverpod (existing patterns), Supabase edge functions (Deno), Meta WhatsApp Cloud API (Graph API v18), `go_router` for deep links.

**Prerequisites:** Plan A (Backend Foundation) and Plan B (Next.js Web App) are shipped. WhatsApp Business account is created with Meta and a phone number is registered.

**Reference design:** [docs/superpowers/specs/2026-05-28-public-link-booking-design.md](../specs/2026-05-28-public-link-booking-design.md)

---

## File Structure

**Create:**
- `supabase/functions/whatsapp-send/index.ts`
- `supabase/functions/whatsapp-send/index.test.ts`
- `supabase/functions/whatsapp-webhook/index.ts`
- `supabase/functions/_shared/whatsapp_client.ts`
- `aura-in-web/public/.well-known/apple-app-site-association` (JSON, no extension)
- `aura-in-web/public/.well-known/assetlinks.json`
- `lib/core/link/widgets/shareable_link_section.dart`
- `lib/app/routing/deep_link_handler.dart`

**Modify:**
- `supabase/functions/process-scheduled-notifications/index.ts` — WhatsApp channel branch
- `supabase/config.toml` — add `verify_jwt = false` for `whatsapp-webhook`
- `lib/core/notifications/domain/entities/scheduled_notification.dart` — add channel + template fields
- `lib/core/notifications/data/models/scheduled_notification_model.dart` — serialize new fields
- `lib/presentation/features/shops/.../shop_settings_screen.dart` — add Shareable Link section
- `lib/presentation/features/freelancer/.../freelancer_settings_screen.dart` — same
- `lib/app/routing/app_router.dart` — register `/book/:slug` route
- `ios/Runner/Info.plist` — Associated Domains
- `android/app/src/main/AndroidManifest.xml` — App Links intent filter
- Shop / freelancer save flows — call `LinkService.createShopLink` / `createWorkerLink` after save

---

## Task 1: NotificationService — add delivery_channel to entity + model

**Files:**
- Modify: `lib/core/notifications/domain/entities/scheduled_notification.dart`
- Modify: `lib/core/notifications/data/models/scheduled_notification_model.dart`
- Modify: tests touching these (if any)

**Why:** Plan A's migration added `delivery_channel`, `whatsapp_template`, `whatsapp_params` columns. Dart side needs to know about them so `process-scheduled-notifications` can use them.

---

- [ ] **Step 1: Add fields to the entity**

Modify `lib/core/notifications/domain/entities/scheduled_notification.dart`:

```dart
class ScheduledNotification {
  final String id;
  final String notificationType;
  final String? userId;
  final String? guestProfileId;          // NEW
  final DateTime scheduledFor;
  final NotificationStatus status;
  final Map<String, dynamic> metadata;
  final String deliveryChannel;          // NEW: 'push' | 'whatsapp'
  final String? whatsappTemplate;        // NEW
  final Map<String, dynamic>? whatsappParams; // NEW
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScheduledNotification({
    required this.id,
    required this.notificationType,
    this.userId,
    this.guestProfileId,
    required this.scheduledFor,
    required this.status,
    this.metadata = const {},
    this.deliveryChannel = 'push',
    this.whatsappTemplate,
    this.whatsappParams,
    required this.createdAt,
    required this.updatedAt,
  });
}
```

- [ ] **Step 2: Update the model serialization**

Modify `lib/core/notifications/data/models/scheduled_notification_model.dart`. Update `fromJson` and `toJson` to include the new fields:

```dart
factory ScheduledNotificationModel.fromJson(Map<String, dynamic> json) {
  return ScheduledNotificationModel(
    id: json['id'].toString(),
    notificationType: json['notification_type'].toString(),
    userId: json['user_id']?.toString(),
    guestProfileId: json['guest_profile_id']?.toString(),
    scheduledFor: DateTime.parse(json['scheduled_for'].toString()),
    status: NotificationStatusX.fromString(json['status']?.toString() ?? 'pending'),
    metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
    deliveryChannel: json['delivery_channel']?.toString() ?? 'push',
    whatsappTemplate: json['whatsapp_template']?.toString(),
    whatsappParams: json['whatsapp_params'] as Map<String, dynamic>?,
    createdAt: DateTime.parse(json['created_at'].toString()),
    updatedAt: DateTime.parse(json['updated_at'].toString()),
  );
}

Map<String, dynamic> toJson() {
  return {
    'id': id,
    'notification_type': notificationType,
    'user_id': userId,
    'guest_profile_id': guestProfileId,
    'scheduled_for': scheduledFor.toIso8601String(),
    'status': status.name,
    'metadata': metadata,
    'delivery_channel': deliveryChannel,
    'whatsapp_template': whatsappTemplate,
    'whatsapp_params': whatsappParams,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
```

- [ ] **Step 3: Run existing notification tests**

```bash
flutter test test/core/notifications/
```

Expected: all existing tests still pass. If a test breaks because it didn't expect the new fields, update it to pass `deliveryChannel: 'push'` and `whatsappTemplate: null` explicitly.

- [ ] **Step 4: Commit**

```bash
git add lib/core/notifications/
git commit -m "feat(notifications): add delivery_channel + whatsapp_template fields

ScheduledNotification entity + model gain delivery_channel ('push' or
'whatsapp'), whatsapp_template, whatsapp_params, and guest_profile_id.
Backward-compatible: existing code passes default 'push' and the
existing OneSignal flow is unchanged.

Used by the worker function in Task 4 to dispatch via Meta WhatsApp
Cloud API when delivery_channel='whatsapp'."
```

---

## Task 2: Shared WhatsApp client

**Files:**
- Create: `supabase/functions/_shared/whatsapp_client.ts`

**Why:** Both `whatsapp-send` and the worker function call Meta's Graph API. Single helper means one place to update the API version, one place to handle retries.

---

- [ ] **Step 1: Write the WhatsApp client helper**

Create `supabase/functions/_shared/whatsapp_client.ts`:

```typescript
// supabase/functions/_shared/whatsapp_client.ts
//
// Thin wrapper around Meta WhatsApp Cloud API v18. Sends template messages
// to a specific phone number, returns the message id or throws on failure.

const META_GRAPH_VERSION = "v18.0";

export interface SendTemplateInput {
  to: string;                                // E.164 phone, e.g. "+233201234567"
  templateName: string;                      // e.g. "booking_confirmation_v1"
  languageCode?: string;                     // default "en"
  bodyParams: string[];                      // ordered values for {{1}}, {{2}}, …
}

export interface SendTemplateResult {
  messageId: string;
}

export async function sendWhatsAppTemplate(
  input: SendTemplateInput,
): Promise<SendTemplateResult> {
  const phoneNumberId = Deno.env.get("WHATSAPP_PHONE_NUMBER_ID");
  const accessToken = Deno.env.get("WHATSAPP_ACCESS_TOKEN");
  if (!phoneNumberId || !accessToken) {
    throw new Error("WhatsApp env vars missing: WHATSAPP_PHONE_NUMBER_ID and WHATSAPP_ACCESS_TOKEN");
  }

  const url = `https://graph.facebook.com/${META_GRAPH_VERSION}/${phoneNumberId}/messages`;
  const body = {
    messaging_product: "whatsapp",
    to: input.to.replace(/^\+/, ""),
    type: "template",
    template: {
      name: input.templateName,
      language: { code: input.languageCode ?? "en" },
      components: input.bodyParams.length > 0
        ? [{
            type: "body",
            parameters: input.bodyParams.map(text => ({ type: "text", text })),
          }]
        : undefined,
    },
  };

  const res = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${accessToken}`,
    },
    body: JSON.stringify(body),
  });

  const responseBody = await res.json();

  if (!res.ok) {
    const code = responseBody?.error?.code;
    const errMsg = responseBody?.error?.message ?? "Unknown error";
    if (code === 132001 || /template.*not found/i.test(errMsg)) {
      throw new WhatsAppTemplateNotFoundError(`Template not found: ${input.templateName}`);
    }
    throw new Error(`Meta API ${res.status}: ${errMsg}`);
  }

  const messageId = responseBody?.messages?.[0]?.id;
  if (!messageId) {
    throw new Error("Meta API returned no message id");
  }
  return { messageId };
}

export class WhatsAppTemplateNotFoundError extends Error {
  constructor(msg: string) {
    super(msg);
    this.name = "WhatsAppTemplateNotFoundError";
  }
}

/**
 * Verify Meta webhook signature. Compares HMAC-SHA256 of raw body with
 * APP_SECRET against the X-Hub-Signature-256 header.
 */
export async function verifyMetaSignature(rawBody: string, header: string): Promise<boolean> {
  if (!header.startsWith("sha256=")) return false;
  const appSecret = Deno.env.get("WHATSAPP_APP_SECRET");
  if (!appSecret) throw new Error("WHATSAPP_APP_SECRET not set");

  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(appSecret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(rawBody));
  const computed = "sha256=" + Array.from(new Uint8Array(sig))
    .map(b => b.toString(16).padStart(2, "0"))
    .join("");
  return timingSafeEqual(computed, header);
}

function timingSafeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) {
    diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }
  return diff === 0;
}
```

- [ ] **Step 2: Set required env vars in Supabase**

```bash
supabase secrets set WHATSAPP_PHONE_NUMBER_ID=<from-meta-app-dashboard>
supabase secrets set WHATSAPP_ACCESS_TOKEN=<system-user-token>
supabase secrets set WHATSAPP_APP_SECRET=<from-meta-app-basic-settings>
supabase secrets set WHATSAPP_VERIFY_TOKEN=<random-string-you-make-up>
```

The verify token is used by the webhook handshake (Task 4). Pick any random string and remember it.

- [ ] **Step 3: Commit**

```bash
git add supabase/functions/_shared/whatsapp_client.ts
git commit -m "feat(whatsapp): shared client for Meta Cloud API

sendWhatsAppTemplate posts to graph.facebook.com/v18.0 with an access
token from env. WhatsAppTemplateNotFoundError exposed for callers that
need to handle the template_not_approved-yet case specially (deferred
retry instead of fatal).

verifyMetaSignature wraps the SHA-256 HMAC check used by the inbound
webhook to authenticate Meta-originated requests."
```

---

## Task 3: whatsapp-send edge function

**Files:**
- Create: `supabase/functions/whatsapp-send/index.ts`
- Create: `supabase/functions/whatsapp-send/index.test.ts`

**Why:** Internal (service-role) edge function called by `process-scheduled-notifications` and by the payment webhooks (for the immediate confirmation message). Wraps the shared client with input validation + structured error responses.

---

- [ ] **Step 1: Write the failing test**

Create `supabase/functions/whatsapp-send/index.test.ts`:

```typescript
import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";

Deno.test("whatsapp-send: requires service-role auth", async () => {
  // No auth header → 401
  const { handler } = await import("./index.ts");
  const req = new Request("https://x/whatsapp-send", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      to: "+233200000099",
      template: "test",
      params: {},
    }),
  });
  const res = await handler(req);
  assertEquals(res.status, 401);
});

Deno.test("whatsapp-send: rejects missing 'to'", async () => {
  const { handler } = await import("./index.ts");
  const req = new Request("https://x/whatsapp-send", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}`,
    },
    body: JSON.stringify({ template: "test", params: {} }),
  });
  const res = await handler(req);
  assertEquals(res.status, 400);
});
```

- [ ] **Step 2: Run tests (expect failure)**

```bash
deno test --allow-net --allow-env supabase/functions/whatsapp-send/index.test.ts
```

- [ ] **Step 3: Write the implementation**

Create `supabase/functions/whatsapp-send/index.ts`:

```typescript
// supabase/functions/whatsapp-send/index.ts
//
// Internal edge function (service-role auth required). Sends a single
// WhatsApp template message via Meta Cloud API. Caller is responsible for
// scheduling and tracking status — this function just does the send.

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { sendWhatsAppTemplate, WhatsAppTemplateNotFoundError } from "../_shared/whatsapp_client.ts";

export async function handler(req: Request): Promise<Response> {
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  // Require service-role.
  const auth = req.headers.get("Authorization") ?? "";
  const expectedToken = `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}`;
  if (auth !== expectedToken) {
    return json({ error: "Unauthorized" }, 401);
  }

  let body: { to?: string; template?: string; params?: Record<string, string>; languageCode?: string };
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }

  if (!body.to || !body.template) {
    return json({ error: "Missing 'to' or 'template'" }, 400);
  }

  // Convert params object {"1": "Kwame", "2": "Limit"} to ordered array.
  const params = body.params ?? {};
  const ordered = Object.keys(params)
    .sort((a, b) => parseInt(a) - parseInt(b))
    .map(k => params[k]);

  try {
    const result = await sendWhatsAppTemplate({
      to: body.to,
      templateName: body.template,
      languageCode: body.languageCode,
      bodyParams: ordered,
    });
    return json({ success: true, messageId: result.messageId }, 200);
  } catch (e) {
    if (e instanceof WhatsAppTemplateNotFoundError) {
      return json({ success: false, error: "template_not_found", message: e.message }, 202);
    }
    console.error("whatsapp-send error:", e);
    return json({ success: false, error: "send_failed", message: (e as Error).message }, 502);
  }
}

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

serve(handler);
```

- [ ] **Step 4: Run tests**

```bash
deno test --allow-net --allow-env supabase/functions/whatsapp-send/index.test.ts
```

Expected: 2 tests pass.

- [ ] **Step 5: Deploy and smoke-test**

```bash
supabase functions deploy whatsapp-send

# Test rejection without auth:
SUPA_URL="https://<project-ref>.supabase.co/functions/v1/whatsapp-send"
curl -s -o /dev/null -w "HTTP %{http_code}\n" -X POST "$SUPA_URL"
# Expected: 401

# Test real send (using your test WhatsApp phone):
curl -s -X POST "$SUPA_URL" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <service-role-key>" \
  -d '{
    "to":"+233<your-test-number>",
    "template":"hello_world",
    "params":{}
  }'
# Expected: { "success": true, "messageId": "wamid..." }
# (hello_world is a default Meta-provided template available immediately)
```

- [ ] **Step 6: Commit**

```bash
git add supabase/functions/whatsapp-send/
git commit -m "feat(whatsapp): whatsapp-send edge function

Internal (service-role only). Accepts { to, template, params } and POSTs
to Meta Cloud API via _shared/whatsapp_client. Returns:
- 200 success with messageId on send
- 202 with error='template_not_found' for not-yet-approved templates
  (caller should defer + retry)
- 502 for other Meta API failures
- 401 if auth missing/wrong, 400 on bad input

Used by paystack-webhook / stripe-webhook (immediate confirmation)
and by process-scheduled-notifications (delayed reminders)."
```

---

## Task 4: whatsapp-webhook edge function

**Files:**
- Create: `supabase/functions/whatsapp-webhook/index.ts`
- Modify: `supabase/config.toml` (add `[functions.whatsapp-webhook] verify_jwt = false`)

**Why:** Two purposes — (1) GET handshake during Meta webhook setup (Meta sends verify_token, we echo the challenge), (2) POST receives delivery receipts to update `scheduled_notifications.status='sent'` or `'failed'`. Inbound message handling is logged-only in v1 (foundation for Spec 4 agent).

---

- [ ] **Step 1: Add to config.toml**

```toml
[functions.whatsapp-webhook]
verify_jwt = false
```

- [ ] **Step 2: Write the webhook**

Create `supabase/functions/whatsapp-webhook/index.ts`:

```typescript
// supabase/functions/whatsapp-webhook/index.ts
//
// Public edge function (verify_jwt = false). Two paths:
// - GET: Meta webhook handshake. Validates ?hub.verify_token matches our
//        WHATSAPP_VERIFY_TOKEN env var and echoes hub.challenge.
// - POST: Meta delivery receipts + inbound messages. Signature-verified.
//
// Delivery receipts update scheduled_notifications.status. Inbound messages
// are logged for future inbound agent (Spec 4) but not processed in v1.

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";
import { verifyMetaSignature } from "../_shared/whatsapp_client.ts";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

serve(async (req) => {
  if (req.method === "GET") {
    return await handleHandshake(req);
  }
  if (req.method === "POST") {
    return await handleEvent(req);
  }
  return new Response("Method not allowed", { status: 405 });
});

async function handleHandshake(req: Request): Promise<Response> {
  const url = new URL(req.url);
  const mode = url.searchParams.get("hub.mode");
  const token = url.searchParams.get("hub.verify_token");
  const challenge = url.searchParams.get("hub.challenge");
  const expected = Deno.env.get("WHATSAPP_VERIFY_TOKEN");

  if (mode === "subscribe" && token === expected && challenge) {
    return new Response(challenge, { status: 200 });
  }
  return new Response("Forbidden", { status: 403 });
}

async function handleEvent(req: Request): Promise<Response> {
  const rawBody = await req.text();
  const signature = req.headers.get("X-Hub-Signature-256") ?? "";

  const isValid = await verifyMetaSignature(rawBody, signature);
  if (!isValid) {
    console.error("❌ Invalid Meta signature");
    return new Response("Forbidden", { status: 403 });
  }

  let event: any;
  try { event = JSON.parse(rawBody); }
  catch { return new Response("Invalid JSON", { status: 400 }); }

  for (const entry of event.entry ?? []) {
    for (const change of entry.changes ?? []) {
      const value = change.value;
      // Delivery / status updates
      for (const status of value.statuses ?? []) {
        await handleDeliveryStatus(status);
      }
      // Inbound messages (v1: log only, future Spec 4 will process)
      for (const msg of value.messages ?? []) {
        console.log("📩 Inbound WhatsApp:", JSON.stringify(msg));
      }
    }
  }

  return new Response(JSON.stringify({ received: true }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
}

async function handleDeliveryStatus(status: any): Promise<void> {
  // status.id is the wamid we returned from whatsapp-send. We stored it
  // in scheduled_notifications.metadata.message_id for matching.
  const messageId = status.id;
  const newStatus = status.status; // 'sent' | 'delivered' | 'read' | 'failed'

  if (!messageId) return;

  // Map Meta status → our status. We treat 'sent' as the success terminal
  // (we don't track read receipts for v1).
  const dbStatus = newStatus === "failed" ? "failed" : "sent";

  const { error } = await supabase
    .from("scheduled_notifications")
    .update({
      status: dbStatus,
      updated_at: new Date().toISOString(),
    })
    .eq("metadata->>message_id", messageId);

  if (error) {
    console.error("status update failed:", error);
  }
}
```

- [ ] **Step 3: Deploy and configure Meta webhook**

```bash
supabase functions deploy whatsapp-webhook
```

In Meta's App Dashboard → WhatsApp → Configuration:
- **Callback URL:** `https://<project-ref>.supabase.co/functions/v1/whatsapp-webhook`
- **Verify token:** the value of `WHATSAPP_VERIFY_TOKEN` you set in Task 2 Step 2
- Click "Verify and save" — should succeed (this triggers the GET handshake)
- Subscribe to: `messages` (for inbound, future use) and `message_status` (for delivery receipts)

- [ ] **Step 4: Verify a delivery receipt updates a notification**

Schedule a quick send via the whatsapp-send curl from Task 3 Step 5. Note the `messageId` returned. Then in SQL editor:

```sql
-- Insert a fake notification row that matches that message_id:
INSERT INTO scheduled_notifications (notification_type, scheduled_for, status, metadata, delivery_channel, created_at, updated_at)
VALUES ('test', now(), 'pending', jsonb_build_object('message_id', '<the-wamid-from-curl>'), 'whatsapp', now(), now());
```

Wait ~30 seconds for Meta to deliver the status callback. Then:

```sql
SELECT status FROM scheduled_notifications
WHERE metadata->>'message_id' = '<the-wamid-from-curl>';
-- Expected: 'sent' (or 'failed' if the number isn't on WhatsApp)
```

- [ ] **Step 5: Commit**

```bash
git add supabase/config.toml supabase/functions/whatsapp-webhook/
git commit -m "feat(whatsapp): inbound webhook for delivery receipts + handshake

GET: Meta handshake (verify_token check + echo challenge).
POST: signature-verified events. Delivery status updates update
scheduled_notifications.status by matching metadata.message_id.
Inbound messages logged but not processed (foundation for Spec 4
WhatsApp booking agent)."
```

---

## Task 5: process-scheduled-notifications WhatsApp branch

**Files:**
- Modify: `supabase/functions/process-scheduled-notifications/index.ts`

**Why:** The cron worker reads pending `scheduled_notifications`. Currently sends via OneSignal regardless of channel. After this task, it routes by `delivery_channel`.

---

- [ ] **Step 1: Find the dispatch loop**

```bash
grep -n "scheduled_notifications\|onesignal\|delivery_channel" supabase/functions/process-scheduled-notifications/index.ts | head -20
```

Note the function that processes a single notification (likely `processNotification(row)` or similar).

- [ ] **Step 2: Add the WhatsApp branch**

In the dispatcher, add:

```typescript
async function processNotification(row: ScheduledNotification): Promise<void> {
  if (row.delivery_channel === "whatsapp") {
    await dispatchWhatsApp(row);
    return;
  }
  // existing OneSignal path — unchanged
  await dispatchPush(row);
}

async function dispatchWhatsApp(row: ScheduledNotification): Promise<void> {
  const phone = row.metadata?.phone as string | undefined;
  const template = row.whatsapp_template;
  const params = row.whatsapp_params ?? {};

  if (!phone || !template) {
    await markFailed(row.id, "missing phone or template");
    return;
  }

  // Call whatsapp-send (service-role, internal).
  const url = `${Deno.env.get("SUPABASE_URL")}/functions/v1/whatsapp-send`;
  const res = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}`,
    },
    body: JSON.stringify({ to: phone, template, params }),
  });

  const body = await res.json();

  if (res.status === 202 && body.error === "template_not_found") {
    // Defer 6h and retry (template approval in progress).
    await deferNotification(row.id, 6 * 60 * 60 * 1000);
    return;
  }

  if (!res.ok || !body.success) {
    await incrementRetryOrFail(row.id, body.message ?? "send failed");
    return;
  }

  // Success — record the message_id so the webhook can match the delivery receipt.
  await supabase
    .from("scheduled_notifications")
    .update({
      status: "sent",
      metadata: { ...row.metadata, message_id: body.messageId },
      updated_at: new Date().toISOString(),
    })
    .eq("id", row.id);
}

async function markFailed(id: string, reason: string): Promise<void> {
  await supabase
    .from("scheduled_notifications")
    .update({
      status: "failed",
      metadata: { error: reason },
      updated_at: new Date().toISOString(),
    })
    .eq("id", id);
}

async function deferNotification(id: string, deferMs: number): Promise<void> {
  await supabase
    .from("scheduled_notifications")
    .update({
      scheduled_for: new Date(Date.now() + deferMs).toISOString(),
      status: "pending",
      updated_at: new Date().toISOString(),
    })
    .eq("id", id);
}

async function incrementRetryOrFail(id: string, reason: string): Promise<void> {
  const { data: row } = await supabase
    .from("scheduled_notifications")
    .select("metadata")
    .eq("id", id)
    .single();

  const retryCount = ((row?.metadata as any)?.retry_count ?? 0) + 1;
  if (retryCount >= 3) {
    await markFailed(id, `${reason} (after ${retryCount} attempts)`);
    return;
  }

  // Exponential backoff: 30s, 5min, 30min.
  const backoffMs = [30_000, 5 * 60_000, 30 * 60_000][retryCount - 1] ?? 30 * 60_000;
  await supabase
    .from("scheduled_notifications")
    .update({
      scheduled_for: new Date(Date.now() + backoffMs).toISOString(),
      status: "pending",
      metadata: { ...(row?.metadata ?? {}), retry_count: retryCount, last_error: reason },
      updated_at: new Date().toISOString(),
    })
    .eq("id", id);
}
```

- [ ] **Step 3: Deploy + verify a real reminder fires**

```bash
supabase functions deploy process-scheduled-notifications
```

Manually invoke (Supabase Dashboard → Edge Functions → Invoke), or wait for the next cron tick. Then create a test scheduled notification:

```sql
INSERT INTO scheduled_notifications (
  notification_type, scheduled_for, status, delivery_channel,
  whatsapp_template, whatsapp_params, metadata,
  created_at, updated_at
) VALUES (
  'test_whatsapp', now() - interval '1 minute', 'pending', 'whatsapp',
  'hello_world', '{}'::jsonb,
  jsonb_build_object('phone', '+233<your-test-number>'),
  now(), now()
);
```

Wait for cron tick. Verify:

```sql
SELECT status, metadata->>'message_id' AS msg_id FROM scheduled_notifications
WHERE notification_type = 'test_whatsapp'
ORDER BY created_at DESC LIMIT 1;
-- Expected: status='sent', msg_id is a wamid
```

- [ ] **Step 4: Commit**

```bash
git add supabase/functions/process-scheduled-notifications/index.ts
git commit -m "feat(notifications): WhatsApp branch in scheduler worker

When scheduled_notifications.delivery_channel='whatsapp', the worker
calls whatsapp-send (internal). Persists the returned message_id into
metadata for delivery-receipt matching in whatsapp-webhook.

Handles 3 failure modes:
- template_not_found (202): defer 6h, retry (template approval pending)
- transient error: exponential backoff (30s, 5min, 30min), max 3 attempts
- permanent error: mark failed after 3 retries

OneSignal path unchanged."
```

---

## Task 6: Mobile shop slug generation + Shareable Link section

**Files:**
- Create: `lib/core/link/widgets/shareable_link_section.dart`
- Modify: shop save flow (find the screen / controller that creates a shop)
- Modify: freelancer save flow
- Modify: shop settings screen (insert ShareableLinkSection)
- Modify: freelancer settings screen (insert ShareableLinkSection)

**Why:** The owner needs to see, copy, and share the link from the app. Slug generation happens on first shop save; the section shows the URL afterwards.

---

- [ ] **Step 1: Write ShareableLinkSection widget**

Create `lib/core/link/widgets/shareable_link_section.dart`:

```dart
// lib/core/link/widgets/shareable_link_section.dart
//
// Reusable widget for shops and freelancers. Shows the public booking link,
// copy + share buttons, and an "Edit slug" affordance.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nano_embryo/core/link/config/aurain_link_config.dart';

class ShareableLinkSection extends ConsumerWidget {
  final String? currentSlug;
  final String entityName; // e.g. "Limit Barbershop"
  final Future<void> Function(String newSlug) onEditSlug;

  const ShareableLinkSection({
    super.key,
    required this.currentSlug,
    required this.entityName,
    required this.onEditSlug,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = AuraInLinkConfig.getConfig();

    if (currentSlug == null) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: const Icon(Icons.link),
          title: const Text('Shareable booking link'),
          subtitle: const Text('Link will appear after your profile is saved.'),
        ),
      );
    }

    final url = 'https://${config.baseDomain}/book/$currentSlug';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shareable booking link',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Share this on WhatsApp or Instagram to let clients book without the app.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                url,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy'),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: url));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link copied')),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('Share'),
                    onPressed: () => Share.share(
                      'Book your appointment at $entityName: $url',
                      subject: 'Book at $entityName',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _showEditSlugDialog(context),
              child: const Text('Edit slug'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditSlugDialog(BuildContext context) async {
    final ctrl = TextEditingController(text: currentSlug);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit booking link slug'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            prefixText: 'aura-in-web.vercel.app/book/',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && result != currentSlug) {
      try {
        await onEditSlug(result);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Slug updated')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not update slug: $e')),
          );
        }
      }
    }
  }
}
```

- [ ] **Step 2: Add share_plus to pubspec.yaml**

```yaml
# pubspec.yaml
dependencies:
  # ... existing deps ...
  share_plus: ^10.0.0
```

```bash
flutter pub get
```

- [ ] **Step 3: Generate slug on shop save (find the shop save handler)**

```bash
grep -rn "shops.*insert\|saveShop\|createShop" lib/presentation/features/shops/ 2>/dev/null | head -5
```

In the shop creation function (likely a Riverpod notifier or repository method), after the shop is successfully inserted, generate the slug:

```dart
// After the shop is saved and has an id:
final linkService = ref.read(linkServiceProvider);
final slug = _slugify(savedShop.name);
final result = await linkService.createShopLink(
  shopId: savedShop.id,
  customSlug: slug,
);
// If collision, retry with -2, -3 (LinkService should handle suffix internally
// per result.suggestedSlug; otherwise loop here):
if (!result.success && result.suggestedSlug != null) {
  await linkService.createShopLink(
    shopId: savedShop.id,
    customSlug: result.suggestedSlug,
  );
}

String _slugify(String name) {
  return name
    .toLowerCase()
    .replaceAll(RegExp(r"[^a-z0-9]+"), "-")
    .replaceAll(RegExp(r"^-+|-+$"), "")
    .substring(0, name.length.clamp(0, 50));
}
```

- [ ] **Step 4: Do the same in freelancer save flow**

```bash
grep -rn "freelancers.*insert\|saveFreelancer\|createFreelancer" lib/presentation/features/freelancer/ 2>/dev/null | head -5
```

Apply the same pattern but call `linkService.createWorkerLink(workerId: savedFreelancer.id, ...)`.

- [ ] **Step 5: Insert ShareableLinkSection into shop settings**

Find the shop settings screen and insert the section near the top (or under shop info):

```dart
ShareableLinkSection(
  currentSlug: shop.bookingSlug,
  entityName: shop.name,
  onEditSlug: (newSlug) async {
    final linkService = ref.read(linkServiceProvider);
    final result = await linkService.createShopLink(
      shopId: shop.id,
      customSlug: newSlug,
    );
    if (!result.success) {
      throw Exception(result.error ?? 'Slug unavailable');
    }
    // Refresh shop data so booking_slug updates in UI
    ref.invalidate(shopByIdProvider(shop.id));
  },
),
```

- [ ] **Step 6: Same for freelancer settings**

Same widget, same pattern, call `createWorkerLink`.

- [ ] **Step 7: Smoke-test in the iOS simulator**

```bash
flutter run
```

- Create a new shop. After save, open shop settings. Verify the URL shows.
- Copy → paste somewhere; verify it matches.
- Share → system share sheet should open.
- Edit slug → enter a new one, save, verify URL updates.
- Open the URL in a browser; verify Plan B's /book/<slug> renders the right shop.

- [ ] **Step 8: Commit**

```bash
git add lib/core/link/widgets/ \
        lib/presentation/features/shops/ \
        lib/presentation/features/freelancer/ \
        pubspec.yaml pubspec.lock
git commit -m "feat(link-booking): mobile slug generation + ShareableLinkSection

ShareableLinkSection widget: shows URL, copy + share via share_plus,
edit-slug dialog with LinkService validation.

Slug auto-generated on shop / freelancer save (slugify(name)) and
inserted via LinkService.createShopLink / createWorkerLink. Collision
handled via LinkService.suggestedSlug (e.g., adds -2 suffix).

Section embedded in shop_settings_screen and freelancer_settings_screen."
```

---

## Task 7: Universal Links — server-side files + mobile config

**Files:**
- Create: `aura-in-web/public/.well-known/apple-app-site-association` (JSON, no extension)
- Create: `aura-in-web/public/.well-known/assetlinks.json`
- Modify: `ios/Runner/Info.plist`
- Modify: `android/app/src/main/AndroidManifest.xml`

---

- [ ] **Step 1: Find your iOS team ID and bundle ID**

In Xcode → select Runner → Signing & Capabilities. Note:
- **Team ID** (10-character alphanumeric)
- **Bundle ID** (e.g., `com.aurain.app`)

- [ ] **Step 2: Find your Android package name + SHA-256 fingerprint**

```bash
# From the android/ directory:
cd android
./gradlew signingReport
```

Note:
- **Package name** (e.g., `com.aurain.app`)
- **SHA-256** for the release keystore (a long hex string with colons)

- [ ] **Step 3: Write the Apple AASA**

Create `aura-in-web/public/.well-known/apple-app-site-association` (no `.json` extension!):

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "<TEAM_ID>.<BUNDLE_ID>",
        "paths": [ "/book/*" ]
      }
    ]
  }
}
```

- [ ] **Step 4: Write the Android assetlinks.json**

Create `aura-in-web/public/.well-known/assetlinks.json`:

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "<ANDROID_PACKAGE_NAME>",
      "sha256_cert_fingerprints": ["<SHA256_FINGERPRINT>"]
    }
  }
]
```

- [ ] **Step 5: Configure Next.js to serve AASA with correct content-type**

Modify `aura-in-web/next.config.mjs`:

```javascript
const nextConfig = {
  async headers() {
    return [
      {
        source: "/.well-known/apple-app-site-association",
        headers: [
          { key: "Content-Type", value: "application/json" },
        ],
      },
      {
        source: "/.well-known/assetlinks.json",
        headers: [
          { key: "Content-Type", value: "application/json" },
        ],
      },
    ];
  },
};
export default nextConfig;
```

- [ ] **Step 6: Add Associated Domains to iOS Info.plist**

Modify `ios/Runner/Info.plist`. Add inside the top-level `<dict>`:

```xml
<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:aura-in-web.vercel.app</string>
</array>
```

Also enable the capability in Xcode → Runner → Signing & Capabilities → "+ Capability" → Associated Domains → add `applinks:aura-in-web.vercel.app`.

- [ ] **Step 7: Add App Links intent filter to AndroidManifest.xml**

Modify `android/app/src/main/AndroidManifest.xml`. Inside the main `<activity android:name=".MainActivity">`, add an intent filter:

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="https"
        android:host="aura-in-web.vercel.app"
        android:pathPrefix="/book/" />
</intent-filter>
```

- [ ] **Step 8: Deploy aura-in-web with the new files**

```bash
cd aura-in-web
npx vercel deploy --prod
```

Verify both files are reachable:

```bash
curl -s https://aura-in-web.vercel.app/.well-known/apple-app-site-association | head -c 200
# Expected: the JSON content + Content-Type: application/json header
curl -sI https://aura-in-web.vercel.app/.well-known/apple-app-site-association | grep -i content-type
# Expected: application/json

curl -s https://aura-in-web.vercel.app/.well-known/assetlinks.json | head -c 200
```

- [ ] **Step 9: Validate AASA with Apple's tool**

Open https://branch.io/resources/aasa-validator/ (or similar) and check `aura-in-web.vercel.app`. Should report "AASA file is valid."

For Android, the validation happens automatically the next time the app installs and `autoVerify` runs. You can manually verify with `adb shell pm get-app-links com.aurain.app`.

- [ ] **Step 10: Commit (no mobile code changes yet — those come in Task 8)**

```bash
git add aura-in-web/public/.well-known/ \
        aura-in-web/next.config.mjs \
        ios/Runner/Info.plist \
        android/app/src/main/AndroidManifest.xml
git commit -m "feat(link-booking): Universal Links setup

aura-in-web/public/.well-known/apple-app-site-association (iOS) and
assetlinks.json (Android) served with Content-Type: application/json.
ios/Runner/Info.plist gains Associated Domains. AndroidManifest gains
the App Links intent filter for https://aura-in-web.vercel.app/book/*.

Mobile-side deep link handler added in Task 8."
```

---

## Task 8: Mobile deep link handler

**Files:**
- Modify: `lib/app/routing/app_router.dart`

**Why:** When iOS/Android intercepts the Universal Link, the app launches and Flutter needs to route to the existing booking flow with the resolved shop/freelancer.

---

- [ ] **Step 1: Find the existing app_router**

```bash
grep -n "GoRoute\|GoRouter" lib/app/routing/app_router.dart | head -10
```

Note the existing routing patterns.

- [ ] **Step 2: Add the /book/:slug route**

Modify `lib/app/routing/app_router.dart`. Add a new GoRoute that resolves the slug then navigates to the existing booking screen:

```dart
GoRoute(
  path: '/book/:slug',
  redirect: (context, state) async {
    final slug = state.pathParameters['slug'];
    if (slug == null) return null;

    // Resolve slug via LinkService.
    final container = ProviderScope.containerOf(context);
    final linkService = container.read(linkServiceProvider);
    final resolved = await linkService.resolveSlug(slug);

    if (resolved == null) return '/';

    if (resolved.type == LinkType.shop) {
      return '/shops/${resolved.targetId}?fromLink=true';
    }
    if (resolved.type == LinkType.freelancer || resolved.type == LinkType.worker) {
      return '/freelancers/${resolved.targetId}?fromLink=true';
    }
    return '/';
  },
),
```

Note: `linkService.resolveSlug(slug)` may not exist yet in your LinkService — verify and add a `resolveSlug` method if missing. It should query `short_links` by slug + appId + is_active and return the row (or null).

- [ ] **Step 3: Smoke-test with iOS simulator**

Build and run on a real iOS device (Universal Links don't work in the simulator). After install, share the URL `https://aura-in-web.vercel.app/book/<real-slug>` to yourself via WhatsApp or Notes. Tap the link.

Expected: the Aura-In app opens directly at the booking screen for that shop, **not** the browser.

If it opens the browser instead, check:
- iOS Settings → Aura-In → Associated Domains is enabled
- AASA file is reachable and valid
- TestFlight / re-install may be needed to re-trigger Universal Links registration

- [ ] **Step 4: Same test on Android**

Install a debug APK. Tap the link from WhatsApp. Should open Aura-In directly.

If Android shows a chooser instead, run:

```bash
adb shell pm verify-app-links --re-verify com.aurain.app
adb shell pm get-app-links com.aurain.app
# Verify status is "verified"
```

- [ ] **Step 5: Commit**

```bash
git add lib/app/routing/app_router.dart \
        lib/core/link/service/link_service.dart   # if resolveSlug added
git commit -m "feat(link-booking): deep link handler for /book/:slug

GoRoute intercepts Universal Links opened from WhatsApp/IG/etc.
Resolves slug via LinkService.resolveSlug, redirects to the existing
shop or freelancer booking screen with ?fromLink=true. Web flow remains
the fallback for users without the app installed."
```

---

## Verification (after Task 8 — v1 complete)

End-to-end test as a fresh guest:

1. **Shop owner setup** — Create a new shop on a device with the app. Verify the URL appears in shop settings.
2. **Share the link via WhatsApp** to a phone *without* Aura-In installed.
3. **Open in browser** — page loads in <3s on cellular.
4. **Pick service + worker + slot** — UI works.
5. **Enter name + phone** — name field stays empty for first-time guest.
6. **Pay deposit** — redirected to Paystack, complete payment.
7. **Land on success page** — within 10s shows "Booking confirmed".
8. **WhatsApp confirmation arrives** within ~5s.
9. **Booking appears on shop owner's app** via Realtime + OneSignal push.
10. **Re-open the link on the same phone** — phone field prefills name after 500ms.
11. **Install Aura-In on the same phone**, re-tap the link from WhatsApp — should open the app directly into the booking flow (not the browser).
12. **Schedule a test reminder** — wait for it to fire, verify WhatsApp arrives.

All 12 must pass for v1 to be ready to ship to real shops.

### Templates submission

Submit these to Meta WhatsApp Business Manager → Templates BEFORE v1 launch:

```
booking_confirmation_v1 (utility, English)
  "Hi {{1}}, your booking at {{2}} is confirmed for {{3}}. Address: {{4}}.
   Deposit paid: {{5}}. Remaining: {{6}} (pay after service)."

booking_reminder_24h_v1 (utility, English)
  "Reminder: your booking at {{1}} is tomorrow at {{2}}. {{3}}"

booking_reminder_2h_v1 (utility, English)
  "Heads up: your appointment at {{1}} is in 2 hours, at {{2}}. {{3}}"

booking_review_prompt_v1 (utility, English)
  "How was your visit to {{1}}? Tap to rate: {{2}}"
```

If templates aren't approved by v1 launch day, the worker function's `template_not_found` deferral will keep retrying every 6h until approved — messages will fire automatically without code changes.

Plan C is shippable when all 12 verification steps pass and the four templates are approved (or queued and the deferral path is verified working with `hello_world` template). At that point, v1 of the public link booking flow is complete.
