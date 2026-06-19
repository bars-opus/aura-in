// Checks a submitted code against Twilio Verify. On approval, persists the
// verified phone to the CALLER's profile via service role. The user id is
// derived from the JWT — never trusted from the request body.
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { checkVerification, TwilioConfigError } from "../_shared/twilio_client.ts";

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
  const userJwt = auth.slice("Bearer ".length);

  const url = Deno.env.get("SUPABASE_URL")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
  const serviceRole = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  // Resolve the caller's user id from their JWT using the anon key.
  const userClient = createClient(url, anonKey, {


  // Resolve the caller's user id from their JWT.
  const userClient = createClient(url, serviceRole, {
    global: { headers: { Authorization: `Bearer ${userJwt}` } },
  });
  const { data: userData, error: userErr } = await userClient.auth.getUser();
  if (userErr || !userData.user) return json({ error: "Unauthorized" }, 401);
  const userId = userData.user.id;

  let body: { phone_e164?: string; code?: string };
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }
  const phone = body.phone_e164?.trim() ?? "";
  const code = body.code?.trim() ?? "";
  if (!E164.test(phone)) return json({ error: "Invalid phone number" }, 400);
  if (!/^\d{4,10}$/.test(code)) return json({ error: "Invalid code" }, 400);

  let status: string;
  try {
    ({ status } = await checkVerification(phone, code));
  } catch (e) {
    if (e instanceof TwilioConfigError) return json({ error: "Service unavailable" }, 503);
    return json({ error: "Verification failed" }, 502);
  }

  if (status !== "approved") return json({ verified: false }, 200);

  // Persist via service role (bypasses the client write-guard trigger).
  const admin = createClient(url, serviceRole);
  const { data: updRows, error: updErr } = await admin
    .from("profiles")
    .update({ phone_e164: phone, phone_verified_at: new Date().toISOString() })
    .eq("id", userId)
    .select("id");
  if (updErr) return json({ error: "Could not save verification" }, 500);
  if (!updRows || updRows.length !== 1) return json({ error: "Could not save verification" }, 500);

    .from("profiles")
    .update({ phone_e164: phone, phone_verified_at: new Date().toISOString() })
    .eq("id", userId);
  if (updErr) return json({ error: "Could not save verification" }, 500);

  return json({ verified: true }, 200);
}

serve(handler);
