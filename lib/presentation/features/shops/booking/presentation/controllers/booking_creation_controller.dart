// lib/features/booking/presentation/controllers/booking_creation_controller.dart

import 'package:nano_embryo/presentation/features/freelancer/presentation/providers/freelancer_details_provider.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/providers/is_freelancer_provider.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/services/notification_service.dart';
import 'package:nano_embryo/presentation/features/shops/wallet/data/models/wallet_transaction_model.dart';
import 'package:nano_embryo/presentation/features/shops/wallet/providers/wallet_providers.dart';
import 'package:nano_embryo/core/notifications/domain/usecases/schedule_booking_reminders.dart';
import 'package:nano_embryo/core/notifications/utils/notification_date_time_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';

part 'booking_creation_controller.g.dart';

// Add a helper provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  // This will be provided by your notification module
  throw UnimplementedError(
    'Make sure notificationServiceProvider is available',
  );
});

/// State class for booking creation
class BookingCreationState {
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;
  final BookingModel? createdBooking;
  final String? idempotencyKey;

  const BookingCreationState({
    required this.isSubmitting,
    required this.isSuccess,
    this.error,
    this.createdBooking,
    this.idempotencyKey,
  });

  factory BookingCreationState.initial() {
    return const BookingCreationState(
      isSubmitting: false,
      isSuccess: false,
      error: null,
      createdBooking: null,
      idempotencyKey: null,
    );
  }

  BookingCreationState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    String? error,
    BookingModel? createdBooking,
    String? idempotencyKey,
  }) {
    return BookingCreationState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
      createdBooking: createdBooking ?? this.createdBooking,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    );
  }

  bool get hasError => error != null;
  bool get canSubmit => !isSubmitting && !isSuccess;
}

/// Controller responsible for creating bookings after payment.
///
/// Handles the final booking submission with proper error handling,
/// idempotency, and race condition management.
///
/// ## Features
/// - Idempotency key generation to prevent duplicate bookings
/// - Comprehensive error handling for all booking exceptions
/// - Multi-service booking support
/// - Post-submission state management
///
/// ## Usage
/// ```dart
/// // After successful payment
/// ref.read(bookingCreationControllerProvider.notifier)
///    .createBooking(userId, shopId);
/// ```
@riverpod
class BookingCreationController extends _$BookingCreationController {
  @override
  BookingCreationState build() {
    // Generate idempotency key at start
    final idempotencyKey = const Uuid().v4();

    return BookingCreationState.initial().copyWith(
      idempotencyKey: idempotencyKey,
    );
  }

  /// Creates a booking after successful payment
  Future<BookingModel?> createBooking({
    required String userId,
    required String shopId,
    required double latitude,
    required double longitude,
    required String shopAddress,
    String? paymentIntentId,
    required String clientName,
    required String shopName,
  }) async {
    // Prevent double submission
    if (state.isSubmitting || state.isSuccess) {
      return state.createdBooking;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      // Gather all selections
      // Gather all selections
      final services = ref.read(selectedServicesProvider);
      final workers = ref.read(selectedWorkersProvider);
      final date = ref.read(selectedDateProvider);
      final quantities = ref.read(serviceQuantityProvider);

      // NEW: Get time slots map and view mode
      final timeSlots = ref.read(selectedTimeSlotsProvider);
      final isCombinedView = ref.read(isCombinedViewProvider);

      // Validate that all services have time slots
      if (isCombinedView) {
        // In combined view, we need at least one slot
        if (timeSlots.isEmpty) {
          throw BookingValidationException({
            'timeSlot': 'No time slot selected',
          });
        }
      } else {
        // In regular view, each service needs its own slot
        for (var service in services) {
          if (!timeSlots.containsKey(service.id)) {
            throw BookingValidationException({
              service.id: 'No time slot selected for ${service.serviceName}',
            });
          }
        }
      }

      // Calculate totals with quantities
      final totalAmount = _calculateTotalAmount(services, quantities);
      final depositAmount = totalAmount * 0.3;

      // We'll create multiple bookings or a single booking with multiple services
      // For now, we'll create one booking with all services

      // Use the first time slot as reference for the booking times
      // (In reality, you might need to handle overlapping times)
      final firstSlot = timeSlots.values.first;

      // Calculate actual end time with buffer (using the longest slot if multiple)
      final actualEndTime = _calculateActualEndTimeForMultipleSlots(
        timeSlots.values.toList(),
        services,
        quantities,
      );

      // Create booking model
      final booking = BookingModel(
        id: const Uuid().v4(),
        userId: userId,
        shopId: shopId,
        bookingDate: date,
        startTime: firstSlot.startTime, // Use earliest start time
        endTime: _getLatestEndTime(
          timeSlots.values.toList(),
        ), // Use latest end time
        actualEndTime: actualEndTime,
        status: BookingStatus.confirmed,
        // paymentIntentId != null
        //     ? BookingStatus.confirmed
        //     : BookingStatus.pending,
        totalAmount: totalAmount,
        paymentStatus:
            paymentIntentId != null ? PaymentStatus.paid : PaymentStatus.unpaid,
        paymentIntentId: paymentIntentId,
        depositAmount: depositAmount ?? 0,
        platformFee: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        latitude: latitude,
        longitude: longitude,
        shopAddress: shopAddress,
      );

      // Create booking services (this already handles per-service data)
      final bookingServices = _createBookingServices(
        booking.id,
        services,
        workers,
        quantities,
        timeSlots, // PASS THE TIME SLOTS!
      );

      // Submit to repository
      final repository = ref.read(bookingRepositoryProvider);
      final createdBooking = await repository.createBooking(
        booking: booking,
        services: bookingServices,
        idempotencyKey: state.idempotencyKey,
      );

      //  SEND NOTIFICATIONS
      await _sendBookingNotifications(
        createdBooking,
        services,
        userId,
        shopId,
        clientName,
        shopName,
      );

      // Update state on success
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: true,
        createdBooking: createdBooking,
      );

      // Invalidate relevant providers
      _invalidateProviders();
      await _addWalletTransaction(createdBooking);

      return createdBooking;
    } on SlotUnavailableException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error:
            'The selected time slot is no longer available. Please choose another.',
      );
      return null;
    } on WorkerUnavailableException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'The selected worker is no longer available at this time.',
      );
      return null;
    } on SlotFullException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'This time slot has reached maximum capacity.',
      );
      return null;
    } on OutsideBusinessHoursException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'This time is outside the shop\'s business hours.',
      );
      return null;
    } on BookingConflictException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'This booking conflicted with another. Please try again.',
      );
      return null;
    } catch (e, stackTrace) {
      if (e is DatabaseBookingException) {
      } else {}
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to create booking: ${e.toString()}',
      );
      return null;
    }
  }

  // ============================================
  // NEW METHOD: Send notifications for booking
  // ============================================

  /// Send notifications for a newly created booking
  Future<void> _sendBookingNotifications(
    BookingModel booking,
    List<AppointmentSlotDTO> services,
    String userId,
    String shopOwnerId,
    String clientName,
    String shopName,
  ) async {
    try {
      final notificationService = ref.read(notificationServiceProvider);

      // Get shop owner ID (you may need to fetch this)

      // Get client name (you may need to fetch this)

      // Get service names
      final serviceNames = services.map((s) => s.serviceName).join(', ');

      // 1. Send immediate notification to shop
      await notificationService.notifyShopNewBooking(
        shopOwnerId: shopOwnerId,
        userName: clientName,
        serviceNames: serviceNames,
        bookingId: booking.id,
        shopId: booking.shopId,
        startTime: booking.startTime,
      );

      // 2. Schedule reminders for client and shop
      final appointmentDateTime = NotificationDateTimeUtils.combineDateAndTime(
        booking.bookingDate,
        booking.startTime,
      );

      // Calculate total duration from services
      final totalDuration = _calculateTotalDuration(services);

      final reminderParams = ScheduleBookingRemindersParams(
        bookingId: booking.id,
        userId: userId,
        shopId: booking.shopId,
        shopOwnerId: shopOwnerId,
        userName: clientName,
        shopName: shopName,
        serviceNames: [serviceNames],
        bookingDate: booking.bookingDate,
        startTime: booking.startTime,
        duration: totalDuration,
      );

      await notificationService.scheduleBookingReminders(reminderParams);

      // print('✅ Notifications sent for booking: ${booking.id}');
    } catch (e) {
      // Don't rethrow - notification failure shouldn't break booking flow
      print('❌ Failed to send notifications: $e');
    }
  }

  /// Calculate total duration from services
  Duration _calculateTotalDuration(List<AppointmentSlotDTO> services) {
    Duration total = Duration.zero;
    for (final service in services) {
      total += DurationUtils.parse(service.duration);
    }
    return total;
  }

  // After booking is successfully created and confirmed
  // After booking is successfully created and confirmed
  Future<void> _addWalletTransaction(BookingModel booking) async {
    try {
      final walletRepository = ref.read(walletRepositoryProvider);

      // Add deposit transaction
      await walletRepository.addTransaction(
        shopId: booking.shopId,
        amount: booking.depositAmount,
        type: TransactionType.deposit,
        bookingId: booking.id,
        description: 'Deposit for booking #${booking.id.substring(0, 8)}',
      );

      print('Wallet transaction added for booking ${booking.id}');
    } catch (e) {
      // Log error but don't fail the booking

      // You might want to send this to a monitoring service
    }
  }

  // Helper method to get the latest end time from multiple slots
  DateTime _getLatestEndTime(List<TimeSlotModel> slots) {
    if (slots.isEmpty) return DateTime.now();
    return slots.reduce((a, b) => a.endTime.isAfter(b.endTime) ? a : b).endTime;
  }

  // Helper to calculate actual end time for multiple slots
  DateTime _calculateActualEndTimeForMultipleSlots(
    List<TimeSlotModel> slots,
    List<AppointmentSlotDTO> services,
    Map<String, int> quantities,
  ) {
    if (slots.isEmpty) return DateTime.now();
    // Use the latest actualEndTime from all slots
    return slots
        .reduce((a, b) => a.actualEndTime.isAfter(b.actualEndTime) ? a : b)
        .actualEndTime;
  }

  double _calculateTotalAmount(
    List<AppointmentSlotDTO> services,
    Map<String, int> quantities,
  ) {
    return services.fold<double>(
      0,
      (sum, service) => sum + (service.price * (quantities[service.id] ?? 1)),
    );
  }

  /// Validates that all necessary selections are made
  void _validateSelections(
    List<AppointmentSlotDTO> services,
    TimeSlotModel? timeSlot,
    Map<String, int> quantities,
  ) {
    if (services.isEmpty) {
      throw BookingValidationException({'services': 'No services selected'});
    }

    if (timeSlot == null) {
      throw BookingValidationException({'timeSlot': 'No time slot selected'});
    }

    // Validate quantities don't exceed max clients
    for (var service in services) {
      final quantity = quantities[service.id] ?? 1;
      if (quantity > service.maxClients) {
        throw BookingValidationException({
          service.id:
              'Quantity exceeds maximum allowed (${service.maxClients})',
        });
      }
    }
  }

  /// Creates booking service models from selections

  List<BookingServiceModel> _createBookingServices(
    String bookingId,
    List<AppointmentSlotDTO> services,
    Map<String, List<Map<String, String?>>> workers,
    Map<String, int> quantities,
    Map<String, TimeSlotModel> timeSlots, // NEW PARAMETER
  ) {
    final List<BookingServiceModel> allServices = [];

    for (var service in services) {
      final quantity = quantities[service.id] ?? 1;
      final workerEntries =
          workers[service.id] ??
          List.generate(quantity, (_) => {'id': null, 'name': null});
      final duration = DurationUtils.parse(service.duration);
      final timeSlot = timeSlots[service.id]; // Get the slot for this service

      for (int i = 0; i < quantity; i++) {
        final workerEntry =
            workerEntries.length > i
                ? workerEntries[i]
                : {'id': null, 'name': null};

        allServices.add(
          BookingServiceModel(
            id: const Uuid().v4(),
            bookingId: bookingId,
            slotId: service.id,
            workerId: workerEntry['id'],
            priceAtBooking: service.price,
            durationMinutes: duration.inMinutes,
            createdAt: DateTime.now(),
            serviceName: service.serviceName,
            workerName: workerEntry['name'],
            // You might want to store the actual time per service
            startTime: timeSlot?.startTime ?? null,
            // endTime: timeSlot?.endTime,
          ),
        );
      }
    }

    return allServices;
  }

  /// Invalidates providers after successful booking
  void _invalidateProviders() {
    ref.invalidate(selectedServicesProvider);
    ref.invalidate(selectedWorkersProvider);
    ref.invalidate(selectedDateProvider);
    ref.invalidate(selectedTimeSlotsProvider);
    ref.invalidate(slotGenerationControllerProvider);
    // Also invalidate user's booking list if needed
    // ref.invalidate(userBookingsProvider);
  }

  /// Resets the controller for a new booking
  void reset() {
    // Generate new idempotency key
    final newKey = const Uuid().v4();

    state = BookingCreationState.initial().copyWith(idempotencyKey: newKey);
  }

  /// Clears any error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Add this method to the existing BookingCreationController class

  /// Creates a booking for a freelancer after successful payment
  Future<BookingModel?> createFreelancerBooking({
    required String userId,
    required String freelancerId,
    required String freelancerName,
    required double freelancerLat,
    required double freelancerLng,
    required int travelRadiusKm,
    required String clientName,
  }) async {
    // Prevent double submission
    if (state.isSubmitting || state.isSuccess) {
      return state.createdBooking;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      // Gather selections
      final services = ref.read(selectedServicesProvider);
      final date = ref.read(selectedDateProvider);
      final quantities = ref.read(serviceQuantityProvider);
      final timeSlots = ref.read(selectedTimeSlotsProvider);
      final isCombinedView = ref.read(isCombinedViewProvider);
      final serviceAddress = ref.read(selectedAddressProvider);

      // Validate selections
      if (services.isEmpty) {
        throw BookingValidationException({'services': 'No services selected'});
      }

      if (isCombinedView) {
        if (timeSlots.isEmpty) {
          throw BookingValidationException({
            'timeSlot': 'No time slot selected',
          });
        }
      } else {
        for (var service in services) {
          if (!timeSlots.containsKey(service.id)) {
            throw BookingValidationException({
              service.id: 'No time slot selected for ${service.serviceName}',
            });
          }
        }
      }

      // Validate address for traveling freelancers
      final freelancerDetails = await ref.read(
        freelancerDetailsProvider(freelancerId).future,
      );
      if (freelancerDetails?.canTravel == true && serviceAddress == null) {
        throw BookingValidationException({
          'address': 'Service address required',
        });
      }

      // Validate distance if address provided
      if (serviceAddress != null &&
          serviceAddress.latitude != null &&
          serviceAddress.longitude != null) {
        final locationService = ref.read(locationServiceProvider);
        final distance = locationService.calculateDistance(
          freelancerLat,
          freelancerLng,
          serviceAddress.latitude!,
          serviceAddress.longitude!,
        );

        if (distance > travelRadiusKm) {
          throw BookingValidationException({
            'address':
                'Address is outside freelancer\'s service area (${distance.toStringAsFixed(1)}km > ${travelRadiusKm}km)',
          });
        }
      }

      // Calculate totals
      final totalAmount = _calculateTotalAmount(services, quantities);
      final depositAmount = totalAmount * 0.3;

      // Get the first time slot as reference
      final firstSlot = timeSlots.values.first;

      // Calculate actual end time with buffer
      final actualEndTime = _calculateActualEndTimeForMultipleSlots(
        timeSlots.values.toList(),
        services,
        quantities,
      );

      // Create booking model with freelancer as shop_id
      final booking = BookingModel(
        id: const Uuid().v4(),
        userId: userId,
        shopId: freelancerId, // Freelancer ID stored in shop_id
        bookingDate: date,
        startTime: firstSlot.startTime,
        endTime: _getLatestEndTime(timeSlots.values.toList()),
        actualEndTime: actualEndTime,
        status: BookingStatus.confirmed,
        totalAmount: totalAmount,
        paymentStatus: PaymentStatus.paid,
        depositAmount: depositAmount,
        platformFee: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        latitude: serviceAddress?.latitude ?? freelancerLat,
        longitude: serviceAddress?.longitude ?? freelancerLng,
        shopAddress: serviceAddress?.fullAddress ?? '',
      );

      // Create booking services (worker_id = null for freelancers)
      final bookingServices = _createFreelancerBookingServices(
        booking.id,
        services,
        quantities,
        timeSlots,
      );

      // Submit to repository
      final repository = ref.read(bookingRepositoryProvider);
      final createdBooking = await repository.createFreelancerBooking(
        booking: booking,
        services: bookingServices,
        idempotencyKey: state.idempotencyKey,
      );

      await _sendBookingNotifications(
        createdBooking,
        services,
        userId,
        freelancerId,
        clientName,
        freelancerName,
      );

      // Update state
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: true,
        createdBooking: createdBooking,
      );

      // Invalidate providers
      _invalidateProviders();

      return createdBooking;
    } on SlotUnavailableException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error:
            'The selected time slot is no longer available. Please choose another.',
      );
      return null;
    } on BookingConflictException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'This booking conflicted with another. Please try again.',
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to create booking: ${e.toString()}',
      );
      return null;
    }
  }

  /// Creates booking service models for freelancer (no worker assignment)
  List<BookingServiceModel> _createFreelancerBookingServices(
    String bookingId,
    List<AppointmentSlotDTO> services,
    Map<String, int> quantities,
    Map<String, TimeSlotModel> timeSlots,
  ) {
    final List<BookingServiceModel> allServices = [];

    for (var service in services) {
      final quantity = quantities[service.id] ?? 1;
      final timeSlot = timeSlots[service.id];
      final duration = DurationUtils.parse(service.duration);

      for (int i = 0; i < quantity; i++) {
        allServices.add(
          BookingServiceModel(
            id: const Uuid().v4(),
            bookingId: bookingId,
            slotId: service.id,
            workerId: null, // No worker for freelancer
            priceAtBooking: service.price,
            durationMinutes: duration.inMinutes,
            createdAt: DateTime.now(),
            serviceName: service.serviceName,
            workerName: null,
            startTime: timeSlot?.startTime,
          ),
        );
      }
    }

    return allServices;
  }
}
