import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_message.dart';
import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_types.dart';

/// Business entity for messages (Sendbird-agnostic)
class Message {
  final String id;
  final String content;
  final DateTime timestamp;
  final MessageSender sender;
  final MessageStatus status;
  final MessageType type;
  final Map<String, dynamic>? metadata;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;

  const Message({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.sender,
    required this.status,
    this.type = MessageType.text,
    this.metadata,
    this.fileUrl,
    this.fileName,
    this.fileSize,
  });

  // Factory to create from Sendbird Message
  factory Message.fromSBMessage(SBMessage? sbMessage, String currentUserId) {
    if (sbMessage == null) {
      return Message(
        id: '',
        content: 'No messages yet',
        timestamp: DateTime.now(),
        sender: MessageSender.system,
        status: MessageStatus.sent,
        type: MessageType.system,
      );
    }

    final isCurrentUser = sbMessage.sender?.userId == currentUserId;

    if (sbMessage is SBUserMessage) {
      return Message(
        id: sbMessage.messageId.toString(),
        content: sbMessage.message,
        timestamp: sbMessage.createdAt,
        sender: isCurrentUser ? MessageSender.user : MessageSender.other,
        status: _mapStatus(sbMessage.sendingStatus),
        type: MessageType.text,
        metadata: sbMessage.data,
      );
    } else if (sbMessage is SBFileMessage) {
      return Message(
        id: sbMessage.messageId.toString(),
        content: sbMessage.message ?? 'Sent a file',
        timestamp: sbMessage.createdAt,
        sender: isCurrentUser ? MessageSender.user : MessageSender.other,
        status: _mapStatus(sbMessage.sendingStatus),
        type: MessageType.file,
        metadata: sbMessage.data,
        fileUrl: sbMessage.url,
        fileName: sbMessage.name,
        fileSize: sbMessage.size,
      );
    } else if (sbMessage is SBAdminMessage) {
      return Message(
        id: sbMessage.messageId.toString(),
        content: sbMessage.message,
        timestamp: sbMessage.createdAt,
        sender: MessageSender.system,
        status: MessageStatus.sent,
        type: MessageType.system,
      );
    }

    return Message(
      id: sbMessage.messageId.toString(),
      content: 'Unknown message type',
      timestamp: sbMessage.createdAt,
      sender: MessageSender.system,
      status: MessageStatus.sent,
      type: MessageType.system,
    );
  }

  // Factory from JSON for local caching
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      sender: MessageSender.values[json['sender'] as int],
      status: MessageStatus.values[json['status'] as int],
      type: MessageType.values[json['type'] as int],
      metadata:
          json['metadata'] != null
              ? Map<String, dynamic>.from(json['metadata'] as Map)
              : null,
      fileUrl: json['fileUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt(),
    );
  }

  // Convert to JSON for local caching
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'sender': sender.index,
      'status': status.index,
      'type': type.index,
      'metadata': metadata,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
    };
  }

  // Copy with method for immutability
  Message copyWith({
    String? id,
    String? content,
    DateTime? timestamp,
    MessageSender? sender,
    MessageStatus? status,
    MessageType? type,
    Map<String, dynamic>? metadata,
    String? fileUrl,
    String? fileName,
    int? fileSize,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      sender: sender ?? this.sender,
      status: status ?? this.status,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  static MessageStatus _mapStatus(SBMessageSendingStatus status) {
    switch (status) {
      case SBMessageSendingStatus.pending:
        return MessageStatus.sending;
      case SBMessageSendingStatus.failed:
        return MessageStatus.failed;
      case SBMessageSendingStatus.succeeded:
        return MessageStatus.sent;
      case SBMessageSendingStatus.none:
        return MessageStatus.sent;
    }
  }

  // Convenience getters
  bool get isFromUser => sender == MessageSender.user;
  bool get isFromOther => sender == MessageSender.other;
  bool get isSystem => sender == MessageSender.system;

  bool get isText => type == MessageType.text;
  bool get isImage => type == MessageType.image;
  bool get isFile => type == MessageType.file;
  bool get isVideo => type == MessageType.video;
  bool get isAudio => type == MessageType.audio;

  bool get isSending => status == MessageStatus.sending;
  bool get isSent => status == MessageStatus.sent;
  bool get isFailed => status == MessageStatus.failed;

  String get shortTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) return 'Now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';

    return '${timestamp.day}/${timestamp.month}';
  }

  // Equality and debugging
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Message{id: $id, sender: $sender, type: $type, '
        'status: $status, content: "${content.length > 30 ? '${content.substring(0, 30)}...' : content}"}';
  }
}

enum MessageSender {
  user, // Current user
  other, // Other users
  system, // System messages
}

enum MessageStatus { sending, sent, delivered, read, failed }

enum MessageType { text, image, video, audio, file, system }
