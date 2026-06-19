# Producer Onboarding + Phone Verification — Design

**Date:** 2026-06-19
**Status:** Approved (ready for implementation plan)

## Goal

Gate the three "become a producer" flows behind a one-time Twilio phone
verification, fix the broken role-based card rendering in
`edit_profile_screen`, and add a seller-onboarding path (shop overview +
business document) so any account can sell a product.

The three gated features:

| Feature | Role context | Route |
|---|---|---|
| Create freelancer profile | `worker` selected | `/freelancerCreationDashboard` |
| Create shop | `shop` selected | `/myShopsScreen` |
| Sell a product | any role | `/sellerOnboarding` (new) |

## Key decisions

- **One verified phone per account**, stored on `profiles`. Verifying once
  permanently unlocks all three features ("verify once, unlock all").
- **Twilio Verify API** (not manual OTP) — Twilio owns code generation,
  expiry, rate limiting, brute-force protection.
- **Phone verification status is written only by the edge function**
  (service role), never client-writable, so the gate cannot be spoofed.
- **Sell a product auto-creates a lightweight seller-shop** on first use,
  reusing the existing product/`shopId` infrastructure.
- **Reuse universal widgets:** `AddContactModal` (phone entry) and
  `ManageDocumentsScreen`'s document upload (`documentsProvider` +
  `DocumentPickerSheet`).

---

## Section 1 — Data layer (Supabase)

### Migration: `profiles`

Add columns:
- `phone_e164 text` — nullable, verified number in E.164 format.
- `phone_verified_at timestamptz` — nullable; non-null ⇒ verified.

**Security:** `phone_e164` and `phone_verified_at` must be written **only by
the edge function via service role**, never by the client. Enforce with a
trigger (or column guard) that rejects client updates to these columns. RLS
otherwise allows users to read/update their own profile row.

### Edge functions (mirror `whatsapp-send` structure)

Backed by **Twilio Verify**. Shared client at `_shared/twilio_client.ts`
(env: `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`,
`TWILIO_VERIFY_SERVICE_SID`).

**`phone-verify-start`**
- Auth: user JWT (not service role — the caller is the end user).
- Input: `{ phone_e164 }`.
- Validates E.164 shape server-side.
- Calls Twilio Verify `verifications.create({ to, channel: "sms" })`.
- Returns `{ success }`. Rate limiting handled by Twilio.

**`phone-verify-check`**
- Auth: user JWT.
- Input: `{ phone_e164, code }`.
- Calls Twilio Verify `verificationChecks.create({ to, code })`.
- On `status === "approved"`: write `phone_e164` + `phone_verified_at =
  now()` to the **authenticated caller's** profile row via service role
  (derive user id from the JWT, never trust a client-supplied id).
- Returns `{ verified: bool }`.

---

## Section 2 — Flutter: verification gate

### `Profile` model

Add `phoneE164` (`String?`) and `phoneVerifiedAt` (`DateTime?`); parse from
`phone_e164` / `phone_verified_at`. Expose:

```dart
bool get isPhoneVerified => phoneVerifiedAt != null;
```

### `phone_verification_provider.dart` (new)

- `startPhoneVerification(String phoneE164)` → calls `phone-verify-start`.
- `checkPhoneVerification(String phoneE164, String code)` → calls
  `phone-verify-check`; on success invalidates `currentUserProfileProvider`.
- Exposes loading / error state.

### `AddContactModal` adaptation

Add an optional `verifyMode` flag (default `false` — existing shop/freelancer
contact call sites are untouched). When `verifyMode == true`:

- Lock the type selector to **phone only** (hide email/website chips and the
  "primary" checkbox).
- After a valid E.164 is entered, "Send code" → `startPhoneVerification`,
  then reveal a 6-digit code field.
- "Verify" → `checkPhoneVerification`; on success `Navigator.pop(context,
  true)`.

### `ensurePhoneVerified(context, ref)` helper (the gate)

Returns `true` if `profile.isPhoneVerified`; otherwise opens the verify
modal and returns its result (`true` on successful verification, `false`/null
if dismissed). Every gated card calls this before navigating.

---

## Section 3 — `edit_profile_screen` rewrite

Replace the broken ternary (current lines 359–429, which do not compile) with
a `_buildProducerCards(loc)` method returning a `Column`:

- `_selectedRole == AccountType.worker` → **"Create freelancer profile"**
  card → `_gatedPush(() => context.push('/freelancerCreationDashboard',
  extra: {userId, mode: FreelancerMode.create}))`.
- `_selectedRole == AccountType.shop` → **"Create shop"** card →
  `_gatedPush(() => context.push('/myShopsScreen'))`.
- **always (any role)** → **"Sell a product"** card → `_gatedPush(() =>
  context.push('/sellerOnboarding'))`.

Where:

```dart
Future<void> _gatedPush(VoidCallback action) async {
  if (await ensurePhoneVerified(context, ref)) action();
}
```

**Fixes alongside the rewrite:**
- Correct the swapped labels/links (worker card linked to shop, shop card
  linked to freelancer).
- Point the "Sell a product" card to the new seller route (was wrongly
  pointing at `freelancerCreationDashboard`).
- Fix copy typos ("neauty" → "beauty") and the duplicate `Icons.person`.

**Not touched:** the role selector, text fields, avatar logic — only the
producer-cards block changes.

---

## Section 4 — Seller onboarding (product selling)

`ProductFormScreen` requires a `shopId`; a plain client has none. First-time
selling auto-creates a lightweight seller-shop.

### `/sellerOnboarding` → `SellerOnboardingScreen` (new)

Flow (phone already verified by the gate before this screen opens):

1. **Existing-shop check** — if the user already owns a shop, skip
   onboarding and push straight to that shop's `/productForm`. No duplicate
   shop is created.
2. **If none**, show one form screen:
   - **Shop overview** — `AppTextFormField` (name + short overview text),
     required.
   - **Business document** — reuse `DocumentPickerSheet` + `documentsProvider`
     to upload a business registration / any document; at least one required.
3. **"Continue"** → create a minimal shop record (overview → name/bio + the
   uploaded document, owner = current user), obtain its `shopId`, then
   `context.push('/productForm', extra: {shopId, mode: FormMode.create})`.

**Reuse, not rebuild:** document upload reuses `documentsProvider` +
`DocumentPickerSheet`; product creation reuses `ProductFormScreen` unchanged.
The only new pieces are the thin onboarding screen and the
create-minimal-seller-shop call.

**Open detail (resolved during planning):** the exact minimal-shop creation
call — whether `ShopCreationNotifier.submit` accepts a reduced draft or a
dedicated lightweight repository method is cleaner.

---

## Algorithm Quality Review Checklist (applied throughout)

- **Input validation:** E.164 validated client-side (existing
  `PhoneFieldWidget`/`ValidationUtils`) and re-validated server-side in
  `phone-verify-start`. Code length/format checked before calling Twilio.
- **Idempotency:** Re-verifying an already-verified phone is safe (overwrites
  `phone_verified_at`). Existing-shop check prevents duplicate seller-shops.
- **Error/edge handling:** Twilio failures, expired/incorrect codes, network
  errors surface as inline errors in the modal; the gate returns `false` and
  no navigation occurs. Dismissing the modal aborts cleanly.
- **Security boundaries:** Verification columns are service-role-write-only;
  the edge function derives the user id from the JWT and never trusts a
  client-supplied id; gate cannot be bypassed by editing the profile row.
- **No regressions:** `AddContactModal` change is additive (opt-in flag);
  existing two call sites unchanged. `ProductFormScreen` unchanged. Only the
  producer-cards block of `edit_profile_screen` is rewritten.

## Out of scope (YAGNI)

- Changing email/website contact behaviour.
- Re-verification expiry / phone change UX (one verification is permanent for
  now).
- SMS provider fallback beyond Twilio.
