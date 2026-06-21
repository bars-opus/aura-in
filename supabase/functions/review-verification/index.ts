// supabase/functions/review-verification/index.ts
// Admin approves/rejects an entity's verification. Auth: admin JWT
// (membership in app_admins). Service role used only for the privileged write.
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

  const admin = createClient(url, serviceRole);

  // Authorize: caller must be an admin.
  const { data: adminRow, error: adminErr } = await admin
    .from("app_admins").select("user_id").eq("user_id", userId).maybeSingle();
  if (adminErr) return json({ error: "Auth check failed" }, 500);
  if (!adminRow) return json({ error: "Forbidden" }, 403);

  let body: {
    entity_type?: string; entity_id?: string;
    decision?: string; rejection_reason?: string;
  };
  try { body = await req.json(); } catch { return json({ error: "Invalid JSON" }, 400); }

  const table = TABLES[body.entity_type ?? ""];
  const entityId = (body.entity_id ?? "").trim();
  const decision = body.decision ?? "";
  const reason = (body.rejection_reason ?? "").trim();
  if (!table || !entityId) return json({ error: "Invalid input" }, 400);
  if (decision !== "approved" && decision !== "rejected") {
    return json({ error: "Invalid decision" }, 400);
  }
  if (decision === "rejected" && reason.length === 0) {
    return json({ error: "Rejection reason required" }, 400);
  }

  const patch: Record<string, unknown> = {
    verification_status: decision,
    verification_reviewed_by: userId,
    verification_reviewed_at: new Date().toISOString(),
    verification_rejection_reason: decision === "rejected" ? reason : null,
  };
  if (table === "shops") patch.verified = decision === "approved";

  const { data: rows, error: updErr } = await admin
    .from(table).update(patch).eq("id", entityId).select("id");
  if (updErr || !rows || rows.length !== 1) {
    return json({ error: "Could not record decision" }, 500);
  }
  return json({ ok: true, status: decision }, 200);
}

serve(handler);
