// aura-in-web/lib/combine-slots.ts
//
// Port of the app's generateCombinedSlots (calculate_combined_slots.dart).
//
// The slot RPC returns one set of time-windows PER selected service (tagged
// with slotId = the service id). To book multiple services as one appointment,
// we group those per-service windows by start time, keep only the start times
// where EVERY selected service has a window, and emit a single combined slot
// whose length is the sum of all the services' window durations (services run
// back-to-back from the shared start time).

import type { SlotEntry } from "@/lib/types";

/** A bookable appointment window that fits all selected services back-to-back. */
export interface CombinedSlot {
  startTime: string; // ISO
  endTime: string; // ISO (start + sum of service durations)
  workerId: string | null; // worker from the first service's window, if any
}

function startKey(iso: string): string {
  // Group by wall-clock start (date + HH:mm). Using the ISO string up to the
  // minute is stable and avoids timezone drift from re-parsing.
  return iso.slice(0, 16); // "2026-06-29T09:00"
}

/**
 * Combine per-service slots into single appointment windows.
 *
 * @param slots       Flat list from get-slots (each tagged with slotId).
 * @param serviceIds  The services the visitor selected, in display order.
 * @returns           One CombinedSlot per start time where all services fit.
 */
export function generateCombinedSlots(
  slots: SlotEntry[],
  serviceIds: string[],
): CombinedSlot[] {
  if (serviceIds.length === 0) return [];

  // Single service: every slot is already a complete window — pass through.
  if (serviceIds.length === 1) {
    return slots.map((s) => ({
      startTime: s.startTime,
      endTime: s.endTime,
      workerId: s.workerId,
    }));
  }

  // Group slots by start time.
  const byStart = new Map<string, SlotEntry[]>();
  for (const s of slots) {
    const k = startKey(s.startTime);
    const list = byStart.get(k) ?? [];
    list.push(s);
    byStart.set(k, list);
  }

  const combined: CombinedSlot[] = [];

  for (const [, group] of byStart) {
    // Every selected service must have a window at this start time.
    const perService: Record<string, SlotEntry> = {};
    let allPresent = true;
    for (const serviceId of serviceIds) {
      const match = group.find((s) => s.slotId === serviceId);
      if (!match) {
        allPresent = false;
        break;
      }
      // First match per service wins (windows are identical across workers).
      if (!perService[serviceId]) perService[serviceId] = match;
    }
    if (!allPresent) continue;

    // Combined length = sum of each service window's duration.
    let totalMs = 0;
    for (const serviceId of serviceIds) {
      const slot = perService[serviceId];
      totalMs +=
        new Date(slot.endTime).getTime() - new Date(slot.startTime).getTime();
    }

    const start = group[0].startTime;
    const end = new Date(new Date(start).getTime() + totalMs).toISOString();

    combined.push({
      startTime: start,
      endTime: end,
      workerId: group[0].workerId ?? null,
    });
  }

  combined.sort(
    (a, b) =>
      new Date(a.startTime).getTime() - new Date(b.startTime).getTime(),
  );
  return combined;
}
