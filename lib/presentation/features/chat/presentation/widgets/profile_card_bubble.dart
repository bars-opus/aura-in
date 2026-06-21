import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ProfileCardBubble extends StatelessWidget {
  final Map<String, dynamic> metadata;
  final bool isUser;

  const ProfileCardBubble({
    super.key,
    required this.metadata,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = (metadata['name'] as String?)?.trim();
    final role = metadata['role'] as String? ?? 'user';
    final avatarUrl = metadata['avatarUrl'] as String?;
    final userId = metadata['userId'] as String? ?? '';

    final textColor = isUser ? colorScheme.onPrimary : colorScheme.onSurface;
    final dividerColor = textColor.withValues(alpha: 0.2);
    final subtleText = textColor.withValues(alpha: 0.65);

    return InkWell(
      onTap: () => context.go('/freelancer/$userId'),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                  backgroundImage:
                      (avatarUrl != null && avatarUrl.isNotEmpty)
                          ? CachedNetworkImageProvider(avatarUrl)
                          : null,
                  child:
                      (avatarUrl == null || avatarUrl.isEmpty)
                          ? Icon(Icons.person, color: colorScheme.primary, size: 24)
                          : null,
                ),
                SizedBox(width: 10.w),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name?.isNotEmpty == true ? name! : userId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _roleLabel(role),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: subtleText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Divider(color: dividerColor, height: 1),
            SizedBox(height: 6.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View Profile',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isUser ? colorScheme.onPrimary : colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: isUser ? colorScheme.onPrimary : colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'freelancer':
        return 'Freelancer';
      case 'shop_owner':
        return 'Shop Owner';
      default:
        return 'Member';
    }
  }
}
