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
import { AddonPicker } from "./AddonPicker";
import { WorkerPicker } from "./WorkerPicker";
import { SlotPicker } from "./SlotPicker";
import { GuestForm } from "./GuestForm";
import { AddressPicker } from "./AddressPicker";
import { createBooking, getSlots } from "@/lib/api";
import { formatMoney } from "@/lib/format";
import { generateCombinedSlots, type CombinedSlot } from "@/lib/combine-slots";

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
  // Multiple services can be booked in one appointment. Order matters — the
  // services run back-to-back from the chosen start time in selection order.
  const [selectedServiceIds, setSelectedServiceIds] = useState<string[]>([]);
  // Add-ons are per-service: serviceId → set of addon ids.
  const [selectedAddonsByService, setSelectedAddonsByService] = useState<
    Record<string, Set<string>>
  >({});
  const [selectedWorkerId, setSelectedWorkerId] = useState<string | null>(null);
  const [slots, setSlots] = useState<SlotEntry[]>([]);
  const [slotsLoading, setSlotsLoading] = useState(false);
  const [selectedSlot, setSelectedSlot] = useState<CombinedSlot | null>(null);
  const [name, setName] = useState("");
  const [phone, setPhone] = useState("");
  const [lastService, setLastService] = useState<string | undefined>();
  const [address, setAddress] = useState<PickedAddress | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  // Bumped after each failed submit so the next attempt sends a fresh
  // idempotency key (Paystack rejects reuse of an already-attempted
  // reference). Stable within a single submit so a network retry of the
  // SAME click doesn't create two charges. Seeded from Date.now() so a
  // page reload after a prior aborted attempt also gets a fresh key.
  const [submitAttempt, setSubmitAttempt] = useState(() =>
    Math.floor(Date.now() / 1000),
  );

  const needsAddress = data.targetType === "freelancer" && data.canTravel;

  // Selected services in selection order.
  const selectedServices: Service[] = useMemo(
    () =>
      selectedServiceIds
        .map((id) => data.services.find((s) => s.id === id))
        .filter((s): s is Service => !!s),
    [data.services, selectedServiceIds],
  );

  // The chosen add-ons for a given service.
  const addonsForService = (svc: Service) => {
    const ids = selectedAddonsByService[svc.id];
    if (!ids || ids.size === 0) return [];
    return svc.addons.filter((a) => ids.has(a.id));
  };

  // Per-service add-on minutes, parallel to selectedServices — drives slot
  // generation (each slot must fit the service + its add-ons).
  const extraMinutesByService = useMemo(
    () =>
      selectedServices.map((svc) =>
        addonsForService(svc).reduce(
          (sum, a) => sum + (a.durationMinutes ?? 0),
          0,
        ),
      ),
    // selectedAddonsByService drives addonsForService; include it explicitly.
    [selectedServices, selectedAddonsByService],
  );
  // A stable signature so the slot effect re-runs when add-on minutes change.
  const extraMinutesSig = extraMinutesByService.join(",");

  // Grand total across all services incl. their add-ons.
  const servicesTotal = useMemo(
    () =>
      selectedServices.reduce((sum, svc) => {
        const addonSum = addonsForService(svc).reduce(
          (s, a) => s + a.price,
          0,
        );
        return sum + svc.price + addonSum;
      }, 0),
    [selectedServices, selectedAddonsByService],
  );

  // Lazy slot fetch over ALL selected services at once. The RPC returns
  // per-service windows (tagged by slotId); generateCombinedSlots then merges
  // them into single appointment windows that fit every service back-to-back.
  // Triggers on service set, worker, add-on minutes, or shop change.
  useEffect(() => {
    if (selectedServiceIds.length === 0) {
      setSlots([]);
      setSelectedSlot(null);
      return;
    }
    setSlotsLoading(true);
    setSelectedSlot(null);
    let cancelled = false;
    getSlots({
      shopId: data.target.id,
      serviceIds: selectedServiceIds,
      quantities: selectedServiceIds.map(() => 1),
      workerIds: selectedWorkerId ? [selectedWorkerId] : null,
      days: 7,
      extraMinutes: extraMinutesByService,
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
    // extraMinutesSig is a primitive signature of extraMinutesByService.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [
    selectedServiceIds.join(","),
    selectedWorkerId,
    data.target.id,
    extraMinutesSig,
  ]);

  // Combined appointment windows (one per start time where all services fit).
  const combinedSlots: CombinedSlot[] = useMemo(
    () => generateCombinedSlots(slots, selectedServiceIds),
    [slots, selectedServiceIds],
  );

  const hasServices = selectedServices.length > 0;
  const canSubmit =
    hasServices &&
    !!selectedSlot &&
    !!name &&
    !!phone &&
    (!needsAddress || !!address) &&
    !submitting;
  const deposit = servicesTotal * data.depositFraction;
  const platformFee = servicesTotal * data.platformFeeFraction;
  const currency = data.target.currency;

  async function handleSubmit() {
    if (!canSubmit || !hasServices || !selectedSlot) return;
    setSubmitting(true);
    setError(null);

    const origin = typeof window !== "undefined" ? window.location.origin : "";

    const startTime = selectedSlot.startTime;
    // selectedSlot is a combined window: end = start + sum of all service
    // durations (incl. add-ons). create-booking re-derives actual_end_time
    // server-side; we pass the combined end for both.
    const endTime = selectedSlot.endTime;
    const actualEndTime = selectedSlot.endTime;

    // Idempotency key scoped to (shop, phone, start_time, attempt) so a
    // double-tap on the CTA can't create two bookings, but a user-initiated
    // retry after a failure rotates the suffix so Paystack accepts the new
    // reference (it 400s on duplicates of prior attempts).
    const idempotencyKey = `shop_${data.target.id}_${phone}_${new Date(
      startTime,
    ).getTime()}_${submitAttempt}`;

    const workerId = selectedWorkerId ?? selectedSlot.workerId;
    const workerName =
      data.workers.find((w) => w.id === workerId)?.name ?? "";

    // One entry per selected service. Each carries its own (service + add-on)
    // price and duration, matching the app's payload contract. totalAmount is
    // the sum, so the create-booking amount guard (total == sum of services)
    // holds.
    const servicesPayload = selectedServices.map((svc) => {
      const svcAddons = addonsForService(svc);
      const addonPrice = svcAddons.reduce((s, a) => s + a.price, 0);
      const addonMinutes = svcAddons.reduce(
        (s, a) => s + (a.durationMinutes ?? 0),
        0,
      );
      return {
        slotId: svc.id,
        workerId,
        serviceName: svc.name,
        workerName,
        priceAtBooking: svc.price + addonPrice,
        durationMinutes: svc.durationMinutes + addonMinutes,
        ...(svcAddons.length > 0
          ? {
              addons: svcAddons.map((a) => ({
                id: a.id,
                name: a.name,
                price: a.price,
                durationMinutes: a.durationMinutes,
              })),
            }
          : {}),
      };
    });

    const res = await createBooking({
      shopId: data.target.id,
      guestName: name,
      guestPhone: phone,
      services: servicesPayload,
      startTime,
      endTime,
      actualEndTime,
      totalAmount: servicesTotal,
      depositAmount: deposit,
      platformFee,
      paymentMethod: "paystack", // server overrides based on currency
      paymentProvider: "paystack",
      idempotencyKey,
      deliveryChannel: "whatsapp",
      successUrl: `${origin}/book/${slug}/success`,
      cancelUrl: `${origin}/book/${slug}`,
      clientAddress: address?.text,
      clientAddressLat: address?.lat,
      clientAddressLng: address?.lng,
    });

    if (!res.success || !res.authorizationUrl) {
      setError(res.error ?? "Could not start payment. Please try again.");
      setSubmitting(false);
      // Rotate idempotency suffix so the user's next click sends a fresh
      // reference (Paystack rejects re-attempts on the same one).
      setSubmitAttempt((a) => a + 1);
      return;
    }
    window.location.href = res.authorizationUrl;
  }

  const toggleService = (id: string) => {
    setSelectedServiceIds((prev) =>
      prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id],
    );
    // Drop any add-ons for a service being removed.
    setSelectedAddonsByService((prev) => {
      if (!selectedServiceIds.includes(id)) return prev;
      const next = { ...prev };
      delete next[id];
      return next;
    });
  };

  const toggleAddon = (serviceId: string, addonId: string) => {
    setSelectedAddonsByService((prev) => {
      const current = new Set(prev[serviceId] ?? []);
      if (current.has(addonId)) {
        current.delete(addonId);
      } else {
        current.add(addonId);
      }
      return { ...prev, [serviceId]: current };
    });
  };

  return (
    <>
      <ServicePicker
        services={data.services}
        currency={currency}
        selectedIds={selectedServiceIds}
        lastBookedServiceName={lastService}
        onToggle={toggleService}
      />
      {/* Per-service add-ons, shown for each selected service that has any. */}
      {selectedServices.map((svc) =>
        svc.addons.length > 0 ? (
          <AddonPicker
            key={svc.id}
            serviceName={svc.name}
            addons={svc.addons}
            currency={currency}
            selectedIds={selectedAddonsByService[svc.id] ?? new Set()}
            onToggle={(addonId) => toggleAddon(svc.id, addonId)}
          />
        ) : null,
      )}
      {data.targetType === "shop" && (
        <WorkerPicker
          workers={data.workers}
          selectedId={selectedWorkerId}
          onSelect={setSelectedWorkerId}
        />
      )}
      <SlotPicker
        slots={combinedSlots}
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
        defaultCountryIso2={data.target.country}
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
            : hasServices
              ? `Pay ${formatMoney(deposit, currency)} deposit · Continue`
              : "Pick a service"}
        </button>
        {hasServices && (
          <div className="bg-slate-50 text-center text-xs text-slate-500 py-2">
            {selectedServices.length} service
            {selectedServices.length === 1 ? "" : "s"} ·{" "}
            {formatMoney(servicesTotal, currency)} total · remaining{" "}
            {formatMoney(servicesTotal - deposit, currency)} after service
          </div>
        )}
      </div>
    </>
  );
}
