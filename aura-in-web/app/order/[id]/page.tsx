// aura-in-web/app/order/[id]/page.tsx
//
// Public order tracking page reachable from the WhatsApp order_received /
// order_confirmed / etc. messages. Mirrors /booking/[id]: shop hero,
// status timeline, items breakdown, contact actions, and a "Rate this
// order" CTA when the order is delivered.
//
// Server component; force-dynamic so a status update reflects on refresh.

import { fetchOrderDetail } from "@/lib/api";
import { notFound } from "next/navigation";
import { formatMoney } from "@/lib/format";

interface Props {
  params: Promise<{ id: string }>;
}

export const dynamic = "force-dynamic";

const STATUS_STEPS: Array<{
  key: string;
  label: string;
  hint: string;
}> = [
  { key: "pending_confirmation", label: "Received",  hint: "Waiting for the shop to confirm." },
  { key: "confirmed",            label: "Confirmed", hint: "Shop is preparing your order." },
  { key: "out_for_delivery",     label: "On the way", hint: "Driver is on the way." },
  { key: "delivered",            label: "Delivered", hint: "Order delivered." },
];

export async function generateMetadata({ params }: Props) {
  const { id } = await params;
  const data = await fetchOrderDetail(id);
  if (!data) return { title: "Order not found" };
  return {
    title: `Order — ${data.shop?.name ?? "Aura-In"}`,
  };
}

export default async function OrderDetailPage({ params }: Props) {
  const { id } = await params;
  const data = await fetchOrderDetail(id);
  if (!data) notFound();

  const currency = data.currency ?? data.shop?.currency ?? "GHS";
  const isCancelled = data.status === "cancelled";
  const stepIndex = STATUS_STEPS.findIndex((s) => s.key === data.status);

  return (
    <main className="min-h-screen bg-slate-50 pb-20">
      <header className="bg-white border-b border-slate-200 px-4 py-5">
        <div className="max-w-md mx-auto flex items-center gap-3">
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
              {data.shop?.name ?? "Order"}
            </h1>
            <p className="text-xs text-slate-500">
              {currentLabel(data.status)} · {formatMoney(data.total_amount, currency)}
            </p>
          </div>
        </div>
      </header>

      {/* Status timeline. Cancelled is its own visual state — collapse the
          stepper into a single banner so we don't suggest forward progress
          that isn't going to happen. */}
      <section className="max-w-md mx-auto px-4 pt-5">
        {isCancelled ? (
          <div className="bg-red-50 border border-red-200 rounded-xl p-4 text-sm text-red-800">
            Order cancelled
            {data.shop_notes && (
              <p className="text-xs text-red-700 mt-1">{data.shop_notes}</p>
            )}
          </div>
        ) : (
          <div className="bg-white rounded-xl border border-slate-200 p-4">
            <h2 className="text-xs uppercase tracking-wide text-slate-500 mb-3 font-medium">
              Status
            </h2>
            <ol className="space-y-3">
              {STATUS_STEPS.map((s, i) => {
                const done   = i <  stepIndex;
                const active = i === stepIndex;
                return (
                  <li key={s.key} className="flex items-start gap-3">
                    <div
                      className={
                        "mt-0.5 w-4 h-4 rounded-full border-2 flex-shrink-0 " +
                        (done
                          ? "bg-emerald-500 border-emerald-500"
                          : active
                          ? "bg-amber-400 border-amber-400 animate-pulse"
                          : "bg-white border-slate-300")
                      }
                    />
                    <div className="min-w-0">
                      <p
                        className={
                          "text-sm " +
                          (done || active
                            ? "text-slate-900 font-medium"
                            : "text-slate-400")
                        }
                      >
                        {s.label}
                      </p>
                      {active && (
                        <p className="text-xs text-slate-500">{s.hint}</p>
                      )}
                    </div>
                  </li>
                );
              })}
            </ol>
          </div>
        )}
      </section>

      <section className="max-w-md mx-auto px-4 pt-3">
        <div className="bg-white rounded-xl border border-slate-200 p-4">
          <h2 className="text-xs uppercase tracking-wide text-slate-500 mb-3 font-medium">
            Delivery to
          </h2>
          <p className="text-sm text-slate-900">{data.delivery_address}</p>
          {data.customer_phone_masked && (
            <p className="text-xs text-slate-500 mt-1">{data.customer_phone_masked}</p>
          )}
          {data.customer_notes && (
            <p className="text-xs text-slate-500 mt-2">Note: {data.customer_notes}</p>
          )}
        </div>
      </section>

      <section className="max-w-md mx-auto px-4 pt-3">
        <div className="bg-white rounded-xl border border-slate-200 p-4">
          <h2 className="text-xs uppercase tracking-wide text-slate-500 mb-3 font-medium">
            Items
          </h2>
          <ul className="divide-y divide-slate-100">
            {data.items.map((it) => (
              <li key={it.product_id} className="flex items-center gap-3 py-2.5">
                {it.image && (
                  <img
                    src={it.image}
                    alt={it.name ?? "Product"}
                    className="w-10 h-10 rounded object-cover bg-slate-100 flex-shrink-0"
                  />
                )}
                <div className="flex-1 min-w-0">
                  <p className="text-sm text-slate-900 truncate">
                    {it.name ?? "Product"}
                  </p>
                  <p className="text-xs text-slate-500">
                    {it.quantity} × {formatMoney(Number(it.unit_price), currency)}
                  </p>
                </div>
                <span className="text-sm text-slate-700 tabular-nums">
                  {formatMoney(Number(it.subtotal), currency)}
                </span>
              </li>
            ))}
          </ul>
          <div className="mt-3 flex items-center justify-between text-sm font-semibold pt-3 border-t border-slate-100">
            <span>Total (pay on delivery)</span>
            <span className="tabular-nums">{formatMoney(data.total_amount, currency)}</span>
          </div>
        </div>
      </section>

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
                  <span className="flex items-center gap-2"><span aria-hidden>📞</span>Call</span>
                  <span className="text-slate-500 tabular-nums">{data.shop.phone}</span>
                </a>
              )}
              {data.shop?.whatsapp && (
                <a
                  href={`https://wa.me/${data.shop.whatsapp.replace(/[^\d]/g, "")}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center justify-between bg-emerald-50 border border-emerald-200 rounded-lg px-3 py-2.5 text-sm text-emerald-900 hover:bg-emerald-100"
                >
                  <span className="flex items-center gap-2"><span aria-hidden>💬</span>WhatsApp</span>
                  <span className="text-emerald-700 tabular-nums">{data.shop.whatsapp}</span>
                </a>
              )}
            </div>
          </div>
        </section>
      )}

      <p className="max-w-md mx-auto px-4 pt-6 text-xs text-slate-400 text-center">
        Reference: {data.id.slice(0, 8)}
      </p>
    </main>
  );
}

function currentLabel(status: string): string {
  switch (status) {
    case "pending_confirmation": return "Awaiting confirmation";
    case "confirmed":            return "Confirmed";
    case "out_for_delivery":     return "On the way";
    case "delivered":            return "Delivered";
    case "cancelled":            return "Cancelled";
    case "disputed":             return "Disputed";
    default:                     return status;
  }
}
