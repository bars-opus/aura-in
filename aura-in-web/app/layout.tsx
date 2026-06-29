// aura-in-web/app/layout.tsx
import type { Metadata, Viewport } from "next";
import "./globals.css";

export const metadata: Metadata = {
  // Resolves relative OG/icon URLs (e.g. /og-default.png) to absolute, which
  // WhatsApp and other crawlers require. Uses the deployment URL in prod, the
  // production domain otherwise.
  metadataBase: new URL(
    process.env.NEXT_PUBLIC_SITE_URL ??
      (process.env.VERCEL_URL
        ? `https://${process.env.VERCEL_URL}`
        : "https://aurain.barsopus.com"),
  ),
  title: "Aura-In · Book your appointment",
  description: "Skip the queue — book your appointment in one minute.",
  openGraph: {
    title: "Aura-In",
    description: "Skip the queue — book your appointment in one minute.",
    siteName: "Aura-In",
    type: "website",
    images: [{ url: "/og-default.png" }],
  },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#0f172a",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="antialiased bg-slate-50 text-slate-900">{children}</body>
    </html>
  );
}
