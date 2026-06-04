# Phase 11 — Business Hours + Service Management editors

## Outcome

Convert the two "Coming Soon" cards on the Tools tab into working
editors. Shop owners can:

- **Business Hours**: open a weekly grid, toggle days closed, adjust
  open/close times per day, and save. The booking pipeline (which
  already enforces these hours via `check_shop_hours`) reflects the
  change on the next booking attempt.
- **Service Management**: list the shop's current services
  (`appointment_slots`), edit price / duration / name / buffer
  minutes / max clients per slot, add a new service, archive (soft
  delete) an existing one. Booking flow already reads from this
  table, so changes appear immediately.

Both editors must save atomically — a failure mid-write must NOT
leave the shop with partial hours or services. This is the
load-bearing constraint that differentiates Phase 11 from "expose
the existing widgets."

## Why this matters

- Phase 10.5 disabled the two cards with "Coming in a future release."
  copy. That sets an expectation we now have to meet.
- The backing schema (`shop_opening_hours`, `appointment_slots`)
  already exists and is in active use by `check_shop_hours`,
  `check_slot_availability`, `generate_available_slots`, and the
  booking pipeline. We don't need new tables — only safer write
  paths.
- The current "edit shop" flow exists ([`edit_shop_provider.dart`](../../../lib/presentation/features/shops/creation/providers/edit_shop_provider.dart))
  but is part of a single multi-step shop-creation wizard. It rewrites
  every shop field on save and uses a delete-then-re-insert pattern
  in a non-transactional loop ([`supabase_shop_creation_repository.dart:394-403`](../../../lib/presentation/features/shops/creation/repository/supabase_shop_creation_repository.dart#L394)).
  Any transient network error mid-loop leaves the shop's hours wiped.
  Phase 11 cannot inherit that risk.

## Definitions

- **Opening hours rebuild**: replace ALL of a shop's `shop_opening_hours`
  rows with the editor's current state. Must be atomic at the DB layer.
- **Service archive (soft delete)**: set `appointment_slots.archived_at`
  to `now()` (or equivalent — confirm column exists in Research). Hard
  delete is out of scope because existing bookings reference the slot
  via `booking_services.slot_id` FK.
- **Service edit**: in-place UPDATE of a single `appointment_slots` row
  by id. Atomic by construction (single statement).

## In scope

| Surface | Scope |
|---------|-------|
| `BusinessHoursScreen` | Reuses `HoursNotifier` + the existing day-of-week row widget from the creation flow. Renders all 7 weekdays. Save calls a new RPC. Cancel restores from the loaded state. |
| `ServiceManagementScreen` | List view of existing services for the shop. Each row links to a `ServiceEditScreen` (existing add-service form, reused). Plus an "Add service" FAB. |
| **New RPC** `rebuild_shop_opening_hours(p_shop_id, p_hours JSONB)` | Transactional DELETE + INSERT inside one statement. Authz: shop owner only. Validates that exactly 7 rows are passed (one per day). |
| **New RPC** `archive_appointment_slot(p_slot_id)` | Soft-delete a service. Authz via `appointment_slots.shop_id → shops.user_id`. |
| **Tools tab routing** | Wire the two cards in `tools_screen.dart` from disabled-with-Snackbar to `Navigator.push(...)` into the new screens. Drop the `Coming in a future release.` SnackBar logic for these two cards. |
| **`KpiCard.enabled`** | Now passes `true` for both cards. |

## Out of scope (locked)

- **Holiday / temporary closure overrides** — separate calendar table; defer to a focused future phase.
- **Per-worker hours / staff scheduling** — Phase 12 candidate.
- **Pricing tiers / time-based pricing** — Phase 13 candidate.
- **Service categories / tagging** — `appointment_slots` doesn't have a category column; adding one is its own scope.
- **Service-level photo uploads** — `shop_media` already handles shop-wide images; service-specific photos are Phase 12+.
- **Service reordering / drag-handle** — `display_order` column may or may not exist; out of scope to add.
- **Bulk operations** — "apply Saturday hours to all weekends" etc. UX nicety, not v1.
- **No reuse of `edit_shop_provider`'s save path** — too coupled, too risky, rewrites unrelated fields.

## Data sources / infrastructure already in place

- `shop_opening_hours` table — verified at [20260517010000_booking_schema.sql:730](../../../supabase/migrations/20260517010000_booking_schema.sql#L730) (read by `check_shop_hours`).
- `appointment_slots` table — verified by direct grep, read by every booking flow (`check_slot_availability`, `generate_available_slots`).
- `HoursNotifier` + `OpeningHoursDraft` — fully working state management for the weekly grid.
- `AppointmentSlotDTO` — fully shaped, already serialized/deserialized in the creation flow.
- `shopDetailsProvider(shopId)` — already in `ToolsScreen` and serves both editors' initial data.

## Server changes

### RPC 1 — `rebuild_shop_opening_hours(p_shop_id UUID, p_hours JSONB) RETURNS VOID`

Transactional DELETE + INSERT in one function body, ATOMIC by Postgres
default per-statement semantics. Authz: caller must own `p_shop_id`.

```sql
CREATE OR REPLACE FUNCTION public.rebuild_shop_opening_hours(
  p_shop_id UUID,
  p_hours   JSONB
) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_owns_shop BOOLEAN;
  v_count     INT;
BEGIN
  -- Authz first.
  SELECT EXISTS (
    SELECT 1 FROM shops WHERE id = p_shop_id AND user_id = auth.uid()
  ) INTO v_owns_shop;
  IF NOT v_owns_shop THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  -- Validate: must be a JSON array of exactly 7 elements (one per weekday).
  IF p_hours IS NULL OR jsonb_typeof(p_hours) <> 'array' THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'HOURS_MUST_BE_ARRAY';
  END IF;
  SELECT jsonb_array_length(p_hours) INTO v_count;
  IF v_count <> 7 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'EXACTLY_7_DAYS_REQUIRED';
  END IF;

  -- Atomic rebuild: DELETE old rows, INSERT new ones. Both statements
  -- run inside the function's implicit transaction; either both
  -- succeed or both roll back.
  DELETE FROM shop_opening_hours WHERE shop_id = p_shop_id;
  INSERT INTO shop_opening_hours (
    shop_id, day_of_week, opens_at, closes_at, is_closed
  )
  SELECT
    p_shop_id,
    (elem->>'day_of_week')::INT,
    (elem->>'opens_at')::TIME,
    (elem->>'closes_at')::TIME,
    COALESCE((elem->>'is_closed')::BOOLEAN, false)
  FROM jsonb_array_elements(p_hours) AS elem;
END;
$$;

REVOKE ALL ON FUNCTION public.rebuild_shop_opening_hours(UUID, JSONB) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.rebuild_shop_opening_hours(UUID, JSONB) TO authenticated;
```

### RPC 2 — `archive_appointment_slot(p_slot_id UUID) RETURNS VOID`

Soft delete. Authz via the slot's shop. Schema assumes an `archived_at`
column exists on `appointment_slots` — confirm in Research. If it
doesn't, add it as a `NULL`-able TIMESTAMPTZ column in the same
migration.

```sql
CREATE OR REPLACE FUNCTION public.archive_appointment_slot(
  p_slot_id UUID
) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_owns_shop BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM appointment_slots s
    JOIN shops sh ON sh.id = s.shop_id
    WHERE s.id = p_slot_id AND sh.user_id = auth.uid()
  ) INTO v_owns_shop;
  IF NOT v_owns_shop THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  UPDATE appointment_slots
     SET archived_at = now()
   WHERE id = p_slot_id;
END;
$$;

REVOKE ALL ON FUNCTION public.archive_appointment_slot(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.archive_appointment_slot(UUID) TO authenticated;
```

### Filter cascade

Booking-side reads need an `archived_at IS NULL` filter added to:

- `check_slot_availability` — currently reads any slot row regardless of archive state. Without the filter, archived slots could still be selected by the booking flow.
- `generate_available_slots` — same.

These two are RPCs that exist in production (verified in
[20260525040000_fix_generate_slots_preselected_direct.sql](../../../supabase/migrations/20260525040000_fix_generate_slots_preselected_direct.sql)).
Updating their bodies is a precondition for archive to mean
"unavailable for booking."

This is a Phase 11 dependency — without it, archive is cosmetic. Cost:
trivial (one extra `AND s.archived_at IS NULL` per query).

## Client changes

### `BusinessHoursScreen` (new)

`lib/presentation/features/shops/dashboard/presentation/screens/business_hours_screen.dart`

ConsumerStatefulWidget. Watches `shopDetailsProvider(shopId)` for
initial state, hydrates a local `HoursNotifier` family via override
(seed from `dto.openingHours`). Renders 7 rows — one per weekday —
each showing day name, a closed-toggle, and two time pickers (open /
close). Save button calls the new RPC; on success, invalidates
`shopDetailsProvider(shopId)` so future opens reload from server.
Discard button pops without saving.

Edge handling:
- Invalid hours (close < open while not closed) — save button disabled, inline error per row.
- Save failure — sanitized `BusinessHoursException`, SnackBar via existing `Snackbar.error`.
- Loading state during the RPC — disabled save button + spinner.

### `ServiceManagementScreen` (new)

`lib/presentation/features/shops/dashboard/presentation/screens/service_management_screen.dart`

ConsumerWidget listing active (non-archived) services for the shop.
Tap a row → `ServiceEditScreen`. FAB "Add service" → same
`ServiceEditScreen` in create-mode. Long-press / swipe → archive
confirmation via existing modal sheet pattern.

### `ServiceEditScreen` (new, reuses existing widgets)

`lib/presentation/features/shops/dashboard/presentation/screens/service_edit_screen.dart`

Hosts the existing add-service form widget (reused from the creation
flow). On save in edit-mode, performs a single Postgrest
`.update(...).eq('id', slotId)` — this is atomic by construction
(single statement); no RPC needed.

On save in create-mode, performs a single Postgrest `.insert(...)`
with `shop_id` set from the screen prop. Returns the new id for the
list to refresh.

### `tools_screen.dart` update

Replace the Coming Soon SnackBar handlers on cards 4 and 5 with real
`Navigator.push` to the two new screens. Set `enabled: true` on both.
Drop the `'Coming in a future release.'` SnackBar logic for these two
cards only — Card 5 stays disabled for any remaining future-only items
(Service Categories would be one, but that's not in scope here).
Update: actually, Card 5 (Service Management) is now in scope, so
both Coming Soon SnackBars disappear in this phase.

### Repository surface

`lib/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart`

Add three abstract methods:

```dart
Future<void> rebuildShopOpeningHours({
  required String shopId,
  required List<OpeningHoursDraft> hours,
});

Future<List<AppointmentSlotDTO>> getActiveServices(String shopId);

Future<void> archiveAppointmentSlot(String slotId);
```

Implementation on `SupabaseDashboardRepository`. Service edit/create
flows through new methods that wrap `.update` / `.insert` with
sanitized error mapping.

### New typed exception

`ServiceManagementException` mirroring `WalletException` / `PromotionException`. Stable code + userMessage.

## Routing

No new GoRouter routes — both new screens use the existing
`MaterialPageRoute` push pattern that the other Tools-tab screens
(`ReminderSettingsScreen`, `PromotionsScreen`) already follow.

## Atomicity invariant

Stated explicitly because it's the load-bearing differentiator:

- **Business Hours save** must be a single transaction. The new RPC
  satisfies this. If the RPC fails for any reason, the existing
  rows remain untouched. This is the single most important
  improvement over the existing `edit_shop_provider` save path,
  which uses a Dart-side loop where a network blip mid-loop leaves
  the shop's hours half-written.
- **Service archive** is a single UPDATE — atomic by construction.
- **Service edit** is a single UPDATE — atomic by construction.
- **Service create** is a single INSERT — atomic by construction.

## Checklist v3.1 coverage

| Check | How |
|-------|-----|
| 1.4 Authz at every access | Both new RPCs use `EXISTS shops WHERE user_id = auth.uid()`. Service edit/create/list rely on existing `appointment_slots` RLS scoped by shop ownership. |
| 1.10 Compensating tx | `rebuild_shop_opening_hours` is one transaction; partial-write impossible. |
| 2.1 Input validation | RPC raises `'invalid_input'` on bad JSONB shape, day count, etc. Client-side day-count enforced by `HoursNotifier`. |
| 2.4 Errors don't leak | All paths through `Snackbar.error` with stable codes; no `e.toString()` in UI. |
| 2.5 Resource limits | Hours JSONB validated to exactly 7 elements server-side. |
| 4.4 PII excluded from logs | Stable error codes only via `AppLogger.warn`. |
| 5.1 Actionable errors | "Hours overlap" / "Close before open" inline copy on the row. |
| 5.5 No internal info in UI | Sanitized exception messages. |
| 6.13 Documentation | Both new RPCs have `COMMENT ON FUNCTION` with intent + Big-O. |

## Files touched

**NEW**
- `supabase/migrations/20260605000000_rebuild_shop_opening_hours_rpc.sql`
- `supabase/migrations/20260605000100_archive_appointment_slot_rpc.sql`
- `supabase/migrations/20260605000200_appointment_slots_archived_at_filter.sql` (rewrites `check_slot_availability` + `generate_available_slots` to filter `archived_at IS NULL`)
- `lib/presentation/features/shops/dashboard/data/exceptions/service_management_exceptions.dart`
- `lib/presentation/features/shops/dashboard/presentation/screens/business_hours_screen.dart`
- `lib/presentation/features/shops/dashboard/presentation/screens/service_management_screen.dart`
- `lib/presentation/features/shops/dashboard/presentation/screens/service_edit_screen.dart`
- `test/dashboard/business_hours_save_test.dart` (controller-level — RPC error mapping)
- `test/dashboard/service_management_test.dart` (archive + edit happy paths)
- `.planning/phases/11-business-hours-and-services/sql/11_smoke_tests.sql` (manual psql)

**EDIT**
- `lib/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart` — 3 new abstract methods
- `lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart` — 3 new impls + error mapping
- `lib/presentation/features/shops/dashboard/presentation/screens/tools_screen.dart` — wire up cards 4 + 5
- `lib/presentation/features/shops/dashboard/providers/dashboard_providers.dart` — provider families for both editors' load/save flows

## Tests

### SQL smoke tests
- `rebuild_shop_opening_hours` authz (non-owner → 42501)
- `rebuild_shop_opening_hours` validation (5 days → 22023 / EXACTLY_7_DAYS_REQUIRED, null → 22023 / HOURS_MUST_BE_ARRAY)
- `rebuild_shop_opening_hours` happy path (7 rows in, 7 rows after)
- `rebuild_shop_opening_hours` atomicity (force a CHECK violation in the array → all 7 inserts roll back, original rows remain)
- `archive_appointment_slot` authz + happy path
- Confirm `check_slot_availability` and `generate_available_slots` skip archived slots after the filter migration

### Dart tests
- Controller-level error-code mapping for both new repository methods.
- Validation tests: `HoursNotifier.isValid` returns false for closesAt < opensAt on a non-closed day.

### Manual UAT
- Edit business hours on staging shop, save, refresh page, confirm hours persisted.
- Force-kill the network mid-save (e.g. airplane mode after tap) — confirm shop's existing hours are untouched (atomicity proof).
- Archive a service, confirm it disappears from the active list AND from `get-slots` output for any future date.
- Edit a service price, confirm new price appears at booking time.
- Add a new service, confirm it appears in the booking flow.

## Effort

| Phase | Hrs |
|-------|-----|
| 3 migrations + filter cascade | 2.5 |
| `ServiceManagementException` + 3 repo methods + error mapping | 1.5 |
| `BusinessHoursScreen` + state plumbing | 2 |
| `ServiceManagementScreen` + list/archive | 1.5 |
| `ServiceEditScreen` + add/edit flow | 1.5 |
| `tools_screen.dart` rewire (cards 4+5) | 0.3 |
| Provider family wiring | 0.5 |
| Tests (unit + SQL smoke) | 2 |
| Manual UAT + screenshots | 0.5 |
| **Total** | **~12.3h ≈ 1.5 days** |

Slightly over Phase 10.5's footprint because three screens are
genuinely new, and the booking-RPC filter cascade adds an
investigation step that 10.5 didn't have. Still inside one engineering
day if executed focused.

## Rollout

1. Push `20260605000000` (`rebuild_shop_opening_hours`) — additive.
2. Push `20260605000100` (`archive_appointment_slot`) — additive. If `archived_at` column doesn't exist, the migration adds it (NULLable, defaults to NULL — backward compatible).
3. Push `20260605000200` (filter cascade on existing RPCs) — modifies two existing functions to add the archive filter. Audit the diff carefully before merging.
4. Run SQL smoke tests against staging.
5. Ship Dart code.
6. 24h log watch: any `dashboard.rebuild_hours_failed` / `service.archive_failed` log events.

## Rollback (Tier 2)

1. Revert the Dart commit — the two Tools-tab cards return to "Coming Soon" state because their handlers re-disable. No data lost.
2. To roll back the migrations, ship a follow-up that drops the two new RPCs. The filter cascade is the harder rollback — reverting it would make archived slots available to booking again. Document this prominently in the PR description.

## Definition of done

- [ ] `flutter analyze` clean on every touched file
- [ ] All new Dart tests pass; SQL smoke tests print `OK:` for every case
- [ ] Business Hours editor saves successfully on staging
- [ ] Atomicity test (force network failure mid-save) leaves shop hours untouched
- [ ] Archive a service — the service stops appearing in the booking flow within the same session
- [ ] Edit a service price — booking flow reflects new price
- [ ] No `e.toString()` lands in either new screen's state
- [ ] Tools tab cards 4 + 5 now route to working screens (no SnackBar fallback)
- [ ] PR description flags the archive filter cascade as the highest-risk delta and documents the rollback plan

## PR risks worth flagging upfront

| Risk | Severity | Mitigation |
|------|----------|------------|
| Archive filter cascade breaks an active booking flow if the filter is malformed | P0 | The migration only adds `AND s.archived_at IS NULL` — additive. Smoke tests against staging before prod. |
| Hours rebuild silently rejects valid input due to JSONB shape drift | P1 | Server validates count + types; client tests cover happy path + invalid case. |
| Existing creation-flow `edit_shop_provider` path still has the loop bug | P2 | Out of scope for this phase. File a follow-up to also route the creation flow through `rebuild_shop_opening_hours`. |
| `archived_at` column doesn't exist on `appointment_slots` | P0 | Migration adds it `IF NOT EXISTS`. Verify the prod column list before merge. |
