import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:nano_embryo/presentation/features/chat/data/models/sendbird/sb_channel.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/message.dart';

/// Business entity for conversations (Sendbird-agnostic)
class Conversation {
  final String id;
  final String name;
  final String? avatarUrl;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;
  final List<String> participants;
  final bool isGroup;
  final String? customData;

  const Conversation({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
    required this.participants,
    required this.isGroup,
    this.customData,
  });

  // Factory to create from Sendbird Channel
  factory Conversation.fromSBChannel(SBChannel channel, String currentUserId) {
    final otherMember =
        channel.members.length > 1
            ? channel.members.firstWhere(
              (m) => m.userId != currentUserId,
              orElse: () => channel.members.first,
            )
            : channel.members.isNotEmpty
            ? channel.members.first
            : null;

    final allMemberIds = channel.members.map((m) => m.userId).toList();
    final derivedName =
        channel.name.isNotEmpty
            ? channel.name
            : (otherMember?.nickname ?? otherMember?.userId ?? 'Unknown');
    final hasCustomCover =
        channel.coverUrl != null &&
        channel.coverUrl!.isNotEmpty &&
        !channel.coverUrl!.contains('static.sendbird.com');
    final derivedAvatar =
        hasCustomCover
            ? channel.coverUrl
            : (otherMember?.profileUrl?.isNotEmpty == true
                ? otherMember!.profileUrl
                : null);
    final isGroup = _determineIfGroup(channel);

    debugPrint(
      '🗂️ [FROM-SB-CHANNEL] url=${channel.channelUrl} | currentUser=$currentUserId | allMembers=$allMemberIds | memberCount=${channel.members.length} | otherMember=${otherMember?.userId} | derivedName="$derivedName" | derivedAvatar=$derivedAvatar | isGroup=$isGroup',
    );

    return Conversation(
      id: channel.channelUrl,
      name: derivedName,
      avatarUrl: derivedAvatar,
      lastMessage:
          channel.lastMessage != null
              ? Message.fromSBMessage(channel.lastMessage!, currentUserId)
              : null,
      unreadCount: channel.unreadMessageCount,
      updatedAt: channel.updatedAt,
      participants: channel.memberIds,
      isGroup: isGroup,
      customData: channel.data?['raw']?.toString() ?? channel.data?.toString(),
    );
  }

  // To this (better logic):
  static bool _determineIfGroup(SBChannel channel) {
    // Option A: If SBChannel has a clear group type
    // return channel.isGroupChannel; // If SBChannel has this property

    // Option B: Based on participant count AND channel type
    final isGroupByCount = channel.memberIds.length > 2;

    // If SBChannel has channelType property
    // final isGroupByType = channel.channelType == SBChannelType.group;
    // return isGroupByType || isGroupByCount;

    // For now, use participant count
    return isGroupByCount;
  }

  // Copy with method for immutability
  Conversation copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    Message? lastMessage,
    int? unreadCount,
    DateTime? updatedAt,
    List<String>? participants,
    bool? isGroup,
    String? customData,
  }) {
    return Conversation(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
      participants: participants ?? this.participants,
      isGroup: isGroup ?? this.isGroup,
      customData: customData ?? this.customData,
    );
  }

  // JSON serialization for local caching
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      lastMessage:
          json['lastMessage'] != null
              ? Message.fromJson(json['lastMessage'] as Map<String, dynamic>)
              : null,
      unreadCount:
          (json['unreadCount'] as num?)?.toInt() ?? 0, // ✅ Safer casting
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      participants: List<String>.from(json['participants'] as List),
      isGroup: json['isGroup'] as bool? ?? true,
      customData: json['customData'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'updatedAt': updatedAt.toIso8601String(),
      'participants': participants,
      'isGroup': isGroup,
      'customData': customData,
    };
  }

  // Convenience getters
  bool get hasUnread => unreadCount > 0;

  /// Shop-scoped business channels carry this metadata. Legacy and personal
  /// channels return null and remain visible regardless of the active shop.
  String? get shopId {
    final raw = customData;
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return (decoded['shop_id'] ?? decoded['shopId'])?.toString();
      }
    } on FormatException {
      final match = RegExp(
        r'(?:shop_id|shopId)\s*:\s*([^,}\s]+)',
      ).firstMatch(raw);
      return match?.group(1);
    }
    return null;
  }

  String get displayName {
    if (name.isNotEmpty) return name;

    if (participants.length == 2 && !isGroup) {
      return 'Direct Message';
    }

    return 'Group Chat';
  }

  // Get other user ID for 1:1 chats (if you store currentUserId elsewhere)
  String? getOtherUserId(String currentUserId) {
    if (participants.length == 2 && !isGroup) {
      return participants.firstWhere(
        (id) => id != currentUserId,
        orElse: () => participants.first,
      );
    }
    return null;
  }

  // Equality and debugging
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Conversation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Conversation{id: $id, name: "$name", isGroup: $isGroup, '
        'participants: ${participants.length}, unread: $unreadCount, '
        'lastMsg: ${lastMessage?.content.substring(0, lastMessage!.content.length.clamp(0, 20))}...}';
  }
}
