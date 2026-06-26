// NanoEmbryo-specific notification configuration.
//
// When copying this engine to a new app, replace the contents of this file
// with your own notification types, templates, tap-navigation logic, and
// setting toggles. Everything else in core/notifications/ is generic and
// can be copied unchanged.
//
// See NOTIFICATION_ENGINE.md for the full integration guide.

import 'package:go_router/go_router.dart';
import 'package:nano_embryo/app/routing/app_router.dart';
import 'package:nano_embryo/core/notifications/config/feature/notification_config.dart';
import 'package:nano_embryo/core/notifications/config/notification_setting_toggle.dart';
import 'package:nano_embryo/core/notifications/domain/entities/notification_template.dart';
import 'package:nano_embryo/core/notifications/domain/entities/notification_type.dart';

/// Returns the NanoEmbryo [NotificationConfig],
///
/// Pass this to [notificationConfigProvider] in the root [ProviderScope].
NotificationConfig buildNanoEmbryoNotificationConfig() {
  return NotificationConfig(
    appName: 'Aura In',
    defaultChannelId: 'booking_notifications',
    defaultChannelName: 'Booking Notifications',
    defaultReminderOffsets: const [
      Duration(hours: 24),
      Duration(hours: 1),
      Duration(minutes: 5),
      Duration(minutes: 15), // shop-owner reminder
    ],
    notificationTypes: {
      'booking_confirmation': NotificationType(
        value: 'booking_confirmation',
        priority: 8,
      ),
      'booking_reminder': NotificationType(
        value: 'booking_reminder',
        priority: 7,
      ),
      'new_review': NotificationType(value: 'new_review', priority: 6),
      'new_shop_nearby': NotificationType(
        value: 'new_shop_nearby',
        priority: 5,
      ),
      'order_placed': NotificationType(value: 'order_placed', priority: 8),
      'out_of_stock': NotificationType(value: 'out_of_stock', priority: 9),
    },
    templates: {
      'booking_confirmation_shop': NotificationTemplate(
        id: 'booking_confirmation_shop',
        titleTemplate: 'New Booking Received!',
        bodyTemplate: '{{user_name}} booked {{service_names}} at {{time}}',
      ),
      'booking_reminder_client': NotificationTemplate(
        id: 'booking_reminder_client',
        titleTemplate: 'Appointment {{offset_text}}',
        bodyTemplate:
            'Your {{service_names}} appointment is {{offset_text}} at {{time}}',
      ),
    },
    // ── Navigation from notification tap ──────────────────────────────────────
    // The router is obtained from GoRouter via context so we don't need
    // the global _appRouter here.
    onNotificationTap: (notification, context) {
      final type = notification.data?['type'] as String?;
      final shopId = notification.data?['shop_id'] as String?;
      final bookingId = notification.data?['booking_id'] as String?;
      final orderId = notification.data?['order_id'] as String?;

      if (type == 'booking_reminder_24h' ||
          type == 'booking_reminder_1h' ||
          type == 'booking_reminder_5min' ||
          type == 'shop_reminder_15min' ||
          type == 'booking_confirmation' ||
          type == 'booking_created' ||
          type == 'booking_confirmed' ||
          type == 'booking_cancelled' ||
          type == 'new_booking' ||
          type == 'new_booking_shop') {
        if (bookingId != null && bookingId.isNotEmpty) {
          GoRouter.of(context).push(
            RouteNames.bookingDetail,
            extra: {'bookingId': bookingId},
          );
        } else {
          GoRouter.of(context).go(RouteNames.calendar);
        }
      } else if (type == 'new_shop_nearby') {
        if (shopId != null && shopId.isNotEmpty) {
          GoRouter.of(context).push(
            RouteNames.shopDetailsScreen,
            extra: {'shopId': shopId, 'coverImageUrl': ''},
          );
        } else {
          GoRouter.of(context).go(RouteNames.home);
        }
      } else if (type == 'review_request' || type == 'new_message') {
        final channelUrl = notification.data?['channel_url'] as String?;
        if (channelUrl != null && channelUrl.isNotEmpty) {
          GoRouter.of(context).push(
            '${RouteNames.chatChannel}?url=${Uri.encodeComponent(channelUrl)}',
          );
        } else {
          GoRouter.of(context).go(RouteNames.home);
        }
      } else if (type == 'order_placed') {
        final targetRole = notification.data?['target_role'] as String? ??
            notification.data?['role'] as String?;
        if (orderId != null && orderId.isNotEmpty) {
          if (targetRole == 'seller' ||
              targetRole == 'shop_owner' ||
              targetRole == 'shop') {
            if (shopId != null && shopId.isNotEmpty) {
              GoRouter.of(context).push(
                RouteNames.shopOrderDetail,
                extra: {'orderId': orderId, 'shopId': shopId},
              );
            } else {
              GoRouter.of(context).go(RouteNames.home);
            }
          } else {
            GoRouter.of(context).push(
              RouteNames.customerOrderDetail,
              extra: orderId,
            );
          }
        } else {
          GoRouter.of(context).go(RouteNames.home);
        }
      } else if (type == 'out_of_stock') {
        if (shopId != null && shopId.isNotEmpty) {
          GoRouter.of(context).push(RouteNames.shopProducts, extra: shopId);
        } else {
          GoRouter.of(context).go(RouteNames.home);
        }
      } else {
        GoRouter.of(context).go(RouteNames.home);
      }
    },
    // ── App-specific settings toggles ─────────────────────────────────────────
    settingToggles: [
      NotificationSettingToggle(
        label: 'Booking Reminders',
        description: 'Reminders before your upcoming appointments',
        getValue: (state) => state.bookingRemindersEnabled,
        setValue: (notifier, value) =>
            notifier.setBookingRemindersEnabled(value),
      ),
      NotificationSettingToggle(
        label: 'New Shops Nearby',
        description: 'Get notified when new shops open near you',
        getValue: (state) => state.newShopsNearbyEnabled,
        setValue: (notifier, value) => notifier.setNewShopsNearbyEnabled(value),
      ),
    ],
  );
}
