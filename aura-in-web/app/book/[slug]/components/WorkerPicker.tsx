// aura-in-web/app/book/[slug]/components/WorkerPicker.tsx
//
// Step 2 of the booking flow. Horizontally scrolling chip row of workers.
// Hidden entirely on freelancer pages (BookingFlow gates the render on
// targetType === "shop"). "Any available" maps to workerId = null and lets
// generate_available_slots pick from all slot-assigned workers.
"use client";

import type { Worker } from "@/lib/types";
import { SectionCard } from "./SectionCard";

export function WorkerPicker({
  workers,
  selectedId,
  onSelect,
}: {
  workers: Worker[];
  selectedId: string | null;
  onSelect: (id: string | null) => void;
}) {
  if (workers.length === 0) return null;

  const chip = (active: boolean) =>
    `flex-shrink-0 px-3 py-2 rounded-lg [border-width:0.5px] text-sm transition-all duration-200 active:scale-[0.97] ${
      active
        ? "border-brand-500 bg-brand-50/60 ring-[0.5px] ring-brand-500 text-slate-900 font-medium"
        : "border-slate-200/70 bg-slate-50 text-slate-600 hover:bg-slate-100/70"
    }`;

  return (
    <SectionCard step={2} title="Worker" hint="optional">
      <div className="flex gap-2 overflow-x-auto -mx-1 px-1 pb-1">
        <button
          type="button"
          onClick={() => onSelect(null)}
          className={chip(selectedId === null)}
        >
          Any available
        </button>
        {workers.map((w) => (
          <button
            key={w.id}
            type="button"
            onClick={() => onSelect(w.id)}
            className={chip(selectedId === w.id)}
          >
            {w.name}
          </button>
        ))}
      </div>
    </SectionCard>
  );
}
