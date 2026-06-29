// aura-in-web/app/book/[slug]/components/ShopHero.tsx
import type { Shop } from "@/lib/types";

// Where the full Flutter web app lives. Tapping the shop header opens the app's
// deep-link resolver (/l/<slug>), which navigates to the shop's detail screen
// so clients can see the full profile, gallery, reviews, etc.
const APP_BASE_URL =
  process.env.NEXT_PUBLIC_APP_URL ?? "https://app.aurain.barsopus.com";

export function ShopHero({ target, slug }: { target: Shop; slug: string }) {
  const rating = target.averageRating;
  const hasRating = typeof rating === "number" && rating > 0;

  return (
    <a
      href={`${APP_BASE_URL}/l/${slug}`}
      className="mx-4 mt-3 flex items-center gap-3 rounded-2xl border border-slate-200/70 bg-white p-4 shadow-[0_1px_2px_rgba(15,23,42,0.04),0_4px_16px_rgba(15,23,42,0.04)] transition-colors active:bg-slate-50"
    >
      {target.logoUrl ? (
        <img
          src={target.logoUrl}
          alt=""
          className="h-12 w-12 shrink-0 rounded-full object-cover bg-slate-200"
        />
      ) : (
        <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-full bg-slate-800 font-semibold text-white">
          {target.name.slice(0, 2).toUpperCase()}
        </div>
      )}

      <div className="min-w-0 flex-1">
        <div className="flex items-center gap-1.5">
          <h1 className="truncate font-semibold text-slate-900">
            {target.name}
          </h1>
          {hasRating && (
            <span className="flex shrink-0 items-center gap-0.5 text-xs font-medium text-slate-600">
              <svg
                viewBox="0 0 20 20"
                className="h-3.5 w-3.5 fill-amber-400"
                aria-hidden
              >
                <path d="M10 1.5l2.6 5.3 5.9.9-4.3 4.1 1 5.8L10 15l-5.2 2.6 1-5.8L1.5 7.7l5.9-.9z" />
              </svg>
              {rating!.toFixed(1)}
              {target.totalReviews ? (
                <span className="text-slate-400">({target.totalReviews})</span>
              ) : null}
            </span>
          )}
        </div>
        <p className="truncate text-xs text-slate-500">
          {target.type ?? "Shop"}
          {target.address ? ` · ${target.address}` : ""}
        </p>
      </div>

      {/* Tappable affordance — opens the full shop profile in the app. */}
      <svg
        viewBox="0 0 24 24"
        className="h-5 w-5 shrink-0 text-slate-300"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        aria-hidden
      >
        <path d="M9 18l6-6-6-6" strokeLinecap="round" strokeLinejoin="round" />
      </svg>
    </a>
  );
}
