# Document Review Queue (Manual Verification) — Design

**Date:** 2026-06-20
**Status:** Approved (ready for implementation plan)

## Goal

Add a manual verification workflow so producer documents (business
registration, IDs, etc.) are reviewed by an admin before the producer goes
live. Today the app collects documents but verifies nothing: the
`ManageDocumentsScreen` claims documents are "for verification" while
`DocumentDraft.isVerified` is hardcoded `false` and never changes, and
`shops.verified` is set `false` at creation and never flips.

This is the **manual-review MVP** — the foundation. An automated IDV vendor
(**Smile ID**, Africa-first: Ghana Card / BVN / NIN / business registration /
liveness) is a deliberate **later** layer that will plug into the same status
fields and shrink the manual queue. This spec does NOT build the vendor
integration.

## Background: how this maps to real platforms

Uber/Bolt/DoorDash use a 3-layer pipeline: (1) automated document
authenticity + OCR + liveness, (2) cross-checks against authoritative
registries (national ID / business registries), (3) human review of edge
cases + ongoing monitoring. They outsource (1)+(2) to vendors (Onfido,
Persona, Veriff, Jumio, Stripe Identity, Sumsub, Smile ID). Most marketplaces
**launch with manual review (layer 3) only** and add automation later. That is
exactly this plan: manual review now, Smile ID later.

## Key decisions

- **Gate = public visibility / going live.** Producers can create and edit
  their shop/freelancer/product, but it stays hidden from clients (not
  discoverable, not bookable, products not purchasable) until approved.
- **Reviewer surface = in-app admin screen** (new Flutter screen), gated by an
  `app_admins` allowlist (no admin concept exists in the app today).
- **Status lives per-producer-entity** — on `shops` and `workers` (the two
  entities that go live). Product sellers are minimal shops, so they are
  covered by the `shops` status.
- **Rejection requires a reason; producer can resubmit** (status → pending).
- **All `verification_*` writes go through service-role edge functions** and
  are trigger-protected from client writes, so no one can self-approve.

---

## Section 1 — Data model

New migration (`ALTER`s existing remote tables `shops` / `workers`, which are
not defined in local migrations — additive only).

### On `shops` and `workers`

- `verification_status text NOT NULL DEFAULT 'pending'`
  — CHECK in (`pending`, `approved`, `rejected`).
- `verification_submitted_at timestamptz`
- `verification_reviewed_by uuid` (admin's profile id)
- `verification_reviewed_at timestamptz`
- `verification_rejection_reason text`

Keep the existing `shops.verified` boolean in sync:
`verified = (verification_status = 'approved')`, maintained by the edge
function (and a one-time backfill: existing `verified=true` rows →
`verification_status='approved'`; everything else → `pending`).
`workers` has no prior `verified` column; status is authoritative there.

### Admin allowlist

New table `app_admins (user_id uuid primary key references auth.users,
created_at timestamptz default now())`. Seeded manually (SQL insert). Used by
the review edge function to authorize the actor and by RLS to let admins read
pending submissions.

### Write protection

A guard trigger (same pattern as the phone-verification guard) on `shops` and
`workers`: the `verification_*` columns and `verified` are writable **only by
service role** (`auth.role() = 'service_role'`). Non-service-role INSERT or
UPDATE that changes these columns raises an exception. This guarantees a
producer cannot self-approve even though they own the row.

---

## Section 2 — Review flow & authorization

Two edge functions (mirroring the `phone-verify-*` structure; service role used
only for the privileged DB write; caller identity always derived from JWT).

### `review-verification` (admin action)

- Auth: user JWT. Derive caller id via `getUser()` (anon-key client + JWT).
  Check membership in `app_admins`; return 403 if absent. Never trust a
  client-supplied admin flag.
- Input: `{ entity_type: 'shop' | 'worker', entity_id: string,
  decision: 'approved' | 'rejected', rejection_reason?: string }`.
- Validate: `entity_type` in the allowed set; `decision` in the allowed set;
  when `decision = 'rejected'`, `rejection_reason` is required and non-empty
  (trimmed). Reject bad input with 400.
- Write (service role) to the target table (`shops` or `workers`) where
  `id = entity_id`:
  - `verification_status = decision`
  - `verification_reviewed_by = caller_id`
  - `verification_reviewed_at = now()`
  - `verification_rejection_reason = (decision == rejected ? reason : null)`
  - for `shops`: `verified = (decision == 'approved')`
  - `.select('id')` and require exactly one row written (else 404/500).
- Return `{ ok: true, status: decision }`.

### `submit-verification` (producer action: first submit + resubmit)

- Auth: user JWT. Derive caller id from JWT.
- Input: `{ entity_type: 'shop' | 'worker', entity_id: string }`.
- Authorize: the caller must **own** the entity (the entity's `user_id` =
  caller id); else 403.
- Write (service role): `verification_status = 'pending'`,
  `verification_submitted_at = now()`, `verification_rejection_reason = null`.
  Row-written guard.
- Return `{ ok: true, status: 'pending' }`.
- Used at the end of onboarding (first submit) and from the rejected-state
  banner (resubmit after re-uploading documents).

Both functions exist because the `verification_*` columns are
trigger-protected from client writes — even the owner's resubmit must route
through a trusted server path. This keeps a single write path and prevents
self-approval.

---

## Section 3 — Gating (hiding unverified producers)

Defense in depth — the current `verified` filter is client-side only, so RLS
is added as the real gate.

### Layer A — RLS (authoritative)

Extend `shops_public_read` and `workers_public_read` so public readers
(anon + authenticated) see a row only when:
`verification_status = 'approved'` AND the existing `account_status='active'`
/ `is_active` conditions hold — **OR** the reader is the owner
(`auth.uid() = user_id`), so producers always see their own row (pending /
rejected included) — **OR** the reader is an admin
(`exists (select 1 from app_admins a where a.user_id = auth.uid())`).

### Layer B — query filters

Update discovery queries currently doing `.eq('verified', true)` to
`.eq('verification_status', 'approved')` for consistency and index use
(`supabase_shop_repository.dart` lines ~125, ~367, ~515 and the worker
equivalents). RLS already enforces it; the explicit filter avoids surprises.

### Products

A product is purchasable only if its shop is approved. Add a shop-status
check where products/checkout resolve the shop (so a product whose shop is
pending/rejected is not displayed or checkoutable). Products inherit gating
through `shops.verification_status`.

### Owner experience while gated

The producer's own shop/freelancer/product screens show a status banner:
- `pending` → "Pending review — your profile is hidden until approved."
- `rejected` → "Rejected: <reason>" + a "Re-upload documents & resubmit"
  action that re-opens document upload and calls `submit-verification`.
Clients simply don't see the entity until `approved`.

---

## Section 4 — Admin review screen

New admin-only `VerificationReviewScreen` at route
`/adminVerificationQueue`.

- **Access:** `isCurrentUserAdminProvider` (FutureProvider) queries
  `app_admins` for the current user id. The entry point — a tile on the
  profile/settings screen — renders only when `isCurrentUserAdmin == true`.
  The route redirects non-admins out. (Server-side, the edge function is the
  real guard; this is UX gating.)
- **Queue list:** a provider fetches pending submissions across both entities
  (`shops` and `workers` with `verification_status='pending'`), ordered by
  `verification_submitted_at` ascending (oldest first). Row shows producer
  name/avatar, entity type label (Shop / Freelancer / Product seller),
  submitted-at, document count.
- **Detail / review:** tapping a row opens the submission — documents from
  `shop_media` where `media_type='document'` (and the worker equivalent),
  rendered with the existing `DocumentPreviewDialog` /
  `DisplayShopDocuments` widgets, plus the overview text. Actions: **Approve**
  and **Reject** (reject reveals a required reason field). Both call
  `review-verification`, then invalidate the queue + entity providers.
- **States:** loading, empty ("No pending submissions"), per-row busy during
  the call, inline error on failure. Material 3 design tokens throughout.

**Reused, not rebuilt:** `DocumentPreviewDialog`, `DisplayShopDocuments`,
`AppButton`, `CardInkWell`, snackbars. New: queue provider, admin-guard
provider, the screen + route, and the two edge functions.

---

## Algorithm Quality Review Checklist (applied throughout)

- **Input validation:** `entity_type` / `decision` constrained to enums
  server-side; `rejection_reason` required+non-empty on reject; entity
  ownership enforced for resubmit. CHECK constraint on
  `verification_status`.
- **Idempotency:** Re-approving/re-rejecting is safe (overwrites status +
  reviewer). Resubmit from any non-pending state is safe. Backfill uses
  `IF NOT EXISTS` / guarded updates.
- **Error/edge handling:** 400 on bad input, 403 on non-admin / non-owner,
  404/500 on no-row-written; client surfaces inline errors and never
  partially updates UI on failure.
- **Security boundaries:** `verification_*` columns service-role-write-only
  (trigger); admin authority checked server-side against `app_admins`;
  caller id always from JWT; RLS hides unverified producers from the public
  even against hand-crafted queries.
- **No regressions:** status columns are additive with safe defaults;
  `verified` kept in sync for any existing consumers; discovery queries
  updated in lockstep with RLS; document-upload widgets reused unchanged.

## Out of scope (YAGNI)

- Automated IDV vendor (Smile ID) integration — separate later spec; this
  design leaves the status fields ready for it to write to.
- External/web admin panel — in-app screen only for launch.
- Per-document (vs per-entity) approval granularity.
- Re-verification scheduling / document-expiry monitoring.
