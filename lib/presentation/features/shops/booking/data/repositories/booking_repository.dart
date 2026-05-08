// lib/features/booking/data/repositories/booking_repository.dart
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/contact_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/data/models/booking_review.dart';

/// Abstract repository for booking operations.
///
/// This interface defines the contract for all booking-related data operations.
/// Implementations can use Supabase, local storage, or mock data.
///
/// Following the repository pattern, this abstraction allows:
/// - Easy testing with mock implementations
/// - Swapping data sources without affecting UI
/// - Centralized error handling
abstract class BookingRepository {
  /// Creates a new booking with optional multiple services.
  ///
  /// [booking] - The main booking information
  /// [services] - List of services included in this booking
  /// [idempotencyKey] - Optional key to prevent duplicate bookings
  ///
  /// Returns the created [BookingModel] with generated ID.
  /// Throws [BookingException] if booking fails (conflict, unavailable, etc.)
  Future<BookingModel> createBooking({
    required BookingModel booking,
    required List<BookingServiceModel> services,
    String? idempotencyKey,
  });

  /// Creates a booking for a freelancer (no worker assignment)
  Future<BookingModel> createFreelancerBooking({
    required BookingModel booking,
    required List<BookingServiceModel> services,
    String? idempotencyKey,
  });

  /// Check if a user owns any shops
  // Future<bool> userHasShops(String userId);

  /// Retrieves a paginated list of bookings based on parameters.
  ///
  /// [params] - Filtering, pagination, and sorting options
  ///
  /// Returns [PaginatedBookings] with results and metadata.
  Future<PaginatedBookings<ClientCalendarBooking>> getClientBookings({
    required String userId,
    int? page = 1,
    int? pageSize = 10,
    String? sortBy = 'start_time',
    bool sortAscending = false,
    BookingStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Fetch appointments for a specific shop on a specific date
  Future<PaginatedBookings<ShopCalendarBooking>> getAppointmentsForDate({
    required String shopId,
    required DateTime date,
    BookingStatus? status,
  });

  /// Fetch appointments for a date range
  Future<PaginatedBookings<ShopCalendarBooking>> getAppointmentsForDateRange({
    required String shopId,
    required DateTime startDate,
    required DateTime endDate,
    BookingStatus? status,
  });

  /// Get shop bookings with filtering and pagination
  Future<PaginatedBookings<ShopCalendarBooking>> getShopBookings({
    required String shopId,
    int? page = 1,
    int? pageSize = 10,
    String? sortBy = 'start_time',
    bool sortAscending = false,
    BookingStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? workerId,
  });

  /// Retrieves a single booking by ID with all associated services.
  ///
  /// [bookingId] - The unique identifier of the booking
  ///
  /// Returns [BookingModel] with services loaded.
  /// Throws [BookingException] if booking not found.
  Future<BookingModel?> getBookingById(String bookingId);

  /// Cancels an existing booking.
  ///
  /// [bookingId] - ID of booking to cancel
  /// [reason] - Optional cancellation reason
  ///
  /// Returns updated [BookingModel] with cancelled status.
  /// Throws [BookingException] if cancellation not allowed.
  Future<BookingModel> cancelBooking(String bookingId, {String? reason});

  /// Checks availability for a specific time slot and worker.
  Future<List<WorkerUnavailabilityModel>> getWorkerUnavailability(
    String workerId,
    DateTime startDate,
    DateTime endDate,
  );

  /// [shopId] - ID of the shop
  /// [slotId] - ID of the appointment slot
  /// [workerId] - Optional worker ID (null if no specific worker)
  /// [startTime] - Proposed start time
  /// [endTime] - Proposed end time
  ///
  /// Returns true if the slot is available.
  Future<bool> checkAvailability({
    required String shopId,
    required String slotId,
    String? workerId,
    required DateTime startTime,
    required DateTime endTime,
  });

  /// Generates available time slots for given criteria.
  ///
  /// [shopId] - ID of the shop
  /// [date] - Date to generate slots for
  /// [services] - Selected services (used to calculate total duration)
  /// [preferredWorkerIds] - Optional preferred worker IDs
  ///
  /// Returns list of available [TimeSlotModel]s.
  Future<List<TimeSlotModel>> generateTimeSlots({
    required String shopId,
    required DateTime date,
    required List<AppointmentSlotDTO> services,
    required Map<String, int> quantities, // Add quantities
    Map<String, List<String>>? selectedWorkerIds, // Update to List<String>
    int? defaultBufferMinutes, // Add this
  });

  /// Gets available workers for a specific slot at a specific time.
  ///
  /// [slotId] - ID of the appointment slot
  /// [startTime] - Proposed start time
  /// [endTime] - Proposed end time
  ///
  /// Returns list of [WorkerDTO]s available during that time.
  Future<List<WorkerDTO>> getAvailableWorkers({
    required String slotId,
    required DateTime startTime,
    required DateTime endTime,
  });

  /// Mark a booking as no-show
  Future<BookingModel> markAsNoShow(String bookingId);

  /// Mark a booking as completed
  Future<BookingModel> markAsComplete(String bookingId);

  /// Get all contacts for a shop
  Future<List<ContactDraft>> getShopContacts(String shopId);

  /// Get all social links for a shop
  Future<List<SocialLinkDraft>> getShopSocialLinks(String shopId);

  /// Add or update special requirements for a booking service
  Future<void> updateSpecialRequirements({
    required String bookingServiceId,
    required String requirements,
  });

  /// Get special requirements for a specific booking service
  Future<String?> getSpecialRequirements(String bookingServiceId);

  /// Validates a booking before creation.

  /// Add a review for a completed booking
  Future<BookingReview> addReview({
    required String bookingId,
    required int rating,
    String? review,
  });

  /// Get review for a specific booking
  Future<BookingReview?> getReviewForBooking(String bookingId);

  /// Get reviews for a shop
  Future<List<BookingReview>> getShopReviews(String shopId, {int limit = 10});

  /// Check if a booking already has a review
  Future<bool> hasReview(String bookingId);

  /// Update shop response to a review (shop owner only)
  Future<void> updateReviewResponse({
    required String reviewId,
    required String response,
  });

  /// [booking] - Proposed booking
  /// [services] - Proposed services
  ///
  /// Returns validation errors map (empty if valid).
  /// Throws [BookingValidationException] if validation fails.
  Future<Map<String, String>> validateBooking({
    required BookingModel booking,
    required List<BookingServiceModel> services,
  });
}
