// aura-in-web/app/book/[slug]/components/BookingFlow.tsx
"use client";

import type { ResolveLinkResponse } from "@/lib/types";

export function BookingFlow({ data, slug }: {
  data: ResolveLinkResponse;
  slug: string;
}) {
  // Placeholder for Task 4. Just shows counts so we can verify the data
  // arrived correctly server-side.
  return (
    <div className="p-4">
      <p className="text-sm text-slate-600">
        {data.services.length} service{data.services.length === 1 ? "" : "s"}
        {" · "}
        {data.workers.length} worker{data.workers.length === 1 ? "" : "s"}
        {" · "}
        targetType: {data.targetType}
      </p>
      <p className="text-xs text-slate-400 mt-4">
        BookingFlow client component pending Task 4 (slug: {slug}).
      </p>
    </div>
  );
}
