# Phase 11 Research

## Summary

The SPEC's biggest correction: **`shop_opening_hours.opens_at` / `closes_at` are stored as TEXT (e.g. `"09:00 AM"`), not Postgres `TIME`.** Every write in the codebase shoves the raw 12-hour string straight into the column. Casting `(elem->>'opens_at')::TIME` in the proposed RPC will reject every existing payload and corrupt every save attempt from the new editor.

Second-biggest correction: **`appointment_slots.archived_at` does not exist** in any of 37 migrations. The SPEC's archive RPC and filter cascade are dead-on-arrival without an `ALTER TABLE` migration. Worse, `create-booking/index.ts:614-616` shows commented-out `is_active` filtering — meaning even the existing `is_active` column (referenced by [create-booking:610](../../../supabase/functions/create-booking/index.ts#L610)) is unused at booking time.

Third: `HoursNotifier` writes back into `shopCreationProvider` / `freelancerCreationProvider` on every save ([hours_provider.dart:77-83](../../../lib/presentation/features/shops/creation/providers/hours_provider.dart#L77)). Reusing it from a Tools-tab edit will silently overwrite the shop-creation draft. We must NOT reuse it as-is.

Fourth: there is a **pre-existing day_of_week mismatch**. Dart writes 1..7 (Monday=1, Sunday=7) but server functions use `EXTRACT(DOW)` which returns 0..6 (Sunday=0). Saturday(6) accidentally aligns. Sunday is broken on both sides today. This is out of scope for Phase 11 but the planner must NOT pretend the data shape is internally consistent.

## Findings

### 1. shop_opening_hours column shape

No `CREATE TABLE shop_opening_hours` exists in any file under `supabase/migrations/`. The table predates the migrations folder. Inferred shape from live code:

- **`shop_id`**: UUID, FK to `shops.id` (used as filter key everywhere, e.g. [supabase_shop_repository.dart:837](../../../lib/presentation/features/shops/query/data/repositories/supabase_shop_repository.dart#L837)).
- **`day_of_week`**: INT. Server `EXTRACT(DOW)` produces 0..6. Dart writes 1..7 (see [opening_hours_draft.dart:4](../../../lib/presentation/features/shops/creation/domain/models/opening_hours_draft.dart#L4) — comment says "1-7 (Monday=1)" — and [supabase_shop_repository.dart:1211](../../../lib/presentation/features/shops/query/data/repositories/supabase_shop_repository.dart#L1211) reads with `dayOfWeek - 1`). **Range mismatch is a live bug, not a Phase 11 concern, but the new RPC's validation cannot assume one canonical range.**
- **`opens_at` / `closes_at`**: **TEXT, NOT TIME.** Proof: [hours_provider.dart:23-24](../../../lib/presentation/features/shops/creation/providers/hours_provider.dart#L23) seeds `"09:00 AM"`; [set_hours_screen.dart:122-123](../../../lib/presentation/features/shops/creation/presentation/screens/set_hours_screen.dart#L122) formats writes as `"09:00 AM"`; the write at [supabase_shop_creation_repository.dart:119](../../../lib/presentation/features/shops/creation/repository/supabase_shop_creation_repository.dart#L119) passes the raw string. Postgres `TIME` would reject `"09:00 AM"`. The architecture doc [SHOPMANAGEMENT.md:208-209](../../../architecture/SHOPMANAGEMENT.md#L208) says `open_time TIME` / `close_time TIME` but that is **stale**: the live column names are `opens_at`/`closes_at`, the live types are TEXT, and the spec writers never re-verified.
- **`is_closed`**: BOOLEAN, defaults false (per `COALESCE(is_closed, false)` in `check_shop_hours`).
- **Primary key, indexes, RLS**: **Unverifiable from migrations.** The architecture doc claims `PRIMARY KEY (shop_id, day_of_week)` but that doc is unreliable (see above). What we know empirically: queries always filter `shop_id = ? AND day_of_week = ?` with `LIMIT 1` ([booking_schema.sql:730](../../../supabase/migrations/20260517010000_booking_schema.sql#L730)), which works whether or not a uniqueness constraint exists. The spec must NOT assume uniqueness — the new RPC must `DELETE FROM shop_opening_hours WHERE shop_id = ?` *before* inserting to avoid relying on an unverified upsert behavior. The SPEC's DELETE+INSERT shape is correct *because* PK is unverified.

**Correction to SPEC**: drop `(elem->>'opens_at')::TIME`. Use `(elem->>'opens_at')::TEXT` (or no cast). Server-side validation must regex-check the string format the existing UI already produces (`"HH:MM AM"` / `"HH:MM PM"` / `"HH:MM"` 24h). The `_parseTime` helper at [supabase_shop_repository.dart:1214](../../../lib/presentation/features/shops/query/data/repositories/supabase_shop_repository.dart#L1214) only handles 24h `H:M`; it would silently misparse "09:00 AM". This is a latent display bug, but it tells us the data is mixed-format.

### 2. appointment_slots.archived_at — exists or not?

**Does not exist.** `grep -rn "archived_at" supabase/migrations/` returns zero matches across all 37 files (verified). Confirms SPEC's P0 risk. Planner MUST add it via `ALTER TABLE appointment_slots ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ;` and add a partial index `CREATE INDEX IF NOT EXISTS idx_appointment_slots_active ON appointment_slots(shop_id) WHERE archived_at IS NULL;` to keep the cascade query fast.

There IS an `is_active BOOLEAN` column already on the table (referenced at [create-booking/index.ts:610](../../../supabase/functions/create-booking/index.ts#L610), declared in [architecture/SHOPMANAGEMENT.md:183](../../../architecture/SHOPMANAGEMENT.md#L183)). The booking edge function **selects but does not check** it (lines 614-616 are commented out). The SPEC chose `archived_at` for soft-delete; an alternative would be flipping `is_active = false`. Recommend sticking with `archived_at` because (a) `is_active` is currently semantic-dead (commented filter, no callers honor it), and (b) `archived_at` carries the timestamp for audit. But the planner must decide whether to *also* set `is_active = false` for defense-in-depth or to leave `is_active` permanently broken.

### 3. Booking-side readers of appointment_slots — full inventory

Beyond the two RPCs the SPEC names, the table is read in these locations:

| Location | Filter on archive/active? |
|----------|---------------------------|
| `booking_schema.sql:542` (`create_booking_with_conflict_check`) | No |
| `booking_schema.sql:631` (`check_slot_availability`) | No |
| `booking_schema.sql:869` (`generate_available_slots` v1) | No |
| `20260517020000_booking_hardening.sql:338` (freelancer booking RPC) | No |
| `20260525020000_fix_generate_slots_selected_workers.sql:84` (variant 2) | No |
| `20260525040000_fix_generate_slots_preselected_direct.sql:82` (variant 3 — live) | No |
| `20260603000000_backfill_dashboard_rpcs.sql:137` (analytics) | No |
| `20260603001500_harden_dashboard_rpcs.sql:208` (analytics, hardened) | No |
| `supabase/functions/resolve-link/index.ts:125` (public link landing) | No — but uses `select` only |
| `supabase/functions/create-booking/index.ts:609` | Selects `is_active` then ignores it |
| Various lib/ paths (creation, query, dashboard, freelancer, export) | All read-without-archive-filter |

**The SPEC's filter cascade is incomplete.** It only patches `check_slot_availability` and `generate_available_slots`. To make archive "mean what it says," the filter must also cover:
- The two **booking-creation** RPCs (`create_booking_with_conflict_check` and the freelancer variant) — these can otherwise create a booking against an archived slot.
- `supabase/functions/resolve-link/index.ts` — public link page would list archived services to a guest.
- The two slot-generation variants (lines 84 in 20260525020000 and 82 in 20260525040000).

Recommend the planner add a `## Archive Filter Cascade (full list)` table to the PLAN with these 6 SQL surfaces + 1 edge function, not just 2.

### 4. HoursNotifier reuse + side-effect decoupling

`HoursNotifier._updateDraft()` ([hours_provider.dart:77-83](../../../lib/presentation/features/shops/creation/providers/hours_provider.dart#L77)) calls `shopCreationProvider.notifier.setOpeningHours(state)` (or freelancer variant) on every state change. Reusing the `hoursProvider` family from the Tools-tab editor would silently **overwrite the half-completed creation draft** of an owner who happens to be midway through creating a *second* shop.

Three options:
- **(a) Override the family with a no-op notifier.** Riverpod `ProviderScope.override` works; but `HoursNotifier`'s constructor still requires `Ref` and is wired to read `draftContextProvider`. Override is leaky and easy to forget at a callsite.
- **(b) Add a `mode` parameter** to `HoursNotifier` (e.g. `HoursMode.draft` vs `HoursMode.standalone`). Cleanest separation; minimal blast radius; `_updateDraft()` early-returns in standalone mode.
- **(c) Skip `HoursNotifier` entirely**, introduce a new local `BusinessHoursEditController` (state notifier or a `useState`-style ValueNotifier) scoped to the screen. The 7-row grid widget already takes a `List<OpeningHoursDraft>` and an `onChanged` callback (see how `set_hours_screen.dart` consumes it) — the widget itself is reusable; only the state container is duplicated.

**Recommendation: (c)**. The shop-creation draft state is non-trivial (Hive persistence, `_persist()` after every mutation), and "Tools-tab edit" has fundamentally different lifecycle semantics (load from server, save once, discard on cancel) than "draft a new shop" (persist locally, save on publish). Option (b) bleeds the standalone case through the creation provider's `Ref`, which still triggers `ref.watch(shopCreationProvider)` in `hoursProvider`'s factory — that's a re-creation-loop trap. Option (c) is one more file but pays for itself in correctness.

### 5. Service edit form reuse

The widget is `ServiceFormModal` at [service_form_modal.dart:8](../../../lib/presentation/features/shops/creation/presentation/widgets/service_form_modal.dart#L8). Constructor:
- `initialService: AppointmentSlotDTO?` (null = create mode, set = edit mode)
- `index: int?` (unused outside the creation list)
- `onSave: Function(AppointmentSlotDTO)` — called at [line 591](../../../lib/presentation/features/shops/creation/presentation/widgets/service_form_modal.dart#L591) before `Navigator.pop(context)`
- `shopId: String?`
- `availableWorkers: List<WorkerDTO>?`

Coupling concerns:
- It reads `hoursProvider` at [line 87](../../../lib/presentation/features/shops/creation/presentation/widgets/service_form_modal.dart#L87) to validate which days a service can be offered on. **Critical:** this means it implicitly assumes opening hours are already loaded into the global `hoursProvider`. If the new `ServiceEditScreen` does NOT also hydrate `hoursProvider` for the shop being edited, the form will show "no hours configured" or use stale draft hours from a *different* shop in the creation flow.
- It uses `_selectedDaysProvider` (a top-level `StateProvider<List<int>>`) — that's app-global state, not scoped. Two simultaneously-open `ServiceFormModal`s would collide. Unlikely in practice (modal), but means re-entering the screen for a different service inherits the previous selection until the microtask in `initState` resets it.
- `bufferMinutes` is hard-coded to 15 at [line 585](../../../lib/presentation/features/shops/creation/presentation/widgets/service_form_modal.dart#L585) — every edit overwrites whatever buffer the service had with 15. This is a pre-existing bug that *will manifest* the moment the form is used as an edit screen. Planner must fix in Phase 11 because it breaks "edit doesn't change the price/buffer" UX expectations.

**Recommendation**: reuse `ServiceFormModal` but the planner MUST require Phase 11 to also (a) load shop hours into `hoursProvider` before opening the modal, OR refactor the form to take hours as a constructor parameter; and (b) fix the hard-coded `bufferMinutes: 15` to use `widget.initialService?.bufferMinutes ?? 0`.

### 6. OpeningHoursDraft → JSONB serialization recipe

Given the column is TEXT (Finding 1), the serializer is dead-simple:
```dart
final hoursJson = hours.map((h) => {
  'day_of_week': h.dayOfWeek,   // 1..7 — see Finding 1 caveat
  'opens_at':    h.opensAt,     // pass through as-is, e.g. "09:00 AM"
  'closes_at':   h.closesAt,
  'is_closed':   h.isClosed,
}).toList();
```
The RPC accepts a `JSONB` parameter; the supabase-dart client serializes `List<Map>` to a JSONB array natively via `.rpc(..., params: {'p_hours': hoursJson})`. No string format conversion needed because the existing code path already accepts `"HH:MM AM/PM"` strings.

**Caveat — day_of_week range**: existing data in `shop_opening_hours` has `day_of_week` values that depend on which writer originally inserted them. Some old rows may be 0..6 (if a long-ago writer used DOW), most are 1..7. The validation in the new RPC should accept the *whole* range `BETWEEN 0 AND 7` to avoid rejecting historic-but-valid rows on a partial-edit, and the count check should be "exactly 7 elements" not "values are exactly {1..7}". Otherwise editing an old shop whose data is 0..6 fails on first save.

### 7. tools_screen.dart cleanup scope

Both cards (4 and 5) become functional in Phase 11. The `Snackbar.info(context, 'Coming in a future release.')` calls at [lines 163-166](../../../lib/presentation/features/shops/dashboard/presentation/screens/tools_screen.dart#L163) and [175-178](../../../lib/presentation/features/shops/dashboard/presentation/screens/tools_screen.dart#L175) are the *only* "Coming Soon" SnackBars on the screen. After Phase 11, no card in `ToolsScreen` is in "Coming Soon" state. The `Snackbar` import is also used by case 3 (Payment Settings) at [line 134](../../../lib/presentation/features/shops/dashboard/presentation/screens/tools_screen.dart#L134) for `Snackbar.info('Loading shop details…')`, so **do NOT remove the import**. Just delete the two card bodies' `onTap` SnackBars and the `enabled: false`.

### 8. Existing creation-flow loop bug — fix or defer?

[`supabase_shop_creation_repository.dart:394-403`](../../../lib/presentation/features/shops/creation/repository/supabase_shop_creation_repository.dart#L394) is one of *eight* delete-then-insert loops in that single method (services, opening hours, social_links, images, etc., all share the same pattern). Fixing only the hours loop while leaving the seven sibling loops un-fixed creates a misleading impression of safety. The bug class is "publish/edit-shop is not transactional" — fixing one row of it is not phase-bounded.

**Recommendation: defer.** Route the new RPC through Phase 11's editor only. File a follow-up phase (suggested: "Phase 12.1 — atomic shop publish path") that rewrites the entire `updateShop` method to call `rebuild_shop_opening_hours` AND introduces matching transactional RPCs for the other six loops. Touching the creation flow in Phase 11 to fix just one loop violates the "surgical fix, flag regression risk" rule and risks regressing the publish flow that 100% of shop creation depends on.

### 9. Archive filter cascade — partial-rollout consequences

Trace the booking flow:

1. Owner archives slot X via `archive_appointment_slot`.
2. Customer opens shop page → `resolve-link` lists slot X (no filter) → customer picks it.
3. Customer requests times → `generate_available_slots` (filtered: X skipped). Customer sees nothing for slot X but the slot is still in the picker. **Confusing UX, not a data leak.**
4. **Alternate path**: customer already had a deep-link to a known slot/time → `check_slot_availability` (unfiltered, if only `generate_available_slots` is patched) → returns `available: true`.
5. Customer triggers booking → `create_booking_with_conflict_check` or `create_booking_transaction` (both unfiltered) → **booking gets created against an archived slot**. The `booking_services.slot_id` FK to the now-archived row is still valid; the row physically exists.
6. Owner sees an unexpected booking on a service they archived. Trust hit.

**If only `generate_available_slots` is patched but not `check_slot_availability`**: race exists where a guest who held the slot picker open before archive can still book it via re-availability check.

**If only `check_slot_availability` is patched but not `generate_available_slots`**: the picker still surfaces archived slots, and the create-time check rejects them — confusing "the slot is here but the system says it's unavailable" experience.

**Required full cascade** (per Finding 3): all six SQL surfaces + `resolve-link` edge function in one migration so the rollout is atomic at the schema level.

### 10. appointment_slots other consumers

See Finding 3 for the full inventory. In `lib/`:
- `supabase_dashboard_repository.dart` lines 256, 267, 277, 349, 593, 785 — analytics/listing
- `supabase_booking_repository.dart` line 33 (constant), 512 (PostgREST nested select)
- `supabase_shop_creation_repository.dart` lines 100, 196, 198, 227, 377, 379
- `supabase_freelancer_repository.dart` lines 109, 372, 374, 561
- `supabase_shop_repository.dart` lines 839, 956, 1006
- `export_repository.dart` line 345, `export_service.dart` line 274
- `worker_slot_assignments_provider.dart` line 15

**For Phase 11**, the booking-impact subset is what matters (Finding 3). Analytics readers SHOULD also add `archived_at IS NULL` to avoid "service appears in past-period reports because it existed back then" surprises, but the planner can defer that to a follow-up. **Document explicitly** in the PR that analytics-side reads still include archived slots.

### 11. Other risks

- **No realtime subscription on `shop_opening_hours` or `appointment_slots`** (verified: only `bookings` is in `supabase_realtime` publication per [20260526210000_enable_realtime_bookings.sql](../../../supabase/migrations/20260526210000_enable_realtime_bookings.sql)). The delete-then-insert inside the RPC fires as a single transaction — even if realtime were enabled later, observers would see a coherent snapshot (Postgres logical replication emits the changes after commit). **No risk.**
- **No triggers on `appointment_slots` or `shop_opening_hours`** (verified: `grep TRIGGER` returns nothing matching). No cascading writes to worry about.
- **`shopDetailsProvider(shopId)` invalidation**: `ToolsScreen` already watches it; after a successful save, invalidating it from each editor will re-fetch all shop fields — fine for a Tools tab but heavier than needed. Future optimization: a `shopOpeningHoursProvider(shopId)` family that the editor invalidates instead.
- **`_parseTime` only handles 24h format** ([supabase_shop_repository.dart:1214](../../../lib/presentation/features/shops/query/data/repositories/supabase_shop_repository.dart#L1214)) — the existing reader silently misparses any `"09:00 AM"` row stored by the current creation flow. This means the consumer-side shop page is likely already showing wrong opening hours for any shop created via the flow. Latent bug, out of Phase 11 scope, but the planner should add an explicit note: "Phase 11 does NOT fix the consumer-side hours display."
- **`appointment_slots.is_active` is a graveyard column**. Filter is commented out in `create-booking`. The planner should explicitly decide between using `is_active` (the column that's already there) or `archived_at` (new column). I recommend `archived_at` (matches SPEC, carries timestamp), with a one-line note in the PR that `is_active` is now formally deprecated.
- **`ServiceFormModal.bufferMinutes: 15` hard-coded** — see Finding 5.

## Recommendations for the planner

- Add an explicit migration `20260605000050_add_archived_at_to_appointment_slots.sql` BEFORE the archive RPC migration. Use `IF NOT EXISTS`. Add a partial index `WHERE archived_at IS NULL` filtered by `shop_id`.
- Change the `rebuild_shop_opening_hours` RPC body: replace `(elem->>'opens_at')::TIME` with `(elem->>'opens_at')::TEXT` (or no cast). Add a regex check `~ '^([01]?[0-9]|2[0-3]):[0-5][0-9]( [AP]M)?$'` against `opens_at` and `closes_at` if validation is required server-side. Drop the cast for `closes_at` too.
- Validate `day_of_week BETWEEN 0 AND 7` (inclusive) in the RPC, not `BETWEEN 1 AND 7`, to tolerate legacy 0-indexed rows.
- Filter cascade migration must touch **all 6 SQL surfaces** from Finding 3 PLUS `resolve-link/index.ts`. Not 2.
- Do NOT reuse `HoursNotifier` in the new screen. Introduce `BusinessHoursEditController` local to the dashboard feature (Finding 4, option c).
- Reuse `ServiceFormModal` but Phase 11 must (a) ensure `hoursProvider` is hydrated for the shop-under-edit before opening the modal, and (b) fix the hard-coded `bufferMinutes: 15` regression.
- Drop both `Coming Soon` SnackBars from `tools_screen.dart` but KEEP the `Snackbar` import (Case 3 needs it).
- Defer the creation-flow `edit_shop_provider` loop fix. File a separate phase. Note explicitly in PR description.
- Decide between `archived_at` (recommended) vs `is_active`. If `archived_at`, treat `is_active` as deprecated and DO NOT add code that sets it.
- Add a `## Out of Scope (carry-over bugs)` section to the plan listing: day_of_week 1-7 vs 0-6 mismatch; `_parseTime` AM/PM bug; analytics reads not filtered by archive.

## Open questions for the user

1. **P0** — Confirm or override the recommendation to use `archived_at` (new column) rather than flipping the existing `is_active` column. Either works; SPEC says `archived_at`; we have no constraint that prevents using `is_active` instead. User pick.
2. **P1** — Should the filter cascade also patch the **booking-creation** RPCs (`create_booking_with_conflict_check` and the freelancer variant in `20260517020000_booking_hardening.sql`), or only the read-side? The SPEC implies read-side only. My read says: without write-side checks, the system can create a booking against an archived slot. Recommend patching both. User confirms or accepts the risk.
3. **P1** — Is fixing the `ServiceFormModal.bufferMinutes: 15` hard-code in scope for Phase 11? It's a one-line fix that becomes catastrophic the first time someone edits a service. Recommend yes.
4. **P2** — Do we proactively load `hoursProvider` for the shop being edited inside `ServiceEditScreen`, or do we refactor `ServiceFormModal` to take hours as a constructor parameter? Either path works; the latter is cleaner but a larger diff in a shared widget.

## RESEARCH COMPLETE
