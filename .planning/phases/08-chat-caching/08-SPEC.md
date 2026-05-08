# Phase 8: Chat Caching — Specification

**Created:** 2026-05-08
**Ambiguity score:** 0.161 (gate: ≤ 0.20) ✓
**Requirements:** 9 locked

## Goal

Opening ConversationsScreen and ChatScreen shows cached content instantly (< 100 ms) with no loading spinner for previously-seen data, while a silent background fetch keeps content fresh — matching standard WhatsApp-class chat UX.

## Background

Currently both screens show a `CircularLoadingIndicator` on every open:

- **ConversationsScreen**: `conversationsProvider` is a `StreamProvider` that uses `async*`. When `connectionProvider` fires (Sendbird connects or reconnects), the generator restarts, re-entering loading state.
- **ChatScreen**: `chatControllerProvider` is `StateNotifierProvider.autoDispose.family`. The `autoDispose` tears down the notifier when the user navigates away, so returning to a conversation fetches all 50 messages from Sendbird again, showing a spinner.

Neither screen has any persistent local cache. `Message` and `Conversation` already have `toJson`/`fromJson`. Hive is initialized in `main.dart` (`Hive.initFlutter()`) and used by `LocalDraftStorage` — the pattern is established but not applied to chat.

`flutter_secure_storage` is **not** in `pubspec.yaml`. It must be added to generate and persist the Hive encryption key on the platform keychain (iOS Keychain / Android Keystore).

## Requirements

### Layer 1 — In-memory keepAlive

1. **chatControllerProvider keepAlive**: The chat controller for a channel stays alive in memory for 5 minutes after the last subscriber leaves.
   - Current: `StateNotifierProvider.autoDispose.family` — disposes immediately when `ChatScreen` pops.
   - Target: `ref.keepAlive()` with a `Timer(Duration(minutes: 5), link.close)` pattern. Re-opening the same channel within 5 minutes skips `_init()` entirely (state already loaded).
   - Acceptance: Navigate to channel A → navigate away → navigate back within 5 min → **no** loading spinner appears and message count in state equals the count from first open without any Sendbird fetch.

2. **conversationsProvider no-flash on reconnect**: `ConversationsScreen` never shows the loading indicator when Sendbird reconnects during an active session.
   - Current: `async*` restarts when `connectionProvider` changes → `AsyncLoading` emitted → spinner shown.
   - Target: Decouple refresh from loading state. When already-loaded conversations exist, a reconnect triggers a silent background refresh that updates the list without resetting to `AsyncLoading`.
   - Acceptance: With conversations loaded, simulate Sendbird reconnect → screen does **not** show spinner; existing conversation tiles remain visible throughout.

### Layer 2 — Hive persistent cache

3. **flutter_secure_storage dependency**: Package added and an encryption key generated on first run, stored in platform secure storage, and reused on subsequent runs.
   - Current: `pubspec.yaml` has no `flutter_secure_storage` entry.
   - Target: `pubspec.yaml` contains `flutter_secure_storage: ^9.0.0` (or latest compatible). `ChatCacheService` calls `_secureStorage.read(key: 'hive_chat_key')` on init; generates a 32-byte random key if absent and writes it back.
   - Acceptance: Uninstalling and reinstalling the app (which clears Keychain on iOS simulator unless keychain is shared) generates a new key without crash; an existing key is reused correctly across hot restarts.

4. **ChatCacheService**: A single service class that owns all Hive box lifecycle for chat data.
   - Current: No `ChatCacheService` exists in the codebase.
   - Target: `lib/presentation/features/chat/data/cache/chat_cache_service.dart` provides:
     - `Future<void> init()` — opens encrypted boxes; called from `main.dart` before `runApp`.
     - `List<Message> readMessages(String channelUrl)` — synchronous; returns `[]` if nothing cached.
     - `Future<void> writeMessages(String channelUrl, List<Message> messages)` — persists last 50 messages.
     - `List<Conversation> readConversations()` — synchronous; returns `[]` if nothing cached.
     - `Future<void> writeConversations(List<Conversation> conversations)` — persists full list.
     - `Future<void> clearAll()` — deletes all chat cache entries (called on logout).
   - Acceptance: Unit test: write 60 messages → `readMessages` returns exactly 50 (newest 50). Write conversations → `readConversations` returns same list. `clearAll` → both return `[]`.

5. **Messages cold-start cache**: Opening a channel for the first time in a session shows cached messages immediately with no spinner.
   - Current: `ChatController._init()` calls `loadMessages()` which sets `isLoading: true` then fetches from Sendbird — always a spinner.
   - Target: `ChatController._init()` reads from `ChatCacheService.readMessages(channelUrl)` first. If the cache is non-empty, sets `state.messages` to the cached list with `isLoading: false` before the Sendbird fetch begins. Sendbird fetch runs concurrently and replaces the list silently when complete.
   - Acceptance: With messages cached in Hive, open `ChatScreen` → message list is visible **before** Sendbird responds (verifiable with network throttling or by inspecting state in the first frame after mount).

6. **Messages cache write-through**: Every successful Sendbird message fetch updates the Hive cache.
   - Current: No cache write occurs after `getMessages`.
   - Target: After `ChatController.loadMessages()` completes successfully, call `ChatCacheService.writeMessages(channelUrl, messages)`. After `_subscribeToMessages` updates state (stream), also write the new list to cache.
   - Acceptance: Load messages, kill app, reopen — `readMessages` returns the messages that were loaded in the previous session (content and count match).

7. **Conversations cold-start cache**: Opening `ConversationsScreen` shows a cached conversation list immediately.
   - Current: `conversationsProvider` emits `AsyncLoading` until `repository.getChannels()` returns.
   - Target: `conversationsProvider` emits the cached list synchronously as its first value (no loading state), then silently overwrites with the Sendbird result. If cache is empty, existing `AsyncLoading` behavior is preserved.
   - Acceptance: With conversations cached, open `ConversationsScreen` → conversation tiles are visible in the first frame (no spinner); title and last-message text match the previous session's data.

8. **Conversations cache write-through**: Every successful `getChannels` result updates the Hive cache.
   - Current: No cache write after `getChannels`.
   - Target: After `conversationsProvider` emits a non-empty list from Sendbird, call `ChatCacheService.writeConversations(conversations)`.
   - Acceptance: After conversations load from Sendbird, restart app → `ConversationsScreen` shows conversation list immediately without spinner.

9. **Cache cleared on logout**: All Hive chat cache is wiped when the authenticated user signs out.
   - Current: No logout hook exists for chat cache; stale data would persist between user sessions.
   - Target: The auth sign-out flow (wherever `supabase.auth.signOut()` is called) invokes `ChatCacheService.clearAll()` before or after the Supabase call.
   - Acceptance: Sign in as User A, load conversations, sign out, sign in as User B — `ConversationsScreen` shows no cached data from User A's session.

## Boundaries

**In scope:**
- `ChatCacheService` — new service with encrypted Hive boxes for messages and conversations
- `flutter_secure_storage` — dependency addition for encryption key storage
- Layer 1 keepAlive — `chatControllerProvider` timed in-memory retention (5 min)
- Layer 1 reconnect fix — `conversationsProvider` silent refresh without `AsyncLoading`
- Write-through on `loadMessages` and `getChannels`
- Cache-first init in `ChatController._init()`
- Cache-first emit in `conversationsProvider`
- `clearAll()` called on logout

**Out of scope:**
- Hive TypeAdapters or code-generation — JSON strings via `toJson/fromJson` are sufficient for this volume; TypeAdapters are a premature optimization at this stage
- Offline send queue — messages typed while offline are not queued; out of scope for this phase
- Message search over the local cache — Sendbird Platform API search is the right tool; local full-text search is a separate phase
- Group channel cache — DM channels only until group chat is formally built out; caching group channels adds complexity without confirmed user need
- Image/file attachment caching — `CachedNetworkImage` (already added) handles this; no additional Hive storage for binary blobs
- Cache versioning / migration — the cache is disposable; schema changes can clear the box; formal migration not needed at this scale
- Background sync / push-triggered cache refresh — out of scope; cache updates only on foreground interaction

## Constraints

- **Cache read must be synchronous** — `readMessages` and `readConversations` must return without `await` so the first frame renders cached content immediately. Hive box reads are synchronous once the box is open.
- **Cache size limit** — store at most 50 messages per channel. Exceeding 50 drops oldest messages. No limit on conversation count (typically < 50 for service-marketplace users).
- **Encryption mandatory** — Hive box must be opened with `HiveAesCipher` using a 32-byte key from `flutter_secure_storage`. Plain `Hive.openBox()` is not acceptable for chat message storage.
- **Key rotation not required** — same key for the lifetime of the install. If the key is lost (e.g. app uninstall on Android without backup), the cache is simply regenerated from Sendbird.
- **No new Hive TypeAdapters** — serialization via `toJson/fromJson` only; no `build_runner` steps added to CI.
- **keepAlive duration is 5 minutes** — not configurable; matches typical return-to-conversation behavior.
- **Dart/Flutter**: project is already Flutter 3.x; no version constraint changes required for `flutter_secure_storage ^9.0.0`.

## Acceptance Criteria

- [ ] `ConversationsScreen` shows conversation tiles with no spinner on second open (cache hit) within the same session
- [ ] `ConversationsScreen` shows conversation tiles with no spinner on first open after app restart (Hive cache hit from previous session)
- [ ] `ChatScreen` shows message list with no spinner when returning to a channel within 5 minutes (keepAlive hit)
- [ ] `ChatScreen` shows message list with no spinner on first open after app restart (Hive cache hit)
- [ ] `ChatScreen` shows spinner only when opening a channel with no cache AND keepAlive has expired (cold start, no prior data)
- [ ] Sendbird reconnect does not trigger spinner in `ConversationsScreen`; existing tiles remain visible
- [ ] `ChatCacheService.readMessages(channelUrl)` returns at most 50 messages regardless of how many were written
- [ ] Hive chat box is opened with `HiveAesCipher`; opening the `.hive` file with a plain box throws (confirming encryption)
- [ ] Sign out clears cache; the next user session starts with no stale data from the previous user
- [ ] No `flutter_secure_storage` key is hardcoded anywhere in source — key is generated at runtime

## Ambiguity Report

| Dimension           | Score | Min  | Status | Notes                                               |
|---------------------|-------|------|--------|-----------------------------------------------------|
| Goal Clarity        | 0.92  | 0.75 | ✓      | Specific measurable target: < 100 ms, no spinner    |
| Boundary Clarity    | 0.85  | 0.70 | ✓      | Explicit out-of-scope list with reasoning           |
| Constraint Clarity  | 0.72  | 0.65 | ✓      | 50-msg cap, 5-min TTL, encryption key locked        |
| Acceptance Criteria | 0.80  | 0.70 | ✓      | 10 pass/fail checkboxes                             |
| **Ambiguity**       | 0.161 | ≤0.20| ✓      |                                                     |

## Interview Log

Context was gathered from a live coding session rather than a structured interview. Decisions recorded below.

| Round | Perspective      | Question summary                                 | Decision locked                                                    |
|-------|------------------|--------------------------------------------------|--------------------------------------------------------------------|
| 1     | Researcher       | What causes the spinner today?                   | autoDispose on chatControllerProvider + async* restart in convProv |
| 1     | Researcher       | What serialization exists?                       | Message.toJson/fromJson + Conversation.toJson/fromJson both exist  |
| 2     | Simplifier       | Minimum viable cache?                            | Layer 1 keepAlive (in-memory) + Layer 2 Hive (persistent)         |
| 2     | Simplifier       | Should we do group channels?                     | DM only — group chat not built out yet                            |
| 3     | Boundary Keeper  | TypeAdapters or JSON strings?                    | JSON strings — TypeAdapters are premature optimization            |
| 3     | Boundary Keeper  | Encryption required?                             | Yes — chat messages are sensitive; HiveAesCipher mandatory        |
| 3     | Boundary Keeper  | Where to store the Hive key?                     | flutter_secure_storage — platform keychain/keystore               |
| 4     | Failure Analyst  | What if key is lost on reinstall?                | Acceptable — cache regenerates from Sendbird; no key rotation     |
| 4     | Failure Analyst  | What if user signs in on shared device?          | clearAll() on logout prevents cross-session data leak             |
| 4     | Failure Analyst  | Offline write queue?                             | Out of scope — complexity not justified at current scale          |

---

*Phase: 08-chat-caching*
*Spec created: 2026-05-08*
*Next step: /gsd-discuss-phase 8 — implementation decisions (box naming, provider structure, init ordering)*
