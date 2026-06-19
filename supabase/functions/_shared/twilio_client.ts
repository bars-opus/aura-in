// Thin wrapper over the Twilio Verify v2 REST API. Twilio owns code
// generation, expiry, rate limiting and brute-force protection — we only
// start a verification and check a submitted code.

export class TwilioConfigError extends Error {}

function config() {
  const sid = Deno.env.get("TWILIO_ACCOUNT_SID");
  const token = Deno.env.get("TWILIO_AUTH_TOKEN");
  const verifySid = Deno.env.get("TWILIO_VERIFY_SERVICE_SID");
  if (!sid || !token || !verifySid) {
    throw new TwilioConfigError("Missing Twilio environment variables");
  }
  return { sid, token, verifySid };
}

function authHeader(sid: string, token: string): string {
  return "Basic " + btoa(`${sid}:${token}`);
}

export async function startVerification(
  phoneE164: string,
): Promise<{ status: string }> {
  const { sid, token, verifySid } = config();
  const res = await fetch(
    `https://verify.twilio.com/v2/Services/${verifySid}/Verifications`,
    {
      method: "POST",
      headers: {
        "Authorization": authHeader(sid, token),
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({ To: phoneE164, Channel: "sms" }),
    },
  );
  if (!res.ok) {
    throw new Error(`Twilio start failed: ${res.status} ${await res.text()}`);
  }
  const data = await res.json();
  return { status: data.status };
}

export async function checkVerification(
  phoneE164: string,
  code: string,
): Promise<{ status: string }> {
  const { sid, token, verifySid } = config();
  const res = await fetch(
    `https://verify.twilio.com/v2/Services/${verifySid}/VerificationCheck`,
    {
      method: "POST",
      headers: {
        "Authorization": authHeader(sid, token),
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({ To: phoneE164, Code: code }),
    },
  );
  if (!res.ok) {
    // 404 here means no pending verification (expired / wrong number).
    if (res.status === 404) return { status: "expired" };
    throw new Error(`Twilio check failed: ${res.status} ${await res.text()}`);
  }
  const data = await res.json();
  return { status: data.status }; // "approved" | "pending" | ...
}
