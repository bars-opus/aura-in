export default function handler(req, res) {
  const params = new URLSearchParams(req.url.split('?')[1] || '');
  const code = params.get('code');
  const type = params.get('type');

  // Try to hand off to the native app via custom scheme (works in Safari, not WebViews)
  const appUrl = code
    ? `aurain://login-callback/?code=${encodeURIComponent(code)}${type ? `&type=${type}` : ''}`
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
