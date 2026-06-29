// aura-in-web/app/book/[slug]/components/SectionCard.tsx
//
// The web analogue of the app's CardInkWell — a soft, floating white card that
// demarcates a booking step. Minimalist: generous padding, a hairline border, a
// whisper of shadow, and an optional numbered step badge. Sections settle up on
// mount (stagger via `index`) for a calm, Apple-like entrance.
"use client";

import type { ReactNode } from "react";

export function SectionCard({
  index = 0,
  step,
  title,
  hint,
  children,
}: {
  /** Position in the flow — drives the staggered entrance delay. */
  index?: number;
  /** Optional step number shown in a small badge before the title. */
  step?: number;
  title?: string;
  /** Optional muted text after the title (e.g. "optional"). */
  hint?: string;
  children: ReactNode;
}) {
  return (
    <section
      className="animate-settle mx-4 mt-3 rounded-2xl border border-slate-200/70 bg-white p-4 shadow-[0_1px_2px_rgba(15,23,42,0.04),0_4px_16px_rgba(15,23,42,0.04)]"
      style={{ animationDelay: `${Math.min(index, 6) * 60}ms` }}
    >
      {title && (
        <div className="mb-3 flex items-center gap-2">
          {step != null && (
            <span className="flex h-5 w-5 items-center justify-center rounded-full bg-slate-900 text-[11px] font-semibold text-white">
              {step}
            </span>
          )}
          <h2 className="text-[13px] font-semibold tracking-tight text-slate-900">
            {title}
          </h2>
          {hint && (
            <span className="text-xs font-normal text-slate-400">{hint}</span>
          )}
        </div>
      )}
      {children}
    </section>
  );
}
