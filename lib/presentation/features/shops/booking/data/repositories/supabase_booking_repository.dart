// lib/features/booking/data/repositories/supabase/supabase_booking_repository.dart
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/contact_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/services/notification_service.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/data/models/booking_review.dart';
import 'package:nano_embryo/core/notifications/domain/usecases/send_immediate_notification.dart';
import 'package:uuid/uuid.dart';

/// Supabase implementation of [BookingRepository].
///
/// This class handles all booking-related database operations using Supabase.
/// It implements proper error handling, transaction management, and RLS policies.
// lib/features/booking/data/repositories/supabase/supabase_booking_repository.dart

/// Supabase implementation of [BookingRepository].
///
/// This class handles all booking-related database operations using Supabase.
/// It implements proper error handling, transaction management, and RLS policies.
///
/// ## Features
/// - Atomic transactions via RPC functions
/// - Idempotency support to prevent duplicate bookings
/// - Comprehensive error mapping to domain exceptions
/// - Pagination and filtering support
/// - Real-time availability checks
class SupabaseBookingRepository implements BookingRepository {
  final SupabaseClient _client;
  final String _bookingsTable = 'bookings';
  final String _bookingServicesTable = 'booking_services';
  final String _appointmentSlotsTable = 'appointment_slots';
  final String _shopWorkersTable = 'workers';
  final String _slotWorkerAssignmentsTable = 'slot_worker_assignments';
  final String _idempotencyTable = 'booking_idempotency_keys';
  final NotificationService? _notificationService;

  SupabaseBookingRepository(this._client, [this._notificationService]);

  // ==================== Core Booking Operations ====================

  @override
  Future<BookingModel> createBooking({
    required BookingModel booking,
    required List<BookingServiceModel> services,
    String? idempotencyKey,
  }) async {
    try {
      // Check idempotency first if key provided
      if (idempotencyKey != null) {
        final existing = await _checkIdempotency(idempotencyKey);
        if (existing != null) return existing;
      }

      // Use RPC for atomic transaction
      final result = await _client.rpc(
        'create_booking_transaction',
        params: {
          'p_booking': booking.toJson(),
          'p_services': services.map((s) => s.toJson()).toList(),
          'p_idempotency_key': idempotencyKey,
        },
      );

      final createdBooking = BookingModel.fromJson(result);

      // Store idempotency key if provided
      if (idempotencyKey != null) {
        await _storeIdempotencyKey(idempotencyKey, createdBooking.id);
      }

      return createdBooking;
    } on PostgrestException catch (e) {
      // Map database errors to domain exceptions
      if (e.code == '23505') {
        // Unique violation
        if (e.message.contains('no_overlap_worker')) {
          throw WorkerUnavailableException(
            workerId: _extractWorkerIdFromError(e.message),
            requestedTime: _extractTimeFromError(e.message),
          );
        }
        throw SlotUnavailableException();
      } else if (e.code == 'P0001') {
        // Raise exception
        if (e.message.contains('slot_full')) {
          throw SlotFullException(
            slotId: _extractSlotIdFromError(e.message),
            slotTime: _extractTimeFromError(e.message),
            maxCapacity: _extractCapacityFromError(e.message),
          );
        } else if (e.message.contains('outside_hours')) {
          throw OutsideBusinessHoursException(
            requestedTime: _extractTimeFromError(e.message),
            shopHours: _extractShopHoursFromError(e.message),
          );
        } else if (e.message.contains('validation_failed')) {
          throw BookingValidationException({});
        }
      }
      throw DatabaseBookingException(
        'Database error: ${e.message}',
        code: e.code,
      );
    } catch (e, stack) {
      String errorMessage = 'Failed to create booking';

      if (e is PostgrestException) {
        errorMessage = e.message ?? errorMessage;
        throw DatabaseBookingException(
          e.message ?? 'Database error',
          code: e.code,
        );
      } else if (e is DatabaseBookingException) {
        // This is our wrapper - the real error is inside
        errorMessage = e.toString();
      }
      throw DatabaseBookingException('Unexpected error: $e');

      // state = state.copyWith(isSubmitting: false, error: errorMessage);
    }
  }

  @override
  Future<PaginatedBookings<ClientCalendarBooking>> getClientBookings({
    required String userId,
    int? page = 1,
    int? pageSize = 10,
    String? sortBy = 'start_time',
    bool sortAscending = false,
    BookingStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      print('🔵 getClientBookings - userId: $userId');

      // First, get total count using a separate query
      dynamic countQuery = _client
          .from('booking_simple')
          .select('booking_id')
          .eq('user_id', userId);

      // Apply filters to count query
      if (status != null) {
        countQuery = countQuery.eq('status', status.value);
      }
      if (fromDate != null) {
        countQuery = countQuery.gte('booking_date', fromDate.toIso8601String());
      }
      if (toDate != null) {
        countQuery = countQuery.lte('booking_date', toDate.toIso8601String());
      }

      final countResponse = await countQuery;
      // Get unique booking IDs for count
      final uniqueBookingIds = <String>{};
      for (final row in countResponse) {
        uniqueBookingIds.add(row['booking_id']);
      }
      final totalCount = uniqueBookingIds.length;
      print('🔵 Total distinct bookings: $totalCount');

      // Now get the paginated data
      dynamic query = _client
          .from('booking_simple')
          .select()
          .eq('user_id', userId);

      // Apply filters
      if (status != null) {
        query = query.eq('status', status.value);
      }
      if (fromDate != null) {
        query = query.gte('booking_date', fromDate.toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('booking_date', toDate.toIso8601String());
      }

      // Apply sorting
      query = query.order(sortBy ?? 'start_time', ascending: sortAscending);

      // Apply pagination
      final from = (page! - 1) * pageSize!;
      final response = await query.range(from, from + pageSize - 1);
      print('🔵 Raw response length: ${response.length}');

      // Group by booking_id to create unique bookings
      final Map<String, Map<String, dynamic>> bookingMap = {};

      for (final row in response) {
        final bookingId = row['booking_id'];
        if (!bookingMap.containsKey(bookingId)) {
          bookingMap[bookingId] = {
            'id': bookingId,
            'start_time': row['start_time'],
            'end_time': row['end_time'],
            'status': row['status'],
            'total_amount': row['total_amount'],
            'shop': {
              'shop_name': row['shop_name'],
              'shop_type': row['shop_type'],
              'currency': row['currency'],
              'shop_logo_url': row['shop_logo_url'],
            },
            'booking_services': [],
          };
        }

        // Add service if exists
        if (row['service_id'] != null && row['service_name'] != null) {
          bookingMap[bookingId]!['booking_services'].add({
            'slot': {'service_name': row['service_name']},
          });
        }
      }

      final data = bookingMap.values.toList();
      print('✅ Grouped into ${data.length} unique bookings');

      final params = BookingParams(
        userId: userId,
        page: page,
        pageSize: pageSize,
        sortBy: sortBy,
        sortAscending: sortAscending,
        status: status,
        fromDate: fromDate,
        toDate: toDate,
      );

      return PaginatedBookings<ClientCalendarBooking>.fromSupabase(
        data,
        totalCount,
        params,
        ClientCalendarBooking.fromJson,
      );
    } catch (e, stack) {
      print('❌ Error in getClientBookings: $e');
      print('Stack trace: $stack');
      throw Exception('Failed to fetch client bookings: $e');
    }
  }

  /// Fetch appointments for a specific shop on a specific date
  /// This is a convenience method that uses getShopBookings with a single day range
  Future<PaginatedBookings<ShopCalendarBooking>> getAppointmentsForDate({
    required String shopId,
    required DateTime date,
    BookingStatus? status,
  }) async {
    // Calculate start and end of the day
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Use existing getShopBookings with date range
    return getShopBookings(
      shopId: shopId,
      fromDate: startOfDay,
      toDate: endOfDay,
      status: status,
      page: 1,
      pageSize: 100, // Fetch all for the day
    );
  }

  /// Fetch appointments for a date range (used for prefetching)
  Future<PaginatedBookings<ShopCalendarBooking>> getAppointmentsForDateRange({
    required String shopId,
    required DateTime startDate,
    required DateTime endDate,
    BookingStatus? status,
  }) async {
    return getShopBookings(
      shopId: shopId,
      fromDate: startDate,
      toDate: endDate,
      status: status,
      page: 1,
      pageSize: 100,
    );
  }

  @override
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
  }) async {
    try {
      // First, get total count using a separate query
      dynamic countQuery = _client
          .from('booking_simple')
          .select('booking_id')
          .eq('shop_id', shopId);

      // Apply filters to count query
      if (status != null) {
        countQuery = countQuery.eq('status', status.value);
      }
      if (fromDate != null) {
        countQuery = countQuery.gte('booking_date', fromDate.toIso8601String());
      }
      if (toDate != null) {
        countQuery = countQuery.lte('booking_date', toDate.toIso8601String());
      }

      final countResponse = await countQuery;
      // Get unique booking IDs for count
      final uniqueBookingIds = <String>{};
      for (final row in countResponse) {
        uniqueBookingIds.add(row['booking_id']);
      }
      final totalCount = uniqueBookingIds.length;

      // Now get the paginated data
      dynamic query = _client
          .from('booking_simple')
          .select()
          .eq('shop_id', shopId);

      // Apply filters
      if (status != null) {
        query = query.eq('status', status.value);
      }
      if (fromDate != null) {
        query = query.gte('booking_date', fromDate.toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('booking_date', toDate.toIso8601String());
      }

      // Apply sorting
      query = query.order(sortBy ?? 'start_time', ascending: sortAscending);

      // Apply pagination
      final from = (page! - 1) * pageSize!;
      final response = await query.range(from, from + pageSize - 1);

      // Group by booking_id to create unique bookings
      final Map<String, Map<String, dynamic>> bookingMap = {};

      for (final row in response) {
        final bookingId = row['booking_id'];
        if (!bookingMap.containsKey(bookingId)) {
          bookingMap[bookingId] = {
            'id': bookingId,
            'start_time': row['start_time'],
            'end_time': row['end_time'],
            'status': row['status'],
            'total_amount': row['total_amount'],
            'client': {
              'display_name': row['client_display_name'],
              'username': row['client_username'],
              'avatar_url': row['client_avatar_url'],
            },
            'booking_services': [],
          };
        }

        // Add service if exists
        if (row['service_id'] != null && row['service_name'] != null) {
          bookingMap[bookingId]!['booking_services'].add({
            'slot': {'service_name': row['service_name']},
          });
        }
      }

      final data = bookingMap.values.toList();

      final params = BookingParams(
        shopId: shopId,
        page: page,
        pageSize: pageSize,
        sortBy: sortBy,
        sortAscending: sortAscending,
        status: status,
        fromDate: fromDate,
        toDate: toDate,
        workerId: workerId,
      );

      return PaginatedBookings<ShopCalendarBooking>.fromSupabase(
        data,
        totalCount,
        params,
        ShopCalendarBooking.fromJson,
      );
    } catch (e, stack) {
      // print('❌ Error in getShopBookings: $e');
      // print('Stack trace: $stack');
      throw Exception('Failed to fetch shop bookings: $e');
    }
  }

  @override
  Future<BookingModel> markAsNoShow(String bookingId) async {
    try {
      final response =
          await _client
              .from(_bookingsTable)
              .update({
                'status': 'no_show',
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', bookingId)
              .select()
              .single();

      return BookingModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseBookingException(
        'Failed to mark as no-show: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw DatabaseBookingException('Unexpected error: $e');
    }
  }

  @override
  Future<BookingModel> markAsComplete(String bookingId) async {
    try {
      final response =
          await _client
              .from(_bookingsTable)
              .update({
                'status': 'completed',
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', bookingId)
              .select()
              .single();

      return BookingModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseBookingException(
        'Failed to mark as no-show: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw DatabaseBookingException('Unexpected error: $e');
    }
  }

  @override
  Future<BookingModel> getBookingById(String bookingId) async {
    try {
      // 1. Fetch the booking data from booking_simple
      final bookingResponse = await _client
          .from('booking_simple')
          .select()
          .eq('booking_id', bookingId);

      if (bookingResponse.isEmpty) {
        throw Exception('Booking not found with id: $bookingId');
      }

      final firstRow = bookingResponse.first;
      final shopId = firstRow['shop_id'];

      // 2. Fetch shop details WITH locations
      final shopResponse =
          await _client
              .from('shops')
              .select('''
          id,
          shop_name,
          shop_logo_url,
          luxury_level,
          verified,
          shop_type,
          address,
          locations:shop_locations(
            address,
            city,
            country,
            latitude,
            longitude,
            is_primary
          )
        ''')
              .eq('id', shopId)
              .single();

      // Extract coordinates from locations
      double? latitude;
      double? longitude;
      String? shopAddress;

      final locations = shopResponse['locations'] as List?;
      if (locations != null && locations.isNotEmpty) {
        final primaryLocation = locations.firstWhere(
          (loc) => loc['is_primary'] == true,
          orElse: () => locations.first,
        );
        latitude = (primaryLocation['latitude'] as num?)?.toDouble();
        longitude = (primaryLocation['longitude'] as num?)?.toDouble();
        shopAddress =
            primaryLocation['address'] as String? ?? shopResponse['address'];
      } else {
        shopAddress = shopResponse['address'] as String?;
      }

      // 3. Fetch booking services
      final servicesResponse = await _client
          .from('booking_services')
          .select('''
          id,
          booking_id,
          slot_id,
          worker_id,
          price_at_booking,
          duration_minutes,
          created_at,
          service_name,
          worker_name,
          special_requirements,
          appointment_slots!slot_id (
            id,
            service_name,
            duration,
            price,
            slot_type
          ),
          workers!worker_id (
            id,
            name,
            bio,
            specialties,
            profile_image_url
          )
        ''')
          .eq('booking_id', bookingId);

      // 4. Build the services list
      final services =
          servicesResponse.map((row) {
            final slotData = row['appointment_slots'] as Map<String, dynamic>?;
            final workerData = row['workers'] as Map<String, dynamic>?;

            return {
              'id': row['id'],
              'booking_id': row['booking_id'],
              'slot_id': row['slot_id'],
              'worker_id': row['worker_id'],
              'price_at_booking': (row['price_at_booking'] ?? 0.0).toDouble(),
              'duration_minutes': row['duration_minutes'] ?? 0,
              'created_at': row['created_at'],
              'service_name': row['service_name'] ?? slotData?['service_name'],
              'worker_name': row['worker_name'] ?? workerData?['name'],
              'special_requirements': row['special_requirements'],
              'slot':
                  slotData != null
                      ? {
                        'id': slotData['id'],
                        'service_name': slotData['service_name'],
                        'duration': slotData['duration'],
                        'price': (slotData['price'] ?? 0.0).toDouble(),
                        'slot_type': slotData['slot_type'],
                      }
                      : null,
              'worker':
                  workerData != null
                      ? {
                        'id': workerData['id'],
                        'name': workerData['name'],
                        'bio': workerData['bio'],
                        'specialties': workerData['specialties'],
                        'profile_image_url': workerData['profile_image_url'],
                      }
                      : null,
            };
          }).toList();

      // 5. Build the complete booking object with coordinates
      final combinedData = {
        'id': firstRow['booking_id'],
        'user_id': firstRow['user_id'],
        'shop_id': firstRow['shop_id'],
        'booking_date': firstRow['booking_date'],
        'start_time': firstRow['start_time'],
        'end_time': firstRow['end_time'],
        'actual_end_time': firstRow['actual_end_time'],
        'status': firstRow['status'],
        'total_amount': firstRow['total_amount'],
        'deposit_amount': firstRow['deposit_amount'],
        'platform_fee': firstRow['platform_fee'],
        'payment_method': firstRow['payment_method'],
        'payment_status': firstRow['payment_status'],
        'payment_intent_id': firstRow['payment_intent_id'],
        'cancellation_reason': firstRow['cancellation_reason'],
        'cancelled_at': firstRow['cancelled_at'],
        'created_at': firstRow['booking_created_at'],
        'updated_at': firstRow['booking_updated_at'],
        'shop': {
          'id': shopResponse['id'],
          'shop_name': shopResponse['shop_name'],
          'shop_logo_url': shopResponse['shop_logo_url'],
          'luxury_level': shopResponse['luxury_level'],
          'verified': shopResponse['verified'],
          'shop_type': shopResponse['shop_type'],
          'address': shopAddress,
          'latitude': latitude, // ← Add latitude
          'longitude': longitude, // ← Add longitude
          'locations': locations, // ← Also include full locations
        },
        'booking_services': services,
      };

      return BookingModel.fromJson(combinedData);
    } catch (e, stack) {
      print('Error in getBookingById: $e');
      print('Stack trace: $stack');
      throw Exception('Failed to fetch booking: $e');
    }
  }

  // @override
  // Future<List<ContactDraft>> getShopContacts(String shopId) async {
  //   try {
  //     final response = await _client
  //         .from('shop_contacts')
  //         .select('*')
  //         .eq('shop_id', shopId)
  //         .eq('is_active', true)
  //         .order('is_primary', ascending: false) // Primary first
  //         .order('sort_order', ascending: true);

  //     return (response as List)
  //         .map((json) => ContactDraft.fromJson(json))
  //         .toList();
  //   } catch (e) {
  //     return [];
  //   }
  // }

  @override
  Future<List<ContactDraft>> getShopContacts(String shopId) async {
    try {
      final response = await _client
          .from('shop_contacts')
          .select('''
          id,
          contact_type,
          value,
          is_primary
        ''')
          .eq('shop_id', shopId)
          .order('is_primary', ascending: false);

      return (response as List).map((json) {
        final typeString = json['contact_type'] as String;
        ContactType type;
        switch (typeString) {
          case 'phone':
            type = ContactType.phone;
            break;
          case 'email':
            type = ContactType.email;
            break;
          case 'website':
            type = ContactType.website;
            break;
          default:
            type = ContactType.phone;
        }

        return ContactDraft(
          id: json['id'] as String,
          type: type,
          value: json['value'] as String,
          isPrimary: json['is_primary'] as bool? ?? false,
          sortOrder: 0, // sort_order doesn't exist in your table
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<SocialLinkDraft>> getShopSocialLinks(String shopId) async {
    try {
      final response = await _client
          .from('shop_social_links')
          .select('''
          id,
          platform,
          url
        ''')
          .eq('shop_id', shopId);

      return (response as List).map((json) {
        return SocialLinkDraft.fromJson({
          'id': json['id'] as String,
          'platform': json['platform'] as String,
          'url': json['url'] as String,
          'isActive': true,
        });
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> updateSpecialRequirements({
    required String bookingServiceId,
    required String requirements,
  }) async {
    try {
      final updateData = {
        'special_requirements': requirements.isEmpty ? null : requirements,
      };

      await _client
          .from('booking_services')
          .update(updateData)
          .eq('id', bookingServiceId);
    } catch (e) {
      throw Exception('Failed to update special requirements: $e');
    }
  }

  @override
  Future<String?> getSpecialRequirements(String bookingServiceId) async {
    try {
      final response =
          await _client
              .from(_bookingServicesTable)
              .select('special_requirements')
              .eq('id', bookingServiceId)
              .maybeSingle();

      return response?['special_requirements'] as String?;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<BookingReview> addReview({
    required String bookingId,
    required int rating,
    String? review,
  }) async {
    try {
      // First, get the booking to get shop_id and user_id
      final booking = await getBookingById(bookingId);

      final response =
          await _client
              .from('booking_reviews')
              .insert({
                'booking_id': bookingId,
                'user_id': booking.userId,
                'shop_id': booking.shopId,
                'rating': rating,
                'review': review,
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();

      final createdReview = BookingReview.fromJson(response);

      // ============================================
      // 🔔 SEND NOTIFICATION TO SHOP (NEW)
      // ============================================
      await _sendReviewNotification(
        shopId: booking.shopId,
        shopOwnerId: booking.shopId, // You'll need this field
        rating: rating,
        review: review,
        bookingId: bookingId,
        userName: booking.clientName ?? '', // You may need to fetch this
      );

      return createdReview;
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('A review already exists for this booking');
      }
      throw Exception('Failed to add review: ${e.message}');
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  // ============================================
  // 🔔 NEW METHOD: Send review notification
  // ============================================
  Future<void> _sendReviewNotification({
    required String shopOwnerId,
    required int rating,
    String? review,
    required String bookingId,
    required String shopId,
    required String userName,
  }) async {
    if (_notificationService == null) {
      print(
        '⚠️ Notification service not available, skipping review notification',
      );
      return;
    }

    try {
      // Create star rating string (e.g., "★★★★☆")
      final starRating = _getStarRating(rating);

      // Prepare notification message
      final title = 'New Review Received! ⭐';
      final body =
          review != null && review.isNotEmpty
              ? '$userName gave you $starRating ($rating/5): "${review.length > 50 ? review.substring(0, 50) + '...' : review}"'
              : '$userName gave you $starRating ($rating/5)';

      // Use the generic method
      await _notificationService!.sendImmediateNotification(
        userId: shopOwnerId,
        title: title,
        body: body,
        data: {
          'type': 'new_review',
          'booking_id': bookingId,
          'shop_id': shopId,
          'rating': rating,
          'review': review,
          'user_name': userName,
        },
        priority: 'high',
      );

      print('✅ Sent review notification to shop: $shopOwnerId');
    } catch (e) {
      print('❌ Failed to send review notification: $e');
    }
  }

  String _getStarRating(int rating) {
    const fullStar = '★';
    const emptyStar = '☆';
    return fullStar * rating + emptyStar * (5 - rating);
  }

  @override
  Future<BookingReview?> getReviewForBooking(String bookingId) async {
    try {
      final response =
          await _client
              .from('review_details')
              .select('*')
              .eq('booking_id', bookingId)
              .maybeSingle();

      if (response == null) return null;

      // Transform the flat response into the nested structure expected by BookingReview
      final transformedJson = {
        ...response,
        'user': {
          'display_name': response['display_name'],
          'username': response['username'],
          'avatar_url': response['avatar_url'],
        },
        'shop': {
          'shop_name': response['shop_name'],
          'shop_logo_url': response['shop_logo_url'],
        },
      };

      return BookingReview.fromJson(transformedJson);
    } catch (e) {
      print('❌ Failed to get review: $e');
      return null;
    }
  }

  @override
  Future<List<BookingReview>> getShopReviews(
    String shopId, {
    int limit = 10,
  }) async {
    try {
      final response = await _client
          .from('booking_reviews')
          .select('''
          *,
          user:profiles!user_id(
            display_name,
            username,
            avatar_url
          )
        ''')
          .eq('shop_id', shopId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => BookingReview.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get shop reviews: $e');
    }
  }

  @override
  Future<bool> hasReview(String bookingId) async {
    try {
      final response =
          await _client
              .from('booking_reviews')
              .select('id')
              .eq('booking_id', bookingId)
              .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> updateReviewResponse({
    required String reviewId,
    required String response,
  }) async {
    try {
      await _client
          .from('booking_reviews')
          .update({
            'shop_response': response,
            'responded_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reviewId);
    } catch (e) {
      throw Exception('Failed to update review response: $e');
    }
  }

  @override
  Future<BookingModel> cancelBooking(String bookingId, {String? reason}) async {
    try {
      final response =
          await _client
              .from(_bookingsTable)
              .update({
                'status': BookingStatus.cancelled.value,
                'cancellation_reason': reason,
                'cancelled_at': DateTime.now().toIso8601String(),
              })
              .eq('id', bookingId)
              .select()
              .single();

      return BookingModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseBookingException(
        'Failed to cancel booking: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw DatabaseBookingException('Unexpected error: $e');
    }
  }

  // ==================== Availability Operations ====================

  @override
  Future<bool> checkAvailability({
    required String shopId,
    required String slotId,
    String? workerId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final result = await _client.rpc(
        'check_slot_availability',
        params: {
          'p_shop_id': shopId,
          'p_slot_id': slotId,
          'p_worker_id': workerId,
          'p_start_time': startTime.toIso8601String(),
          'p_end_time': endTime.toIso8601String(),
        },
      );

      return result['available'] as bool;
    } catch (e) {
      throw DatabaseBookingException('Failed to check availability: $e');
    }
  }

  // In supabase_shop_repository.dart
  @override
  Future<List<WorkerUnavailabilityModel>> getWorkerUnavailability(
    String workerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _client
        .from('worker_unavailability')
        .select('*')
        .eq('worker_id', workerId)
        .gte('start_time', startDate.toIso8601String())
        .lte('end_time', endDate.toIso8601String());

    return (response as List)
        .map((json) => WorkerUnavailabilityModel.fromJson(json))
        .toList();
  }

  // In supabase_booking_repository.dart

  @override
  Future<List<TimeSlotModel>> generateTimeSlots({
    required String shopId,
    required DateTime date,
    required List<AppointmentSlotDTO> services,
    required Map<String, int> quantities,
    Map<String, List<String>>? selectedWorkerIds,
    int? defaultBufferMinutes,
  }) async {
    try {
      final params = <String, dynamic>{
        'p_shop_id': shopId,
        'p_date': date.toIso8601String().split('T')[0],
        'p_service_ids': services.map((s) => s.id).toList(),
        'p_quantities': services.map((s) => quantities[s.id] ?? 1).toList(),
      };

      // Add selected worker IDs if provided (flattened list for parallel booking)
      if (selectedWorkerIds != null && selectedWorkerIds.isNotEmpty) {
        final allSelectedWorkers =
            selectedWorkerIds.values
                .expand((list) => list)
                .where((id) => id.isNotEmpty)
                .toList();

        if (allSelectedWorkers.isNotEmpty) {
          params['p_selected_worker_ids'] = allSelectedWorkers;
        } else {
          params['p_selected_worker_ids'] = null;
        }
      } else {
        params['p_selected_worker_ids'] = null;
      }

      // Add default buffer if provided
      if (defaultBufferMinutes != null) {
        params['p_default_buffer_minutes'] = defaultBufferMinutes;
      } else {
        params['p_default_buffer_minutes'] = null;
      }

      final result = await _client.rpc(
        'generate_available_slots',
        params: params,
      );

      // Safely map the results with null checks
      return (result as List).map((json) {
        // Handle available_workers with null safety
        final availableWorkersJson = json['available_workers'] as List? ?? [];
        final availableWorkers =
            availableWorkersJson.map((wJson) {
              return WorkerDTO(
                id: wJson['id'] as String? ?? '',
                shopId: shopId,
                name: wJson['name'] as String? ?? '',
                bio: wJson['bio'] as String?,
                profileImage: wJson['profile_image_url'] as String?,
                specialties: List<String>.from(
                  wJson['specialties'] as List? ?? [],
                ),
                isActive: true,
                ratingAverage: (wJson['rating_average'] as num?)?.toDouble(),
              );
            }).toList();

        // Handle actualEndTime with null safety
        DateTime? actualEndTime;
        if (json['actual_end_time'] != null) {
          actualEndTime = DateTime.parse(json['actual_end_time'] as String);
        }

        return TimeSlotModel(
          startTime: DateTime.parse(json['start_time'] as String),
          endTime: DateTime.parse(json['end_time'] as String),
          actualEndTime:
              actualEndTime ?? DateTime.parse(json['end_time'] as String),
          slotId: json['slot_id'] as String? ?? '',
          serviceName: json['service_name'] as String? ?? '',
          price: (json['price'] as num?)?.toDouble() ?? 0.0,
          availableWorkers: availableWorkers,
          remainingSpots: json['remaining_spots'] as int?,
          requiresWorkerSelection:
              json['requires_worker_selection'] as bool? ?? false,
          bufferMinutes: json['buffer_minutes'] as int? ?? 0,
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw DatabaseBookingException(
        e.message ?? 'Database error generating slots',
      );
    } catch (e, stack) {
      throw DatabaseBookingException('Unexpected error: $e');
    }
  }

  @override
  Future<List<WorkerDTO>> getAvailableWorkers({
    required String slotId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      // First, get all workers assigned to this slot
      final assignedWorkers = await _client
          .from('slot_worker_assignments')
          .select('worker_id')
          .eq('slot_id', slotId);

      final workerIds =
          assignedWorkers
              .map<String>((row) => row['worker_id'] as String)
              .toList();

      // Now call the RPC with the exact same parameters that worked in SQL
      final result = await _client.rpc(
        'get_available_workers',
        params: {
          'p_worker_ids': workerIds,
          'p_start_time': startTime.toIso8601String(),
          'p_end_time': endTime.toIso8601String(),
        },
      );

      // Try to map and see where it fails
      final workers =
          (result as List).map((json) {
            print('🔄 Mapping worker JSON: $json');
            return WorkerDTO.fromJson(json);
          }).toList();

      return workers;
    } on PostgrestException catch (e) {
      throw DatabaseBookingException(
        'Failed to get available workers: ${e.message}',
      );
    } catch (e) {
      print('🔥 Unexpected error: $e');
      throw DatabaseBookingException('Failed to get available workers: $e');
    }
  }

  // Add this method to SupabaseBookingRepository

  @override
  Future<BookingModel> createFreelancerBooking({
    required BookingModel booking,
    required List<BookingServiceModel> services,
    String? idempotencyKey,
  }) async {
    // Check idempotency
    if (idempotencyKey != null) {
      final existing = await _checkIdempotency(idempotencyKey);
      if (existing != null) return existing;
    }

    try {
      // Use the existing RPC function with worker_id = null
      final result = await _client.rpc(
        'create_booking_with_conflict_check',
        params: {
          'p_user_id': booking.userId,
          'p_shop_id': booking.shopId, // freelancer_id
          'p_slot_id': services.first.slotId,
          'p_worker_id': null, // No worker for freelancer
          'p_booking_date':
              booking.bookingDate.toIso8601String().split('T').first,
          'p_start_time': booking.startTime.toIso8601String(),
          'p_end_time': booking.endTime.toIso8601String(),
          'p_total_amount': booking.totalAmount,
          'p_deposit_amount': booking.depositAmount,
          'p_service_address': booking.shopAddress,
          'p_service_latitude': booking.latitude,
          'p_service_longitude': booking.longitude,
        },
      );

      final bookingId = result as String;
      final createdBooking = booking.copyWith(id: bookingId);

      // Store idempotency key
      if (idempotencyKey != null) {
        await _storeIdempotencyKey(idempotencyKey, bookingId);
      }

      return createdBooking;
    } catch (e) {
      if (e.toString().contains('SLOT_CONFLICT')) {
        throw BookingConflictException();
      }
      throw DatabaseBookingException('Failed to create freelancer booking: $e');
    }
  }

  Future<BookingModel?> _checkIdempotency(String idempotencyKey) async {
    try {
      final response =
          await _client
              .from('idempotency_keys')
              .select('booking_id')
              .eq('key', idempotencyKey)
              .maybeSingle();

      if (response != null && response['booking_id'] != null) {
        return await getBookingById(response['booking_id']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _storeIdempotencyKey(String key, String bookingId) async {
    await _client.from('idempotency_keys').insert({
      'key': key,
      'booking_id': bookingId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ==================== Validation Operations ====================

  // lib/features/booking/data/repositories/supabase/supabase_booking_repository.dart

  @override
  Future<Map<String, String>> validateBooking({
    required BookingModel booking,
    required List<BookingServiceModel> services,
  }) async {
    final errors = <String, String>{};

    try {
      // Validate basic booking info
      if (booking.startTime.isBefore(DateTime.now())) {
        errors['startTime'] = 'Booking cannot be in the past';
      }

      if (booking.endTime.isBefore(booking.startTime)) {
        errors['endTime'] = 'End time must be after start time';
      }

      // Validate each service
      for (final service in services) {
        // Check if slot exists and is active
        final slotExists =
            await _client
                .from(_appointmentSlotsTable)
                .select('id')
                .eq('id', service.slotId)
                .maybeSingle();

        if (slotExists == null) {
          errors['service_${service.slotId}'] =
              'Selected service is no longer available';
        }

        // If worker required, validate worker exists and is active
        if (service.workerId != null && service.workerId!.isNotEmpty) {
          try {
            final workerExists =
                await _client
                    .from(_shopWorkersTable)
                    .select('id')
                    .eq('id', service.workerId!) // Now safe with null check
                    .eq('is_active', true)
                    .maybeSingle();

            if (workerExists == null) {
              errors['worker_${service.workerId}'] =
                  'Selected worker is no longer available';
            }
          } catch (e) {
            // Log but don't fail validation for this specific error
            errors['worker_${service.workerId}'] =
                'Failed to validate worker availability';
          }
        }
      }

      // Validate shop hours
      try {
        final isWithinHours = await _client.rpc(
          'check_shop_hours',
          params: {
            // 'p_shop_id': booking.shopId,
            'p_start_time': booking.startTime.toIso8601String(),
            'p_end_time': booking.endTime.toIso8601String(),
          },
        );

        if (!isWithinHours) {
          errors['shopHours'] = 'Booking is outside shop operating hours';
        }
      } catch (e) {
        errors['shopHours'] = 'Unable to validate shop hours';
      }

      return errors;
    } catch (e) {
      errors['validation'] = 'Validation failed: $e';
      return errors;
    }
  }

  // Error parsing helpers
  String _extractWorkerIdFromError(String message) {
    final regex = RegExp(r'worker_id: ([a-f0-9-]+)');
    final match = regex.firstMatch(message);
    return match?.group(1) ?? 'unknown';
  }

  DateTime _extractTimeFromError(String message) {
    final regex = RegExp(r'time: ([\d-]+T[\d:]+)');
    final match = regex.firstMatch(message);
    if (match != null) {
      return DateTime.parse(match.group(1)!);
    }
    return DateTime.now();
  }

  String _extractSlotIdFromError(String message) {
    final regex = RegExp(r'slot_id: ([a-f0-9-]+)');
    final match = regex.firstMatch(message);
    return match?.group(1) ?? 'unknown';
  }

  int _extractCapacityFromError(String message) {
    final regex = RegExp(r'capacity: (\d+)');
    final match = regex.firstMatch(message);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  String _extractShopHoursFromError(String message) {
    final regex = RegExp(r'hours: (.+?)(?:,|$)');
    final match = regex.firstMatch(message);
    return match?.group(1) ?? 'unknown';
  }
}
