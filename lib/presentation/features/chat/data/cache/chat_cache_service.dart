import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/conversation.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/message.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const _kKeyName = 'hive_chat_aes_key';
const _kMessagesBox = 'chat_messages_v1';
const _kConversationsBox = 'chat_conversations_v1';
const _kMaxMessages = 50;

// ─── Provider ─────────────────────────────────────────────────────────────────
// Overridden in main.dart after init() completes.

final chatCacheServiceProvider = Provider<ChatCacheService>((ref) {
  throw UnimplementedError(
    'chatCacheServiceProvider must be overridden in main.dart '
    'after ChatCacheService.init() has been awaited.',
  );
});

// ─── Service ──────────────────────────────────────────────────────────────────

/// Encrypted, persistent cache for chat messages and conversation lists.
///
/// Encryption: Hive AES-256 cipher. The 32-byte key is generated once per
/// install using dart:math Random.secure() and stored in platform secure
/// storage (iOS Keychain / Android EncryptedSharedPreferences).
///
/// Lifecycle: call [init] once in main() before runApp, then read/write
/// synchronously without any await in the hot path.
class ChatCacheService {
  ChatCacheService._();

  static final ChatCacheService _instance = ChatCacheService._();
  factory ChatCacheService() => _instance;

  late Box<String> _messagesBox;
  late Box<String> _conversationsBox;

  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    final cipher = HiveAesCipher(await _resolveKey());
    await _openBoxes(cipher);
    debugPrint('✅ [CHAT-CACHE] initialized | '
        'msgs=${_messagesBox.length} channels, convs=${_conversationsBox.length}');
  }

  /// Returns the stored AES key, or generates + persists a new one.
  Future<Uint8List> _resolveKey() async {
    final stored = await _secure.read(key: _kKeyName);
    if (stored != null) return base64Decode(stored);

    final key = Uint8List.fromList(
      List<int>.generate(32, (_) => Random.secure().nextInt(256)),
    );
    await _secure.write(key: _kKeyName, value: base64Encode(key));
    debugPrint('🔑 [CHAT-CACHE] new AES key generated and stored in keychain');
    return key;
  }

  /// Opens encrypted boxes, wiping corrupt state if the key changed.
  Future<void> _openBoxes(HiveAesCipher cipher) async {
    try {
      _messagesBox = await Hive.openBox<String>(
        _kMessagesBox,
        encryptionCipher: cipher,
      );
      _conversationsBox = await Hive.openBox<String>(
        _kConversationsBox,
        encryptionCipher: cipher,
      );
    } catch (_) {
      // Key mismatch (e.g. Android app-data clear without keychain wipe).
      // Purge stale files and start fresh with the current key.
      debugPrint('⚠️ [CHAT-CACHE] corrupt boxes — wiping and recreating');
      await Hive.deleteBoxFromDisk(_kMessagesBox).catchError((_) => null);
      await Hive.deleteBoxFromDisk(_kConversationsBox).catchError((_) => null);
      _messagesBox = await Hive.openBox<String>(
        _kMessagesBox,
        encryptionCipher: cipher,
      );
      _conversationsBox = await Hive.openBox<String>(
        _kConversationsBox,
        encryptionCipher: cipher,
      );
    }
  }

  // ── Messages ──────────────────────────────────────────────────────────────

  /// Synchronous — safe to call in the first frame.
  List<Message> readMessages(String channelUrl) {
    try {
      final raw = _messagesBox.get(channelUrl);
      if (raw == null || raw.isEmpty) return [];
      return (jsonDecode(raw) as List)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('⚠️ [CHAT-CACHE] readMessages error: $e');
      return [];
    }
  }

  /// Persists the newest [_kMaxMessages] messages for [channelUrl].
  Future<void> writeMessages(String channelUrl, List<Message> messages) async {
    if (messages.isEmpty) return;
    try {
      final limited = messages.length > _kMaxMessages
          ? messages.sublist(0, _kMaxMessages)
          : messages;
      await _messagesBox.put(
        channelUrl,
        jsonEncode(limited.map((m) => m.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('⚠️ [CHAT-CACHE] writeMessages error: $e');
    }
  }

  // ── Conversations ─────────────────────────────────────────────────────────

  /// Synchronous — safe to call in the first frame.
  List<Conversation> readConversations() {
    try {
      final raw = _conversationsBox.get('list');
      if (raw == null || raw.isEmpty) return [];
      return (jsonDecode(raw) as List)
          .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('⚠️ [CHAT-CACHE] readConversations error: $e');
      return [];
    }
  }

  Future<void> writeConversations(List<Conversation> conversations) async {
    if (conversations.isEmpty) return;
    try {
      await _conversationsBox.put(
        'list',
        jsonEncode(conversations.map((c) => c.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('⚠️ [CHAT-CACHE] writeConversations error: $e');
    }
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Wipes all cached chat data. Call on user sign-out to prevent
  /// cross-session data leakage.
  Future<void> clearAll() async {
    try {
      await Future.wait([
        _messagesBox.clear(),
        _conversationsBox.clear(),
      ]);
      debugPrint('🗑️  [CHAT-CACHE] cleared all cached data');
    } catch (e) {
      debugPrint('⚠️ [CHAT-CACHE] clearAll error: $e');
    }
  }
}
