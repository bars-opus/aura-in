



## 🎯 Overview

The Chat System enables real-time communication between customers and shop owners using Sendbird SDK. It includes one-on-one and group channels, typing indicators, read receipts, message status tracking (sending/sent/delivered/read), file attachments (images, documents), and unread message counts. The system uses Riverpod for state management and a repository pattern to abstract Sendbird-specific implementation.

**Dependencies**: Phase 0 (Foundation), Phase 1 (Shop Management), Phase 3 (Booking System)

## 🏗️ Core Decisions

### 1. Chat SDK: Sendbird

**Decision**: Sendbird SDK v3.2.20 for real-time chat

**Why**:

- Enterprise-grade reliability and scalability
- Built-in real-time features (typing indicators, read receipts)
- Comprehensive Flutter SDK support
- No backend infrastructure to maintain
- GDPR compliant with regional data centers

### 2. Repository Pattern for Chat

**Decision**: Abstract repository interface with Sendbird implementation

**Why**:

- Clean separation of concerns
- Easy to swap implementations (test vs production)
- Consistent API across platforms
- Testable with mock repositories

### 3. Stream-Based Real-Time Updates

**Decision**: Dart Streams for real-time events

**Why**:

- Built-in to Dart language
- Perfect for continuous data flow
- Easy integration with Riverpod
- Efficient resource management

### 4. Platform-Native API Key Security

**Decision**: Environment variables with separate dev/prod files

**Why**:

- Keys never hardcoded in source code
- Different keys for development/production
- Git-ignored for security
- Easy rotation without code changes

### 5. Channel-Based Conversations

**Decision**: Each booking has a dedicated chat channel

**Why**:

- Contextual communication tied to specific booking
- Automatic channel creation on first message
- Easy for both parties to reference booking details
- Prevents cross-booking confusion

## 📊 Data Models

**Location**: `lib/features/chat/data/models/`

| Model                      | Purpose                                                              |
| -------------------------- | -------------------------------------------------------------------- |
| `conversation.dart`        | UI-friendly channel model with unread count, last message, timestamp |
| `message.dart`             | UI-friendly message with status (sending/sent/delivered/read)        |
| `sendbird/sb_channel.dart` | Sendbird GroupChannel wrapper                                        |
| `sendbird/sb_message.dart` | Sendbird UserMessage/FileMessage/AdminMessage wrapper                |
| `sendbird/sb_user.dart`    | Sendbird User wrapper                                                |
| `sendbird/sb_types.dart`   | Sendbird enums (ChannelType, MessageType, etc.)                      |

## 🔌 Sendbird Configuration

### Environment Variables

**Location**: `assets/env/.env.development` and `assets/env/.env.production`

```env
SENDBIRD_APP_ID=your-sendbird-app-id
```

### Sendbird Initialization

**Location**: Integrated in `lib/main.dart` after Supabase initialization

| Step | Purpose                                              |
| ---- | ---------------------------------------------------- |
| 1    | `SendbirdSdk.init(appId: Environment.sendbirdAppId)` |
| 2    | Configure log level based on DEBUG flag              |
| 3    | Set up connection state listener                     |
| 4    | Store SDK instance in provider for global access     |

## 📂 Repository Layer

### Chat Repository Interface

**Location**: `lib/features/chat/domain/repositories/chat_repository.dart`

| Method               | Purpose                                                    |
| -------------------- | ---------------------------------------------------------- |
| `connect()`          | Authenticate user with Sendbird using user ID and nickname |
| `disconnect()`       | Disconnect from Sendbird                                   |
| `isConnected()`      | Check current connection status                            |
| `getChannels()`      | Fetch list of chat channels for current user               |
| `watchChannels()`    | Stream of channel list updates                             |
| `createChannel()`    | Create new group channel (for booking)                     |
| `joinChannel()`      | Join existing channel                                      |
| `leaveChannel()`     | Leave channel                                              |
| `getMessages()`      | Fetch paginated message history for channel                |
| `watchMessages()`    | Stream of new messages for channel                         |
| `sendTextMessage()`  | Send text message to channel                               |
| `sendFileMessage()`  | Send image/document file to channel                        |
| `deleteMessage()`    | Delete message (with permission check)                     |
| `startTyping()`      | Send typing indicator to channel                           |
| `endTyping()`        | End typing indicator                                       |
| `watchTypingUsers()` | Stream of users currently typing                           |
| `markAsRead()`       | Mark channel as read (clears unread count)                 |
| `watchUnreadCount()` | Stream of total unread message count                       |
| `getUnreadCount()`   | Get total unread message count                             |

## 🧠 State Management

### Chat Providers

**Location**: `lib/features/chat/presentation/state/chat_providers.dart`

| Provider                 | Type                  | Purpose                                   |
| ------------------------ | --------------------- | ----------------------------------------- |
| `chatRepositoryProvider` | Provider              | Singleton repository instance             |
| `connectionProvider`     | StreamProvider        | Real-time connection state                |
| `conversationsProvider`  | StreamProvider        | List of chat channels                     |
| `messagesProvider`       | StreamProvider.family | Messages for specific channel             |
| `typingUsersProvider`    | StreamProvider.family | Users typing in specific channel          |
| `unreadCountProvider`    | StreamProvider        | Total unread messages across all channels |
| `chatControllerProvider` | StateNotifierProvider | Chat operations controller                |

### Chat Controller

**Location**: `lib/features/chat/presentation/state/chat_controller.dart`

| State Property   | Type          | Purpose                                |
| ---------------- | ------------- | -------------------------------------- |
| `currentChannel` | SBChannel     | Currently active channel               |
| `messages`       | List<Message> | Current message list                   |
| `isLoading`      | bool          | Loading state indicator                |
| `hasMore`        | bool          | More messages available for pagination |
| `nextCursor`     | String?       | Pagination cursor                      |
| `isSending`      | bool          | Message in progress                    |
| `error`          | String?       | Error message if operation fails       |

| Method                | Purpose                                   |
| --------------------- | ----------------------------------------- |
| `connectUser()`       | Authenticate and connect to Sendbird      |
| `disconnectUser()`    | Disconnect from Sendbird                  |
| `selectChannel()`     | Set current active channel, load messages |
| `loadMessages()`      | Fetch message history with pagination     |
| `sendMessage()`       | Send text or file message                 |
| `deleteMessage()`     | Delete user's own message                 |
| `markChannelAsRead()` | Mark current channel as read              |
| `sendTypingStatus()`  | Send typing indicator (with debounce)     |

## 🎨 UI Components (Paths Only)

### Chat Screens

| Screen                | Path                                                               | Purpose                                      |
| --------------------- | ------------------------------------------------------------------ | -------------------------------------------- |
| `ChatHomeScreen`      | `lib/features/chat/presentation/screens/chat_home_screen.dart`     | Connection management and navigation hub     |
| `ConversationsScreen` | `lib/features/chat/presentation/screens/conversations_screen.dart` | List of all chat channels with unread badges |
| `ChatScreen`          | `lib/features/chat/presentation/screens/chat_screen.dart`          | Message interface for specific channel       |

### Chat Widgets

| Widget                | Path                                                                | Purpose                                           |
| --------------------- | ------------------------------------------------------------------- | ------------------------------------------------- |
| `MessageBubble`       | `lib/features/chat/presentation/widgets/message_bubble.dart`        | Individual message with avatar, text, status icon |
| `TypingIndicator`     | `lib/features/chat/presentation/widgets/typing_indicator.dart`      | Animated dots showing user is typing              |
| `MessageInputField`   | `lib/features/chat/presentation/widgets/message_input_field.dart`   | Text input with send button and attachment picker |
| `AttachmentPreview`   | `lib/features/chat/presentation/widgets/attachment_preview.dart`    | Image/document preview before sending             |
| `UnreadBadge`         | `lib/features/chat/presentation/widgets/unread_badge.dart`          | Red circle with unread count for channel list     |
| `ConnectionStatusBar` | `lib/features/chat/presentation/widgets/connection_status_bar.dart` | Banner showing connecting/connected/disconnected  |
| `ChannelAvatar`       | `lib/features/chat/presentation/widgets/channel_avatar.dart`        | Channel icon (shop logo or default)               |

## 🔄 Key Flows

### User Connection Flow

```
User logs into app (auth success)
        ↓
ChatHomeScreen loads → gets user ID and nickname from profile
        ↓
chatController.connectUser() called
        ↓
Repository calls SendbirdSdk.connect(userId, nickname)
        ↓
connectionProvider stream emits 'connected'
        ↓
ConversationsScreen automatically loads channels
        ↓
Unread badge shows total unread count
```

### Channel Creation Flow

```
Customer completes booking
        ↓
System checks if chat channel exists for booking
        ↓
If not exists → createChannel() called
        ↓
Repository creates Sendbird GroupChannel
        ↓
Channel name: "Booking #${bookingId} - ${shopName}"
        ↓
Both customer and shop owner automatically added as members
        ↓
UI shows "Chat" button in booking details
```

### Message Sending Flow

```
User types in MessageInputField
        ↓
onTextChanged triggers sendTypingStatus() (debounced 300ms)
        ↓
Repository calls startTyping() on channel
        ↓
Other users see TypingIndicator
        ↓
User presses send button
        ↓
sendMessage() called with text
        ↓
Repository calls sendTextMessage()
        ↓
Message appears with status "sending"
        ↓
Sendbird confirms delivery → status updates to "sent"
        ↓
Other user opens channel → status updates to "delivered"
        ↓
Other user reads message → status updates to "read"
        ↓
Message bubble shows read receipt checkmarks
```

### Unread Count Flow

```
User receives new message in background channel
        ↓
Sendbird sends unread count update
        ↓
watchUnreadCount() stream emits new total
        ↓
AppBar shows badge with unread count
        ↓
ConversationsScreen shows per-channel unread badges
        ↓
User opens channel → markChannelAsRead() called
        ↓
Repository calls markAsRead() on channel
        ↓
Unread count decreases
        ↓
Badge disappears from channel list
```

## 📦 Dependencies Added in Phase 8

```yaml
dependencies:
  sendbird_sdk: ^3.2.20
  image_picker: ^1.0.4
  file_picker: ^5.3.0
```

## 📁 Phase 8 Folder Structure

```
lib/features/chat/
├── data/
│   ├── models/
│   │   ├── sendbird/
│   │   │   ├── sb_channel.dart
│   │   │   ├── sb_message.dart
│   │   │   ├── sb_user.dart
│   │   │   └── sb_types.dart
│   │   ├── conversation.dart
│   │   └── message.dart
│   └── repositories/
│       └── sendbird_chat_repository.dart
├── domain/
│   ├── entities/
│   │   ├── conversation.dart
│   │   └── message.dart
│   └── repositories/
│       └── chat_repository.dart
└── presentation/
    ├── screens/
    │   ├── chat_home_screen.dart
    │   ├── conversations_screen.dart
    │   └── chat_screen.dart
    ├── state/
    │   ├── chat_providers.dart
    │   └── chat_controller.dart
    └── widgets/
        ├── message_bubble.dart
        ├── typing_indicator.dart
        ├── message_input_field.dart
        ├── attachment_preview.dart
        ├── unread_badge.dart
        ├── connection_status_bar.dart
        └── channel_avatar.dart
```

## ⏭️ Next Phase

**Phase 9: Complete Folder Structure**, which provides the full project tree from root to all files with purpose annotations.
