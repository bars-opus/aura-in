#!/usr/bin/env bash
#
# Build and deploy the FULL Flutter web app (the complete app in a browser) to
# its Vercel project. This is NOT the Next.js link site in aura-in-web/ — that
# one auto-deploys from git. This is the heavy Flutter-compiled-to-web build,
# which has no git integration, so it must be built + pushed manually.
#
# Usage:   ./scripts/deploy-web.sh           # build + deploy to production
#          ./scripts/deploy-web.sh --preview # build + deploy a preview URL
#
# Requirements:
#   - .env.json at the repo root (Supabase/Mapbox/Sendbird keys — already present)
#   - Vercel CLI logged in (npx vercel login), linked to the aura-in-app project
#
set -euo pipefail

# Run from the repo root regardless of where the script is invoked.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

if [[ ! -f .env.json ]]; then
  echo "❌ .env.json not found at repo root — it carries the build-time keys." >&2
  exit 1
fi

PROD_FLAG="--prod"
if [[ "${1:-}" == "--preview" ]]; then
  PROD_FLAG=""
  echo "▶ Building Flutter web (preview)…"
else
  echo "▶ Building Flutter web (production)…"
fi

# --no-tree-shake-icons: the app builds some IconData non-const, which trips the
# icon tree-shaker on web. Disabling it is the documented workaround.
flutter build web --release \
  --dart-define-from-file=.env.json \
  --no-tree-shake-icons

# The SPA needs all routes rewritten to index.html (client-side routing) plus
# the deep-link rules. The root vercel.json holds them — ship it inside the
# build output so Vercel applies it to this static deployment.
cp vercel.json build/web/vercel.json

echo "▶ Deploying build/web to Vercel (aura-in-app)…"
# Deploy the prebuilt static directory. A fresh .vercel link avoids picking up
# the aura-in-web project's settings if this dir was used for another deploy.
( cd build/web && rm -rf .vercel && npx vercel $PROD_FLAG --yes --name aura-in-app )

echo "✅ Flutter web deploy complete."
echo "   (Public once Deployment Protection is off and app.aurain.barsopus.com is attached.)"
