import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

/// Predefined empty state types for common scenarios
enum EmptyStateType {
  noData, // No data available
  noResults, // Search returned no results
  noInternet, // No internet connection
  noFavorites, // No favorites saved
  noMessages, // No messages/conversations
  noShops,
  noWorker,

  custom, // Custom configuration
}

class EmptyStateWidget extends StatelessWidget {
  final EmptyStateType type;
  final String? title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  final Widget? customIllustration;
  final bool compact;

  const EmptyStateWidget({
    super.key,
    this.type = EmptyStateType.noData,
    this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.icon,
    this.customIllustration,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final config = _getConfiguration(context);

    return Container(
      color: Colors.transparent,
      padding:
          compact
              ? EdgeInsets.all(Spacing.xl.h)
              : EdgeInsets.symmetric(
                vertical: Spacing.xxl.h,
                horizontal: Spacing.xl.w,
              ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          if (customIllustration != null) ...[
            customIllustration!,
            Gap(compact ? Spacing.lg.h : Spacing.xxl.h),
          ] else if (config.$1 != null) ...[
            Icon(
              icon ?? config.$1,
              size: compact ? 50.h : 70.h,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            Gap(compact ? Spacing.md.h : Spacing.lg.h),
          ],

          // Title
          if (config.$2 != null || title != null)
            if (title != null)
              if (title!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: Spacing.sm.h),
                  child: Text(
                    title ?? config.$2!,
                    style:
                        compact
                            ? textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            )
                            : textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                    textAlign: TextAlign.center,
                  ),
                ),

          // Subtitle
          if (config.$3 != null || subtitle != null)
            Padding(
              padding: EdgeInsets.only(
                bottom: compact ? Spacing.lg.h : Spacing.xxl.h,
              ),
              child: Text(
                subtitle ?? config.$3!,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
                maxLines: compact ? 3 : 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Action Button (if provided)
          if (onAction != null)
            AppButton(
              height: 40.h,
              label: actionLabel ?? config.$4 ?? 'Retry',
              onPressed: onAction,
              padding: Spacing.horizontalMd,
              variant: ButtonVariant.outline,
              size: ButtonSize.small,
              outlineColor: Colors.transparent,
              width: double.infinity,
            ),
        ],
      ),
    );
  }

  // Returns: (icon, title, subtitle, actionLabel)
  (IconData?, String?, String?, String?) _getConfiguration(
    BuildContext context,
  ) {
    final loc = AppLocalizations.of(context);
    switch (type) {
      case EmptyStateType.noData:
        return (
          Icons.inbox_outlined,
          loc?.emptyStateNoDataTitle(loc.dataTypeData) ?? 'No data yet',
          loc?.emptyStateNoDataSubtitle(loc.dataTypeData) ??
              'When data becomes available, it will appear here.',
          loc?.emptyStateRefresh ?? 'Refresh',
        );
      case EmptyStateType.noResults:
        return (
          Icons.search_off_outlined,
          loc?.emptyStateNoResultsTitle ?? 'No results found',
          loc?.emptyStateNoResultsSubtitle(loc.dataTypeItems) ??
              'Try adjusting your search or filters to find items.',
          loc?.emptyStateClearFilters ?? 'Clear filters',
        );
      case EmptyStateType.noInternet:
        return (
          Icons.wifi_off_outlined,
          loc?.emptyStateNoInternetTitle ?? 'No internet connection',
          loc?.emptyStateNoInternetSubtitle ??
              'Check your connection and try again.',
          loc?.emptyStateRetry ?? 'Try again',
        );
      case EmptyStateType.noFavorites:
        return (
          Icons.favorite_border_outlined,
          loc?.emptyStateNoFavoritesTitle ?? 'No favorites yet',
          loc?.emptyStateNoFavoritesSubtitle ??
              'Start adding items to your favorites list.',
          loc?.emptyStateExplore ?? 'Explore',
        );
      case EmptyStateType.noMessages:
        return (
          Icons.forum_outlined,
          loc?.emptyStateNoMessagesTitle ?? 'No messages',
          loc?.emptyStateNoMessagesSubtitle ??
              'Start a conversation to see messages here.',
          loc?.emptyStateStartChat ?? 'Start chat',
        );
      case EmptyStateType.noShops:
        return (
          Icons.storefront_rounded,
          // loc?.emptyStateNoShopsTitle ??
          'No shops found',
          // loc?.emptyStateNoShopsSubtitle ??
          'Try expanding your search or change location.',
          loc?.emptyStateStartChat ?? 'Start chat',
        );

      case EmptyStateType.noWorker:
        return (
          FontAwesomeIcons.hands,
          // loc?.emptyStateNoShopsTitle ??
          'No worker selection needed',
          // loc?.emptyStateNoShopsSubtitle ??
          'Continue to Time Selection.',
          loc?.emptyStateStartChat ?? 'Continue',
        );

      case EmptyStateType.custom:
        return (null, null, null, null);
    }
  }
}
