// lib/features/booking/presentation/controllers/booking_creation_controller.dart

import 'package:nano_embryo/presentation/features/freelancer/presentation/providers/freelancer_details_provider.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/utils/booking_logger.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/utils/booking_sanitizer.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/utils/booking_validators.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/providers/is_freelancer_provider.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/services/notification_service.dart';
import 'package:nano_embryo/wallet/data/models/wallet_transaction_model.dart';
import 'package:nano_embryo/wallet/providers/wallet_providers.dart';
import 'package:nano_embryo/core/notifications/domain/usecases/schedule_booking_reminders.dart';
import 'package:nano_embryo/core/notifications/utils/notification_date_time_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';

part 'booking_creation_controller.g.dart';

/// Provided by the app bootstrap. Throws if unwired so a missing
/// integration surfaces during development instead of at runtime.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError(
    'notificationServiceProvider must be overridden at app bootstrap',
  );
});

/// Deposit percentage of the total amount. Pinned to 30 % to match the
/// server-side default; if shops gain per-shop deposit configuration
/// later, this constant moves into the shop model.
const double _kDepositPercent = 0.30;

/// Platform fee charged per booking. Currently flat; will move to a
/// configurable column on `shops` once payments wire that up.
const double _kPlatformFee = 2.0;

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
/// Pre-validates the draft client-side (services selected, time slots
/// assigned, group quantities within max_clients), then posts to the
/// server through a single idempotency key. The key is generated once
/// in `build()` and reused across retries; the underlying RPC dedupes
/// on it.
@riverpod
class BookingCreationController extends _$BookingCreationController {
  @override
  BookingCreationState build() {
    return BookingCreationState.initial().copyWith(
      idempotencyKey: const Uuid().v4(),
    );
  }

  /// Creates a booking after successful payment.
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
    if (state.isSubmitting || state.isSuccess) return state.createdBooking;
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final services = ref.read(selectedServicesProvider);
      final workers = ref.read(selectedWorkersProvider);
      final date = ref.read(selectedDateProvider);
      final quantities = ref.read(serviceQuantityProvider);
      final timeSlots = ref.read(selectedTimeSlotsProvider);
      final isCombinedView = ref.read(isCombinedViewProvider);

      BookingValidators.validateSelections(
        services: services,
        timeSlots: timeSlots,
        quantities: quantities,
        isCombinedView: isCombinedView,
      );
      BookingValidators.validateNoDuplicateWorkers(workers);

      final totalAmount = _calculateTotalAmount(services, quantities);
      final depositAmount = totalAmount * _kDepositPercent;

      // start_time = earliest selected; end_time = latest selected.
      // The previous version used `timeSlots.values.first` which broke
      // for non-overlapping multi-service bookings — the earliest slot
      // by start_time is the right anchor.
      final sortedSlots = BookingValidators.sortedByStart(timeSlots.values);
      final firstSlot = sortedSlots.first;
      final actualEndTime = BookingValidators.latestActualEnd(sortedSlots);
      final endTime = BookingValidators.latestEnd(sortedSlots);

      final booking = BookingModel(
        id: const Uuid().v4(),
        userId: userId,
        shopId: shopId,
        bookingDate: date,
        startTime: firstSlot.startTime,
        endTime: endTime,
        actualEndTime: actualEndTime,
        status: BookingStatus.confirmed,
        totalAmount: totalAmount,
        paymentStatus:
            paymentIntentId != null ? PaymentStatus.paid : PaymentStatus.unpaid,
        paymentIntentId: paymentIntentId,
        depositAmount: depositAmount,
        platformFee: _kPlatformFee,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        latitude: latitude,
        longitude: longitude,
        shopAddress: shopAddress,
      );

      final bookingServices = _createBookingServices(
        booking.id,
        services,
        workers,
        quantities,
        timeSlots,
      );

      final repository = ref.read(bookingRepositoryProvider);
      final createdBooking = await repository.createBooking(
        booking: booking,
        services: bookingServices,
        idempotencyKey: state.idempotencyKey,
      );

      await _sendBookingNotifications(
        createdBooking,
        services,
        userId,
        shopId,
        clientName,
        shopName,
      );

      state = state.copyWith(
        isSubmitting: false,
        isSuccess: true,
        createdBooking: createdBooking,
      );

      _invalidateProviders();
      await _addWalletTransaction(createdBooking);

      return createdBooking;
    } on BookingException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: BookingValidators.userFacingMessage(e),
      );
      BookingLogger.warn('createBooking domain error', error: e);
      return null;
    } catch (e, stack) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'We could not create your booking. Please try again.',
      );
      BookingLogger.error('createBooking unexpected error', error: e, stack: stack);
      return null;
    }
  }

  /// Creates a booking for a freelancer after successful payment.
  Future<BookingModel?> createFreelancerBooking({
    required String userId,
    required String freelancerId,
    required String freelancerName,
    required double freelancerLat,
    required double freelancerLng,
    required int travelRadiusKm,
    required String clientName,
  }) async {
    if (state.isSubmitting || state.isSuccess) return state.createdBooking;
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final services = ref.read(selectedServicesProvider);
      final date = ref.read(selectedDateProvider);
      final quantities = ref.read(serviceQuantityProvider);
      final timeSlots = ref.read(selectedTimeSlotsProvider);
      final isCombinedView = ref.read(isCombinedViewProvider);
      final serviceAddress = ref.read(selectedAddressProvider);

      BookingValidators.validateSelections(
        services: services,
        timeSlots: timeSlots,
        quantities: quantities,
        isCombinedView: isCombinedView,
      );

      final freelancerDetails =
          await ref.read(freelancerDetailsProvider(freelancerId).future);
      if (freelancerDetails?.canTravel == true && serviceAddress == null) {
        throw BookingValidationException({'address': 'Service address required'});
      }

      if (serviceAddress != null &&
          serviceAddress.latitude != null &&
          serviceAddress.longitude != null) {
        if (!BookingSanitizer.isValidCoordinate(
          serviceAddress.latitude,
          serviceAddress.longitude,
        )) {
          throw BookingValidationException({'address': 'Invalid service location'});
        }
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

      final totalAmount = _calculateTotalAmount(services, quantities);
      final depositAmount = totalAmount * _kDepositPercent;

      final sortedSlots = BookingValidators.sortedByStart(timeSlots.values);
      final firstSlot = sortedSlots.first;
      final actualEndTime = BookingValidators.latestActualEnd(sortedSlots);

      final booking = BookingModel(
        id: const Uuid().v4(),
        userId: userId,
        shopId: freelancerId,
        bookingDate: date,
        startTime: firstSlot.startTime,
        endTime: BookingValidators.latestEnd(sortedSlots),
        actualEndTime: actualEndTime,
        status: BookingStatus.confirmed,
        totalAmount: totalAmount,
        paymentStatus: PaymentStatus.paid,
        depositAmount: depositAmount,
        platformFee: _kPlatformFee,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        latitude: serviceAddress?.latitude ?? freelancerLat,
        longitude: serviceAddress?.longitude ?? freelancerLng,
        shopAddress: serviceAddress?.fullAddress ?? '',
      );

      final bookingServices = _createFreelancerBookingServices(
        booking.id,
        services,
        quantities,
        timeSlots,
      );

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

      state = state.copyWith(
        isSubmitting: false,
        isSuccess: true,
        createdBooking: createdBooking,
      );
      _invalidateProviders();
      return createdBooking;
    } on BookingException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: BookingValidators.userFacingMessage(e),
      );
      BookingLogger.warn('createFreelancerBooking domain error', error: e);
      return null;
    } catch (e, stack) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'We could not create your booking. Please try again.',
      );
      BookingLogger.error(
        'createFreelancerBooking unexpected error',
        error: e,
        stack: stack,
      );
      return null;
    }
  }

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
      final serviceNames = services.map((s) => s.serviceName).join(', ');

      await notificationService.notifyShopNewBooking(
        shopOwnerId: shopOwnerId,
        userName: clientName,
        serviceNames: serviceNames,
        bookingId: booking.id,
        shopId: booking.shopId,
        startTime: booking.startTime,
      );

      NotificationDateTimeUtils.combineDateAndTime(
        booking.bookingDate,
        booking.startTime,
      );

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
    } catch (e, stack) {
      BookingLogger.warn(
        'failed to send booking notifications (booking still succeeded)',
        error: e,
        stack: stack,
      );
    }
  }

  Duration _calculateTotalDuration(List<AppointmentSlotDTO> services) {
    return services.fold<Duration>(
      Duration.zero,
      (acc, s) => acc + DurationUtils.parse(s.duration),
    );
  }

  Future<void> _addWalletTransaction(BookingModel booking) async {
    try {
      final walletRepository = ref.read(walletRepositoryProvider);
      await walletRepository.addTransaction(
        shopId: booking.shopId,
        amount: booking.depositAmount,
        type: TransactionType.deposit,
        bookingId: booking.id,
        description: 'Deposit for booking #${booking.id.substring(0, 8)}',
      );
    } catch (e, stack) {
      BookingLogger.warn(
        'wallet deposit transaction failed (booking still succeeded)',
        error: e,
        stack: stack,
      );
    }
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

  List<BookingServiceModel> _createBookingServices(
    String bookingId,
    List<AppointmentSlotDTO> services,
    Map<String, List<Map<String, String?>>> workers,
    Map<String, int> quantities,
    Map<String, TimeSlotModel> timeSlots,
  ) {
    final all = <BookingServiceModel>[];

    for (final service in services) {
      final quantity = quantities[service.id] ?? 1;
      final workerEntries = workers[service.id] ??
          List.generate(quantity, (_) => {'id': null, 'name': null});
      final duration = DurationUtils.parse(service.duration);
      final timeSlot = timeSlots[service.id];

      for (var i = 0; i < quantity; i++) {
        final entry = workerEntries.length > i
            ? workerEntries[i]
            : {'id': null, 'name': null};

        all.add(
          BookingServiceModel(
            id: const Uuid().v4(),
            bookingId: bookingId,
            slotId: service.id,
            workerId: entry['id'],
            priceAtBooking: service.price,
            durationMinutes: duration.inMinutes,
            createdAt: DateTime.now(),
            serviceName: service.serviceName,
            workerName: entry['name'],
            startTime: timeSlot?.startTime,
          ),
        );
      }
    }

    return all;
  }

  List<BookingServiceModel> _createFreelancerBookingServices(
    String bookingId,
    List<AppointmentSlotDTO> services,
    Map<String, int> quantities,
    Map<String, TimeSlotModel> timeSlots,
  ) {
    final all = <BookingServiceModel>[];

    for (final service in services) {
      final quantity = quantities[service.id] ?? 1;
      final timeSlot = timeSlots[service.id];
      final duration = DurationUtils.parse(service.duration);

      for (var i = 0; i < quantity; i++) {
        all.add(
          BookingServiceModel(
            id: const Uuid().v4(),
            bookingId: bookingId,
            slotId: service.id,
            workerId: null,
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

    return all;
  }

  void _invalidateProviders() {
    ref.invalidate(selectedServicesProvider);
    ref.invalidate(selectedWorkersProvider);
    ref.invalidate(selectedDateProvider);
    ref.invalidate(selectedTimeSlotsProvider);
    ref.invalidate(slotGenerationControllerProvider);
  }

  /// Resets the controller for a new booking. The new idempotency key
  /// means the next submission cannot be replayed against the previous
  /// booking — call this only after the user explicitly starts over.
  void reset() {
    state = BookingCreationState.initial().copyWith(
      idempotencyKey: const Uuid().v4(),
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
