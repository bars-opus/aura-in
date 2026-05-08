import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool showAvatar;
  final bool showStatus;

  /// Null means the action is not available for this message
  /// (e.g. can't delete someone else's message).
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const MessageBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
    this.showStatus = true,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    final isSystem = message.sender == MessageSender.system;

    if (isSystem) return _buildSystemMessage(context);

    return GestureDetector(
      onLongPress: () => _showContextMenu(context),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: Spacing.xs.h,
          horizontal: Spacing.md.w,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isUser) _buildAvatar(context, isUser),
            if (!isUser) SizedBox(width: Spacing.sm.w),
            Flexible(
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  _buildBubble(context, isUser),
                  if (showStatus) _buildMessageStatus(context),
                ],
              ),
            ),
            if (isUser) SizedBox(width: Spacing.sm.w),
            if (isUser && showAvatar) _buildAvatar(context, isUser),
          ],
        ),
      ),
    );
  }

  // ─── Bubble content ───────────────────────────────────────────────────────

  Widget _buildBubble(BuildContext context, bool isUser) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isUser ? colorScheme.primary : colorScheme.surface,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.15),
          width: .5,
        ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isUser ? 20 : 0),
          bottomRight: Radius.circular(isUser ? 0 : 20),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isUser ? 20 : 0),
          bottomRight: Radius.circular(isUser ? 0 : 20),
        ),
        child: _buildBubbleContent(context, isUser),
      ),
    );
  }

  Widget _buildBubbleContent(BuildContext context, bool isUser) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = isUser ? colorScheme.onPrimary : colorScheme.onSurface;

    switch (message.type) {
      case MessageType.image:
        return _buildImageContent(context, textColor);

      case MessageType.video:
        return _buildFileContent(
          context,
          Icons.videocam,
          textColor,
          isUser: isUser,
        );

      case MessageType.audio:
        return _buildFileContent(
          context,
          Icons.audiotrack,
          textColor,
          isUser: isUser,
        );

      case MessageType.file:
        return _buildFileContent(
          context,
          _iconForMime(message.fileName ?? ''),
          textColor,
          isUser: isUser,
        );

      default:
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
          child: Text(
            message.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: textColor,
            ),
          ),
        );
    }
  }

  Widget _buildImageContent(BuildContext context, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.fileUrl != null)
          GestureDetector(
            onTap: () => _openFullImage(context, message.fileUrl!),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 220.w, maxHeight: 200.h),
              child: CachedNetworkImage(
                imageUrl: message.fileUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => SizedBox(
                  width: 220.w,
                  height: 150.h,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => SizedBox(
                  width: 220.w,
                  height: 100.h,
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
          ),
        if (message.content.isNotEmpty && message.content != 'Sent a file')
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            child: Text(
              message.content,
              style: TextStyle(color: textColor),
            ),
          ),
      ],
    );
  }

  Widget _buildFileContent(
    BuildContext context,
    IconData icon,
    Color textColor, {
    required bool isUser,
  }) {
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24.h, color: textColor),
          ),
          SizedBox(width: 10.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.fileName ?? message.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (message.fileSize != null)
                  Text(
                    _formatFileSize(message.fileSize!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Context menu ─────────────────────────────────────────────────────────

  void _showContextMenu(BuildContext context) {
    HapticFeedback.mediumImpact();

    final canEdit =
        onEdit != null &&
        message.sender == MessageSender.user &&
        message.type == MessageType.text;
    final canDelete = onDelete != null && message.sender == MessageSender.user;
    final canCopy = message.type == MessageType.text;

    if (!canEdit && !canDelete && !canCopy) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MessageContextMenu(
        message: message,
        onCopy:
            canCopy
                ? () {
                  Clipboard.setData(ClipboardData(text: message.content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                : null,
        onEdit: canEdit ? onEdit : null,
        onDelete:
            canDelete
                ? () => _confirmDelete(context)
                : null,
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete message'),
            content: const Text(
              'This message will be permanently deleted.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onDelete?.call();
                },
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _openFullImage(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder:
            (_) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              body: Center(
                child: InteractiveViewer(
                  child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
                ),
              ),
            ),
      ),
    );
  }

  // ─── Avatar ───────────────────────────────────────────────────────────────

  Widget _buildAvatar(BuildContext context, bool isUser) {
    final colorScheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 14.h,
      backgroundColor: isUser ? colorScheme.primary : colorScheme.surfaceVariant,
      child: Icon(
        Icons.person,
        size: 16.h,
        color: isUser ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
      ),
    );
  }

  // ─── System message ───────────────────────────────────────────────────────

  Widget _buildSystemMessage(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 24.w),
        child: Text(
          message.content,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  // ─── Status row ───────────────────────────────────────────────────────────

  Widget _buildMessageStatus(BuildContext context) {
    if (message.sender != MessageSender.user) return const SizedBox.shrink();

    IconData? icon;
    String label;
    Color color = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);

    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        label = 'Sending';
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        label = 'Sent';
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        label = 'Delivered';
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        label = 'Read';
        color = Theme.of(context).colorScheme.primary;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        label = 'Failed';
        color = Theme.of(context).colorScheme.error;
        break;
    }

    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 12.h, color: color),
          if (icon != null) SizedBox(width: 3.w),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontSize: FontSizeTokens.xs.sp,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  IconData _iconForMime(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (['pdf'].contains(ext)) return Icons.picture_as_pdf;
    if (['doc', 'docx'].contains(ext)) return Icons.description;
    if (['xls', 'xlsx'].contains(ext)) return Icons.table_chart;
    if (['mp4', 'mov', 'avi'].contains(ext)) return Icons.videocam;
    if (['mp3', 'aac', 'm4a'].contains(ext)) return Icons.audiotrack;
    return Icons.insert_drive_file;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ─── Context menu sheet ───────────────────────────────────────────────────────

class _MessageContextMenu extends StatelessWidget {
  final Message message;
  final VoidCallback? onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _MessageContextMenu({
    required this.message,
    this.onCopy,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (onCopy != null)
              _MenuItem(
                icon: Icons.copy,
                label: 'Copy',
                onTap: () {
                  Navigator.pop(context);
                  onCopy!();
                },
              ),
            if (onEdit != null)
              _MenuItem(
                icon: Icons.edit,
                label: 'Edit',
                onTap: () {
                  Navigator.pop(context);
                  onEdit!();
                },
              ),
            if (onDelete != null)
              _MenuItem(
                icon: Icons.delete_outline,
                label: 'Delete',
                color: colorScheme.error,
                onTap: () {
                  Navigator.pop(context);
                  onDelete!();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: effectiveColor, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
