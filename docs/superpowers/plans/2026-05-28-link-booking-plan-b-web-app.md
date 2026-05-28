# Public Link Booking — Plan B: Next.js Web App

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the public-facing browser booking flow at `aura-in-web.vercel.app/book/<slug>` — single-page scroll, server-rendered for fast first paint, one client component for slot interactivity, deposit payment via redirect to Paystack/Stripe hosted page.

**Architecture:** Next.js 14 with the app router. Server components fetch all booking data in one round-trip to Plan A's `resolve-link` edge function. A single client component (`SlotPicker`) handles the only interactive bit (slot selection). Form submit POSTs to `create-booking`, server returns `authorizationUrl`, browser redirects. After payment, browser is redirected to `/book/<slug>/success?reference=...` which polls `bookings` until confirmed.

**Tech Stack:** Next.js 14 app router (React 18, server components), TypeScript, Tailwind CSS, no UI library. Mapbox JS Geocoder lazy-loaded only for freelancer-with-canTravel pages. Deployed to Vercel.

**Prerequisites:** Plan A (Backend Foundation) is fully shipped and the edge functions return the documented JSON shapes.

**Reference design:** [docs/superpowers/specs/2026-05-28-public-link-booking-design.md](../specs/2026-05-28-public-link-booking-design.md)

---

## File Structure

**Create (new top-level directory):**

```
aura-in-web/
├── package.json
├── next.config.mjs
├── tailwind.config.ts
├── tsconfig.json
├── postcss.config.mjs
├── .env.local.example
├── .env.local                                # gitignored, holds real keys
├── public/
│   ├── favicon.ico
│   └── og-image.png
├── app/
│   ├── layout.tsx                            # root layout, fonts, viewport
│   ├── page.tsx                              # landing page (marketing-y, optional)
│   ├── globals.css
│   ├── book/
│   │   └── [slug]/
│   │       ├── page.tsx                      # server component, /book/<slug>
│   │       ├── success/page.tsx              # confirmation polling
│   │       ├── error/page.tsx                # error states
│   │       └── components/
│   │           ├── ShopHero.tsx              # server component
│   │           ├── FreelancerHero.tsx        # server component
│   │           ├── ServicePicker.tsx         # client component
│   │           ├── WorkerPicker.tsx          # client component (optional)
│   │           ├── SlotPicker.tsx            # client component (the main interactive bit)
│   │           ├── AddressPicker.tsx         # client component (freelancer canTravel only)
│   │           ├── GuestForm.tsx             # client component
│   │           └── BookingFlow.tsx           # client component, orchestrates form state + submit
│   └── api/
│       └── (no route handlers needed; everything goes through Supabase edge fns)
└── lib/
    ├── api.ts                                # typed calls to resolve-link, lookup-guest, create-booking
    ├── types.ts                              # shared types (ResolveLinkResponse, etc.)
    └── format.ts                             # currency / date formatters
```

---

## Task 1: Bootstrap the Next.js project

**Files:**
- Create: `aura-in-web/` directory + all baseline files (package.json, next.config, tailwind, tsconfig)

---

- [ ] **Step 1: Create the project with Next.js's create-next-app**

```bash
npx create-next-app@latest aura-in-web \
  --typescript \
  --tailwind \
  --app \
  --src-dir=false \
  --import-alias="@/*" \
  --eslint
```

Answer the prompts:
- Use ESLint? **Yes**
- Use src/ directory? **No** (we want `aura-in-web/app/` at the top)
- Use App Router? **Yes**
- Customize import alias? **Yes**, use `@/*`

- [ ] **Step 2: Verify it runs locally**

```bash
cd aura-in-web
npm run dev
```

Expected: server starts on `http://localhost:3000`, default Next.js homepage renders.

Stop with Ctrl+C.

- [ ] **Step 3: Add environment variables template**

Create `aura-in-web/.env.local.example`:

```
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://<project-ref>.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=<anon-key>

# Mapbox (for freelancer address geocoding, optional)
NEXT_PUBLIC_MAPBOX_TOKEN=
```

Create `aura-in-web/.env.local` with real values (do not commit).

Verify `.env.local` is in `aura-in-web/.gitignore` (Next.js puts it there by default).

- [ ] **Step 4: Trim the default homepage**

Replace `aura-in-web/app/page.tsx` with a minimal placeholder:

```tsx
// aura-in-web/app/page.tsx
export default function Home() {
  return (
    <main className="min-h-screen flex items-center justify-center p-8">
      <div className="text-center">
        <h1 className="text-2xl font-semibold text-slate-900">Aura-In</h1>
        <p className="text-slate-500 mt-2">
          Visit a shop&apos;s booking link to make an appointment.
        </p>
      </div>
    </main>
  );
}
```

Replace `aura-in-web/app/layout.tsx`:

```tsx
// aura-in-web/app/layout.tsx
import type { Metadata, Viewport } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Aura-In · Book your appointment",
  description: "Skip the queue — book your appointment in one minute.",
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
```

- [ ] **Step 5: Run the dev server and verify the trimmed homepage**

```bash
cd aura-in-web
npm run dev
```

Visit http://localhost:3000 — expect the centered "Aura-In" placeholder.

- [ ] **Step 6: Commit**

```bash
git add aura-in-web/
git commit -m "feat(aura-in-web): bootstrap Next.js 14 app

Plan B step 1: scaffolds the public booking web app. Next.js 14 with
the app router, Tailwind, TypeScript. Minimal landing page at /.
Environment variables template in .env.local.example.
Real /book/<slug> pages added in subsequent tasks."
```

---

## Task 2: Shared types and API client

**Files:**
- Create: `aura-in-web/lib/types.ts`
- Create: `aura-in-web/lib/api.ts`
- Create: `aura-in-web/lib/format.ts`

---

- [ ] **Step 1: Write shared types**

Create `aura-in-web/lib/types.ts`:

```typescript
// aura-in-web/lib/types.ts
//
// Types shared between server components, client components, and the API
// helpers. Mirror the JSON shapes returned by the Supabase edge functions
// from Plan A.

export type TargetType = "shop" | "freelancer";

export interface ShopTarget {
  id: string;
  name: string;
  type: string;
  currency: string;
  country: string;
  address: string | null;
  logo_url: string | null;
  cover_url: string | null;
  latitude: number | null;
  longitude: number | null;
  can_travel: boolean;
  travel_radius_km: number | null;
}

export interface FreelancerTarget {
  id: string;
  name: string;
  type: string;
  currency: string;
  country: string;
  profile_image_url: string | null;
  cover_image_url: string | null;
  latitude: number | null;
  longitude: number | null;
  can_travel: boolean;
  travel_radius_km: number | null;
  base_address: string | null;
}

export interface Service {
  id: string;
  service_name: string;
  price: number;
  duration: string;          // ISO 8601 duration, e.g., "PT30M"
  description: string | null;
}

export interface Worker {
  id: string;
  name: string;
  profile_image_url: string | null;
  specialties: string[];
  rating_average: number | null;
}

export interface SlotEntry {
  start_time: string;        // ISO timestamp
  end_time: string;          // ISO timestamp
  worker_id: string | null;
}

export interface ResolveLinkResponse {
  targetType: TargetType;
  target: ShopTarget | FreelancerTarget;
  services: Service[];
  workers: Worker[];         // empty array for freelancer
  canTravel: boolean;
  travelRadiusKm: number | null;
  availableSlots: SlotEntry[];
  depositFraction: number;
  platformFeeFraction: number;
}

export interface LookupGuestResponse {
  name: string;
  lastServices: string[];
}

export interface CreateBookingRequest {
  shopId?: string;
  freelancerId?: string;
  guestName: string;
  guestPhone: string;
  clientAddress?: string;
  clientAddressLat?: number;
  clientAddressLng?: number;
  services: Array<{
    slotId: string;
    workerId: string | null;
    serviceName: string;
    workerName: string;
    priceAtBooking: number;
    durationMinutes: number;
  }>;
  startTime: string;
  endTime: string;
  actualEndTime: string;
  totalAmount: number;
  depositAmount: number;
  platformFee: number;
  paymentMethod: string;
  paymentProvider: string;
  idempotencyKey: string;
  deliveryChannel: "whatsapp";
  successUrl: string;
  cancelUrl: string;
}

export interface CreateBookingResponse {
  success: boolean;
  authorizationUrl?: string;
  reference?: string;
  paymentIntentId?: string;
  error?: string;
}
```

- [ ] **Step 2: Write the API client**

Create `aura-in-web/lib/api.ts`:

```typescript
// aura-in-web/lib/api.ts
//
// Typed wrappers around the Supabase edge functions. Server-component side:
// uses fetch with cache hints. Client-component side: uses regular fetch.

import type {
  ResolveLinkResponse,
  LookupGuestResponse,
  CreateBookingRequest,
  CreateBookingResponse,
} from "./types";

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const ANON_KEY = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

if (!SUPABASE_URL || !ANON_KEY) {
  throw new Error("Supabase env vars missing — check .env.local");
}

/**
 * Resolve a slug to shop/freelancer + services + slots. Called from server
 * components; cached at the Vercel edge for 30s.
 */
export async function resolveLink(slug: string): Promise<ResolveLinkResponse | null> {
  const url = `${SUPABASE_URL}/functions/v1/resolve-link?slug=${encodeURIComponent(slug)}`;
  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${ANON_KEY}` },
    next: { revalidate: 30 },
  });
  if (res.status === 404) return null;
  if (!res.ok) {
    throw new Error(`resolve-link failed: ${res.status}`);
  }
  return res.json();
}

/**
 * Look up a guest profile by phone. Returns null if unknown (200 + null body).
 * Called from client components after the user types a phone.
 */
export async function lookupGuest(phone: string): Promise<LookupGuestResponse | null> {
  const url = `${SUPABASE_URL}/functions/v1/lookup-guest`;
  const res = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${ANON_KEY}`,
    },
    body: JSON.stringify({ phone }),
  });
  if (!res.ok) return null;
  const body = await res.json();
  return body; // null or { name, lastServices }
}

/**
 * Submit a booking. Returns the Paystack/Stripe authorization URL the
 * browser should redirect to.
 */
export async function createBooking(
  req: CreateBookingRequest,
): Promise<CreateBookingResponse> {
  const url = `${SUPABASE_URL}/functions/v1/create-booking`;
  const res = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${ANON_KEY}`,
    },
    body: JSON.stringify(req),
  });
  if (!res.ok) {
    const errBody = await res.json().catch(() => ({ error: "Unknown error" }));
    return { success: false, error: errBody.error ?? `HTTP ${res.status}` };
  }
  return res.json();
}

/**
 * Server-side: poll bookings by reference until confirmed. Used by the
 * /success page after Paystack redirects back.
 */
export async function fetchBookingByReference(
  reference: string,
): Promise<{ id: string; status: string } | null> {
  const url =
    `${SUPABASE_URL}/rest/v1/bookings?payment_intent_id=eq.${encodeURIComponent(reference)}&select=id,status&status=eq.confirmed&limit=1`;
  const res = await fetch(url, {
    headers: {
      apikey: ANON_KEY,
      Authorization: `Bearer ${ANON_KEY}`,
    },
    cache: "no-store",
  });
  if (!res.ok) return null;
  const rows = await res.json();
  return rows[0] ?? null;
}
```

- [ ] **Step 3: Write formatters**

Create `aura-in-web/lib/format.ts`:

```typescript
// aura-in-web/lib/format.ts

export function formatMoney(amount: number, currency: string): string {
  const symbol = currency === "GHS"
    ? "GH₵"
    : currency === "NGN"
    ? "₦"
    : currency === "KES"
    ? "KSh"
    : currency === "USD"
    ? "$"
    : currency === "EUR"
    ? "€"
    : currency;
  return `${symbol} ${amount.toFixed(2)}`;
}

export function formatDuration(iso: string): string {
  // ISO 8601 duration like "PT30M" or "PT1H30M"
  const match = iso.match(/PT(?:(\d+)H)?(?:(\d+)M)?/);
  if (!match) return iso;
  const hours = match[1] ? parseInt(match[1]) : 0;
  const minutes = match[2] ? parseInt(match[2]) : 0;
  if (hours && minutes) return `${hours}h ${minutes}min`;
  if (hours) return `${hours}h`;
  return `${minutes} min`;
}

export function durationToMinutes(iso: string): number {
  const match = iso.match(/PT(?:(\d+)H)?(?:(\d+)M)?/);
  if (!match) return 0;
  const hours = match[1] ? parseInt(match[1]) : 0;
  const minutes = match[2] ? parseInt(match[2]) : 0;
  return hours * 60 + minutes;
}

export function formatTimeSlot(iso: string): string {
  const d = new Date(iso);
  return d.toLocaleTimeString("en-GB", {
    hour: "numeric",
    minute: "2-digit",
    hour12: true,
  });
}

export function formatDateHeader(iso: string): string {
  const d = new Date(iso);
  return d.toLocaleDateString("en-GB", {
    weekday: "short",
    day: "numeric",
    month: "short",
  });
}
```

- [ ] **Step 4: Verify the project type-checks**

```bash
cd aura-in-web
npm run lint
npx tsc --noEmit
```

Expected: both pass with no errors.

- [ ] **Step 5: Commit**

```bash
git add aura-in-web/lib/
git commit -m "feat(aura-in-web): typed API client + formatters

lib/types.ts: shared types mirroring Plan A edge function responses
lib/api.ts: resolveLink, lookupGuest, createBooking, fetchBookingByReference
lib/format.ts: money / duration / time / date formatters

Server components in the next task use these to fetch and render data."
```

---

## Task 3: /book/[slug] page — server component

**Files:**
- Create: `aura-in-web/app/book/[slug]/page.tsx`
- Create: `aura-in-web/app/book/[slug]/components/ShopHero.tsx`
- Create: `aura-in-web/app/book/[slug]/components/FreelancerHero.tsx`

**Why:** The single page that renders shop info, services, and slots in HTML on first paint. All interactive bits (slot picker, form) are introduced in Task 4.

---

- [ ] **Step 1: Write the server component**

Create `aura-in-web/app/book/[slug]/page.tsx`:

```tsx
// aura-in-web/app/book/[slug]/page.tsx
//
// Server component. Resolves the slug, fetches shop/freelancer + services +
// slots from Plan A's resolve-link edge function, renders the page server-side
// for fast first paint. Interactive client components (slot picker, form)
// receive the data as props.

import { resolveLink } from "@/lib/api";
import { ShopHero } from "./components/ShopHero";
import { FreelancerHero } from "./components/FreelancerHero";
import { BookingFlow } from "./components/BookingFlow";
import { notFound } from "next/navigation";
import type { Metadata } from "next";

interface Props {
  params: { slug: string };
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const data = await resolveLink(params.slug);
  if (!data) {
    return { title: "Booking link not found · Aura-In" };
  }
  return {
    title: `Book at ${data.target.name} · Aura-In`,
    description: `Book your appointment at ${data.target.name}. Pay deposit, get WhatsApp confirmation.`,
  };
}

export default async function BookingPage({ params }: Props) {
  const data = await resolveLink(params.slug);

  if (!data) notFound();

  return (
    <main className="min-h-screen bg-slate-50 pb-32">
      <div className="max-w-md mx-auto">
        {data.targetType === "shop"
          ? <ShopHero target={data.target as any} />
          : <FreelancerHero target={data.target as any} />}

        <BookingFlow data={data} slug={params.slug} />
      </div>
    </main>
  );
}
```

- [ ] **Step 2: Write ShopHero**

Create `aura-in-web/app/book/[slug]/components/ShopHero.tsx`:

```tsx
// aura-in-web/app/book/[slug]/components/ShopHero.tsx
import type { ShopTarget } from "@/lib/types";

export function ShopHero({ target }: { target: ShopTarget }) {
  return (
    <header className="bg-white border-b border-slate-200 px-4 py-4 flex items-center gap-3">
      {target.logo_url
        ? <img
            src={target.logo_url}
            alt=""
            className="w-12 h-12 rounded-lg object-cover bg-slate-200"
          />
        : <div className="w-12 h-12 rounded-lg bg-slate-800 text-white flex items-center justify-center font-semibold">
            {target.name.slice(0, 2).toUpperCase()}
          </div>}
      <div className="flex-1 min-w-0">
        <h1 className="font-semibold text-slate-900 truncate">{target.name}</h1>
        <p className="text-xs text-slate-500 truncate">
          {target.type}
          {target.address ? ` · ${target.address}` : ""}
        </p>
      </div>
    </header>
  );
}
```

- [ ] **Step 3: Write FreelancerHero**

Create `aura-in-web/app/book/[slug]/components/FreelancerHero.tsx`:

```tsx
// aura-in-web/app/book/[slug]/components/FreelancerHero.tsx
import type { FreelancerTarget } from "@/lib/types";

export function FreelancerHero({ target }: { target: FreelancerTarget }) {
  return (
    <header className="bg-white border-b border-slate-200 px-4 py-4 flex items-center gap-3">
      {target.profile_image_url
        ? <img
            src={target.profile_image_url}
            alt=""
            className="w-12 h-12 rounded-full object-cover bg-slate-200"
          />
        : <div className="w-12 h-12 rounded-full bg-slate-800 text-white flex items-center justify-center font-semibold">
            {target.name.slice(0, 2).toUpperCase()}
          </div>}
      <div className="flex-1 min-w-0">
        <h1 className="font-semibold text-slate-900 truncate">{target.name}</h1>
        <p className="text-xs text-slate-500 truncate">
          {target.type}
          {target.can_travel ? " · Comes to you" : ""}
        </p>
      </div>
    </header>
  );
}
```

- [ ] **Step 4: Write a placeholder BookingFlow client component (gets fleshed out in Task 4)**

Create `aura-in-web/app/book/[slug]/components/BookingFlow.tsx`:

```tsx
// aura-in-web/app/book/[slug]/components/BookingFlow.tsx
"use client";

import type { ResolveLinkResponse } from "@/lib/types";

export function BookingFlow({ data, slug }: {
  data: ResolveLinkResponse;
  slug: string;
}) {
  return (
    <div className="p-4">
      <p className="text-sm text-slate-600">
        {data.services.length} service{data.services.length === 1 ? "" : "s"}
        {" · "}
        {data.availableSlots.length} slots available
      </p>
      <p className="text-xs text-slate-400 mt-4">
        BookingFlow client component pending Task 4.
      </p>
    </div>
  );
}
```

- [ ] **Step 5: Run dev server and smoke-test**

```bash
cd aura-in-web
npm run dev
```

Visit:
- http://localhost:3000/book/test-shop-slug (with a real slug from Plan A setup)
  → expect shop name + service count to render
- http://localhost:3000/book/nonexistent
  → expect Next.js 404 page

- [ ] **Step 6: Commit**

```bash
git add aura-in-web/app/book/
git commit -m "feat(aura-in-web): /book/[slug] server component + hero rendering

Renders shop or freelancer hero server-side from resolve-link data.
notFound() routes unknown slugs to the standard Next.js 404 page.
generateMetadata sets title + description per shop.
BookingFlow client component is a placeholder filled in Task 4."
```

---

## Task 4: BookingFlow client component (the main interactive piece)

**Files:**
- Replace: `aura-in-web/app/book/[slug]/components/BookingFlow.tsx` (the placeholder from Task 3)
- Create: `aura-in-web/app/book/[slug]/components/ServicePicker.tsx`
- Create: `aura-in-web/app/book/[slug]/components/WorkerPicker.tsx`
- Create: `aura-in-web/app/book/[slug]/components/SlotPicker.tsx`
- Create: `aura-in-web/app/book/[slug]/components/GuestForm.tsx`

---

- [ ] **Step 1: Write ServicePicker**

Create `aura-in-web/app/book/[slug]/components/ServicePicker.tsx`:

```tsx
"use client";

import type { Service } from "@/lib/types";
import { formatDuration, formatMoney } from "@/lib/format";

export function ServicePicker({
  services, currency, selectedId, lastBookedServiceName, onSelect,
}: {
  services: Service[];
  currency: string;
  selectedId: string | null;
  lastBookedServiceName?: string;
  onSelect: (id: string) => void;
}) {
  return (
    <section className="px-4 pt-4">
      <h2 className="text-xs uppercase tracking-wide text-slate-500 mb-2 font-medium">
        1. Service
      </h2>
      <div className="space-y-2">
        {services.map(svc => {
          const selected = selectedId === svc.id;
          const isLast = lastBookedServiceName && svc.service_name === lastBookedServiceName;
          return (
            <button
              key={svc.id}
              type="button"
              onClick={() => onSelect(svc.id)}
              className={`w-full text-left bg-white rounded-lg p-3 flex justify-between items-center border ${
                selected ? "border-emerald-500 ring-1 ring-emerald-500" : "border-slate-200"
              }`}
            >
              <div>
                <div className="font-medium text-slate-900 flex items-center gap-2">
                  {svc.service_name}
                  {isLast && (
                    <span className="text-[10px] uppercase tracking-wide bg-emerald-50 text-emerald-700 px-1.5 py-0.5 rounded">
                      Booked last time
                    </span>
                  )}
                </div>
                <div className="text-xs text-slate-500 mt-0.5">
                  {formatDuration(svc.duration)}
                </div>
              </div>
              <div className={`font-semibold ${selected ? "text-emerald-600" : "text-slate-700"}`}>
                {formatMoney(svc.price, currency)}
              </div>
            </button>
          );
        })}
      </div>
    </section>
  );
}
```

- [ ] **Step 2: Write WorkerPicker (optional step, shops only)**

Create `aura-in-web/app/book/[slug]/components/WorkerPicker.tsx`:

```tsx
"use client";

import type { Worker } from "@/lib/types";

export function WorkerPicker({
  workers, selectedId, onSelect,
}: {
  workers: Worker[];
  selectedId: string | null;
  onSelect: (id: string | null) => void;
}) {
  if (workers.length === 0) return null;

  return (
    <section className="px-4 pt-3">
      <h2 className="text-xs uppercase tracking-wide text-slate-500 mb-2 font-medium">
        2. Worker <span className="lowercase text-slate-400">(optional)</span>
      </h2>
      <div className="flex gap-2 overflow-x-auto -mx-4 px-4 pb-1">
        <button
          type="button"
          onClick={() => onSelect(null)}
          className={`flex-shrink-0 px-3 py-2 rounded-lg border bg-white ${
            selectedId === null ? "border-emerald-500 ring-1 ring-emerald-500 text-slate-900 font-medium" : "border-slate-200 text-slate-600"
          }`}
        >
          Any available
        </button>
        {workers.map(w => (
          <button
            key={w.id}
            type="button"
            onClick={() => onSelect(w.id)}
            className={`flex-shrink-0 px-3 py-2 rounded-lg border bg-white ${
              selectedId === w.id ? "border-emerald-500 ring-1 ring-emerald-500 text-slate-900 font-medium" : "border-slate-200 text-slate-600"
            }`}
          >
            {w.name}
          </button>
        ))}
      </div>
    </section>
  );
}
```

- [ ] **Step 3: Write SlotPicker**

Create `aura-in-web/app/book/[slug]/components/SlotPicker.tsx`:

```tsx
"use client";

import { useMemo } from "react";
import type { SlotEntry } from "@/lib/types";
import { formatTimeSlot, formatDateHeader } from "@/lib/format";

export function SlotPicker({
  slots, workerId, selectedSlot, onSelect,
}: {
  slots: SlotEntry[];
  workerId: string | null;
  selectedSlot: SlotEntry | null;
  onSelect: (slot: SlotEntry) => void;
}) {
  // Filter slots by worker if one is selected.
  const filtered = useMemo(() => {
    if (!workerId) return slots;
    return slots.filter(s => s.worker_id === workerId);
  }, [slots, workerId]);

  // Group by date.
  const byDate = useMemo(() => {
    const groups: Record<string, SlotEntry[]> = {};
    for (const s of filtered) {
      const date = new Date(s.start_time).toDateString();
      (groups[date] ??= []).push(s);
    }
    return Object.entries(groups);
  }, [filtered]);

  // Default to first available date.
  const [selectedDate, setSelectedDate] = useDateState(byDate);

  const slotsForDate = byDate.find(([d]) => d === selectedDate)?.[1] ?? [];

  return (
    <section className="px-4 pt-3">
      <h2 className="text-xs uppercase tracking-wide text-slate-500 mb-2 font-medium">
        3. When
      </h2>

      <div className="flex gap-1 overflow-x-auto -mx-4 px-4 pb-2 mb-2">
        {byDate.map(([date]) => (
          <button
            key={date}
            type="button"
            onClick={() => setSelectedDate(date)}
            className={`flex-shrink-0 min-w-[3rem] px-2 py-1.5 rounded text-center border ${
              selectedDate === date ? "bg-slate-900 text-white border-slate-900" : "bg-white text-slate-700 border-slate-200"
            }`}
          >
            <div className="text-[10px] opacity-70">{formatDateHeader(date).split(" ")[0]}</div>
            <div className="font-semibold text-sm">{new Date(date).getDate()}</div>
          </button>
        ))}
      </div>

      <div className="grid grid-cols-3 gap-1">
        {slotsForDate.map(slot => {
          const selected = selectedSlot?.start_time === slot.start_time;
          return (
            <button
              key={slot.start_time}
              type="button"
              onClick={() => onSelect(slot)}
              className={`py-2 text-center rounded text-sm border ${
                selected ? "bg-emerald-50 border-emerald-500 text-emerald-700 font-semibold" : "bg-white border-slate-200 text-slate-700"
              }`}
            >
              {formatTimeSlot(slot.start_time)}
            </button>
          );
        })}
        {slotsForDate.length === 0 && (
          <div className="col-span-3 text-center text-sm text-slate-400 py-6">
            No slots available on this date.
          </div>
        )}
      </div>
    </section>
  );
}

import { useState } from "react";
function useDateState(byDate: [string, SlotEntry[]][]): [string | null, (d: string) => void] {
  const [date, setDate] = useState<string | null>(byDate[0]?.[0] ?? null);
  return [date, setDate];
}
```

- [ ] **Step 4: Write GuestForm**

Create `aura-in-web/app/book/[slug]/components/GuestForm.tsx`:

```tsx
"use client";

import { useState, useEffect } from "react";
import { lookupGuest } from "@/lib/api";

export function GuestForm({
  name, phone, onChange,
}: {
  name: string;
  phone: string;
  onChange: (next: { name: string; phone: string; lastService?: string }) => void;
}) {
  const [phoneDebounced, setPhoneDebounced] = useState(phone);

  // Debounce phone changes by 500ms.
  useEffect(() => {
    const t = setTimeout(() => setPhoneDebounced(phone), 500);
    return () => clearTimeout(t);
  }, [phone]);

  // Phone lookup → prefill name + signal last service.
  useEffect(() => {
    if (!/^\+\d{8,15}$/.test(phoneDebounced)) return;
    let cancelled = false;
    lookupGuest(phoneDebounced).then(res => {
      if (cancelled || !res) return;
      if (!name) {
        onChange({ name: res.name, phone, lastService: res.lastServices[0] });
      } else {
        onChange({ name, phone, lastService: res.lastServices[0] });
      }
    });
    return () => { cancelled = true; };
  }, [phoneDebounced]); // eslint-disable-line react-hooks/exhaustive-deps

  return (
    <section className="px-4 pt-3">
      <h2 className="text-xs uppercase tracking-wide text-slate-500 mb-2 font-medium">
        4. Your details
      </h2>
      <input
        type="text"
        placeholder="Full name"
        value={name}
        onChange={e => onChange({ name: e.target.value, phone })}
        className="w-full bg-white border border-slate-200 rounded-lg px-3 py-2.5 text-sm mb-2"
      />
      <input
        type="tel"
        placeholder="Phone (MoMo, with country code, e.g. +233...)"
        value={phone}
        onChange={e => onChange({ name, phone: e.target.value })}
        className="w-full bg-white border border-slate-200 rounded-lg px-3 py-2.5 text-sm"
      />
    </section>
  );
}
```

- [ ] **Step 5: Replace BookingFlow with the full orchestrator**

Replace `aura-in-web/app/book/[slug]/components/BookingFlow.tsx`:

```tsx
"use client";

import { useState, useMemo } from "react";
import type { ResolveLinkResponse, SlotEntry, Service } from "@/lib/types";
import { ServicePicker } from "./ServicePicker";
import { WorkerPicker } from "./WorkerPicker";
import { SlotPicker } from "./SlotPicker";
import { GuestForm } from "./GuestForm";
import { createBooking } from "@/lib/api";
import { formatMoney, durationToMinutes } from "@/lib/format";

export function BookingFlow({ data, slug }: {
  data: ResolveLinkResponse;
  slug: string;
}) {
  const [selectedServiceId, setSelectedServiceId] = useState<string | null>(null);
  const [selectedWorkerId, setSelectedWorkerId] = useState<string | null>(null);
  const [selectedSlot, setSelectedSlot] = useState<SlotEntry | null>(null);
  const [name, setName] = useState("");
  const [phone, setPhone] = useState("");
  const [lastService, setLastService] = useState<string | undefined>();
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const selectedService: Service | null = useMemo(
    () => data.services.find(s => s.id === selectedServiceId) ?? null,
    [data.services, selectedServiceId],
  );

  const canSubmit = selectedService && selectedSlot && name && phone;
  const deposit = selectedService
    ? selectedService.price * data.depositFraction
    : 0;
  const platformFee = selectedService
    ? selectedService.price * data.platformFeeFraction
    : 0;
  const currency = data.target.currency;

  async function handleSubmit() {
    if (!canSubmit || !selectedService || !selectedSlot) return;
    setSubmitting(true);
    setError(null);

    const startTime = selectedSlot.start_time;
    const durationMin = durationToMinutes(selectedService.duration);
    const endTime = new Date(
      new Date(startTime).getTime() + durationMin * 60_000,
    ).toISOString();
    const actualEndTime = endTime;

    const isShop = data.targetType === "shop";
    const idempotencyKey = `${isShop ? "shop" : "freelancer"}_${data.target.id}_${phone}_${new Date(startTime).getTime()}`;

    const res = await createBooking({
      shopId: isShop ? data.target.id : undefined,
      freelancerId: !isShop ? data.target.id : undefined,
      guestName: name,
      guestPhone: phone,
      services: [{
        slotId: selectedService.id,
        workerId: selectedWorkerId,
        serviceName: selectedService.service_name,
        workerName: data.workers.find(w => w.id === selectedWorkerId)?.name ?? "",
        priceAtBooking: selectedService.price,
        durationMinutes: durationMin,
      }],
      startTime,
      endTime,
      actualEndTime,
      totalAmount: selectedService.price,
      depositAmount: deposit,
      platformFee,
      paymentMethod: "paystack", // server overrides based on currency
      paymentProvider: "paystack",
      idempotencyKey,
      deliveryChannel: "whatsapp",
      successUrl: `https://aura-in-web.vercel.app/book/${slug}/success`,
      cancelUrl: `https://aura-in-web.vercel.app/book/${slug}`,
    });

    if (!res.success || !res.authorizationUrl) {
      setError(res.error ?? "Could not start payment. Please try again.");
      setSubmitting(false);
      return;
    }
    window.location.href = res.authorizationUrl;
  }

  return (
    <>
      <ServicePicker
        services={data.services}
        currency={currency}
        selectedId={selectedServiceId}
        lastBookedServiceName={lastService}
        onSelect={setSelectedServiceId}
      />
      {data.targetType === "shop" && (
        <WorkerPicker
          workers={data.workers}
          selectedId={selectedWorkerId}
          onSelect={setSelectedWorkerId}
        />
      )}
      <SlotPicker
        slots={data.availableSlots}
        workerId={selectedWorkerId}
        selectedSlot={selectedSlot}
        onSelect={setSelectedSlot}
      />
      <GuestForm
        name={name}
        phone={phone}
        onChange={({ name, phone, lastService }) => {
          setName(name);
          setPhone(phone);
          if (lastService) setLastService(lastService);
        }}
      />

      {error && (
        <div className="mx-4 mt-3 bg-red-50 border border-red-200 text-red-700 text-sm px-3 py-2 rounded">
          {error}
        </div>
      )}

      <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-slate-200">
        <button
          type="button"
          onClick={handleSubmit}
          disabled={!canSubmit || submitting}
          className={`w-full py-3.5 text-white font-semibold ${
            canSubmit && !submitting ? "bg-emerald-600 active:bg-emerald-700" : "bg-slate-300"
          }`}
        >
          {submitting
            ? "Starting payment…"
            : selectedService
            ? `Pay ${formatMoney(deposit, currency)} deposit · Continue`
            : "Pick a service"}
        </button>
        {selectedService && (
          <div className="bg-slate-50 text-center text-xs text-slate-500 py-2">
            Remaining {formatMoney(selectedService.price - deposit, currency)} paid after service
          </div>
        )}
      </div>
    </>
  );
}
```

- [ ] **Step 6: Smoke-test the full flow on localhost**

```bash
cd aura-in-web
npm run dev
```

Visit http://localhost:3000/book/test-shop-slug (real slug). Verify:
- Service list renders
- Tapping a service highlights it
- Worker picker shows for shops
- Slot picker shows times by date
- Form accepts name + phone
- "Pay GH₵ X deposit" button activates only when all fields are set
- Tapping it (with real data) hits create-booking and redirects to Paystack

- [ ] **Step 7: Commit**

```bash
git add aura-in-web/app/book/[slug]/components/
git commit -m "feat(aura-in-web): single-page booking flow

ServicePicker + WorkerPicker (shops only) + SlotPicker + GuestForm,
orchestrated by BookingFlow. Submit calls create-booking and redirects
to the returned Paystack/Stripe checkout URL. Lookup-guest prefills
name and surfaces 'Booked last time' pill on returning clients.

Flow is single-page scroll (no wizard), sticky CTA at bottom with
deposit + remaining-after-service copy."
```

---

## Task 5: Freelancer address picker (Mapbox geocoder)

**Files:**
- Create: `aura-in-web/app/book/[slug]/components/AddressPicker.tsx`
- Modify: `aura-in-web/app/book/[slug]/components/BookingFlow.tsx` (add AddressPicker section)
- Modify: `aura-in-web/package.json` (add Mapbox dep)

---

- [ ] **Step 1: Install Mapbox dep**

```bash
cd aura-in-web
npm install @mapbox/mapbox-gl-geocoder mapbox-gl
```

- [ ] **Step 2: Write AddressPicker**

Create `aura-in-web/app/book/[slug]/components/AddressPicker.tsx`:

```tsx
"use client";

import { useEffect, useRef, useState } from "react";
import type { FreelancerTarget } from "@/lib/types";

interface PickedAddress {
  text: string;
  lat: number;
  lng: number;
}

export function AddressPicker({
  freelancer, onChange,
}: {
  freelancer: FreelancerTarget;
  onChange: (addr: PickedAddress | null, distanceKm: number | null) => void;
}) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let geocoder: any = null;

    async function init() {
      const token = process.env.NEXT_PUBLIC_MAPBOX_TOKEN;
      if (!token) {
        setError("Address autocomplete unavailable");
        return;
      }
      // Lazy import to avoid the bundle cost on shop pages.
      const Mapbox = await import("@mapbox/mapbox-gl-geocoder");
      const Geocoder = (Mapbox as any).default ?? Mapbox;

      geocoder = new Geocoder({
        accessToken: token,
        placeholder: "Enter your address",
        countries: freelancer.country?.toLowerCase() ?? undefined,
        types: "address,place,locality",
      });

      if (containerRef.current) {
        geocoder.addTo(containerRef.current);
      }

      geocoder.on("result", (e: any) => {
        const lng = e.result.center[0];
        const lat = e.result.center[1];
        const distance = haversineKm(
          freelancer.latitude ?? 0,
          freelancer.longitude ?? 0,
          lat, lng,
        );
        if (distance > (freelancer.travel_radius_km ?? 0)) {
          setError(
            `${distance.toFixed(1)}km from ${freelancer.name} (max ${freelancer.travel_radius_km}km)`,
          );
          onChange(null, distance);
        } else {
          setError(null);
          onChange({ text: e.result.place_name, lat, lng }, distance);
        }
      });

      geocoder.on("clear", () => {
        setError(null);
        onChange(null, null);
      });
    }
    init();
    return () => {
      if (geocoder && typeof geocoder.clear === "function") geocoder.clear();
    };
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  return (
    <section className="px-4 pt-3">
      <h2 className="text-xs uppercase tracking-wide text-slate-500 mb-2 font-medium">
        Where should they come?
      </h2>
      <div
        ref={containerRef}
        className="[&_.mapboxgl-ctrl-geocoder]:!w-full [&_.mapboxgl-ctrl-geocoder]:!max-w-none [&_.mapboxgl-ctrl-geocoder]:!shadow-none [&_.mapboxgl-ctrl-geocoder]:!border [&_.mapboxgl-ctrl-geocoder]:!border-slate-200 [&_.mapboxgl-ctrl-geocoder]:!rounded-lg [&_.mapboxgl-ctrl-geocoder_input]:!h-11"
      />
      <link
        rel="stylesheet"
        href="https://api.mapbox.com/mapbox-gl-js/plugins/mapbox-gl-geocoder/v5.0.0/mapbox-gl-geocoder.css"
      />
      {error && (
        <p className="text-xs text-red-600 mt-2">{error}</p>
      )}
    </section>
  );
}

function haversineKm(lat1: number, lng1: number, lat2: number, lng2: number): number {
  const R = 6371;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLng = (lng2 - lng1) * Math.PI / 180;
  const a = Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(a));
}
```

- [ ] **Step 3: Wire AddressPicker into BookingFlow for freelancers**

Modify `aura-in-web/app/book/[slug]/components/BookingFlow.tsx`. Add state for the picked address:

```typescript
const [address, setAddress] = useState<PickedAddress | null>(null);
```

(add `import type { PickedAddress }` or inline the type)

Conditionally render the AddressPicker section between SlotPicker and GuestForm (for freelancers who can travel):

```tsx
{data.targetType === "freelancer" && (data.target as FreelancerTarget).can_travel && (
  <AddressPicker
    freelancer={data.target as FreelancerTarget}
    onChange={(addr) => setAddress(addr)}
  />
)}
```

Update `canSubmit` to require address for freelancers with canTravel:

```typescript
const needsAddress = data.targetType === "freelancer" && (data.target as FreelancerTarget).can_travel;
const canSubmit = selectedService && selectedSlot && name && phone && (!needsAddress || address);
```

In `handleSubmit`, pass the address fields to createBooking:

```typescript
clientAddress: address?.text,
clientAddressLat: address?.lat,
clientAddressLng: address?.lng,
```

- [ ] **Step 4: Smoke-test with a freelancer slug**

```bash
cd aura-in-web
npm run dev
```

Visit http://localhost:3000/book/<freelancer-slug-with-canTravel>. Verify the address picker shows, typing yields suggestions, picking one in-radius enables CTA, picking one out-of-radius blocks it with the distance message.

- [ ] **Step 5: Commit**

```bash
git add aura-in-web/
git commit -m "feat(aura-in-web): freelancer address picker via Mapbox geocoder

Conditionally renders AddressPicker between SlotPicker and GuestForm
when targetType=freelancer + canTravel. Mapbox geocoder is dynamically
imported so the bundle cost is paid only on freelancer pages.
Picked address is haversine-distance-checked against travel_radius_km
before the CTA enables."
```

---

## Task 6: /book/[slug]/success page with reference polling

**Files:**
- Create: `aura-in-web/app/book/[slug]/success/page.tsx`

**Why:** Paystack/Stripe redirect here after payment. Need to wait for the webhook to insert the booking row, then show the success state.

---

- [ ] **Step 1: Write the success page**

Create `aura-in-web/app/book/[slug]/success/page.tsx`:

```tsx
// aura-in-web/app/book/[slug]/success/page.tsx
//
// After Paystack/Stripe redirects here, polls bookings by payment_intent_id
// every 2s for up to 60s. Renders the success state once status='confirmed'.
// After 60s, renders a graceful fallback ("processing — WhatsApp incoming").

import { fetchBookingByReference } from "@/lib/api";
import { redirect } from "next/navigation";

interface Props {
  params: { slug: string };
  searchParams: { reference?: string };
}

const POLL_TIMEOUT_MS = 60_000;
const POLL_INTERVAL_MS = 2_000;

async function pollForBooking(reference: string) {
  const deadline = Date.now() + POLL_TIMEOUT_MS;
  while (Date.now() < deadline) {
    const booking = await fetchBookingByReference(reference);
    if (booking) return booking;
    await new Promise(r => setTimeout(r, POLL_INTERVAL_MS));
  }
  return null;
}

export default async function SuccessPage({ params, searchParams }: Props) {
  const reference = searchParams.reference;
  if (!reference) redirect(`/book/${params.slug}`);

  const booking = await pollForBooking(reference);

  if (booking) {
    return (
      <main className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
        <div className="bg-white rounded-2xl shadow-sm border border-slate-200 max-w-md w-full p-6 text-center">
          <div className="w-14 h-14 mx-auto rounded-full bg-emerald-100 flex items-center justify-center mb-4">
            <span className="text-emerald-600 text-3xl">✓</span>
          </div>
          <h1 className="text-xl font-semibold text-slate-900 mb-2">Booking confirmed</h1>
          <p className="text-sm text-slate-500 mb-6">
            We&apos;ll send you a WhatsApp message with the details shortly.
          </p>
          <p className="text-xs text-slate-400">
            Reference: {booking.id.slice(0, 8)}
          </p>
        </div>
      </main>
    );
  }

  // Webhook didn't fire within 60s — graceful fallback.
  return (
    <main className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-sm border border-slate-200 max-w-md w-full p-6 text-center">
        <div className="w-14 h-14 mx-auto rounded-full bg-amber-100 flex items-center justify-center mb-4">
          <span className="text-amber-600 text-2xl">⏳</span>
        </div>
        <h1 className="text-lg font-semibold text-slate-900 mb-2">
          Payment is processing
        </h1>
        <p className="text-sm text-slate-500">
          Your payment was received but the booking is taking longer than usual
          to confirm. We&apos;ll send a WhatsApp message as soon as it&apos;s
          confirmed — you can safely close this page.
        </p>
      </div>
    </main>
  );
}

// Disable static generation — this page is dynamic per request.
export const dynamic = "force-dynamic";
```

- [ ] **Step 2: Smoke-test by completing a real booking**

Make a real test booking via the /book/<slug> page. After Paystack redirects, the success page should poll and (within ~10s typically) show the green check + "Booking confirmed".

- [ ] **Step 3: Commit**

```bash
git add aura-in-web/app/book/[slug]/success/
git commit -m "feat(aura-in-web): /book/[slug]/success polls bookings by reference

After Paystack/Stripe redirect, polls bookings table every 2s for up
to 60s via the Supabase REST API. Success state on row found; graceful
'processing' fallback if not confirmed within 60s (WhatsApp message
will still arrive when the webhook eventually fires)."
```

---

## Task 7: Error page + Vercel deploy

**Files:**
- Create: `aura-in-web/app/book/[slug]/error/page.tsx`
- Create: `aura-in-web/app/not-found.tsx`
- Modify: Vercel project config + custom domain

---

- [ ] **Step 1: Write the booking-flow error page**

Create `aura-in-web/app/book/[slug]/error/page.tsx`:

```tsx
"use client";

export default function ErrorPage({
  error, reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <main className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-sm border border-slate-200 max-w-md w-full p-6 text-center">
        <h1 className="text-lg font-semibold text-slate-900 mb-2">
          Something went wrong
        </h1>
        <p className="text-sm text-slate-500 mb-4">
          We couldn&apos;t finish setting up your booking. Please try again.
        </p>
        <button
          type="button"
          onClick={reset}
          className="bg-emerald-600 text-white font-medium px-4 py-2 rounded-lg"
        >
          Try again
        </button>
      </div>
    </main>
  );
}
```

- [ ] **Step 2: Write the 404 page**

Create `aura-in-web/app/not-found.tsx`:

```tsx
import Link from "next/link";

export default function NotFound() {
  return (
    <main className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
      <div className="text-center max-w-sm">
        <h1 className="text-2xl font-semibold text-slate-900 mb-2">
          Link not found
        </h1>
        <p className="text-sm text-slate-500 mb-6">
          This booking link doesn&apos;t exist or has expired. Ask the shop
          owner for a fresh link.
        </p>
        <Link
          href="/"
          className="text-emerald-600 text-sm font-medium underline"
        >
          Go to Aura-In home
        </Link>
      </div>
    </main>
  );
}
```

- [ ] **Step 3: Build locally to catch issues**

```bash
cd aura-in-web
npm run build
```

Expected: build succeeds with no type errors. Note any warnings — for v1 it's OK if there are warnings about dynamic rendering on `/book/[slug]` and `/success` (both are intentional).

- [ ] **Step 4: Deploy to Vercel**

```bash
# From aura-in-web/:
npx vercel deploy --prod
```

Follow prompts:
- Link to project? **Yes** (or create new if first time)
- Project name: **aura-in-web**

Set environment variables in Vercel dashboard:
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `NEXT_PUBLIC_MAPBOX_TOKEN`

- [ ] **Step 5: Verify the custom domain**

If `aura-in-web.vercel.app` isn't the default URL, add it in Vercel → Project → Settings → Domains.

- [ ] **Step 6: Production smoke test**

Visit `https://aura-in-web.vercel.app/book/<a-real-slug>` from your phone on cellular (not Wi-Fi). Complete a real booking with Paystack test cards. Verify:
- Page paints in <3s
- Booking submits, redirects to Paystack
- After paying, lands on success page
- Within 10s, success page shows "Booking confirmed"

- [ ] **Step 7: Run Lighthouse for performance verification**

In Chrome DevTools → Lighthouse → Mobile + Slow 4G:

Run on `https://aura-in-web.vercel.app/book/<a-real-slug>`.

Expected:
- Performance score ≥ 90
- First Contentful Paint < 2s
- Largest Contentful Paint < 3s

If LCP > 3s, the slow culprit is likely an unoptimized hero image. Switch to Next.js `<Image>` component with `priority` (or remove the image for v1).

- [ ] **Step 8: Commit**

```bash
git add aura-in-web/app/
git commit -m "feat(aura-in-web): error + 404 pages, prod deploy

Error page (per-route) and not-found.tsx for clear user feedback on
broken slugs / server errors. Production deployed at aura-in-web.vercel.app.
Lighthouse verified: FCP <2s, LCP <3s on Mobile Slow 4G profile."
```

---

## Verification (after Task 7)

1. **`npm run build` in `aura-in-web/`** — succeeds with no type errors
2. **Visit production URL with a real slug** — booking page renders correctly server-side
3. **Lighthouse Mobile Slow 4G** — Performance ≥ 90, FCP <2s, LCP <3s
4. **Complete a real Paystack test payment** — redirected to /success, sees confirmed state within 10s
5. **Visit `/book/nonexistent-slug`** — Next.js 404 page renders correctly

Plan B is shippable when those five checks pass. End-to-end booking flow works via browser; only WhatsApp messages + Universal Links + mobile slug UI remain (Plan C).
