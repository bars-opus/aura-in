// aura-in-web/app/booking/[id]/page.tsx
//
// Public booking-detail page reachable from the WhatsApp confirmation link.
// Renders the shop hero, the booking time window, the per-service breakdown,
// and the payment summary. Phone is server-redacted before reaching here.
//
// Server component — fetches the booking on the server, returns notFound()
// for unknown IDs so the existing /not-found page is shown.

import { fetchBookingDetail, fetchBookingReview } from "@/lib/api";
import { notFound } from "next/navigation";
import Link from "next/link";
import { formatMoney } from "@/lib/format";

interface Props {
  params: Promise<{ id: string }>;
}

export const dynamic = "force-dynamic";

export async function generateMetadata({ params }: Props) {
  const { id } = await params;
  const data = await fetchBookingDetail(id);
  if (!data) return { title: "Booking not found" };
  const shopName = data.shop?.name ?? "Booking";
  return {
    title: `${shopName} — booking confirmed`,
    description: `Booking at ${shopName} on ${formatDateTime(data.start_time)}.`,
  };
}

export default async function BookingDetailPage({ params }: Props) {
  const { id } = await params;
  const [data, review] = await Promise.all([
    fetchBookingDetail(id),
    fetchBookingReview(id),
  ]);
  if (!data) notFound();

  const remaining = data.total_amount - data.deposit_amount;
  // Pick a sensible currency display. We don't have the currency on the
  // RPC payload — default to GHS for v1 (Africa-first); revisit when we
  // ship multi-currency surfaces.
  const currency = "GHS";

  return (
    <main className="min-h-screen bg-slate-50 pb-20">
      <header className="bg-white border-b border-slate-200 px-4 py-5">
        <div className="max-w-md mx-auto">
          <div className="flex items-center gap-3">
            {data.shop?.logo_url ? (
              <img
                src={data.shop.logo_url}
                alt={data.shop.name}
                className="w-12 h-12 rounded-lg object-cover bg-slate-100"
              />
            ) : (
              <div className="w-12 h-12 rounded-lg bg-slate-100 flex items-center justify-center text-slate-400 text-lg">
                {(data.shop?.name?.[0] ?? "?").toUpperCase()}
              </div>
            )}
            <div className="flex-1 min-w-0">
              <h1 className="text-base font-semibold text-slate-900 truncate">
                {data.shop?.name ?? "Booking"}
              </h1>
              {data.shop?.type && (
                <p className="text-xs text-slate-500 truncate">{data.shop.type}</p>
              )}
            </div>
            <span className="inline-flex items-center gap-1 bg-emerald-50 text-emerald-700 text-xs font-medium px-2 py-1 rounded-full">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
              Confirmed
            </span>
          </div>
        </div>
      </header>

      <section className="max-w-md mx-auto px-4 pt-5">
        <div className="bg-white rounded-xl border border-slate-200 p-4">
          <h2 className="text-xs uppercase tracking-wide text-slate-500 mb-3 font-medium">
            When
          </h2>
          <p className="text-base text-slate-900 font-medium">
            {formatDateTime(data.start_time)}
          </p>
          {data.end_time && (
            <p className="text-xs text-slate-500 mt-0.5">
              Ends at {formatTime(data.end_time)}
            </p>
          )}
        </div>
      </section>

      <section className="max-w-md mx-auto px-4 pt-3">
        <div className="bg-white rounded-xl border border-slate-200 p-4">
          <h2 className="text-xs uppercase tracking-wide text-slate-500 mb-3 font-medium">
            Where
          </h2>
          <p className="text-sm text-slate-900">
            {data.client_address ?? data.shop?.address ?? "—"}
          </p>
          {(() => {
            // Maps link: prefer coords (precise pin), fall back to a
            // text search over the address. Works in Google Maps + iOS
            // routes through to Apple Maps via the universal handoff.
            const lat = data.shop?.latitude;
            const lng = data.shop?.longitude;
            const addr = data.client_address ?? data.shop?.address;
            const mapsUrl =
              lat != null && lng != null
                ? `https://www.google.com/maps/search/?api=1&query=${lat},${lng}`
                : addr
                ? `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(addr)}`
                : null;
            if (!mapsUrl) return null;
            return (
              <a
                href={mapsUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="mt-3 inline-flex items-center gap-1.5 text-sm font-medium text-sky-600 hover:text-sky-700"
              >
                <span aria-hidden>📍</span>
                Open in Maps
              </a>
            );
          })()}
        </div>
      </section>

      {/* Contact the shop. Phone uses tel: (native dialer); WhatsApp
          uses wa.me which opens the right app on every platform. Both
          buttons hidden when the shop hasn't published a contact yet. */}
      {(data.shop?.phone || data.shop?.whatsapp) && (
        <section className="max-w-md mx-auto px-4 pt-3">
          <div className="bg-white rounded-xl border border-slate-200 p-4">
            <h2 className="text-xs uppercase tracking-wide text-slate-500 mb-3 font-medium">
              Contact {data.shop?.name ?? "the shop"}
            </h2>
            <div className="flex flex-col gap-2">
              {data.shop?.phone && (
                <a
                  href={`tel:${data.shop.phone}`}
                  className="flex items-center justify-between bg-slate-50 border border-slate-200 rounded-lg px-3 py-2.5 text-sm text-slate-900 hover:bg-slate-100"
                >
                  <span className="flex items-center gap-2">
                    <span aria-hidden>📞</span>
                    Call
                  </span>
                  <span className="text-slate-500 tabular-nums">
                    {data.shop.phone}
                  </span>
                </a>
              )}
              {data.shop?.whatsapp && (
                <a
                  href={`https://wa.me/${data.shop.whatsapp.replace(/[^\d]/g, "")}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center justify-between bg-emerald-50 border border-emerald-200 rounded-lg px-3 py-2.5 text-sm text-emerald-900 hover:bg-emerald-100"
                >
                  <span className="flex items-center gap-2">
                    <span aria-hidden>💬</span>
                    WhatsApp
                  </span>
                  <span className="text-emerald-700 tabular-nums">
                    {data.shop.whatsapp}
                  </span>
                </a>
              )}
            </div>
          </div>
        </section>
      )}

      {data.services.length > 0 && (
        <section className="max-w-md mx-auto px-4 pt-3">
          <div className="bg-white rounded-xl border border-slate-200 p-4">
            <h2 className="text-xs uppercase tracking-wide text-slate-500 mb-3 font-medium">
              Services
            </h2>
            <ul className="divide-y divide-slate-100">
              {data.services.map((svc, i) => (
                <li key={i} className="py-2.5 first:pt-0 last:pb-0">
                  <div className="flex items-baseline justify-between gap-3">
                    <div className="min-w-0">
                      <p className="text-sm text-slate-900 font-medium truncate">
                        {svc.name}
                      </p>
                      <p className="text-xs text-slate-500">
                        {svc.duration_minutes} min
                        {svc.worker_name ? ` · with ${svc.worker_name}` : ""}
                      </p>
                    </div>
                    <span className="text-sm text-slate-700 tabular-nums">
                      {formatMoney(svc.price, currency)}
                    </span>
                  </div>
                </li>
              ))}
            </ul>
          </div>
        </section>
      )}

      <section className="max-w-md mx-auto px-4 pt-3">
        <div className="bg-white rounded-xl border border-slate-200 p-4">
          <h2 className="text-xs uppercase tracking-wide text-slate-500 mb-3 font-medium">
            Payment
          </h2>
          <dl className="space-y-1.5">
            <Row label="Total" value={formatMoney(data.total_amount, currency)} />
            <Row label="Deposit paid" value={formatMoney(data.deposit_amount, currency)} />
            <Row
              label="Remaining (at shop)"
              value={formatMoney(remaining, currency)}
              emphasize
            />
          </dl>
        </div>
      </section>

      {(data.guest_name || data.guest_phone_masked) && (
        <section className="max-w-md mx-auto px-4 pt-3">
          <div className="bg-white rounded-xl border border-slate-200 p-4">
            <h2 className="text-xs uppercase tracking-wide text-slate-500 mb-3 font-medium">
              Guest
            </h2>
            {data.guest_name && (
              <p className="text-sm text-slate-900">{data.guest_name}</p>
            )}
            {data.guest_phone_masked && (
              <p className="text-xs text-slate-500 mt-0.5">{data.guest_phone_masked}</p>
            )}
          </div>
        </section>
      )}

      {/* Review section mirrors the in-app RatingSection: shows the
          existing review when one exists, or a CTA to write one when
          the booking is completed. Pre-completion this section is
          hidden — clients shouldn't review what hasn't happened. */}
      {review ? (
        <section className="max-w-md mx-auto px-4 pt-3">
          <div className="bg-white rounded-xl border border-slate-200 p-4">
            <h2 className="text-xs uppercase tracking-wide text-slate-500 mb-2 font-medium">
              Your review
            </h2>
            <div className="flex items-center gap-1" aria-label={`${review.rating} out of 5 stars`}>
              {[1, 2, 3, 4, 5].map((i) => (
                <span
                  key={i}
                  className={
                    i <= review.rating
                      ? "text-amber-400 text-lg leading-none"
                      : "text-slate-200 text-lg leading-none"
                  }
                >
                  ★
                </span>
              ))}
            </div>
            {review.review && (
              <p className="mt-2 text-sm text-slate-700 whitespace-pre-wrap">
                {review.review}
              </p>
            )}
          </div>
        </section>
      ) : data.status === "completed" ? (
        <section className="max-w-md mx-auto px-4 pt-3">
          <Link
            href={`/r/${data.id}`}
            className="block bg-slate-900 text-white text-sm font-medium rounded-xl py-3 text-center"
          >
            ★ Rate your visit
          </Link>
        </section>
      ) : null}

      <p className="max-w-md mx-auto px-4 pt-6 text-xs text-slate-400 text-center">
        Reference: {data.id.slice(0, 8)}
      </p>
    </main>
  );
}

function Row({
  label,
  value,
  emphasize,
}: {
  label: string;
  value: string;
  emphasize?: boolean;
}) {
  return (
    <div className="flex items-baseline justify-between">
      <dt className="text-sm text-slate-500">{label}</dt>
      <dd
        className={
          emphasize
            ? "text-sm text-slate-900 font-semibold tabular-nums"
            : "text-sm text-slate-700 tabular-nums"
        }
      >
        {value}
      </dd>
    </div>
  );
}

// Local formatters — the existing format.ts helpers are tailored to the
// /book flow's needs; these handle the booking-detail surface.
function formatDateTime(iso: string): string {
  const d = new Date(iso);
  return d.toLocaleString("en-GB", {
    weekday: "short",
    day: "numeric",
    month: "short",
    hour: "numeric",
    minute: "2-digit",
    hour12: true,
  });
}

function formatTime(iso: string): string {
  return new Date(iso).toLocaleTimeString("en-GB", {
    hour: "numeric",
    minute: "2-digit",
    hour12: true,
  });
}
