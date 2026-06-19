// supabase/functions/phone-verify-start/index.ts
// Starts a Twilio Verify SMS verification for the calling user's phone.
// Auth: end-user JWT (the platform verifies the Supabase-signed JWT).
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { startVerification, TwilioConfigError } from "../_shared/twilio_client.ts";

const E164 = /^\+[1-9]\d{6,14}$/;

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

export async function handler(req: Request): Promise<Response> {
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const auth = req.headers.get("Authorization") ?? "";
  if (!auth.startsWith("Bearer ")) return json({ error: "Unauthorized" }, 401);

  let body: { phone_e164?: string };
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }

  const phone = body.phone_e164?.trim() ?? "";
  if (!E164.test(phone)) return json({ error: "Invalid phone number" }, 400);

  try {
    await startVerification(phone);
    return json({ success: true }, 200);
  } catch (e) {
    if (e instanceof TwilioConfigError) return json({ error: "Service unavailable" }, 503);
    return json({ error: "Failed to send code" }, 502);
  }
}

serve(handler);
