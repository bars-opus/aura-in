// aura-in-web/app/book/[slug]/components/GuestForm.tsx
//
// Step 4 of the booking flow. Name + phone. The phone is debounced and
// fed into lookup-guest; if the phone matches a known guest, we prefill
// the name (only if empty) and surface their last-booked service so
// BookingFlow can flag it in ServicePicker.
"use client";

import { useState, useEffect } from "react";
import { lookupGuest } from "@/lib/api";
import { PhoneInput } from "./PhoneInput";
import { SectionCard } from "./SectionCard";

export function GuestForm({
  name,
  phone,
  defaultCountryIso2,
  onChange,
}: {
  name: string;
  phone: string;
  /** Shop country, used to default the phone-input country picker. */
  defaultCountryIso2: string | null;
  onChange: (next: {
    name: string;
    phone: string;
    lastService?: string;
  }) => void;
}) {
  const [phoneDebounced, setPhoneDebounced] = useState(phone);

  useEffect(() => {
    const t = setTimeout(() => setPhoneDebounced(phone), 500);
    return () => clearTimeout(t);
  }, [phone]);

  useEffect(() => {
    // Only hit lookup-guest once the phone looks plausibly complete.
    // Loose regex — lookup-guest itself validates and returns null for
    // malformed inputs, so we just gate the network call.
    if (!/^\+\d{8,15}$/.test(phoneDebounced)) return;
    let cancelled = false;
    lookupGuest(phoneDebounced).then((res) => {
      if (cancelled || !res) return;
      // Don't clobber a name the visitor has already typed — only prefill
      // when the field is still empty. Always surface lastService so
      // ServicePicker can flag returning-guest favourites.
      if (!name) {
        onChange({
          name: res.name,
          phone,
          lastService: res.lastServices[0],
        });
      } else {
        onChange({ name, phone, lastService: res.lastServices[0] });
      }
    });
    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [phoneDebounced]);

  return (
    <SectionCard step={4} title="Your details">
      <input
        type="text"
        placeholder="Full name"
        value={name}
        onChange={(e) => onChange({ name: e.target.value, phone })}
        className="w-full bg-slate-50 text-slate-900 placeholder:text-slate-400 border border-slate-200/80 rounded-lg px-3 py-2.5 text-sm mb-2 transition-colors focus:bg-white focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
      />
      <PhoneInput
        value={phone}
        defaultCountryIso2={defaultCountryIso2}
        onChange={(e164) => onChange({ name, phone: e164 })}
      />
    </SectionCard>
  );
}
