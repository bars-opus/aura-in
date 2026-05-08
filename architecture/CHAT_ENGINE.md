# Chat Engine — Integration Guide

A plug-and-play real-time chat engine for Flutter + Sendbird + Supabase.

Copy `lib/presentation/features/chat/` into any new project and follow this guide to go from zero to working chat in under an hour.

---

## What you get out of the box

| Feature | Details |
|---------|---------|
| Real-time messaging | Sendbird channel event handlers with StreamControllers |
| Conversation list | Live-updating channel list with unread badges |
| Typing indicators | Per-channel typing status with animated dots |
| File/image messages | Camera, gallery, and document sending |
| Message actions | Long-press delete and edit with optimistic UI |
| Group chat creation | Multi-user channel creation screen |
| Pagination | Infinite scroll with timestamp-cursor pagination |
| Secure auth | Supabase Edge Function issues Sendbird session tokens |
| Config-driven UI | Custom app bar, custom list items — no source edits needed |

---

## Prerequisites

| Dependency | Version | Notes |
|-----------|---------|-------|
| `flutter_riverpod` | ^2.x | State management |
| `supabase_flutter` | ^2.x | Auth + Edge Functions |
| `sendbird_sdk` | ^3.2.20 | Chat SDK |

---

## 1 — Sendbird project setup

1. Create an application at [dashboard.sendbird.com](https://dashboard.sendbird.com).
2. Copy the **Application ID** from Settings → Application → Application ID.
3. Add to your `.env.json`:

```json
{
  "SENDBIRD_APP_ID": "your-sendbird-app-id"
}
```

Run with:
```bash
flutter run --dart-define-from-file=.env.json
```

---

## 2 — Supabase Edge Function (session tokens)

Deploy the `sendbird-auth` function so the SDK connects with a signed session token:

```bash
supabase functions deploy sendbird-auth
```

Set secrets (Dashboard → Settings → Edge Functions):

```
SENDBIRD_APP_ID          # Your Sendbird application ID
SENDBIRD_MASTER_API_TOKEN  # Sendbird → Settings → API → Chat API token
```

### Edge Function source

```typescript
// supabase/functions/sendbird-auth/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const authHeader = req.headers.get('Authorization')!
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    { global: { headers: { Authorization: authHeader } } }
  )

  const { data: { user }, error } = await supabase.auth.getUser()
  if (error || !user) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 })
  }

  const appId = Deno.env.get('SENDBIRD_APP_ID')!
  const masterToken = Deno.env.get('SENDBIRD_MASTER_API_TOKEN')!

  // Create or update the Sendbird user
  await fetch(`https://api-${appId}.sendbird.com/v3/users`, {
    method: 'POST',
    headers: {
      'Api-Token': masterToken,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      user_id: user.id,
      nickname: user.email ?? user.id,
      upsert: true,
    }),
  })

  // Issue a session token
  const tokenRes = await fetch(
    `https://api-${appId}.sendbird.com/v3/users/${user.id}/token`,
    {
      method: 'POST',
      headers: {
        'Api-Token': masterToken,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ expires_at: 0 }),
    }
  )

  const { token } = await tokenRes.json()
  return new Response(JSON.stringify({ token }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

---

## 3 — Flutter wiring

### 3a. Wire the config in `main.dart`

```dart
import 'package:your_app/presentation/features/chat/config/chat_config.dart';

// Inside ProviderScope overrides:
chatConfigProvider.overrideWithValue(
  ChatConfig(
    appId: Environment.sendbirdAppId,

    // Optional: override the screen title (defaults to 'Chat')
    conversationsTitle: 'Messages',

    // Optional: replace the default name + avatar header with your own widget.
    // Return null to keep the built-in header.
    chatAppBarTitle: (conversation, context) => MyProfileHeader(
      name: conversation.name,
      avatarUrl: conversation.avatarUrl,
    ),

    // Optional: replace the built-in list tile with your own design.
    conversationItemBuilder: (conversation, onTap, context) =>
        MyConversationTile(conversation: conversation, onTap: onTap),
  ),
),
```

### 3b. Add screens to your router

```dart
GoRoute(
  path: '/chat',
  builder: (_, __) => ConversationsScreen(currentUserId: userId),
),
GoRoute(
  path: '/chat/:channelUrl',
  builder: (_, state) => ChatScreen(
    conversation: state.extra as Conversation,
  ),
),
```

### 3c. Connect on login

The engine auto-connects using the authenticated Supabase user ID. Just make sure `currentUserProvider` is available (it reads from `supabaseClientProvider`). No extra wiring needed.

### 3d. Disconnect on logout

```dart
ref.read(connectionProvider.notifier).disconnect();
```

### 3e. Show unread badge on a tab

```dart
final unreadCount = ref.watch(unreadCountProvider);
unreadCount.when(
  data: (count) => Badge(label: Text('$count'), child: Icon(Icons.chat)),
  loading: () => Icon(Icons.chat),
  error: (_, __) => Icon(Icons.chat),
);
```

---

## 4 — Creating channels

### Direct message (1-to-1)

```dart
final repo = ref.read(chatRepositoryProvider);
final conversation = await repo.createChannel(
  name: 'Alice & Bob',
  userIds: [currentUserId, otherUserId],
  isDistinct: true,   // one channel per pair
);
```

### Group chat

Use the built-in `GroupChatCreationScreen`, which lets users search by Supabase profile and select multiple members.

---

## 5 — Sending push notifications for new messages

Wire Sendbird webhooks → your push endpoint (OneSignal or FCM):

1. Sendbird Dashboard → Settings → Notifications → Webhooks.
2. Add your Supabase Edge Function URL as the webhook endpoint.
3. In the webhook handler, call `send-onesignal-push` (from the Notification Engine) with `type: 'new_message'`.

See `NOTIFICATION_ENGINE.md` for the push delivery infrastructure.

---

## 6 — Customising the UI

### Custom app bar

```dart
ChatConfig(
  appId: '...',
  chatAppBarTitle: (conversation, context) {
    return Row(
      children: [
        NetworkAvatar(url: conversation.avatarUrl),
        const SizedBox(width: 8),
        Column(children: [
          Text(conversation.name),
          OnlineStatusDot(userId: conversation.id),
        ]),
      ],
    );
  },
)
```

### Custom conversation list tile

```dart
ChatConfig(
  appId: '...',
  conversationItemBuilder: (conversation, onTap, context) {
    return MyListTile(
      title: conversation.name,
      subtitle: conversation.lastMessage?.content,
      badge: conversation.unreadCount,
      onTap: onTap,
    );
  },
)
```

---

## 7 — Files to change per app

When porting to a new project, **only these files need editing**:

| File | What to change |
|------|---------------|
| `main.dart` | Add `chatConfigProvider.overrideWithValue(ChatConfig(appId: '...'))` |
| `.env.json` | `SENDBIRD_APP_ID` |
| Supabase secrets | `SENDBIRD_APP_ID`, `SENDBIRD_MASTER_API_TOKEN` |

Everything inside `presentation/features/chat/` except the config wiring is generic and can be copied unchanged.

---

## 8 — Architecture overview

```
┌─────────────────────────────────────────────────────────────┐
│  Flutter App                                                │
│                                                             │
│  ConversationsScreen ──► ChatScreen                         │
│  GroupChatCreationScreen                                    │
│  (all driven by ChatConfig callbacks)                       │
│                         │                                   │
│  Riverpod Providers      │                                   │
│  ├─ chatRepositoryProvider (Provider)                       │
│  ├─ connectionProvider (StateNotifier<bool>)                │
│  ├─ conversationsProvider (StreamProvider)                  │
│  ├─ messagesProvider.family (StreamProvider)                │
│  ├─ typingUsersProvider.family (StreamProvider)             │
│  ├─ unreadCountProvider (StreamProvider)                    │
│  └─ chatControllerProvider.family (StateNotifier)           │
└──────────────────────┬──────────────────────────────────────┘
                       │ Sendbird SDK
          ┌────────────┼─────────────────────────┐
          │            │                         │
   GroupChannel    ChannelEventHandler    ConnectionEventHandler
   (messages)      (real-time events)     (connect/disconnect)
          │
          └─► Supabase Edge Function (sendbird-auth)
                    │
                    └─► Sendbird REST API ──► Session token
```

### Key classes

| Class | Role |
|-------|------|
| `ChatConfig` | Injectable config — app ID, UI builders, title |
| `ChatRepository` | Abstract interface for all Sendbird operations |
| `SendbirdChatRepository` | Concrete implementation using SDK 3.2.20 |
| `ConnectionNotifier` | Manages connect/disconnect lifecycle |
| `ChatController` | Per-channel state: messages, typing, send, edit, delete |
| `ChatState` | Immutable value object for a single channel's UI state |
