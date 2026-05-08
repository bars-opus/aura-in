/// Sendbird-compatible enums (exact same as Sendbird SDK)
enum SBChannelType {
  group,
  open,
  feed,
}

enum SBMessageType {
  user,     // UserMessage
  file,     // FileMessage
  admin,    // AdminMessage
  system,
}

enum SBMessageSendingStatus {
  pending,
  failed,
  succeeded,
  none,
}

enum SBMemberState {
  joined,
  invited,
}

enum SBChannelFilter {
  all,
  unread,
  joined,
  invited,
}

enum SBUnreadFilter {
  all,
  unreadMessage,
}
