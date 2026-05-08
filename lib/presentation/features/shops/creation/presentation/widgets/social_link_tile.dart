// lib/features/shop/creation/presentation/widgets/social_link_tile.dart

import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart'
    as social;
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart'
    show SocialPlatform;
import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';

class SocialLinkTile extends StatelessWidget {
  final social.SocialLinkDraft link;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isDraggable;

  const SocialLinkTile({
    super.key,
    required this.link,
    required this.onEdit,
    required this.onDelete,
    this.isDraggable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CardInkWell(
      elevation: isDraggable ? null : 0,
      margin: EdgeInsets.only(bottom: Spacing.xs),
      onTap: () {},
      padding:
          isDraggable
              ? null
              : EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.xs,
              ),
      child: InfoRowWidget(
        subtitle: _formatUrl(link.url),
        title: link.platform.displayName,
        subTitleMaxLines: 1,
        icon: link.platform.icon,
        iconColor: _getPlatformColor(link.platform),
        iconSize: 20.sp,
        backgroundColor: _getPlatformColor(link.platform).withOpacity(.3),
        onTap: () {},
        disableTrailing: false,
        showAvatar: false,
        showDivider: false,
        showTrailingArrow: false,
        trailing:
            isDraggable
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null)
                      AppIconButton(
                        icon: Icons.edit,
                        onPressed: onEdit,
                        iconColor: theme.colorScheme.primary,
                      ),

                    // IconButton(
                    //   icon: Icon(Icons.edit, size: 20.sp),
                    //   onPressed: onEdit,
                    //   color: theme.colorScheme.primary,
                    // ),
                    if (onDelete != null)
                      AppIconButton(
                        icon: Icons.delete,
                        onPressed: onDelete,

                        iconColor: theme.colorScheme.error,
                      ),
                    // IconButton(
                    //   icon: Icon(Icons.delete, size: 20.sp),
                    //   onPressed: onDelete,
                    //   color: theme.colorScheme.error,
                    // ),
                    if (isDraggable)
                      AppIconButton(
                        icon: Icons.drag_handle,
                        onPressed: onDelete,
                      ),
                    // Icon(
                    //   Icons.drag_handle,
                    //   color: theme.colorScheme.onSurface.withOpacity(0.3),
                    // ),
                  ],
                )
                : null,
      ),
    );
  }

  Color _getPlatformColor(social.SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.instagram:
        return const Color(0xFFE4405F);
      case SocialPlatform.facebook:
        return const Color(0xFF1877F2);
      case SocialPlatform.twitter:
        return const Color(0xFF1DA1F2);
      case SocialPlatform.tiktok:
        return const Color(0xFF000000);
      case SocialPlatform.youtube:
        return const Color(0xFFFF0000);
      case SocialPlatform.linkedin:
        return const Color(0xFF0077B5);
      case SocialPlatform.pinterest:
        return const Color(0xFFBD081C);
      case SocialPlatform.snapchat:
        return const Color(0xFFFFFC00);
      case SocialPlatform.whatsapp:
        return const Color(0xFF25D366);
      default:
        return Colors.grey;
    }
  }

  String _formatUrl(String url) {
    return url.replaceAll('https://', '').replaceAll('http://', '');
  }
}
