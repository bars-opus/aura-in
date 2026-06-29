// aura-in-web/app/book/[slug]/components/ServicePicker.tsx
//
// Step 1 of the booking flow. Vertical list of services with price +
// duration. When the visitor is a returning guest (lookup-guest matched
// their phone), the service they last booked gets a "Booked last time"
// pill so they can re-book in one tap.
"use client";

import type { Service } from "@/lib/types";
import { formatDuration, formatMoneyMinor } from "@/lib/format";

export function ServicePicker({
  services,
  currency,
  selectedIds,
  lastBookedServiceName,
  onToggle,
}: {
  services: Service[];
  currency: string | null;
  selectedIds: string[];
  lastBookedServiceName?: string;
  onToggle: (id: string) => void;
}) {
  return (
    <section className="px-4 pt-4">
      <h2 className="text-xs uppercase tracking-wide text-slate-500 mb-2 font-medium">
        1. Services{" "}
        <span className="normal-case text-slate-400">(select one or more)</span>
      </h2>
      <div className="space-y-2">
        {services.map((svc) => {
          const selected = selectedIds.includes(svc.id);
          const isLast =
            lastBookedServiceName && svc.name === lastBookedServiceName;
          return (
            <button
              key={svc.id}
              type="button"
              onClick={() => onToggle(svc.id)}
              className={`w-full text-left bg-white rounded-lg p-3 flex justify-between items-start border ${
                selected
                  ? "border-brand-500 ring-1 ring-brand-500"
                  : "border-slate-200"
              }`}
            >
              <div className="min-w-0 pr-3 flex items-start gap-3">
                <span
                  className={`mt-0.5 flex h-5 w-5 shrink-0 items-center justify-center rounded border ${
                    selected
                      ? "bg-brand-500 border-brand-500 text-white"
                      : "border-slate-300"
                  }`}
                  aria-hidden
                >
                  {selected && (
                    <svg viewBox="0 0 16 16" className="h-3.5 w-3.5 fill-current">
                      <path d="M6.5 11.5L3 8l1-1 2.5 2.5L12 4l1 1z" />
                    </svg>
                  )}
                </span>
                <div className="min-w-0">
                <div className="font-medium text-slate-900 flex items-center gap-2">
                  {svc.name}
                  {isLast && (
                    <span className="text-[10px] uppercase tracking-wide bg-brand-50 text-brand-700 px-1.5 py-0.5 rounded">
                      Booked last time
                    </span>
                  )}
                </div>
                {svc.description && (
                  <div className="text-xs text-slate-500 mt-1 line-clamp-3">
                    {svc.description}
                  </div>
                )}
                <div className="text-xs text-slate-500 mt-1 flex items-center gap-3">
                  <span>{formatDuration(svc.durationMinutes)}</span>
                  {svc.maxClients > 1 && (
                    <span>Up to {svc.maxClients} clients</span>
                  )}
                </div>
                </div>
              </div>
              <div
                className={`font-semibold shrink-0 ${
                  selected ? "text-brand-600" : "text-slate-700"
                }`}
              >
                {formatMoneyMinor(svc.priceMinor, currency)}
              </div>
            </button>
          );
        })}
      </div>
    </section>
  );
}
