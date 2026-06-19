# Producer Onboarding + Phone Verification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Gate the three "become a producer" flows (create freelancer profile, create shop, sell a product) behind a one-time Twilio phone verification, fix the broken role-based card rendering in `edit_profile_screen`, and add a seller-onboarding path that lets any account sell a product.

**Architecture:** Phone verification status lives on the `profiles` table (`phone_e164`, `phone_verified_at`), written only by a Twilio-Verify-backed edge function via service role. Flutter reads `Profile.isPhoneVerified` and gates navigation through an `ensurePhoneVerified()` helper that opens a phone-only variant of the existing `AddContactModal`. Selling a product auto-creates a minimal seller-shop (overview + business document) reusing the existing shop-creation repository and `ProductFormScreen`.

**Tech Stack:** Flutter, Riverpod, GoRouter, Supabase (Postgres + Edge Functions/Deno), Twilio Verify.

## Global Constraints

- State management: Riverpod providers only. Repository pattern for data.
- Material Design 3 with project design tokens (`Spacing`, `theme.colorScheme`).
- Edge functions mirror the structure of `supabase/functions/whatsapp-send/index.ts` and share helpers via `supabase/functions/_shared/`.
- Verification columns (`phone_e164`, `phone_verified_at`) are **service-role-write-only** — never client-writable.
- Phone numbers are E.164. Client validation via existing `PhoneFieldWidget` / `ValidationUtils`; server re-validates.
- Edge functions are invoked from Flutter via `supabase.functions.invoke(name, body: {...})` (see `lib/payment/data/repositories/payment_settings_repository.dart:89`).
- Do not modify the existing two `AddContactModal` call sites' behaviour — the verify path is opt-in via a new flag.
- Copy fix: "neauty" → "beauty".

---

## File Structure

**Backend (Supabase):**
- `supabase/migrations/20260619120000_phone_verification.sql` — add columns + guard trigger.
- `supabase/functions/_shared/twilio_client.ts` — Twilio Verify wrapper.
- `supabase/functions/phone-verify-start/index.ts` — start verification.
- `supabase/functions/phone-verify-check/index.ts` — check code + persist.

**Flutter:**
- `lib/presentation/features/profile/models/profile.dart` — add fields (Modify).
- `lib/presentation/features/profile/repositories/supabase_profile_repository.dart` — select new columns (Modify, if explicit column list).
- `lib/presentation/features/auth/providers/phone_verification_provider.dart` — provider (Create).
- `lib/presentation/features/auth/widgets/ensure_phone_verified.dart` — gate helper (Create).
- `lib/presentation/features/shops/creation/presentation/widgets/add_contact_modal.dart` — add `verifyMode` (Modify).
- `lib/presentation/features/profile/widgets/edit_profile_screen.dart` — rewrite producer cards (Modify).
- `lib/presentation/features/products/presentation/screens/seller_onboarding_screen.dart` — seller onboarding (Create).
- `lib/app/routing/app_router.dart` — add `/sellerOnboarding` route (Modify).

---

## Task 1: Database migration — phone verification columns + write guard

**Files:**
- Create: `supabase/migrations/20260619120000_phone_verification.sql`

**Interfaces:**
- Produces: `profiles.phone_e164 text`, `profiles.phone_verified_at timestamptz`; trigger `guard_phone_verification_columns` that raises if a non-service-role session changes either column.

- [ ] **Step 1: Write the migration**

```sql
-- supabase/migrations/20260619120000_phone_verification.sql
-- Adds one-time phone verification fields to profiles. These columns gate the
-- freelancer / shop / product-seller flows and are written ONLY by the
-- phone-verify-check edge function (service role). Client writes are rejected
-- by the guard trigger below so the gate cannot be spoofed.

alter table public.profiles
  add column if not exists phone_e164 text,
  add column if not exists phone_verified_at timestamptz;

create or replace function public.guard_phone_verification_columns()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- auth.role() is 'service_role' for service-role JWTs, 'authenticated' for users.
  if auth.role() <> 'service_role' then
    if new.phone_e164 is distinct from old.phone_e164
       or new.phone_verified_at is distinct from old.phone_verified_at then
      raise exception 'phone verification columns are read-only for clients';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_guard_phone_verification on public.profiles;
create trigger trg_guard_phone_verification
  before update on public.profiles
  for each row
  execute function public.guard_phone_verification_columns();
```

- [ ] **Step 2: Apply locally and verify columns exist**

Run: `supabase db reset` (or `supabase migration up` if preferred for incremental).
Expected: migration applies with no errors; `profiles` now has `phone_e164`, `phone_verified_at`.

- [ ] **Step 3: Verify the guard blocks client writes**

Run (psql against local DB, as a non-service role / authenticated context):
```sql
update public.profiles set phone_verified_at = now() where id = '<any-id>';
```
Expected: ERROR `phone verification columns are read-only for clients`.

- [ ] **Step 4: Commit**

```bash
git add supabase/migrations/20260619120000_phone_verification.sql
git commit -m "feat(db): add phone verification columns + client write guard"
```

---

## Task 2: Shared Twilio Verify client

**Files:**
- Create: `supabase/functions/_shared/twilio_client.ts`

**Interfaces:**
- Produces:
  - `startVerification(phoneE164: string): Promise<{ status: string }>`
  - `checkVerification(phoneE164: string, code: string): Promise<{ status: string }>`
  - `class TwilioConfigError extends Error`
  - Reads env: `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_VERIFY_SERVICE_SID`.

- [ ] **Step 1: Write the client**

```ts
// supabase/functions/_shared/twilio_client.ts
// Thin wrapper over the Twilio Verify v2 REST API. Twilio owns code
// generation, expiry, rate limiting and brute-force protection — we only
// start a verification and check a submitted code.

export class TwilioConfigError extends Error {}

function config() {
  const sid = Deno.env.get("TWILIO_ACCOUNT_SID");
  const token = Deno.env.get("TWILIO_AUTH_TOKEN");
  const verifySid = Deno.env.get("TWILIO_VERIFY_SERVICE_SID");
  if (!sid || !token || !verifySid) {
    throw new TwilioConfigError("Missing Twilio environment variables");
  }
  return { sid, token, verifySid };
}

function authHeader(sid: string, token: string): string {
  return "Basic " + btoa(`${sid}:${token}`);
}

export async function startVerification(
  phoneE164: string,
): Promise<{ status: string }> {
  const { sid, token, verifySid } = config();
  const res = await fetch(
    `https://verify.twilio.com/v2/Services/${verifySid}/Verifications`,
    {
      method: "POST",
      headers: {
        "Authorization": authHeader(sid, token),
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({ To: phoneE164, Channel: "sms" }),
    },
  );
  if (!res.ok) {
    throw new Error(`Twilio start failed: ${res.status} ${await res.text()}`);
  }
  const data = await res.json();
  return { status: data.status };
}

export async function checkVerification(
  phoneE164: string,
  code: string,
): Promise<{ status: string }> {
  const { sid, token, verifySid } = config();
  const res = await fetch(
    `https://verify.twilio.com/v2/Services/${verifySid}/VerificationCheck`,
    {
      method: "POST",
      headers: {
        "Authorization": authHeader(sid, token),
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({ To: phoneE164, Code: code }),
    },
  );
  if (!res.ok) {
    // 404 here means no pending verification (expired / wrong number).
    if (res.status === 404) return { status: "expired" };
    throw new Error(`Twilio check failed: ${res.status} ${await res.text()}`);
  }
  const data = await res.json();
  return { status: data.status }; // "approved" | "pending" | ...
}
```

- [ ] **Step 2: Type-check**

Run: `deno check supabase/functions/_shared/twilio_client.ts`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add supabase/functions/_shared/twilio_client.ts
git commit -m "feat(edge): add shared Twilio Verify client"
```

---

## Task 3: `phone-verify-start` edge function

**Files:**
- Create: `supabase/functions/phone-verify-start/index.ts`

**Interfaces:**
- Consumes: `startVerification` from `_shared/twilio_client.ts`.
- Produces: POST endpoint, user-JWT auth. Body `{ phone_e164: string }`. Returns `{ success: true }` (200) or `{ error }` (4xx/5xx).

- [ ] **Step 1: Write the function**

```ts
// supabase/functions/phone-verify-start/index.ts
// Starts a Twilio Verify SMS verification for the calling user's phone.
// Auth: end-user JWT (the platform verifies the Supabase-signed JWT).
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { startVerification, TwilioConfigError } from "../_shared/twilio_client.ts";

const E164 = /^\+[1-9]\d{6,14}$/;

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

export async function handler(req: Request): Promise<Response> {
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const auth = req.headers.get("Authorization") ?? "";
  if (!auth.startsWith("Bearer ")) return json({ error: "Unauthorized" }, 401);

  let body: { phone_e164?: string };
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }

  const phone = body.phone_e164?.trim() ?? "";
  if (!E164.test(phone)) return json({ error: "Invalid phone number" }, 400);

  try {
    await startVerification(phone);
    return json({ success: true }, 200);
  } catch (e) {
    if (e instanceof TwilioConfigError) return json({ error: "Service unavailable" }, 503);
    return json({ error: "Failed to send code" }, 502);
  }
}

serve(handler);
```

- [ ] **Step 2: Type-check**

Run: `deno check supabase/functions/phone-verify-start/index.ts`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add supabase/functions/phone-verify-start/index.ts
git commit -m "feat(edge): add phone-verify-start function"
```

---

## Task 4: `phone-verify-check` edge function (verify + persist)

**Files:**
- Create: `supabase/functions/phone-verify-check/index.ts`

**Interfaces:**
- Consumes: `checkVerification` from `_shared/twilio_client.ts`.
- Produces: POST endpoint, user-JWT auth. Body `{ phone_e164: string, code: string }`. On Twilio `approved`, writes `phone_e164` + `phone_verified_at = now()` to the **caller's** profile (user id derived from JWT) via service role. Returns `{ verified: bool }`.

- [ ] **Step 1: Write the function**

```ts
// supabase/functions/phone-verify-check/index.ts
// Checks a submitted code against Twilio Verify. On approval, persists the
// verified phone to the CALLER's profile via service role. The user id is
// derived from the JWT — never trusted from the request body.
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { checkVerification, TwilioConfigError } from "../_shared/twilio_client.ts";

const E164 = /^\+[1-9]\d{6,14}$/;

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

export async function handler(req: Request): Promise<Response> {
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const auth = req.headers.get("Authorization") ?? "";
  if (!auth.startsWith("Bearer ")) return json({ error: "Unauthorized" }, 401);
  const userJwt = auth.slice("Bearer ".length);

  const url = Deno.env.get("SUPABASE_URL")!;
  const serviceRole = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  // Resolve the caller's user id from their JWT.
  const userClient = createClient(url, serviceRole, {
    global: { headers: { Authorization: `Bearer ${userJwt}` } },
  });
  const { data: userData, error: userErr } = await userClient.auth.getUser();
  if (userErr || !userData.user) return json({ error: "Unauthorized" }, 401);
  const userId = userData.user.id;

  let body: { phone_e164?: string; code?: string };
  try {
    body = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }
  const phone = body.phone_e164?.trim() ?? "";
  const code = body.code?.trim() ?? "";
  if (!E164.test(phone)) return json({ error: "Invalid phone number" }, 400);
  if (!/^\d{4,10}$/.test(code)) return json({ error: "Invalid code" }, 400);

  let status: string;
  try {
    ({ status } = await checkVerification(phone, code));
  } catch (e) {
    if (e instanceof TwilioConfigError) return json({ error: "Service unavailable" }, 503);
    return json({ error: "Verification failed" }, 502);
  }

  if (status !== "approved") return json({ verified: false }, 200);

  // Persist via service role (bypasses the client write-guard trigger).
  const admin = createClient(url, serviceRole);
  const { error: updErr } = await admin
    .from("profiles")
    .update({ phone_e164: phone, phone_verified_at: new Date().toISOString() })
    .eq("id", userId);
  if (updErr) return json({ error: "Could not save verification" }, 500);

  return json({ verified: true }, 200);
}

serve(handler);
```

- [ ] **Step 2: Type-check**

Run: `deno check supabase/functions/phone-verify-check/index.ts`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add supabase/functions/phone-verify-check/index.ts
git commit -m "feat(edge): add phone-verify-check function"
```

---

## Task 5: `Profile` model — phone verification fields

**Files:**
- Modify: `lib/presentation/features/profile/models/profile.dart`

**Interfaces:**
- Produces: `Profile.phoneE164` (`String?`), `Profile.phoneVerifiedAt` (`DateTime?`), `bool get isPhoneVerified`; both parsed in `fromJson`, emitted in `toJson`, threaded through `copyWith`.

- [ ] **Step 1: Add fields to the class**

In `lib/presentation/features/profile/models/profile.dart`, add to the field list (after `avatarUrl`):

```dart
  final String? phoneE164;
  final DateTime? phoneVerifiedAt;
```

Add to the const constructor parameter list (after `this.avatarUrl,`):

```dart
    this.phoneE164,
    this.phoneVerifiedAt,
```

- [ ] **Step 2: Add the verified getter**

Immediately after the constructor (before the `factory Profile.fromJson`):

```dart
  /// True once the account has completed phone verification.
  bool get isPhoneVerified => phoneVerifiedAt != null;
```

- [ ] **Step 3: Parse in fromJson**

In `fromJson`, after `avatarUrl: json['avatar_url'] as String?,`:

```dart
      phoneE164: json['phone_e164'] as String?,
      phoneVerifiedAt: _parseNullableDate(json['phone_verified_at']),
```

- [ ] **Step 4: Emit in toJson**

In `toJson`, after `if (avatarUrl != null) 'avatar_url': avatarUrl,`:

```dart
      if (phoneE164 != null) 'phone_e164': phoneE164,
      if (phoneVerifiedAt != null)
        'phone_verified_at': phoneVerifiedAt!.toIso8601String(),
```

- [ ] **Step 5: Thread through copyWith**

In `copyWith`, add params after `String? avatarUrl,`:

```dart
    String? phoneE164,
    DateTime? phoneVerifiedAt,
```

And in the returned `Profile(...)`, after `avatarUrl: avatarUrl ?? this.avatarUrl,`:

```dart
      phoneE164: phoneE164 ?? this.phoneE164,
      phoneVerifiedAt: phoneVerifiedAt ?? this.phoneVerifiedAt,
```

- [ ] **Step 6: Verify the repository select includes the new columns**

Check `lib/presentation/features/profile/repositories/supabase_profile_repository.dart` for the profile fetch. If it uses `.select()` (all columns) or `.select('*')`, no change is needed. If it lists explicit columns, add `phone_e164` and `phone_verified_at` to that list.

Run: `grep -n "\.select(" lib/presentation/features/profile/repositories/supabase_profile_repository.dart`
Expected: confirm whether columns are explicit; edit only if so.

- [ ] **Step 7: Analyze**

Run: `flutter analyze lib/presentation/features/profile/models/profile.dart`
Expected: No issues.

- [ ] **Step 8: Commit**

```bash
git add lib/presentation/features/profile/models/profile.dart lib/presentation/features/profile/repositories/supabase_profile_repository.dart
git commit -m "feat(profile): add phone verification fields to Profile model"
```

---

## Task 6: Phone verification provider

**Files:**
- Create: `lib/presentation/features/auth/providers/phone_verification_provider.dart`

**Interfaces:**
- Consumes: `supabaseClientProvider` (`lib/presentation/features/auth/providers/auth_provider.dart:12`), `currentUserProfileProvider`.
- Produces: `phoneVerificationControllerProvider` → `PhoneVerificationController` with:
  - `Future<void> sendCode(String phoneE164)` — throws on failure with a user-message.
  - `Future<bool> verifyCode(String phoneE164, String code)` — returns whether approved; invalidates `currentUserProfileProvider` on success.

- [ ] **Step 1: Write the provider**

```dart
// lib/presentation/features/auth/providers/phone_verification_provider.dart
//
// Drives the Twilio Verify edge functions for one-time phone verification.
// On a successful check, invalidates the profile so isPhoneVerified flips.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/core/providers/profile_providers/profile_provider.dart';

class PhoneVerificationController {
  PhoneVerificationController(this._ref);
  final Ref _ref;

  Future<void> sendCode(String phoneE164) async {
    final client = _ref.read(supabaseClientProvider);
    final res = await client.functions.invoke(
      'phone-verify-start',
      body: {'phone_e164': phoneE164},
    );
    final data = res.data;
    final ok = data is Map && data['success'] == true;
    if (!ok) {
      throw Exception(
        (data is Map ? data['error'] : null)?.toString() ??
            'Could not send code. Please try again.',
      );
    }
  }

  /// Returns true when the code was approved and the profile updated.
  Future<bool> verifyCode(String phoneE164, String code) async {
    final client = _ref.read(supabaseClientProvider);
    final res = await client.functions.invoke(
      'phone-verify-check',
      body: {'phone_e164': phoneE164, 'code': code},
    );
    final data = res.data;
    final verified = data is Map && data['verified'] == true;
    if (verified) {
      _ref.invalidate(currentUserProfileProvider);
    }
    return verified;
  }
}

final phoneVerificationControllerProvider =
    Provider<PhoneVerificationController>(
  (ref) => PhoneVerificationController(ref),
);
```

- [ ] **Step 2: Analyze**

Run: `flutter analyze lib/presentation/features/auth/providers/phone_verification_provider.dart`
Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/features/auth/providers/phone_verification_provider.dart
git commit -m "feat(auth): add phone verification controller provider"
```

---

## Task 7: `AddContactModal` — opt-in verify mode

**Files:**
- Modify: `lib/presentation/features/shops/creation/presentation/widgets/add_contact_modal.dart`

**Interfaces:**
- Consumes: `phoneVerificationControllerProvider`.
- Produces: `AddContactModal(verifyMode: true, ...)` — when set, the modal collects a phone, sends a code, verifies it, and on success pops with `true`. Default (`verifyMode: false`) is the existing behaviour, unchanged.

**Note:** `AddContactModal` is currently a `StatefulWidget`. To read the provider, convert it to `ConsumerStatefulWidget` (import `flutter_riverpod`, change base classes, change `State` → `ConsumerState`). All existing field access stays the same.

- [ ] **Step 1: Add the flag and Riverpod base**

Add import at top:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/auth/providers/phone_verification_provider.dart';
```

Change the widget declaration and add the field:
```dart
class AddContactModal extends ConsumerStatefulWidget {
  final Function(ContactDraft)? onSave;
  final ContactDraft? initialContact;
  final String? shopCountryIsoCode;
  final bool verifyMode;

  const AddContactModal({
    super.key,
    this.onSave,
    this.initialContact,
    this.shopCountryIsoCode,
    this.verifyMode = false,
  });

  @override
  ConsumerState<AddContactModal> createState() => _AddContactModalState();
}

class _AddContactModalState extends ConsumerState<AddContactModal> {
```

(Note: `onSave` becomes nullable since verify mode does not use it. Existing call sites pass it, so they are unaffected.)

- [ ] **Step 2: Add verify-mode state fields**

Inside `_AddContactModalState`, add:
```dart
  bool _codeSent = false;
  bool _busy = false;
  String? _verifyError;
  final _codeController = TextEditingController();
```

In `dispose()`, before `super.dispose();` add:
```dart
    _codeController.dispose();
```

In `initState()`, when `widget.verifyMode` is true, default the selected type to phone:
```dart
    if (widget.verifyMode) {
      _selectedType = ContactType.phone;
    }
```
(Place this at the end of `initState`.)

- [ ] **Step 3: Render verify UI when verifyMode is on**

In `build`, replace the `actions:` of the AppBar so verify mode hides the Add/Save button:
```dart
        actions: [
          if (!widget.verifyMode)
            AppTextButton(
              text: widget.initialContact == null ? 'Add' : 'Save',
              onPressed: _submit,
            ),
        ],
```

In the card `Column`, hide the type selector and primary checkbox in verify mode, and append the verify controls. Wrap the existing type-selector `Text('Contact Type')` + `_buildTypeSelector()` + type-error block in `if (!widget.verifyMode) ...[ ... ]`. Wrap the existing primary-checkbox `Row` condition as `if (!widget.verifyMode && widget.initialContact == null)`.

After the phone field / text field block, add:
```dart
                  if (widget.verifyMode) ...[
                    Gap(Spacing.md.h),
                    if (_codeSent) ...[
                      AppTextFormField(
                        controller: _codeController,
                        label: 'Verification code',
                        hintText: '123456',
                        keyboardType: TextInputType.number,
                      ),
                      Gap(Spacing.sm.h),
                    ],
                    if (_verifyError != null) ...[
                      Text(
                        _verifyError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                      Gap(Spacing.sm.h),
                    ],
                    AppButton(
                      label: _busy
                          ? 'Please wait...'
                          : (_codeSent ? 'Verify' : 'Send code'),
                      onPressed: _busy
                          ? null
                          : (_codeSent ? _verifyCode : _sendCode),
                      width: double.infinity,
                    ),
                  ],
```

- [ ] **Step 4: Add the send/verify handlers**

Add these methods to `_AddContactModalState`:
```dart
  Future<void> _sendCode() async {
    if (_e164Phone == null) {
      setState(() => _verifyError = 'Enter a valid phone number');
      return;
    }
    setState(() {
      _busy = true;
      _verifyError = null;
    });
    try {
      await ref
          .read(phoneVerificationControllerProvider)
          .sendCode(_e164Phone!);
      setState(() => _codeSent = true);
    } catch (e) {
      setState(() => _verifyError = 'Could not send code. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _verifyError = 'Enter the code');
      return;
    }
    setState(() {
      _busy = true;
      _verifyError = null;
    });
    try {
      final ok = await ref
          .read(phoneVerificationControllerProvider)
          .verifyCode(_e164Phone!, code);
      if (!mounted) return;
      if (ok) {
        Navigator.pop(context, true);
      } else {
        setState(() => _verifyError = 'Incorrect or expired code');
      }
    } catch (e) {
      setState(() => _verifyError = 'Verification failed. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
```

- [ ] **Step 5: Guard the existing `_submit` against null onSave**

In `_submit`, the two `widget.onSave(...)` calls become `widget.onSave?.call(...)`. (Verify mode never calls `_submit`, but this keeps the nullable signature safe.)

- [ ] **Step 6: Analyze**

Run: `flutter analyze lib/presentation/features/shops/creation/presentation/widgets/add_contact_modal.dart`
Expected: No issues.

- [ ] **Step 7: Commit**

```bash
git add lib/presentation/features/shops/creation/presentation/widgets/add_contact_modal.dart
git commit -m "feat(contacts): add opt-in phone verify mode to AddContactModal"
```

---

## Task 8: `ensurePhoneVerified` gate helper

**Files:**
- Create: `lib/presentation/features/auth/widgets/ensure_phone_verified.dart`

**Interfaces:**
- Consumes: `currentUserProfileProvider`, `AddContactModal(verifyMode: true)`, `BottomSheetUtils`.
- Produces: `Future<bool> ensurePhoneVerified(BuildContext context, WidgetRef ref)` — `true` if already verified or just verified via the sheet; `false` if dismissed/failed.

- [ ] **Step 1: Confirm the modal presentation helper**

Run: `grep -n "static.*show" lib/core/utils/bottom_sheet_utils.dart`
Expected: identify a method that presents a full-screen/large sheet (e.g. `showDocumentationBottomSheet` is used for `DocumentPickerSheet`). Use the same one `AddContactModal` is normally shown with.

- [ ] **Step 2: Write the helper**

```dart
// lib/presentation/features/auth/widgets/ensure_phone_verified.dart
//
// Gate for producer flows (freelancer / shop / product). Returns true when the
// account already has a verified phone, or completes verification via a
// phone-only AddContactModal. Returns false if the user dismisses.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/providers/profile_providers/profile_provider.dart';
import 'package:nano_embryo/core/utils/bottom_sheet_utils.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/add_contact_modal.dart';

Future<bool> ensurePhoneVerified(BuildContext context, WidgetRef ref) async {
  final profile = await ref.read(currentUserProfileProvider.future);
  if (profile?.isPhoneVerified == true) return true;

  if (!context.mounted) return false;
  final result = await BottomSheetUtils.showDocumentationBottomSheet<bool>(
    context: context,
    widget: const AddContactModal(verifyMode: true),
  );
  return result == true;
}
```

(If Step 1 shows a different/more appropriate presenter that returns the popped value, use that instead; the contract is that the sheet returns `true` when `Navigator.pop(context, true)` fires.)

- [ ] **Step 3: Verify the presenter returns the popped value**

Run: `grep -n "Future<\|return.*showModalBottomSheet\|return.*showCupertino\|return.*await" lib/core/utils/bottom_sheet_utils.dart | head`
Expected: confirm the chosen method is generic / returns the awaited result. If it is `void`/non-generic, add a generic variant or use `showModalBottomSheet<bool>` directly in the helper.

- [ ] **Step 4: Analyze**

Run: `flutter analyze lib/presentation/features/auth/widgets/ensure_phone_verified.dart`
Expected: No issues.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/features/auth/widgets/ensure_phone_verified.dart
git commit -m "feat(auth): add ensurePhoneVerified gate helper"
```

---

## Task 9: Rewrite producer cards in `edit_profile_screen`

**Files:**
- Modify: `lib/presentation/features/profile/widgets/edit_profile_screen.dart`

**Interfaces:**
- Consumes: `ensurePhoneVerified`, `AccountType`, routes `/freelancerCreationDashboard`, `/myShopsScreen`, `/sellerOnboarding`.
- Produces: a compiling producer-cards block replacing the broken ternary at lines ~358–429.

- [ ] **Step 1: Add the import**

At the top of the file:
```dart
import 'package:nano_embryo/presentation/features/auth/widgets/ensure_phone_verified.dart';
```

- [ ] **Step 2: Add gate + card builder methods**

In `_EditProfileScreenState`, add:
```dart
  Future<void> _gatedPush(VoidCallback action) async {
    final ok = await ensurePhoneVerified(context, ref);
    if (!mounted || !ok) return;
    action();
  }

  Widget _producerCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return CardInkWell(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Column(
        children: [
          InfoRowWidget(
            subtitle: subtitle,
            title: title,
            icon: icon,
            avatarRadius: 25.h,
            onTap: onTap,
            showAvatar: false,
            showTrailingArrow: true,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildProducerCards(AppLocalizations loc) {
    return Column(
      children: [
        if (_selectedRole == AccountType.worker)
          _producerCard(
            title: loc.editProfileScreenEditWorkProfileTitle,
            subtitle: loc.editProfileScreenEditShopSubtitle,
            icon: Icons.person,
            onTap: () => _gatedPush(
              () => context.push(
                '/freelancerCreationDashboard',
                extra: {
                  'userId': widget.currentUserId,
                  'mode': FreelancerMode.create,
                },
              ),
            ),
          ),
        if (_selectedRole == AccountType.shop)
          _producerCard(
            title: loc.editProfileScreenEditShopTitle,
            subtitle: loc.editProfileScreenEditShopSubtitle,
            icon: Icons.storefront_rounded,
            onTap: () => _gatedPush(() => context.push('/myShopsScreen')),
          ),
        _producerCard(
          title: 'Sell a product',
          subtitle:
              'Sell your beauty products like pomades, shampoos, hairbrushes and more.',
          icon: Icons.sell_outlined,
          onTap: () => _gatedPush(() => context.push('/sellerOnboarding')),
        ),
      ],
    );
  }
```

- [ ] **Step 3: Replace the broken ternary block in `build`**

Delete the entire broken block currently spanning from `_selectedRole?.displayName == 'worker'?` (line ~359) through the closing of the third `CardInkWell` (line ~429), i.e. everything between `Gap(Spacing.sm),` and `Gap(Spacing.xl),`. Replace with:

```dart
            Gap(Spacing.sm),
            _buildProducerCards(loc),
            Gap(Spacing.xl),
```

- [ ] **Step 4: Analyze (must compile now)**

Run: `flutter analyze lib/presentation/features/profile/widgets/edit_profile_screen.dart`
Expected: No issues. (Previously this file did not compile.)

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/features/profile/widgets/edit_profile_screen.dart
git commit -m "fix(profile): rewrite role-based producer cards with phone gate"
```

---

## Task 10: Seller onboarding screen

**Files:**
- Create: `lib/presentation/features/products/presentation/screens/seller_onboarding_screen.dart`

**Interfaces:**
- Consumes:
  - `currentUserProvider` (`auth_provider.dart:33`) for the profile id.
  - `shopRepositoryProvider` → `getShopsByProfileId(profileId)` (existing shop check). Defined in `lib/presentation/features/shops/query/providers/shop_repository_provider.dart`. Returns `List<ShopListItemDTO>`; each DTO exposes `.id` (`lib/presentation/features/shops/query/data/models/dtos/shop_list_item_dto.dart:4`).
  - `uploadDocumentImageProvider` → `UploadDocumentImage.execute(document, profileId, shopId)` (`lib/presentation/features/shops/creation/data/upload_document_image.dart`).
  - `shopCreationRepositoryProvider` → `SupabaseShopCreationRepository.createShop(profileId, draft, imageUrls, documentUrls, logoUrl)` (provider defined at `lib/presentation/features/shops/creation/repository/supabase_shop_creation_repository.dart:599`).
  - `ShopDraft(profileId:, shopName:, overview:, shopType:)` (`shop_draft.dart`).
  - `DocumentPickerSheet(onDocumentPicked:)` + `DocumentDraft` + `BottomSheetUtils.showDocumentationBottomSheet`.
  - `ProductFormScreen` via `/productForm` route, `extra: {'shopId', 'mode': FormMode.create}`.
- Produces: `SellerOnboardingScreen` widget.

- [ ] **Step 1: Write the screen**

```dart
// lib/presentation/features/products/presentation/screens/seller_onboarding_screen.dart
//
// First-time product seller onboarding. Phone verification has already passed
// (gate runs before navigation). If the user already owns a shop, we route
// straight to its product form. Otherwise we collect a shop overview + a
// business document, create a minimal seller-shop, and open the product form.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/bottom_sheet_utils.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/product_form_screen.dart';
import 'package:nano_embryo/presentation/features/shops/creation/data/upload_document_image.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/document_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/shop_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/document_picker_sheet.dart';
import 'package:nano_embryo/presentation/features/shops/creation/repository/supabase_shop_creation_repository.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_repository_provider.dart';

class SellerOnboardingScreen extends ConsumerStatefulWidget {
  const SellerOnboardingScreen({super.key});

  @override
  ConsumerState<SellerOnboardingScreen> createState() =>
      _SellerOnboardingScreenState();
}

class _SellerOnboardingScreenState
    extends ConsumerState<SellerOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _overviewController = TextEditingController();
  final List<DocumentDraft> _documents = [];
  bool _checkingExisting = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkExistingShop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _overviewController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingShop() async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) {
      setState(() => _checkingExisting = false);
      return;
    }
    try {
      final shops =
          await ref.read(shopRepositoryProvider).getShopsByProfileId(userId);
      if (!mounted) return;
      if (shops.isNotEmpty) {
        // Already a shop owner — go straight to the product form.
        _openProductForm(shops.first.id);
        return;
      }
    } catch (_) {
      // Fall through to onboarding form on lookup failure.
    }
    if (mounted) setState(() => _checkingExisting = false);
  }

  void _openProductForm(String shopId) {
    context.pushReplacement(
      '/productForm',
      extra: {'shopId': shopId, 'mode': FormMode.create},
    );
  }

  void _pickDocument() {
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      widget: DocumentPickerSheet(
        onDocumentPicked: (doc) => setState(() => _documents.add(doc)),
      ),
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_documents.isEmpty) {
      setState(() => _error = 'Please upload at least one business document.');
      return;
    }
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      // 1. Upload documents (reuse the shop document uploader).
      final uploader = ref.read(uploadDocumentImageProvider);
      final documentUrls = <String>[];
      for (final doc in _documents) {
        final url = await uploader.execute(
          document: doc,
          profileId: userId,
          shopId: 'temp',
        );
        if (url != null) documentUrls.add(url);
      }

      // 2. Create a minimal seller-shop.
      final draft = ShopDraft(
        profileId: userId,
        shopName: _nameController.text.trim(),
        overview: _overviewController.text.trim(),
        shopType: 'product_seller',
      );
      final shopId = await ref.read(shopCreationRepositoryProvider).createShop(
            profileId: userId,
            draft: draft,
            imageUrls: const [],
            documentUrls: documentUrls,
            logoUrl: null,
          );

      if (!mounted) return;
      _openProductForm(shopId);
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Could not start selling. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_checkingExisting) {
      return const Scaffold(body: Center(child: CircularLoadingIndicator()));
    }

    return Scaffold(
      backgroundColor: colorScheme.neutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Sell a product',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(Spacing.lg),
          children: [
            AppTextFormField(
              controller: _nameController,
              label: 'Shop name',
              hintText: 'e.g., Kwame Beauty Supplies',
              validator: (v) =>
                  (v == null || v.trim().length < 3) ? 'Enter a shop name' : null,
            ),
            Gap(Spacing.md),
            AppTextFormField(
              controller: _overviewController,
              label: 'Shop overview',
              hintText: 'Tell buyers what you sell...',
              maxLines: 4,
              validator: (v) => (v == null || v.trim().length < 10)
                  ? 'Add a short overview'
                  : null,
            ),
            Gap(Spacing.lg),
            Text(
              'Business document',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            Gap(Spacing.xs),
            Text(
              'Upload a business registration or any verification document.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Gap(Spacing.sm),
            ..._documents.asMap().entries.map(
                  (e) => ListTile(
                    leading: Icon(e.value.type.icon),
                    title: Text(e.value.fileName),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () =>
                          setState(() => _documents.removeAt(e.key)),
                    ),
                  ),
                ),
            OutlinedButton.icon(
              onPressed: _pickDocument,
              icon: const Icon(Icons.upload_file),
              label: const Text('Add document'),
            ),
            if (_error != null) ...[
              Gap(Spacing.md),
              Text(
                _error!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colorScheme.error),
              ),
            ],
            Gap(Spacing.xl),
            AppButton(
              label: _submitting ? 'Please wait...' : 'Continue',
              onPressed: _submitting ? null : _submit,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

Run: `flutter analyze lib/presentation/features/products/presentation/screens/seller_onboarding_screen.dart`
Expected: No issues. If `currentProfileIdProvider` is the canonical way to get the profile id elsewhere in shop creation, `currentUserProvider?.id` is equivalent here (both yield the auth user id used as `profileId`).

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/features/products/presentation/screens/seller_onboarding_screen.dart
git commit -m "feat(products): add seller onboarding (overview + document) screen"
```

---

## Task 11: Register `/sellerOnboarding` route

**Files:**
- Modify: `lib/app/routing/app_router.dart`

**Interfaces:**
- Consumes: `SellerOnboardingScreen`.
- Produces: `RouteNames.sellerOnboarding = '/sellerOnboarding'` + a `GoRoute` building `SellerOnboardingScreen`.

- [ ] **Step 1: Add the route name**

Near the other route-name constants (e.g. after `productForm` at line ~169):
```dart
  static const String sellerOnboarding = '/sellerOnboarding';
```

- [ ] **Step 2: Add the import**

With the other screen imports at the top:
```dart
import 'package:nano_embryo/presentation/features/products/presentation/screens/seller_onboarding_screen.dart';
```

- [ ] **Step 3: Add the GoRoute**

Next to the `productForm` route (after line ~1086):
```dart
      GoRoute(
        path: RouteNames.sellerOnboarding,
        name: 'sellerOnboarding',
        builder: (context, state) => const SellerOnboardingScreen(),
      ),
```

- [ ] **Step 4: Analyze**

Run: `flutter analyze lib/app/routing/app_router.dart`
Expected: No issues.

- [ ] **Step 5: Commit**

```bash
git add lib/app/routing/app_router.dart
git commit -m "feat(routing): register /sellerOnboarding route"
```

---

## Task 12: Full analyze + manual smoke test

**Files:** none (verification only)

- [ ] **Step 1: Full analyze**

Run: `flutter analyze`
Expected: No new issues introduced by this work.

- [ ] **Step 2: Deploy edge functions + set secrets (manual, requires Twilio account)**

```bash
supabase secrets set TWILIO_ACCOUNT_SID=... TWILIO_AUTH_TOKEN=... TWILIO_VERIFY_SERVICE_SID=...
supabase functions deploy phone-verify-start
supabase functions deploy phone-verify-check
```
Expected: both functions deploy successfully.

- [ ] **Step 3: Manual smoke test (run the app)**

1. As a `worker`-role account, open Edit Profile → only the "Create freelancer profile" + "Sell a product" cards show.
2. Switch role to `shop` → "Create shop" + "Sell a product" cards show.
3. Tap any card with no verified phone → verify sheet opens; send code; enter the SMS code → sheet closes and the original flow opens.
4. Tap another gated card → no verify prompt (already verified).
5. "Sell a product" with no existing shop → overview + document form → Continue → product form opens with a real shopId.

Expected: all five behave as described.

- [ ] **Step 4: Commit any fixes uncovered**

```bash
git add -A
git commit -m "fix: address smoke-test findings for producer onboarding"
```

---

## Notes on the Algorithm Quality Review Checklist

- **Input validation:** E.164 validated in `PhoneFieldWidget` (client) and re-validated by regex in both edge functions; code format checked before Twilio call.
- **Idempotency:** Re-verification overwrites `phone_verified_at` harmlessly; existing-shop check prevents duplicate seller-shops.
- **Error/edge handling:** Twilio/network failures surface as inline errors; gate returns `false` so no navigation occurs; expired/incorrect codes handled (`approved` check + 404 → expired).
- **Security boundaries:** verification columns are service-role-write-only (DB trigger); edge function derives user id from JWT, never from the body.
- **No regressions:** `AddContactModal` change is opt-in; `ProductFormScreen` unchanged; only the producer-cards block of `edit_profile_screen` is rewritten.
