import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_types.dart';
import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_user.dart';

/// Base class representing Sendbird's BaseMessage structure
/// https://sendbird.com/docs/chat/v3/platform-api/message/overview#2-resource-representation
abstract class SBMessage {
  final int messageId;
  final String channelUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final SBUser? sender;
  final SBMessageSendingStatus sendingStatus;
  final SBMessageType messageType;
  final Map<String, dynamic>? data;
  final List<String>? reactions;
  final int? parentMessageId;
  final bool isPinned;
  final int? pinExpiresAt;
  
  const SBMessage({
    required this.messageId,
    required this.channelUrl,
    required this.createdAt,
    this.updatedAt,
    this.sender,
    this.sendingStatus = SBMessageSendingStatus.succeeded,
    required this.messageType,
    this.data,
    this.reactions,
    this.parentMessageId,
    this.isPinned = false,
    this.pinExpiresAt,
  });
}

/// UserMessage - text messages
class SBUserMessage extends SBMessage {
  final String message;
  final String? translatedText;
  final Map<String, String>? translations;
  
  const SBUserMessage({
    required super.messageId,
    required super.channelUrl,
    required super.createdAt,
    required this.message,
    super.sender,
    super.sendingStatus,
    super.data,
    super.reactions,
    super.parentMessageId,
    super.isPinned,
    super.pinExpiresAt,
    this.translatedText,
    this.translations,
  }) : super(messageType: SBMessageType.user);
}

/// FileMessage - file attachments
class SBFileMessage extends SBMessage {
  final String url;
  final String name;
  final String type;
  final int size;
  final List<SBThumbnail>? thumbnails;
  final String? message; // Caption
  
  const SBFileMessage({
    required super.messageId,
    required super.channelUrl,
    required super.createdAt,
    required this.url,
    required this.name,
    required this.type,
    required this.size,
    this.thumbnails,
    this.message,
    super.sender,
    super.sendingStatus,
    super.data,
    super.reactions,
    super.parentMessageId,
    super.isPinned,
    super.pinExpiresAt,
  }) : super(messageType: SBMessageType.file);
}

class SBThumbnail {
  final String url;
  final int width;
  final int height;
  final int actualWidth;
  final int actualHeight;
  
  const SBThumbnail({
    required this.url,
    required this.width,
    required this.height,
    required this.actualWidth,
    required this.actualHeight,
  });
}

/// AdminMessage - system messages
class SBAdminMessage extends SBMessage {
  final String message;
  
  const SBAdminMessage({
    required super.messageId,
    required super.channelUrl,
    required super.createdAt,
    required this.message,
  }) : super(messageType: SBMessageType.admin);
}
