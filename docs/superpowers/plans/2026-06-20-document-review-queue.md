# Document Review Queue Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a manual admin verification workflow so producer documents are reviewed before a shop/freelancer/product becomes publicly visible, with an in-app admin review queue.

**Architecture:** Add `verification_status` + reviewer fields to `shops` and `workers`, guarded so only the service role can write them. Two Twilio-style edge functions handle admin decisions (`review-verification`) and producer (re)submission (`submit-verification`), authorizing the caller from their JWT. Public visibility is gated by RLS (real gate) plus discovery-query filters (consistency). An in-app admin-only screen lists pending submissions and renders uploaded document URLs for approve/reject.

**Tech Stack:** Flutter, Riverpod, GoRouter, Supabase (Postgres + RLS + Edge Functions/Deno).

## Global Constraints

- State management: Riverpod only. Repository pattern for data.
- Material Design 3 with design tokens (`Spacing`, `theme.colorScheme`).
- Edge functions mirror `supabase/functions/phone-verify-check/index.ts`: caller identity derived from JWT via an anon-key client; service role used ONLY for the privileged DB write; errors sanitized to generic client messages.
- Edge functions invoked from Flutter via `supabase.functions.invoke(name, body: {...})` (see `lib/payment/data/repositories/payment_settings_repository.dart:89`).
- `verification_status` ∈ {`pending`, `approved`, `rejected`} (CHECK-constrained).
- `verification_*` columns + `shops.verified` are service-role-write-only (guard trigger).
- `verified` is kept in sync: `verified = (verification_status = 'approved')` for `shops`.
- Deno type-check: run `deno check --no-config <file>` (repo lacks import_map.json).
- supabaseClientProvider: `lib/presentation/features/auth/providers/auth_provider.dart:12`. currentUserProvider: same file, line 33.

---

## File Structure

**Backend (Supabase):**
- `supabase/migrations/20260620120000_verification_queue.sql` — columns, CHECK, `app_admins` table, guard trigger, backfill, RLS updates.
- `supabase/functions/review-verification/index.ts` — admin approve/reject.
- `supabase/functions/submit-verification/index.ts` — producer (re)submit.

**Flutter:**
- `lib/presentation/features/admin/providers/admin_provider.dart` — `isCurrentUserAdminProvider`, `pendingVerificationsProvider`, `verificationActionsProvider` (Create).
- `lib/presentation/features/admin/data/verification_submission.dart` — DTO for a queue row (Create).
- `lib/presentation/features/admin/presentation/screens/verification_review_screen.dart` — queue + detail/review UI (Create).
- `lib/app/routing/app_router.dart` — `/adminVerificationQueue` route (Modify).
- `lib/presentation/features/profile/widgets/profile_screen.dart` — admin entry tile shown only to admins (Modify).
- `lib/presentation/features/shops/query/data/repositories/supabase_shop_repository.dart` — swap `verified` filters to `verification_status='approved'` (Modify).

---

## Task 1: Migration — status columns, app_admins, guard, backfill, RLS

**Files:**
- Create: `supabase/migrations/20260620120000_verification_queue.sql`

**Interfaces:**
- Produces: `shops`/`workers`.`verification_status` (+ `verification_submitted_at`, `verification_reviewed_by`, `verification_reviewed_at`, `verification_rejection_reason`); table `public.app_admins(user_id uuid pk, created_at timestamptz)`; trigger `trg_guard_verification_cols` on both tables; updated `shops_public_read`, `workers_public_read`, `products_read_active` policies.

- [ ] **Step 1: Write the migration**

```sql
-- supabase/migrations/20260620120000_verification_queue.sql
-- Manual document verification workflow. Producer entities (shops, workers)
-- carry a verification_status that gates public visibility. Only the service
-- role (via review-verification / submit-verification edge functions) may write
-- the verification_* columns; a guard trigger enforces this so producers
-- cannot self-approve.

-- 1. Status columns on shops + workers
alter table public.shops
  add column if not exists verification_status text not null default 'pending',
  add column if not exists verification_submitted_at timestamptz,
  add column if not exists verification_reviewed_by uuid,
  add column if not exists verification_reviewed_at timestamptz,
  add column if not exists verification_rejection_reason text;

alter table public.workers
  add column if not exists verification_status text not null default 'pending',
  add column if not exists verification_submitted_at timestamptz,
  add column if not exists verification_reviewed_by uuid,
  add column if not exists verification_reviewed_at timestamptz,
  add column if not exists verification_rejection_reason text;

do $$ begin
  alter table public.shops
    add constraint shops_verification_status_chk
    check (verification_status in ('pending','approved','rejected'));
exception when duplicate_object then null; end $$;

do $$ begin
  alter table public.workers
    add constraint workers_verification_status_chk
    check (verification_status in ('pending','approved','rejected'));
exception when duplicate_object then null; end $$;

-- 2. Backfill: existing verified shops are treated as already approved.
update public.shops
  set verification_status = 'approved'
  where verified = true and verification_status <> 'approved';

-- 3. Admin allowlist
create table if not exists public.app_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.app_admins enable row level security;
-- Admins can read the allowlist (to self-check); only service role writes it.
drop policy if exists app_admins_self_read on public.app_admins;
create policy app_admins_self_read on public.app_admins
  for select to authenticated
  using (user_id = auth.uid());

-- 4. Guard: verification_* columns (and shops.verified) are service-role-only.
create or replace function public.guard_verification_columns()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.role() <> 'service_role' then
    if tg_op = 'INSERT' then
      if new.verification_status is distinct from 'pending'
         or new.verification_reviewed_by is not null
         or new.verification_reviewed_at is not null
         or new.verification_rejection_reason is not null then
        raise exception 'verification columns are read-only for clients';
      end if;
    else
      if new.verification_status is distinct from old.verification_status
         or new.verification_submitted_at is distinct from old.verification_submitted_at
         or new.verification_reviewed_by is distinct from old.verification_reviewed_by
         or new.verification_reviewed_at is distinct from old.verification_reviewed_at
         or new.verification_rejection_reason is distinct from old.verification_rejection_reason then
        raise exception 'verification columns are read-only for clients';
      end if;
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_guard_verification_cols on public.shops;
create trigger trg_guard_verification_cols
  before insert or update on public.shops
  for each row execute function public.guard_verification_columns();

-- shops.verified is derived from verification_status and must also be
-- client-write-protected (added here for shops only):
create or replace function public.guard_shop_verified_column()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.role() <> 'service_role'
     and tg_op = 'UPDATE'
     and new.verified is distinct from old.verified then
    raise exception 'verified is read-only for clients';
  end if;
  return new;
end;
$$;
drop trigger if exists trg_guard_shop_verified on public.shops;
create trigger trg_guard_shop_verified
  before update on public.shops
  for each row execute function public.guard_shop_verified_column();

drop trigger if exists trg_guard_verification_cols on public.workers;
create trigger trg_guard_verification_cols
  before insert or update on public.workers
  for each row execute function public.guard_verification_columns();

-- 5. RLS: public sees only approved entities; owner + admins see all.
drop policy if exists shops_public_read on public.shops;
create policy shops_public_read on public.shops
  for select to anon, authenticated
  using (
    (
      verification_status = 'approved'
      and exists (
        select 1 from public.profiles p
        where p.id = shops.user_id and p.account_status = 'active'
      )
    )
    or auth.uid() = shops.user_id
    or exists (select 1 from public.app_admins a where a.user_id = auth.uid())
  );

drop policy if exists workers_public_read on public.workers;
create policy workers_public_read on public.workers
  for select to anon, authenticated
  using (
    (
      verification_status = 'approved'
      and coalesce(is_active, true) = true
      and exists (
        select 1 from public.profiles p
        where p.id = workers.user_id and p.account_status = 'active'
      )
      and (
        workers.shop_id is null
        or exists (
          select 1 from public.shops s
          join public.profiles owner_profile on owner_profile.id = s.user_id
          where s.id = workers.shop_id
            and owner_profile.account_status = 'active'
        )
      )
    )
    or auth.uid() = workers.user_id
    or exists (select 1 from public.app_admins a where a.user_id = auth.uid())
  );

-- 6. Products gated through their shop's verification.
drop policy if exists products_read_active on public.products;
create policy products_read_active on public.products
  for select
  using (
    is_active = true
    and exists (
      select 1 from public.shops s
      join public.profiles p on p.id = s.user_id
      where s.id = products.shop_id
        and p.account_status = 'active'
        and s.verification_status = 'approved'
    )
  );
```

- [ ] **Step 2: Apply and verify (if local Supabase available)**

Run: `supabase db reset` (or `supabase migration up`).
Expected: applies cleanly. If no local Docker/Supabase, validate SQL is well-formed and idempotent (IF NOT EXISTS / create or replace / drop ... if exists / duplicate_object guards) and note runtime test skipped.

- [ ] **Step 3: Verify the guard blocks client self-approval (if DB available)**

Run (authenticated, non-service-role): `update public.shops set verification_status='approved' where id='<own-shop>';`
Expected: ERROR `verification columns are read-only for clients`.

- [ ] **Step 4: Commit**

```bash
git add supabase/migrations/20260620120000_verification_queue.sql
git commit -m "feat(db): verification status, app_admins, guard trigger, gating RLS"
```

---

## Task 2: `submit-verification` edge function

**Files:**
- Create: `supabase/functions/submit-verification/index.ts`

**Interfaces:**
- Produces: POST endpoint, user-JWT auth. Body `{ entity_type: 'shop'|'worker', entity_id: string }`. Caller must own the entity. Sets status='pending', submitted_at=now(), clears rejection_reason. Returns `{ ok: true, status: 'pending' }`.

- [ ] **Step 1: Write the function**

```ts
// supabase/functions/submit-verification/index.ts
// Producer (re)submits an entity for verification. Auth: owner JWT.
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status, headers: { "Content-Type": "application/json" },
  });
}

const TABLES: Record<string, string> = { shop: "shops", worker: "workers" };

export async function handler(req: Request): Promise<Response> {
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);
  const auth = req.headers.get("Authorization") ?? "";
  if (!auth.startsWith("Bearer ")) return json({ error: "Unauthorized" }, 401);
  const userJwt = auth.slice("Bearer ".length);

  const url = Deno.env.get("SUPABASE_URL")!;
  const serviceRole = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;

  const userClient = createClient(url, anonKey, {
    global: { headers: { Authorization: `Bearer ${userJwt}` } },
  });
  const { data: userData, error: userErr } = await userClient.auth.getUser();
  if (userErr || !userData.user) return json({ error: "Unauthorized" }, 401);
  const userId = userData.user.id;

  let body: { entity_type?: string; entity_id?: string };
  try { body = await req.json(); } catch { return json({ error: "Invalid JSON" }, 400); }
  const table = TABLES[body.entity_type ?? ""];
  const entityId = (body.entity_id ?? "").trim();
  if (!table || !entityId) return json({ error: "Invalid input" }, 400);

  const admin = createClient(url, serviceRole);
  // Ownership check via service role (entity may be hidden from the user by RLS).
  const { data: owned, error: ownErr } = await admin
    .from(table).select("user_id").eq("id", entityId).maybeSingle();
  if (ownErr) return json({ error: "Lookup failed" }, 500);
  if (!owned || owned.user_id !== userId) return json({ error: "Forbidden" }, 403);

  const { data: rows, error: updErr } = await admin
    .from(table)
    .update({
      verification_status: "pending",
      verification_submitted_at: new Date().toISOString(),
      verification_rejection_reason: null,
    })
    .eq("id", entityId)
    .select("id");
  if (updErr || !rows || rows.length !== 1) {
    return json({ error: "Could not submit" }, 500);
  }
  return json({ ok: true, status: "pending" }, 200);
}

serve(handler);
```

- [ ] **Step 2: Type-check**

Run: `deno check --no-config supabase/functions/submit-verification/index.ts`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add supabase/functions/submit-verification/index.ts
git commit -m "feat(edge): add submit-verification function"
```

---

## Task 3: `review-verification` edge function

**Files:**
- Create: `supabase/functions/review-verification/index.ts`

**Interfaces:**
- Produces: POST endpoint, user-JWT auth, caller must be in `app_admins`. Body `{ entity_type:'shop'|'worker', entity_id, decision:'approved'|'rejected', rejection_reason? }`. Writes status/reviewer fields (and `verified` for shops). Returns `{ ok:true, status }`.

- [ ] **Step 1: Write the function**

```ts
// supabase/functions/review-verification/index.ts
// Admin approves/rejects an entity's verification. Auth: admin JWT
// (membership in app_admins). Service role used only for the privileged write.
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status, headers: { "Content-Type": "application/json" },
  });
}

const TABLES: Record<string, string> = { shop: "shops", worker: "workers" };

export async function handler(req: Request): Promise<Response> {
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);
  const auth = req.headers.get("Authorization") ?? "";
  if (!auth.startsWith("Bearer ")) return json({ error: "Unauthorized" }, 401);
  const userJwt = auth.slice("Bearer ".length);

  const url = Deno.env.get("SUPABASE_URL")!;
  const serviceRole = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;

  const userClient = createClient(url, anonKey, {
    global: { headers: { Authorization: `Bearer ${userJwt}` } },
  });
  const { data: userData, error: userErr } = await userClient.auth.getUser();
  if (userErr || !userData.user) return json({ error: "Unauthorized" }, 401);
  const userId = userData.user.id;

  const admin = createClient(url, serviceRole);

  // Authorize: caller must be an admin.
  const { data: adminRow, error: adminErr } = await admin
    .from("app_admins").select("user_id").eq("user_id", userId).maybeSingle();
  if (adminErr) return json({ error: "Auth check failed" }, 500);
  if (!adminRow) return json({ error: "Forbidden" }, 403);

  let body: {
    entity_type?: string; entity_id?: string;
    decision?: string; rejection_reason?: string;
  };
  try { body = await req.json(); } catch { return json({ error: "Invalid JSON" }, 400); }

  const table = TABLES[body.entity_type ?? ""];
  const entityId = (body.entity_id ?? "").trim();
  const decision = body.decision ?? "";
  const reason = (body.rejection_reason ?? "").trim();
  if (!table || !entityId) return json({ error: "Invalid input" }, 400);
  if (decision !== "approved" && decision !== "rejected") {
    return json({ error: "Invalid decision" }, 400);
  }
  if (decision === "rejected" && reason.length === 0) {
    return json({ error: "Rejection reason required" }, 400);
  }

  const patch: Record<string, unknown> = {
    verification_status: decision,
    verification_reviewed_by: userId,
    verification_reviewed_at: new Date().toISOString(),
    verification_rejection_reason: decision === "rejected" ? reason : null,
  };
  if (table === "shops") patch.verified = decision === "approved";

  const { data: rows, error: updErr } = await admin
    .from(table).update(patch).eq("id", entityId).select("id");
  if (updErr || !rows || rows.length !== 1) {
    return json({ error: "Could not record decision" }, 500);
  }
  return json({ ok: true, status: decision }, 200);
}

serve(handler);
```

- [ ] **Step 2: Type-check**

Run: `deno check --no-config supabase/functions/review-verification/index.ts`
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add supabase/functions/review-verification/index.ts
git commit -m "feat(edge): add review-verification function"
```

---

## Task 4: Admin providers + submission DTO

**Files:**
- Create: `lib/presentation/features/admin/data/verification_submission.dart`
- Create: `lib/presentation/features/admin/providers/admin_provider.dart`

**Interfaces:**
- Consumes: `supabaseClientProvider`, `currentUserProvider` (`auth_provider.dart:12,33`).
- Produces:
  - `class VerificationSubmission { final String entityType; final String entityId; final String ownerName; final String? ownerAvatarUrl; final DateTime? submittedAt; final List<String> documentUrls; final String? overview; }`
  - `isCurrentUserAdminProvider` → `FutureProvider<bool>`
  - `pendingVerificationsProvider` → `FutureProvider<List<VerificationSubmission>>`
  - `verificationActionsProvider` → `Provider<VerificationActions>` with `Future<void> review({required String entityType, required String entityId, required String decision, String? rejectionReason})` and `Future<void> submit({required String entityType, required String entityId})`; both invalidate `pendingVerificationsProvider`.

- [ ] **Step 1: Write the DTO**

```dart
// lib/presentation/features/admin/data/verification_submission.dart
class VerificationSubmission {
  final String entityType; // 'shop' | 'worker'
  final String entityId;
  final String ownerName;
  final String? ownerAvatarUrl;
  final DateTime? submittedAt;
  final List<String> documentUrls;
  final String? overview;

  const VerificationSubmission({
    required this.entityType,
    required this.entityId,
    required this.ownerName,
    this.ownerAvatarUrl,
    this.submittedAt,
    this.documentUrls = const [],
    this.overview,
  });

  String get entityLabel => entityType == 'shop' ? 'Shop' : 'Freelancer';
}
```

- [ ] **Step 2: Write the providers**

```dart
// lib/presentation/features/admin/providers/admin_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/admin/data/verification_submission.dart';

final isCurrentUserAdminProvider = FutureProvider<bool>((ref) async {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return false;
  final client = ref.watch(supabaseClientProvider);
  final row = await client
      .from('app_admins')
      .select('user_id')
      .eq('user_id', userId)
      .maybeSingle();
  return row != null;
});

final pendingVerificationsProvider =
    FutureProvider<List<VerificationSubmission>>((ref) async {
  final client = ref.watch(supabaseClientProvider);

  // Shops pending review (admin RLS lets admins read all).
  final shopRows = await client
      .from('shops')
      .select(
        'id, overview, user_id, verification_submitted_at,'
        ' profiles!shops_user_id_fkey(display_name, username, avatar_url),'
        ' shop_media(url, media_type)',
      )
      .eq('verification_status', 'pending')
      .order('verification_submitted_at', ascending: true);

  final workerRows = await client
      .from('workers')
      .select(
        'id, user_id, verification_submitted_at,'
        ' profiles!workers_user_id_fkey(display_name, username, avatar_url)',
      )
      .eq('verification_status', 'pending')
      .order('verification_submitted_at', ascending: true);

  final List<VerificationSubmission> out = [];

  for (final r in (shopRows as List)) {
    final p = (r['profiles'] as Map?) ?? {};
    final media = ((r['shop_media'] as List?) ?? [])
        .where((m) => (m as Map)['media_type'] == 'document')
        .map((m) => (m as Map)['url'] as String)
        .toList();
    out.add(VerificationSubmission(
      entityType: 'shop',
      entityId: r['id'] as String,
      ownerName: (p['display_name'] ?? p['username'] ?? 'Unknown') as String,
      ownerAvatarUrl: p['avatar_url'] as String?,
      submittedAt: r['verification_submitted_at'] == null
          ? null
          : DateTime.tryParse(r['verification_submitted_at'] as String),
      documentUrls: media,
      overview: r['overview'] as String?,
    ));
  }

  for (final r in (workerRows as List)) {
    final p = (r['profiles'] as Map?) ?? {};
    out.add(VerificationSubmission(
      entityType: 'worker',
      entityId: r['id'] as String,
      ownerName: (p['display_name'] ?? p['username'] ?? 'Unknown') as String,
      ownerAvatarUrl: p['avatar_url'] as String?,
      submittedAt: r['verification_submitted_at'] == null
          ? null
          : DateTime.tryParse(r['verification_submitted_at'] as String),
    ));
  }

  out.sort((a, b) {
    final at = a.submittedAt, bt = b.submittedAt;
    if (at == null && bt == null) return 0;
    if (at == null) return 1;
    if (bt == null) return -1;
    return at.compareTo(bt);
  });
  return out;
});

class VerificationActions {
  VerificationActions(this._ref);
  final Ref _ref;

  Future<void> review({
    required String entityType,
    required String entityId,
    required String decision,
    String? rejectionReason,
  }) async {
    final client = _ref.read(supabaseClientProvider);
    final res = await client.functions.invoke('review-verification', body: {
      'entity_type': entityType,
      'entity_id': entityId,
      'decision': decision,
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
    });
    final data = res.data;
    if (data is! Map || data['ok'] != true) {
      throw Exception('Could not record decision. Please try again.');
    }
    _ref.invalidate(pendingVerificationsProvider);
  }

  Future<void> submit({
    required String entityType,
    required String entityId,
  }) async {
    final client = _ref.read(supabaseClientProvider);
    final res = await client.functions.invoke('submit-verification', body: {
      'entity_type': entityType,
      'entity_id': entityId,
    });
    final data = res.data;
    if (data is! Map || data['ok'] != true) {
      throw Exception('Could not submit for review. Please try again.');
    }
    _ref.invalidate(pendingVerificationsProvider);
  }
}

final verificationActionsProvider =
    Provider<VerificationActions>((ref) => VerificationActions(ref));
```

- [ ] **Step 3: Verify the foreign-key hint names**

The `profiles!shops_user_id_fkey` / `profiles!workers_user_id_fkey` embed syntax requires the actual FK constraint names. Run:
`grep -rn "shop_media\|user_id" lib/presentation/features/shops/query/data/repositories/supabase_shop_repository.dart | grep -i "profiles\|fkey\|select(" | head`
and check an existing profile-embed query in the repo for the correct hint. If the repo embeds profiles differently (e.g. `profiles(...)` without the `!fkey` hint, or a different constraint name), match that exact syntax. If shops have no direct FK embed example, use a two-step fetch instead: fetch the pending rows, collect `user_id`s, then `client.from('profiles').select('id, display_name, username, avatar_url').inFilter('id', ids)` and join in Dart. Note which approach you used.

- [ ] **Step 4: Analyze**

Run: `flutter analyze lib/presentation/features/admin/`
Expected: No issues.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/features/admin/
git commit -m "feat(admin): verification queue providers + submission DTO"
```

---

## Task 5: Admin review screen + route

**Files:**
- Create: `lib/presentation/features/admin/presentation/screens/verification_review_screen.dart`
- Modify: `lib/app/routing/app_router.dart`

**Interfaces:**
- Consumes: `pendingVerificationsProvider`, `verificationActionsProvider`, `VerificationSubmission`.
- Produces: `VerificationReviewScreen` (const constructor); route `/adminVerificationQueue`.

- [ ] **Step 1: Write the screen**

```dart
// lib/presentation/features/admin/presentation/screens/verification_review_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/presentation/features/admin/data/verification_submission.dart';
import 'package:nano_embryo/presentation/features/admin/providers/admin_provider.dart';

class VerificationReviewScreen extends ConsumerWidget {
  const VerificationReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final queue = ref.watch(pendingVerificationsProvider);

    return Scaffold(
      backgroundColor: colorScheme.neutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Verification queue',
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: queue.when(
        loading: () => const Center(child: CircularLoadingIndicator()),
        error: (e, _) => Center(
          child: ErrorStateWidget(
            subtitle: 'Could not load the queue.',
            onPrimaryAction: () =>
                ref.invalidate(pendingVerificationsProvider),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: EmptyStateWidget(
                icon: Icons.verified_outlined,
                title: 'No pending submissions',
                subtitle: 'New verification requests will appear here.',
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(Spacing.md),
            itemCount: items.length,
            separatorBuilder: (_, __) => Gap(Spacing.sm),
            itemBuilder: (_, i) => _SubmissionCard(item: items[i]),
          );
        },
      ),
    );
  }
}

class _SubmissionCard extends ConsumerStatefulWidget {
  const _SubmissionCard({required this.item});
  final VerificationSubmission item;

  @override
  ConsumerState<_SubmissionCard> createState() => _SubmissionCardState();
}

class _SubmissionCardState extends ConsumerState<_SubmissionCard> {
  bool _busy = false;

  Future<void> _decide(String decision, {String? reason}) async {
    setState(() => _busy = true);
    try {
      await ref.read(verificationActionsProvider).review(
            entityType: widget.item.entityType,
            entityId: widget.item.entityId,
            decision: decision,
            rejectionReason: reason,
          );
      if (mounted) {
        context.showSuccessSnackbar(
          decision == 'approved' ? 'Approved' : 'Rejected',
        );
      }
    } catch (_) {
      if (mounted) context.showErrorSnackbar('Action failed. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _promptReject() async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject submission'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Reason (shown to the producer)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final r = controller.text.trim();
              if (r.isNotEmpty) Navigator.pop(ctx, r);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (reason != null && reason.isNotEmpty) {
      await _decide('rejected', reason: reason);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;
    return CardInkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${item.ownerName} · ${item.entityLabel}',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${item.documentUrls.length} doc(s)',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          if (item.overview != null && item.overview!.isNotEmpty) ...[
            Gap(Spacing.xs),
            Text(item.overview!, style: theme.textTheme.bodySmall),
          ],
          if (item.documentUrls.isNotEmpty) ...[
            Gap(Spacing.sm),
            SizedBox(
              height: 90.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: item.documentUrls.length,
                separatorBuilder: (_, __) => Gap(Spacing.xs),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _openDocument(item.documentUrls[i]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      item.documentUrls[i],
                      width: 90.h,
                      height: 90.h,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 90.h,
                        height: 90.h,
                        color: theme.colorScheme.surface,
                        child: const Icon(Icons.description),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          Gap(Spacing.sm),
          if (_busy)
            const Center(child: CircularLoadingIndicator())
          else
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Approve',
                    onPressed: () => _decide('approved'),
                  ),
                ),
                Gap(Spacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _promptReject,
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _openDocument(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.network(
            url,
            errorBuilder: (_, __, ___) => const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Could not load document.'),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify reused widgets exist via export_screens**

Run: `grep -rn "CircularLoadingIndicator\|EmptyStateWidget\|ErrorStateWidget\|CardInkWell\|showSuccessSnackbar\|showErrorSnackbar\|class Gap" lib/core | head`
Expected: confirm these symbols are exported by `export_screens.dart` (they are used widely in the codebase). If `Gap` is from a package import rather than core, ensure it resolves via `export_screens.dart` like other screens; adapt imports if analyze flags it.

- [ ] **Step 3: Add the route**

In `lib/app/routing/app_router.dart`: add a route-name constant near the others:
```dart
  static const String adminVerificationQueue = '/adminVerificationQueue';
```
Add the import with the other screen imports:
```dart
import 'package:nano_embryo/presentation/features/admin/presentation/screens/verification_review_screen.dart';
```
Add the GoRoute next to another simple no-arg route (e.g. `feedback`):
```dart
      GoRoute(
        path: RouteNames.adminVerificationQueue,
        name: 'adminVerificationQueue',
        builder: (context, state) => const VerificationReviewScreen(),
      ),
```

- [ ] **Step 4: Analyze**

Run: `flutter analyze lib/presentation/features/admin/ lib/app/routing/app_router.dart`
Expected: No errors.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/features/admin/ lib/app/routing/app_router.dart
git commit -m "feat(admin): verification review screen + route"
```

---

## Task 6: Admin entry tile + swap discovery filters

**Files:**
- Modify: `lib/presentation/features/profile/widgets/profile_screen.dart`
- Modify: `lib/presentation/features/shops/query/data/repositories/supabase_shop_repository.dart`

**Interfaces:**
- Consumes: `isCurrentUserAdminProvider`, route `/adminVerificationQueue`.

- [ ] **Step 1: Add the admin entry tile (admins only)**

In `profile_screen.dart`, add the import:
```dart
import 'package:nano_embryo/presentation/features/admin/providers/admin_provider.dart';
```
Find where the screen builds its list of settings/menu tiles (look for existing `InfoRowWidget` / `CardInkWell` entries or a `ListView`/`Column` of options). Watch the admin provider in `build` (the screen must be a `ConsumerWidget`/`ConsumerStatefulWidget` — it already uses `ref` if it reads profile providers; if not, convert it). Insert, conditional on admin:
```dart
ref.watch(isCurrentUserAdminProvider).maybeWhen(
  data: (isAdmin) => isAdmin
      ? CardInkWell(
          margin: EdgeInsets.only(bottom: 10.h),
          child: InfoRowWidget(
            title: 'Verification queue',
            subtitle: 'Review pending producer documents',
            icon: Icons.verified_user_outlined,
            avatarRadius: 25.h,
            onTap: () => context.push('/adminVerificationQueue'),
            showAvatar: false,
            showTrailingArrow: true,
            showDivider: false,
          ),
        )
      : const SizedBox.shrink(),
  orElse: () => const SizedBox.shrink(),
),
```
Match the exact placement/style of neighboring tiles in that file. Report where you inserted it.

- [ ] **Step 2: Swap discovery filters to verification_status**

In `supabase_shop_repository.dart`, change the three discovery filters that read `verified`:
```dart
query = query.eq('verified', true);
```
to:
```dart
query = query.eq('verification_status', 'approved');
```
(at the lines around 125, 367, 515 — find each `\.eq('verified', true)` and replace). Leave any non-discovery `verified` usage untouched. Run:
`grep -n "\.eq('verified', true)" lib/presentation/features/shops/query/data/repositories/supabase_shop_repository.dart`
first to enumerate them, replace each, then re-run to confirm none remain.

- [ ] **Step 3: Analyze**

Run: `flutter analyze lib/presentation/features/profile/widgets/profile_screen.dart lib/presentation/features/shops/query/data/repositories/supabase_shop_repository.dart`
Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/features/profile/widgets/profile_screen.dart lib/presentation/features/shops/query/data/repositories/supabase_shop_repository.dart
git commit -m "feat(admin): admin entry tile + gate discovery on verification_status"
```

---

## Task 7: Wire submission into onboarding + owner status banner

**Files:**
- Modify: `lib/presentation/features/products/presentation/screens/seller_onboarding_screen.dart`
- Modify: `lib/presentation/features/shops/creation/domain/usecases/publish_shop_usecase.dart` (or the shop/freelancer publish path)

**Interfaces:**
- Consumes: `verificationActionsProvider.submit(...)`.

- [ ] **Step 1: Submit shop for review after creation (seller onboarding)**

In `seller_onboarding_screen.dart` `_submit`, after `createShop` returns `shopId` and before navigating to the product form, call:
```dart
await ref.read(verificationActionsProvider).submit(
  entityType: 'shop',
  entityId: shopId,
);
```
Wrap so a submit failure does not block navigation (the shop exists; it just stays `pending` by default — log/snackbar but continue). Add the import:
```dart
import 'package:nano_embryo/presentation/features/admin/providers/admin_provider.dart';
```

- [ ] **Step 2: Submit on the main shop + freelancer publish paths**

Find where the full shop creation completes (`publish_shop_usecase.dart` after `createShop`) and where freelancer/worker creation completes. After each successful create, call `submit-verification` for the new entity id (`entity_type: 'shop'` or `'worker'`). Since the use case is not a widget, call the edge function via the existing supabase client it holds, OR have the calling provider (`publish_provider.dart`) invoke `verificationActionsProvider.submit(...)` after the use case returns. Use whichever matches the existing structure; report the chosen call site. (Default behavior is `pending` even without this call — this just stamps `verification_submitted_at` so the queue orders correctly.)

- [ ] **Step 3: Owner status banner**

In the producer's own shop/freelancer view (the screen the owner sees for their entity — locate the owner-facing shop detail/management screen), read the entity's `verification_status` and `verification_rejection_reason` and render a banner:
- `pending`: an info banner "Pending review — hidden from clients until approved."
- `rejected`: an error banner "Rejected: <reason>" + a button that re-opens document upload (reuse `ManageDocumentsScreen` flow) and on completion calls `verificationActionsProvider.submit(entityType, entityId)`.
- `approved`: no banner.
Use `SemanticContainerWidget` (already used for document hints) for the banner styling. Report which screen(s) you added it to.

- [ ] **Step 4: Analyze**

Run: `flutter analyze lib/presentation/features/products/presentation/screens/seller_onboarding_screen.dart`
Expected: No errors.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat(verification): submit on create + owner status banner"
```

---

## Task 8: Full analyze + manual verification

**Files:** none (verification only)

- [ ] **Step 1: Full analyze**

Run: `flutter analyze lib/`
Expected: No new errors in `lib/` introduced by this work (pre-existing test/ errors unrelated).

- [ ] **Step 2: Deploy edge functions + seed an admin (manual; needs Supabase access)**

```bash
supabase functions deploy submit-verification review-verification
# seed yourself as admin:
# insert into app_admins (user_id) values ('<your-auth-user-id>');
```

- [ ] **Step 3: Manual smoke test**

1. As a producer, create a shop/freelancer/sell-a-product → it submits, status `pending` → not visible in client discovery.
2. As an admin, open Profile → "Verification queue" → see the submission, preview documents.
3. Reject with a reason → producer sees the rejection banner + reason; re-uploads + resubmits → back in queue.
4. Approve → entity becomes discoverable/bookable; products purchasable.
5. Confirm a non-admin user does NOT see the "Verification queue" tile and cannot read pending entities via a direct query.

- [ ] **Step 4: Commit any fixes**

```bash
git add -A
git commit -m "fix: address verification queue smoke-test findings"
```

---

## Notes on the Algorithm Quality Review Checklist

- **Input validation:** enums (`entity_type`, `decision`) constrained server-side; rejection reason required+non-empty on reject; ownership enforced for resubmit; CHECK constraint on `verification_status`.
- **Idempotency:** re-approve/re-reject overwrites safely; resubmit from any non-pending state safe; migration backfill + columns guarded with IF NOT EXISTS / duplicate_object.
- **Error/edge handling:** 400 bad input, 403 non-admin/non-owner, 404/500 no-row-written; client surfaces inline errors, no partial UI update on failure.
- **Security boundaries:** verification_* + verified service-role-write-only (triggers); admin authority checked server-side against app_admins; caller id from JWT; RLS hides unverified producers from the public even against hand-crafted queries.
- **No regressions:** additive columns with safe defaults; `verified` kept in sync; discovery queries swapped in lockstep with RLS; document-upload widgets reused unchanged; admin UI gated client-side for UX and server-side for authority.
