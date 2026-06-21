# Account Lifecycle Engine — Integration Guide

A plug-and-play deactivate, restore, and pending-delete account lifecycle engine
for Flutter + Supabase apps. Copy `lib/core/account_lifecycle/` and the two
SQL migrations into any new project, override one file with your routes and
localization, and you have a production-grade lifecycle flow in under an hour.

This engine is graded against [`Algorithm Quality Review Checklist v3.1`](algorithms/algorithm_quality_review_checklist.md).
It passes all P0 and P1 items, the relevant P2 items, and includes a Dart unit
test suite covering models, guard, error mapping, and the Riverpod controller.

---

## What you get out of the box

| Feature | Details |
|---------|---------|
| Deactivate account | Hides public presence (shops, workers, products, short-links) |
| Pending deletion | Configurable grace window (default 30 days) before final scrub |
| Restore | One-shot restore replays the captured visibility snapshot |
| Confirmation | Password for email users, typed phrase for OAuth users (DEACTIVATE / DELETE) |
| Blockers | RPC-driven checks for active bookings, orders, withdrawals |
| Router guard | Inactive users are forced to the restore screen |
| Recent-auth gate | 10-minute reauth window enforced server-side |
| Rate limiting | 5 attempts per 10 minutes per (action, user) — configurable |
| Audit trail | Append-only `account_lifecycle_audit_log` with PII-redacted snapshots |
| Correlation IDs | Generated client-side, propagated through every RPC into audit context |
| Structured logging | Pluggable logger callback for entry/exit/error events |
| Finalizer | Chunked, per-row error isolation, dead-letter queue, configurable cron |

---

## Prerequisites

| Dependency | Version | Notes |
|-----------|---------|-------|
| `flutter_riverpod` | ^2.x | State management |
| `supabase_flutter` | ^2.x | Backend + RPCs |
| `go_router` | ^13.x | Route guard helper assumes `context.go(...)` |
| `intl` | ^0.x | Date formatting for the restore screen |

---

## 1 — Database setup

Apply both migrations in order against your Supabase project:

```bash
supabase db push   # if using local Supabase CLI
# or paste these into Dashboard → SQL Editor → Run, in order:
#   supabase/migrations/20260609000000_account_lifecycle.sql
#   supabase/migrations/20260609001000_harden_account_lifecycle.sql
#   supabase/migrations/20260613120000_account_lifecycle_v2.sql
```

The migrations create:

| Object | Purpose |
|--------|---------|
| `profiles.account_status` + lifecycle columns | Tombstone state on the existing profiles table |
| `account_lifecycle_audit_log` | Append-only audit trail (no UPDATE / DELETE / TRUNCATE) |
| `account_lifecycle_rate_limit` | Per-user, per-action token bucket |
| `account_lifecycle_finalizer_dlq` | Failed finalizer rows for retry / inspection |
| `account_lifecycle_recent_metrics` view | Rolling 7-day RED metrics |
| 5 RPCs | `get_account_action_blockers`, `deactivate_account`, `request_account_deletion`, `restore_account`, `finalize_due_account_deletions` |

The finalizer is registered on `pg_cron` (default `17 3 * * *`) when the
extension is available. Override the schedule with the
`app.account_lifecycle.finalizer_cron` GUC.

---

## 2 — App-specific SQL hooks

Every app needs to answer the same five domain questions. Edit the helper
functions in `20260609000000_account_lifecycle.sql` to match your schema:

| Hook | Question | NanoEmbryo answer |
|------|----------|-------------------|
| `get_account_action_blockers()` | What active obligations prevent leaving? | bookings, orders, withdrawals |
| `snapshot_account_visibility()` | Which public visibility fields must be restored exactly? | shops, products, workers, short-links |
| `hide_account_public_presence()` | Which public rows must disappear? | flip `is_active`, clear booking slug |
| `restore_account_visibility()` | How should the snapshot be replayed? | UPSERT from JSONB array |
| `finalize_due_account_deletions()` | Which PII columns get scrubbed on final delete? | `username`, `display_name`, `bio`, `avatar_url` |

The public RPC names stay the same. Only the bodies of these five functions
need app-specific changes when porting.

---

## 3 — Configurable thresholds (Postgres GUCs)

Every threshold is server-side configurable without a code change. Set GUCs
via `ALTER DATABASE ... SET ...` or per-session `SET LOCAL`:

| GUC | Default | Purpose |
|-----|---------|---------|
| `app.account_lifecycle.pending_delete_window` | `30 days` | Grace period before finalize |
| `app.account_lifecycle.reauth_window` | `10 minutes` | How fresh the session must be for destructive ops |
| `app.account_lifecycle.rate_limit_max` | `5` | Attempts per window per (action, user) |
| `app.account_lifecycle.rate_limit_window` | `10 minutes` | Rate-limit window |
| `app.account_lifecycle.finalizer_batch_size` | `500` | Profiles processed per finalizer run |
| `app.account_lifecycle.finalizer_cron` | `17 3 * * *` | Cron schedule for the finalizer |
| `app.account_lifecycle.reason_max` | `1000` | Hard cap on free-text reason length |

Example:

```sql
ALTER DATABASE postgres SET app.account_lifecycle.pending_delete_window = '14 days';
ALTER DATABASE postgres SET app.account_lifecycle.rate_limit_max = '3';
```

---

## 4 — Flutter wiring

### 4a. Wire the config in `main.dart`

```dart
import 'package:your_app/core/account_lifecycle/config/account_lifecycle_config.dart';

// Inside ProviderScope overrides:
accountLifecycleConfigProvider.overrideWithValue(
  buildYourAppAccountLifecycleConfig(),
),
```

Build the config once, in `lib/core/account_lifecycle/config/account_lifecycle_config.dart`
(the only file you should edit when porting). NanoEmbryo's version looks like:

```dart
AccountLifecycleConfig buildYourAppAccountLifecycleConfig() {
  return AccountLifecycleConfig(
    appName: 'Your App',
    restoreRoute: RouteNames.restoreAccount,
    homeRoute: RouteNames.home,
    introRoute: RouteNames.intro,

    // Must equal app.account_lifecycle.pending_delete_window GUC.
    pendingDeleteWindow: const Duration(days: 30),
    reasonMaxLength: 1000,

    textsBuilder: (context) => YourAppLifecycleTexts(AppLocalizations.of(context)!),

    refreshProfile: (ref) => ref.invalidate(currentUserProfileProvider),

    signOut: (context, ref) async {
      await ref.read(authOperationsProvider).signOut();
      await ref.read(preferencesServiceProvider).clearUserData();
      if (context.mounted) context.go(RouteNames.intro);
    },

    showSuccess: (context, m) => context.showSuccessSnackbar(m),
    showError: (context, m) => context.showErrorSnackbar(m),

    // Optional but recommended: hook your app's logger.
    logger: (message, {correlationId, context, error, stackTrace}) {
      yourLogger.info('account_lifecycle: $message',
        extra: {'correlation_id': correlationId, ...?context},
        error: error, stackTrace: stackTrace);
    },
  );
}
```

### 4b. Register the three routes

```dart
GoRoute(path: '/deactivateAccount', builder: (_, __) => const DeactivateAccountScreen()),
GoRoute(path: '/deleteAccount',     builder: (_, __) => const DeleteAccountScreen()),
GoRoute(path: '/restoreAccount',    builder: (_, __) => const RestoreAccountScreen()),
```

### 4c. Wire the guard into your router redirect

```dart
final accountGuard = accountLifecycleGuard(
  profile: profile,
  currentLocation: state.matchedLocation,
  restoreRoute: RouteNames.restoreAccount,
  homeRoute: RouteNames.home,
);
if (accountGuard.shouldRedirect) return accountGuard.route;
```

The helper accepts either a `Map<String, dynamic>` or any object with a
`toJson()` method that returns one — so it works against both raw Supabase rows
and typed models.

### 4d. Add settings entries

Drop two rows into your settings screen that `context.go('/deactivateAccount')`
and `context.go('/deleteAccount')` respectively. The engine does not dictate
your settings UI.

---

## 5 — Localization

The engine ships with English defaults via `AccountLifecycleTexts`. To
localize, subclass it and pass the subclass through `textsBuilder`. NanoEmbryo
maps every string to `AppLocalizations` (see
`config/account_lifecycle_config.dart`).

The required string keys are listed in `config/account_lifecycle_texts.dart`.
Add the new error key `rateLimited` when porting from older versions.

---

## 6 — Observability

| Signal | Where |
|--------|-------|
| Audit row per attempt | `account_lifecycle_audit_log` (action, actor, outcome, before/after, context) |
| Correlation ID | `context.correlation_id` on every audit row, propagated from the client |
| Rolling RED metrics | `account_lifecycle_recent_metrics` view (last 7 days, by action × outcome) |
| Failed finalizer rows | `account_lifecycle_finalizer_dlq` (error code, message, target_user_id) |
| Client logs | `AccountLifecycleConfig.logger` callback (entry / exit / error) |

Recommended alerts (set up in your monitoring of choice):

| Alert | Query / signal |
|-------|----------------|
| Spike in `denied` outcomes | `count(*) FILTER (WHERE outcome='denied')` over rolling hour |
| Any `finalize_account_deletion` failure | `account_lifecycle_finalizer_dlq` non-empty |
| `rate_limited` spike | Audit context reason = `rate_limited` |

---

## 7 — Security model

| Concern | Mitigation |
|---------|------------|
| Unauthorized RPC | `auth.uid()` checked in every RPC; helpers are REVOKEd from `public` |
| Recent-auth gate | `account_lifecycle_assert_recent_confirmation` requires sign-in within `reauth_window` |
| Confirmation phrase | OAuth users must type `DEACTIVATE` / `DELETE`; server uppercases input before comparison |
| Rate limiting | Per-user, per-action token bucket; fires before auth checks |
| Input bounds | Reason length capped (1000 chars); audit context capped (8 KiB) |
| Audit immutability | Triggers reject `UPDATE` / `DELETE` / `TRUNCATE`; service_role lacks those grants |
| PII in audit | Snapshots are redacted: only status + timestamps + booleans, never username/bio/email/avatar |
| RLS on public rows | shops / workers / products / short-links are visible only when owner `account_status='active'` |
| Single transaction | All state changes happen inside one RPC = one transaction; partial state is impossible |

---

## 8 — Failure modes & runbook

| Failure | Symptom | Recovery |
|---------|---------|----------|
| Provider transient error on RPC | User sees the engine's generic error | Retry-as-user is safe (idempotent on state) |
| Finalizer cron misses a day | DLQ stays empty, no `finalize_account_deletion` audit rows for that day | Manually run `SELECT public.finalize_due_account_deletions();` |
| Single row fails in finalizer | DLQ row added; other rows in the batch still succeed | Investigate the DLQ row, fix root cause, re-run the finalizer |
| Visibility restore partial failure | Restore RPC throws; profile stays inactive; audit `outcome='failure'` with `reason=visibility_restore_failed` | Re-run `restore_account_visibility(user_id, snapshot_from_audit_before_state)` manually, then update profile status |
| Need to rollback the v2 migration | RPC signatures gained a third arg `p_correlation_id` | Revert by re-running the v1 hardening migration; older signatures will replace the v2 ones |
| User stuck in pending_delete after schedule passed | Cron not running | Check `cron.job` for `finalize-due-account-deletions`; trigger manually |

---

## 9 — Files to change per app

When porting to a new project, only these files need editing:

| File | What to change |
|------|---------------|
| `config/account_lifecycle_config.dart` | Routes, localization bridge, logger, sign-out, refresh-profile, success/error snackbars |
| App router | Three routes plus guard helper call |
| Settings UI | Rows that `go('/deactivateAccount')` and `go('/deleteAccount')` |
| Supabase lifecycle SQL | App-specific helper bodies (blockers / snapshot / hide / restore / scrub) |

Everything inside `core/account_lifecycle/` except
`config/account_lifecycle_config.dart` is generic and is intended to be
copied unchanged.

---

## 10 — Architecture overview

```
┌───────────────────────────────────────────────────────────────┐
│  Flutter App                                                  │
│                                                               │
│  DeactivateAccountScreen   DeleteAccountScreen                │
│  RestoreAccountScreen      Router guard                       │
│       │                                                       │
│       │  AccountLifecycleConfig (one file you edit)           │
│       ▼                                                       │
│  AccountLifecycleController                                   │
│  ├─ generates correlation_id                                  │
│  ├─ thread-safe via Riverpod autoDispose                      │
│  └─ logs entry / exit / error via injected logger             │
│       │                                                       │
│       ▼                                                       │
│  AccountLifecycleRepository                                   │
│  └─ Supabase RPC calls (typed PostgrestException → engine     │
│     exception code → localized error text)                    │
└──────────────────────┬────────────────────────────────────────┘
                       │ Supabase client (20s hard timeout)
          ┌────────────┼────────────────────────────────┐
          │            │                                │
   deactivate_account  request_account_deletion  restore_account
   (recent-auth gate, rate limit, phrase check, RLS, append-only audit)
          │
          └─► profiles (account_status tombstone)
              + account_lifecycle_audit_log (redacted snapshots)
              + account_lifecycle_rate_limit (token bucket)
              + account_lifecycle_finalizer_dlq (failed finalize attempts)
                       │
                       └─► finalize_due_account_deletions (cron, configurable)
                             chunked LIMIT N + SKIP LOCKED + per-row isolation
```

---

## 11 — Test suite

The engine ships with Dart unit tests covering models, the router guard, the
error mapper, and the Riverpod controller (47 tests):

```bash
flutter test test/account_lifecycle/
```

SQL hardening verification lives at
`supabase/tests/account_lifecycle_hardening.sql` — run against staging after
applying the migrations.

---

## 12 — Versioning

- **v1** (`20260609000000_account_lifecycle.sql`) — initial RPCs and RLS.
- **v1.1** (`20260609001000_harden_account_lifecycle.sql`) — reason bound,
  recent-auth gate, append-only audit log.
- **v2** (`20260613120000_account_lifecycle_v2.sql`) — PII-redacted audit
  snapshots, configurable GUCs, rate limiting, chunked finalizer with DLQ,
  optional `p_correlation_id`, savepoint on restore.

All three are required for a fresh install. v2 is a strict superset of v1.1.
