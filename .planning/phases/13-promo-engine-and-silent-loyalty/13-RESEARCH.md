# Phase 13 Research — Promo Engine + Silent Loyalty

## Summary

Six corrections the planner MUST absorb before writing tasks. The first one
reframes the entire phase.

1. **`promotions` and `promotion_redemptions` ALREADY EXIST in production.** The
   SPEC proposes `promo_codes` + `promo_redemptions` as new tables. They are
   not new. [20260604000100_backfill_tools_screen_drift.sql:22-82](../../../supabase/migrations/20260604000100_backfill_tools_screen_drift.sql#L22-L82)
   creates `promotions` (`shop_id`, `name`, `code`, `discount_type ∈
   {percentage, fixed, free_addon}`, `discount_value NUMERIC`, `valid_from
   DATE`, `valid_to DATE`, `usage_limit`, `usage_count`, `is_active`) and
   `promotion_redemptions` (`promotion_id`, `booking_id`, `user_id NULLABLE`,
   `discount_amount`, UNIQUE on `(promotion_id, booking_id)`).
   `redeem_promotion(p_promotion_id, p_booking_id, p_user_id, p_discount_amount)`
   is the existing atomic counter+ledger writer
   ([20260604000400_redeem_promotion.sql](../../../supabase/migrations/20260604000400_redeem_promotion.sql)).
   A full owner-facing UI exists today: `PromotionsScreen`, `CreatePromotionScreen`,
   `PromotionsRepository`, `PromotionsController`, `Promotion` model with
   `DiscountType` enum, `PromotionException` hierarchy with HINT-routed typed
   exceptions. Tools tab already links to it
   ([tools_screen.dart:113-116](../../../lib/presentation/features/shops/dashboard/presentation/screens/tools_screen.dart#L113-L116)).
   **The planner must pick one of: (a) EXTEND the existing tables with the
   new columns Phase 13 needs (`source`, `target_user_id`,
   `target_guest_profile_id`, `archived_at`, `per_client_max`,
   `min_booking_amount`, `service_restriction`, `valid_from/_to → TIMESTAMPTZ`),
   or (b) Build a parallel `promo_codes` / `promo_redemptions` schema and
   leave the existing `promotions` table dormant.** Recommend (a). See §1.

2. **`bookings.total_amount` is the discount target. There is no `subtotal`.**
   The bookings DDL has only `total_amount`, `deposit_amount`, `platform_fee`
   ([20260517010000_booking_schema.sql:49-51](../../../supabase/migrations/20260517010000_booking_schema.sql#L49-L51)).
   The webhook insert path writes `total_amount: pending.amount` where
   `pending.amount` is the already-validated total from `pending_payments`
   ([paystack-webhook/index.ts:152, stripe-webhook/index.ts:214, verify-payment/index.ts:147](../../../supabase/functions/paystack-webhook/index.ts#L152)).
   `platform_fee` is computed CLIENT-SIDE in `payment_controller.dart` as
   `totalPrice * config.platformFeeFraction`
   ([booking_confirmation_screen.dart:335](../../../lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart#L335)),
   passed as a raw value through the metadata payload, and stored as-is.
   **Platform fee is computed AGAINST the pre-discount total today.** Phase
   13 needs to decide: does platform_fee get recomputed against the DISCOUNTED
   total (clean), or stay against the pre-discount total (shop earns less,
   platform earns the same)? Both have business semantics. SPEC line 76-77
   says "Platform fee + deposit are recomputed against the discounted total
   before payment." Confirm. See §2.

3. **The webhook integration point is NOT Stripe/Paystack metadata. It's
   `pending_payments.booking_data`.** All three webhooks read the booking
   payload from `pending_payments` (a Supabase table), not from the payment
   provider's metadata field. `pending_payments.booking_data` is a JSONB
   blob containing the entire `processPayment` request body
   ([create-booking/index.ts:466-477](../../../supabase/functions/create-booking/index.ts#L466-L477)).
   This means: Stripe and Paystack metadata size limits are IRRELEVANT to
   Phase 13. Adding `promoCodeId` to the `processPayment` request body
   ([payment_controller.dart:123-139](../../../lib/payment/presentation/controllers/payment_controller.dart#L123-L139))
   carries it through to the webhook with zero size pressure. See §3.

4. **The Phase 12 `cancel_and_followup` is called INLINE from RPC bodies, not
   from a trigger.** `mark_booking_complete` UPDATEs status THEN PERFORMs
   `cancel_and_followup`
   ([20260605130700_wire_terminal_rpcs.sql:109-119](../../../supabase/migrations/20260605130700_wire_terminal_rpcs.sql#L109-L119)).
   This means Phase 13's new AFTER UPDATE trigger on `bookings` fires
   BEFORE `cancel_and_followup` runs (the trigger fires during the UPDATE
   statement; PERFORM is a later statement). Trigger ordering with the
   existing `trg_bookings_schedule_reminders`
   ([20260605130600_booking_lifecycle_triggers.sql:51](../../../supabase/migrations/20260605130600_booking_lifecycle_triggers.sql#L51))
   is irrelevant — that trigger has `WHEN (NEW.status = 'confirmed')` and
   only fires on the confirmed transition, NOT on the completed transition.
   Zero conflict. The loyalty trigger fires alone on the completed
   transition. See §4.

5. **Recovery code generation in `enqueue_booking_reminder` is a clean
   inline change.** The Phase 12 helper
   ([20260605130400_enqueue_booking_reminder_helper.sql](../../../supabase/migrations/20260605130400_enqueue_booking_reminder_helper.sql))
   composes `whatsapp_params` and `metadata.body` inside the function. The
   recovery_checkin branch builds `jsonb_build_object('1', v_client_name,
   '2', v_shop_name)` for WhatsApp and a hand-crafted body string for push.
   Phase 13 inserts a `generate_recovery_code(p_booking_id)` call BEFORE the
   v_template/v_body construction, then appends the code text as variable
   `{{3}}` in WhatsApp params and concatenates "`Use code <CODE> for X% off`"
   into the body. **The helper rewrite is contained.** See §5.

6. **Meta WhatsApp templates support up to 15 variables.** Existing
   `recovery_checkin_v1` uses `{{1}} = client_name` and `{{2}} = shop_name`.
   Adding `{{3}} = code` is well under the 15-var cap, but submitting a
   modified template requires Meta re-approval and the existing 6h
   `WhatsAppTemplateNotFoundError` retry behavior covers the gap. **A
   parallel `recovery_checkin_v2` template is the safer migration path** —
   submit v2 for approval before the helper switches, then change the
   `_v1` → `_v2` line in the helper. See §6.

## Findings

### 1. Existing `promotions` schema vs. SPEC's `promo_codes` — extend, don't rebuild

The SPEC's proposed `promo_codes` columns versus the existing `promotions`
columns:

| SPEC's `promo_codes`              | Existing `promotions`        | Reconciliation                                  |
|-----------------------------------|------------------------------|-------------------------------------------------|
| `code TEXT`                       | `code TEXT`                  | Same. UNIQUE (shop_id, code) already enforced.  |
| `shop_id UUID`                    | `shop_id UUID`               | Same.                                           |
| `discount_kind ∈ {percent,fixed}` | `discount_type ∈ {percentage,fixed,free_addon}` | Rename or accept `discount_type`. free_addon is unused-by-Phase-13. |
| `discount_value NUMERIC`          | `discount_value NUMERIC`     | Same.                                           |
| `valid_from`, `valid_until`       | `valid_from DATE`, `valid_to DATE` | **DATE vs TIMESTAMPTZ.** ALTER COLUMN TYPE. See below. |
| `max_redemptions INT`             | `usage_limit INT`            | Rename or accept `usage_limit`.                 |
| `per_client_max INT`              | (missing)                    | ADD COLUMN.                                     |
| `min_booking_amount NUMERIC`      | (missing)                    | ADD COLUMN.                                     |
| `service_restriction UUID[]`      | (missing)                    | ADD COLUMN.                                     |
| `source ∈ {owner_defined,loyalty,recovery}` | (missing)          | ADD COLUMN. Default 'owner_defined' on backfill. |
| `target_user_id`                  | (missing)                    | ADD COLUMN.                                     |
| `target_guest_profile_id`         | (missing)                    | ADD COLUMN.                                     |
| `archived_at TIMESTAMPTZ`         | `is_active BOOLEAN`          | KEEP `is_active` for owner UI on/off. ADD `archived_at` for soft-delete (silent codes never get is_active=false; they archive on redemption). |

**Critical schema detail: `valid_from/valid_to` are DATE, not TIMESTAMPTZ.**
[backfill_tools_screen_drift.sql:12](../../../supabase/migrations/20260604000100_backfill_tools_screen_drift.sql#L12)
calls this out explicitly. The owner UI persists dates as
`toIso8601String().split('T').first`
([promotion_model.dart:118-119](../../../lib/presentation/features/shops/dashboard/data/models/promotion_model.dart#L118-L119)).
Recovery codes need a 30-day TTL with hour-level precision (the SPEC says
`valid_until = now() + 30 days`). Loyalty codes have no TTL. Two options:

- **(a) ALTER COLUMN TYPE valid_from/valid_to TO TIMESTAMPTZ.** Existing data
  is preserved (DATE → TIMESTAMPTZ widens). The owner UI keeps writing dates;
  Postgres coerces to midnight UTC. Server-generated codes write timestamps
  with sub-second precision. **Risk:** existing Dart code reads `valid_to`
  as a date string; the timestamp serialization will include a time
  component (`2026-07-05T00:00:00+00:00`). The
  `DateTime.parse(json['valid_to'])` call in `promotion_model.dart:101`
  handles both shapes — no client-side break.
- **(b) Keep `valid_from/valid_to DATE`, add `valid_until_at TIMESTAMPTZ` for
  system-generated codes.** Two-column validity is footgun-prone; reject.

Recommend (a). Document the schema migration: `ALTER TABLE promotions ALTER
COLUMN valid_from TYPE TIMESTAMPTZ USING valid_from::TIMESTAMPTZ; ALTER COLUMN
valid_to TYPE TIMESTAMPTZ USING valid_to::TIMESTAMPTZ;`

**Code rename: `code`, `shop_id`, `discount_type`, `discount_value`,
`usage_limit`, `usage_count`, `is_active` stay as-is.** Rewriting these to
match the SPEC's names breaks the entire existing owner-facing UI for zero
upside. The SPEC's terminology was written without knowledge of the existing
table. The planner should adopt the existing column names in all new
migrations and RPCs.

**Backfill safety:** every ADD COLUMN must be `IF NOT EXISTS` and idempotent.
The new columns have safe defaults:

```sql
ALTER TABLE public.promotions
  ADD COLUMN IF NOT EXISTS per_client_max          INT NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS min_booking_amount      NUMERIC,
  ADD COLUMN IF NOT EXISTS service_restriction     UUID[],
  ADD COLUMN IF NOT EXISTS source                  TEXT NOT NULL DEFAULT 'owner_defined'
    CHECK (source IN ('owner_defined','loyalty','recovery')),
  ADD COLUMN IF NOT EXISTS target_user_id          UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS target_guest_profile_id UUID REFERENCES public.guest_profiles(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS archived_at             TIMESTAMPTZ;
```

Plus the partial unique index for the auto-apply lookup path
(see §11):

```sql
CREATE UNIQUE INDEX IF NOT EXISTS promotions_silent_target_uniq
  ON public.promotions (shop_id, COALESCE(target_user_id, target_guest_profile_id), source)
  WHERE source IN ('loyalty','recovery') AND archived_at IS NULL;
```

**RLS migration:** the existing `promotions_owner_all` policy
([backfill_tools_screen_drift.sql:40](../../../supabase/migrations/20260604000100_backfill_tools_screen_drift.sql#L40))
is FOR ALL — owner can SELECT/INSERT/UPDATE/DELETE. **System-generated codes
(source IN ('loyalty', 'recovery')) need a SECURITY DEFINER insert path** so
the trigger / helper can write them without auth.uid() matching. The existing
policy doesn't block this because SECURITY DEFINER functions bypass RLS.
**Tighten the policy to deny direct INSERT of system codes** so a malicious
owner can't fabricate `source='loyalty', target_user_id=<arbitrary>` rows:

```sql
DROP POLICY IF EXISTS promotions_owner_all ON public.promotions;
CREATE POLICY promotions_owner_select ON public.promotions
  FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.shops s
                 WHERE s.id = promotions.shop_id AND s.user_id = auth.uid()));
CREATE POLICY promotions_owner_write_owner_defined ON public.promotions
  FOR INSERT TO authenticated
  WITH CHECK (
    source = 'owner_defined'
    AND EXISTS (SELECT 1 FROM public.shops s
                WHERE s.id = promotions.shop_id AND s.user_id = auth.uid())
  );
CREATE POLICY promotions_owner_update_owner_defined ON public.promotions
  FOR UPDATE TO authenticated
  USING (source = 'owner_defined' AND EXISTS (SELECT 1 FROM public.shops s
                                              WHERE s.id = promotions.shop_id AND s.user_id = auth.uid()))
  WITH CHECK (source = 'owner_defined');
CREATE POLICY promotions_owner_delete_owner_defined ON public.promotions
  FOR DELETE TO authenticated
  USING (source = 'owner_defined' AND EXISTS (SELECT 1 FROM public.shops s
                                              WHERE s.id = promotions.shop_id AND s.user_id = auth.uid()));
```

Existing `promotion_redemptions` retention is **no deletion ever** — confirmed
by absence of a delete policy. Phase 13 inherits this. Forensic; locked.

### 2. `bookings` discount column + platform_fee timing

Verified column shape ([20260517010000_booking_schema.sql:49-51](../../../supabase/migrations/20260517010000_booking_schema.sql#L49-L51)):

```sql
total_amount        NUMERIC(12,2) NOT NULL,
deposit_amount      NUMERIC(12,2) NOT NULL DEFAULT 0,
platform_fee       NUMERIC(12,2),
```

No `subtotal` column. **`total_amount` IS the discount target.** SPEC's
`min_booking_amount` semantics compare against `total_amount` (the
pre-discount sum of services). `validate_and_apply_promo` returns
`amount_off` and `new_total`; the client stores `new_total` as the value to
send as `totalAmount` in `processPayment`.

**Platform fee timing — locked decision needed from user.** Three places in
the codebase compute platform_fee:

- Client: `totalPrice * config.platformFeeFraction`
  ([booking_confirmation_screen.dart:335](../../../lib/presentation/features/shops/booking/presentation/screens/client/booking_confirmation_screen.dart#L335))
- Webhook: takes the client-passed value verbatim, stores in
  `bookings.platform_fee` ([paystack-webhook/index.ts:154](../../../supabase/functions/paystack-webhook/index.ts#L154),
  [stripe-webhook/index.ts:216](../../../supabase/functions/stripe-webhook/index.ts#L216),
  [verify-payment/index.ts:149](../../../supabase/functions/verify-payment/index.ts#L149))
- Wallet credit: `netAmount = paidAmount - platformFee` and credits the shop wallet
  ([paystack-webhook/index.ts:324-325](../../../supabase/functions/paystack-webhook/index.ts#L324-L325)).

The discount reduces `totalAmount`. The client recomputes platform_fee
against the new total when applying the discount. **The webhook sees the
recomputed platform_fee in `pending_payments.booking_data`** and stores it
as-is. **No webhook-side recomputation needed if the client recomputes
correctly.** The validate RPC returns `new_total` and the client passes
`new_total * config.platformFeeFraction` as the new platform_fee — this is
the same arithmetic the client does today, just on the discounted total.

**Verify-before-plan:** does `validate_and_apply_promo` need to return
`new_platform_fee` and `new_deposit` separately, or does the client compute
them from `new_total`? Recommend the latter — keeps the RPC focused on
discount math, and the client already knows the platform_fee fraction from
`paymentConfigProvider`.

### 3. Webhook integration point: `pending_payments.booking_data`

`processPayment` builds a `requestBody` JSONB blob
([payment_controller.dart:123-139](../../../lib/payment/presentation/controllers/payment_controller.dart#L123-L139))
sent to `create-booking`. `create-booking` stores it verbatim as
`pending_payments.booking_data`
([create-booking/index.ts:474](../../../supabase/functions/create-booking/index.ts#L474):
`booking_data: body`). All three webhooks then read it
([paystack:128](../../../supabase/functions/paystack-webhook/index.ts#L128),
[stripe:188](../../../supabase/functions/stripe-webhook/index.ts#L188),
[verify-payment:128](../../../supabase/functions/verify-payment/index.ts#L128)).

**Phase 13 wire-up:**
1. Add `promoCodeId: String?` to the `processPayment` signature
   ([payment_controller.dart:90-103](../../../lib/payment/presentation/controllers/payment_controller.dart#L90-L103)).
2. Add `'promoCodeId': promoCodeId` to `requestBody`
   ([payment_controller.dart:123](../../../lib/payment/presentation/controllers/payment_controller.dart#L123)).
3. In each webhook, after the booking insert succeeds, read
   `bookingData.promoCodeId` and call `record_promo_redemption` if non-null:

```ts
// paystack-webhook/index.ts AFTER line 169 (after "✅ Booking created")
if (bookingData.promoCodeId) {
  const { error: redeemError } = await supabase.rpc('record_promo_redemption', {
    p_promo_code_id: bookingData.promoCodeId,
    p_booking_id: booking.id,
    p_amount_off: bookingData.promoAmountOff,
  });
  if (redeemError) console.error('⚠️ promo redemption failed (non-fatal):', redeemError);
}
```

**Equivalent insertion points:**
- `paystack-webhook/index.ts:170` (after `console.log('✅ Booking created:', booking.id);`)
- `stripe-webhook/index.ts:242` (after `console.log('✅ Booking created from Stripe payment:', booking.id);`)
- `verify-payment/index.ts:189` (after `console.log('✅ Booking created via verify-payment:', newBooking.id);`)

**Stripe / Paystack metadata size limits are irrelevant.** Metadata is not
the carrier. For reference if it ever matters: Stripe allows 50 keys ×
40-char names × 500-char values
([docs.stripe.com/api/metadata](https://docs.stripe.com/api/metadata));
Paystack's `custom_fields` array has no documented per-field cap
([paystack.com/docs/payments/metadata](https://paystack.com/docs/payments/metadata)).
A 36-char UUID fits trivially in either.

**Idempotency:** `record_promo_redemption` is `INSERT ... ON CONFLICT
(promo_code_id, booking_id) DO NOTHING`. The existing
`promotion_redemptions_promo_booking_uniq` constraint
([backfill_tools_screen_drift.sql:67-71](../../../supabase/migrations/20260604000100_backfill_tools_screen_drift.sql#L67-L71))
is the dedupe surface. Race-free across the three webhook callers (a
booking can only reach 'confirmed' via one path; the others see the existing
booking row and skip).

**Reuse `redeem_promotion` or write `record_promo_redemption`?** The
existing RPC's signature is `(p_promotion_id, p_booking_id, p_user_id,
p_discount_amount)`. The Phase 13 path knows `promo_code_id`, `booking_id`,
`amount_off` — the `user_id` field is derivable from
`bookings.user_id`/`guest_profile_id`. **Reuse the existing
`redeem_promotion` RPC.** It does the atomic counter bump + ledger insert
correctly. Phase 13 doesn't need a new `record_promo_redemption` — the
SPEC's name is a renaming of an already-working RPC.

### 4. Loyalty trigger + Phase 12 cancel_and_followup interaction

[20260605130700_wire_terminal_rpcs.sql:109-119](../../../supabase/migrations/20260605130700_wire_terminal_rpcs.sql#L109-L119)
verbatim:

```sql
IF v_booking.status <> 'completed' THEN
  UPDATE bookings SET status = 'completed', updated_at = now()
  WHERE  id = p_booking_id;
  -- audit log insert
  PERFORM public.cancel_and_followup(p_booking_id, 'completed');
END IF;
```

Trigger fires during the UPDATE statement. PERFORM is a later statement.
**The trigger sees `NEW.status = 'completed'` before `cancel_and_followup`
runs.** No race; no ordering question to resolve.

**Trigger naming.** [20260605130600_booking_lifecycle_triggers.sql:51](../../../supabase/migrations/20260605130600_booking_lifecycle_triggers.sql#L51)
uses `trg_bookings_schedule_reminders` with `WHEN (NEW.status = 'confirmed')`.
Phase 13's loyalty trigger uses `WHEN (NEW.status = 'completed')`. They have
non-overlapping WHEN clauses — fires on different transitions. Order doesn't
matter.

Recommend: `trg_bookings_loyalty_visit` for naming consistency. Both
triggers prefixed `trg_bookings_*`.

**Trigger body (Phase 13):**

```sql
CREATE OR REPLACE FUNCTION public.generate_loyalty_code()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_temp
AS $function$
DECLARE
  v_rule        RECORD;
  v_visit_count INTEGER;
  v_existing    UUID;
  v_new_code    TEXT;
BEGIN
  -- Re-mark-as-completed UPDATE: no-op.
  IF TG_OP = 'UPDATE' AND OLD.status = 'completed' THEN
    RETURN NEW;
  END IF;

  -- Look up the shop's loyalty rule.
  SELECT * INTO v_rule
  FROM public.loyalty_rules
  WHERE shop_id = NEW.shop_id AND is_active = TRUE;
  IF NOT FOUND THEN RETURN NEW; END IF;

  -- Count this client's completed bookings at this shop (including this one).
  SELECT COUNT(*) INTO v_visit_count
  FROM public.bookings b
  WHERE b.shop_id = NEW.shop_id
    AND b.status = 'completed'
    AND (
      (NEW.user_id IS NOT NULL AND b.user_id = NEW.user_id) OR
      (NEW.guest_profile_id IS NOT NULL AND b.guest_profile_id = NEW.guest_profile_id)
    );

  -- Threshold check: trigger_visit_count is 1-indexed. v_visit_count includes
  -- this completion; firing exactly when count = trigger_visit_count gives
  -- "on every Nth booking, reward the next one."
  IF v_visit_count % v_rule.trigger_visit_count <> 0 THEN
    RETURN NEW;
  END IF;

  -- Idempotency: skip if an unredeemed loyalty code already exists.
  -- The partial unique index from §1 also enforces this at the storage
  -- layer; this check makes the trigger predictable.
  SELECT id INTO v_existing FROM public.promotions
  WHERE shop_id = NEW.shop_id
    AND source = 'loyalty'
    AND archived_at IS NULL
    AND COALESCE(target_user_id, target_guest_profile_id) =
        COALESCE(NEW.user_id, NEW.guest_profile_id)
    AND NOT EXISTS (
      SELECT 1 FROM public.promotion_redemptions r
      WHERE r.promotion_id = promotions.id
    );
  IF FOUND THEN RETURN NEW; END IF;

  -- Generate the code.
  v_new_code := 'LOYAL' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 6);
  v_new_code := upper(v_new_code);

  INSERT INTO public.promotions (
    shop_id, name, code, discount_type, discount_value,
    valid_from, valid_to, usage_limit, is_active,
    source, target_user_id, target_guest_profile_id, per_client_max
  ) VALUES (
    NEW.shop_id, 'Loyalty reward', v_new_code,
    v_rule.discount_type, v_rule.discount_value,
    now(), now() + INTERVAL '10 years', 1, TRUE,
    'loyalty', NEW.user_id, NEW.guest_profile_id, 1
  );

  RETURN NEW;
END;
$function$;

DROP TRIGGER IF EXISTS trg_bookings_loyalty_visit ON public.bookings;
CREATE TRIGGER trg_bookings_loyalty_visit
  AFTER UPDATE OF status ON public.bookings
  FOR EACH ROW
  WHEN (NEW.status = 'completed')
  EXECUTE FUNCTION public.generate_loyalty_code();
```

**Webhook direct UPDATE path.** No webhook flips `bookings.status` to
'completed'. The 'completed' transitions only happen via
`mark_booking_complete` RPC. Verified by grepping all functions/* for
`'completed'` — every match outside `mark_booking_complete` is either
`pending_payments.status = 'completed'` (a different table) or string
constants in Stripe SDK types. The trigger only sees RPC-driven transitions.

**Loyalty code TTL.** SPEC says loyalty codes have no TTL. Using `valid_to =
now() + INTERVAL '10 years'` is the pragmatic "no expiry" — keeps the
TIMESTAMPTZ NOT NULL constraint happy without a NULL semantics carve-out.
Document.

### 5. `enqueue_booking_reminder` recovery_checkin patch

The Phase 12 helper composes a 2-variable WhatsApp params object for ALL
notification types:
[20260605130400_enqueue_booking_reminder_helper.sql:103-104](../../../supabase/migrations/20260605130400_enqueue_booking_reminder_helper.sql#L103-L104):

```sql
CASE WHEN v_channel = 'whatsapp'
     THEN jsonb_build_object('1', v_client_name, '2', v_shop_name)
     ELSE NULL END,
```

**Phase 13 patch (inline, no separate helper):**

```sql
-- After SELECT v_booking, BEFORE the v_template/v_body composition:
DECLARE
  ...
  v_recovery_code TEXT;
BEGIN
  ...
  -- NEW: generate recovery code for recovery_checkin only.
  IF p_type = 'recovery_checkin' THEN
    v_recovery_code := public.generate_recovery_code(
      v_booking.shop_id,
      v_booking.user_id,
      v_booking.guest_profile_id
    );
  END IF;
  ...
```

And modify the `whatsapp_params` line:

```sql
CASE WHEN v_channel = 'whatsapp'
     THEN CASE WHEN p_type = 'recovery_checkin' AND v_recovery_code IS NOT NULL
               THEN jsonb_build_object('1', v_client_name, '2', v_shop_name, '3', v_recovery_code)
               ELSE jsonb_build_object('1', v_client_name, '2', v_shop_name)
          END
     ELSE NULL END,
```

And the push body for recovery_checkin gets a code suffix:

```sql
WHEN 'recovery_checkin' THEN
  'We noticed your last appointment at ' || v_shop_name || ' didn''t happen. ' ||
  CASE WHEN v_recovery_code IS NOT NULL
       THEN 'Use code ' || v_recovery_code || ' for a discount on your next booking.'
       ELSE 'Book a new time whenever works for you.'
  END
```

**`generate_recovery_code` is a new SECURITY DEFINER helper** (not called
from user code). Signature: `generate_recovery_code(p_shop_id UUID,
p_user_id UUID, p_guest_profile_id UUID) RETURNS TEXT`. Body:

```sql
CREATE OR REPLACE FUNCTION public.generate_recovery_code(
  p_shop_id          UUID,
  p_user_id          UUID,
  p_guest_profile_id UUID
) RETURNS TEXT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp
AS $function$
DECLARE
  v_rule_value INT;
  v_rule_kind  TEXT;
  v_code       TEXT;
BEGIN
  IF p_user_id IS NULL AND p_guest_profile_id IS NULL THEN
    RETURN NULL;
  END IF;
  -- Idempotency: reuse an existing unredeemed recovery code for this client
  -- at this shop if one exists.
  SELECT code INTO v_code FROM public.promotions
  WHERE shop_id = p_shop_id
    AND source = 'recovery'
    AND archived_at IS NULL
    AND valid_to > now()
    AND COALESCE(target_user_id, target_guest_profile_id) =
        COALESCE(p_user_id, p_guest_profile_id)
    AND NOT EXISTS (
      SELECT 1 FROM public.promotion_redemptions r
      WHERE r.promotion_id = promotions.id
    )
  ORDER BY created_at DESC LIMIT 1;
  IF FOUND THEN RETURN v_code; END IF;

  -- Use the shop's loyalty rule as the recovery discount (the SPEC doesn't
  -- separate them; recovery uses the same discount values). If no rule,
  -- default to 10% off.
  SELECT discount_type, discount_value INTO v_rule_kind, v_rule_value
  FROM public.loyalty_rules WHERE shop_id = p_shop_id AND is_active = TRUE;
  IF NOT FOUND THEN
    v_rule_kind := 'percentage'; v_rule_value := 10;
  END IF;

  v_code := 'WELCOME' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 4);
  v_code := upper(v_code);

  INSERT INTO public.promotions (
    shop_id, name, code, discount_type, discount_value,
    valid_from, valid_to, usage_limit, is_active,
    source, target_user_id, target_guest_profile_id, per_client_max
  ) VALUES (
    p_shop_id, 'Recovery offer', v_code,
    v_rule_kind, v_rule_value,
    now(), now() + INTERVAL '30 days', 1, TRUE,
    'recovery', p_user_id, p_guest_profile_id, 1
  );
  RETURN v_code;
END;
$function$;
REVOKE ALL ON FUNCTION public.generate_recovery_code(UUID, UUID, UUID) FROM PUBLIC;
COMMENT ON FUNCTION public.generate_recovery_code(UUID, UUID, UUID) IS
  'Idempotently issues a recovery promo code for a (shop, client) pair. Reuses an existing unredeemed code if one is live. Discount kind/value follow the shop''s active loyalty_rule; falls back to 10% off. Called from enqueue_booking_reminder. SECURITY DEFINER; not exposed to clients. Phase 13.';
```

**Recovery code discount semantics — locked decision needed from user.**
SPEC §Definitions silent code definition implies recovery codes have their
own discount config. The SPEC doesn't surface "recovery rule" as a separate
config. Options:

- **(a) Recovery uses the loyalty rule's discount.** One config; recovery
  and loyalty look the same. Simplest, recommended.
- **(b) Recovery has its own row in a separate `recovery_rules` table.**
  Owner can tune recovery separately ("we win clients back at 20%, reward
  loyalty at 15%"). One more screen, one more table.
- **(c) Hardcode recovery to 10% off.** Worst — no owner agency.

Recommend (a). If the owner wants finer control, Phase 14 adds a
recovery-specific rule.

### 6. WhatsApp template variable count + Meta approval

Meta confirms: WhatsApp Business templates allow **up to 15 variables per
template**, with placeholders numbered `{{1}}..{{15}}` in sequential order
([qiscus.com/whatsapp-template-variables](https://support.qiscus.com/hc/en-us/articles/900001316346)).
The full message body cap is 1024 characters, but per-variable values are
uncapped as long as the total stays under 1024. Three variables is trivial.

**Phase 12 already ships `recovery_checkin_v1` with `{{1}} = client_name,
{{2}} = shop_name`.** Phase 13 needs to add `{{3}} = code`. **Submit a new
`recovery_checkin_v2` template to Meta BEFORE merging the helper change.**
The helper switches `v_template := p_type::text || '_v1'` to `'_v2'` for
recovery_checkin only:

```sql
v_template := CASE p_type
  WHEN 'recovery_checkin' THEN 'recovery_checkin_v2'
  ELSE p_type::text || '_v1'
END;
```

The 6h `WhatsAppTemplateNotFoundError` retry behavior in
`process-scheduled-notifications` covers the Meta approval window. If `v2`
isn't approved when the helper switches, messages defer and retry; no lost
notifications.

**Verify-before-plan:** the existing `recovery_checkin_v1` template body
shape is unknown from the codebase (Meta-side artifact). The planner needs
to check Meta Business Manager for the current `_v1` text before drafting
`_v2`.

### 7. validate_and_apply_promo — query plan and index strategy

The RPC needs three lookup patterns:

1. **Single-row code lookup** — `WHERE shop_id = $1 AND UPPER(code) = $2 AND
   archived_at IS NULL`. The existing `UNIQUE (shop_id, code)` covers exact
   match. **But `code` is stored uppercased today**
   ([promotion_model.dart:97](../../../lib/presentation/features/shops/dashboard/data/models/promotion_model.dart#L97):
   `code: json['code'].toUpperCase()`,
   [promotion_model.dart:115](../../../lib/presentation/features/shops/dashboard/data/models/promotion_model.dart#L115)).
   The server normalizes on insert via the new `create_promo_code` RPC.
   `UPPER(code)` on lookup is redundant but safe. Add a defensive
   functional index for cheap re-runs:

   ```sql
   CREATE UNIQUE INDEX IF NOT EXISTS promotions_code_lookup
     ON public.promotions (shop_id, UPPER(code))
     WHERE archived_at IS NULL;
   ```

   This index ALSO encodes the soft-delete predicate — non-archived rows
   only. The existing `UNIQUE (shop_id, code)` is the hard constraint;
   this index is the fast lookup. **The existing UNIQUE constraint will
   conflict with a re-created code after archive** (you can't re-issue
   `SUMMER10` next year because the archived row still owns the unique
   key). Recommend dropping the existing unconstrained UNIQUE and replacing
   with the partial-unique:

   ```sql
   ALTER TABLE public.promotions DROP CONSTRAINT IF EXISTS promotions_shop_id_code_key;
   ```

   Verify the constraint name first — Postgres auto-generates from
   `UNIQUE (shop_id, code)` typically as `<table>_<col1>_<col2>_key`.

2. **Per-client redemption count** — `SELECT COUNT(*) FROM
   promotion_redemptions WHERE promotion_id = $1 AND user_id = $2` (or
   matching the guest path). Needs index on `(promotion_id, user_id)`. The
   existing `UNIQUE (promotion_id, booking_id)` doesn't help — wrong leading
   columns. Add:

   ```sql
   CREATE INDEX IF NOT EXISTS promotion_redemptions_promo_user
     ON public.promotion_redemptions (promotion_id, user_id)
     WHERE user_id IS NOT NULL;
   ```

   For the guest path, the schema currently has no `guest_profile_id` on
   `promotion_redemptions`. **ADD COLUMN required:**

   ```sql
   ALTER TABLE public.promotion_redemptions
     ADD COLUMN IF NOT EXISTS guest_profile_id UUID
       REFERENCES public.guest_profiles(id) ON DELETE SET NULL;
   CREATE INDEX IF NOT EXISTS promotion_redemptions_promo_guest
     ON public.promotion_redemptions (promotion_id, guest_profile_id)
     WHERE guest_profile_id IS NOT NULL;
   ```

   The `redeem_promotion` RPC signature also needs amending to accept
   guest_profile_id, OR the Phase 13 caller passes it via a new RPC. Recommend
   amending — keeps one writer.

3. **Auto-apply silent code lookup** — `WHERE shop_id = $1 AND source IN
   ('loyalty', 'recovery') AND archived_at IS NULL AND COALESCE(target_user_id,
   target_guest_profile_id) = $2 AND NOT EXISTS (redemption)`. The partial
   unique index from §1 covers the lookup:
   `promotions (shop_id, COALESCE(target_user_id, target_guest_profile_id),
   source) WHERE source IN ('loyalty','recovery') AND archived_at IS NULL`.

**Estimated cost.** For a shop with 1000 active codes and 10k redemptions:
- Lookup #1: one btree probe on `promotions_code_lookup`. <1ms.
- Lookup #2: one btree probe on `promotion_redemptions_promo_user`. <1ms.
- Lookup #3: one btree probe on `promotions_silent_target_uniq`. <1ms.

Well under the SPEC's 100ms budget. **No additional indexes needed beyond
the four added above.**

### 8. Auto-apply tiebreak under highest-discount-wins

SPEC risk register: when both a loyalty AND a recovery code exist for one
client at one shop, return the highest-discount silent code. Tiebreak on
`valid_until` (sooner-expiring wins). Implementation:

```sql
-- Inside validate_and_apply_promo, when p_code IS NULL:
SELECT id, code, discount_type, discount_value, valid_to
INTO v_silent_code
FROM public.promotions
WHERE shop_id = p_shop_id
  AND source IN ('loyalty', 'recovery')
  AND archived_at IS NULL
  AND valid_to > now()
  AND COALESCE(target_user_id, target_guest_profile_id) =
      COALESCE(p_user_id, p_guest_profile_id)
  AND NOT EXISTS (
    SELECT 1 FROM public.promotion_redemptions r
    WHERE r.promotion_id = promotions.id
  )
ORDER BY
  -- Highest-discount-wins. For percent vs fixed, compute the dollar value
  -- against p_booking_total and compare.
  CASE WHEN discount_type = 'percentage'
       THEN LEAST(p_booking_total * discount_value / 100, p_booking_total)
       WHEN discount_type = 'fixed'
       THEN LEAST(discount_value, p_booking_total)
       ELSE 0
  END DESC,
  valid_to ASC  -- tiebreak: sooner-expiring wins
LIMIT 1;
```

**Note:** the `free_addon` discount_type from the existing schema is
ignored — Phase 13 doesn't use it. The auto-apply path explicitly rejects
free_addon by returning `null` in the CASE.

### 9. `loyalty_rules` schema

SPEC says: `shop_id`, `trigger_visit_count`, `discount_kind`, `discount_value`,
`is_active`. Plus the SPEC's "one active rule per shop" constraint.

```sql
CREATE TABLE IF NOT EXISTS public.loyalty_rules (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id             UUID NOT NULL REFERENCES public.shops(id) ON DELETE CASCADE,
  trigger_visit_count INT NOT NULL CHECK (trigger_visit_count BETWEEN 2 AND 50),
  discount_type       TEXT NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
  discount_value      NUMERIC NOT NULL CHECK (discount_value > 0),
  is_active           BOOLEAN NOT NULL DEFAULT TRUE,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS loyalty_rules_one_active_per_shop
  ON public.loyalty_rules (shop_id) WHERE is_active = TRUE;
ALTER TABLE public.loyalty_rules ENABLE ROW LEVEL SECURITY;
CREATE POLICY loyalty_rules_owner_all ON public.loyalty_rules
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.shops s
                 WHERE s.id = loyalty_rules.shop_id AND s.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.shops s
                      WHERE s.id = loyalty_rules.shop_id AND s.user_id = auth.uid()));
```

**No `loyalty_code_validity_days` column.** The SPEC says loyalty codes
have no TTL. The 10-year `valid_to` from §4 is the implementation. If the
owner wants a TTL, that's Phase 14 — adds one column without DDL pain.

**`discount_type` alignment with `promotions.discount_type`.** Both tables
use the string enum `'percentage' | 'fixed'`. Match. The Dart `DiscountType`
enum is shared.

### 10. Code text validation

SPEC says `[A-Z0-9]{3,20}`, no hyphens, no underscores. Fresha confirms
the same shape ([fresha.com/help-center](https://www.fresha.com/help-center/knowledge-base/marketing/143-create-and-manage-promotions)):
max 20 chars, capital letters and numbers, no separators. Examples Fresha
suggests: `XMASCUT22`, `BESTBEARD`. Industry norm.

**Hyphens and underscores look amateurish to owners migrating from
competitor products** — none of the four (Fresha, Booksy, Vagaro, Square)
allow them. Stay strict.

**Server-side enforcement** in `create_promo_code` RPC:

```sql
-- After authz:
IF p_code !~ '^[A-Z0-9]{3,20}$' THEN
  RAISE EXCEPTION 'invalid_code_format'
    USING ERRCODE = '22023', HINT = 'CODE_MUST_BE_UPPERCASE_ALPHANUMERIC_3_TO_20';
END IF;
```

Normalization is `upper(trim(p_code))` BEFORE the regex check, so the owner
can type `summer10` and the server stores `SUMMER10`. Match the existing
`promotion_model.dart:97` client-side uppercase.

### 11. `target_*` semantics for system codes — guest vs registered

The bookings table enforces exactly-one-of `(user_id, guest_profile_id)`
([20260528120000_link_booking_guest_support.sql:66-71](../../../supabase/migrations/20260528120000_link_booking_guest_support.sql#L66-L71)).
Phase 13's silent codes carry the same constraint:

```sql
-- Add to the ALTER TABLE in §1:
ALTER TABLE public.promotions ADD CONSTRAINT promotions_target_xor_check
  CHECK (
    source = 'owner_defined'
    OR (
      source IN ('loyalty', 'recovery')
      AND ((target_user_id IS NOT NULL) <> (target_guest_profile_id IS NOT NULL))
    )
  );
```

**For owner-defined codes, both target_* are NULL.** For loyalty/recovery,
exactly one is set. The auto-apply query uses
`COALESCE(target_user_id, target_guest_profile_id) = COALESCE(p_user_id,
p_guest_profile_id)` to match either identity transparently.

**A registered user who later books as a guest (different phone, different
identity) does NOT inherit their registered loyalty code.** Locked
by the identity split. Acceptable.

### 12. Checkout screen state for which code applied

The `validate_and_apply_promo` RPC returns `{ promo_code_id, code,
amount_off, new_total, source }`. The checkout screen tracks:

```dart
class _BookingConfirmationState extends ConsumerState<...> {
  String? _appliedPromoCodeId;     // UUID for the redemption call
  String? _appliedCodeText;        // 'SUMMER10' or null for silent
  double  _amountOff = 0;
  double  _discountedTotal = 0;
  String? _appliedSource;          // 'owner_defined' | 'loyalty' | 'recovery'

  // Line-item display:
  //   owner_defined  → "Code: SUMMER10"  (-GHS 5.00)
  //   loyalty        → "Loyalty reward"  (-GHS 5.00)
  //   recovery       → "Welcome back"    (-GHS 5.00)
}
```

**Auto-apply call on mount** — `validate_and_apply_promo` with `p_code =
null` → returns the silent code if any. The screen treats source=loyalty /
recovery as system-applied; the TextField is empty; the line-item shows
"Loyalty reward" or "Welcome back" without the code text. **No code text
surfaced to the client for silent codes** — locked silent.

**Manual-entry call on Apply tap** — `validate_and_apply_promo` with `p_code
= textController.text` → returns the owner_defined code if valid.

**Replacement semantics.** If a silent code is auto-applied and the client
THEN enters a manual code that's also valid:
- Manual code wins (the client's explicit intent).
- The silent code's `promo_code_id` stays unredeemed for the next booking.
- UI swaps the line-item from "Loyalty reward" → "Code: <X>".

This is a UX detail; document and test.

### 13. Discount precision and where math lives

`validate_and_apply_promo` returns `amount_off` and `new_total` as
authoritative server-computed NUMERIC values. The client treats them as
opaque; never recomputes. This matches the existing pattern in
`payment_controller.dart`:`processPayment` takes `totalAmount`,
`depositAmount`, `platformFee` as explicit doubles, sends them through to
the server. The server doesn't recompute either; the webhook stores what
came in. **Source of truth: validate RPC. Client is a passive renderer.**

**The only client recomputation** is `platformFee = new_total *
config.platformFeeFraction`. This is unchanged behavior — the client
already does this against the pre-discount total. With Phase 13, the
multiplier input changes to `new_total`.

### 14. Discount kind storage: one column vs split

SPEC asks: should `discount_value` for percent and fixed share one INTEGER
column, or split into `discount_percent` / `discount_amount_minor`?

Existing schema stores both in one `discount_value NUMERIC` column. The
client-side `Promotion` model preserves it
([promotion_model.dart:51](../../../lib/presentation/features/shops/dashboard/data/models/promotion_model.dart#L51)).
The interpretation is driven by `discount_type`.

**Recommend: keep one column.** Splitting introduces a nullable-coupled
pair that has to be CHECK-constrained ("exactly one of X or Y is set
depending on Z"). Phase 13 inherits a working pattern; don't refactor.

**Currency-minor-units note.** Existing storage is `NUMERIC` (decimal
currency), not minor units (integer cents). The SPEC's mention of
"currency-minor-units" is incorrect for this codebase. Match existing
semantics: NUMERIC, two decimal places, currency-aligned. `total_amount` is
`NUMERIC(12,2)`. `discount_value` for `fixed` would be `12.50` not `1250`.

### 15. Owner-facing Promotions screen — extend vs new

[promotions_screen.dart](../../../lib/presentation/features/shops/dashboard/presentation/screens/promotions_screen.dart)
exists today. List + create + edit + delete. Wired through Tools tab.
**Phase 13 extends this screen** with:

- New form fields in `CreatePromotionScreen`: `per_client_max`,
  `min_booking_amount`, service multi-select for `service_restriction`.
- Filter on list: hide `source IN ('loyalty', 'recovery')` rows by default
  (silent — owner sees totals but not individual codes). Optional debug
  toggle.
- New stats: "Total loyalty rewards issued: N" and "Total $ discounted: X"
  computed by the existing `getPromotionStats` repository method, extended
  to break out by `source`.

**New loyalty rule screen** is genuinely new — `LoyaltyRuleScreen` with one
form: visit count, discount type, discount value, is_active toggle. Single
save button (sticky-note convention; no autosave). Single RPC call:
`upsert_loyalty_rule`. The Tools screen gets a new card.

**Existing `PromotionsRepository` extension** — add `getLoyaltyRule(shopId)`
and `upsertLoyaltyRule(...)`. Add `validateAndApplyPromo(...)` for the
checkout path. HINT-based exception mapping mirrors the existing
`incrementUsage` pattern at
[promotions_repository.dart:130-148](../../../lib/presentation/features/shops/dashboard/data/repositories/promotions_repository.dart#L130-L148).

### 16. Competitor survey — table-stakes feature set

| Competitor | Code format       | Validity window | Per-client cap | Service restriction | Auto-apply loyalty | Notes |
|------------|-------------------|-----------------|----------------|---------------------|--------------------|-------|
| Fresha     | `[A-Z0-9]{3,20}` (max 20) `[VERIFIED]` | Date range | Configurable | Yes (per-service or per-category) | Yes ("Smart Pricing") | Industry default. `[CITED]` |
| Booksy     | `[A-Z0-9]+` (no published cap) | Date range | Configurable | Yes (Smart Marketing) | Yes ("Loyalty") | `[CITED]` |
| Vagaro     | `[A-Z0-9]+` (alpha+num) | Date range | Configurable | Yes | Yes (auto-rewards) | `[CITED]` |
| Square Appointments | `[A-Z0-9]+` (max 25) | Date range | Configurable | Limited (whole-booking only) | Yes (Loyalty Program) | `[CITED]` |

Sources:
- Fresha: [How to manage promotions](https://www.fresha.com/help-center/knowledge-base/marketing/143-create-and-manage-promotions) `[CITED]`
- Booksy Smart Marketing: [booksy.com](https://booksy.com/biz/smart-marketing) `[CITED]` (verified Phase 12)
- Vagaro automated marketing: [vagaro.com](https://www.vagaro.com/pro/features/automated-marketing) `[CITED]`

**Table-stakes for marketplace parity:**
1. ✓ Code text (alphanumeric, max 20)
2. ✓ Validity window
3. ✓ Per-client cap
4. ✓ Service restriction
5. ✓ Auto-apply silent loyalty
6. ✗ Per-day-of-week activation (locked out — Phase 14+)
7. ✗ Referral codes (locked out — Phase 14+)
8. ✗ Tiered loyalty (locked out)

Phase 13's scope hits 1-5. Sufficient for marketplace parity.

### 17. Client-side exception mapping — extend `PromotionException`

Existing hierarchy at
[promotion_exceptions.dart](../../../lib/presentation/features/shops/dashboard/data/exceptions/promotion_exceptions.dart):

```dart
class PromotionException implements Exception { ... }
class DuplicateCodeException extends PromotionException { ... }
class PromotionNotFoundException extends PromotionException { ... }
class PromotionLimitReachedException extends PromotionException { ... }
class InvalidDiscountAmountException extends PromotionException { ... }
```

**Phase 13 adds** (in the same file, NOT a separate `promo_exceptions.dart`
as the SPEC suggested):

```dart
class PromoExpiredException extends PromotionException { ... }              // code: PROMO_EXPIRED
class PromoMinAmountNotMetException extends PromotionException { ... }      // code: PROMO_MIN_AMOUNT
class PromoServiceNotEligibleException extends PromotionException { ... }   // code: PROMO_SERVICE_RESTRICTION
class PromoPerClientMaxException extends PromotionException { ... }         // code: PROMO_PER_CLIENT_MAX
class PromoWrongClientException extends PromotionException { ... }          // code: PROMO_WRONG_CLIENT
class LoyaltyRuleSaveFailedException extends PromotionException { ... }     // code: LOYALTY_SAVE_FAILED
```

The repository's `_classifyPromoValidateError` switch reads
`PostgrestException.code` (`42501`, `P0002`, `22023`) and
`PostgrestException.hint`. HINT codes the RPC raises:
- `CODE_NOT_FOUND` → PromotionNotFoundException
- `CODE_EXPIRED` → PromoExpiredException
- `CODE_LIMIT_REACHED` → PromotionLimitReachedException
- `CODE_PER_CLIENT_MAX` → PromoPerClientMaxException
- `CODE_MIN_AMOUNT_NOT_MET` → PromoMinAmountNotMetException
- `CODE_SERVICE_NOT_ELIGIBLE` → PromoServiceNotEligibleException
- `CODE_WRONG_CLIENT` → PromoWrongClientException

**No string matching on `e.message` or `e.toString()`.** Locked by Phase 11.

### 18. Mandatory hardening template parity

Every Phase 13 RPC follows the Phase 11 template
([20260603001500_harden_dashboard_rpcs.sql](../../../supabase/migrations/20260603001500_harden_dashboard_rpcs.sql)):

1. `LANGUAGE plpgsql SECURITY DEFINER SET search_path = public`.
2. **Authz FIRST** — before payload validation: `IF NOT EXISTS (SELECT 1
   FROM shops WHERE id = p_shop_id AND user_id = auth.uid()) THEN RAISE
   EXCEPTION 'not_found' USING ERRCODE = '42501'; END IF;`. The existing
   `redeem_promotion` ([20260604000400:50-60](../../../supabase/migrations/20260604000400_redeem_promotion.sql#L50-L60))
   is the canonical pattern.
3. NULL shape validation can precede authz (it has no side effect and
   prevents NULLs from masquerading as authz failures) — see
   [redeem_promotion:42-48](../../../supabase/migrations/20260604000400_redeem_promotion.sql#L42-L48)
   for the exact comment.
4. Payload validation AFTER authz with HINT codes:
   `RAISE EXCEPTION 'invalid_input' USING ERRCODE = '22023', HINT =
   'CODE_MIN_AMOUNT_NOT_MET';`
5. `REVOKE ALL ON FUNCTION ... FROM PUBLIC; GRANT EXECUTE ... TO
   authenticated;` for owner-callable RPCs. **SECURITY DEFINER trigger
   functions and helpers (e.g. `generate_loyalty_code`,
   `generate_recovery_code`) are NOT granted to authenticated.**
6. `COMMENT ON FUNCTION ... IS '...';` with Big-O.

The `validate_and_apply_promo` RPC is GRANTed to authenticated (clients
call it from checkout). Authz inside is the per-client check — any
authenticated user can call it for any shop they're booking from. The RPC
returns ONLY codes scoped to `p_shop_id`; it does NOT enumerate codes from
other shops.

`record_promo_redemption` (i.e. the existing `redeem_promotion`) is GRANTed
to authenticated today
([20260604000400:113](../../../supabase/migrations/20260604000400_redeem_promotion.sql#L113)).
**Phase 13 should REVOKE this grant** — the webhook calls it with
service_role, and a malicious authenticated client could call it directly
to fabricate redemptions against their own bookings. Verify the change
doesn't break the existing dashboard flow (search for direct
`redeem_promotion` callers in Dart code):

```bash
grep -rn "redeem_promotion" lib/
```

Returns: only `promotions_repository.dart:122` calls it, in the
`incrementUsage` method. That method is called from… nothing currently
(checked). It's dead code per the Phase 10.5 cleanup that moved the actual
redemption to the booking path. Safe to revoke.

### 19. Validation Architecture (nyquist_validation enabled)

**Test Framework**

| Property | Value |
|----------|-------|
| Framework | Flutter `flutter_test` (workspace) + `mocktail` (already in pubspec) |
| Config | `analysis_options.yaml` + per-test imports |
| Quick run | `flutter test test/dashboard/promo_validate_test.dart -p chrome --no-coverage` |
| Full suite | `flutter test` |
| SQL tests | `supabase/tests/phase13_smoke.sql` (manual psql per Phase 10/11/12 precedent — no pgTAP runner exists) |

**Phase Requirements → Test Map** (SPEC success criteria 1-9)

| SC | Behavior | Test type | Command | Exists? |
|----|----------|-----------|---------|---------|
| 1 | Owner creates SUMMER10; other shop owner can't see it | RLS smoke | `psql -f supabase/tests/phase13_smoke.sql` | ❌ Wave 0 |
| 2 | Client enters SUMMER10; total updates; payment proceeds | Dart widget test | `flutter test test/booking/booking_confirmation_promo_test.dart` | ❌ Wave 0 |
| 3 | Per-client cap rejection | Repository unit + smoke | `flutter test test/dashboard/promo_validate_test.dart` | ❌ Wave 0 |
| 4 | 6 completed bookings → loyalty code appears | SQL smoke | `phase13_smoke.sql:loyalty_threshold` | ❌ Wave 0 |
| 5 | 7th booking auto-applies the loyalty code | Dart widget | `booking_confirmation_silent_apply_test.dart` | ❌ Wave 0 |
| 6 | Cancelled booking → recovery_checkin with code | SQL smoke | `phase13_smoke.sql:recovery_code_in_reminder` | ❌ Wave 0 |
| 7 | Expired / non-existent / service-restricted rejections | Repository unit | `promo_validate_test.dart` | ❌ Wave 0 |
| 8 | Idempotent validate | SQL smoke | `phase13_smoke.sql:validate_idempotency` | ❌ Wave 0 |
| 9 | Idempotent record_promo_redemption | SQL smoke | `phase13_smoke.sql:redemption_idempotency` | ❌ Wave 0 |

**Sampling rate**
- Per task commit: targeted file (`flutter test test/dashboard/promo_validate_test.dart`)
- Per wave merge: `flutter test test/dashboard/ test/booking/`
- Phase gate: full `flutter test` green + `psql -f supabase/tests/phase13_smoke.sql` clean exit

**Wave 0 gaps**
- [ ] `supabase/tests/phase13_smoke.sql` — covers SC 1, 4, 6, 8, 9
- [ ] `test/dashboard/promo_validate_test.dart` — covers SC 3, 7
- [ ] `test/booking/booking_confirmation_promo_test.dart` — covers SC 2, 5
- [ ] `test/dashboard/loyalty_rule_test.dart` — covers loyalty rule CRUD

### 20. Security Domain (security_enforcement enabled)

| ASVS | Applies | Standard Control |
|------|---------|------------------|
| V2 Authentication | yes | Supabase `auth.uid()` in every RPC |
| V3 Session | n/a | Supabase JWT handles |
| V4 Access Control | yes | RLS + per-RPC `EXISTS (shops WHERE user_id = auth.uid())` gate |
| V5 Input Validation | yes | regex `^[A-Z0-9]{3,20}$` server-side; HINT-based rejection |
| V6 Cryptography | n/a | code text is not a secret; `gen_random_uuid()` for entropy |
| V7 Error Handling | yes | sanitized exceptions ('not_found' not 'shop X not found') |
| V8 Data Protection | yes | client identity (target_*) never echoed in WhatsApp params; only code text |
| V9 Communications | n/a | Supabase HTTPS |

**Known threat patterns for Phase 13:**

| Pattern | STRIDE | Mitigation |
|---------|--------|------------|
| Code enumeration via timing (does SUMMER10 exist?) | Information disclosure | Uniform `RAISE EXCEPTION 'not_found'` for both "code doesn't exist" and "code expired"; no distinguishable error |
| Owner fabricates a `source='loyalty'` row for arbitrary user | Tampering/Privilege escalation | RLS INSERT policy denies non-owner_defined source values |
| Client floods validate RPC to brute-force code text | DoS | Rate limit (`check_rate_limit('validate_promo', 60, 60)` — borrow from existing) |
| Replay of `record_promo_redemption` to over-count usage | Tampering | UNIQUE (promotion_id, booking_id) idempotency |
| Cross-shop redemption (recovery code for shop A applied at shop B) | Tampering | RLS shop_id filter in validate RPC body |
| Loyalty trigger fires N times on retry storm | Tampering | NOT EXISTS guard on unredeemed loyalty code; partial unique index |

## Open questions for the user (verify before plan)

1. **P0 — Table strategy.** Extend the existing `promotions` /
   `promotion_redemptions` (recommended), or build parallel `promo_codes` /
   `promo_redemptions`? Extension is cheaper, simpler, doesn't break the
   live owner UI. User pick.

2. **P0 — Platform fee recomputation.** Confirm SPEC line 76-77: platform
   fee recomputes against the discounted total (`new_total *
   platformFeeFraction`), so platform earns less when discount applies.
   Alternative: platform fee stays based on pre-discount total
   (`totalPrice * platformFeeFraction`), shop absorbs the discount
   entirely. Both have business semantics. Recommend SPEC default
   (recompute) but confirm.

3. **P0 — Recovery code discount source.** The recovery code uses the
   loyalty rule's discount kind/value (recommend), or has its own config
   (Phase 14 if owner asks for it). User confirms.

4. **P1 — Existing `redeem_promotion` GRANT.** Revoke the
   `GRANT EXECUTE TO authenticated` on `redeem_promotion`
   ([20260604000400:113](../../../supabase/migrations/20260604000400_redeem_promotion.sql#L113))
   in Phase 13? It's dead code from the client side; webhooks use
   service_role. Recommend yes — closes the redemption-fabrication surface.

5. **P1 — Existing `promotions.discount_type='free_addon'`.** The legacy
   `free_addon` value sits in the CHECK constraint. Phase 13 doesn't use
   it; the validate RPC rejects it. Keep the constraint as-is, or DROP the
   `free_addon` allowed value? Recommend keep (zero forward cost, avoids
   a CHECK constraint rewrite).

6. **P1 — WhatsApp `recovery_checkin_v2` template body.** Phase 13 needs
   the planner to draft the v2 template body and submit to Meta BEFORE the
   helper switch. Template approval is asynchronous (typically 24h). The
   plan must include a Wave 0 task: submit `recovery_checkin_v2` to Meta
   Business Manager. User confirms whether they'll do it manually or
   document the body in the PR for someone to action.

7. **P2 — Live-DB column shape verification.** Phase 11 burned a day on
   a column-shape misread (hours migration); Phase 12 had a hotfix. Phase
   13 needs to pre-verify on the live DB:

   ```sql
   -- Confirm promotions.valid_from / valid_to are DATE (not already
   -- TIMESTAMPTZ from a dashboard hand-edit):
   SELECT column_name, data_type FROM information_schema.columns
   WHERE table_name = 'promotions' AND column_name IN ('valid_from', 'valid_to');

   -- Confirm promotion_redemptions has only the documented columns:
   SELECT column_name, data_type FROM information_schema.columns
   WHERE table_name = 'promotion_redemptions' ORDER BY ordinal_position;

   -- Confirm the UNIQUE (shop_id, code) constraint name:
   SELECT conname FROM pg_constraint
   WHERE conrelid = 'public.promotions'::regclass AND contype = 'u';

   -- Confirm whether there's an existing index on promotion_redemptions
   -- besides the PK and the (promotion_id, booking_id) UNIQUE:
   SELECT indexname, indexdef FROM pg_indexes
   WHERE tablename = 'promotion_redemptions';
   ```

   The planner runs these once during plan-check, locks any drift into
   the migration shape, and proceeds.

## RESEARCH COMPLETE

Sources:
- [Meta WhatsApp template variable limit](https://support.qiscus.com/hc/en-us/articles/900001316346-What-is-the-maximum-number-of-variables-that-can-be-submitted-on-the-HSM-and-WhatsApp-Broadcast-Template-Message)
- [Stripe metadata limits](https://docs.stripe.com/api/metadata)
- [Paystack metadata documentation](https://paystack.com/docs/payments/metadata/)
- [Fresha promo code format guide](https://www.fresha.com/help-center/knowledge-base/marketing/143-create-and-manage-promotions)
- [PostgreSQL trigger execution order](https://www.postgresql.org/docs/current/sql-createtrigger.html)
