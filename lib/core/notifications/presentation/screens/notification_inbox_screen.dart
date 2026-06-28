import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/notifications/config/feature/notification_config.dart';
import 'package:nano_embryo/core/notifications/domain/entities/app_notification.dart';
import 'package:nano_embryo/core/notifications/presentation/providers/notification_notifier.dart';
import 'package:nano_embryo/core/notifications/presentation/providers/notification_provider.dart';
import 'package:nano_embryo/core/notifications/presentation/providers/notification_state.dart';
import 'package:nano_embryo/core/notifications/presentation/widgets/notification_list_tile.dart';
import 'package:nano_embryo/core/notifications/utils/notification_utils.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_context_provider.dart';

class NotificationInboxScreen extends ConsumerStatefulWidget {
  const NotificationInboxScreen({super.key});

  @override
  ConsumerState<NotificationInboxScreen> createState() =>
      _NotificationInboxScreenState();
}

class _NotificationInboxScreenState
    extends ConsumerState<NotificationInboxScreen> {
  String? _selectedTypeFilter;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(notificationListProvider.notifier).loadNotifications(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final notificationState = ref.watch(notificationListProvider);
    final notifier = ref.read(notificationListProvider.notifier);
    final selectedShopId = ref.watch(currentShopIdProvider);
    final shopScopedNotifications =
        notificationState.notifications
            .where(
              (notification) => notificationBelongsToShopContext(
                notification,
                selectedShopId,
              ),
            )
            .toList();
    final availableTypes = _extractAvailableTypes(shopScopedNotifications);
    final visibleNotifications =
        _selectedTypeFilter == null
            ? shopScopedNotifications
            : shopScopedNotifications
                .where(
                  (notification) =>
                      (notification.data?['type'] as String?) ==
                      _selectedTypeFilter,
                )
                .toList();

    return Scaffold(
      backgroundColor: colorScheme.neutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          'Notifications',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
        ),

        actions: [
          if (visibleNotifications.any((notification) => !notification.isRead))
            AppTextButton(
              text: 'Mark all as read',

              padding: const EdgeInsets.only(
                top: Spacing.md,
                right: Spacing.md,
              ),
              onPressed:
                  () => Future.wait(
                    visibleNotifications
                        .where((notification) => !notification.isRead)
                        .map(
                          (notification) =>
                              notifier.markAsRead(notification.id),
                        ),
                  ),
            ),

          AppIconButton(
            icon: Icons.sort,
            onPressed: () {
              _showTypeFilterSheet(context, availableTypes);
            },
          ),
        ],
      ),
      body: _buildBody(notificationState, visibleNotifications, notifier),
    );
  }

  Widget _buildBody(
    NotificationListState state,
    List<AppNotification> visibleNotifications,
    NotificationNotifier notifier,
  ) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(child: CircularLoadingIndicator());
    }

    if (state.error != null) {
      return Center(
        child: ErrorStateWidget(
          subtitle: state.error!,
          onPrimaryAction: () => notifier.loadNotifications(),
        ),
      );
    }

    if (visibleNotifications.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.notifications_none,
          title: 'No notifications yet',
          subtitle: 'We\'ll notify you when something arrives',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadNotifications(),
      child: ListView.builder(
        itemCount: visibleNotifications.length,
        padding: const EdgeInsets.only(top: Spacing.md),
        itemBuilder: (context, index) {
          final notification = visibleNotifications[index];
          return NotificationListTile(
            notification: notification,
            onTap: () => _handleTap(notification, notifier),
            onDismissed: () => notifier.deleteNotification(notification.id),
          );
        },
      ),
    );
  }

  Future<void> _handleTap(
    AppNotification notification,
    NotificationNotifier notifier,
  ) async {
    if (!notification.isRead) {
      await notifier.markAsRead(notification.id);
    }

    if (!mounted) return;

    // Delegate navigation to the app-specific config callback.
    // Apps configure this via notificationConfigProvider in ProviderScope.
    final config = ref.read(notificationConfigProvider);
    config.onNotificationTap?.call(notification, context);
  }

  void _showTypeFilterSheet(BuildContext context, List<String> availableTypes) {
    final colorScheme = Theme.of(context).colorScheme;
    final options = <String?>[null, ...availableTypes];

    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      maxHeight: 420.h,
      widget: ListView(
        padding: EdgeInsets.only(bottom: Spacing.xl.h),
        children: [
          Text(
            'Filter notifications',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          Gap(Spacing.md.h),
          AppDivider(),
          Gap(Spacing.md.h),
          ...options.map(
            (type) => InfoRowWidget(
              title:
                  type == null ? 'All notifications' : _formatTypeLabel(type),
              subtitle:
                  type == null
                      ? 'Show every notification type'
                      : 'Only show ${_formatTypeLabel(type).toLowerCase()}',
              icon:
                  type == null
                      ? Icons.notifications_active_outlined
                      : NotificationUtils.getIconForType(type),
              iconColor: colorScheme.primary,
              showDivider: true,
              showTrailingArrow: false,
              disableTrailing: _selectedTypeFilter != type,
              trailing:
                  _selectedTypeFilter == type
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
              onTap: () {
                setState(() {
                  _selectedTypeFilter = type;
                });
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> _extractAvailableTypes(List<AppNotification> notifications) {
    final types =
        notifications
            .map((notification) => notification.data?['type'] as String?)
            .whereType<String>()
            .toSet()
            .toList()
          ..sort((a, b) => _formatTypeLabel(a).compareTo(_formatTypeLabel(b)));

    return types;
  }

  String _formatTypeLabel(String type) {
    return type
        .split('_')
        .where((segment) => segment.isNotEmpty)
        .map(
          (segment) =>
              '${segment[0].toUpperCase()}${segment.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
