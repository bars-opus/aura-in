// Strict allowlist: Supabase PKCE codes and recovery token_hashes are
// alphanumeric + `-` + `_`, never contain quotes or angle brackets. Reject
// anything else to keep untrusted input out of the HTML/JS we emit below.
const TOKEN_PATTERN = /^[A-Za-z0-9_-]{1,256}$/;
const TYPE_PATTERN = /^[a-z_]{1,32}$/;

export default function handler(req, res) {
  const params = new URLSearchParams(req.url.split('?')[1] || '');
  const rawCode = params.get('code');
  const rawType = params.get('type');

  const code = rawCode && TOKEN_PATTERN.test(rawCode) ? rawCode : null;
  const type = rawType && TYPE_PATTERN.test(rawType) ? rawType : null;

  if ((rawCode && !code) || (rawType && !type)) {
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    return res.status(400).send('Invalid callback parameters');
  }

  // Both `code` and `type` are now safe to interpolate into a URL.
  // We still URL-encode defensively for the path portion.
  const appUrl = code
    ? `aurain://login-callback/?code=${encodeURIComponent(code)}${type ? `&type=${encodeURIComponent(type)}` : ''}`
    : 'aurain://login-callback/';

  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.status(200).send(`<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Opening Aura-In...</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; background: #f5f5f5; }
    .card { background: white; border-radius: 16px; padding: 32px 24px; text-align: center; max-width: 320px; box-shadow: 0 2px 16px rgba(0,0,0,0.08); }
    h2 { margin: 0 0 8px; font-size: 20px; color: #111; }
    p { margin: 0 0 24px; color: #666; font-size: 15px; line-height: 1.5; }
    a.btn { display: block; background: #007AFF; color: white; text-decoration: none; padding: 14px; border-radius: 12px; font-weight: 600; font-size: 16px; }
  </style>
</head>
<body>
  <div class="card">
    <h2>Opening Aura-In</h2>
    <p>Tap the button below if the app doesn't open automatically.</p>
    <a class="btn" href="${appUrl}" id="openBtn">Open in Aura-In App</a>
  </div>
  <script>
    // Auto-attempt after a short delay
    setTimeout(function() {
      window.location.href = "${appUrl}";
    }, 500);
  </script>
</body>
</html>`);
}
