import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nano_embryo/presentation/features/chat/data/cache/pending_send.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/conversation.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/message.dart';
import 'package:nano_embryo/presentation/features/chat/utils/chat_log.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const _kKeyName = 'hive_chat_aes_key';
const _kMessagesBox = 'chat_messages_v1';
const _kConversationsBox = 'chat_conversations_v1';
const _kOutboxBox = 'chat_outbox_v1';
const _kMaxMessages = 50;
// 2.14: hard ceiling on the outbound queue so a permanently-offline device
// can't grow it without bound. Oldest entries are evicted past this.
const _kMaxOutbox = 100;

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
  late Box<String> _outboxBox;

  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    final cipher = HiveAesCipher(await _resolveKey());
    await _openBoxes(cipher);
    ChatLog.d('✅ [CHAT-CACHE] initialized | '
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
    ChatLog.d('🔑 [CHAT-CACHE] new AES key generated and stored in keychain');
    return key;
  }

  /// Opens encrypted boxes, wiping corrupt state if the key changed.
  Future<void> _openBoxes(HiveAesCipher cipher) async {
    Future<void> open() async {
      _messagesBox =
          await Hive.openBox<String>(_kMessagesBox, encryptionCipher: cipher);
      _conversationsBox = await Hive.openBox<String>(
        _kConversationsBox,
        encryptionCipher: cipher,
      );
      _outboxBox =
          await Hive.openBox<String>(_kOutboxBox, encryptionCipher: cipher);
    }

    try {
      await open();
    } catch (_) {
      // Key mismatch (e.g. Android app-data clear without keychain wipe).
      // Purge stale files and start fresh with the current key.
      ChatLog.d('⚠️ [CHAT-CACHE] corrupt boxes — wiping and recreating');
      for (final name in [_kMessagesBox, _kConversationsBox, _kOutboxBox]) {
        await Hive.deleteBoxFromDisk(name).catchError((e) {
          ChatLog.d('⚠️ [CHAT-CACHE] failed to delete $name: $e');
          return null;
        });
      }
      await open();
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
      ChatLog.d('⚠️ [CHAT-CACHE] readMessages error: $e');
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
      ChatLog.d('⚠️ [CHAT-CACHE] writeMessages error: $e');
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
      ChatLog.d('⚠️ [CHAT-CACHE] readConversations error: $e');
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
      ChatLog.d('⚠️ [CHAT-CACHE] writeConversations error: $e');
    }
  }

  // ── Outbox (pending sends) ──────────────────────────────────────────────────

  /// All pending sends, oldest-first (FIFO replay order). Synchronous.
  List<PendingSend> readOutbox() {
    try {
      final entries = _outboxBox.values
          .map((raw) => PendingSend.fromJson(
                jsonDecode(raw) as Map<String, dynamic>,
              ))
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return entries;
    } catch (e) {
      ChatLog.d('⚠️ [CHAT-CACHE] readOutbox error: $e');
      return [];
    }
  }

  /// Upserts a pending send keyed by its clientReqId. Evicts the oldest entry
  /// when the queue exceeds [_kMaxOutbox] (2.14: bounded).
  Future<void> putOutbox(PendingSend send) async {
    try {
      await _outboxBox.put(send.clientReqId, jsonEncode(send.toJson()));
      if (_outboxBox.length > _kMaxOutbox) {
        final oldest = readOutbox();
        final overflow = oldest.length - _kMaxOutbox;
        for (var i = 0; i < overflow; i++) {
          await _outboxBox.delete(oldest[i].clientReqId);
        }
      }
    } catch (e) {
      ChatLog.d('⚠️ [CHAT-CACHE] putOutbox error: $e');
    }
  }

  /// Removes a pending send once it is confirmed (or abandoned).
  Future<void> removeOutbox(String clientReqId) async {
    try {
      await _outboxBox.delete(clientReqId);
    } catch (e) {
      ChatLog.d('⚠️ [CHAT-CACHE] removeOutbox error: $e');
    }
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Wipes all cached chat data. Call on user sign-out to prevent
  /// cross-session data leakage.
  /// Throws on failure so the caller (sign-out) can handle or surface the error.
  Future<void> clearAll() async {
    await Future.wait([
      _messagesBox.clear(),
      _conversationsBox.clear(),
      _outboxBox.clear(),
    ]);
    ChatLog.d('🗑️  [CHAT-CACHE] cleared all cached data');
  }
}
