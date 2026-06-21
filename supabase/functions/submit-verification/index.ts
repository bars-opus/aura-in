// supabase/functions/submit-verification/index.ts
// Producer (re)submits an entity for verification. Auth: owner JWT.
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status, headers: { "Content-Type": "application/json" },
  });
}

const TABLES: Record<string, string> = { shop: "shops", worker: "workers" };

export async function handler(req: Request): Promise<Response> {
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);
  const auth = req.headers.get("Authorization") ?? "";
  if (!auth.startsWith("Bearer ")) return json({ error: "Unauthorized" }, 401);
  const userJwt = auth.slice("Bearer ".length);

  const url = Deno.env.get("SUPABASE_URL")!;
  const serviceRole = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;

  const userClient = createClient(url, anonKey, {
    global: { headers: { Authorization: `Bearer ${userJwt}` } },
  });
  const { data: userData, error: userErr } = await userClient.auth.getUser();
  if (userErr || !userData.user) return json({ error: "Unauthorized" }, 401);
  const userId = userData.user.id;

  let body: { entity_type?: string; entity_id?: string };
  try { body = await req.json(); } catch { return json({ error: "Invalid JSON" }, 400); }
  const table = TABLES[body.entity_type ?? ""];
  const entityId = (body.entity_id ?? "").trim();
  if (!table || !entityId) return json({ error: "Invalid input" }, 400);

  const admin = createClient(url, serviceRole);
  // Ownership check via service role (entity may be hidden from the user by RLS).
  const { data: owned, error: ownErr } = await admin
    .from(table).select("user_id").eq("id", entityId).maybeSingle();
  if (ownErr) return json({ error: "Lookup failed" }, 500);
  if (!owned || owned.user_id !== userId) return json({ error: "Forbidden" }, 403);

  const { data: rows, error: updErr } = await admin
    .from(table)
    .update({
      verification_status: "pending",
      verification_submitted_at: new Date().toISOString(),
      verification_rejection_reason: null,
    })
    .eq("id", entityId)
    .select("id");
  if (updErr || !rows || rows.length !== 1) {
    return json({ error: "Could not submit" }, 500);
  }
  return json({ ok: true, status: "pending" }, 200);
}

serve(handler);
