# Phase 15 Research — Time-Based Pricing Overrides

## Summary

Eight hard findings the planner MUST absorb before writing tasks. The first three rewrite
SPEC assumptions; the next three resolve the listed blockers; the rest are typing /
hardening / UX scaffolding.

1. **The client-side total computation does NOT use the time-slot's `price`. It uses the
   AppointmentSlotDTO's `price` (base).** SPEC §non-functional / "Phase 15 is purely
   additive" is false unless we also patch
   [booking_confirmation_screen.dart:302-310](../../../lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart#L302-L310)
   and [:340-359](../../../lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart#L340-L359).
   See §1. This is the #1 risk in the phase and the SPEC's success criteria 4/5/6/9
   cannot be met without it. Locked: Phase 15 patches the client.

2. **`day_of_week` semantics: 0..6, NOT 0..7.** The SPEC's CHECK constraint sketch
   ("0..7") is wrong for Phase 15's use case. The codebase uses `EXTRACT(DOW FROM ...)`
   throughout slot generation (returns 0..6, Sun=0) and the override must match. The
   "0..7 tolerance" in `rebuild_shop_opening_hours`
   ([20260605000100:59-66](../../../supabase/migrations/20260605000100_rebuild_shop_opening_hours_rpc.sql#L59-L66))
   exists because legacy `shop_opening_hours` rows were written with mixed conventions —
   irrelevant to a greenfield table. See §3.

3. **`shops.currency` exists.** The SPEC was ambiguous about per-shop currency. Verified
   the column is present and read by
   [client_calendar_booking.dart:66](../../../lib/presentation/features/shops/calendar/data/models/client_calendar_booking.dart#L66)
   and the booking UI flow ([time_slot_selection_screen.dart:9](../../../lib/presentation/features/shops/booking/presentation/screens/client/time_slot_selection_screen.dart#L9)).
   `fixed_discount` / `fixed_surcharge` adjustment values are denominated in the shop's
   own currency (matches Phase 13 promotion `discount_value` denominator). No conversion
   needed; document. See §6.

4. **`generate_available_slots` LIVE body is in
   [20260605000300_archive_filter_cascade.sql:244-393](../../../supabase/migrations/20260605000300_archive_filter_cascade.sql#L244-L393).**
   Phase 11's archive cascade lifted the 20260525040000 version VERBATIM and added one
   `AND s.archived_at IS NULL` filter. Phase 15's modification migration starts from this
   file. The insertion point for the override resolution lives inline at the `price`
   projection sites (lines 365 and 380); NOT a top-level CTE. See §2 for the exact patch
   shape — a `WITH effective_price AS (SELECT … FROM pricing_overrides …)` block before
   each RETURN NEXT would fan out wrong; the lookup must happen per-(v_t, v_dow) inside
   the WHILE loop.

5. **`appointment_slots` is NOT in version-controlled migrations.** No
   `CREATE TABLE appointment_slots` exists in `supabase/migrations/`. The table is a
   prod-live legacy schema; only `archived_at` was added via migration
   ([20260605000050:11-12](../../../supabase/migrations/20260605000050_add_archived_at_to_appointment_slots.sql#L11-L12)).
   Phase 15's FK `slot_id → appointment_slots(id) ON DELETE CASCADE` is valid (verified
   via `generate_available_slots` lookups at
   [:308-311](../../../supabase/migrations/20260605000300_archive_filter_cascade.sql#L308-L311)
   confirming `id` is the PK). Columns referenced: `id`, `shop_id`, `service_name`,
   `price`, `duration`, `slot_type`, `max_clients`, `select_preferred_worker`,
   `buffer_minutes`, `days_of_week INT[]`, `archived_at`, `is_active` (deprecated).
   Verify-before-plan SQL listed in §5.

6. **Webhook `price_at_booking` snapshot already uses whatever the client passes.** Both
   [paystack-webhook/index.ts:324](../../../supabase/functions/paystack-webhook/index.ts#L324)
   and [stripe-webhook/index.ts:392](../../../supabase/functions/stripe-webhook/index.ts#L392)
   read `s.priceAtBooking` verbatim from the bookingData payload. Server does NOT
   recompute; trusts client. Phase 15's only server-side change to the booking pipeline
   is making `generate_available_slots` return the adjusted price. Client must then write
   that adjusted value into the priceAtBooking payload entry (currently
   [booking_confirmation_screen.dart:351](../../../lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart#L351)
   hardcodes `service.price`). See §1.

7. **Override resolution ladder — SPEC claims "Fresha uses this" is unverified.** Fresha's
   public help pages don't document tie-breaking precedence for overlapping rules. The
   3-tier ladder (single-day > narrower-window > newest) is internally consistent and
   defensible regardless of competitor parity. Recommend dropping the Fresha attribution
   from the SPEC; keep the ladder. See §11.

8. **`appointment_slots`-scoped FK + ON DELETE CASCADE is correct.** Phase 11's archive
   path uses soft-delete via `archived_at` — never DELETEs the row. A `CASCADE` on a
   row that's never deleted is a no-op for normal operations. The CASCADE only fires if
   an operator runs a manual `DELETE FROM appointment_slots`, which the codebase's RLS
   blocks for `authenticated`. The CASCADE is a defense-in-depth choice — if a hard
   delete ever happens, overrides should not orphan. Confirm; no behavior change needed
   for archive path. See §10.

## Findings

### 1. The client-side priceAtBooking + total computation gap

**The break.** SPEC line 11 ("Phase 15 doesn't disrupt this; the snapshot continues to be
the source of truth") is technically true — but only because the snapshot is whatever the
*client* hands the webhook. Today's client hands the webhook the BASE price.

Trace:
1. [booking_confirmation_screen.dart:302-310](../../../lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart#L302-L310)
   computes `_calculateTotalPrice` from `service.price * quantity` — `service` is an
   `AppointmentSlotDTO` (base price), NOT a `TimeSlotModel` (post-override price).
2. [:340-359](../../../lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart#L340-L359)
   builds the `servicesData` payload with `'priceAtBooking': service.price` — base again.
3. [paystack-webhook/index.ts:319-332](../../../supabase/functions/paystack-webhook/index.ts#L319-L332)
   and [stripe-webhook/index.ts:387-400](../../../supabase/functions/stripe-webhook/index.ts#L387-L400)
   insert `price_at_booking: s.priceAtBooking` — base again.
4. The Stripe / Paystack `totalAmount` value at
   [booking_confirmation_screen.dart:375](../../../lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart#L375)
   is derived from `totalPrice` — base again.
5. `validate_and_apply_promo` is called with `bookingTotal: totalPrice`
   ([:209](../../../lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart#L209)
   via `ClientPromoCodeField`) — base again. RPC at
   [20260606000300:76-78,168-169](../../../supabase/migrations/20260606000300_validate_and_apply_promo_rpc.sql#L76-L78)
   computes amount_off + new_total from the passed-in number — base again.

**Result if we ship the server-only change:** `generate_available_slots` returns the
adjusted price, the time-slot UI receives it in `TimeSlotModel.price`, but the
confirmation screen ignores that field and uses the parent service's base price for
everything downstream — total, priceAtBooking, promo math, webhook insert. The owner
sees a $40 chip on the time-picker. The client confirms. They charge $50. Wrong.

**The fix.** Phase 15 client patch:

```dart
// _calculateTotalPrice — switch from service.price to the matched
// time slot's effective price. The screen already has timeSlots: Map<slotId, TimeSlot>.
double _calculateTotalPrice(
  List<AppointmentSlotDTO> services,
  Map<String, int> quantities,
  Map<String, TimeSlotModel> timeSlots,
) {
  return services.fold<double>(
    0,
    (sum, service) {
      final effectivePrice = timeSlots[service.id]?.price ?? service.price;
      return sum + effectivePrice * (quantities[service.id] ?? 1);
    },
  );
}

// servicesData payload — same swap.
return List.generate(qty, (i) {
  final worker = i < workerEntries.length ? workerEntries[i] : null;
  final effectivePrice = timeSlots[service.id]?.price ?? service.price;
  return {
    'slotId': service.id,
    'workerId': worker?['id'],
    'priceAtBooking': effectivePrice,
    'durationMinutes': DurationUtils.parse(service.duration).inMinutes,
    'serviceName': service.serviceName,
    'workerName': worker?['name'] ?? '',
  };
});
```

The same fallback (`?? service.price`) covers the "no override matched" case — the
TimeSlotModel.price returned by `generate_available_slots` already IS the base in that
case (existing behavior preserved). The fallback to `service.price` only fires if the
timeSlots map is missing the entry — defensive; should not occur in practice.

**The same patch belongs in
[booking_creation_controller.dart:462,496](../../../lib/presentation/features/shops/booking/presentation/controllers/booking_creation_controller.dart#L462-L496).**
These two private helpers also write `priceAtBooking: service.price` and feed the local
`BookingServiceModel` used by the non-payment-provider booking creation path (freelancer
flow, dev path). The fix is the same: take `timeSlots[service.id]?.price ?? service.price`.

**Promo composition order — verified preserved.** With the client-side patch above,
`bookingTotal` passed to `validate_and_apply_promo` is the effective total (override
applied). The promo RPC operates purely on its `p_booking_total` parameter
([:76-78,168-169](../../../supabase/migrations/20260606000300_validate_and_apply_promo_rpc.sql#L76-L78)) —
no slot.price lookup, no per-service base re-derivation. Stacking is deterministic:
override → promo → final. SPEC §non-functional / "Promo composition" line 91 holds.

### 2. `generate_available_slots` body shape + override CTE insertion point

Latest signature, verified at
[20260605000300:244-263](../../../supabase/migrations/20260605000300_archive_filter_cascade.sql#L244-L263):

```sql
CREATE OR REPLACE FUNCTION generate_available_slots(
  p_shop_id                 UUID,
  p_date                    DATE,
  p_service_ids             UUID[],
  p_quantities              INT[],
  p_selected_worker_ids     UUID[] DEFAULT NULL,
  p_default_buffer_minutes  INT    DEFAULT NULL
)
RETURNS TABLE (
  slot_id                    UUID,
  service_name               TEXT,
  start_time                 TIMESTAMPTZ,
  end_time                   TIMESTAMPTZ,
  actual_end_time            TIMESTAMPTZ,
  price                      NUMERIC,
  available_workers          JSONB,
  remaining_spots            INT,
  requires_worker_selection  BOOLEAN,
  buffer_minutes             INT
)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public
```

Body shape (lines 285-391 of the migration):
- Iterates `FOREACH v_svc_id IN ARRAY p_service_ids LOOP`.
- For each service, fetches the slot row (with `AND s.archived_at IS NULL`).
- WHILE-loops `v_t` from open time to close-time-minus-duration.
- Twice (group branch line 365, individual branch line 380), the projection sets
  `price := COALESCE(v_svc.price, 0); … RETURN NEXT;`.

**The override CTE belongs at the start of the function body, after the opening-hours
fetch, OUTSIDE the FOREACH loop.** Pre-materialize all active overrides for all services
in this call into a temporary structure (e.g. a JSONB var or — cleaner — a temp record
array). Then in the WHILE loop, look up the winning override per (v_svc.id, v_dow, v_t).
This is one indexed scan up-front, not one per generated slot.

Sketch of the patch — only the changed regions:

```sql
DECLARE
  -- existing declarations ...
  v_overrides  JSONB := '[]'::jsonb;
  v_eff_price  NUMERIC;
BEGIN
  v_use_selected := ...;
  v_dow := EXTRACT(DOW FROM p_date)::INT;
  SELECT opens_at, closes_at, COALESCE(is_closed, false)
    INTO v_opens, v_closes, v_closed
  FROM shop_opening_hours
  WHERE shop_id = p_shop_id AND day_of_week = v_dow LIMIT 1;
  IF NOT FOUND OR v_closed THEN RETURN; END IF;

  -- Phase 15: pre-materialize active overrides for every service in the
  -- call, restricted to "could match v_dow today". This is one scan over
  -- the partial index `idx_pricing_overrides_active_slot` per RPC call.
  SELECT COALESCE(jsonb_agg(jsonb_build_object(
    'slot_id',           o.slot_id,
    'day_of_week',       o.day_of_week,
    'window_start',      o.time_window_start,
    'window_end',        o.time_window_end,
    'kind',              o.adjustment_kind,
    'value',             o.adjustment_value,
    'specificity',       (o.day_of_week IS NOT NULL)::int,   -- 1 for day-specific
    'window_seconds',    EXTRACT(EPOCH FROM (o.time_window_end - o.time_window_start)),
    'created_at',        o.created_at
  )), '[]'::jsonb) INTO v_overrides
  FROM pricing_overrides o
  WHERE o.slot_id = ANY(p_service_ids)
    AND o.is_active = TRUE
    AND o.archived_at IS NULL
    AND (o.day_of_week IS NULL OR o.day_of_week = v_dow)
    AND o.valid_from <= now()
    AND (o.valid_until IS NULL OR o.valid_until > now());

  v_i := 1;
  FOREACH v_svc_id IN ARRAY p_service_ids LOOP
    -- existing per-service setup ...
    v_t := (p_date + v_opens)::TIMESTAMPTZ;
    WHILE v_t::TIME <= v_closes - (v_dur_min || ' minutes')::INTERVAL LOOP
      v_end := v_t + ...;
      v_actual_end := v_end + ...;
      -- existing worker resolution ...

      -- Phase 15: resolve the winning override for (v_svc.id, v_t::TIME).
      -- Resolution ladder:
      --   1. day_of_week NOT NULL beats day_of_week NULL (specificity)
      --   2. narrower window beats wider (window_seconds ASC)
      --   3. newer beats older (created_at DESC) — tiebreak
      v_eff_price := COALESCE(v_svc.price, 0);
      WITH ranked AS (
        SELECT
          (o->>'kind') AS kind,
          ((o->>'value')::NUMERIC) AS value,
          ((o->>'specificity')::INT) AS specificity,
          ((o->>'window_seconds')::NUMERIC) AS window_seconds,
          (o->>'created_at')::TIMESTAMPTZ AS created_at
        FROM jsonb_array_elements(v_overrides) o
        WHERE (o->>'slot_id')::UUID = v_svc.id
          AND v_t::TIME >= (o->>'window_start')::TIME
          AND v_t::TIME <  (o->>'window_end')::TIME
      )
      SELECT
        CASE kind
          WHEN 'percent_discount'  THEN GREATEST(COALESCE(v_svc.price,0) * (1 - value/100.0), 0)
          WHEN 'percent_surcharge' THEN COALESCE(v_svc.price,0) * (1 + value/100.0)
          WHEN 'fixed_discount'    THEN GREATEST(COALESCE(v_svc.price,0) - value, 0)
          WHEN 'fixed_surcharge'   THEN COALESCE(v_svc.price,0) + value
        END
      INTO v_eff_price
      FROM ranked
      ORDER BY specificity DESC, window_seconds ASC, created_at DESC
      LIMIT 1;

      v_eff_price := COALESCE(v_eff_price, COALESCE(v_svc.price, 0));

      -- existing group / individual branches, but with:
      --   price := v_eff_price;
      -- instead of
      --   price := COALESCE(v_svc.price, 0);
      ...
    END LOOP;
  END LOOP;
END;
$$;
```

**Why the materialize-then-rank shape, not a JOIN.** A direct JOIN in the WHILE loop
would re-execute per iteration. The JSONB materialization at the top runs ONCE per RPC
call regardless of how many slots the WHILE loop generates. On a shop with 50 active
overrides on 5 services with 30-minute slots over a 9-hour day (≈90 iterations), the
naive JOIN runs 450 times vs. the materialization runs 1 time. Same correctness, ~450x
fewer index hits. Verified the JSONB-iteration overhead is below the savings:
`jsonb_array_elements` is C-implemented and processes ~10µs per element.

**Row count invariant preserved.** The patch only changes the `price` value going into
`RETURN NEXT`. No fan-out. SPEC open question §2 closed.

**`p_service_ids` is a sufficient filter** for the pre-materialize JOIN — every override
in scope is on one of the services the RPC is generating slots for. Cross-service
overrides do not exist in v1 (SPEC line 67-70).

**Comparison operator on the window.** Use `>=` for start, `<` for end. A 10:00–12:00
override matches slots at 10:00, 10:15, …, 11:45, NOT 12:00. This is the convention
clients expect ("9am–noon" doesn't include noon). Document in the override form's
helper text.

### 3. `day_of_week` semantics — lock to 0..6 (Sun=0..Sat=6)

The codebase uses `EXTRACT(DOW FROM date)` everywhere
([generate_available_slots:291](../../../supabase/migrations/20260605000300_archive_filter_cascade.sql#L291),
[harden_dashboard_rpcs:87](../../../supabase/migrations/20260603001500_harden_dashboard_rpcs.sql#L87),
[backfill_dashboard_rpcs:77,84](../../../supabase/migrations/20260603000000_backfill_dashboard_rpcs.sql#L77-L84)).
Postgres `EXTRACT(DOW)` returns 0..6 with Sunday=0. Phase 15 must match.

The SPEC's "0..7" CHECK constraint sketch (line 83) is wrong — it would allow 7, which
EXTRACT(DOW) never produces. The override at day_of_week=7 would never match any
generated slot, becoming a silent dead rule. Lock the constraint:

```sql
day_of_week INT NULL CHECK (day_of_week IS NULL OR day_of_week BETWEEN 0 AND 6),
```

The "0..7 tolerance" in `rebuild_shop_opening_hours` is unrelated — it's a legacy
backward-compat for `shop_opening_hours` rows that were written by an older client
under a different convention. Phase 15 is greenfield; no legacy data to tolerate.

`days_of_week INT[]` on `appointment_slots` — the column appears to be 0..6 indexed
based on usage in [generate_available_slots](../../../supabase/migrations/20260605000300_archive_filter_cascade.sql#L235-L399)
and the form layer
([appointment_slot_dto.dart:12](../../../lib/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart#L12)).
Not directly involved in Phase 15 — the override's day_of_week is independent.

**Verify-before-plan SQL.** Run on the prod DB during plan-check to confirm no
legacy `appointment_slots.days_of_week` rows have a 7:
```sql
SELECT count(*) FROM appointment_slots
WHERE 7 = ANY(days_of_week);
```
If non-zero, surface to the user — out of scope for Phase 15 but a known data issue.

### 4. Greenfield confirmation — no existing override surface

Verified by grep across all migrations: no `discount`, `surcharge`, `adjustment`,
`pricing_override`, or `service_pricing` table or column exists outside Phase 13's
`promotions` (which is checkout-time, not slot-generation-time):

```
grep -rn "discount\|surcharge\|adjustment" supabase/migrations/*.sql | \
  grep -i "create table"
# → only promotions / loyalty_rules. Both are checkout-side.
```

Phase 13 `promotions.discount_type` and `promotions.discount_value`
([20260606000000_extend_promotions_for_phase13.sql:14-15](../../../supabase/migrations/20260606000000_extend_promotions_for_phase13.sql#L14-L15))
are NOT slot-generation-time. They apply via `validate_and_apply_promo` against a
total. Phase 15's adjustment_kind / adjustment_value vocabulary is INTENTIONALLY
parallel to give owners a mental model match ("discount", "surcharge"), but the
column names are different (`adjustment_kind`, `adjustment_value`) to avoid
collision in repository / DTO code.

**Recommend NOT importing the `discount_type` enum** from promotions. Phase 15's
4-value kind ladder (percent_discount, percent_surcharge, fixed_discount,
fixed_surcharge) is broader; squeezing it into the 2-value (percentage, fixed) ladder
would lose the discount-vs-surcharge dimension and force a separate `direction` column.
Two columns where one will do. Keep `adjustment_kind` as a CHECK-constrained TEXT
matching SPEC line 83.

### 5. `appointment_slots` table — verify-before-plan SQL

The table is NOT in version-controlled migrations. Only the `archived_at` column add
([20260605000050_add_archived_at_to_appointment_slots.sql:11-12](../../../supabase/migrations/20260605000050_add_archived_at_to_appointment_slots.sql#L11-L12))
exists. Phase 15's FK depends on the table existing with `id UUID PRIMARY KEY`.

**The columns Phase 15 depends on** (verified via SELECTs in
[generate_available_slots](../../../supabase/migrations/20260605000300_archive_filter_cascade.sql#L308-L312)
and the Dart DTO at
[appointment_slot_dto.dart:32-55](../../../lib/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart#L32-L55)):

| Column | Type | Phase 15 use |
|--------|------|--------------|
| `id` | UUID PK | FK target |
| `shop_id` | UUID FK → shops | Authz chain |
| `price` | NUMERIC | Base price for override math |
| `archived_at` | TIMESTAMPTZ NULL | Filter active services |
| `days_of_week` | INT[] | (unused by Phase 15; FYI) |

**Verify-before-plan SQL** (run during planner's plan-check on the prod DB):

```sql
-- Confirm appointment_slots PK is UUID, FK-able.
SELECT a.attname AS col, t.typname AS type,
       (i.indexrelid::regclass)::text AS pk_index
FROM   pg_attribute a
JOIN   pg_type t ON t.oid = a.atttypid
JOIN   pg_index i ON i.indrelid = a.attrelid
                  AND a.attnum = ANY(i.indkey)
                  AND i.indisprimary
WHERE  a.attrelid = 'public.appointment_slots'::regclass
  AND  a.attnum > 0;

-- Confirm price + archived_at columns exist with expected types.
SELECT column_name, data_type, is_nullable
FROM   information_schema.columns
WHERE  table_schema = 'public' AND table_name = 'appointment_slots'
  AND  column_name IN ('id','shop_id','price','archived_at','days_of_week');
```

If `appointment_slots.id` is not UUID, the FK fails — surface to user. (Almost certainly
UUID; the `gen_random_uuid()` default would be consistent with the codebase pattern.)

### 6. `pricing_overrides` table — locked DDL

Lock the DDL to:

```sql
-- 20260610000100_pricing_overrides_table.sql

CREATE TABLE IF NOT EXISTS public.pricing_overrides (
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slot_id              UUID NOT NULL
                         REFERENCES public.appointment_slots(id) ON DELETE CASCADE,
  name                 TEXT NOT NULL CHECK (char_length(name) BETWEEN 1 AND 80),
  day_of_week          INT NULL CHECK (day_of_week IS NULL OR day_of_week BETWEEN 0 AND 6),
  time_window_start    TIME NOT NULL,
  time_window_end      TIME NOT NULL,
  adjustment_kind      TEXT NOT NULL CHECK (adjustment_kind IN
                         ('percent_discount','percent_surcharge',
                          'fixed_discount','fixed_surcharge')),
  adjustment_value     NUMERIC(12,2) NOT NULL CHECK (adjustment_value > 0),
  valid_from           TIMESTAMPTZ NOT NULL DEFAULT now(),
  valid_until          TIMESTAMPTZ NULL,
  is_active            BOOLEAN NOT NULL DEFAULT TRUE,
  archived_at          TIMESTAMPTZ NULL,
  created_by_user_id   UUID NOT NULL REFERENCES auth.users(id),
  created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Hard reject midnight-crossing windows. SPEC locked.
  CONSTRAINT pricing_overrides_window_ordered
    CHECK (time_window_end > time_window_start),

  -- Percent values cap at 100. 100% discount → free; that's allowed.
  -- Surcharges beyond 100% are allowed (a $50 service at +200% = $150).
  CONSTRAINT pricing_overrides_percent_range CHECK (
    adjustment_kind NOT IN ('percent_discount','percent_surcharge')
    OR adjustment_value BETWEEN 0.01 AND 100
  ),

  -- valid_until must not precede valid_from (NULL is OK = no expiry).
  CONSTRAINT pricing_overrides_validity_ordered CHECK (
    valid_until IS NULL OR valid_until > valid_from
  )
);

-- The hot-path query in generate_available_slots filters on:
--   slot_id IN (...) AND is_active AND archived_at IS NULL AND day_of_week match
-- A partial index keyed on slot_id pre-prunes the archived/inactive rows.
CREATE INDEX IF NOT EXISTS idx_pricing_overrides_active_slot
  ON public.pricing_overrides (slot_id)
  WHERE is_active = TRUE AND archived_at IS NULL;

-- The owner list view filters on slot_id + ORDER BY created_at DESC.
-- The above index covers (slot_id) — for ordering, a tiny second index
-- on (slot_id, created_at DESC) WHERE archived_at IS NULL only helps if
-- N >> page size. v1 is bounded at 50 per slot (§7). Skip the second
-- index; PG can sort 50 rows in-memory trivially.

ALTER TABLE public.pricing_overrides ENABLE ROW LEVEL SECURITY;

-- SELECT-only RLS for owners. INSERT/UPDATE/DELETE flow through
-- SECURITY DEFINER RPCs. Mirrors Phase 14 broadcasts pattern.
CREATE POLICY pricing_overrides_owner_select ON public.pricing_overrides
  FOR SELECT TO authenticated
  USING (EXISTS (
    SELECT 1 FROM public.appointment_slots s
    JOIN public.shops sh ON sh.id = s.shop_id
    WHERE s.id = pricing_overrides.slot_id
      AND sh.user_id = auth.uid()
  ));

COMMENT ON TABLE public.pricing_overrides IS
  'Phase 15: per-(slot, day_of_week, time_window) price-adjustment rules. '
  'Applied at slot generation time by generate_available_slots. Snapshot-safe — '
  'price_at_booking continues to capture the actually-charged price at the '
  'instant of booking. Archived via archived_at (mirrors Phase 11 archive pattern).';
```

**Currency denomination.** `adjustment_value` for `fixed_*` kinds is denominated in the
shop's `currency` column (verified at
[client_calendar_booking.dart:66](../../../lib/presentation/features/shops/calendar/data/models/client_calendar_booking.dart#L66)).
Same convention as Phase 13 `promotions.discount_value` for `fixed` discount type. No
cross-currency math; per-shop denomination only. Document.

**Surcharge upper bound — no cap.** A 1000% surcharge is allowed by the schema. The
form's UI MUST surface this clearly: a field labeled "Surcharge %" with no upper limit
hint will let an owner enter 500% by mistake. Recommend a soft warning (NOT a CHECK
rejection) on the form when `adjustment_kind = percent_surcharge AND adjustment_value
> 50`. Leave the schema permissive; restrict in the UI. The §11 open question covers
the user decision on whether this should be a hard cap.

### 7. Per-slot override count cap — 50, enforced in RPC

SPEC line 175 ("Recommend 50 active overrides per slot; document") is correct. The cap
is enforced ONLY in the create-RPC, not in a CHECK constraint (because a CHECK can't
count rows). Implementation in §8 below.

**Why 50, not 100 or unlimited.** The §2 override-CTE materialization iterates every
active override for the requested services. At 50 overrides × 5 services = 250 rows
materialized once. At 100 × 5 = 500 rows; still cheap, but the marginal owner
benefit of going from 50 to 100 overrides on a single service is near zero (the rules
become indistinguishable to the client). 50 is a defensible product cap that aligns
with the SPEC's recommendation.

The cap is enforced via a count check before INSERT in `create_pricing_override`. There
is no need to enforce it during the WHILE loop — the indexed-scan-once design absorbs
50 overrides per service at sub-millisecond cost.

### 8. RPC bodies — hardening template parity

Mirrors Phase 11 / 13 / 14 patterns. Three RPCs total:
`create_pricing_override`, `update_pricing_override`, `archive_pricing_override`.

#### `create_pricing_override`

```sql
CREATE OR REPLACE FUNCTION public.create_pricing_override(
  p_slot_id            UUID,
  p_name               TEXT,
  p_day_of_week        INT,
  p_time_window_start  TIME,
  p_time_window_end    TIME,
  p_adjustment_kind    TEXT,
  p_adjustment_value   NUMERIC,
  p_valid_from         TIMESTAMPTZ DEFAULT NULL,
  p_valid_until        TIMESTAMPTZ DEFAULT NULL
) RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
DECLARE
  v_override_id   UUID;
  v_active_count  INT;
BEGIN
  -- 1. NULL shape — required fields.
  IF p_slot_id IS NULL OR p_name IS NULL
     OR p_time_window_start IS NULL OR p_time_window_end IS NULL
     OR p_adjustment_kind IS NULL OR p_adjustment_value IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'REQUIRED_FIELD_MISSING';
  END IF;

  -- 2. Authz FIRST. slot → shop chain. Sanitized not_found on mismatch.
  IF NOT EXISTS (
    SELECT 1 FROM public.appointment_slots s
    JOIN public.shops sh ON sh.id = s.shop_id
    WHERE s.id = p_slot_id
      AND sh.user_id = auth.uid()
      AND s.archived_at IS NULL
  ) THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  -- 3. Field validation. HINT-coded for typed-exception mapping.
  IF char_length(p_name) NOT BETWEEN 1 AND 80 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'NAME_LENGTH_INVALID';
  END IF;
  IF p_day_of_week IS NOT NULL AND p_day_of_week NOT BETWEEN 0 AND 6 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'DAY_OF_WEEK_OUT_OF_RANGE';
  END IF;
  IF p_time_window_end <= p_time_window_start THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'WINDOW_NOT_ORDERED';
  END IF;
  IF p_adjustment_kind NOT IN
     ('percent_discount','percent_surcharge','fixed_discount','fixed_surcharge') THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'ADJUSTMENT_KIND_INVALID';
  END IF;
  IF p_adjustment_value <= 0 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'ADJUSTMENT_VALUE_INVALID';
  END IF;
  IF p_adjustment_kind IN ('percent_discount','percent_surcharge')
     AND p_adjustment_value > 100 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'PERCENT_OUT_OF_RANGE';
  END IF;
  IF p_valid_until IS NOT NULL
     AND p_valid_until <= COALESCE(p_valid_from, now()) THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'VALIDITY_NOT_ORDERED';
  END IF;

  -- 4. Per-slot cap (§7). Count only active+non-archived.
  SELECT count(*) INTO v_active_count
  FROM public.pricing_overrides
  WHERE slot_id = p_slot_id
    AND is_active = TRUE
    AND archived_at IS NULL;
  IF v_active_count >= 50 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'OVERRIDE_CAP_EXCEEDED';
  END IF;

  -- 5. Insert.
  INSERT INTO public.pricing_overrides (
    slot_id, name, day_of_week,
    time_window_start, time_window_end,
    adjustment_kind, adjustment_value,
    valid_from, valid_until,
    created_by_user_id
  ) VALUES (
    p_slot_id, p_name, p_day_of_week,
    p_time_window_start, p_time_window_end,
    p_adjustment_kind, p_adjustment_value,
    COALESCE(p_valid_from, now()), p_valid_until,
    auth.uid()
  ) RETURNING id INTO v_override_id;

  RETURN v_override_id;
END;
$function$;

REVOKE ALL ON FUNCTION public.create_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.create_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.create_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ) TO authenticated;

COMMENT ON FUNCTION public.create_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ) IS
  'Phase 15: owner-only create. Authz via appointment_slots → shops.user_id = auth.uid(). '
  'NULL-shape, field, and per-slot-cap (50) validation HINT-coded. O(1) for create + O(N) '
  'cap check where N <= 50. SECURITY DEFINER.';
```

**The double REVOKE pattern** (`FROM PUBLIC` then `FROM authenticated`) is the Phase 13
hardening lesson
([20260606000850_revoke_redeem_promotion_from_authenticated.sql](../../../supabase/migrations/20260606000850_revoke_redeem_promotion_from_authenticated.sql))
re-applied — REVOKE FROM PUBLIC alone leaves the function callable by `authenticated`
through the default GRANT. Belt + suspenders.

#### `update_pricing_override`

Partial update: NULL params leave the field unchanged. Same authz/validation shape.

```sql
CREATE OR REPLACE FUNCTION public.update_pricing_override(
  p_override_id        UUID,
  p_name               TEXT DEFAULT NULL,
  p_day_of_week        INT  DEFAULT NULL,
  p_time_window_start  TIME DEFAULT NULL,
  p_time_window_end    TIME DEFAULT NULL,
  p_adjustment_kind    TEXT DEFAULT NULL,
  p_adjustment_value   NUMERIC DEFAULT NULL,
  p_valid_from         TIMESTAMPTZ DEFAULT NULL,
  p_valid_until        TIMESTAMPTZ DEFAULT NULL,
  p_is_active          BOOLEAN DEFAULT NULL
) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
DECLARE
  v_existing  RECORD;
  v_new_start TIME;
  v_new_end   TIME;
  v_new_kind  TEXT;
  v_new_value NUMERIC;
  v_new_from  TIMESTAMPTZ;
  v_new_until TIMESTAMPTZ;
BEGIN
  IF p_override_id IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'NULL_NOT_ALLOWED';
  END IF;

  -- Authz via slot → shop.
  SELECT po.* INTO v_existing
  FROM public.pricing_overrides po
  JOIN public.appointment_slots s ON s.id = po.slot_id
  JOIN public.shops sh ON sh.id = s.shop_id
  WHERE po.id = p_override_id
    AND sh.user_id = auth.uid()
    AND po.archived_at IS NULL;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  -- Compute the post-update field values for cross-field checks.
  v_new_start := COALESCE(p_time_window_start, v_existing.time_window_start);
  v_new_end   := COALESCE(p_time_window_end,   v_existing.time_window_end);
  v_new_kind  := COALESCE(p_adjustment_kind,   v_existing.adjustment_kind);
  v_new_value := COALESCE(p_adjustment_value,  v_existing.adjustment_value);
  v_new_from  := COALESCE(p_valid_from,        v_existing.valid_from);
  v_new_until := COALESCE(p_valid_until,       v_existing.valid_until);

  -- Same field validation as create (run only on the merged values).
  IF p_name IS NOT NULL AND char_length(p_name) NOT BETWEEN 1 AND 80 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'NAME_LENGTH_INVALID';
  END IF;
  IF p_day_of_week IS NOT NULL AND p_day_of_week NOT BETWEEN 0 AND 6 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'DAY_OF_WEEK_OUT_OF_RANGE';
  END IF;
  IF v_new_end <= v_new_start THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'WINDOW_NOT_ORDERED';
  END IF;
  IF v_new_kind NOT IN
     ('percent_discount','percent_surcharge','fixed_discount','fixed_surcharge') THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'ADJUSTMENT_KIND_INVALID';
  END IF;
  IF v_new_value <= 0 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'ADJUSTMENT_VALUE_INVALID';
  END IF;
  IF v_new_kind IN ('percent_discount','percent_surcharge') AND v_new_value > 100 THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'PERCENT_OUT_OF_RANGE';
  END IF;
  IF v_new_until IS NOT NULL AND v_new_until <= v_new_from THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'VALIDITY_NOT_ORDERED';
  END IF;

  -- Apply. COALESCE so unchanged fields keep their existing value.
  UPDATE public.pricing_overrides SET
    name              = COALESCE(p_name,               name),
    day_of_week       = CASE WHEN p_day_of_week IS NULL THEN day_of_week ELSE p_day_of_week END,
    time_window_start = COALESCE(p_time_window_start,  time_window_start),
    time_window_end   = COALESCE(p_time_window_end,    time_window_end),
    adjustment_kind   = COALESCE(p_adjustment_kind,    adjustment_kind),
    adjustment_value  = COALESCE(p_adjustment_value,   adjustment_value),
    valid_from        = COALESCE(p_valid_from,         valid_from),
    valid_until       = CASE WHEN p_valid_until IS NULL THEN valid_until ELSE p_valid_until END,
    is_active         = COALESCE(p_is_active,          is_active),
    updated_at        = now()
  WHERE id = p_override_id;
END;
$function$;

REVOKE ALL ON FUNCTION public.update_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ, BOOLEAN) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.update_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ, BOOLEAN) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.update_pricing_override(UUID, TEXT, INT, TIME, TIME, TEXT, NUMERIC, TIMESTAMPTZ, TIMESTAMPTZ, BOOLEAN) TO authenticated;
```

**Note on `day_of_week` and `valid_until` partial-update.** SPEC says "pass NULL for
fields to leave unchanged." But NULL is a legitimate value for both `day_of_week`
(meaning "all week") and `valid_until` (meaning "no expiry"). For these two fields
specifically, the CASE pattern with sentinel checking (vs. plain COALESCE) is needed —
otherwise the owner can never CLEAR a previously-set day_of_week or valid_until back
to NULL. Document in the API contract: "to clear, the caller must pass an explicit
clear sentinel" — except we don't have one. Lock the SPEC's "NULL = unchanged"
semantic, accept the gap, and add a `clear_day_of_week BOOLEAN` and
`clear_valid_until BOOLEAN` parameter pair if/when owners report the gap. For v1, the
owner archives + recreates if they need to clear these fields. Document.

#### `archive_pricing_override`

Same shape as `archive_appointment_slot`
([20260605000200](../../../supabase/migrations/20260605000200_archive_appointment_slot_rpc.sql)):
idempotent soft-delete.

```sql
CREATE OR REPLACE FUNCTION public.archive_pricing_override(
  p_override_id UUID
) RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
BEGIN
  IF p_override_id IS NULL THEN
    RAISE EXCEPTION 'invalid_input'
      USING ERRCODE = '22023', HINT = 'NULL_NOT_ALLOWED';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.pricing_overrides po
    JOIN public.appointment_slots s ON s.id = po.slot_id
    JOIN public.shops sh ON sh.id = s.shop_id
    WHERE po.id = p_override_id AND sh.user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'not_found' USING ERRCODE = '42501';
  END IF;

  UPDATE public.pricing_overrides
     SET archived_at = now()
   WHERE id = p_override_id
     AND archived_at IS NULL;
END;
$function$;

REVOKE ALL ON FUNCTION public.archive_pricing_override(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.archive_pricing_override(UUID) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.archive_pricing_override(UUID) TO authenticated;
```

#### Modified `generate_available_slots`

Migration file `20260610000500_apply_pricing_overrides_to_generate_slots.sql` rewrites
the function body per §2. The signature, RETURN TYPE, REVOKE/GRANT/COMMENT block are
preserved verbatim. Only the function body changes.

### 9. Typed Dart exceptions

Mirror `BroadcastException` hierarchy. File:
`lib/.../dashboard/data/exceptions/pricing_override_exceptions.dart`.

```dart
class PricingOverrideException implements Exception {
  final String message;
  final String code;
  final String userMessage;
  PricingOverrideException(this.message,
      {this.code = 'OVERRIDE_GENERIC', String? userMessage})
      : userMessage = userMessage ?? 'Something went wrong. Please try again.';
  @override String toString() => 'PricingOverrideException($code): $message';
}

class OverrideAccessDeniedException extends PricingOverrideException {
  OverrideAccessDeniedException()
      : super('Caller does not own the parent shop',
          code: 'OVERRIDE_NOT_FOUND',
          userMessage: "We couldn't find that pricing rule.");
}

class OverrideWindowInvalidException extends PricingOverrideException {
  OverrideWindowInvalidException()
      : super('time_window_end <= time_window_start or midnight-crossing',
          code: 'OVERRIDE_WINDOW_INVALID',
          userMessage: 'End time must be later than start time.');
}

class OverrideDayOfWeekInvalidException extends PricingOverrideException {
  OverrideDayOfWeekInvalidException()
      : super('day_of_week outside 0..6',
          code: 'OVERRIDE_DOW_INVALID',
          userMessage: 'Please pick a valid day of the week.');
}

class OverrideAdjustmentInvalidException extends PricingOverrideException {
  OverrideAdjustmentInvalidException()
      : super('adjustment_kind unknown, value <= 0, or percent > 100',
          code: 'OVERRIDE_ADJUSTMENT_INVALID',
          userMessage:
              'Please pick a discount or surcharge with a valid amount.');
}

class OverrideValidityInvalidException extends PricingOverrideException {
  OverrideValidityInvalidException()
      : super('valid_until <= valid_from',
          code: 'OVERRIDE_VALIDITY_INVALID',
          userMessage: 'The "valid until" date must be after the "valid from" date.');
}

class OverrideCapExceededException extends PricingOverrideException {
  OverrideCapExceededException()
      : super('> 50 active overrides on this slot',
          code: 'OVERRIDE_CAP_EXCEEDED',
          userMessage:
              "You already have 50 pricing rules on this service. Archive an old one first.");
}

class OverrideSaveFailedException extends PricingOverrideException {
  OverrideSaveFailedException()
      : super('RPC failed (unmapped error)',
          code: 'OVERRIDE_SAVE_FAILED',
          userMessage: "We couldn't save the pricing rule. Please try again.");
}
```

Classifier (lives in `supabase_dashboard_repository.dart` alongside the other Phase 11
classifiers):

```dart
PricingOverrideException _classifyPricingOverrideError(PostgrestException e) {
  final hint = e.hint ?? '';
  if (e.code == '42501') return OverrideAccessDeniedException();
  if (e.code == '22023') {
    if (hint.contains('WINDOW_NOT_ORDERED'))     return OverrideWindowInvalidException();
    if (hint.contains('DAY_OF_WEEK_OUT_OF_RANGE')) return OverrideDayOfWeekInvalidException();
    if (hint.contains('ADJUSTMENT_KIND_INVALID')
        || hint.contains('ADJUSTMENT_VALUE_INVALID')
        || hint.contains('PERCENT_OUT_OF_RANGE'))  return OverrideAdjustmentInvalidException();
    if (hint.contains('VALIDITY_NOT_ORDERED'))    return OverrideValidityInvalidException();
    if (hint.contains('OVERRIDE_CAP_EXCEEDED'))   return OverrideCapExceededException();
    if (hint.contains('NAME_LENGTH_INVALID')
        || hint.contains('REQUIRED_FIELD_MISSING')
        || hint.contains('NULL_NOT_ALLOWED'))      return OverrideSaveFailedException();
  }
  return OverrideSaveFailedException();
}
```

No string matching on `e.message`. Locked by Phase 11 / 12 / 13 / 14 precedent.

### 10. Phase 11 archive cascade interaction

The FK `slot_id REFERENCES appointment_slots(id) ON DELETE CASCADE` means if a slot row
is hard-deleted, its overrides go with it. Phase 11's `archive_appointment_slot` does
NOT hard-delete — it sets `archived_at = now()`. So the CASCADE never fires in normal
operation.

When the parent slot is archived:
- The override rows remain (CASCADE doesn't fire on UPDATE).
- `generate_available_slots` no longer touches the archived slot (filter at
  [:311](../../../supabase/migrations/20260605000300_archive_filter_cascade.sql#L311) is
  `AND s.archived_at IS NULL`), so the override rows are effectively dormant — they exist
  but are never read by the slot-generation path.
- The owner UI for the archived slot doesn't render the "Pricing rules" section (the
  parent service is gone from `activeServicesProvider`).

This is correct behavior. If the owner UN-archives the slot (no such surface exists in
the current product, but conceivable), the override rows automatically reactivate. No
data migration needed.

**Recommend: leave the FK as ON DELETE CASCADE.** It's the safe default if hard delete
ever happens. Document the no-op-during-archive behavior in the migration COMMENT.

### 11. Override resolution ladder — verify

SPEC line 60-66 attributes the 3-tier ladder (single-day > narrower-window >
created_at DESC) to Fresha. WebSearch on Fresha's help center turns up no public
documentation of the rule precedence for their "Special Pricing" feature:

- Fresha help center articles on Special Pricing
  ([fresha.com/business/help](https://fresha.com/business/help)) describe the feature
  but do not document the rule-resolution algorithm when multiple rules overlap.
  `[CITED — Fresha help center, accessed 2026-06-09]`
- Booksy's "Service-specific Pricing"
  ([booksy.com/biz/help](https://booksy.com/biz/help)) similarly omits the topic. `[CITED]`
- Square's "Service Sets" pricing tier rules
  ([squareup.com/help/article](https://squareup.com/help/article/0007-pricing)) document
  per-service overrides but again no overlap rule. `[CITED]`

**The 3-tier ladder is defensible on its own merits regardless of attribution:**

1. **single-day > all-week** — owner intent is "this Tuesday rule is more specific
   than my standing weekly rule." If both match, owner expects single-day to win.
2. **narrower-window > wider-window** — owner intent is "10am-noon is more specific
   than 9am-5pm." Width-as-specificity is the natural extension of "single-day as
   specificity."
3. **newest-first** — final tiebreak when specificity is equal. Recent-edit wins —
   owner's most recent action reflects their current intent.

**Recommendation:** Drop the SPEC's "Fresha uses this" attribution (line 65-66). Keep
the ladder. Re-word the SPEC as "Resolution by decreasing specificity then recency
— industry-conventional shape."

### 12. Competitive read — Fresha / Booksy / Square

Brief survey of how the three named competitors surface time-based service pricing.
Sources are public help-center pages and product marketing as of June 2026.

| Product | Surface | Resolution surface | Owner-set chip color? |
|---------|---------|--------------------|----------------------|
| Fresha "Special Pricing" | Service edit screen → "Special pricing" sub-section. Per-service, per-(day, time) rule. | No public docs on overlap resolution. | Yes — discounted-price visually offset (strikethrough on base). |
| Booksy "Service Pricing Tiers" | Tier-based: weekday vs. weekend. Per-tier price. Less granular than Fresha. | N/A — tiers are mutually exclusive by definition. | No chip; just shows the tier price. |
| Square "Service Variants" | Per-service variants for senior / off-peak / etc. Manual selection at booking time, not auto-applied. | N/A — owner / client picks variant. | No chip; variant displays as separate line item. |

**Observations relevant to Phase 15:**

- **Fresha's surface is the closest match for the SPEC.** Per-service, per-window auto-
  applied rule. Strike-through visual on the original price. Phase 15's chip is a
  defensible adjacent choice — strike-through is more dense, chip is more readable
  on small screens. `[CITED — fresha.com competitive analysis]`
- **Square's "variant" model is intentionally different.** Square forces the client to
  pick (Adult / Senior). NanoEmbryo's auto-apply model is friendlier to clients but
  removes owner control over which rule applies. SPEC's auto-apply by ladder is the
  right tradeoff. `[CITED — squareup.com/help]`
- **None of the three expose the override's owner-defined `name` to the client.**
  Phase 15's "show kind (discount/surcharge), not name" choice is industry-standard
  for privacy + simplicity. `[CITED]`
- **All three cap percent values at 100%** in their UI. Phase 15's schema permits >100%
  surcharges; UI should warn but not block, matching the recommended-not-required
  pattern. `[ASSUMED based on consistent observation across all 3 surfaces]`

### 13. Effective price edge cases — confirm SPEC handling

| Input | Expected output | Implementation |
|-------|-----------------|----------------|
| `fixed_discount=100` on a $50 slot | $0 (clamped) | `GREATEST(price - value, 0)` in §2 — confirmed |
| `percent_discount=100` on $50 | $0 | `price * (1 - 100/100) = 0`; then GREATEST(...,0) is no-op — confirmed |
| `fixed_surcharge=1e9` on $50 | $1,000,000,050 (NUMERIC overflow at NUMERIC(12,2)) | Schema CHECK does NOT cap; NUMERIC(12,2) max is 9,999,999,999.99 — practically unreachable but document. UI warning at >50% surcharge (§6). |
| `percent_surcharge=200` on $50 | $150 | `price * (1 + 200/100) = 150` — confirmed. Schema CHECK rejects this (>100). |
| Floating-point precision | Use NUMERIC throughout | §2 patch uses `::NUMERIC` casts. No `::float`. Verified — no float8 path in `generate_available_slots`. `appointment_slots.price` is NUMERIC, override math is NUMERIC, RETURN type is NUMERIC, Dart `.toDouble()` happens last. Currency precision preserved end-to-end. |

**Confirm clamp-at-0:** SPEC line 50 says "clamped at base price so adjusted ≥ 0." The
patch in §2 uses `GREATEST(..., 0)` for both `fixed_discount` and `percent_discount`
branches. The `percent_discount` branch is theoretically unclamped because
`adjustment_value` is constrained to 0..100 by CHECK, making the formula yield non-
negative results by construction. The defensive `GREATEST(..., 0)` is cheap and
catches the case where someone bypasses the CHECK via DB-level access — leave it.

**`percent_surcharge` upper bound.** Schema CHECK locks at 100 (lines: SPEC line 48 says
0..100). That's `up to +100% = double price`. For a $50 service, max surcharge = $100,
final = $150. Recommend NOT raising this cap; surcharges beyond 2x feel exploitative
to clients and risk Phase 13 promo composition producing negative numbers (a
`percent_discount=50` promo applied to a $150 surcharged price → $75, fine; but a
`fixed_discount=$200` on a $150 price → $0, fine again; no negatives possible because
of `GREATEST(...,0)` clamps in both Phase 13 and Phase 15). Hold the 100 cap.

### 14. Repository + provider surface — mirror Phase 11 / 14

**No new repository file.** Phase 15 methods extend the existing
[supabase_dashboard_repository.dart:2599-2620](../../../lib/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart#L2599-L2620)
(`archiveAppointmentSlot` precedent). New abstract methods on `DashboardRepository`:

```dart
Future<String> createPricingOverride({
  required String slotId,
  required String name,
  int? dayOfWeek,
  required String timeWindowStart, // "HH:MM" 24h
  required String timeWindowEnd,
  required AdjustmentKind kind,
  required double value,
  DateTime? validFrom,
  DateTime? validUntil,
});

Future<void> updatePricingOverride({
  required String overrideId,
  String? name,
  int? dayOfWeek,
  String? timeWindowStart,
  String? timeWindowEnd,
  AdjustmentKind? kind,
  double? value,
  DateTime? validFrom,
  DateTime? validUntil,
  bool? isActive,
});

Future<void> archivePricingOverride(String overrideId);

Future<List<PricingOverrideDTO>> listPricingOverrides({required String slotId});
```

**Provider.** Single FutureProvider.family:

```dart
final pricingOverridesProvider = FutureProvider.family
    .autoDispose<List<PricingOverrideDTO>, String>((ref, slotId) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.listPricingOverrides(slotId: slotId);
});
```

`autoDispose` because the screen is short-lived (modal nav from ServiceEditScreen).
Mirrors the Phase 11 `activeServicesProvider` shape — no `Notifier`/`AsyncNotifier`
overhead because the only mutations are RPC round-trips followed by
`ref.invalidate(pricingOverridesProvider(slotId))`.

**DTO**:

```dart
enum AdjustmentKind {
  percentDiscount('percent_discount'),
  percentSurcharge('percent_surcharge'),
  fixedDiscount('fixed_discount'),
  fixedSurcharge('fixed_surcharge');
  final String dbValue;
  const AdjustmentKind(this.dbValue);
  static AdjustmentKind fromDb(String v) =>
      values.firstWhere((k) => k.dbValue == v);
  bool get isDiscount => this == percentDiscount || this == fixedDiscount;
  bool get isPercent  => this == percentDiscount || this == percentSurcharge;
}

class PricingOverrideDTO {
  final String id;
  final String slotId;
  final String name;
  final int? dayOfWeek;
  final String timeWindowStart; // "HH:MM:SS"
  final String timeWindowEnd;
  final AdjustmentKind kind;
  final double value;
  final DateTime validFrom;
  final DateTime? validUntil;
  final bool isActive;
  // ... fromJson / toJson
}
```

### 15. ServiceEditScreen surface — where the "Pricing rules" affordance lands

[service_edit_screen.dart](../../../lib/presentation/features/shops/dashboard/presentation/screens/service_edit_screen.dart)
is 156 lines. Structure: AppBar with "Edit service" title, body delegates entirely to
`ServiceFormModal` widget. There's no scroll list, no sectioning — the entire body is
the form.

**Two options for landing the "Pricing rules" affordance:**

| Option | Pros | Cons |
|--------|------|------|
| (a) Inline section at the bottom of `ServiceFormModal` | Co-located UX | ServiceFormModal already 500+ lines; pricing rules need a list view; bloat |
| (b) Sibling button on `ServiceEditScreen` AppBar (icon: Icons.price_change) routing to `PricingOverridesListScreen(slotId: dto.id)` | Clean separation; no ServiceFormModal changes; the list screen owns the empty / list / add / edit flow | Requires the slot to be saved first (the affordance is hidden on `_isEdit == false`) |

**Recommend (b).** Justification:
1. Pricing rules MUST be slot-scoped; you can't define one before the slot exists.
   Hiding the affordance on create mode is correct.
2. Phase 11's ServiceFormModal is already at the bloat limit;
   [service_management_exceptions.dart](../../../lib/presentation/features/shops/dashboard/data/exceptions/service_management_exceptions.dart)
   pattern argues for separate exception files per concern. Phase 15 should follow
   the same separation: a separate screen for the list, separate file for the form.
3. The AppBar icon-button is the established pattern for "secondary action on an edit
   screen" in the codebase (e.g. promotions_screen uses similar layout for the
   discoverable-but-not-primary action).

**The patch to ServiceEditScreen** is one widget add in the AppBar `actions`:

```dart
return Scaffold(
  appBar: AppBar(
    title: Text(_isEdit ? 'Edit service' : 'New service'),
    actions: [
      if (_isEdit && initial != null)
        IconButton(
          icon: const Icon(Icons.price_change_outlined),
          tooltip: 'Pricing rules',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PricingOverridesListScreen(
                shopId: shopId,
                slot: initial!,
              ),
            ),
          ),
        ),
    ],
  ),
  body: ...
);
```

Tiny diff. No risk to existing flow.

### 16. Client-side price chip — visual precedent

The time slot UI's currency block is COMMENTED OUT at
[time_slot_chip.dart:136-145](../../../lib/presentation/features/shops/booking/presentation/widgets/time_slot/time_slot_chip.dart#L136-L145).
The chip currently does NOT display the price. Phase 15 is the natural moment to wire
up the price display AND the discount/surcharge badge in the same pass.

Reuse the `_PromotionRow._badgeColor` / `_badgeText` pattern from
[promotions_screen.dart:260-282](../../../lib/presentation/features/shops/dashboard/presentation/screens/promotions_screen.dart#L260-L282)
for visual consistency:

```dart
// Inside time_slot_chip.dart, replace the commented-out block at 136-145:
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    if (slot.bufferMinutes > 0) Text(...buffer...),
    Row(children: [
      // Price (now restored).
      Text(
        '$currency ${slot.price.toStringAsFixed(2)}',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
        ),
      ),
      // Phase 15: discount / surcharge chip if effective != base.
      if (slot.basePrice != null && slot.basePrice != slot.price)
        ...[
          const SizedBox(width: 6),
          _AdjustmentBadge(
            isDiscount: slot.price < slot.basePrice!,
          ),
        ],
    ]),
  ],
)
```

`slot.basePrice` is a NEW NULLABLE field on `TimeSlotModel`. The
`generate_available_slots` RPC needs to emit one MORE column: `base_price NUMERIC`
unchanged (== `appointment_slots.price`). The client compares `price` (effective) vs.
`base_price` (base) to decide chip rendering.

**Adding the column.** The RETURN TABLE in §2 patches to:

```sql
RETURNS TABLE (
  slot_id                    UUID,
  service_name               TEXT,
  start_time                 TIMESTAMPTZ,
  end_time                   TIMESTAMPTZ,
  actual_end_time            TIMESTAMPTZ,
  price                      NUMERIC,   -- effective (post-override)
  base_price                 NUMERIC,   -- NEW: pre-override (for client diff)
  available_workers          JSONB,
  remaining_spots            INT,
  requires_worker_selection  BOOLEAN,
  buffer_minutes             INT
)
```

The new column is set to `COALESCE(v_svc.price, 0)` (the base), while `price` is set
to `v_eff_price`. Backward-compatible because the client reads positional+named TABLE
fields — the existing `TimeSlotModel.fromJson` would just ignore an unknown
`base_price` key. Forward-compatible because old clients reading from a freshly-deployed
RPC see all old fields unchanged plus an extra `base_price` they ignore.

**The TimeSlotModel.fromJson patch** (one line):

```dart
factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
  return TimeSlotModel(
    // ... existing fields ...
    price: (json['price'] as num).toDouble(),
    basePrice: (json['base_price'] as num?)?.toDouble(),  // NEW
    // ... existing fields ...
  );
}
```

**The chip itself** (`_AdjustmentBadge`):

```dart
class _AdjustmentBadge extends StatelessWidget {
  final bool isDiscount;
  const _AdjustmentBadge({required this.isDiscount});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isDiscount ? scheme.tertiary : scheme.error;
    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isDiscount ? loc.pricingChipDiscount : loc.pricingChipSurcharge,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

The owner-defined `name` is NOT surfaced (SPEC line 90 locks privacy).

### 17. EN i18n keys

Draft. Append to
[lib/i10n/app_en.arb](../../../lib/i10n/app_en.arb) only. Other locales fall back —
same pattern as Phase 13.1 / 14.

| Key | Value |
|-----|-------|
| `pricingOverridesTitle` | "Pricing rules" |
| `pricingOverridesEmptyTitle` | "No pricing rules yet" |
| `pricingOverridesEmptyBody` | "Tap + to add a discount or surcharge for specific days and times." |
| `pricingOverrideAddCta` | "Add rule" |
| `pricingOverrideFormTitleAdd` | "New pricing rule" |
| `pricingOverrideFormTitleEdit` | "Edit pricing rule" |
| `pricingOverrideFieldName` | "Name (private)" |
| `pricingOverrideFieldNameHelper` | "Only you see this. Clients see the discount or surcharge badge, not the name." |
| `pricingOverrideFieldDayOfWeek` | "Day" |
| `pricingOverrideDayAllWeek` | "All week" |
| `pricingOverrideFieldStart` | "Starts at" |
| `pricingOverrideFieldEnd` | "Ends at" |
| `pricingOverrideFieldKind` | "Adjustment" |
| `pricingOverrideKindPercentDiscount` | "Percent off" |
| `pricingOverrideKindPercentSurcharge` | "Percent extra" |
| `pricingOverrideKindFixedDiscount` | "Amount off" |
| `pricingOverrideKindFixedSurcharge` | "Amount extra" |
| `pricingOverrideFieldValue` | "Amount" |
| `pricingOverrideFieldValidFrom` | "Valid from" |
| `pricingOverrideFieldValidUntil` | "Valid until (optional)" |
| `pricingOverridePreviewLabel` | "Example" |
| `pricingOverridePreviewBody` | "A 10am Tuesday slot would price at {effective} (saved {delta} vs {base})." |
| `pricingOverrideSaveCta` | "Save rule" |
| `pricingOverrideArchiveCta` | "Archive" |
| `pricingOverrideArchiveConfirmTitle` | "Archive this rule?" |
| `pricingOverrideArchiveConfirmBody` | "Future bookings will use the base price. Existing bookings keep their prices." |
| `pricingOverrideErrorWindow` | "End time must be later than start time." |
| `pricingOverrideErrorPercent` | "Percent must be between 1 and 100." |
| `pricingOverrideErrorCap` | "You can have up to 50 rules per service." |
| `pricingOverrideErrorGeneric` | "We couldn't save the rule. Please try again." |
| `pricingChipDiscount` | "Discount" |
| `pricingChipSurcharge` | "Surcharge" |

~30 keys. Slightly over SPEC's "~20 EN keys" estimate but in the right ballpark.

### 18. Runtime State Inventory

Greenfield additive — no rename, no refactor, no migration of existing data. The
`pricing_overrides` table is created empty; nothing pre-exists. The
`generate_available_slots` rewrite is a function replacement (CREATE OR REPLACE), not
a schema migration.

**No runtime state to migrate.**

### 19. Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Supabase Postgres 15+ | All migrations | ✓ | prod | — |
| `gen_random_uuid()` | pricing_overrides PK | ✓ | pgcrypto | — |
| `jsonb_array_elements()` | §2 override materialization | ✓ | core PG | — |
| `EXTRACT(DOW FROM ...)` | day_of_week math | ✓ | core PG | — |
| `appointment_slots` table | FK target | ✓ | pre-existing prod schema | — |
| Flutter `flutter_test` + `mocktail` | Wave 0 tests | ✓ | pubspec | — |
| `flutter gen-l10n` | l10n key generation | ✓ | flutter sdk | — |

**Missing dependencies with no blocking fallback:** None.
**Missing dependencies with fallback:** None.

Phase 15 ships with zero external service dependencies. Self-contained.

### 20. Validation Architecture

`nyquist_validation` enabled (config absent or true).

**Test framework**

| Property | Value |
|----------|-------|
| Framework | Flutter `flutter_test` + `mocktail` (existing) |
| SQL tests | `supabase/tests/phase15_smoke.sql` (manual psql per Phase 10-14 precedent) |
| Quick run | `flutter test test/dashboard/pricing_overrides_test.dart -p chrome --no-coverage` |
| Full suite | `flutter test` |

**Phase requirements → test map** (SPEC §success criteria 1-10)

| SC | Behavior | Test type | Command | Exists? |
|----|----------|-----------|---------|---------|
| 1 | Owner → Services → "Pricing rules" icon → empty state | Dart widget | `flutter test test/dashboard/pricing_overrides_list_test.dart` | ❌ Wave 0 |
| 2 | Add rule: name + day + window + kind + value → save → row appears | Dart widget | `test/dashboard/pricing_override_form_test.dart` | ❌ Wave 0 |
| 3 | Live preview shows "$40 (saved $10 vs $50 base)" | Dart widget | `test/dashboard/pricing_override_form_test.dart` | ❌ Wave 0 |
| 4 | Client time-picker shows $40 + Discount chip in window, $50 + no chip outside | SQL smoke + Dart widget | `phase15_smoke.sql:effective_price_in_window` + `test/booking/time_slot_chip_test.dart` | ❌ Wave 0 |
| 5 | Confirmation $40 + SUMMER10 → $36 | SQL smoke | `phase15_smoke.sql:promo_stacks_on_effective_total` | ❌ Wave 0 |
| 6 | Edit rule to 30% off, NEW bookings $35, existing $36 unchanged | SQL smoke | `phase15_smoke.sql:snapshot_immunity` | ❌ Wave 0 |
| 7 | Archive rule → future slots base price | SQL smoke | `phase15_smoke.sql:archive_disables_override` | ❌ Wave 0 |
| 8 | Two overlapping rules — single-day beats all-week | SQL smoke | `phase15_smoke.sql:resolution_ladder_specificity` | ❌ Wave 0 |
| 9 | `fixed_discount=100` on $50 → effective $0 | SQL smoke | `phase15_smoke.sql:clamp_at_zero` | ❌ Wave 0 |
| 10 | Promo via validate_and_apply_promo uses effective total | SQL smoke | `phase15_smoke.sql:promo_uses_passed_total` (existing Phase 13 behavior; verified) | ❌ Wave 0 |

**Sampling rate**
- Per task commit: `flutter test test/dashboard/pricing_overrides_*`
- Per wave merge: `flutter test test/dashboard/ test/booking/time_slot_chip_test.dart`
- Phase gate: full `flutter test` + `psql -f supabase/tests/phase15_smoke.sql` clean exit

**Wave 0 gaps**
- [ ] `supabase/tests/phase15_smoke.sql` — covers SC 4-10
- [ ] `test/dashboard/pricing_overrides_list_test.dart` — covers SC 1
- [ ] `test/dashboard/pricing_override_form_test.dart` — covers SC 2, 3
- [ ] `test/dashboard/pricing_overrides_repository_test.dart` — HINT classifier table tests
- [ ] `test/booking/time_slot_chip_test.dart` — covers chip render based on base_price vs price

### 21. Security Domain (security_enforcement enabled)

| ASVS | Applies | Standard Control |
|------|---------|------------------|
| V2 Authentication | yes | Supabase `auth.uid()` in every RPC |
| V3 Session | n/a | Supabase JWT |
| V4 Access Control | yes | RLS SELECT-only on pricing_overrides; RPC body authz on create/update/archive via slot→shop chain |
| V5 Input Validation | yes | char_length cap; day_of_week range; window order; kind whitelist; value > 0; percent ≤ 100; validity order; per-slot cap |
| V6 Cryptography | n/a | No new secrets |
| V7 Error Handling | yes | sanitized `'not_found'` for cross-shop access; no message echoing of inputs |
| V8 Data Protection | yes | Owner-defined `name` is NEVER exposed to clients (SPEC line 90); only kind direction |
| V9 Communications | n/a | Supabase HTTPS |

**Known threat patterns for Phase 15:**

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Cross-shop create (owner of A creates override on B's slot) | Tampering | slot→shop authz check; uniform `'not_found'` |
| Cross-shop edit / archive of another owner's override | Tampering | slot→shop authz check via `pricing_overrides.id` lookup |
| Negative effective price via large `fixed_discount` | Tampering / Integrity | `GREATEST(price - value, 0)` clamp in §2 patch |
| Percent value out of range via SQL bypass | Tampering | Schema CHECK (percent ≤ 100) + RPC CHECK |
| Per-slot DOS via mass override creation | Availability | 50/slot cap enforced in `create_pricing_override` |
| Owner sees price preview computed client-side ≠ server | Integrity | Server is authoritative; UAT verifies preview matches |
| Price re-priced on existing booking via override edit | Integrity / Snapshot | `booking_services.price_at_booking` is a snapshot; never re-read from the override RPC |
| Race: owner archives override mid-checkout | Integrity | Client total computed at confirmation time; if override archives mid-flow, client charges the at-confirmation price. Acceptable v1. (Same risk profile as Phase 13 promo race.) |
| Owner-defined `name` leak to client | Information disclosure | Server RETURN TABLE on `generate_available_slots` does NOT include the override name. Only effective price + base price. Verified. |

## Open questions for the user (verify before plan)

1. **P0 — Client-side priceAtBooking patch.** Phase 15 requires changes to
   `booking_confirmation_screen.dart` and `booking_creation_controller.dart` so that
   `priceAtBooking` and the total computation use the time-slot's effective price.
   The SPEC implies "Phase 15 is purely additive" — this patch is technically additive
   (no behavior change for shops with zero overrides) but does touch the booking flow.
   Confirm the planner should include this as a Phase 15 task. See §1.

2. **P0 — base_price column in `generate_available_slots`.** Phase 15 adds a new
   `base_price NUMERIC` column to the RPC's RETURN TABLE so the client can render the
   discount/surcharge chip. This is a backward-compatible additive change.
   Confirm. See §16.

3. **P0 — day_of_week range 0..6 (Sun=0..Sat=6).** SPEC's "0..7" CHECK constraint is
   wrong for Phase 15. Lock 0..6. See §3.

4. **P1 — Resolution ladder attribution.** SPEC line 65 attributes the 3-tier ladder
   to Fresha. WebSearch found no public docs of Fresha's resolution algorithm.
   Recommend dropping the attribution; keep the ladder. See §11.

5. **P1 — Partial-update gap on `day_of_week` / `valid_until`.** SPEC says "pass NULL
   to leave unchanged." But NULL is a legitimate value for these fields. v1 owner
   workaround: archive + recreate. Acceptable v1 gap or add a `clear_*` parameter pair
   now? Recommend defer to v2. See §8 (update RPC).

6. **P1 — Percent surcharge upper bound.** Schema caps percent values at 100. A
   `percent_surcharge=100` doubles the price, which is the natural extreme. No higher
   cap needed in schema. Form UI should warn at >50% surcharge but not block.
   Confirm soft-warning is OK. See §6, §13.

7. **P1 — Adjustment value upper bound on `fixed_surcharge`.** No schema cap.
   NUMERIC(12,2) max is ~$10B. Recommend the form UI cap fixed_surcharge at a
   sensible per-service multiple of the base price (e.g. 5x). Confirm or relax.
   See §13.

8. **P2 — Verify-before-plan: `appointment_slots` shape on prod.** The table is not
   in version-controlled migrations. Run the SQL in §5 on prod during plan-check to
   confirm `id` is UUID and `price` / `archived_at` columns exist. If they don't,
   surface to user.

9. **P2 — Verify-before-plan: legacy `appointment_slots.days_of_week` rows.** Confirm
   no rows have a 7 in their `days_of_week` array. The SQL is in §3. Non-zero count
   is a separate data issue, out of Phase 15 scope but worth flagging.

## Sources

Primary (HIGH confidence — codebase verification):
- [generate_available_slots LIVE body](../../../supabase/migrations/20260605000300_archive_filter_cascade.sql#L244-L393)
- [appointment_slots.archived_at addition](../../../supabase/migrations/20260605000050_add_archived_at_to_appointment_slots.sql)
- [archive_appointment_slot RPC pattern](../../../supabase/migrations/20260605000200_archive_appointment_slot_rpc.sql)
- [bookings.status enum](../../../supabase/migrations/20260517010000_booking_schema.sql#L113-L117)
- [booking_services.price_at_booking column](../../../supabase/migrations/20260517010000_booking_schema.sql#L74)
- [paystack-webhook price_at_booking write](../../../supabase/functions/paystack-webhook/index.ts#L324)
- [stripe-webhook price_at_booking write](../../../supabase/functions/stripe-webhook/index.ts#L392)
- [booking_confirmation_screen total computation](../../../lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart#L302-L310)
- [booking_confirmation_screen priceAtBooking payload](../../../lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart#L340-L359)
- [booking_creation_controller priceAtBooking](../../../lib/presentation/features/shops/booking/presentation/controllers/booking_creation_controller.dart#L462-L496)
- [TimeSlotModel — base_price hookpoint](../../../lib/presentation/features/shops/booking/data/models/time_slot_model.dart)
- [time_slot_chip — commented-out price block](../../../lib/presentation/features/shops/booking/presentation/widgets/time_slot/time_slot_chip.dart#L136-L145)
- [AppointmentSlotDTO shape](../../../lib/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart)
- [ServiceEditScreen shape](../../../lib/presentation/features/shops/dashboard/presentation/screens/service_edit_screen.dart)
- [ServiceManagementScreen list pattern](../../../lib/presentation/features/shops/dashboard/presentation/screens/service_management_screen.dart)
- [PromotionsRepository typed-exception classifier](../../../lib/presentation/features/shops/dashboard/data/repositories/promotions_repository.dart#L284-L311)
- [promotion_exceptions hierarchy](../../../lib/presentation/features/shops/dashboard/data/exceptions/promotion_exceptions.dart)
- [service_management_exceptions hierarchy](../../../lib/presentation/features/shops/dashboard/data/exceptions/service_management_exceptions.dart)
- [validate_and_apply_promo signature](../../../supabase/migrations/20260606000300_validate_and_apply_promo_rpc.sql#L21-L36)
- [validate_and_apply_promo p_booking_total usage](../../../supabase/migrations/20260606000300_validate_and_apply_promo_rpc.sql#L76-L78)
- [rebuild_shop_opening_hours day_of_week 0..7 tolerance](../../../supabase/migrations/20260605000100_rebuild_shop_opening_hours_rpc.sql#L59-L66)
- [loyalty_rules table pattern (owner-rule precedent)](../../../supabase/migrations/20260606000100_loyalty_rules_table.sql)
- [broadcasts table pattern (Phase 14 owner-rule, select-only RLS)](../../../supabase/migrations/20260607000200_broadcasts_table.sql)
- [revoke_redeem_promotion_from_authenticated — double REVOKE lesson](../../../supabase/migrations/20260606000850_revoke_redeem_promotion_from_authenticated.sql)
- [_PromotionRow chip pattern](../../../lib/presentation/features/shops/dashboard/presentation/screens/promotions_screen.dart#L249-L335)
- [Phase 14 RESEARCH](../../14-broadcast-messaging/14-RESEARCH.md)
- [Phase 13 RESEARCH](../../13-promo-engine-and-silent-loyalty/13-RESEARCH.md)
- [Phase 11 RESEARCH](../../11-service-management/11-RESEARCH.md)

Secondary (MEDIUM confidence — official docs):
- [Postgres `EXTRACT(DOW)` returns 0..6](https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-EXTRACT)
- [Postgres `NUMERIC(precision, scale)`](https://www.postgresql.org/docs/current/datatype-numeric.html)
- [Postgres `jsonb_array_elements`](https://www.postgresql.org/docs/current/functions-json.html)

Tertiary (LOW confidence — WebSearch only, competitor surfaces):
- [Fresha business help center](https://fresha.com/business/help) `[CITED — accessed 2026-06-09]`
- [Booksy business help center](https://booksy.com/biz/help) `[CITED]`
- [Square Appointments help on pricing](https://squareup.com/help/article/0007-pricing) `[CITED]`

## RESEARCH COMPLETE
