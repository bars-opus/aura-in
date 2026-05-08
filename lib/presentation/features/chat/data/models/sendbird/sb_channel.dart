import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_message.dart';
import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_types.dart';
import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_user.dart';

/// Represents Sendbird's GroupChannel structure
/// https://sendbird.com/docs/chat/v3/platform-api/channel/overview#3-group-channel
class SBChannel {
  final String channelUrl;        // Unique identifier (like Sendbird)
  final String name;
  final String? coverUrl;
  final String? customType;
  final SBChannelType channelType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SBMessage? lastMessage;
  final int unreadMessageCount;
  final List<SBUser> members;
  final List<SBUser> invitedMembers;
  final bool isDistinct;
  final bool isPublic;
  final bool isEphemeral;
  final bool isSuper;
  final bool isBroadcast;
  final bool isFrozen;
  final Map<String, dynamic>? data;
  final int messageOffsetTimestamp;
  final int messageSurvivalSeconds;
  
  const SBChannel({
    required this.channelUrl,
    required this.name,
    this.coverUrl,
    this.customType,
    required this.channelType,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    this.unreadMessageCount = 0,
    this.members = const [],
    this.invitedMembers = const [],
    this.isDistinct = false,
    this.isPublic = false,
    this.isEphemeral = false,
    this.isSuper = false,
    this.isBroadcast = false,
    this.isFrozen = false,
    this.data,
    this.messageOffsetTimestamp = 0,
    this.messageSurvivalSeconds = 0,
  });
  
  // Helper methods (like Sendbird's GroupChannel)
  bool get hasUnreadMessages => unreadMessageCount > 0;
  List<String> get memberIds => members.map((m) => m.userId).toList();
  bool isMember(String userId) => members.any((m) => m.userId == userId);
}
