import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/url_launcher_utils.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/presentation/features/shops/appointments/shop_daily_schedule/providers/daily_schedule_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart';

class SocialLinksBottomSheet extends ConsumerStatefulWidget {
  final String shopId;
  final String? shopName;

  const SocialLinksBottomSheet({
    super.key,
    required this.shopId,
    this.shopName,
  });

  @override
  ConsumerState<SocialLinksBottomSheet> createState() =>
      _SocialLinksBottomSheetState();
}

class _SocialLinksBottomSheetState
    extends ConsumerState<SocialLinksBottomSheet> {
  late Future<List<SocialLinkDraft>> _socialLinksFuture;

  @override
  void initState() {
    super.initState();
    final repository = ref.read(bookingRepositoryProvider);
    _socialLinksFuture = repository.getShopSocialLinks(widget.shopId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            margin: EdgeInsets.only(top: Spacing.sm.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(100.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(Spacing.md.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Connect with ${widget.shopName ?? 'Shop'}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onSurface),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Social Links List
          FutureBuilder<List<SocialLinkDraft>>(
            future: _socialLinksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: EdgeInsets.all(Spacing.xl.h),
                  child: const Center(child: CircularLoadingIndicator()),
                );
              }

              if (snapshot.hasError) {
                return _buildErrorState(context);
              }

              final socialLinks = snapshot.data ?? [];

              if (socialLinks.isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
                children: [
                  // Header Text
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.md.w,
                      vertical: Spacing.sm.h,
                    ),
                    child: Text(
                      'Follow us on social media',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),

                  // Social Links
                  ...socialLinks.map(
                    (link) => _buildSocialLinkItem(context, link),
                  ),

                  SizedBox(height: Spacing.md.h),
                ],
              );
            },
          ),

          SizedBox(height: Spacing.lg.h),
        ],
      ),
    );
  }

  Widget _buildSocialLinkItem(BuildContext context, SocialLinkDraft link) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => _launchSocialLink(context, link),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.md.w,
          vertical: Spacing.sm.h,
        ),
        child: Row(
          children: [
            // Platform Icon with Color Background
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: _getPlatformColor(link.platform).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                link.platform.icon,
                size: 24.h,
                color: _getPlatformColor(link.platform),
              ),
            ),
            SizedBox(width: Spacing.md.w),

            // Platform Name and URL
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    link.platform.displayName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _formatUrl(link.url),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Open Button
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.sm.w,
                vertical: Spacing.xs.h,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Text(
                    'Open',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: Spacing.xs.w),
                  Icon(
                    Icons.open_in_new,
                    size: 12.h,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.all(Spacing.xl.h),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48.w, color: colorScheme.error),
          SizedBox(height: Spacing.md.h),
          Text(
            'Failed to load social links',
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: Spacing.md.h),
          TextButton(
            onPressed: () {
              setState(() {
                final repository = ref.read(bookingRepositoryProvider);
                _socialLinksFuture = repository.getShopSocialLinks(
                  widget.shopId,
                );
              });
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.all(Spacing.xl.h),
      child: Column(
        children: [
          Icon(
            Icons.share,
            size: 48.w,
            color: colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: Spacing.md.h),
          Text(
            'No social media links available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          SizedBox(height: Spacing.sm.h),
          Text(
            'Check back later for updates!',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _launchSocialLink(BuildContext context, SocialLinkDraft link) {
    UrlLauncherUtils.launchUrlWithFeedback(
      context: context,
      url: link.url,
      errorMessage: 'Cannot open ${link.platform.displayName}',
    );
  }

  Color _getPlatformColor(SocialPlatform platform) {
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
        return const Color(0xFF0A66C2);
      case SocialPlatform.pinterest:
        return const Color(0xFFBD081C);
      case SocialPlatform.snapchat:
        return const Color(0xFFFFFC00);
      case SocialPlatform.whatsapp:
        return const Color(0xFF25D366);
      case SocialPlatform.website:
        return const Color(0xFF4285F4);
      default:
        return Colors.blue;
    }
  }

  String _formatUrl(String url) {
    return url
        .replaceAll('https://', '')
        .replaceAll('http://', '')
        .replaceAll('www.', '')
        .split('/')
        .first;
  }
}
