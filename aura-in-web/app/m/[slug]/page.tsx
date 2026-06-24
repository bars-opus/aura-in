// aura-in-web/app/m/[slug]/page.tsx
//
// Public shop-products page. Server-fetches the shop + product grid via
// resolve-products-link, then renders the ShopProductsFlow client
// component which owns cart state + checkout. notFound() for unknown
// slugs so /not-found takes over.

import { resolveProductsLink } from "@/lib/api";
import { notFound } from "next/navigation";
import { ShopProductsFlow } from "./components/ShopProductsFlow";

interface Props {
  params: Promise<{ slug: string }>;
}

export const dynamic = "force-dynamic";

export async function generateMetadata({ params }: Props) {
  const { slug } = await params;
  const data = await resolveProductsLink(slug);
  if (!data) return { title: "Shop not found" };
  return {
    title: `${data.shop.name} — order online`,
    description: `Browse and order from ${data.shop.name}. Pay on delivery.`,
  };
}

export default async function ShopProductsPage({ params }: Props) {
  const { slug } = await params;
  const data = await resolveProductsLink(slug);
  if (!data) notFound();

  return <ShopProductsFlow data={data} />;
}
