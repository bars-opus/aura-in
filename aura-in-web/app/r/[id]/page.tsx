// aura-in-web/app/r/[id]/page.tsx
//
// Public review page reachable from the WhatsApp review prompt (template
// booking_review_prompt_v1 sends https://aurain.barsopus.com/r/<bookingId>).
// Server-fetches the booking + any existing review, then renders the
// ReviewForm client component for submission. Visually mirrors the
// in-app RatingSection.

import { fetchBookingDetail, fetchBookingReview } from "@/lib/api";
import { notFound } from "next/navigation";
import { ReviewForm } from "./review-form";

interface Props {
  params: Promise<{ id: string }>;
}

export const dynamic = "force-dynamic";

export async function generateMetadata({ params }: Props) {
  const { id } = await params;
  const data = await fetchBookingDetail(id);
  return {
    title: data?.shop?.name
      ? `Rate your visit to ${data.shop.name}`
      : "Rate your booking",
  };
}

export default async function ReviewPage({ params }: Props) {
  const { id } = await params;
  const [booking, existing] = await Promise.all([
    fetchBookingDetail(id),
    fetchBookingReview(id),
  ]);
  if (!booking) notFound();

  return (
    <main className="min-h-screen bg-slate-50 pb-20">
      <header className="bg-white border-b border-slate-200 px-4 py-5">
        <div className="max-w-md mx-auto flex items-center gap-3">
          {booking.shop?.logo_url ? (
            <img
              src={booking.shop.logo_url}
              alt={booking.shop.name}
              className="w-12 h-12 rounded-lg object-cover bg-slate-100"
            />
          ) : (
            <div className="w-12 h-12 rounded-lg bg-slate-100 flex items-center justify-center text-slate-400 text-lg">
              {(booking.shop?.name?.[0] ?? "?").toUpperCase()}
            </div>
          )}
          <div className="flex-1 min-w-0">
            <h1 className="text-base font-semibold text-slate-900 truncate">
              {booking.shop?.name ?? "Your booking"}
            </h1>
            <p className="text-xs text-slate-500 truncate">
              {existing
                ? "Thanks for sharing your experience"
                : "How was your experience?"}
            </p>
          </div>
        </div>
      </header>

      <section className="max-w-md mx-auto px-4 pt-5">
        {existing ? (
          <ExistingReview
            rating={existing.rating}
            review={existing.review}
            shopResponse={existing.shop_response}
          />
        ) : (
          <ReviewForm
            bookingId={booking.id}
            shopName={booking.shop?.name ?? "this shop"}
          />
        )}
      </section>
    </main>
  );
}

function ExistingReview({
  rating,
  review,
  shopResponse,
}: {
  rating: number;
  review: string | null;
  shopResponse: string | null | undefined;
}) {
  return (
    <div className="bg-white rounded-xl border border-slate-200 p-5">
      <Stars value={rating} />
      {review && (
        <p className="mt-3 text-sm text-slate-700 whitespace-pre-wrap">
          {review}
        </p>
      )}
      {shopResponse && (
        <div className="mt-4 bg-slate-50 rounded-lg p-3 border border-slate-100">
          <p className="text-xs uppercase tracking-wide text-slate-500 mb-1">
            Shop response
          </p>
          <p className="text-sm text-slate-700 whitespace-pre-wrap">
            {shopResponse}
          </p>
        </div>
      )}
      <p className="mt-4 text-xs text-slate-400">
        Thanks for the feedback — it helps other clients find great shops.
      </p>
    </div>
  );
}

function Stars({ value }: { value: number }) {
  return (
    <div className="flex items-center gap-1" aria-label={`${value} out of 5 stars`}>
      {[1, 2, 3, 4, 5].map((i) => (
        <span
          key={i}
          className={
            i <= value
              ? "text-amber-400 text-2xl leading-none"
              : "text-slate-200 text-2xl leading-none"
          }
        >
          ★
        </span>
      ))}
    </div>
  );
}
