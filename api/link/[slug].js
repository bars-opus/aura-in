// api/link/[slug].js
import { createClient } from '@supabase/supabase-js';

// Initialize Supabase client
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
);

// Detect platform from user agent
function detectPlatform(userAgent) {
  if (/iPhone|iPad|iPod/.test(userAgent)) return 'ios';
  if (/Android/.test(userAgent)) return 'android';
  return 'web';
}

// Generate HTML response for web fallback
function generateWebFallback({ slug, shopName, shopImage, error }) {
  if (error) {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <title>Link Not Found - Aura-In</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background: #f5f5f5; }
          .container { text-align: center; padding: 20px; max-width: 400px; }
          .logo { font-size: 48px; margin-bottom: 20px; }
          h1 { color: #333; margin-bottom: 10px; }
          p { color: #666; margin-bottom: 20px; }
          .button { display: inline-block; background: #007aff; color: white; padding: 12px 24px; text-decoration: none; border-radius: 8px; font-weight: 500; margin: 5px; }
          .button-outline { background: transparent; border: 1px solid #007aff; color: #007aff; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="logo">🔗</div>
          <h1>Link Not Found</h1>
          <p>This link may have expired or been removed.</p>
          <a href="/" class="button">Go to Home</a>
        </div>
      </body>
      </html>
    `;
  }

  return `
    <!DOCTYPE html>
    <html>
    <head>
      <title>${shopName || 'Aura-In'} - Aura-In</title>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta property="og:title" content="${shopName || 'Aura-In'}">
      <meta property="og:description" content="Book appointments at ${shopName || 'this shop'} on Aura-In">
      ${shopImage ? `<meta property="og:image" content="${shopImage}">` : ''}
      <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; background: #f5f5f5; }
        .banner { background: #fff; padding: 12px; text-align: center; border-bottom: 1px solid #e5e5e5; position: sticky; top: 0; z-index: 100; }
        .banner-content { max-width: 400px; margin: 0 auto; display: flex; justify-content: space-between; align-items: center; }
        .open-app-btn { background: #007aff; color: white; border: none; padding: 8px 16px; border-radius: 20px; font-weight: 500; cursor: pointer; }
        .content { max-width: 600px; margin: 0 auto; padding: 20px; }
        .shop-card { background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .shop-image { width: 100%; height: 200px; object-fit: cover; background: #e5e5e5; }
        .shop-info { padding: 20px; }
        .shop-name { font-size: 24px; font-weight: 600; margin: 0 0 8px 0; }
        .install-prompt { background: #e8f0fe; border-radius: 12px; padding: 16px; margin-top: 20px; text-align: center; }
        .install-buttons { display: flex; gap: 12px; justify-content: center; margin-top: 12px; flex-wrap: wrap; }
        .app-store-btn { display: inline-block; height: 44px; }
        .fallback-text { display: none; }
        @media (max-width: 480px) { .content { padding: 12px; } }
      </style>
    </head>
    <body>
      <div class="banner">
        <div class="banner-content">
          <span>📱 Aura-In</span>
          <button class="open-app-btn" onclick="openApp()">Open in App</button>
        </div>
      </div>
      
      <div class="content">
        <div class="shop-card">
          ${shopImage ? `<img src="${shopImage}" class="shop-image" alt="${shopName}">` : '<div class="shop-image"></div>'}
          <div class="shop-info">
            <h1 class="shop-name">${shopName || 'Shop'}</h1>
            <p>Book appointments, view services, and connect with professionals.</p>
          </div>
        </div>
        
        <div class="install-prompt" id="installPrompt">
          <p>Get the best experience with the Aura-In app</p>
          <div class="install-buttons" id="installButtons"></div>
          <p class="fallback-text" id="fallbackText" style="font-size: 12px; color: #666;"></p>
        </div>
      </div>

      <script>
        const userAgent = navigator.userAgent;
        const isIOS = /iPhone|iPad|iPod/.test(userAgent);
        const isAndroid = /Android/.test(userAgent);
        const slug = '${slug}';
        
        function openApp() {
          const appScheme = 'aurain://shop/' + slug;
          window.location.href = appScheme;
          
          // Fallback timeout
          setTimeout(() => {
            if (isIOS) {
              window.location.href = 'https://apps.apple.com/app/idYOUR_APP_ID';
            } else if (isAndroid) {
              window.location.href = 'https://play.google.com/store/apps/details?id=com.barsOpus.aurain';
            }
          }, 500);
        }
        
        function renderInstallButtons() {
          const container = document.getElementById('installButtons');
          if (isIOS) {
            container.innerHTML = '<a href="https://apps.apple.com/app/idYOUR_APP_ID" class="app-store-btn"><img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" height="44"></a>';
          } else if (isAndroid) {
            container.innerHTML = '<a href="https://play.google.com/store/apps/details?id=com.barsOpus.aurain" class="app-store-btn"><img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" height="60"></a>';
          } else {
            document.getElementById('installPrompt').style.display = 'none';
          }
        }
        
        function checkAppInstalled() {
          const iframe = document.createElement('iframe');
          iframe.style.display = 'none';
          iframe.src = 'aurain://ping';
          document.body.appendChild(iframe);
          
          setTimeout(() => {
            document.body.removeChild(iframe);
          }, 1000);
        }
        
        renderInstallButtons();
        
        // Try to open app automatically after 1 second
        setTimeout(openApp, 1000);
      </script>
    </body>
    </html>
  `;
}

export default async function handler(req, res) {
  const { slug } = req.query;
  const userAgent = req.headers['user-agent'] || '';
  const platform = detectPlatform(userAgent);
  
  try {
    // Query the link from Supabase
    const { data: link, error } = await supabase
      .from('short_links')
      .select('*, shop:shops(*)')
      .eq('slug', slug)
      .eq('is_active', true)
      .single();
    
    if (error || !link) {
      return res.status(200).send(generateWebFallback({ slug, error: true }));
    }
    
    // Track the click
    await supabase.rpc('increment_link_clicks', {
      link_slug: slug,
      click_data: {
        platform: platform,
        user_agent: userAgent,
        referrer: req.headers.referer || null,
      }
    });
    
    // For iOS/Android, try to open app first
    if (platform !== 'web') {
      // Set headers for app detection
      res.setHeader('Content-Type', 'text/html');
      return res.status(200).send(generateWebFallback({
        slug,
        shopName: link.shop?.name,
        shopImage: link.shop?.image_url,
      }));
    }
    
    // For web, show the web version
    res.redirect(302, `https://aura-in-web.vercel.app/shop/${link.target_id}`);

    
    
  } catch (error) {
    console.error('Link resolution error:', error);
    return res.status(200).send(generateWebFallback({ slug, error: true }));
  }
}