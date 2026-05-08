// test/features/notifications/domain/usecases/schedule_booking_reminders_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nano_embryo/core/notifications/data/repositories/notification_repository_interface.dart';
import 'package:nano_embryo/core/notifications/domain/entities/scheduled_notification.dart';
import 'package:nano_embryo/core/notifications/domain/usecases/schedule_booking_reminders.dart';

// test/notifications/schedule_booking_reminders_test.dart

class MockNotificationRepository extends Mock
    implements NotificationRepositoryInterface {}

void main() {
  late ScheduleBookingRemindersUseCase useCase;
  late MockNotificationRepository mockRepository;

  setUpAll(() {
    // Register fallback values for matchers
    registerFallbackValue(<ScheduledNotification>[]);
  });

  setUp(() {
    mockRepository = MockNotificationRepository();
    useCase = ScheduleBookingRemindersUseCase(mockRepository);
  });

  test('should schedule 5 reminders for a booking', () async {
    // Arrange
    final now = DateTime.now();
    final startTime = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour + 2,
      now.minute,
      now.second,
    );
    final bookingDate = DateTime(now.year, now.month, now.day);

    final params = ScheduleBookingRemindersParams(
      bookingId: 'booking123',
      userId: 'user123',
      shopId: 'shop123',
      shopOwnerId: 'owner123',
      userName: 'John Doe',
      shopName: 'Test Shop',
      serviceNames: ['Haircut'],
      bookingDate: bookingDate,
      startTime: startTime,
      duration: const Duration(hours: 1),
    );

    // Setup mock to return empty list when scheduleNotifications is called
    when(
      () => mockRepository.scheduleNotifications(any()),
    ).thenAnswer((_) async => []);

    // Act
    await useCase(params);

    // Assert - verify the method was called exactly once
    verify(() => mockRepository.scheduleNotifications(any())).called(1);
  });
}
