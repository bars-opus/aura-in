// aura-in-web/app/book/[slug]/components/BookingFlow.tsx
//
// Single-page booking orchestrator. Renders ServicePicker → WorkerPicker
// (shops only) → SlotPicker → GuestForm with a sticky CTA at the bottom.
//
// Data flow:
//   1. resolve-link populates `data` server-side (services + workers +
//      target metadata). availableSlots is ALWAYS [] in v1 — we ignore it.
//   2. When the visitor picks a service (or changes their worker), we fire
//      getSlots() lazily. Race-safe via cancellation flag.
//   3. Submit POSTs create-booking and redirects to the returned
//      Paystack/Stripe checkout URL. Provider selection is server-side
//      (currency-based) — we hard-code paymentMethod="paystack" because the
//      server overrides it.
"use client";

import { useState, useEffect, useMemo } from "react";
import type {
  ResolveLinkResponse,
  SlotEntry,
  Service,
} from "@/lib/types";
import { ServicePicker } from "./ServicePicker";
import { WorkerPicker } from "./WorkerPicker";
import { SlotPicker } from "./SlotPicker";
import { GuestForm } from "./GuestForm";
import { AddressPicker } from "./AddressPicker";
import { createBooking, getSlots } from "@/lib/api";
import { formatMoney } from "@/lib/format";

interface PickedAddress {
  text: string;
  lat: number;
  lng: number;
}

export function BookingFlow({
  data,
  slug,
}: {
  data: ResolveLinkResponse;
  slug: string;
}) {
  const [selectedServiceId, setSelectedServiceId] = useState<string | null>(
    null,
  );
  const [selectedWorkerId, setSelectedWorkerId] = useState<string | null>(null);
  const [slots, setSlots] = useState<SlotEntry[]>([]);
  const [slotsLoading, setSlotsLoading] = useState(false);
  const [selectedSlot, setSelectedSlot] = useState<SlotEntry | null>(null);
  const [name, setName] = useState("");
  const [phone, setPhone] = useState("");
  const [lastService, setLastService] = useState<string | undefined>();
  const [address, setAddress] = useState<PickedAddress | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const needsAddress = data.targetType === "freelancer" && data.canTravel;

  const selectedService: Service | null = useMemo(
    () => data.services.find((s) => s.id === selectedServiceId) ?? null,
    [data.services, selectedServiceId],
  );

  // Lazy slot fetch. Triggers on:
  //   - service change (slots are service-specific in the RPC)
  //   - worker change (server can narrow via p_selected_worker_ids)
  //   - shop id change (only ever once in practice — included for soundness)
  // Cancellation flag protects against an old request landing after a
  // newer one fires (e.g. user taps service A then quickly switches to B).
  useEffect(() => {
    if (!selectedServiceId) {
      setSlots([]);
      setSelectedSlot(null);
      return;
    }
    setSlotsLoading(true);
    setSelectedSlot(null);
    let cancelled = false;
    getSlots({
      shopId: data.target.id,
      serviceIds: [selectedServiceId],
      quantities: [1],
      workerIds: selectedWorkerId ? [selectedWorkerId] : null,
      days: 7,
    })
      .then((res) => {
        if (cancelled) return;
        setSlots(res.slots);
      })
      .catch(() => {
        if (cancelled) return;
        setSlots([]);
      })
      .finally(() => {
        if (!cancelled) setSlotsLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [selectedServiceId, selectedWorkerId, data.target.id]);

  const canSubmit =
    !!selectedService &&
    !!selectedSlot &&
    !!name &&
    !!phone &&
    (!needsAddress || !!address) &&
    !submitting;
  const deposit = selectedService
    ? selectedService.price * data.depositFraction
    : 0;
  const platformFee = selectedService
    ? selectedService.price * data.platformFeeFraction
    : 0;
  const currency = data.target.currency;

  async function handleSubmit() {
    if (!canSubmit || !selectedService || !selectedSlot) return;
    setSubmitting(true);
    setError(null);

    const startTime = selectedSlot.startTime;
    // Prefer the RPC-reported endTime (already accounts for the slot
    // duration); fall back to a computed end if for some reason it's
    // missing. actual_end_time isn't surfaced through get-slots so we
    // approximate with endTime — create-booking's conflict checker
    // re-derives it on the server side.
    const computedEnd = new Date(
      new Date(startTime).getTime() +
        selectedService.durationMinutes * 60_000,
    ).toISOString();
    const endTime = selectedSlot.endTime || computedEnd;
    const actualEndTime = selectedSlot.endTime || computedEnd;

    // Idempotency key scoped to (shop, phone, start_time) so a double-tap
    // on the CTA can't create two bookings.
    const idempotencyKey = `shop_${data.target.id}_${phone}_${new Date(
      startTime,
    ).getTime()}`;

    const res = await createBooking({
      shopId: data.target.id,
      guestName: name,
      guestPhone: phone,
      services: [
        {
          slotId: selectedService.id,
          workerId: selectedWorkerId,
          serviceName: selectedService.name,
          workerName:
            data.workers.find((w) => w.id === selectedWorkerId)?.name ?? "",
          priceAtBooking: selectedService.price,
          durationMinutes: selectedService.durationMinutes,
        },
      ],
      startTime,
      endTime,
      actualEndTime,
      totalAmount: selectedService.price,
      depositAmount: deposit,
      platformFee,
      paymentMethod: "paystack", // server overrides based on currency
      paymentProvider: "paystack",
      idempotencyKey,
      deliveryChannel: "whatsapp",
      successUrl: `https://aura-in-web.vercel.app/book/${slug}/success`,
      cancelUrl: `https://aura-in-web.vercel.app/book/${slug}`,
      clientAddress: address?.text,
      clientAddressLat: address?.lat,
      clientAddressLng: address?.lng,
    });

    if (!res.success || !res.authorizationUrl) {
      setError(res.error ?? "Could not start payment. Please try again.");
      setSubmitting(false);
      return;
    }
    window.location.href = res.authorizationUrl;
  }

  return (
    <>
      <ServicePicker
        services={data.services}
        currency={currency}
        selectedId={selectedServiceId}
        lastBookedServiceName={lastService}
        onSelect={setSelectedServiceId}
      />
      {data.targetType === "shop" && (
        <WorkerPicker
          workers={data.workers}
          selectedId={selectedWorkerId}
          onSelect={setSelectedWorkerId}
        />
      )}
      <SlotPicker
        slots={slots}
        workerId={selectedWorkerId}
        selectedSlot={selectedSlot}
        onSelect={setSelectedSlot}
        loading={slotsLoading}
      />
      {needsAddress && (
        <AddressPicker
          freelancer={data.target}
          travelRadiusKm={data.travelRadiusKm}
          onChange={(addr) => setAddress(addr)}
        />
      )}
      <GuestForm
        name={name}
        phone={phone}
        onChange={({ name: n, phone: p, lastService: ls }) => {
          setName(n);
          setPhone(p);
          if (ls) setLastService(ls);
        }}
      />

      {error && (
        <div className="mx-4 mt-3 bg-red-50 border border-red-200 text-red-700 text-sm px-3 py-2 rounded">
          {error}
        </div>
      )}

      <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-slate-200 max-w-md mx-auto">
        <button
          type="button"
          onClick={handleSubmit}
          disabled={!canSubmit}
          className={`w-full py-3.5 text-white font-semibold ${
            canSubmit
              ? "bg-emerald-600 active:bg-emerald-700"
              : "bg-slate-300"
          }`}
        >
          {submitting
            ? "Starting payment…"
            : selectedService
              ? `Pay ${formatMoney(deposit, currency)} deposit · Continue`
              : "Pick a service"}
        </button>
        {selectedService && (
          <div className="bg-slate-50 text-center text-xs text-slate-500 py-2">
            Remaining {formatMoney(selectedService.price - deposit, currency)}{" "}
            paid after service
          </div>
        )}
      </div>
    </>
  );
}
