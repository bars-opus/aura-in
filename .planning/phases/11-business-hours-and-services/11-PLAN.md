# Phase 11 PLAN — Business Hours + Service Management

## Goal

Convert the two "Coming Soon" cards on the shop-owner Tools tab (Business Hours, Service Management) into working editors that save atomically through new hardened RPCs. The Business Hours editor performs a single-transaction `DELETE + INSERT` rebuild of `shop_opening_hours` (so a mid-save failure never leaves the shop half-written), and the Service Management editor lists / edits / archives rows of `appointment_slots` with `archived_at` as the new soft-delete semantic. A booking-side filter cascade ensures archive actually means "unavailable" across all six SQL surfaces plus the public link landing edge function — without that cascade, archive is cosmetic. (SPEC §Outcome lines 5–22; §"Atomicity invariant" lines 273–283; RESEARCH Finding 3 lines 33–56 + Finding 9 lines 111–125.)

## Out of scope (locked)

Verbatim from SPEC §"Out of scope (locked)" lines 62–70:

- **Holiday / temporary closure overrides** — separate calendar table; defer to a focused future phase.
- **Per-worker hours / staff scheduling** — Phase 12 candidate.
- **Pricing tiers / time-based pricing** — Phase 13 candidate.
- **Service categories / tagging** — `appointment_slots` does not have a category column; adding one is its own scope.
- **Service-level photo uploads** — `shop_media` already handles shop-wide images; service-specific photos are Phase 12+.
- **Service reordering / drag-handle** — `display_order` may or may not exist; out of scope to add.
- **Bulk operations** — "apply Saturday hours to all weekends" UX nicety, not v1.
- **No reuse of `edit_shop_provider`'s save path** — too coupled, too risky, rewrites unrelated fields.

### Out of scope (carry-over bugs — explicitly NOT fixed in Phase 11)

Locked correction 11. These pre-date Phase 11 and stay broken until their own phase:

- **`day_of_week` range mismatch.** Dart writes `1..7` (Monday=1, Sunday=7) at `lib/presentation/features/shops/creation/domain/models/opening_hours_draft.dart:4`; server `EXTRACT(DOW)` produces `0..6` (Sunday=0). Saturday(6) accidentally aligns; Sunday is broken on both sides today. The new `rebuild_shop_opening_hours` RPC accepts `BETWEEN 0 AND 7` so we do not reject legacy rows on first save (locked correction 5), but Phase 11 does not normalize the data. (RESEARCH Finding 1 line 20; Finding 6 line 98.)
- **`_parseTime` AM/PM bug** at `lib/presentation/features/shops/query/data/repositories/supabase_shop_repository.dart:1214` — the helper only parses 24h `H:M`; rows stored as `"09:00 AM"` (the format the existing UI writes) misparse. Consumer-side shop page already shows wrong hours for any shop saved via the creation flow. Phase 11 does NOT fix the consumer-side hours display. (RESEARCH Finding 1 line 25; Finding 11 line 145.)
- **Analytics reads still include archived slots.** The filter cascade in Phase 11 covers booking-impact surfaces only (read + create). Analytics RPCs at `supabase/migrations/20260603000000_backfill_dashboard_rpcs.sql:137` and `20260603001500_harden_dashboard_rpcs.sql:208` and dashboard repo paths (`supabase_dashboard_repository.dart` lines 256, 267, 277, 349, 593, 785) still join `appointment_slots` without `archived_at IS NULL`. Archived services therefore still appear in past-period reports. Accepted; documented in PR. (RESEARCH Finding 3 line 47–48; Finding 10 line 138.)
- **Creation-flow loop bug** at `lib/presentation/features/shops/creation/repository/supabase_shop_creation_repository.dart:394-403` — one of eight delete-then-insert loops in `updateShop` (services, hours, social_links, images, ...). Fixing only the hours loop while seven siblings remain non-transactional creates a misleading impression of safety. Deferred to a future "Phase 12.1 atomic shop publish" phase that rewrites all eight loops to call hardened RPCs. (RESEARCH Finding 8 lines 104–108; locked correction 10.)
- **`appointment_slots.is_active`** is formally deprecated. The booking edge function at `supabase/functions/create-booking/index.ts:610` selects it but the filter is commented out (lines 614–616). Phase 11 uses `archived_at` exclusively and MUST NOT add code that sets or filters on `is_active`. (RESEARCH Finding 2 line 31; Finding 11 line 146; locked correction 3.)

## Files touched

**NEW**

- `supabase/migrations/20260605000050_add_archived_at_to_appointment_slots.sql`
- `supabase/migrations/20260605000100_rebuild_shop_opening_hours_rpc.sql`
- `supabase/migrations/20260605000200_archive_appointment_slot_rpc.sql`
- `supabase/migrations/20260605000300_archive_filter_cascade.sql`
- `lib/presentation/features/shops/dashboard/data/exceptions/business_hours_exceptions.dart`
- `lib/presentation/features/shops/dashboard/data/exceptions/service_management_exceptions.dart`
- `lib/presentation/features/shops/dashboard/presentation/controllers/business_hours_edit_controller.dart`
- `lib/presentation/features/shops/dashboard/presentation/screens/business_hours_screen.dart`
- `lib/presentation/features/shops/dashboard/presentation/screens/service_management_screen.dart`
- `lib/presentation/features/shops/dashboard/presentation/screens/service_edit_screen.dart`
- `test/presentation/features/shops/dashboard/data/exceptions/business_hours_exceptions_test.dart`
- `test/presentation/features/shops/dashboard/data/exceptions/service_management_exceptions_test.dart`
- `test/presentation/features/shops/dashboard/presentation/controllers/business_hours_edit_controller_test.dart`
- `test/presentation/features/shops/dashboard/data/repositories/services_repository_test.dart`
- `.planning/phases/11-business-hours-and-services/sql/11_smoke_tests.sql`

**EDIT**

- `supabase/functions/resolve-link/index.ts` — line 125 select adds `archived_at IS NULL` predicate (edge function, separate from the SQL cascade migration but ships in the same release).
- `lib/presentation/features/shops/creation/presentation/widgets/service_form_modal.dart` — (a) refactor to accept `availableHours: List<OpeningHoursDraft>` as a constructor parameter; remove the `ref.read(hoursProvider)` read at line 87 (locked correction 8). (b) Fix the hard-coded `bufferMinutes: 15` at line 585 to `bufferMinutes: widget.initialService?.bufferMinutes ?? 0` (locked correction 7).
- `lib/presentation/features/shops/creation/presentation/screens/set_hours_screen.dart` — update the one call-site that constructs `ServiceFormModal` to pass `availableHours: ref.read(hoursProvider)`.
- `lib/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart` — add three abstract methods (`rebuildShopOpeningHours`, `getActiveServices`, `archiveAppointmentSlot`).
- `lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart` — implement the three methods with `PostgrestException` → typed-exception mapping.
- `lib/presentation/features/shops/dashboard/presentation/screens/tools_screen.dart` — wire Card 4 → `BusinessHoursScreen`, Card 5 → `ServiceManagementScreen`; drop both `Snackbar.info(context, 'Coming in a future release.')` calls at lines 163-166 and 175-178 (locked correction 9); KEEP the `Snackbar` import (case 3 Payment Settings still uses it at line 134); both cards become `enabled: true`.
- `lib/presentation/features/shops/dashboard/providers/dashboard_providers.dart` — add `activeServicesProvider.family(shopId)` for the list view; expose `businessHoursEditControllerProvider.family(shopId)`.

## Migration plan

Four new SQL migrations, applied in strict timestamp order, plus one edge-function update that ships in the same release. Every RPC body follows the hardening template at `supabase/migrations/20260603001500_harden_dashboard_rpcs.sql` lines 29–108 byte-for-byte: `LANGUAGE plpgsql`, `SECURITY DEFINER`, `SET search_path = public`, authz ownership gate FIRST, validation second, `'not_found'` raises with `ERRCODE = '42501'`, `'invalid_*'` raises with `ERRCODE = '22023'` (plus `HINT = '...'`), then `REVOKE ALL ON FUNCTION ... FROM PUBLIC`, `GRANT EXECUTE ... TO authenticated`, and `COMMENT ON FUNCTION ... IS '... Big-O ...'`.

### 1. `20260605000050_add_archived_at_to_appointment_slots.sql`

MUST land BEFORE the archive RPC. Without this column, the RPC body in migration 2 throws `column "archived_at" does not exist` on first call. (RESEARCH Finding 2 lines 27–29; locked correction 2.)

```sql
-- Adds soft-delete column on appointment_slots, plus a partial index that
-- keeps the filter-cascade queries (see 20260605000300) fast by pre-pruning
-- archived rows. Idempotent (IF NOT EXISTS).
--
-- Locked correction 3: is_active is formally deprecated. We do NOT touch
-- it. New code reads/writes archived_at exclusively.

ALTER TABLE public.appointment_slots
  ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_appointment_slots_active
  ON public.appointment_slots (shop_id)
  WHERE archived_at IS NULL;

COMMENT ON COLUMN public.appointment_slots.archived_at IS
  'Soft-delete timestamp. NULL = active. Set by archive_appointment_slot RPC. is_active is deprecated as of 2026-06-05; do not use.';
```

### 2. `20260605000100_rebuild_shop_opening_hours_rpc.sql`

Transactional `DELETE + INSERT` inside one function body. Atomic by Postgres per-statement semantics: either both succeed or both roll back. Authz: caller must own `p_shop_id`.

Locked corrections applied (override SPEC §"RPC 1" lines 82–136):
- **No `::TIME` casts.** `shop_opening_hours.opens_at` / `closes_at` are TEXT in prod, not Postgres `TIME` (RESEARCH Finding 1 lines 21–25; locked correction 1). The SPEC's `(elem->>'opens_at')::TIME` would reject every existing payload — the existing UI writes `"09:00 AM"`. We pass-through as TEXT.
- **`day_of_week BETWEEN 0 AND 7`.** Existing data is mixed 0..6 and 1..7. Rejecting either range would break first-save on legacy shops (RESEARCH Finding 6 line 98; locked correction 5).

```sql
CREATE OR REPLACE FUNCTION public.rebuild_shop_opening_hours(
  p_shop_id UUID,
  p_hours   JSONB
) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $function$
DECLARE
  v_owns_shop BOOLEAN;
  v_count     INT;
  v_bad_dow   INT;
BEGIN
  -- Authz FIRST. Matches harden_dashboard_rpcs.sql:45-51.
  SELECT EXISTS (
    SELECT 1 FROM public.shops
    WHERE id = p_shop_id AND user_id = auth.uid()
  ) INTO v_owns_shop;
  IF NOT v_owns_shop THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  -- Shape: must be a JSON array of exactly 7 elements.
  IF p_hours IS NULL OR jsonb_typeof(p_hours) <> 'array' THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'HOURS_MUST_BE_ARRAY';
  END IF;
  SELECT jsonb_array_length(p_hours) INTO v_count;
  IF v_count <> 7 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'EXACTLY_7_DAYS_REQUIRED';
  END IF;

  -- day_of_week BETWEEN 0 AND 7 inclusive (locked correction 5).
  -- Tolerates legacy 0..6 and current 1..7 writers.
  SELECT MIN((elem->>'day_of_week')::INT) INTO v_bad_dow
  FROM jsonb_array_elements(p_hours) elem
  WHERE (elem->>'day_of_week')::INT NOT BETWEEN 0 AND 7;
  IF v_bad_dow IS NOT NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'DAY_OF_WEEK_OUT_OF_RANGE';
  END IF;

  -- Atomic rebuild. Both statements run in the function's implicit tx.
  -- No ::TIME cast (locked correction 1) — column is TEXT in prod.
  DELETE FROM public.shop_opening_hours WHERE shop_id = p_shop_id;
  INSERT INTO public.shop_opening_hours (
    shop_id, day_of_week, opens_at, closes_at, is_closed
  )
  SELECT
    p_shop_id,
    (elem->>'day_of_week')::INT,
    elem->>'opens_at',
    elem->>'closes_at',
    COALESCE((elem->>'is_closed')::BOOLEAN, false)
  FROM jsonb_array_elements(p_hours) AS elem;
END;
$function$;

REVOKE ALL ON FUNCTION public.rebuild_shop_opening_hours(UUID, JSONB) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.rebuild_shop_opening_hours(UUID, JSONB) TO authenticated;
COMMENT ON FUNCTION public.rebuild_shop_opening_hours(UUID, JSONB) IS
  'Atomic rebuild of a shop''s weekly opening hours. DELETE + INSERT in one tx. SECURITY DEFINER with shops.user_id=auth.uid() gate. Accepts day_of_week BETWEEN 0 AND 7 to tolerate legacy 0-indexed rows. opens_at / closes_at stored as TEXT (existing prod shape). O(1) — bounded at 7 rows per call.';
```

### 3. `20260605000200_archive_appointment_slot_rpc.sql`

Single-row soft delete. Authz via the slot's shop ownership. Depends on the column added in migration 1.

```sql
CREATE OR REPLACE FUNCTION public.archive_appointment_slot(
  p_slot_id UUID
) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $function$
DECLARE
  v_owns_shop BOOLEAN;
BEGIN
  IF p_slot_id IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'NULL_NOT_ALLOWED';
  END IF;

  SELECT EXISTS (
    SELECT 1
    FROM public.appointment_slots s
    JOIN public.shops sh ON sh.id = s.shop_id
    WHERE s.id = p_slot_id AND sh.user_id = auth.uid()
  ) INTO v_owns_shop;
  IF NOT v_owns_shop THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  UPDATE public.appointment_slots
     SET archived_at = now()
   WHERE id = p_slot_id
     AND archived_at IS NULL;  -- idempotent: re-archive is a no-op
END;
$function$;

REVOKE ALL ON FUNCTION public.archive_appointment_slot(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.archive_appointment_slot(UUID) TO authenticated;
COMMENT ON FUNCTION public.archive_appointment_slot(UUID) IS
  'Soft-delete an appointment slot by setting archived_at. SECURITY DEFINER with appointment_slots → shops.user_id=auth.uid() gate. Idempotent (WHERE archived_at IS NULL). O(1).';
```

### 4. `20260605000300_archive_filter_cascade.sql`

Patches SIX existing SQL surfaces so archive means "unavailable." Without this cascade, archive is cosmetic — read-time picker still shows archived services and create-time RPCs still book against them (RESEARCH Finding 3 lines 33–56; Finding 9 lines 111–125; locked correction 4).

Six surfaces, replaced as `CREATE OR REPLACE FUNCTION` rebuilds (full bodies, not patches — Postgres does not support partial function rewrites):

1. **`create_booking_with_conflict_check`** at `20260517010000_booking_schema.sql:542` — the `SELECT service_name, price FROM appointment_slots WHERE id = p_slot_id` gains `AND archived_at IS NULL`. If the slot is archived, the SELECT finds no row, `v_name`/`v_price` stay NULL, and the function must raise `archived_slot` (`P0001`, HINT `SLOT_ARCHIVED`) before the `INSERT INTO bookings` runs. This prevents the race where a customer holds a stale slot id and books it after the owner archived it.
2. **`check_slot_availability`** at `20260517010000_booking_schema.sql:631` — the `SELECT slot_type, COALESCE(max_clients, 1) FROM appointment_slots WHERE id = p_slot_id` gains `AND archived_at IS NULL`. If no row, return `jsonb_build_object('available', false, 'reason', 'archived')`. This keeps the pre-flight check honest.
3. **`generate_available_slots` v1** at `20260517010000_booking_schema.sql:869` — the `SELECT s.* FROM appointment_slots s WHERE s.id = v_svc_id` gains `AND s.archived_at IS NULL` (the `IF NOT FOUND THEN CONTINUE;` already handles the skipped-row case).
4. **Freelancer booking RPC** at `20260517020000_booking_hardening.sql:338` — the `SELECT service_name, price FROM appointment_slots WHERE id = p_slot_id` gains `AND archived_at IS NULL`. Same archived-slot raise as surface 1.
5. **`generate_available_slots` variant 2 (selected workers)** at `20260525020000_fix_generate_slots_selected_workers.sql:84` — same single-line predicate addition.
6. **`generate_available_slots` variant 3 (preselected direct, currently live)** at `20260525040000_fix_generate_slots_preselected_direct.sql:82` — same single-line predicate addition.

Plus **edge function** (shipped in the same release but NOT in this SQL migration — Task 2.1):

7. **`supabase/functions/resolve-link/index.ts:125`** — the `.from('appointment_slots').select(...).eq('shop_id', shop.id)` chain gains `.is('archived_at', null)`. Public link landing must not list archived services.

The migration recreates surfaces 1–6 with the predicate added; signatures and bodies are otherwise byte-for-byte preserved from their current state (so a future reviewer can `diff` migration 4 against the live function source and verify the one-line delta per body).

(Body templates omitted from this PLAN for length — the executor copies each current body verbatim and inserts the documented predicate. Each rewrite ends with the standard `REVOKE ALL ... FROM PUBLIC; GRANT EXECUTE ... TO authenticated; COMMENT ON FUNCTION ... IS 'Phase 11: archived_at IS NULL filter added. ...';` trio.)

## Tasks

Atomic. Each touches ≤ 3 files. Each maps to ≥ 1 checklist v3.1 row. Estimates in minutes; rolled up at the end.

### 1. Migrations

**Task 1.1 — Add `archived_at` column + partial index to `appointment_slots`**
- File(s): `supabase/migrations/20260605000050_add_archived_at_to_appointment_slots.sql` (NEW)
- Description: Write the migration per Migration Plan §1 above. `ALTER TABLE ... ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ;` then `CREATE INDEX IF NOT EXISTS idx_appointment_slots_active ON appointment_slots(shop_id) WHERE archived_at IS NULL;` then `COMMENT ON COLUMN`. No data backfill — existing rows are implicitly active (archived_at IS NULL).
- Acceptance: `psql staging -c "\d public.appointment_slots"` lists `archived_at | timestamp with time zone` and `idx_appointment_slots_active` shows in `\d` output as a partial index. `psql -c "SELECT count(*) FROM appointment_slots WHERE archived_at IS NULL"` matches the total row count (no row was accidentally marked archived).
- Checklist refs: 1.4 (enables RLS-equivalent filtering in subsequent RPCs), 3.3 (partial index supports the cascade EXPLAIN), 6.13 (column COMMENT).
- Estimate: 20

**Task 1.2 — Create `rebuild_shop_opening_hours` RPC**
- File(s): `supabase/migrations/20260605000100_rebuild_shop_opening_hours_rpc.sql` (NEW)
- Description: Write the function per Migration Plan §2 above. Hardening template byte-for-byte (mirrors `20260603001500_harden_dashboard_rpcs.sql:29-108`). Authz FIRST via `EXISTS shops WHERE id=p_shop_id AND user_id=auth.uid()`. JSONB shape validation second (`array` type, exactly 7 elements). `day_of_week BETWEEN 0 AND 7` tolerance check (locked correction 5). NO `::TIME` casts — `opens_at`/`closes_at` pass through as TEXT (locked correction 1). Atomic `DELETE WHERE shop_id = p_shop_id; INSERT ... SELECT FROM jsonb_array_elements(p_hours)` inside one tx.
- Acceptance: Smoke-test §a–§e print `OK:`: (a) non-owner → `42501`; (b) null `p_hours` → `22023 / HOURS_MUST_BE_ARRAY`; (c) 5-element array → `22023 / EXACTLY_7_DAYS_REQUIRED`; (d) array containing `day_of_week=9` → `22023 / DAY_OF_WEEK_OUT_OF_RANGE`; (e) happy path with 7 elements containing `"09:00 AM"` strings inserts 7 rows with TEXT values intact (no parse error). Atomicity §f: deliberately raise inside the function after DELETE (via a test wrapper that injects `RAISE EXCEPTION` between DELETE and INSERT) and confirm the original 7 rows remain.
- Checklist refs: 1.4 (authz), 1.10 (compensating tx: single-tx DELETE+INSERT), 2.1 (shape + range validation), 2.4 (stable error codes via HINTs), 2.5 (size cap implicit via 7-element validation), 6.13 (Big-O in COMMENT).
- Estimate: 50

**Task 1.3 — Create `archive_appointment_slot` RPC**
- File(s): `supabase/migrations/20260605000200_archive_appointment_slot_rpc.sql` (NEW)
- Description: Write the function per Migration Plan §3 above. NULL-input guard raises `22023 / NULL_NOT_ALLOWED`. Authz via `EXISTS appointment_slots JOIN shops WHERE s.id = p_slot_id AND sh.user_id = auth.uid()`. UPDATE includes `AND archived_at IS NULL` so re-archive is a silent no-op (idempotency by construction). Depends on Task 1.1 (column must exist).
- Acceptance: Smoke-test §g–§i print `OK:`: (g) non-owner → `42501`; (h) owner happy path sets `archived_at = now()` on first call; (i) owner second call on the same slot leaves `archived_at` unchanged (idempotent UPDATE).
- Checklist refs: 1.4 (authz), 2.1 (NULL guard), 2.18 (idempotency via `WHERE archived_at IS NULL`), 6.13 (Big-O).
- Estimate: 25

**Task 1.4 — Filter cascade: surfaces 1, 2 (create_booking_with_conflict_check + check_slot_availability)**
- File(s): `supabase/migrations/20260605000300_archive_filter_cascade.sql` (NEW — Part 1 of 3 in the same file)
- Description: Open the new file, copy the current body of `create_booking_with_conflict_check` from `20260517010000_booking_schema.sql:506-585` verbatim, and insert `AND archived_at IS NULL` into the `SELECT service_name, price ... WHERE id = p_slot_id` clause (around line 543). After the SELECT, add: `IF v_name IS NULL THEN RAISE EXCEPTION 'archived_slot' USING ERRCODE = 'P0001', HINT = 'SLOT_ARCHIVED'; END IF;`. Append `REVOKE ALL ... FROM PUBLIC; GRANT EXECUTE ... TO authenticated; COMMENT ON FUNCTION ... IS 'Phase 11: archived_at IS NULL filter on appointment_slots lookup. ...'`. Next, copy the current body of `check_slot_availability` from `20260517010000_booking_schema.sql:591-649` verbatim, insert `AND archived_at IS NULL` into the `SELECT slot_type, COALESCE(max_clients, 1) ... WHERE id = p_slot_id` clause (around line 632), and after that SELECT add: `IF NOT FOUND THEN RETURN jsonb_build_object('available', false, 'reason', 'archived'); END IF;`. Append the same REVOKE/GRANT/COMMENT trio.
- Acceptance: `grep -c 'archived_at IS NULL' supabase/migrations/20260605000300_archive_filter_cascade.sql | grep -v '^#'` returns at least 2 for this task's two functions (final whole-file gate is in Task 1.6). Smoke §j: archive a slot then call `check_slot_availability` for it → returns `{available:false, reason:'archived'}`. Smoke §k: archive a slot then call `create_booking_with_conflict_check` → raises `archived_slot` (P0001 / SLOT_ARCHIVED).
- Checklist refs: 1.4 (authz unchanged from upstream; predicate only narrows access), 1.10 (no compensating-tx regression — the archived-row raise happens BEFORE any INSERT in `create_booking_with_conflict_check`), 6.13 (COMMENT documents the Phase 11 delta).
- Estimate: 50

**Task 1.5 — Filter cascade: surfaces 3, 4 (generate_available_slots v1 + freelancer booking RPC)**
- File(s): `supabase/migrations/20260605000300_archive_filter_cascade.sql` (Part 2 of 3 — append to the same file)
- Description: Append to the same migration file. Copy the current body of `generate_available_slots` v1 from `20260517010000_booking_schema.sql:825-955` verbatim and insert `AND s.archived_at IS NULL` into the `SELECT s.* FROM appointment_slots s WHERE s.id = v_svc_id` clause (around line 869). The existing `IF NOT FOUND THEN CONTINUE;` already handles the archived-row skip — no other change needed. Then copy the current body of the freelancer booking RPC from `20260517020000_booking_hardening.sql` (around line 268–378, the function that includes the line-338 SELECT) verbatim and insert `AND archived_at IS NULL` into the `SELECT service_name, price ... WHERE id = p_slot_id` clause (line 338 region). Add the same archived-slot raise pattern from Task 1.4 (`IF v_name IS NULL THEN RAISE EXCEPTION 'archived_slot' ...`). Append REVOKE/GRANT/COMMENT for both.
- Acceptance: Smoke §l: archive a service used by `generate_available_slots` v1, call the RPC for a future date, the archived service is absent from the SETOF result. Smoke §m: archive a slot used by the freelancer booking RPC, call it, it raises `archived_slot`.
- Checklist refs: 1.4, 1.10, 6.13.
- Estimate: 45

**Task 1.6 — Filter cascade: surfaces 5, 6 (generate_available_slots variants 2 + 3)**
- File(s): `supabase/migrations/20260605000300_archive_filter_cascade.sql` (Part 3 of 3 — append to the same file)
- Description: Append to the same migration file. Copy the current body of `generate_available_slots` variant 2 from `20260525020000_fix_generate_slots_selected_workers.sql` (full body lines 24–156) verbatim and insert `AND s.archived_at IS NULL` into the `SELECT s.* FROM appointment_slots s WHERE s.id = v_svc_id` clause (line 84 region). Then copy `generate_available_slots` variant 3 from `20260525040000_fix_generate_slots_preselected_direct.sql` (full body lines ~20–163) verbatim and insert `AND s.archived_at IS NULL` into the `SELECT s.* ... WHERE s.id = v_svc_id` clause (line 82 region). Variant 3 is the LIVE version — its body is what production currently runs, so the predicate insertion here is the load-bearing change for the picker UX. Append REVOKE/GRANT/COMMENT for both. End-of-file whole-cascade gate: `grep -v '^--' supabase/migrations/20260605000300_archive_filter_cascade.sql | grep -c 'archived_at IS NULL'` returns at least 6 (one per surface).
- Acceptance: Smoke §n: archive a slot, call variant 3 (the live one) for a future date, the archived slot is absent from the SETOF result. Whole-file grep gate passes. `psql staging -f supabase/migrations/20260605000300_archive_filter_cascade.sql` applies cleanly (CREATE OR REPLACE for all six surfaces).
- Checklist refs: 1.4, 1.10, 6.13. **Note**: the high-risk delta callout for the cascade lives in §Rollout.
- Estimate: 50

### 2. Edge function update

**Task 2.1 — Patch `resolve-link/index.ts` to skip archived slots**
- File(s): `supabase/functions/resolve-link/index.ts`
- Description: At line 125, add `.is('archived_at', null)` to the chain so the final query reads `supabase.from("appointment_slots").select("id, service_name, description, duration, price, slot_type").eq("shop_id", shop.id).is("archived_at", null)`. This is the only `appointment_slots` read in the edge function. Public link guests must not see archived services in the picker. The change is additive and backward-compatible — pre-cascade rows have NULL `archived_at` so behavior is unchanged for existing data. (RESEARCH Finding 3 row "resolve-link/index.ts:125"; Finding 9 line 116 — without this, the link page lists archived services while subsequent calls reject them; confusing UX.)
- Acceptance: `grep -n "archived_at" supabase/functions/resolve-link/index.ts` returns ≥ 1. Smoke §o: archive a service, hit a public link for the shop, the service is absent from the JSON response.
- Checklist refs: 2.1 (consistency between read + write paths), 5.1 (no orphan UI — picker only shows bookable services).
- Estimate: 15

### 3. Dart exceptions

**Task 3.1 — Create `BusinessHoursException` hierarchy**
- File(s): `lib/presentation/features/shops/dashboard/data/exceptions/business_hours_exceptions.dart` (NEW)
- Description: Mirror `lib/wallet/data/exceptions/wallet_exceptions.dart` and `lib/presentation/features/shops/dashboard/data/exceptions/promotion_exceptions.dart` shape byte-for-byte. Base `BusinessHoursException` with `message` (logs only, may contain ids), `code` (stable identifier, default `'HOURS_GENERIC'`), `userMessage` (safe to render, default `'Something went wrong. Please try again.'`). Subtypes: `InvalidHoursPayloadException` (`HOURS_INVALID_PAYLOAD`, "Please re-check your hours for each day."), `DayOfWeekOutOfRangeException` (`HOURS_DOW_RANGE`, "One of the days is not in a valid range."), `HoursNotFoundException(String shopId)` (`HOURS_NOT_FOUND`, "We couldn't find this shop."), `HoursSaveFailedException` (`HOURS_SAVE_FAILED`, "We couldn't save the hours. Please try again."). Same `toString` format. NO `e.toString()` ever flows into `userMessage`.
- Acceptance: `dart analyze lib/presentation/features/shops/dashboard/data/exceptions/business_hours_exceptions.dart` clean. Shape pinned by Task 9.1.
- Checklist refs: 2.4 (stable error codes), 5.5 (no internal info in userMessage).
- Estimate: 20

**Task 3.2 — Create `ServiceManagementException` hierarchy**
- File(s): `lib/presentation/features/shops/dashboard/data/exceptions/service_management_exceptions.dart` (NEW)
- Description: Same template as Task 3.1. Base `ServiceManagementException` (default `code='SERVICE_GENERIC'`). Subtypes: `ServiceNotFoundException(String slotId)` (`SERVICE_NOT_FOUND`, "We couldn't find that service."), `ServiceArchiveFailedException` (`SERVICE_ARCHIVE_FAILED`, "We couldn't archive that service. Please try again."), `ServiceSaveFailedException` (`SERVICE_SAVE_FAILED`, "We couldn't save the service. Please try again."), `InvalidServicePayloadException` (`SERVICE_INVALID_PAYLOAD`, "Please re-check the service details.").
- Acceptance: `dart analyze` clean on the file. Shape pinned by Task 9.2.
- Checklist refs: 2.4, 5.5.
- Estimate: 15

### 4. Repository methods

**Task 4.1 — Extend `DashboardRepository` abstract API with three methods**
- File(s): `lib/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart`
- Description: Add three abstract method signatures to the existing abstract class:
  ```dart
  Future<void> rebuildShopOpeningHours({
    required String shopId,
    required List<OpeningHoursDraft> hours,
  });
  Future<List<AppointmentSlotDTO>> getActiveServices(String shopId);
  Future<void> archiveAppointmentSlot(String slotId);
  ```
  Add imports for `OpeningHoursDraft` (from `lib/presentation/features/shops/creation/domain/models/opening_hours_draft.dart`) and `AppointmentSlotDTO` (from `lib/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart`). Do NOT add concrete implementations here — this file is the abstract interface only.
- Acceptance: `grep -c 'rebuildShopOpeningHours\|getActiveServices\|archiveAppointmentSlot' lib/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart` returns 3. `flutter analyze` reports the supabase impl class missing these methods (expected — fixed in Task 4.2).
- Checklist refs: 1.7 (stateless interface), 6.13 (interface-level documentation via doc comments).
- Estimate: 15

**Task 4.2 — Implement the three methods on `SupabaseDashboardRepository` with typed-exception mapping**
- File(s): `lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart`, `lib/presentation/features/shops/dashboard/data/exceptions/business_hours_exceptions.dart` (import), `lib/presentation/features/shops/dashboard/data/exceptions/service_management_exceptions.dart` (import)
- Description: Implement the three methods.
  - `rebuildShopOpeningHours`: serialize hours per RESEARCH Finding 6 lines 87–95:
    ```dart
    final hoursJson = hours.map((h) => {
      'day_of_week': h.dayOfWeek,
      'opens_at':    h.opensAt,
      'closes_at':   h.closesAt,
      'is_closed':   h.isClosed,
    }).toList();
    await _supabase.rpc('rebuild_shop_opening_hours', params: {'p_shop_id': shopId, 'p_hours': hoursJson});
    ```
    Catch `PostgrestException` and map: `'42501'` → `HoursNotFoundException(shopId)`; `'22023'` with hint `'HOURS_MUST_BE_ARRAY'` or `'EXACTLY_7_DAYS_REQUIRED'` → `InvalidHoursPayloadException()`; `'22023'` with hint `'DAY_OF_WEEK_OUT_OF_RANGE'` → `DayOfWeekOutOfRangeException()`; fallback → `HoursSaveFailedException()`. Log via `AppLogger.warn('dashboard.rebuild_hours_failed', fields: {'shop_id': shopId, 'error': e.toString()})` BEFORE the throw.
  - `getActiveServices`: `await _supabase.from('appointment_slots').select('*').eq('shop_id', shopId).isFilter('archived_at', null).order('created_at', ascending: false).limit(200);` then map rows to `AppointmentSlotDTO`. `.limit(200)` is the resource cap (checklist 2.5).
  - `archiveAppointmentSlot`: `await _supabase.rpc('archive_appointment_slot', params: {'p_slot_id': slotId});`. Map `'42501'` → `ServiceNotFoundException(slotId)`; `'22023'` → `InvalidServicePayloadException()`; fallback → `ServiceArchiveFailedException()`. Log via `AppLogger.warn('service.archive_failed', fields: {'shop_id': '<unknown>', 'slot_id': slotId, 'error': e.toString()})` BEFORE the throw.
  NEVER interpolate `$e` into the throw message. NEVER use `e.toString().contains(...)` for branching.
- Acceptance: `grep -n "rebuildShopOpeningHours\|getActiveServices\|archiveAppointmentSlot" lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart` returns ≥ 3. `grep -n 'e\.toString()\.contains' lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart` returns 0. `flutter analyze` clean.
- Checklist refs: 2.1 (param validation lives in RPC; client never trusts), 2.4 (typed exceptions, no `$e`), 2.5 (`.limit(200)`), 4.4 (logger redacts; `e.toString()` only in `fields:`), 5.5 (`userMessage` only path to UI).
- Estimate: 60

### 5. BusinessHoursEditController + BusinessHoursScreen

**Task 5.1 — `BusinessHoursEditController` (StateNotifier scoped to the dashboard feature)**
- File(s): `lib/presentation/features/shops/dashboard/presentation/controllers/business_hours_edit_controller.dart` (NEW)
- Description: Per locked correction 6, do NOT reuse `HoursNotifier` from the creation flow — `HoursNotifier._updateDraft()` at `lib/presentation/features/shops/creation/providers/hours_provider.dart:77-83` writes back into `shopCreationProvider` / `freelancerCreationProvider` on every state change, which would silently overwrite a half-completed shop-creation draft. Introduce a fresh local controller.
  ```dart
  class BusinessHoursEditController extends StateNotifier<AsyncValue<List<OpeningHoursDraft>>> {
    final String _shopId;
    final DashboardRepository _repo;
    BusinessHoursEditController(this._shopId, this._repo) : super(const AsyncValue.loading()) { _load(); }
    Future<void> _load() async {
      try {
        final shop = await _repo.getShopDetails(_shopId);  // existing method
        state = AsyncValue.data(List.of(shop.openingHours));
      } catch (e, st) { state = AsyncValue.error(...); }
    }
    void updateDay(int dayOfWeek, {String? opensAt, String? closesAt, bool? isClosed}) { ... }
    Future<void> save() async { await _repo.rebuildShopOpeningHours(shopId: _shopId, hours: state.value!); }
    void discard() => _load();  // re-fetch from server
  }
  ```
  Lifecycle: load from server on construction, in-memory edits during the session, save once, discard re-loads. NO writes to `shopCreationProvider` or `freelancerCreationProvider`. NO Hive persistence. NO global `_selectedDaysProvider`-style top-level providers.
  Expose `businessHoursEditControllerProvider = StateNotifierProvider.family<BusinessHoursEditController, AsyncValue<List<OpeningHoursDraft>>, String>((ref, shopId) => BusinessHoursEditController(shopId, ref.read(dashboardRepositoryProvider)));` in `lib/presentation/features/shops/dashboard/providers/dashboard_providers.dart`.
  Validation: a setter for `closesAt` / `opensAt` MUST NOT block invalid input (the row widget handles its own inline error); a public `bool get isValid` returns `false` if any non-closed day has `closesAt <= opensAt` (parse uses the same 12h-aware logic as the existing form widget). `save()` throws `InvalidHoursPayloadException` BEFORE the RPC call if `!isValid`.
- Acceptance: File compiles. Unit test from Task 9.3 verifies: load → state becomes `AsyncValue.data`; updateDay → state updates without triggering any write to `shopCreationProvider` (assert via mock that `setOpeningHours` is never called); save calls `_repo.rebuildShopOpeningHours` exactly once with the in-memory list; discard re-calls `_repo.getShopDetails`. `grep -n 'shopCreationProvider\|freelancerCreationProvider' lib/presentation/features/shops/dashboard/presentation/controllers/business_hours_edit_controller.dart` returns 0.
- Checklist refs: 1.6 (concurrency: scoped StateNotifier — no shared global), 1.10 (atomic save via single RPC), 2.4 (validation raises typed exception before RPC), 2.17 (controller isolates business rule from I/O).
- Estimate: 50

**Task 5.2 — `BusinessHoursScreen` UI**
- File(s): `lib/presentation/features/shops/dashboard/presentation/screens/business_hours_screen.dart` (NEW)
- Description: `ConsumerStatefulWidget` (or `ConsumerWidget` if state lives entirely in the controller). Watches `businessHoursEditControllerProvider(shopId)`. Renders an AppBar with title "Business Hours", a Save button (disabled during loading or when `!controller.isValid`), and a Discard / Cancel that pops without saving. Body: AsyncValue switch — `loading` shows a centered spinner, `error` shows `error_state.dart` with retry, `data` renders 7 rows (one per weekday, ordered 1..7 then 0 if present, i.e. Monday → Sunday by display). Each row: day name (from `_dayNames` const matching `service_form_modal.dart:43-51`), a `Switch` for `isClosed`, two `TimePicker`-launching text fields for `opensAt` / `closesAt` (formatted `"HH:MM AM"` via the existing helper in `set_hours_screen.dart:122-123`), and an inline error string when `closesAt <= opensAt` on a non-closed day. Save button onPressed: `try { await controller.save(); ref.invalidate(shopDetailsProvider(shopId)); Navigator.pop(context); Snackbar.success(context, 'Hours saved'); } on BusinessHoursException catch (e) { Snackbar.error(context, e.userMessage); }`. Spinner overlay while save is in flight.
  Must NOT pass `hours` through to any `ServiceFormModal` invocation (that's Task 7's screen). Must NOT call `hoursProvider`.
- Acceptance: Screen renders 7 day rows when hydrated. Save button is disabled when any non-closed day has `closesAt <= opensAt`. Save flow: tap → spinner → success Snackbar → pop. Error flow: forced PostgrestException → `Snackbar.error` shows `userMessage` only (no `PostgrestException(...)` text). Widget test in Task 9.4 covers the disabled/enabled save states and the invalidation call. `grep -n 'hoursProvider\|shopCreationProvider' lib/presentation/features/shops/dashboard/presentation/screens/business_hours_screen.dart` returns 0.
- Checklist refs: 5.1 (inline error + Snackbar both actionable), 5.2 (loading spinner ≤ 200ms via existing AsyncValue flow), 5.5 (only `userMessage` reaches UI).
- Estimate: 55

### 6. ServiceFormModal refactor (hours param + bufferMinutes fix)

**Task 6.1 — Refactor `ServiceFormModal` to take `availableHours` as a constructor parameter; fix `bufferMinutes: 15` regression**
- File(s): `lib/presentation/features/shops/creation/presentation/widgets/service_form_modal.dart`, `lib/presentation/features/shops/creation/presentation/screens/set_hours_screen.dart`
- Description: Per locked corrections 7 + 8:
  (a) Add a required constructor parameter `final List<OpeningHoursDraft> availableHours;` (lines 8–22 region — add to constructor signature). Remove `import 'package:nano_embryo/presentation/features/shops/creation/providers/hours_provider.dart';` at line 4 — no longer needed. Replace the `_loadShopHours()` body at lines 86–116 with a synchronous `_shopHours = List.of(widget.availableHours); _isLoadingHours = false; _hasHoursError = widget.availableHours.isEmpty;` and call it from `initState()` (no `ref.read(hoursProvider)`). The `_selectedDaysProvider` top-level `StateProvider` at line 6 stays in place for now (it is app-global but scoped to one open modal — out of scope to fix; documented in §Out of scope carry-overs only if a future review asks).
  (b) Fix `bufferMinutes: 15` at line 585 to `bufferMinutes: widget.initialService?.bufferMinutes ?? 0`. This is the regression-prevention fix; without it, every edit silently overwrites the saved buffer minutes with 15.
  (c) Update the one existing call site at `lib/presentation/features/shops/creation/presentation/screens/set_hours_screen.dart` (and any other call site discovered by `grep -rn 'ServiceFormModal(' lib/`) to pass `availableHours: ref.read(hoursProvider)` so the creation-flow behavior is unchanged. New call sites in Task 7 will pass shop-loaded hours.
- Acceptance: `grep -n "ref.read(hoursProvider)" lib/presentation/features/shops/creation/presentation/widgets/service_form_modal.dart` returns 0. `grep -n "bufferMinutes: 15" lib/presentation/features/shops/creation/presentation/widgets/service_form_modal.dart` returns 0. `grep -n "bufferMinutes: widget.initialService" lib/presentation/features/shops/creation/presentation/widgets/service_form_modal.dart` returns 1. All call sites of `ServiceFormModal(` pass `availableHours:`. `flutter analyze` clean.
- Checklist refs: 1.6 (decouples from global `hoursProvider`), 2.4 (regression fix prevents stable behavior surprise), 6.4 (negative: edit-mode save must NOT change bufferMinutes when the user didn't touch it — covered by Task 9.5).
- Estimate: 35

### 7. ServiceManagementScreen + ServiceEditScreen wiring

**Task 7.1 — `ServiceManagementScreen` list view + archive flow**
- File(s): `lib/presentation/features/shops/dashboard/presentation/screens/service_management_screen.dart` (NEW), `lib/presentation/features/shops/dashboard/providers/dashboard_providers.dart`
- Description: Add a new family provider in `dashboard_providers.dart`: `final activeServicesProvider = FutureProvider.family<List<AppointmentSlotDTO>, String>((ref, shopId) async => ref.read(dashboardRepositoryProvider).getActiveServices(shopId));`. New `ServiceManagementScreen extends ConsumerWidget` watches `activeServicesProvider(shopId)`. AppBar title "Service Management", a "+" FAB that pushes `ServiceEditScreen(shopId: shopId, initial: null)` (create mode). Body: AsyncValue switch. `data` renders a `ListView.separated` over services: each row shows `service_name`, `price` + `duration`, and a trailing `more_vert` icon. Tap row → push `ServiceEditScreen(shopId: shopId, initial: dto)`. Long-press OR `more_vert` → bottom-sheet with "Archive" and "Cancel" actions. "Archive" calls a confirmation dialog ("Archive this service? It will no longer be bookable."), and on confirm: `try { await ref.read(dashboardRepositoryProvider).archiveAppointmentSlot(dto.id); ref.invalidate(activeServicesProvider(shopId)); Snackbar.success(context, 'Service archived'); } on ServiceManagementException catch (e) { Snackbar.error(context, e.userMessage); }`. Pop on success. After any `ServiceEditScreen` returns truthy, invalidate `activeServicesProvider(shopId)` so the list refreshes. Empty-state widget when the list is empty: "No services yet. Tap + to add one."
- Acceptance: Screen renders. Archive → row disappears from list after invalidation. Widget test in Task 9.6 covers (a) row count = service count from mocked repo, (b) archive confirmation flow calls the repo method exactly once, (c) error → `Snackbar.error` shows `userMessage`. `grep -n 'archiveAppointmentSlot' lib/presentation/features/shops/dashboard/presentation/screens/service_management_screen.dart` returns 1.
- Checklist refs: 1.10 (single-statement archive is atomic by construction), 5.1 (confirmation dialog + actionable Snackbar), 5.5 (`userMessage` only), 6.4 (negative: error path covered).
- Estimate: 50

**Task 7.2 — `ServiceEditScreen` wiring (hosts the refactored `ServiceFormModal`)**
- File(s): `lib/presentation/features/shops/dashboard/presentation/screens/service_edit_screen.dart` (NEW)
- Description: New `ConsumerWidget`. Constructor: `ServiceEditScreen({required this.shopId, this.initial, super.key})`. Watches `shopDetailsProvider(shopId)` to get the loaded shop's `openingHours`. AsyncValue switch — `loading` spinner, `error` retry state, `data`: render `ServiceFormModal(initialService: initial, availableHours: shop.openingHours, shopId: shopId, availableWorkers: shop.workers, onSave: _handleSave)`. `_handleSave(AppointmentSlotDTO dto)`: branch on `initial == null`. Create-mode: single Postgrest insert `await _supabase.from('appointment_slots').insert({...dto.toJson(), 'shop_id': shopId}).select('id').single();` — atomic by construction. Edit-mode: single Postgrest update `await _supabase.from('appointment_slots').update({...dto.toJson()}).eq('id', dto.id).select('id').single();` — atomic by construction. Catch `PostgrestException`, log via `AppLogger.warn('service.save_failed', fields: {'shop_id': shopId, 'slot_id': dto.id, 'error': e.toString()})`, throw `ServiceSaveFailedException()`. On success: `ref.invalidate(activeServicesProvider(shopId))`, `Navigator.pop(context, true)` so the list screen knows to refresh. On exception: `Snackbar.error(context, e.userMessage)`. Do NOT call `archive_appointment_slot` here — that lives in the list screen.
- Acceptance: Screen pushes from list. Existing services pre-populate the form (initial passed through). Save → list refreshes on return. `grep -n 'rpc.*archive_appointment_slot' lib/presentation/features/shops/dashboard/presentation/screens/service_edit_screen.dart` returns 0 (archive lives on the list screen). `grep -n 'ServiceFormModal' lib/presentation/features/shops/dashboard/presentation/screens/service_edit_screen.dart` returns 1. `flutter analyze` clean.
- Checklist refs: 1.10 (single-statement save is atomic), 2.4 (typed exception path), 4.4 (logger redacts), 5.5.
- Estimate: 45

### 8. tools_screen.dart wiring

**Task 8.1 — Wire Card 4 (Business Hours) and Card 5 (Service Management) to the new screens**
- File(s): `lib/presentation/features/shops/dashboard/presentation/screens/tools_screen.dart`
- Description: Locked correction 9. Case 4 (lines 156–167 region): set `enabled: true`, replace `onTap: () => Snackbar.info(context, 'Coming in a future release.')` with `onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BusinessHoursScreen(shopId: shopId)))`, and change the card title from `'Coming Soon'` to `'Configure →'`. Case 5 (lines 168–179 region): same treatment, route to `ServiceManagementScreen(shopId: shopId)`, title `'Manage →'`. Add the two imports. KEEP the `Snackbar` import — Case 3 Payment Settings still uses `Snackbar.info(context, 'Loading shop details…')` at line 134. After both edits, NO card in `ToolsScreen` should be in the `Coming Soon` state, and the file's `grep` of `'Coming in a future release.'` must return 0. Also update the comment block at the top (lines 9–10) to match the new state.
- Acceptance: `grep -n "Coming in a future release." lib/presentation/features/shops/dashboard/presentation/screens/tools_screen.dart` returns 0. `grep -n "Snackbar" lib/presentation/features/shops/dashboard/presentation/screens/tools_screen.dart` returns ≥ 1 (case 3 import retained). `grep -n "BusinessHoursScreen\|ServiceManagementScreen" lib/presentation/features/shops/dashboard/presentation/screens/tools_screen.dart` returns ≥ 2. Both card `enabled` values are `true`. `flutter analyze` clean.
- Checklist refs: 5.1 (cards now actionable), 5.5 (no leak — both navigations go to screens that funnel exceptions through `userMessage`).
- Estimate: 20

### 9. Tests

**Task 9.1 — `BusinessHoursException` unit test**
- File(s): `test/presentation/features/shops/dashboard/data/exceptions/business_hours_exceptions_test.dart` (NEW)
- Description: Mirror `promotion_exceptions_test.dart` shape (which mirrors `WalletException`). Tests: (a) base `BusinessHoursException('boom')` has `code == 'HOURS_GENERIC'` + default `userMessage`; (b) `toString()` returns `'BusinessHoursException(HOURS_GENERIC): boom'`; (c) each subtype exposes its declared `code` and `userMessage`; (d) `HoursNotFoundException('shop-xyz')` does NOT include `'shop-xyz'` in `userMessage` (PII isolation).
- Acceptance: `flutter test test/presentation/features/shops/dashboard/data/exceptions/business_hours_exceptions_test.dart` passes.
- Checklist refs: 2.4, 5.5, 6.7.
- Estimate: 20

**Task 9.2 — `ServiceManagementException` unit test**
- File(s): `test/presentation/features/shops/dashboard/data/exceptions/service_management_exceptions_test.dart` (NEW)
- Description: Same template as Task 9.1 for the service-management hierarchy.
- Acceptance: `flutter test test/presentation/features/shops/dashboard/data/exceptions/service_management_exceptions_test.dart` passes.
- Checklist refs: 2.4, 5.5, 6.7.
- Estimate: 15

**Task 9.3 — `BusinessHoursEditController` unit test**
- File(s): `test/presentation/features/shops/dashboard/presentation/controllers/business_hours_edit_controller_test.dart` (NEW)
- Description: Mock `DashboardRepository` via `mocktail`. Tests: (a) on construction, controller calls `getShopDetails(shopId)` exactly once and state transitions to `AsyncValue.data`; (b) `updateDay(2, closesAt: '08:00 PM')` mutates state without calling any creation-flow provider (assert via spy that `shopCreationProvider` / `freelancerCreationProvider` are not even referenced — verify by asserting the controller's source file contains 0 matches for those strings via `Process.run('grep', ...)` OR by injecting fake providers with `Listener` and asserting zero notifications); (c) `save()` calls `_repo.rebuildShopOpeningHours` exactly once with the in-memory list; (d) `save()` with a non-closed day where `closesAt <= opensAt` throws `InvalidHoursPayloadException` BEFORE any repo call; (e) `discard()` re-calls `getShopDetails`; (f) repo throwing `HoursNotFoundException` surfaces as state `AsyncValue.error` with the typed exception preserved (not raw `PostgrestException`).
- Acceptance: `flutter test test/presentation/features/shops/dashboard/presentation/controllers/business_hours_edit_controller_test.dart` passes. Test (b) explicitly asserts the controller does NOT touch the creation providers.
- Checklist refs: 1.6, 2.4, 6.1 (edge cases incl. closes_at <= opens_at), 6.4 (negative — creation provider not touched).
- Estimate: 50

**Task 9.4 — `BusinessHoursScreen` widget test (smoke)**
- File(s): same file as Task 9.3 OR a sibling — recommend a single file per surface, so this lives at `test/presentation/features/shops/dashboard/presentation/screens/business_hours_screen_test.dart` (NEW)
- Description: Use a `ProviderScope` override of `dashboardRepositoryProvider` with a fake returning a fixed `List<OpeningHoursDraft>`. Tests: (a) on first frame, 7 day rows visible; (b) tapping `isClosed` toggle on Wednesday updates the toggle state; (c) Save button is disabled when one non-closed day has `closesAt <= opensAt`; (d) Save tap calls `repo.rebuildShopOpeningHours` exactly once; (e) Save error → `Snackbar.error` shows `userMessage` (assert via `find.text('We couldn\'t save the hours. Please try again.')`); (f) on success, `Navigator.pop` is called.
- Acceptance: `flutter test test/presentation/features/shops/dashboard/presentation/screens/business_hours_screen_test.dart` passes. All 6 assertions green.
- Checklist refs: 5.1, 5.5, 6.4.
- Estimate: 55

**Task 9.5 — `ServiceFormModal` regression test for `bufferMinutes` preservation**
- File(s): `test/presentation/features/shops/creation/presentation/widgets/service_form_modal_buffer_test.dart` (NEW — co-located with existing creation tests if any, else in the path above)
- Description: Pump `ServiceFormModal(initialService: AppointmentSlotDTO(... bufferMinutes: 25), availableHours: [...7 days...], shopId: 'sxx', onSave: capturedDto)`. Without touching any field, tap Save. Assert `capturedDto.bufferMinutes == 25` (NOT 15). This is the regression-prevention test for locked correction 7. Second test: `initialService` with `bufferMinutes == null` → `capturedDto.bufferMinutes == 0` (the `?? 0` fallback).
- Acceptance: `flutter test test/presentation/features/shops/creation/presentation/widgets/service_form_modal_buffer_test.dart` passes both cases.
- Checklist refs: 6.4 (negative: edit-mode save must NOT change unchanged fields), 2.4 (regression pinned).
- Estimate: 30

**Task 9.6 — `ServiceManagementScreen` + `getActiveServices` repository test**
- File(s): `test/presentation/features/shops/dashboard/data/repositories/services_repository_test.dart` (NEW)
- Description: Mock `SupabaseClient` via `mocktail`. Tests:
  (a) `getActiveServices` query chain includes `.isFilter('archived_at', null)` AND `.limit(200)` AND `.eq('shop_id', ...)` — assert via verify-call counters.
  (b) `archiveAppointmentSlot` issues exactly one `.rpc('archive_appointment_slot', params: {'p_slot_id': ...})` call.
  (c) When `.rpc` throws `PostgrestException(code: '42501')`, caller receives `ServiceNotFoundException`.
  (d) When `.rpc` throws `PostgrestException(code: '22023')`, caller receives `InvalidServicePayloadException`.
  (e) `rebuildShopOpeningHours` serializes `OpeningHoursDraft` to the JSONB shape from RESEARCH Finding 6 lines 87–95 (assert the params dict's `p_hours[0]` keys are exactly `day_of_week`, `opens_at`, `closes_at`, `is_closed` — NOT the camelCase variants).
  (f) When `rebuildShopOpeningHours` RPC throws `PostgrestException(code: '22023', hint: 'EXACTLY_7_DAYS_REQUIRED')`, caller receives `InvalidHoursPayloadException`.
  (g) When the RPC throws `PostgrestException(code: '22023', hint: 'DAY_OF_WEEK_OUT_OF_RANGE')`, caller receives `DayOfWeekOutOfRangeException`.
- Acceptance: `flutter test test/presentation/features/shops/dashboard/data/repositories/services_repository_test.dart` passes. All 7 assertions green.
- Checklist refs: 2.4 (exception mapping asserted, no string-match), 2.5 (`.limit(200)` asserted), 3.1 (pagination cap asserted), 6.4.
- Estimate: 55

**Task 9.7 — SQL smoke-test script**
- File(s): `.planning/phases/11-business-hours-and-services/sql/11_smoke_tests.sql` (NEW)
- Description: Hand-runnable script against a staging branch DB. Sections (acceptance markers in `RAISE NOTICE 'OK: <name>'` per section):
  (a) **rebuild_shop_opening_hours authz** — non-owner uid → `42501`.
  (b) **rebuild_shop_opening_hours shape** — null payload → `22023 / HOURS_MUST_BE_ARRAY`.
  (c) **rebuild_shop_opening_hours count** — 5-element array → `22023 / EXACTLY_7_DAYS_REQUIRED`.
  (d) **rebuild_shop_opening_hours dow range** — element with `day_of_week=9` → `22023 / DAY_OF_WEEK_OUT_OF_RANGE`.
  (e) **rebuild_shop_opening_hours happy** — 7 elements with `"09:00 AM"` strings → 7 rows, `opens_at` values match input verbatim (TEXT, no parse error).
  (f) **rebuild_shop_opening_hours atomicity** — wrap the RPC body in a test wrapper that `RAISE EXCEPTION` after DELETE; verify pre-existing rows remain by checking `count(*)` before and after.
  (g) **archive_appointment_slot authz** — non-owner → `42501`.
  (h) **archive_appointment_slot happy** — owner call sets `archived_at` to a non-null timestamp.
  (i) **archive_appointment_slot idempotent** — owner second call leaves `archived_at` unchanged (assert `archived_at_before = archived_at_after`).
  (j) **check_slot_availability filter** — archive a slot, call → returns `{available:false, reason:'archived'}`.
  (k) **create_booking_with_conflict_check filter** — archive a slot, call → raises `archived_slot` (P0001 / SLOT_ARCHIVED).
  (l) **generate_available_slots v1 filter** — archive a slot, call for a future date → slot is absent from SETOF.
  (m) **freelancer booking RPC filter** — archive a slot used by the freelancer RPC → raises `archived_slot`.
  (n) **generate_available_slots variant 3 (LIVE) filter** — archive a slot, call → slot is absent. This is the load-bearing picker assertion.
  (o) **resolve-link archive filter** — archive a slot, GET the public link, the archived slot is absent from the JSON response. (Run via curl, not psql.)
- Acceptance: Each section ends with `RAISE NOTICE 'OK: <case-name>';` on success. Script run end-to-end via `psql $STAGING_DB_URL -f .planning/phases/11-business-hours-and-services/sql/11_smoke_tests.sql` prints `OK:` for every SQL case; case (o) is a separate curl assertion documented inline.
- Checklist refs: 6.1, 6.2, 6.4, 2.18.
- Estimate: 75

### 10. Manual UAT

**Task 10.1 — Business Hours editor UAT (atomicity proof)**
- File(s): n/a (manual)
- Description: On a real device against staging: (1) Open Tools tab → tap "Business Hours". (2) Toggle Saturday closed → on; change Friday close from `05:00 PM` to `08:00 PM`. (3) Tap Save → spinner → success Snackbar → pop. (4) Re-open Business Hours → verify the changes persisted. (5) **Atomicity proof**: enable airplane mode on the device, re-open Business Hours, change Monday open to `07:00 AM`, tap Save → expect `Snackbar.error` with sanitized message. Disable airplane mode, re-open Business Hours, verify that Monday is still at its previous saved value (NOT `07:00 AM`) — the failed save did NOT leave a partial write. (6) Capture screenshots for the PR.
- Acceptance: Step 4 shows persistence. Step 5 shows pre-save state is intact (the atomicity claim). Screenshots attached.
- Checklist refs: 1.10 (atomicity), 5.1, 8.2.
- Estimate: 25

**Task 10.2 — Service Management UAT (archive cascade + edit price + add new + buffer regression)**
- File(s): n/a (manual)
- Description: On a real device against staging: (1) Open Tools tab → tap "Service Management". (2) Tap a service → change price by 50% → Save → verify the new price appears in the list. (3) Open the customer-facing booking flow for the same shop, pick a future date, verify the new price appears in the picker (filter cascade verification). (4) Back to Service Management → long-press a service → Archive → confirm. (5) Verify it disappears from the list. (6) Open the customer-facing booking flow again → verify the archived service is absent from the picker AND from the public link landing page (resolve-link cascade verification — open the share-link URL in a private browser tab). (7) Add a new service via the FAB → fill all fields → Save → verify it appears in the list AND in the booking flow. (8) **bufferMinutes regression check**: edit an existing service that had `bufferMinutes=25` (set this server-side in a staging row before the UAT). Without touching the buffer field in the form, tap Save. Verify in the DB that `buffer_minutes` is still 25, NOT 15. Capture screenshots throughout.
- Acceptance: All 8 steps observed. Step 6 confirms the filter cascade is live end-to-end. Step 8 confirms locked correction 7 holds. Screenshots attached.
- Checklist refs: 5.1, 5.2, 8.2, 6.4 (step 8: negative — Save did NOT change a field the user didn't touch).
- Estimate: 25

## Verification per task

| Task | Observable acceptance |
|------|-----------------------|
| 1.1 | `\d public.appointment_slots` shows `archived_at` + `idx_appointment_slots_active` partial index. |
| 1.2 | Smoke §a–§f print `OK:`. |
| 1.3 | Smoke §g–§i print `OK:`. |
| 1.4 | Smoke §j, §k print `OK:`. |
| 1.5 | Smoke §l, §m print `OK:`. |
| 1.6 | Smoke §n prints `OK:`; whole-file grep gate for `archived_at IS NULL` ≥ 6. |
| 2.1 | `grep -n "archived_at" supabase/functions/resolve-link/index.ts` ≥ 1; smoke §o (curl) confirms archived absent. |
| 3.1 | `dart analyze` clean on the file; Task 9.1 passes. |
| 3.2 | `dart analyze` clean on the file; Task 9.2 passes. |
| 4.1 | `grep -c 'rebuildShopOpeningHours\|getActiveServices\|archiveAppointmentSlot' lib/.../dashboard_repository.dart` = 3. |
| 4.2 | `grep -n "e\.toString()\.contains" lib/.../supabase_dashboard_repository.dart` = 0; Task 9.6 passes. |
| 5.1 | `grep -n 'shopCreationProvider\|freelancerCreationProvider' lib/.../business_hours_edit_controller.dart` = 0; Task 9.3 passes. |
| 5.2 | `grep -n 'hoursProvider\|shopCreationProvider' lib/.../business_hours_screen.dart` = 0; Task 9.4 passes. |
| 6.1 | `grep -n "bufferMinutes: 15" lib/.../service_form_modal.dart` = 0; `grep -n "ref.read(hoursProvider)" lib/.../service_form_modal.dart` = 0; Task 9.5 passes. |
| 7.1 | `grep -n 'archiveAppointmentSlot' lib/.../service_management_screen.dart` = 1; archive flow round-trips. |
| 7.2 | `grep -n 'rpc.*archive_appointment_slot' lib/.../service_edit_screen.dart` = 0 (archive is list-screen only); create + edit issue single Postgrest statements. |
| 8.1 | `grep -n "Coming in a future release." lib/.../tools_screen.dart` = 0; `grep -n "Snackbar" lib/.../tools_screen.dart` ≥ 1 (case 3 import retained). |
| 9.1 | Test file green. |
| 9.2 | Test file green. |
| 9.3 | Test file green; (b) asserts creation providers are not touched. |
| 9.4 | Test file green; 6 assertions. |
| 9.5 | Test file green; bufferMinutes preserved both branches. |
| 9.6 | Test file green; 7 assertions; (a) asserts call-count `.isFilter('archived_at', null)` exactly 1. |
| 9.7 | `psql -f` prints `OK:` for §a–§n; §o curl outputs absent. |
| 10.1 | Atomicity demonstrated (step 5 = no partial write); screenshots in PR. |
| 10.2 | Filter cascade demonstrated end-to-end (step 6 = archive absent from picker AND public link); bufferMinutes preserved (step 8); screenshots in PR. |

## Risk register

| ID | Risk | Severity | Mitigation in this plan |
|----|------|----------|--------------------------|
| R1 | **Archive filter cascade partial-rollout**. If any of the 6 SQL surfaces + edge function is missed, archive becomes cosmetic and a customer can still book an archived service. The cascade is BIGGER than SPEC said (RESEARCH Finding 3 line 51 — locked correction 4). | P0 | One migration `20260605000300_archive_filter_cascade.sql` recreates all 6 surfaces in a single deploy. Tasks 1.4–1.6 split for atomic review (each task ≤ 2 surfaces ≤ 3 files). Task 2.1 ships the edge function in the same release. Smoke §j–§o exercise every surface. §Rollout step 3 calls this out as the highest-risk delta. |
| R2 | **`bufferMinutes: 15` regression** ships unfixed. Without locked correction 7, every edit silently overwrites the user's buffer with 15 the moment the form is first used as an edit screen. | P0 (fixed) | Task 6.1 fixes the hard-code. Task 9.5 pins the regression with two tests (preserved + null-fallback). Task 10.2 step 8 confirms it manually. |
| R3 | **`shop_opening_hours.opens_at` TEXT vs TIME** drift would silently corrupt every save attempt from the new editor — SPEC's `::TIME` cast would reject every `"09:00 AM"` payload. | P0 (fixed) | Migration 2 drops the cast per locked correction 1; smoke §e asserts `"09:00 AM"` round-trips intact. |
| R4 | **`day_of_week` range mismatch** (Dart 1..7 vs server EXTRACT(DOW) 0..6) — pre-existing carry-over. Rejecting either range on first save would break legacy shops. | P0 (mitigated) | RPC accepts `BETWEEN 0 AND 7` per locked correction 5. Mismatch documented as carry-over in §Out of scope; smoke §d exercises the edge of the validation. |
| R5 | **`HoursNotifier` reuse silently overwrites the creation draft.** If `BusinessHoursScreen` accidentally reuses `hoursProvider`, opening Business Hours mid-shop-creation wipes the draft (RESEARCH Finding 4 line 60–67). | P1 (avoided) | Locked correction 6: dedicated `BusinessHoursEditController`. Task 5.1 + 5.2 grep gates assert zero references to `shopCreationProvider` / `freelancerCreationProvider` / `hoursProvider`. Task 9.3 (b) asserts the controller does not touch them at runtime. |
| R6 | **Atomicity claim regression** — if a future reviewer "optimizes" the rebuild RPC to a Dart-side loop or splits DELETE / INSERT into separate calls, the no-partial-write guarantee is gone. | P1 | `COMMENT ON FUNCTION rebuild_shop_opening_hours` documents the atomicity claim (Task 1.2). Task 10.1 step 5 is a forcing function: airplane-mode-mid-save test is part of the DoD. |
| R7 | **Day-of-week range mismatch** + creation flow loop bug + `_parseTime` AM/PM bug all remain. Phase 11 ships with these latent issues. | P2 (accepted) | Explicitly listed in §Out of scope (carry-over bugs). PR description re-states each one. Phase 12.1 ticket filed for the atomic shop publish path. |
| R8 | **Analytics reads still include archived slots.** Past-period reports include archived services. (RESEARCH Finding 10 line 138.) | P2 (accepted) | Documented in §Out of scope (carry-over bugs). Decision: archived services existed at booking time, so including them in historical reports is technically correct. P2 follow-up flagged in PR. |
| R9 | **`ServiceFormModal._selectedDaysProvider` is a top-level `StateProvider`** — two simultaneously-open modals would collide. (RESEARCH Finding 5 line 80.) | P2 (accepted) | Modals are non-stacking in current UX; collision unreachable in practice. The `Future.microtask` reset in `initState` clears stale state on the next open. Out of Phase 11 scope to refactor — would require a Riverpod family rewrite. |
| R10 | **Race between rebuild and concurrent reader.** Between the `DELETE` and `INSERT` inside the RPC, a reader (e.g. `check_shop_hours`) holding a snapshot before the DELETE could miss the new rows. | P2 | Postgres uses transaction-level snapshot isolation by default — a concurrent reader sees either the pre-DELETE state or the post-INSERT state, never the gap. SECURITY DEFINER + single tx makes this safe. Verified by smoke §f (atomicity) which exercises rollback. |

## Checklist v3.1 coverage matrix

| Check | Task(s) |
|-------|---------|
| 1.4 Authz at every access | 1.2, 1.3, 1.4, 1.5, 1.6 (RPC `auth.uid()` gates); 4.2 (typed exception on `42501`) |
| 1.6 Concurrency risks mitigated | 5.1 (scoped StateNotifier, no global state shared with creation flow) |
| 1.7 Stateless interface | 4.1 (abstract repository methods are stateless) |
| 1.10 Compensating tx | 1.2 (single-tx DELETE+INSERT); 1.4 (archived-slot raise before INSERT); 7.1, 7.2 (single-statement Postgrest ops) |
| 2.1 Input sanitization | 1.2 (shape + range), 1.3 (NULL guard), 4.2 (params via RPC), 7.2 (Postgrest schema enforcement) |
| 2.4 Errors don't leak | 3.1, 3.2 (typed exception hierarchies); 4.2 (mapping); 5.2, 7.1, 7.2 (UI shows `userMessage` only); 6.1 (form regression pinned) |
| 2.5 Resource limits | 4.2 (`.limit(200)` on `getActiveServices`); 1.2 (7-element cap); 1.1 (partial index keeps cascade O(active rows)) |
| 2.17 Side effects isolated | 5.1 (controller logic separate from RPC I/O) |
| 2.18 Idempotency | 1.3 (`WHERE archived_at IS NULL` makes re-archive a no-op); 9.7 §i smoke verifies |
| 2.22 Audit log | n/a — no money handled in Phase 11; existing booking_audit_log unchanged |
| 3.1 Pagination | 4.2 (`.limit(200)`); 9.6 (a) asserts |
| 3.2 No N+1 | 4.2 (`getActiveServices` is a single query); 7.1 (list view binds to one provider) |
| 4.4 Sensitive data excluded from logs | 4.2 (`AppLogger.warn` redacts; `e.toString()` only in `fields:`); 5.1, 7.1, 7.2 |
| 5.1 Actionable errors | 5.2 (Save disabled with inline error + Snackbar); 7.1 (archive confirmation); 8.1 (cards route to working screens) |
| 5.2 p95 ≤ 200ms first-paint | 5.2 (AsyncValue spinner ≤ 200ms); 7.1 (FutureProvider warm-start); UAT 10.1 step 1 observation |
| 5.5 No internal info in UI | 3.1, 3.2 (userMessage defaults); 4.2 (no `$e` interpolation); 5.2, 7.1, 7.2 |
| 6.1 Edge cases | 9.3 (d) closes_at <= opens_at; 9.5 (null `bufferMinutes` fallback); 9.7 §b–§d, §i |
| 6.2 Failure scenarios | 9.4 (e) save error → Snackbar; 9.7 §a, §g (authz negative) |
| 6.4 Negative tests | 9.3 (b) controller doesn't touch creation providers; 9.5 (Save with no field-touch doesn't change bufferMinutes); 9.6 (c, d) PostgrestException → typed exception |
| 6.13 Documentation | 1.1 (column COMMENT); 1.2, 1.3, 1.4–1.6 (function COMMENT with Big-O) |
| 7.4 Least privilege | 1.2, 1.3, 1.4–1.6 (`REVOKE ALL FROM PUBLIC` + `GRANT EXECUTE TO authenticated`) |
| 8.2 Smoke tests | 9.7 (SQL + curl); 10.1, 10.2 (device-against-staging) |

## Rollout

**Strict order. The filter cascade migration (`20260605000300`) is the highest-risk delta in this phase — it modifies six existing booking-pipeline RPCs that are currently running in production. Audit the diff carefully before merging.**

1. **Push `20260605000050_add_archived_at_to_appointment_slots.sql`.** Pure additive — adds nullable column + partial index. Zero behavior change for anything currently in prod. Verify with `\d public.appointment_slots`.
2. **Push `20260605000100_rebuild_shop_opening_hours_rpc.sql`.** Additive — new function, no existing surface changed. Verify with smoke §a–§f.
3. **Push `20260605000200_archive_appointment_slot_rpc.sql`.** Additive — new function. Verify with smoke §g–§i.
4. **Push `20260605000300_archive_filter_cascade.sql` — HIGHEST-RISK STEP.** Recreates six existing booking-pipeline RPCs with the `archived_at IS NULL` predicate added. Before push: open the migration file and `diff` each function body against its current source (referenced in §Migration plan §4) to confirm only the documented one-line predicate addition + archived-slot raise have been inserted. Push to staging FIRST. Run smoke §j–§n against staging. Only after every `OK:` fires do we push to prod. **If smoke §n fails (variant 3, the LIVE picker), STOP and roll back step 4 before step 5 ships.**
5. **Ship the edge function update** (`supabase functions deploy resolve-link`) — `archived_at` filter on the public link landing. Verify with smoke §o (curl).
6. **Ship the Dart code** as one commit. The widget changes are additive: if a card load fails, the existing "Coming Soon" SnackBar fallback is gone but the screen degrades to an `error_state.dart` widget with retry — no crash.
7. **24-hour log watch**: any `AppLogger.warn` event whose `event` starts with `dashboard.rebuild_hours_failed`, `service.archive_failed`, or `service.save_failed`. A spike indicates a sanitization gap or an unmapped `PostgrestException` code that escaped Task 4.2. Cross-check against any client error reporter wired through `AppLogger`.
8. **PR description** must explicitly call out: (a) the six-surface filter cascade is the highest-risk delta and the rollback for it would re-expose archived slots to the booking pipeline; (b) `is_active` is now formally deprecated and Phase 11 does NOT touch it (locked correction 3); (c) the four carry-over bugs in §Out of scope; (d) Phase 12.1 (atomic shop publish) is filed as the follow-up that closes the creation-flow loop bug.

### Rollback (Tier 2)

1. Revert the Dart commit — Cards 4 and 5 re-disable cleanly (their handlers fall back to the previous SnackBar state if the imports are also reverted). No data loss.
2. To roll back the SQL: ship a follow-up migration that drops the two new RPCs and re-runs the original bodies of the six cascade surfaces from their source migrations (`20260517010000`, `20260517020000`, `20260525020000`, `20260525040000`). **Do NOT drop the `archived_at` column** — any rows archived during the rollout window would become un-archivable. Leave it; deprecation note stays.
3. Revert the edge function: `supabase functions deploy resolve-link --version <prev-sha>`.

## Definition of done

- [ ] `flutter analyze` clean on every touched file (NEW + EDIT).
- [ ] All new tests (Tasks 9.1–9.6) pass locally and in CI.
- [ ] `supabase db reset && supabase db push` applies the four new migrations cleanly to a fresh DB.
- [ ] Smoke-test SQL script (Task 9.7) printed `OK:` for all 14 SQL cases against staging.
- [ ] Smoke case §o (curl against resolve-link) confirms archived slot is absent from public link response.
- [ ] Business Hours editor saves successfully on staging (UAT 10.1 step 4).
- [ ] Atomicity test (UAT 10.1 step 5, airplane mode mid-save) leaves shop hours untouched.
- [ ] Archive a service → service is absent from active list AND from `get-slots` output for any future date AND from the public link landing (UAT 10.2 step 6).
- [ ] Edit a service price → booking flow reflects new price within the same session (UAT 10.2 step 3).
- [ ] Add a new service → it appears in the booking flow (UAT 10.2 step 7).
- [ ] `bufferMinutes` regression closed: edit a service without touching the buffer field, `buffer_minutes` is preserved verbatim (UAT 10.2 step 8 + Task 9.5).
- [ ] Tools tab cards 4 + 5 now route to working screens (no `Coming in a future release.` Snackbar fallback).
- [ ] Grep gates (run as a CI step or `make verify` target — exact commands):
  - [ ] `grep -rn 'Coming in a future release.' lib/presentation/features/shops/dashboard/presentation/screens/tools_screen.dart` returns `0`.
  - [ ] `grep -rn 'bufferMinutes: 15' lib/presentation/features/shops/creation/presentation/widgets/service_form_modal.dart` returns `0`.
  - [ ] `grep -rn 'ref.read(hoursProvider)' lib/presentation/features/shops/creation/presentation/widgets/service_form_modal.dart` returns `0`.
  - [ ] `grep -rn 'shopCreationProvider\|freelancerCreationProvider' lib/presentation/features/shops/dashboard/presentation/controllers/business_hours_edit_controller.dart` returns `0`.
  - [ ] `grep -rn 'shopCreationProvider\|freelancerCreationProvider\|hoursProvider' lib/presentation/features/shops/dashboard/presentation/screens/business_hours_screen.dart` returns `0`.
  - [ ] `grep -rn 'is_active' lib/presentation/features/shops/dashboard/presentation/screens/service_management_screen.dart lib/presentation/features/shops/dashboard/presentation/screens/service_edit_screen.dart` returns `0` (locked correction 3 — Phase 11 does NOT touch `is_active`).
  - [ ] `grep -rn 'e\.toString()\.contains' lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart` returns `0`.
  - [ ] `grep -v '^--' supabase/migrations/20260605000300_archive_filter_cascade.sql | grep -c 'archived_at IS NULL'` returns at least `6` (one predicate per cascade surface).
  - [ ] `grep -n 'archived_at' supabase/functions/resolve-link/index.ts` returns at least `1`.
- [ ] PR description flags the filter cascade as the highest-risk delta and documents the rollback plan (per §Rollout step 8).
- [ ] PR description lists the four carry-over bugs in §Out of scope (day-of-week range, `_parseTime` AM/PM, analytics filter, creation-flow loop) as known-not-fixed-in-this-phase.

**Estimated total effort:** 920 minutes ≈ 15.3 hours. **Lands above the SPEC's ~12.3h target.** The bump is documented and load-bearing: the filter cascade is six surfaces, not two (RESEARCH Finding 3 line 51 + locked correction 4), so Tasks 1.4–1.6 + Task 2.1 + smoke cases §j–§o together account for ~3h of additional work that the SPEC's two-surface scope did not capture. The plan is not splittable without sacrificing the atomicity-of-rollout property — surfaces 1–6 must ship together or the picker UX breaks (RESEARCH Finding 9 lines 111–125).

## PLAN COMPLETE
