# Survey Engine — Integration Guide

A plug-and-play feature-survey engine for Flutter + Supabase.

Copy `lib/core/config/survey/` and `supabase/migrations/*_survey_engine.sql`
into any new project and follow this guide to go from zero to working in
under thirty minutes.

---

## What you get out of the box

| Feature | Details |
|---------|---------|
| 👍/👎 sentiment per feature | One row per `(user_id, feature_key)`, upsert-based |
| Optimistic UI | Chip flips immediately; submit batches writes |
| Completion threshold | "Survey complete" once N of M features rated |
| Per-app feature list | Driven entirely by `SurveyConfig` — no source edits |
| Per-app copy | Headline, intro, banner, submit labels all configurable |
| Submit callback | Hook for analytics or post-submit navigation |
| RLS-secured table | Users can only read/write their own responses |

---

## Prerequisites

| Dependency | Version | Notes |
|-----------|---------|-------|
| `flutter_riverpod` | ^2.x | State management |
| `supabase_flutter` | ^2.x | Backend |
| `equatable` | ^2.x | Value-equality on entities |

---

## 1 — Database setup

Run the migration once against your Supabase project:

```bash
supabase db push
# or paste supabase/migrations/20260614000000_survey_engine.sql
# into Dashboard → SQL Editor → Run
```

The migration creates one table with RLS:

| Table | Purpose |
|-------|---------|
| `feature_survey_responses` | `(user_id, feature_key) → sentiment` |

RLS policies allow each user to `select`, `insert`, and `update` only their
own rows. No `delete` — responses are upsert-only from the client.

---

## 2 — Flutter wiring

### 2a. Define your feature list

Create or edit `lib/core/config/survey/config/feature/survey_config.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:your_app/core/config/survey/config/survey_config.dart';

SurveyConfig buildMyAppSurveyConfig() {
  return const SurveyConfig(
    appName: 'My App',
    features: [
      SurveyFeature(
        key: 'onboarding',                      // STABLE — never rename
        title: 'Onboarding',
        description: 'The first-run tutorial',
        icon: Icons.flag,
      ),
      SurveyFeature(
        key: 'search',
        title: 'Search',
        description: 'Finding what you need',
        icon: Icons.search,
      ),
      // ...
    ],
  );
}
```

> **Don't rename `key` after shipping.** It's the join key for stored
> responses; renaming orphans every existing row.

### 2b. Override the provider in `main.dart`

```dart
import 'package:your_app/core/config/survey/config/survey_config.dart';
import 'package:your_app/core/config/survey/config/feature/survey_config.dart';

ProviderScope(
  overrides: [
    surveyConfigProvider.overrideWithValue(buildMyAppSurveyConfig()),
  ],
  child: MyApp(),
)
```

### 2c. Add the survey route to your router

```dart
GoRoute(
  path: '/featureSurvey',
  builder: (_, __) => const FeatureSurveyScreen(),
),
```

### 2d. Open the screen from wherever makes sense

```dart
context.go('/featureSurvey');
```

Common entry points: settings menu, post-onboarding nudge, post-major-update
banner. For an unobtrusive prompt, only show the entry point when
`hasCompletedSurveyProvider` is false (you can derive that from
`surveyControllerProvider(userId).select((s) => !s.hasCompleted)`).

---

## 3 — Customising copy and behaviour

Every visible string and behavioural knob is on `SurveyConfig`:

```dart
SurveyConfig(
  appName: 'My App',
  features: [...],
  headline: 'Quick poll',
  intro: 'Two taps. We swear.',
  submitLabel: 'Submit',
  updateLabel: 'Update',
  thanksMessage: 'Thanks!',
  completionThreshold: 3,                // override default of 2/3 of list
  onSubmitted: (context, responses) {
    // responses is Map<featureKey, 'like'|'dislike'>
    analytics.track('survey_submitted', properties: responses);
  },
)
```

---

## 4 — Reading responses

The controller exposes the live response map:

```dart
final responses = ref.watch(
  surveyControllerProvider(userId).select((s) => s.responses),
);
// {'onboarding': Sentiment.like, 'search': Sentiment.dislike, ...}
```

For analytics aggregation, query Supabase directly:

```sql
select feature_key,
       count(*) filter (where sentiment = 'like')    as likes,
       count(*) filter (where sentiment = 'dislike') as dislikes
from   feature_survey_responses
group  by feature_key
order  by likes desc;
```

---

## 5 — Files to change per app

| File | What to change |
|------|---------------|
| `config/feature/survey_config.dart` | Feature list + per-app copy |
| `main.dart` | `surveyConfigProvider.overrideWithValue(...)` |
| Router | Add the `/featureSurvey` route |

Everything else inside `core/config/survey/` is generic and can be copied
unchanged.

---

## 6 — Failure modes & runbook

The engine maps every failure to a typed `SurveyException` subclass and a
user-friendly message. Use this table when triaging reports.

| Exception | When it fires | User sees | Retry safe? | Operator action |
|-----------|--------------|-----------|-------------|------------------|
| `SurveyAuthException` | JWT expired or RLS denied auth.uid() check | "Please log in to submit feedback." | ❌ | Force re-auth; check Supabase Auth dashboard for session anomalies |
| `SurveyValidationException` | featureKey fails length / `^[a-z0-9_]+$` check, or batch > 64 rows | "Some of your feedback is invalid…" | ❌ | Bug in config — audit `SurveyConfig.features[*].key` for new entries |
| `SurveyTimeoutException` | One upsert exceeded 15s × 3 attempts | "The network is slow. Tap Try again…" | ✅ | Check Supabase status page and project quota; nothing to do if isolated |
| `SurveyDatabaseException` | PostgreSQL CHECK / FK / RLS / 5xx after retries | "Unable to save your feedback…" | ✅ for 5xx, ❌ for CHECK/RLS — both surfaced as retryable to the user, but the second won't help | Inspect Sentry breadcrumb `survey.upsert.failed` for the `code` attribute |
| `SurveyException` (base) | Anything not caught above | "Something went wrong…" | ✅ | Always indicates a missing exception mapping — file a bug |

**Observability events** (fired on every action):

| Event | Attributes | Trigger |
|-------|-----------|---------|
| `survey_loaded` | `response_count` | Successful `loadResponses()` |
| `survey_load_failed` | `category` ∈ {auth, validation, timeout, database, unknown} | Load threw |
| `survey_submit_started` | `response_count` | `submitAllResponses()` begins |
| `survey_submitted` | `response_count`, `likes`, `dislikes` | Batch upsert succeeded |
| `survey_submit_failed` | `category` | Batch upsert threw |

Wire the host app's analytics by passing `SurveyConfig.onEvent`:

```dart
SurveyConfig(
  features: [...],
  onEvent: (event, attrs) => Analytics.track(event, properties: attrs),
)
```

Wire error tracking once at app bootstrap:

```dart
SurveyLogger.setSink((level, msg, {error, stack, attributes}) {
  if (level == SurveyLogLevel.error) {
    Sentry.captureException(error ?? msg, stackTrace: stack);
  }
});
```

### Alert thresholds (suggested)

| Condition | Window | Threshold | Action |
|-----------|--------|-----------|--------|
| `survey_submit_failed` rate | 5 min | > 5% of `survey_submit_started` | Page on-call; check Supabase dashboard |
| `category=auth` share | 15 min | > 30% of failures | Look for a JWT/refresh regression in the auth provider |
| `category=database` share | 15 min | > 30% of failures | Look for a recent migration or RLS-policy change |

---

## 7 — Rollback

The forward migration is idempotent (`create … if not exists`). To roll back:

1. Run `supabase/migrations/down/20260614000000_survey_engine_down.sql` via the
   Dashboard SQL Editor (service role).
2. Remove the `surveyConfigProvider.overrideWithValue(...)` line from
   `main.dart` so the engine falls back to its `SurveyConfig.defaults()`
   (empty feature list — screen renders blank but does not crash).
3. Optionally remove the `/featureSurvey` route.

The down-migration **drops the table and all responses**. Take a backup of
`feature_survey_responses` first if the data is wanted for analytics.

---

## 8 — Architecture overview

```
┌────────────────────────────────────────────────────────────┐
│  Flutter App                                               │
│                                                            │
│  FeatureSurveyScreen ──watches── surveyConfigProvider      │
│        │                                                   │
│        └── reads ── surveyControllerProvider(userId)       │
│                          │                                 │
│                          └── SurveyRepository              │
└──────────────────────────┬─────────────────────────────────┘
                           │ Supabase client (with auth JWT)
                           ▼
                feature_survey_responses
                (RLS: own-user select/upsert)
```
