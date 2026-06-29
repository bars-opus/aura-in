// aura-in-web/app/book/[slug]/components/AddonPicker.tsx
//
// Optional step shown only when the selected service has add-ons. Mirrors the
// app's ServiceAddonsSheet: multi-select extras that add to the price and the
// appointment duration. Toggling is folded into the booking total + duration
// by BookingFlow.
"use client";

import type { Addon } from "@/lib/types";
import { formatMoneyMinor } from "@/lib/format";
import { SectionCard } from "./SectionCard";

export function AddonPicker({
  serviceName,
  addons,
  currency,
  selectedIds,
  onToggle,
}: {
  serviceName?: string;
  addons: Addon[];
  currency: string | null;
  selectedIds: Set<string>;
  onToggle: (id: string) => void;
}) {
  return (
    <SectionCard
      title={serviceName ? `${serviceName} add-ons` : "Add-ons"}
      hint="optional"
    >
      <div className="space-y-2">
        {addons.map((addon) => {
          const checked = selectedIds.has(addon.id);
          return (
            <button
              key={addon.id}
              type="button"
              onClick={() => onToggle(addon.id)}
              className={`w-full text-left rounded-xl p-3 flex justify-between items-center border transition-all duration-200 active:scale-[0.99] ${
                checked
                  ? "border-brand-500 bg-brand-50/60 ring-1 ring-brand-500"
                  : "border-slate-200/80 bg-slate-50 hover:bg-slate-100/70"
              }`}
            >
              <div className="flex items-center gap-3 min-w-0">
                <span
                  className={`flex h-5 w-5 shrink-0 items-center justify-center rounded border ${
                    checked
                      ? "bg-brand-500 border-brand-500 text-white"
                      : "border-slate-300"
                  }`}
                  aria-hidden
                >
                  {checked && (
                    <svg viewBox="0 0 16 16" className="h-3.5 w-3.5 fill-current">
                      <path d="M6.5 11.5L3 8l1-1 2.5 2.5L12 4l1 1z" />
                    </svg>
                  )}
                </span>
                <div className="min-w-0">
                  <div className="font-medium text-slate-900 truncate">
                    {addon.name}
                  </div>
                  {addon.durationMinutes ? (
                    <div className="text-xs text-slate-500 mt-0.5">
                      +{addon.durationMinutes} min
                    </div>
                  ) : null}
                </div>
              </div>
              <div
                className={`font-semibold shrink-0 ${
                  checked ? "text-brand-600" : "text-slate-700"
                }`}
              >
                +{formatMoneyMinor(addon.priceMinor, currency)}
              </div>
            </button>
          );
        })}
      </div>
    </SectionCard>
  );
}
