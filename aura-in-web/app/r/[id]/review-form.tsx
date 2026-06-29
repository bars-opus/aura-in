// aura-in-web/app/r/[id]/review-form.tsx
//
// Client component: 5-star picker + optional comment + submit.
// Mirrors the mobile ReviewBottomSheet UX: rating is required, text is
// optional, idempotent submission (a second submit shows the existing
// review state).
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { submitGuestReview } from "@/lib/api";

export function ReviewForm({
  bookingId,
  shopName,
}: {
  bookingId: string;
  shopName: string;
}) {
  const router = useRouter();
  const [rating, setRating] = useState(0);
  const [hover, setHover] = useState(0);
  const [text, setText] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function onSubmit() {
    if (rating === 0) return;
    setSubmitting(true);
    setError(null);
    const res = await submitGuestReview(bookingId, rating, text);
    if (!res.ok) {
      setError(res.error ?? "Could not submit your review. Please try again.");
      setSubmitting(false);
      return;
    }
    // Refresh server component → ExistingReview view takes over.
    router.refresh();
  }

  return (
    <div className="bg-white rounded-xl border border-slate-200 p-5">
      <h2 className="text-sm font-medium text-slate-900 mb-1">
        How was your visit to {shopName}?
      </h2>
      <p className="text-xs text-slate-500 mb-4">
        Your honest rating helps other clients pick the right shop.
      </p>

      <div className="flex items-center gap-1.5" role="radiogroup" aria-label="Rating">
        {[1, 2, 3, 4, 5].map((i) => (
          <button
            key={i}
            type="button"
            role="radio"
            aria-checked={rating === i}
            aria-label={`${i} star${i > 1 ? "s" : ""}`}
            onClick={() => setRating(i)}
            onMouseEnter={() => setHover(i)}
            onMouseLeave={() => setHover(0)}
            className="text-4xl leading-none transition-colors focus:outline-none focus:ring-2 focus:ring-amber-300 rounded"
          >
            <span
              className={
                i <= (hover || rating)
                  ? "text-amber-400"
                  : "text-slate-200"
              }
            >
              ★
            </span>
          </button>
        ))}
      </div>

      <textarea
        value={text}
        onChange={(e) => setText(e.target.value)}
        placeholder="What did you love? Anything we could do better?"
        rows={4}
        maxLength={1000}
        className="mt-5 w-full bg-white text-slate-900 placeholder:text-slate-400 border border-slate-200 rounded-lg px-3 py-2.5 text-sm resize-y"
      />

      {error && (
        <div className="mt-3 bg-red-50 border border-red-200 text-red-700 text-sm px-3 py-2 rounded">
          {error}
        </div>
      )}

      <button
        type="button"
        disabled={rating === 0 || submitting}
        onClick={onSubmit}
        className="mt-4 w-full bg-slate-900 text-white text-sm font-medium rounded-lg py-3 disabled:bg-slate-300 disabled:cursor-not-allowed"
      >
        {submitting ? "Submitting…" : "Submit review"}
      </button>
    </div>
  );
}
