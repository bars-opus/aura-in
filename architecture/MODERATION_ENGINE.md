# Moderation Engine — Integration Guide

A plug-and-play blocking, reporting, and audit engine for Flutter + Supabase apps.

Copy `lib/core/moderation/` and the SQL migration into any new project and follow this guide to go from zero to working moderation in under an hour. Same pattern as the notification engine — one config object, one migration, no source changes inside the engine itself.

---

## What you get out of the box

| Feature | Details |
|---------|---------|
| Mutual user blocking | If either side blocks, both lose profile / listing / chat visibility |
| Idempotent block / unblock | Partial unique index + race-safe insert; replays are no-ops |
| Structured report queue | Reports for `profile`, `shop`, `freelancer` targets, with per-target ownership verification |
| Idempotent report submission | Client UUID idempotency key reused across retries; replays return `already_reported` |
| Rate limiting | 20 reports/hour per reporter, 3/24h per target_owner — abuse / brigading guard |
| Pagination | Cursor-based `get_blocked_accounts` with max 200/page |
| Append-only audit log | Triggers block UPDATE / DELETE / TRUNCATE; `record_moderation_audit` writes actor / event / target / payload |
| Blocked accounts inbox | List + unblock screen for the current user |
| Unavailable state widget | Shared widget for hidden / blocked profile and listing surfaces |
| Localized copy | Default English bundle; subclass `ModerationTexts` to localize |
| Observability hook | Per-RPC log event with elapsed time and stable error code |
| Per-RPC timeout | 15s default, configurable |
| Stable error codes | SQL `HINT` strings round-tripped to a Dart enum for friendly UX copy |

---

## Prerequisites

| Dependency | Version | Notes |
|-----------|---------|-------|
| `flutter_riverpod` | ^2.x | State management |
| `supabase_flutter` | ^2.x | Backend + RLS |
| `go_router` | ^13.x | Navigation (only needed if you wire the engine routes) |
| `uuid` | ^4.x | Client-side idempotency keys |

Schema dependencies the migration expects to already exist in your project:

| Table | Required columns |
|-------|------------------|
| `profiles` | `id uuid primary key`, plus `display_name`, `username`, `avatar_url` (for the blocked-accounts list) |
| `shops` | `id uuid`, `user_id uuid` (owner) |
| `workers` | `id uuid`, `user_id uuid`, `is_freelancer boolean` |

If you do not use `shops` or `workers`, edit `moderation_target_exists` to remove those branches and drop those values from the `target_type` CHECK constraint.

---

## 1 — Database setup

Run the migration once against your Supabase project:

```bash
supabase db push
# or paste supabase/migrations/20260613000000_moderation_engine.sql
# into Dashboard → SQL Editor → Run
```

The migration creates three tables, a handful of `SECURITY DEFINER` RPCs, and triggers that enforce audit-log immutability.

| Table | Purpose |
|-------|---------|
| `user_blocks` | Active and released block pairs (mutual semantics) |
| `moderation_reports` | Structured reports against profile / shop / freelancer |
| `moderation_audit_log` | Append-only ledger of every moderation action |

| RPC | Auth | Purpose |
|-----|------|---------|
| `get_blocked_accounts(limit, cursor_created_at)` | authenticated | Paginated list of the caller's active blocks |
| `get_moderation_hidden_user_ids()` | authenticated | Union of both-direction blocks for visibility filters |
| `is_moderation_blocked(other_user_id)` | authenticated | `{is_blocked, is_blocked_by_current_user, is_blocking_current_user}` |
| `block_user(blocked_user_id, reason)` | authenticated | Idempotent block; returns `{success, reason?}` |
| `unblock_user(blocked_user_id)` | authenticated | Soft-delete via `released_at`; returns `{success, reason?}` |
| `submit_moderation_report(target_type, target_id, target_owner_id, reason, details, client_idempotency_key)` | authenticated | Idempotent + rate-limited |

All RPCs return uniform `jsonb` objects, never `RETURNS TABLE` (Dart parses one shape).

---

## 2 — Stable error codes (SQL `HINT` → Dart enum)

Every SQL exception sets `HINT = '<stable_code>'`. The Dart repository maps the hint to `ModerationErrorCode.*`, and `moderationErrorMessage(texts, error)` turns that into user-facing copy.

| HINT | Where it fires | Default English message |
|------|----------------|-------------------------|
| `auth_required` | RPC entry — no `auth.uid()` | "Please sign in to continue." |
| `self_block_not_allowed` | `block_user` | "You cannot block your own account." |
| `self_report_not_allowed` | `submit_moderation_report` | "You cannot report your own account." |
| `target_not_found` | target row missing or `target_owner_id` mismatch | "This profile or listing is no longer available." |
| `target_missing` | NULL `target_id` / `target_owner_id` | maps to `targetNotFound` copy |
| `target_type_invalid` | unsupported `target_type` | "Please check the information you entered." |
| `reason_invalid` | unsupported `reason` enum value | "Select a reason before continuing." |
| `reason_max_300` | block reason > 300 chars | "Reason must be 300 characters or fewer." |
| `details_max_1000` | report details > 1000 chars | "Details must be 1000 characters or fewer." |
| `idempotency_required` | NULL `client_idempotency_key` | generic |
| `rate_limited_hour` | reporter > 20 reports / hour | "You have submitted too many reports recently…" |
| `rate_limited_target` | reporter > 3 reports / target / 24h | "You have already reported this account multiple times today." |
| `timeout` | client-side `TimeoutException` after `rpcTimeout` | "The request took too long. Please try again." |

Override any of these strings by subclassing `ModerationTexts` and passing your builder into `ModerationConfig.textsBuilder`.

---

## 3 — Flutter wiring

### 3a. Wire the config in `main.dart`

```dart
import 'package:your_app/core/moderation/config/feature/moderation_config.dart';
import 'package:your_app/core/moderation/config/moderation_config.dart';

// Inside ProviderScope overrides:
moderationConfigProvider.overrideWithValue(
  buildYourAppModerationConfig(),
),
```

Where `buildYourAppModerationConfig()` returns a `ModerationConfig` like:

```dart
ModerationConfig buildYourAppModerationConfig() {
  return ModerationConfig(
    appName: 'YourApp',
    blockedAccountsRoute: '/settings/blocked',
    blockAccountRoute: '/moderation/block',
    reportTargetRoute: '/moderation/report',
    supabaseClient: Supabase.instance.client,

    // Localize: subclass ModerationTexts and return it here.
    textsBuilder: (context) => YourAppModerationTexts(context),

    // After block/unblock/report, refresh app-side providers that may
    // now show different data (e.g. profile, search results).
    refreshProfile: (ref) => ref.invalidate(currentUserProfileProvider),
    refreshSearch: (ref) => ref.invalidate(searchResultsProvider),

    // Per-feature feedback. Defaults to ScaffoldMessenger snack bars.
    showSuccess: (context, msg) => context.showSuccessSnackbar(msg),
    showError:   (context, msg) => context.showErrorSnackbar(msg),

    // Optional observability — fires once per RPC.
    logger: (event) => Analytics.track('moderation.${event.operation}', {
      'success': event.success,
      'elapsed_ms': event.elapsed.inMilliseconds,
      if (event.errorCode != null) 'error_code': event.errorCode,
    }),

    rpcTimeout: const Duration(seconds: 15),
  );
}
```

### 3b. Add routes to your router

```dart
GoRoute(
  path: '/settings/blocked',
  builder: (_, __) => const BlockedAccountsScreen(),
),
GoRoute(
  path: '/moderation/block',
  builder: (_, state) => BlockAccountScreen(
    target: state.extra as ModerationTarget,
  ),
),
GoRoute(
  path: '/moderation/report',
  builder: (_, state) => ReportTargetScreen(
    target: state.extra as ModerationTarget,
  ),
),
```

Pass a `ModerationTarget` through the route `extra` when navigating from the "Block" or "Report" action sheets.

### 3c. Hide blocked users from your own surfaces

The engine exposes a single check the rest of your app can read:

```dart
final blockStatus = ref.watch(moderationBlockStatusProvider(otherUserId));
final hidden = blockStatus.value?.isBlocked == true;

if (hidden) {
  return Scaffold(
    body: ModerationUnavailableWidget(texts: moderationTexts),
  );
}
```

Or filter list queries server-side via `get_moderation_hidden_user_ids()`.

---

## 4 — Target model

All block / report flows take a `ModerationTarget`:

| Field | Meaning |
|------|---------|
| `targetType` | `profile`, `shop`, or `freelancer` |
| `targetId` | Record ID for the listing / profile being acted on |
| `targetOwnerId` | User / profile ID behind that record (the "person you're blocking") |
| `displayName` | Human-friendly label for UI copy |

The `(targetType, targetId, targetOwnerId)` triple is verified server-side by `moderation_target_exists` — a caller cannot report a real `target_id` with a forged owner.

### NanoEmbryo target conventions

- **Profile** — `targetId == targetOwnerId == profiles.id`
- **Shop** — `targetId = shops.id`, `targetOwnerId = shops.user_id`
- **Freelancer** — `targetId = workers.id`, `targetOwnerId = workers.user_id`

---

## 5 — Idempotency contract

| Operation | Key | Server behavior on replay |
|-----------|-----|---------------------------|
| `block_user` | `(blocker, blocked)` pair via partial unique index | Returns `{success: true, reason: 'already_blocked'}` |
| `unblock_user` | none needed — UPDATE | Returns `{success: true, reason: 'not_blocked'}` if no active row |
| `submit_moderation_report` | `(reporter_user_id, client_idempotency_key)` UNIQUE | Returns `{success: true, reason: 'already_reported'}` |

`ReportTargetScreen` generates one UUID v4 in `initState` and **reuses it across retries** of the same intent. The key only rotates after a confirmed success — so a network-failed retry hits the same `(reporter, key)` row and the server short-circuits before re-running the rate-limit check.

If you build your own report entry point, follow the same pattern: one key per user intent, not one per HTTP call.

---

## 6 — Customising

### Add a new target type

1. Add the value to the SQL CHECK constraint on `moderation_reports.target_type`.
2. Add a branch to `moderation_target_exists`.
3. Add the value to `ModerationTargetType` in `data/moderation_models.dart`.

### Add a new report reason

1. Add the value to the SQL CHECK constraint on `moderation_reports.reason`.
2. Add a `ModerationReasonOption` to `ModerationTexts.reasonOptions()`.

### Change rate-limit thresholds

Edit the `20` and `3` literals in `submit_moderation_report`. Consider whether the limit should be per-user or per-IP (engine ships with per-user; add IP-based via a header trigger if you need it).

### Localize

Subclass `ModerationTexts`, override the getters you care about, return it from `ModerationConfig.textsBuilder`. See `lib/core/moderation/config/feature/moderation_config.dart` for the NanoEmbryo six-language subclass as an example.

---

## 7 — Files to change per app

When porting to a new project, **only these files need editing**:

| File | What to change |
|------|---------------|
| `config/feature/moderation_config.dart` | App routes, text bundle, refresh hooks, snackbar adapter, logger |
| `main.dart` | `moderationConfigProvider.overrideWithValue(...)` in `ProviderScope` |
| Router | Wire `BlockedAccountsScreen`, `BlockAccountScreen`, `ReportTargetScreen` routes |
| `supabase/migrations/20260613000000_moderation_engine.sql` | Drop `shops` / `workers` branches if your app doesn't use them |

Everything inside `core/moderation/` **except** `config/feature/moderation_config.dart` is generic and can be copied unchanged.

---

## 8 — Observability

Pass a `logger` to `ModerationConfig` to capture every RPC:

```dart
logger: (event) {
  log.info('moderation.${event.operation}', extra: {
    'success': event.success,
    'elapsed_ms': event.elapsed.inMilliseconds,
    'error_code': event.errorCode,
  });
},
```

Recommended dashboards:
- **Rate** of `submit_moderation_report.success=true` per minute.
- **Error breakdown** by `errorCode` — sustained `rate_limited_*` signals abuse; sustained `timeout` signals a Supabase regression.
- **p95 elapsed** per operation.

The `moderation_audit_log` table is the system of record. It is append-only at the row level (triggers block UPDATE / DELETE / TRUNCATE). Use it for forensics and reconciliation, not for real-time metrics.

---

## 9 — Architecture overview

```
┌──────────────────────────────────────────────────────────────────┐
│  Flutter App                                                     │
│                                                                  │
│  BlockedAccountsScreen ──► moderationControllerProvider          │
│  BlockAccountScreen     ──► (block/unblock/submitReport)         │
│  ReportTargetScreen                                              │
│                                                                  │
│  ModerationUnavailableWidget — drop-in for hidden surfaces       │
│                                                                  │
│  Riverpod Providers                                              │
│  ├─ blockedAccountsProvider       (FutureProvider, autoDispose)  │
│  ├─ blockedUserIdsProvider        (derived set)                  │
│  ├─ moderationBlockStatusProvider (family, by otherUserId)       │
│  └─ moderationControllerProvider  (StateNotifier — mutations)    │
└──────────────────────────────┬───────────────────────────────────┘
                               │  Supabase RPC (jsonb, 15s timeout)
       ┌───────────────────────┼────────────────────────┐
       │                       │                        │
   user_blocks         moderation_reports        moderation_audit_log
   (partial unique     (reporter+key UNIQUE,     (append-only triggers,
    active pair idx)    rate-limited insert)      every action recorded)
```

---

## 10 — Quality checklist alignment (Algorithm Review v3.1)

| Phase | Coverage |
|-------|----------|
| Design | Idempotency keys (1.1), timeouts (1.2), authorization at every access (1.4/1.5), concurrency-safe (1.6), mutual block semantics documented |
| Implementation | Parameterized queries (2.2), no secrets (2.7–2.9), input sanitization (2.1), append-only audit (2.22), idempotent mutations (2.18/2.21) |
| Performance | Pagination (3.1), partial indexes (3.3), rate limiting (3.8) |
| Observability | Structured logger hook (4.1), stable error codes (4.5), audit ledger (4.8) |
| UX | Actionable error copy (5.1), no info leakage (5.5), retry button on error state |
| Security | RLS + REVOKE + GRANT EXECUTE (1.4/7.4), `SECURITY DEFINER` with locked `search_path` (7.2) |

Gaps deferred until the right time (acceptable for v1, track in the moderation audit backlog):
- Soak / load test (6.10 / 6.11)
- Distributed tracing (4.3)
- Mutation testing (6.8)
- Dependency CVE scan automation (7.7)
