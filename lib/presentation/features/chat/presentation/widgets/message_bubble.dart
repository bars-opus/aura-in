import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/message.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/widgets/location_bubble.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/widgets/profile_card_bubble.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final Message? replyToMessage;
  final bool showAvatar;
  final bool showStatus;

  /// Null means the action is not available for this message
  /// (e.g. can't delete someone else's message).
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onReply;
  final VoidCallback? onReplyPreviewTapped;

  /// Non-null only for failed messages — tapping the status re-sends (G1).
  final VoidCallback? onRetry;

  /// Display name of the other participant, used in the reply preview header
  /// instead of a generic "Other" (G7). Falls back to "Other" when null.
  final String? otherName;

  /// Avatar URL for the other participant, shown in the incoming-message avatar
  /// (G7). Falls back to an initial/icon when null.
  final String? otherAvatarUrl;
  final bool isHighlighted;

  /// 0.0–1.0 while a file upload is in progress; null otherwise.
  final double? uploadProgress;

  const MessageBubble({
    super.key,
    required this.message,
    this.replyToMessage,
    this.showAvatar = true,
    this.showStatus = true,
    this.onDelete,
    this.onEdit,
    this.onReply,
    this.onReplyPreviewTapped,
    this.onRetry,
    this.otherName,
    this.otherAvatarUrl,
    this.isHighlighted = false,
    this.uploadProgress,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  // ─── Slide-to-reply state ─────────────────────────────────────────────────

  double _dragOffset = 0;
  bool _replyTriggered = false;
  static const double _replyThreshold = 60;

  void _onDragUpdate(DragUpdateDetails details) {
    if (details.delta.dx > 0) {
      setState(() {
        _dragOffset = (_dragOffset + details.delta.dx).clamp(0.0, 80.0);
        if (_dragOffset >= _replyThreshold && !_replyTriggered) {
          _replyTriggered = true;
          HapticFeedback.lightImpact();
        }
      });
    }
  }

  void _onDragEnd(DragEndDetails _) {
    if (_replyTriggered) widget.onReply?.call();
    setState(() {
      _dragOffset = 0;
      _replyTriggered = false;
    });
  }

  void _onDragCancel() {
    setState(() {
      _dragOffset = 0;
      _replyTriggered = false;
    });
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final isUser = message.sender == MessageSender.user;
    final isSystem = message.sender == MessageSender.system;

    if (isSystem) return _buildSystemMessage(context);

    final bubbleContent = GestureDetector(
      onLongPress: () => _showContextMenu(context),
      onHorizontalDragUpdate: widget.onReply != null ? _onDragUpdate : null,
      onHorizontalDragEnd: widget.onReply != null ? _onDragEnd : null,
      onHorizontalDragCancel: widget.onReply != null ? _onDragCancel : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: widget.isHighlighted
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5)
            : Colors.transparent,
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
                  _buildTimestamp(context, isUser),
                  if (widget.showStatus) _buildMessageStatus(context),
                ],
              ),
            ),
            if (isUser) SizedBox(width: Spacing.sm.w),
            if (isUser && widget.showAvatar) _buildAvatar(context, isUser),
          ],
        ),
      ),
      ),
    );

    if (widget.onReply == null) return bubbleContent;

    // Wrap with slide indicator when reply is available.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Transform.translate(
          offset: Offset(_dragOffset, 0),
          child: bubbleContent,
        ),
        if (_dragOffset > 0)
          Positioned(
            left: 12,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Opacity(
                opacity: (_dragOffset / _replyThreshold).clamp(0.0, 1.0),
                child: Icon(
                  Icons.reply,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ─── Bubble ───────────────────────────────────────────────────────────────

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.replyToMessage != null)
              _buildReplyPreview(context, isUser),
            _buildBubbleContent(context, isUser),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview(BuildContext context, bool isUser) {
    final reply = widget.replyToMessage!;
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = isUser
        ? Colors.black.withValues(alpha: 0.12)
        : colorScheme.surfaceContainerHighest;
    final borderColor = isUser
        ? colorScheme.onPrimary.withValues(alpha: 0.6)
        : colorScheme.primary;
    final textColor =
        isUser ? colorScheme.onPrimary : colorScheme.onSurface;

    return GestureDetector(
      onTap: widget.onReplyPreviewTapped,
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(color: borderColor, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              reply.sender == MessageSender.user
                  ? 'You'
                  : (widget.otherName ?? 'Other'),
              style: TextStyle(
                color: borderColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              reply.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.75),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubbleContent(BuildContext context, bool isUser) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = isUser ? colorScheme.onPrimary : colorScheme.onSurface;
    final meta = widget.message.metadata;

    // Structured message types — dispatch before the generic switch.
    if (meta != null) {
      final type = meta['type'] as String?;
      if (type == 'profile_card') {
        return ProfileCardBubble(metadata: meta, isUser: isUser);
      }
      if (type == 'location') {
        return LocationBubble(
          metadata: meta,
          fileUrl: widget.message.fileUrl,
          isUser: isUser,
        );
      }
    }

    switch (widget.message.type) {
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
          _iconForMime(widget.message.fileName ?? ''),
          textColor,
          isUser: isUser,
        );

      default:
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
          child: Text(
            widget.message.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: textColor,
            ),
          ),
        );
    }
  }

  Widget _buildImageContent(BuildContext context, Color textColor) {
    final fileUrl = widget.message.fileUrl;
    final localPath = widget.message.localFilePath;
    final progress = widget.uploadProgress;

    Widget imageWidget;
    if (fileUrl != null) {
      // Confirmed upload — load from CDN. If we still have the local file
      // (localPath was preserved through the optimistic→confirmed swap and the
      // subsequent Sendbird network refresh), use it as the placeholder so the
      // user never sees a spinner flash. Also use it as the error fallback in
      // case the CDN URL is temporarily unreachable.
      imageWidget = GestureDetector(
        onTap: () => _openFullImage(context, fileUrl),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 220.w, maxHeight: 200.h),
          child: Hero(
            tag: 'chat_image_${widget.message.id}',
            child: CachedNetworkImage(
            imageUrl: fileUrl,
            fit: BoxFit.cover,
            width: 220.w,
            placeholder:
                localPath != null
                    ? (_, __) => Image.file(
                      File(localPath),
                      fit: BoxFit.cover,
                      width: 220.w,
                    )
                    : (_, __) => SizedBox(
                      width: 220.w,
                      height: 150.h,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
            errorWidget:
                localPath != null
                    ? (_, __, ___) => Image.file(
                      File(localPath),
                      fit: BoxFit.cover,
                      width: 220.w,
                    )
                    : (_, __, ___) => SizedBox(
                      width: 220.w,
                      height: 100.h,
                      child: const Center(child: Icon(Icons.broken_image)),
                    ),
          ),
          ),
        ),
      );
    } else if (localPath != null) {
      // Optimistic — show local file while uploading.
      imageWidget = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 220.w, maxHeight: 200.h),
        child: Image.file(
          File(localPath),
          fit: BoxFit.cover,
          width: 220.w,
          errorBuilder: (_, __, ___) => SizedBox(
            width: 220.w,
            height: 100.h,
            child: const Center(child: Icon(Icons.broken_image)),
          ),
        ),
      );
    } else {
      imageWidget = const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        imageWidget,
        // Upload progress bar beneath the image thumbnail.
        if (progress != null)
          Padding(
            padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: textColor.withValues(alpha: 0.2),
                  color: textColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        if (widget.message.content.isNotEmpty &&
            widget.message.content != 'Sent a file')
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            child: Text(
              widget.message.content,
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
    final progress = widget.uploadProgress;
    final fileUrl = widget.message.fileUrl;

    final body = Padding(
      padding: EdgeInsets.all(10.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      widget.message.fileName ?? widget.message.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.message.fileSize != null)
                      Text(
                        _formatFileSize(widget.message.fileSize!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
              ),
              if (fileUrl != null && progress == null)
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Icon(
                    Icons.download_rounded,
                    size: 18.h,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
          if (progress != null) ...[
            SizedBox(height: 6.h),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: textColor.withValues(alpha: 0.2),
              color: textColor,
              borderRadius: BorderRadius.circular(4),
            ),
            SizedBox(height: 2.h),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );

    if (fileUrl != null && progress == null) {
      return InkWell(
        onTap: () => _openUrl(fileUrl),
        borderRadius: BorderRadius.circular(20),
        child: body,
      );
    }
    return body;
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ─── Context menu ─────────────────────────────────────────────────────────

  void _showContextMenu(BuildContext context) {
    HapticFeedback.mediumImpact();

    final message = widget.message;
    final withinEditWindow =
        DateTime.now().difference(message.timestamp).inMinutes < 15;

    final canEdit =
        widget.onEdit != null &&
        message.sender == MessageSender.user &&
        message.type == MessageType.text &&
        withinEditWindow;
    final canDelete =
        widget.onDelete != null && message.sender == MessageSender.user;
    final canCopy = message.type == MessageType.text;
    final canReply = widget.onReply != null;

    if (!canEdit && !canDelete && !canCopy && !canReply) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MessageContextMenu(
        message: message,
        onCopy: canCopy
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
        onReply: canReply ? widget.onReply : null,
        onEdit: canEdit ? widget.onEdit : null,
        onDelete: canDelete ? () => _confirmDelete(context) : null,
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
              widget.onDelete?.call();
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
    final heroTag = 'chat_image_${widget.message.id}';
    final localPath = widget.message.localFilePath;
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          // G6: swipe-down or tap background to dismiss.
          body: GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            onVerticalDragEnd: (d) {
              if ((d.primaryVelocity ?? 0).abs() > 300) {
                Navigator.of(context).maybePop();
              }
            },
            child: Center(
              child: Hero(
                tag: heroTag,
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                    placeholder: localPath != null
                        ? (_, __) => Image.file(File(localPath))
                        : (_, __) => const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                    errorWidget: (_, __, ___) => localPath != null
                        ? Image.file(File(localPath))
                        : const Icon(Icons.broken_image,
                            color: Colors.white54, size: 64),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Avatar ───────────────────────────────────────────────────────────────

  Widget _buildAvatar(BuildContext context, bool isUser) {
    final colorScheme = Theme.of(context).colorScheme;
    final url = isUser ? null : widget.otherAvatarUrl;

    final fallback = Icon(
      Icons.person,
      size: 16.h,
      color: isUser ? colorScheme.onPrimary : colorScheme.onSurface,
    );

    // G7: cached avatar with graceful fallback. CachedNetworkImageProvider
    // caches to disk so we don't refetch the avatar on every rebuild/scroll.
    return CircleAvatar(
      radius: 14.h,
      backgroundColor:
          isUser ? colorScheme.primary : colorScheme.surfaceContainerHighest,
      backgroundImage: (url != null && url.isNotEmpty)
          ? CachedNetworkImageProvider(url)
          : null,
      child: (url == null || url.isEmpty) ? fallback : null,
    );
  }

  // ─── System message ───────────────────────────────────────────────────────

  Widget _buildSystemMessage(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 24.w),
        child: Text(
          widget.message.content,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  // ─── Timestamp ────────────────────────────────────────────────────────────

  Widget _buildTimestamp(BuildContext context, bool isUser) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Text(
        _formatTime(widget.message.timestamp),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          fontSize: 10.sp,
        ),
      ),
    );
  }

  static String _formatTime(DateTime ts) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(ts.year, ts.month, ts.day);
    final time =
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';

    if (msgDay == today) return time;

    final yesterday = today.subtract(const Duration(days: 1));
    if (msgDay == yesterday) return 'Yesterday $time';

    if (now.difference(ts).inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${days[ts.weekday - 1]} $time';
    }

    return '${ts.day}/${ts.month} $time';
  }

  // ─── Status row ───────────────────────────────────────────────────────────

  Widget _buildMessageStatus(BuildContext context) {
    final message = widget.message;
    if (message.sender != MessageSender.user) return const SizedBox.shrink();

    final IconData icon;
    String label;
    Color color =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);

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
        // G1: when a retry handler is available, invite the tap explicitly.
        label = widget.onRetry != null ? 'Failed — tap to retry' : 'Failed';
        color = Theme.of(context).colorScheme.error;
        break;
    }

    final row = Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.h, color: color),
          SizedBox(width: 3.w),
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

    // Failed messages are tappable to re-send.
    if (message.status == MessageStatus.failed && widget.onRetry != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onRetry,
        child: row,
      );
    }
    return row;
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
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _MessageContextMenu({
    required this.message,
    this.onCopy,
    this.onReply,
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
            if (onReply != null)
              _MenuItem(
                icon: Icons.reply,
                label: 'Reply',
                onTap: () {
                  Navigator.pop(context);
                  onReply!();
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
    final effectiveColor = color ?? Theme.of(context).colorScheme.onSurface;
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
