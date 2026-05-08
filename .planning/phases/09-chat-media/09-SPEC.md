# Phase 09 — Chat Media Improvements: SPEC

**Phase:** 09-chat-media  
**Status:** SPEC  
**Priority order:** F1 → F2 → F3 → F6 → F5 → F4  
**Spec date:** 2026-05-08

---

## Phase Goal

Harden the chat attachment system so that every file type sends correctly (MIME fix), large files are rejected gracefully, permission failures surface actionable UI, uploads show real progress, and two new sharing surfaces (own profile card, live location) are shipped as first-class chat messages.

---

## Context — Current State

| Area | Current state |
|------|---------------|
| MIME detection | `_mimeFromExtension` in `chat_text_field.dart:180` handles pdf/doc/xls/mp4/mp3/png/gif. Missing `jpg` and `jpeg` — file picker sends JPEG images with `application/octet-stream`. |
| File size | No size guard. Users can attempt to send arbitrarily large files; Sendbird SDK fails silently or times out. |
| Permission UX | `LocationService.requestLocationPermission()` returns `false` on `deniedForever` with no user feedback. Camera/gallery use `image_picker` which also surfaces no actionable UI on permanent denial. `permission_handler: ^11.0.0` is installed but unused in chat. |
| Upload progress | `ChatController.sendFileMessage` sets `isSending: true` then `false`; no intermediate state. Sendbird SDK 3.2.20 exposes `OnUploadProgressCallback` on `channel.sendFileMessage(params, progress, onCompleted)` but it is not wired. |
| Location sharing | `_handleLocationShare` in `chat_text_field.dart:165` is a stub (`Navigator.pop(context)` only). `LocationService.getCurrentLocationWithDetails()` and Mapbox token exist. |
| Profile sharing | `_handleContactShare` in `chat_text_field.dart:170` is a stub. `app_links: ^6.0.0` and `share_plus: ^7.0.0` are installed. No structured message format defined. |

---

## Out of Scope

- Contact picker (system address book sharing)  
- Video thumbnail generation  
- Multi-file upload  
- Message reactions or threads  
- Sendbird bot / push payload changes  
- `share_plus` native share sheet for sharing *out of* the app — profile is shared *into* a chat channel only  

---

## Features

### F1 — MIME Map Fix (jpg/jpeg)

**Priority:** 1 (fix first, no dependencies)

**What:** Add `jpg` and `jpeg` cases to `_mimeFromExtension` so the file picker sends JPEG images with the correct MIME type.

**Files:** `lib/presentation/features/chat/presentation/widgets/chat_text_field.dart:180`

**Change:**
```dart
case 'jpg':
case 'jpeg':
  return 'image/jpeg';
```
Insert before the existing `'png'` case.

**Acceptance criteria:**
- AC1: Picking a `.jpg` file via the file picker calls `onFilePicked` with `mimeType == 'image/jpeg'`.
- AC2: Picking a `.jpeg` file via the file picker calls `onFilePicked` with `mimeType == 'image/jpeg'`.
- AC3: Picking a `.png` file via the file picker still calls `onFilePicked` with `mimeType == 'image/png'` (no regression).
- AC4: Gallery handler continues to hard-code `image/jpeg` / `image/png` by extension — not affected.

---

### F2 — File Size Guard (25 MB)

**Priority:** 2

**What:** Reject files larger than 25 MB before calling `onFilePicked`. Show a SnackBar with no action. The guard applies to all three pickers: camera, gallery, and file picker.

**Threshold:** 25 × 1024 × 1024 = 26,214,400 bytes.

**SnackBar text:** `"File is too large. Maximum size is 25 MB."`

**Files:** `lib/presentation/features/chat/presentation/widgets/chat_text_field.dart` — inside `_handleCamera`, `_handleGallery`, `_handleFilePicker`, after the file is resolved and before `onFilePicked?.call(...)`.

**Pattern per handler:**
```dart
final bytes = await file.length();
if (bytes > 26214400) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File is too large. Maximum size is 25 MB.')),
    );
  }
  return;
}
```

**Acceptance criteria:**
- AC1: Camera photo > 25 MB → SnackBar shown; `onFilePicked` is NOT called.
- AC2: Gallery image > 25 MB → SnackBar shown; `onFilePicked` is NOT called.
- AC3: File picker result > 25 MB → SnackBar shown; `onFilePicked` is NOT called.
- AC4: Any file ≤ 25 MB proceeds normally; no SnackBar.
- AC5: SnackBar is dismissed without requiring user interaction (default 4-second timeout).

---

### F3 — Permission Denied Feedback with "Open Settings" Action

**Priority:** 3

**What:** When camera or location permission is permanently denied (`deniedForever`), show a SnackBar with an "Open Settings" action that launches app settings. First-time denial re-prompts normally — no SnackBar.

**Scope:**
- **Location** (`_handleLocationShare`): check `Geolocator.checkPermission()` before GPS fetch.
- **Camera** (`_handleCamera`): check `Permission.camera.status` via `permission_handler` before launching image picker.
- **Gallery** (`_handleGallery`): check `Permission.photos.status` (iOS) / `Permission.storage.status` (Android) before launching image picker.

**SnackBar pattern:**
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('${_permissionLabel} permission denied. Allow access in Settings.'),
    action: SnackBarAction(
      label: 'Open Settings',
      onPressed: () => openAppSettings(), // from permission_handler
    ),
    duration: const Duration(seconds: 6),
  ),
);
```

Where `_permissionLabel` is `'Camera'`, `'Photos'`, or `'Location'` depending on the handler.

**Location-specific flow:**
```
Geolocator.checkPermission()
  → denied → Geolocator.requestPermission()
      → denied → return (user can tap again)
      → deniedForever → show SnackBar "Location permission denied. Allow access in Settings." + Open Settings
  → deniedForever → show SnackBar immediately
  → whileInUse / always → proceed
```

**Files:** `lib/presentation/features/chat/presentation/widgets/chat_text_field.dart`

**Acceptance criteria:**
- AC1: User with `deniedForever` camera permission taps Camera → SnackBar with "Open Settings" appears; image picker is NOT launched.
- AC2: User with `deniedForever` location permission taps Location → SnackBar with "Open Settings" appears; GPS is NOT requested.
- AC3: User with `deniedForever` photos permission (iOS) / storage (Android) taps Photos → SnackBar with "Open Settings" appears.
- AC4: Tapping "Open Settings" in the SnackBar opens the device app settings screen.
- AC5: First-time deny (status == `denied`) for camera/photos → re-prompt system dialog; no SnackBar.
- AC6: Granted permission → proceeds normally.

---

### F6 — Upload Progress Indicator in Pending Bubble

**Priority:** 4 (spec priority 6 = implementation order 4)

**What:** Show a `LinearProgressIndicator` inside the pending file message bubble while the file uploads to Sendbird. When upload completes, the bubble transitions to the normal sent state.

#### State changes

Add to `ChatState`:
```dart
final double? fileUploadProgress; // null = no upload; 0.0–1.0 during upload
```

Add `clearFileUploadProgress: bool = false` sentinel to `copyWith`.

#### Repository change

Extend `ChatRepository` interface:
```dart
Future<Message> sendFileMessage(
  String channelUrl,
  String filePath,
  String fileName,
  String mimeType, {
  String? caption,
  Map<String, dynamic>? data,
  void Function(int sent, int total)? onProgress,  // ADD
});
```

In `SendbirdChatRepository.sendFileMessage`, wire the existing SDK callback:
```dart
channel.sendFileMessage(
  params,
  (int bytesSent, int totalBytes) {
    onProgress?.call(bytesSent, totalBytes);
  },
  onCompleted: (message, error) { ... },
);
```

#### Controller change

In `ChatController.sendFileMessage`:
```dart
state = state.copyWith(isSending: true, fileUploadProgress: 0.0);

await repository.sendFileMessage(
  channelUrl, filePath, fileName, mimeType,
  caption: caption,
  onProgress: (sent, total) {
    if (mounted && total > 0) {
      state = state.copyWith(fileUploadProgress: sent / total);
    }
  },
);

if (mounted) {
  state = state.copyWith(isSending: false, clearFileUploadProgress: true);
}
```

#### UI — optimistic file bubble

The optimistic file message bubble (identified by `status == MessageStatus.sending` and `isFile == true`) shows:
```
┌─────────────────────────────┐
│  [thumbnail or file icon]   │
│  filename.jpg               │
│  ████████░░░░  65%          │  ← LinearProgressIndicator(value: progress)
└─────────────────────────────┘
```

Progress value comes from `ref.watch(chatControllerProvider(channelUrl).select((s) => s.fileUploadProgress))`.

**Files:**
- `lib/presentation/features/chat/data/repositories/chat_repository.dart` — interface
- `lib/presentation/features/chat/data/repositories/sendbird_chat_repository.dart:569`
- `lib/presentation/features/chat/presentation/state/chat_state.dart`
- `lib/presentation/features/chat/presentation/widgets/message_bubble.dart` — add progress UI to file bubble

**Acceptance criteria:**
- AC1: Sending a file shows progress from ~0% to 100% in the bubble before the final sent state appears.
- AC2: `fileUploadProgress` is `null` when no file upload is in progress (no lingering state).
- AC3: Upload failure sets `isSending: false`, clears `fileUploadProgress`, and marks bubble `MessageStatus.failed`.
- AC4: Text message sends are unaffected (no progress bar shown for text).
- AC5: Sending a second file while first is in flight is not possible — `isSending: true` guard prevents it.

---

### F5 — Profile Sharing (Own Profile Card)

**Priority:** 5

**What:** Tapping "Contact" in the `AttachmentMenu` sends the current user's profile as a structured text message. The message is rendered as a profile card bubble. Tapping the card navigates to the user's freelancer profile screen.

#### Message format

Sent as a Sendbird **text message** with `data` field encoding a JSON payload:
```json
{
  "type": "profile_card",
  "userId": "u123",
  "name": "Kwame Mensah",
  "role": "freelancer",
  "avatarUrl": "https://...",
  "url": "nano://freelancer/u123"
}
```

Message `content` (visible in Sendbird dashboard / notifications): `"👤 Kwame Mensah shared their profile"`

#### Deep link scheme

`nano://freelancer/{userId}` — handled by the existing `AppLinks` infrastructure in `main.dart`. The chat-side tap handler calls `GoRouter.of(context).go('/freelancer/$userId')` directly (no need for external URL dispatch).

#### Profile card bubble

A new widget `ProfileCardBubble` rendered when `message.data['type'] == 'profile_card'`:
```
┌─────────────────────────────┐
│  👤 [avatar 40px]           │
│  Kwame Mensah               │
│  Freelance Barber           │
│  ──────────────────         │
│  View Profile →             │
└─────────────────────────────┘
```

The card is tappable (`InkWell`) and navigates to the freelancer detail screen.

#### Controller method

```dart
Future<void> sendProfileCard() async {
  final user = ref.read(currentUserProvider);
  if (user == null || !mounted) return;
  final content = '👤 ${user.fullName ?? user.id} shared their profile';
  final data = {
    'type': 'profile_card',
    'userId': user.id,
    'name': user.fullName ?? '',
    'role': 'freelancer',
    'avatarUrl': user.avatarUrl ?? '',
    'url': 'nano://freelancer/${user.id}',
  };
  await repository.sendTextMessage(channelUrl, content, data: data);
}
```

**Files:**
- `lib/presentation/features/chat/presentation/state/chat_state.dart` — `sendProfileCard()`
- `lib/presentation/features/chat/data/repositories/sendbird_chat_repository.dart` — ensure `sendTextMessage` accepts `data: Map<String, dynamic>?`
- `lib/presentation/features/chat/presentation/widgets/message_bubble.dart` — dispatch to `ProfileCardBubble` when data type matches
- `lib/presentation/features/chat/presentation/widgets/profile_card_bubble.dart` — NEW widget
- `lib/presentation/features/chat/presentation/widgets/chat_text_field.dart` — wire `_handleContactShare` to `sendProfileCard()`

**Acceptance criteria:**
- AC1: Tapping Contact sends a message with `data.type == 'profile_card'` and the sender's userId.
- AC2: Both sender and receiver see the profile card bubble (not a raw text bubble).
- AC3: Tapping the profile card navigates to `/freelancer/{userId}`.
- AC4: The card shows name, role, and avatar (or placeholder if no avatar).
- AC5: Profiles belonging to non-freelancer users still send (role defaults to `'user'`).

---

### F4 — Location Sharing (Mapbox thumbnail + address)

**Priority:** 6 (last; depends on F3 for permission UX)

**What:** Tapping "Location" in the `AttachmentMenu` requests GPS permission, fetches the current position, builds a Mapbox Static Images URL, downloads the thumbnail bytes, and sends the image as a file message with structured `data` containing lat/lng and address. The bubble renders as a tappable map thumbnail with an address line below. Tapping opens Apple Maps (iOS) or Google Maps (Android) at the coordinates.

#### Mapbox Static Images URL

```
https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/{lng},{lat},15,0/300x200@2x?access_token={token}
```

- Width: 300, Height: 200, @2x (600×400 actual), zoom 15.
- Use `Environment.mapboxAccessToken`.
- Download as bytes via `http.get(url)` and write to a temp file (`path_provider`: `getTemporaryDirectory()`).

#### Message format

File message with:
- `fileName`: `'location_${lat}_${lng}.jpg'`
- `mimeType`: `'image/jpeg'`
- `data`:
```json
{
  "type": "location",
  "lat": 5.6037,
  "lng": -0.1870,
  "address": "12 Main St, Accra, Greater Accra, Ghana"
}
```

#### Location bubble

When `message.data['type'] == 'location'`:
```
┌─────────────────────────────┐
│  [map thumbnail 300×200]    │
│  📍 12 Main St, Accra, GH  │
│                    12:34   │
└─────────────────────────────┘
```

Tapping the bubble: open Maps app.
- iOS: `https://maps.apple.com/?ll={lat},{lng}&q=Location`
- Android: `geo:{lat},{lng}?q={lat},{lng}(Location)`
- Use `url_launcher` (already in pubspec if present, else add).

#### Flow in `_handleLocationShare`

```
1. Check permission (F3 pattern — show "Open Settings" if deniedForever)
2. If granted: show loading indicator (CircularProgressIndicator overlay or disable button)
3. LocationService.getCurrentLocationWithDetails()
4. Build Mapbox URL, fetch bytes, write temp file
5. Call onFilePicked(tempFile, fileName, 'image/jpeg') — with data passed via a wrapper
```

Because `onFilePicked` signature is `Future<void> Function(File, String, String)`, the `data` map must be passed through a separate mechanism. Options:
- **Option A (recommended):** Add `Map<String, dynamic>? data` to `onFilePicked` signature: `Future<void> Function(File, String, String, {Map<String, dynamic>? data})`.
- Option B: Use a closure in `chat_screen.dart` that captures data separately.

**Use Option A** — extend the `onFilePicked` typedef to include optional `data`.

**Files:**
- `lib/presentation/features/chat/presentation/widgets/chat_text_field.dart` — `_handleLocationShare`
- `lib/presentation/features/chat/presentation/screens/chat_screen.dart` — update `onFilePicked` callback signature
- `lib/presentation/features/chat/presentation/state/chat_state.dart` — `sendFileMessage` already accepts `data`
- `lib/presentation/features/chat/presentation/widgets/message_bubble.dart` — dispatch to `LocationBubble`
- `lib/presentation/features/chat/presentation/widgets/location_bubble.dart` — NEW widget
- `lib/core/services/location_service.dart` — no changes needed

**Acceptance criteria:**
- AC1: Tapping Location with permission granted sends a file message with `data.type == 'location'`, `lat`, `lng`, `address` populated.
- AC2: Both sender and receiver see the map thumbnail with address text below.
- AC3: Tapping the bubble opens Apple Maps (iOS) or Google Maps (Android) at the correct coordinates.
- AC4: If GPS fetch fails (timeout or no fix), show SnackBar `'Could not get your location. Try again.'` and send nothing.
- AC5: Permission `deniedForever` → "Open Settings" SnackBar (F3 pattern); no GPS request made.
- AC6: The loading state (step 2–4) shows a spinner or disables the Location button for the duration.

---

## Data Model Changes

### `ChatState` additions

```dart
final double? fileUploadProgress; // F6 — null when idle
```

### `Message` — no schema change

`data` is already deserialized as `Map<String, dynamic>?` via `message.data` in Sendbird. Profile card and location messages use the existing `data` field.

### `onFilePicked` typedef change (F4)

```dart
// Before
final Future<void> Function(File file, String fileName, String mimeType)? onFilePicked;

// After (F4)
final Future<void> Function(
  File file,
  String fileName,
  String mimeType, {
  Map<String, dynamic>? data,
})? onFilePicked;
```

---

## Error States

| Scenario | Response |
|----------|----------|
| File > 25 MB | SnackBar "File is too large. Maximum size is 25 MB." No send. |
| Camera permission `deniedForever` | SnackBar "Camera permission denied. Allow access in Settings." + "Open Settings" action. |
| Photos permission `deniedForever` | SnackBar "Photos permission denied. Allow access in Settings." + "Open Settings" action. |
| Location permission `deniedForever` | SnackBar "Location permission denied. Allow access in Settings." + "Open Settings" action. |
| GPS unavailable / timeout | SnackBar "Could not get your location. Try again." |
| File upload fails mid-progress | `MessageStatus.failed` on bubble. `fileUploadProgress` cleared. Existing retry/delete context menu available. |
| Profile card: user has no name | Falls back to userId as display name in card. |
| Mapbox static image fetch fails | SnackBar "Could not generate map preview. Try again." No send. |

---

## Dependencies / Risks

| Item | Status |
|------|--------|
| `geolocator: ^11.0.0` | ✅ Installed |
| `permission_handler: ^11.0.0` | ✅ Installed |
| `app_links: ^6.0.0` | ✅ Installed |
| `share_plus: ^7.0.0` | ✅ Installed |
| `mapbox_maps_flutter: ^2.1.0` | ✅ Installed (Mapbox token via `Environment.mapboxAccessToken`) |
| `http` | ✅ Already used in `LocationService` |
| `path_provider` | ⚠️ Check pubspec — needed for temp file in F4 |
| `url_launcher` | ⚠️ Check pubspec — needed for Maps tap in F4 |
| Sendbird `OnUploadProgressCallback` | ✅ SDK 3.2.20 exposes it on `channel.sendFileMessage` |
| `data` field on `sendTextMessage` | ⚠️ Verify `UserMessageParams` accepts `data` string in current SDK |
| iOS `NSLocationWhenInUseUsageDescription` | ✅ Geolocator already configured (app uses location elsewhere) |
| Android location permissions in `AndroidManifest.xml` | ✅ Already present |
| Camera/Photos plist entries for iOS | ✅ `image_picker` already requires them |

**Risk:** Sendbird's `data` field on `UserMessageParams` is a `String?`, so the JSON must be `jsonEncode(data)` on send and `jsonDecode(message.data ?? '{}')` on receive. The `Message.fromSBMessage` already does this partially — verify the existing deserialization handles the `type` field.

---

## Testing Requirements

- Unit: `_mimeFromExtension` with `.jpg`, `.jpeg`, `.JPG` inputs (F1).
- Unit: File size guard returns false for 26 MB, true for 25 MB exactly (F2).
- Widget: `ProfileCardBubble` renders name, role, and triggers navigation on tap (F5).
- Widget: `LocationBubble` renders thumbnail URL and address text (F4).
- Integration: `ChatController.sendFileMessage` with mocked repository emits progress states from 0.0 → 1.0 → null (F6).
- Manual: All three pickers with files > 25 MB on device; permission revocation flows on iOS and Android.
