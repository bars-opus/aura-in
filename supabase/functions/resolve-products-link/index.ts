// supabase/functions/resolve-products-link/index.ts
//
// Public edge function (verify_jwt = false). Mirrors resolve-link but for
// the shop_products link type — resolves a slug to the shop's product
// grid for the /m/[slug] web page.
//
// Reuses the SECURITY DEFINER RPC get_shop_products_by_slug so all
// joins + ordering + caps stay server-side; this function is mostly a
// rate-limit + CORS + logging wrapper.
//
// Checklist alignment:
//   * 1.5  — verify_jwt=false documented in supabase/config.toml.
//   * 2.1  — slug length/charset bounded by RPC.
//   * 3.4  — Cache-Control: 30s for the grid (matches resolve-link).
//   * 3.7+3.8 — 60/min/IP rate limit via shared helper.
//   * 4.4  — only the redactError sanitizer touches console.error.
//   * 7.5  — TLS terminated upstream by Supabase.
//   * 7.6  — origin-restricted CORS via shared helper.

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";
import { buildCorsHeaders } from "../_shared/cors.ts";
import { checkRateLimit } from "../_shared/rate_limit.ts";
import { redactError } from "../_shared/sanitize.ts";

let _supabase: SupabaseClient | null = null;
function getSupabase(): SupabaseClient {
  if (_supabase) return _supabase;
  _supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );
  return _supabase;
}

export async function handler(req: Request): Promise<Response> {
  const cors = buildCorsHeaders(req, "GET, OPTIONS");
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: cors });
  }
  if (req.method !== "GET") {
    return jsonResponse(cors, { error: "Method not allowed" }, 405);
  }

  const url = new URL(req.url);
  const slug = url.searchParams.get("slug");
  if (!slug || slug.trim().length === 0) {
    return jsonResponse(cors, { error: "Missing slug" }, 400);
  }
  if (slug.length > 80) {
    return jsonResponse(cors, { error: "Invalid slug" }, 400);
  }

  const supabase = getSupabase();

  const rl = await checkRateLimit(supabase, "resolve-products-link", req, {
    max: 60,
    windowSeconds: 60,
  });
  if (!rl.allowed) {
    return jsonResponse(
      cors,
      { error: "Too many requests" },
      429,
      { "Retry-After": String(rl.retryAfterSeconds) },
    );
  }

  try {
    const { data, error } = await supabase.rpc("get_shop_products_by_slug", {
      p_slug: slug,
    });
    if (error) {
      console.error("resolve-products-link RPC error:", redactError(error));
      return jsonResponse(cors, { error: "Internal error" }, 500);
    }
    if (data == null) {
      return jsonResponse(cors, { error: "Slug not found" }, 404);
    }
    return jsonResponse(
      cors,
      data,
      200,
      { "Cache-Control": "public, max-age=30, s-maxage=30" },
    );
  } catch (e) {
    console.error("resolve-products-link threw:", redactError(e));
    return jsonResponse(cors, { error: "Internal error" }, 500);
  }
}

function jsonResponse(
  cors: Record<string, string>,
  body: unknown,
  status: number,
  extraHeaders: Record<string, string> = {},
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...cors,
      "Content-Type": "application/json",
      ...extraHeaders,
    },
  });
}

serve(handler);
