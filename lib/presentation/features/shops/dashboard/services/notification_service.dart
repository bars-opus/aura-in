// lib/features/notifications/services/notification_service.dart

import 'package:flutter/foundation.dart';
import 'package:nano_embryo/presentation/features/search/presentation/state/search_providers.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/services/notification_service.dart';
import 'package:nano_embryo/core/notifications/data/repositories/notification_repository_impl.dart';
import 'package:nano_embryo/core/notifications/data/repositories/notification_repository_interface.dart';
import 'package:nano_embryo/core/notifications/domain/entities/app_notification.dart';
import 'package:nano_embryo/core/notifications/domain/usecases/cancel_booking_notifications.dart';
import 'package:nano_embryo/core/notifications/domain/usecases/get_unread_count.dart';
import 'package:nano_embryo/core/notifications/domain/usecases/get_user_notifications.dart';
import 'package:nano_embryo/core/notifications/domain/usecases/mark_notification_as_read.dart';
import 'package:nano_embryo/core/notifications/domain/usecases/notify_new_shop_nearby.dart';
import 'package:nano_embryo/core/notifications/domain/usecases/register_push_token.dart';
import 'package:nano_embryo/core/notifications/domain/usecases/schedule_booking_reminders.dart';
import 'package:nano_embryo/core/notifications/domain/usecases/send_immediate_notification.dart';
import 'package:nano_embryo/core/notifications/presentation/providers/notification_notifier.dart';
import 'package:nano_embryo/core/notifications/presentation/providers/notification_settings_notifier.dart';
import 'package:nano_embryo/core/notifications/presentation/providers/notification_state.dart';
import 'package:nano_embryo/core/notifications/utils/notification_date_time_utils.dart';
import 'package:supabase/src/supabase_client.dart';

/// Main service class for handling all notification operations
/// This is the primary interface for the rest of the app to use
class NotificationService {
  final ScheduleBookingRemindersUseCase _scheduleRemindersUseCase;
  final SendImmediateNotificationUseCase _sendImmediateUseCase;
  final CancelBookingNotificationsUseCase _cancelBookingUseCase;
  final RegisterPushTokenUseCase _registerPushTokenUseCase;
  final NotifyNewShopNearbyUseCase _notifyNewShopNearbyUseCase;
  final GetUserNotificationsUseCase _getUserNotificationsUseCase;
  final MarkNotificationAsReadUseCase _markAsReadUseCase;
  final GetUnreadCountUseCase _getUnreadCountUseCase;

  NotificationService({
    required ScheduleBookingRemindersUseCase scheduleRemindersUseCase,
    required SendImmediateNotificationUseCase sendImmediateUseCase,
    required CancelBookingNotificationsUseCase cancelBookingUseCase,
    required RegisterPushTokenUseCase registerPushTokenUseCase,
    required NotifyNewShopNearbyUseCase notifyNewShopNearbyUseCase,
    required GetUserNotificationsUseCase getUserNotificationsUseCase,
    required MarkNotificationAsReadUseCase markAsReadUseCase,
    required GetUnreadCountUseCase getUnreadCountUseCase,
    // required SupabaseClient supabaseClient,
  }) : _scheduleRemindersUseCase = scheduleRemindersUseCase,
       _sendImmediateUseCase = sendImmediateUseCase,
       _cancelBookingUseCase = cancelBookingUseCase,
       _registerPushTokenUseCase = registerPushTokenUseCase,
       _notifyNewShopNearbyUseCase = notifyNewShopNearbyUseCase,
       _getUserNotificationsUseCase = getUserNotificationsUseCase,
       _markAsReadUseCase = markAsReadUseCase,
       _getUnreadCountUseCase = getUnreadCountUseCase;

  /// Schedule all reminders for a booking
  /// Call this right after a booking is created
  Future<void> scheduleBookingReminders(
    ScheduleBookingRemindersParams params,
  ) async {
    try {
      await _scheduleRemindersUseCase(params);
      if (kDebugMode) {
        print('✅ Scheduled reminders for booking: ${params.bookingId}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to schedule reminders: $e');
      }
      // Don't rethrow - notification failure shouldn't break booking flow
    }
  }

  Future<void> sendImmediateNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String priority = 'normal',
  }) async {
    try {
      await _sendImmediateUseCase(
        SendImmediateNotificationParams(
          userId: userId,
          title: title,
          body: body,
          data: data,
          priority: priority,
        ),
      );
      if (kDebugMode) {
        print('✅ Sent immediate notification to user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to send immediate notification: $e');
      }
    }
  }

  /// Send immediate notification to shop when new booking is created
  Future<void> notifyShopNewBooking({
    required String shopOwnerId,
    required String userName,
    required String serviceNames,
    required String bookingId,
    required String shopId,
    required DateTime startTime,
  }) async {
    try {
      await _sendImmediateUseCase(
        SendImmediateNotificationParams(
          userId: shopOwnerId,
          title: 'New Booking Received!',
          body:
              '$userName booked $serviceNames at ${NotificationDateTimeUtils.formatTime(startTime)}',
          data: {
            'type': 'new_booking',
            'booking_id': bookingId,
            'shop_id': shopId,
            'user_name': userName,
          },
          priority: 'high',
        ),
      );
      if (kDebugMode) {
        print('✅ Sent new booking notification to shop: $shopOwnerId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to send shop notification: $e');
      }
    }
  }

  /// Notify nearby users when a new shop is created
  Future<void> notifyNearbyUsersNewShop({
    required String shopId,
    required String shopName,
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) async {
    try {
      await _notifyNewShopNearbyUseCase(
        NotifyNewShopNearbyParams(
          shopId: shopId,
          shopName: shopName,
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
        ),
      );
      if (kDebugMode) {
        print('✅ Sent nearby user notifications for shop: $shopName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to send nearby notifications: $e');
      }
    }
  }

  /// Cancel all notifications for a booking (e.g., when booking is cancelled)
  Future<void> cancelBookingNotifications(String bookingId) async {
    try {
      final cancelledCount = await _cancelBookingUseCase(bookingId);
      if (kDebugMode) {
        print(
          '✅ Cancelled $cancelledCount notifications for booking: $bookingId',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to cancel notifications: $e');
      }
    }
  }

  /// Register device push token for a user
  Future<void> registerPushToken({
    required String userId,
    required String token,
    required String platform,
  }) async {
    try {
      await _registerPushTokenUseCase(
        RegisterPushTokenParams(
          userId: userId,
          token: token,
          platform: platform,
        ),
      );
      if (kDebugMode) {
        print('✅ Registered push token for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to register push token: $e');
      }
    }
  }

  /// Get all in-app notifications for current user
  Future<List<AppNotification>> getUserNotifications(String userId) async {
    try {
      return await _getUserNotificationsUseCase(userId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get notifications: $e');
      }
      return [];
    }
  }

  /// Mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _markAsReadUseCase(notificationId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to mark notification as read: $e');
      }
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount(String userId) async {
    try {
      return await _getUnreadCountUseCase(userId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get unread count: $e');
      }
      return 0;
    }
  }
}
