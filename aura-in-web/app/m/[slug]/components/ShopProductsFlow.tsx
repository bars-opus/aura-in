// aura-in-web/app/m/[slug]/components/ShopProductsFlow.tsx
//
// Orchestrator for the link-products checkout. Shows the shop hero,
// product grid, sticky cart drawer, then the GuestCheckoutSheet to
// collect name + phone + address + notes and submit the guest order.
//
// State lives entirely in this component (no global store). The cart is
// in-memory only — refresh blanks it; matches the mobile single-shop
// invariant by design (one slug = one shop).
"use client";

import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import type { ShopProduct, ShopProductsResponse } from "@/lib/types";
import { createGuestOrder } from "@/lib/api";
import { formatMoney } from "@/lib/format";
import { PhoneInput } from "../../../book/[slug]/components/PhoneInput";

interface CartLine {
  product: ShopProduct;
  qty: number;
}

export function ShopProductsFlow({ data }: { data: ShopProductsResponse }) {
  const router = useRouter();
  const [cart, setCart] = useState<Map<string, CartLine>>(new Map());
  const [showCheckout, setShowCheckout] = useState(false);

  const currency = data.shop.currency ?? "GHS";

  const itemCount = useMemo(
    () => [...cart.values()].reduce((s, l) => s + l.qty, 0),
    [cart],
  );
  const total = useMemo(
    () => [...cart.values()].reduce((s, l) => s + l.qty * Number(l.product.price), 0),
    [cart],
  );

  function setQty(p: ShopProduct, qty: number) {
    setCart((prev) => {
      const next = new Map(prev);
      if (qty <= 0) {
        next.delete(p.id);
      } else {
        next.set(p.id, { product: p, qty: Math.min(qty, p.stock_quantity) });
      }
      return next;
    });
  }

  return (
    <main className="min-h-screen bg-slate-50 pb-32">
      <header className="bg-white border-b border-slate-200 px-4 py-5">
        <div className="max-w-2xl mx-auto flex items-center gap-3">
          {data.shop.logo_url ? (
            <img
              src={data.shop.logo_url}
              alt={data.shop.name}
              className="w-12 h-12 rounded-lg object-cover bg-slate-100"
            />
          ) : (
            <div className="w-12 h-12 rounded-lg bg-slate-100 flex items-center justify-center text-slate-400 text-lg">
              {(data.shop.name?.[0] ?? "?").toUpperCase()}
            </div>
          )}
          <div className="flex-1 min-w-0">
            <h1 className="text-base font-semibold text-slate-900 truncate">
              {data.shop.name}
            </h1>
            <p className="text-xs text-slate-500 truncate">
              {data.shop.type ?? "Shop"} · Pay on delivery
            </p>
          </div>
        </div>
      </header>

      {data.products.length === 0 ? (
        <p className="max-w-2xl mx-auto px-4 pt-10 text-center text-sm text-slate-500">
          No products listed yet.
        </p>
      ) : (
        <section className="max-w-2xl mx-auto px-4 pt-5 grid grid-cols-2 gap-3">
          {data.products.map((p) => (
            <ProductCard
              key={p.id}
              product={p}
              currency={currency}
              qty={cart.get(p.id)?.qty ?? 0}
              onQty={(q) => setQty(p, q)}
            />
          ))}
        </section>
      )}

      {itemCount > 0 && (
        <div className="fixed bottom-0 inset-x-0 bg-white border-t border-slate-200 px-4 py-3 z-30">
          <div className="max-w-2xl mx-auto flex items-center gap-3">
            <div className="flex-1 min-w-0">
              <p className="text-xs text-slate-500">
                {itemCount} item{itemCount > 1 ? "s" : ""}
              </p>
              <p className="text-sm font-semibold text-slate-900 tabular-nums">
                {formatMoney(total, currency)}
              </p>
            </div>
            <button
              type="button"
              onClick={() => setShowCheckout(true)}
              className="bg-brand-500 text-white text-sm font-medium rounded-lg px-5 py-2.5"
            >
              Continue
            </button>
          </div>
        </div>
      )}

      {showCheckout && (
        <CheckoutSheet
          shop={data.shop}
          lines={[...cart.values()]}
          total={total}
          currency={currency}
          onClose={() => setShowCheckout(false)}
          onSubmitted={(orderId) => router.push(`/order/${orderId}`)}
        />
      )}
    </main>
  );
}

function ProductCard({
  product,
  currency,
  qty,
  onQty,
}: {
  product: ShopProduct;
  currency: string;
  qty: number;
  onQty: (q: number) => void;
}) {
  const out = product.stock_quantity <= 0;
  const cover = product.images?.[0];
  return (
    <article
      className={
        "bg-white rounded-xl border border-slate-200 overflow-hidden flex flex-col " +
        (out ? "opacity-60" : "")
      }
    >
      <div className="aspect-square bg-slate-100">
        {cover && (
          <img
            src={cover}
            alt={product.name}
            className="w-full h-full object-cover"
          />
        )}
      </div>
      <div className="p-3 flex flex-col gap-1 flex-1">
        <p className="text-sm font-medium text-slate-900 line-clamp-2">
          {product.name}
        </p>
        <p className="text-sm text-slate-900 tabular-nums">
          {formatMoney(Number(product.price), currency)}
        </p>
        {out ? (
          <p className="mt-1 text-xs text-red-600">Out of stock</p>
        ) : qty === 0 ? (
          <button
            type="button"
            onClick={() => onQty(1)}
            className="mt-2 w-full bg-slate-100 hover:bg-slate-200 text-slate-900 text-xs font-medium rounded-md py-2"
          >
            Add
          </button>
        ) : (
          <div className="mt-2 flex items-center justify-between bg-slate-50 rounded-md border border-slate-200 px-2 py-1">
            <button
              type="button"
              aria-label="Decrease"
              onClick={() => onQty(qty - 1)}
              className="w-7 h-7 text-slate-700 hover:bg-slate-200 rounded text-base"
            >
              −
            </button>
            <span className="text-sm tabular-nums">{qty}</span>
            <button
              type="button"
              aria-label="Increase"
              disabled={qty >= product.stock_quantity}
              onClick={() => onQty(qty + 1)}
              className="w-7 h-7 text-slate-700 hover:bg-slate-200 rounded text-base disabled:opacity-40"
            >
              +
            </button>
          </div>
        )}
      </div>
    </article>
  );
}

function CheckoutSheet({
  shop,
  lines,
  total,
  currency,
  onClose,
  onSubmitted,
}: {
  shop: ShopProductsResponse["shop"];
  lines: CartLine[];
  total: number;
  currency: string;
  onClose: () => void;
  onSubmitted: (orderId: string) => void;
}) {
  const [name, setName] = useState("");
  const [phone, setPhone] = useState("");
  const [address, setAddress] = useState("");
  const [notes, setNotes] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  // Per-mount idempotency salt — a refresh produces a new salt so a
  // genuine retry sends a different reference.
  const [submitAttempt, setSubmitAttempt] = useState(() =>
    Math.floor(Date.now() / 1000),
  );

  const canSubmit =
    name.trim().length >= 2 &&
    /^\+\d{8,15}$/.test(phone) &&
    address.trim().length >= 5 &&
    !submitting;

  async function submit() {
    if (!canSubmit) return;
    setSubmitting(true);
    setError(null);

    const idempotencyKey = `m_${shop.id}_${phone}_${submitAttempt}`;

    const res = await createGuestOrder({
      shopId: shop.id,
      guestName: name.trim(),
      guestPhone: phone,
      deliveryAddress: address.trim(),
      customerNotes: notes.trim() || undefined,
      items: lines.map((l) => ({ productId: l.product.id, quantity: l.qty })),
      totalAmount: total,
      idempotencyKey,
      deliveryChannel: "whatsapp",
    });

    if (!res.success || !res.orderId) {
      setError(res.error ?? "Could not place order. Try again.");
      setSubmitting(false);
      setSubmitAttempt((a) => a + 1);
      return;
    }
    onSubmitted(res.orderId);
  }

  return (
    <div className="fixed inset-0 bg-black/40 z-40 flex items-end justify-center">
      <div className="bg-white w-full max-w-2xl rounded-t-2xl max-h-[92vh] overflow-y-auto">
        <header className="sticky top-0 bg-white border-b border-slate-200 px-4 py-3 flex items-center gap-3">
          <button
            type="button"
            onClick={onClose}
            className="text-slate-500 text-xl leading-none w-8 h-8"
            aria-label="Close"
          >
            ×
          </button>
          <h2 className="text-sm font-semibold text-slate-900">Checkout</h2>
        </header>

        <section className="px-4 pt-4">
          <h3 className="text-xs uppercase tracking-wide text-slate-500 mb-2 font-medium">
            Your order
          </h3>
          <ul className="divide-y divide-slate-100 bg-white rounded-xl border border-slate-200">
            {lines.map((l) => (
              <li key={l.product.id} className="flex items-center justify-between px-3 py-2.5 text-sm">
                <span className="min-w-0 truncate">
                  {l.qty} × {l.product.name}
                </span>
                <span className="tabular-nums text-slate-700 ml-3">
                  {formatMoney(l.qty * Number(l.product.price), currency)}
                </span>
              </li>
            ))}
            <li className="flex items-center justify-between px-3 py-2.5 text-sm font-semibold">
              <span>Total</span>
              <span className="tabular-nums">{formatMoney(total, currency)}</span>
            </li>
          </ul>
          <p className="text-xs text-slate-500 mt-2">Pay on delivery.</p>
        </section>

        <section className="px-4 pt-4">
          <h3 className="text-xs uppercase tracking-wide text-slate-500 mb-2 font-medium">
            Your details
          </h3>
          <input
            type="text"
            placeholder="Full name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            className="w-full bg-white text-slate-900 placeholder:text-slate-400 border border-slate-200 rounded-lg px-3 py-2.5 text-sm mb-2"
          />
          <PhoneInput
            value={phone}
            defaultCountryIso2={shop.country}
            onChange={setPhone}
          />
          <textarea
            value={address}
            onChange={(e) => setAddress(e.target.value)}
            placeholder="Delivery address (street, area, landmark)"
            rows={2}
            maxLength={500}
            className="mt-2 w-full bg-white text-slate-900 placeholder:text-slate-400 border border-slate-200 rounded-lg px-3 py-2.5 text-sm resize-y"
          />
          <textarea
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            placeholder="Notes for the shop (optional)"
            rows={2}
            maxLength={1000}
            className="mt-2 w-full bg-white text-slate-900 placeholder:text-slate-400 border border-slate-200 rounded-lg px-3 py-2.5 text-sm resize-y"
          />
        </section>

        {error && (
          <div className="mx-4 mt-3 bg-red-50 border border-red-200 text-red-700 text-sm px-3 py-2 rounded">
            {error}
          </div>
        )}

        <div className="sticky bottom-0 bg-white border-t border-slate-200 px-4 py-3">
          <button
            type="button"
            disabled={!canSubmit}
            onClick={submit}
            className="w-full bg-brand-500 text-white text-sm font-medium rounded-lg py-3 disabled:bg-slate-300 disabled:cursor-not-allowed"
          >
            {submitting ? "Placing order…" : `Place order · ${formatMoney(total, currency)}`}
          </button>
        </div>
      </div>
    </div>
  );
}
