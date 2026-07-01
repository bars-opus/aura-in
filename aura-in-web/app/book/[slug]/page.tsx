// aura-in-web/app/book/[slug]/page.tsx
//
// Server component. Resolves the slug, fetches shop/freelancer + services +
// workers + slots from Plan A's resolve-link edge function, renders the page
// server-side for fast first paint. Interactive client components (slot
// picker, form) receive the data as props.
//
// Next 16: params is a Promise — must await it.

import { resolveLink } from "@/lib/api";
import { ShopHero } from "./components/ShopHero";
import { FreelancerHero } from "./components/FreelancerHero";
import { BookingFlow } from "./components/BookingFlow";
import { notFound } from "next/navigation";
import type { Metadata } from "next";

interface Props {
  params: Promise<{ slug: string }>;
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const data = await resolveLink(slug);
  if (!data) {
    return { title: "Booking link not found · Aura-In" };
  }
  const title = `Book at ${data.target.name} · Aura-In`;
  const overview = data.target.overview?.trim() ?? "";
  const description = overview.length > 0
    ? overview
    : `Book your appointment at ${data.target.name}. Pay deposit, get WhatsApp confirmation.`;
  // Preview image for WhatsApp / social: the shop's own logo when it has one,
  // otherwise the Aura-In mark. og:image must be an absolute URL.
  const image = data.target.logoUrl ?? "/og-default.png";
  return {
    title,
    description,
    openGraph: {
      title,
      description,
      type: "website",
      siteName: "Aura-In",
      images: [{ url: image }],
    },
    twitter: {
      card: "summary",
      title,
      description,
      images: [image],
    },
  };
}

export default async function BookingPage({ params }: Props) {
  const { slug } = await params;
  const data = await resolveLink(slug);

  if (!data) notFound();

  return (
    <main className="min-h-screen bg-slate-50 pb-40">
      <div className="max-w-md mx-auto pb-2">
        {data.targetType === "shop"
          ? <ShopHero target={data.target} slug={slug} />
          : <FreelancerHero target={data.target} slug={slug} />}

        <BookingFlow data={data} slug={slug} />
      </div>
    </main>
  );
}
