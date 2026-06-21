# Feedback Engine — Integration Guide

A plug-and-play in-app feedback engine for Flutter + Supabase.

Copy `lib/core/feedback/` and `supabase/migrations/*_feedback_engine.sql`
into any new project and follow this guide to go from zero to working in
under thirty minutes.

---

## What you get out of the box

| Feature | Details |
|---------|---------|
| Submit screen | Type chips + title + description + optional screenshots |
| History screen | Lists the user's past submissions with status chip |
| Custom categories | Bug / Suggestion / Question / Other by default; fully replaceable |
| Screenshots | Optional, gated by config flag; uploads to a Supabase Storage bucket |
| Device + version info | Captured automatically via `DeviceInfoService` |
| Validation | Configurable length limits; structured exceptions |
| Server lifecycle | `pending → reviewed → implemented | rejected`, managed by staff |
| RLS-secured table | Users can only read/write their own submissions |

---

## Prerequisites

| Dependency | Version | Notes |
|-----------|---------|-------|
| `flutter_riverpod` | ^2.x | State management |
| `supabase_flutter` | ^2.x | Backend + storage |
| `image_picker` | ^1.x | Screenshot picking (only if `enableScreenshots: true`) |
| `device_info_plus` + `package_info_plus` | recent | Captured via `DeviceInfoService` |
| `intl` | ^0.19.x | Date formatting on the history screen |

---

## 1 — Database setup

Run the migration once against your Supabase project:

```bash
supabase db push
# or paste supabase/migrations/20260614000100_feedback_engine.sql
# into Dashboard → SQL Editor → Run
```

The migration creates:

| Object | Purpose |
|--------|---------|
| `public.user_feedback` table | One row per submission, RLS-scoped to the author |
| `storage.buckets` row `feedback-screenshots` | Public bucket, own-folder write |
| `storage.objects` RLS policies | Each user sandboxed to `<user_id>/…` |

RLS allows users to `select` and `insert` only their own rows. Status
transitions (`reviewed`, `implemented`, `rejected`) are reserved for
service-role / admin tooling.

---

## 2 — Flutter wiring

### 2a. Define your feedback categories

Create or edit `lib/core/feedback/config/feature/feedback_config.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:your_app/core/feedback/config/feedback_config.dart';

FeedbackConfig buildMyAppFeedbackConfig() {
  return const FeedbackConfig(
    appName: 'My App',
    types: [
      FeedbackTypeOption(
        key: 'bug',                 // STABLE — persisted in user_feedback.type
        label: '🐛 Bug',
        icon: Icons.bug_report,
      ),
      FeedbackTypeOption(
        key: 'idea',
        label: '💡 Idea',
        icon: Icons.lightbulb_outline,
      ),
      FeedbackTypeOption(
        key: 'praise',
        label: '🎉 Praise',
        icon: Icons.celebration,
      ),
    ],
    enableScreenshots: true,        // false → no attach UI, no Storage dep
    maxScreenshots: 3,
    maxTitleLength: 100,
    maxDescriptionLength: 5000,
  );
}
```

> **Don't rename `key` after shipping.** It's persisted in `user_feedback.type`
> and renaming orphans every existing row. To deprecate a type, drop it from
> `types` but keep handling old keys in your dashboard / analytics.

### 2b. Override the provider in `main.dart`

```dart
import 'package:your_app/core/feedback/config/feedback_config.dart';
import 'package:your_app/core/feedback/config/feature/feedback_config.dart';

ProviderScope(
  overrides: [
    feedbackConfigProvider.overrideWithValue(buildMyAppFeedbackConfig()),
  ],
  child: MyApp(),
)
```

### 2c. Add routes

```dart
GoRoute(
  path: '/feedback',
  builder: (_, __) => const FeedbackScreen(),
),
GoRoute(
  path: '/feedback/history',
  builder: (_, __) => const FeedbackHistoryScreen(),
),
```

### 2d. Open the screen from settings / app drawer

```dart
ListTile(
  leading: const Icon(Icons.feedback_outlined),
  title: const Text('Send feedback'),
  onTap: () => context.push('/feedback'),
),
```

---

## 3 — Customising copy and behaviour

Every visible string and behavioural knob is on `FeedbackConfig`:

```dart
FeedbackConfig(
  appName: 'My App',
  types: [...],
  submitScreenTitle: 'Tell us what's up',
  historyScreenTitle: 'Your reports',
  submitLabel: 'Send',
  thanksMessage: 'Got it — thanks!',
  maxTitleLength: 80,
  maxDescriptionLength: 2000,
  enableScreenshots: true,
  screenshotBucket: 'feedback-screenshots',
  maxScreenshots: 5,
  onSubmitted: (context, feedback) {
    analytics.track('feedback_sent', properties: {
      'type': feedback.type,
      'has_screenshots': feedback.screenshotUrls.isNotEmpty,
    });
  },
)
```

---

## 4 — Server-side status updates

The client cannot transition `status`. Update it from your admin tool or
SQL editor using the service role:

```sql
update public.user_feedback
set    status = 'implemented'
where  id = '00000000-0000-0000-0000-000000000000';
```

The history screen picks up the new status next time the user opens it
(or you can wire a Supabase realtime subscription to refresh live).

---

## 5 — Files to change per app

| File | What to change |
|------|---------------|
| `config/feature/feedback_config.dart` | Categories + per-app copy + screenshot flag |
| `main.dart` | `feedbackConfigProvider.overrideWithValue(...)` |
| Router | Add `/feedback` and `/feedback/history` routes |
| Supabase secrets | None — the engine uses the existing client + JWT |

Everything else inside `core/feedback/` is generic and can be copied
unchanged.

---

## 6 — Failure modes & runbook

The engine maps every failure to a typed `FeedbackException` subclass and a
user-friendly message. The error banner on the submit screen tells the user
whether retrying is safe (network blip → yes, validation → no).

| Exception | When it fires | User sees | Retry safe? | Operator action |
|-----------|--------------|-----------|-------------|------------------|
| `FeedbackAuthException` | JWT expired, RLS denied, or user not logged in | "Please log in to submit feedback." | ❌ | Force re-auth; check Supabase Auth dashboard |
| `FeedbackValidationException` | Title/desc length, screenshot > 5 MB, type not in config, or batch > 10 screenshots | The specific message | ❌ | Either fix client validation or expand the config's `types` list |
| `FeedbackTimeoutException` | An insert or upload exceeded its deadline × 3 attempts | "The network is slow…" | ✅ | Supabase status / project quota |
| `FeedbackStorageException` | Bucket policy or storage backend failure on upload | "Couldn't upload your screenshot…" | ✅ | Check Storage policies for `feedback-screenshots`; verify bucket exists |
| `FeedbackDatabaseException` | Postgres CHECK / FK / RLS / 5xx after retries | "Unable to submit feedback…" | ✅ for 5xx, ❌ for CHECK/RLS | Inspect Sentry `feedback.submit.failed` for the `code` attribute |
| `FeedbackException` (base) | Anything not caught above | "Something went wrong…" | ✅ | Always indicates a missing exception mapping — file a bug |

### Idempotency

Every submit carries a client-generated `idempotency_key` UUID. The DB unique
constraint `(user_id, idempotency_key)` dedupes server-side. If the user taps
Submit, the upload succeeds, the DB insert times out, and they re-tap, the
second insert hits the unique constraint and the repo silently fetches and
returns the already-persisted row — no duplicate entries, no lost work.

### Orphan-file cleanup

If screenshots upload successfully but the DB insert fails, the uploader's
`deleteAll(storagePaths)` is fired in the background to remove the orphaned
files. Cleanup is best-effort; failures are logged but not raised.

### Observability events

Emitted via `FeedbackLogger` (sink for Sentry/Crashlytics) and optionally the
host app's analytics via `FeedbackConfig.onEvent`. Attributes never contain
PII — only counts, error categories, and type keys.

| Event | Attributes | Trigger |
|-------|-----------|---------|
| `feedback_submit_started` | `type`, `has_screenshots`, `screenshot_count` | `submitFeedback` begins |
| `feedback_submitted` | `type`, `screenshot_count` | Insert succeeded |
| `feedback_submit_failed` | `category` ∈ {auth, validation, storage, timeout, database, unknown} | Insert or upload threw |
| `feedback_history_loaded` | `count` | Successful `loadFeedbackHistory` |
| `feedback_history_load_failed` | `category` | Load threw |
| `feedback.submit.dedup_hit` | — | Idempotency-key collision triggered a "refetch existing row" path |

Wire the host app's analytics:

```dart
FeedbackConfig(
  types: [...],
  onEvent: (event, attrs) => Analytics.track(event, properties: attrs),
)
```

Wire error tracking once at app bootstrap:

```dart
FeedbackLogger.setSink((level, msg, {error, stack, attributes}) {
  if (level == FeedbackLogLevel.error) {
    Sentry.captureException(error ?? msg, stackTrace: stack);
  }
});
```

### Alert thresholds (suggested)

| Condition | Window | Threshold | Action |
|-----------|--------|-----------|--------|
| `feedback_submit_failed` rate | 5 min | > 5% of `feedback_submit_started` | Page on-call; check Supabase dashboard |
| `category=storage` share | 15 min | > 30% of failures | Look at `feedback-screenshots` bucket / Storage backend |
| `category=auth` share | 15 min | > 30% of failures | Look for an auth-provider regression |
| `category=database` share | 15 min | > 30% of failures | Recent migration or RLS-policy change |

---

## 7 — PII & data retention

Free-form `title` and `description` are stored exactly as the user typed
them. **We don't redact**, because feedback is most useful when verbatim.
The host app is responsible for:

- Communicating in the UI that the user shouldn't paste payment details,
  passwords, or other sensitive content.
- Defining a retention policy (e.g. "archive `user_feedback` rows older
  than 12 months").
- Deleting all of a user's feedback when they delete their account. The
  `on delete cascade` on `user_feedback.user_id` handles this when the
  host app deletes the auth user.

`device_info` is auto-captured by `DeviceInfoService` and includes the OS
build, model, and on iOS the **user-set device name** (commonly contains the
owner's first name). The engine's `scrubDeviceInfoForPersistence` strips
`device_name`/`name` before insert, so what lands in the DB is the
deterministic-property subset only.

Screenshots are uploaded to a `public = true` bucket so they render via
plain `getPublicUrl`. The Storage RLS policies still gate writes/reads to
`<user_id>/…` paths, and the URL only lives inside `user_feedback.screenshot_urls`
(itself RLS-gated). If your host app's screenshots ever start carrying
sensitive content, flip the bucket to private and mint signed URLs at
render time.

---

## 8 — Rollback

The forward migration is idempotent (`create … if not exists` / `add column
if not exists`). To roll back:

1. Run `supabase/migrations/down/20260614000100_feedback_engine_down.sql`
   via the Dashboard SQL Editor (service role).
2. Remove the `feedbackConfigProvider.overrideWithValue(...)` line from
   `main.dart` so the engine falls back to `FeedbackConfig.defaults()`.
3. Optionally remove the `/feedback` and `/feedback/history` routes.

The down-migration **drops the table and every screenshot**. Take a backup
first if the data is wanted for analytics.

---

## 9 — Architecture overview

```
┌────────────────────────────────────────────────────────────┐
│  Flutter App                                               │
│                                                            │
│  FeedbackScreen ──watches── feedbackConfigProvider         │
│        │                                                   │
│        ├─ reads ─ feedbackControllerProvider(userId)       │
│        │           │                                       │
│        │           ├─ FeedbackRepository (insert/read)     │
│        │           └─ FeedbackScreenshotUploader           │
│        │                       │                           │
│        │                       └─► Supabase Storage        │
│        │                            feedback-screenshots/  │
│        │                                                   │
│  FeedbackHistoryScreen ──reads── same controller           │
└──────────────────────────┬─────────────────────────────────┘
                           │ Supabase client (with auth JWT)
                           ▼
                    user_feedback
                    (RLS: own-user select/insert)
```
