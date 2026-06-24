// aura-in-web/app/order/[id]/order-review-form.tsx
//
// Client component used inline on /order/[id] when an order is delivered
// and no review exists yet. Mirrors the booking ReviewForm UX (5 stars +
// optional comment + idempotent submit) but talks to the order RPC.
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { submitGuestOrderReview } from "@/lib/api";

export function OrderReviewForm({
  orderId,
  shopName,
}: {
  orderId: string;
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
    const res = await submitGuestOrderReview(orderId, rating, text);
    if (!res.ok) {
      setError(res.error ?? "Could not submit your review. Please try again.");
      setSubmitting(false);
      return;
    }
    router.refresh();
  }

  return (
    <div className="bg-white rounded-xl border border-slate-200 p-4">
      <h2 className="text-xs uppercase tracking-wide text-slate-500 mb-2 font-medium">
        Rate your order
      </h2>
      <p className="text-xs text-slate-500 mb-3">
        How was your experience ordering from {shopName}?
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
            className="text-3xl leading-none transition-colors focus:outline-none focus:ring-2 focus:ring-amber-300 rounded"
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
        placeholder="Tell other shoppers what went well or what could be better."
        rows={3}
        maxLength={1000}
        className="mt-3 w-full bg-white border border-slate-200 rounded-lg px-3 py-2.5 text-sm resize-y"
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
        className="mt-3 w-full bg-slate-900 text-white text-sm font-medium rounded-lg py-2.5 disabled:bg-slate-300 disabled:cursor-not-allowed"
      >
        {submitting ? "Submitting…" : "Submit review"}
      </button>
    </div>
  );
}
