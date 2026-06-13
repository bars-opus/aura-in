// lib/features/booking/data/repositories/supabase/supabase_booking_repository.dart
import 'package:nano_embryo/core/utils/money.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/utils/booking_logger.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/utils/booking_retry_policy.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/utils/booking_sanitizer.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/contact_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/services/notification_service.dart';
import 'package:nano_embryo/presentation/features/shops/reviews/data/models/booking_review.dart';

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
  // Table-name constants kept as fields so test doubles can override if
  // we ever want to point at a *_test mirror schema.
  static const String _bookingServicesTable = 'booking_services';
  static const String _appointmentSlotsTable = 'appointment_slots';
  static const String _shopWorkersTable = 'workers';
  final NotificationService? _notificationService;

  SupabaseBookingRepository(this._client, [this._notificationService]);

  // ==================== Core Booking Operations ====================

  @override
  Future<BookingModel> createBooking({
    required BookingModel booking,
    required List<BookingServiceModel> services,
    String? idempotencyKey,
  }) async {
    // The server-side create_booking_transaction RPC handles idempotency
    // replay internally (matches by key + expiry window), so the client
    // doesn't need a pre-flight check anymore. Retry the whole call —
    // safe because the idempotency key dedupes replays.
    return BookingRetryPolicy.run(
      operationName: 'create_booking_transaction',
      () async {
        try {
          final result = await _client.rpc(
            'create_booking_transaction',
            params: {
              'p_booking': booking.toJson(),
              'p_services': services.map((s) => s.toJson()).toList(),
              'p_idempotency_key': idempotencyKey,
            },
          );
          return BookingModel.fromJson(result as Map<String, dynamic>);
        } on PostgrestException catch (e) {
          throw _mapBookingRpcError(e);
        }
      },
    );
  }

  /// Maps a Postgrest error from a booking-creation RPC to the right
  /// domain exception. Uses SQLSTATE codes (not message substrings) so
  /// the mapping is stable when error wording changes server-side.
  BookingException _mapBookingRpcError(PostgrestException e) {
    final code = e.code;
    final msg = e.message;

    // 53400 = configuration_limit_exceeded — our rate_limit signal.
    if (code == '53400') {
      return BookingValidationException({
        'rate': 'Too many requests. Please wait a moment and try again.',
      });
    }
    // 42501 = insufficient_privilege — auth mismatch.
    if (code == '42501') {
      return BookingValidationException({'auth': 'Not authorized'});
    }
    // 23505 = unique_violation — worker overlap, idempotency clash, or
    // the distinct-worker constraint inside the booking.
    if (code == '23505') {
      if (msg.contains('worker_id') || msg.contains('SLOT_CONFLICT')) {
        return WorkerUnavailableException(
          workerId: _extractWorkerIdFromError(msg),
          requestedTime: _extractTimeFromError(msg),
        );
      }
      return SlotUnavailableException();
    }
    // P0001 = raise_exception — domain RAISE EXCEPTION from our RPCs.
    if (code == 'P0001') {
      if (msg.contains('slot_full')) {
        return SlotFullException(
          slotId: _extractSlotIdFromError(msg),
          slotTime: _extractTimeFromError(msg),
          maxCapacity: _extractCapacityFromError(msg),
        );
      }
      if (msg.contains('outside_hours') || msg.contains('shop hours')) {
        return OutsideBusinessHoursException(
          requestedTime: _extractTimeFromError(msg),
          shopHours: _extractShopHoursFromError(msg),
        );
      }
      if (msg.contains('illegal transition') ||
          msg.contains('cannot cancel') ||
          msg.contains('cannot complete') ||
          msg.contains('cannot no-show')) {
        return BookingConflictException();
      }
    }
    // 22023 = invalid_parameter_value — bad input from the client.
    if (code == '22023') {
      return BookingValidationException({'input': msg});
    }
    // P0002 = no_data_found.
    if (code == 'P0002') {
      return BookingValidationException({'notFound': msg});
    }
    return DatabaseBookingException(msg, code: code);
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
    return BookingRetryPolicy.run(
      operationName: 'getClientBookings',
      () async {
        try {
          dynamic countQuery = _client
              .from('booking_simple')
              .select('booking_id')
              .eq('user_id', userId);

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
          final uniqueBookingIds = <String>{};
          for (final row in countResponse) {
            uniqueBookingIds.add(row['booking_id']);
          }
          final totalCount = uniqueBookingIds.length;

          dynamic query = _client
              .from('booking_simple')
              .select()
              .eq('user_id', userId);

          if (status != null) {
            query = query.eq('status', status.value);
          }
          if (fromDate != null) {
            query = query.gte('booking_date', fromDate.toIso8601String());
          }
          if (toDate != null) {
            query = query.lte('booking_date', toDate.toIso8601String());
          }

          query = query.order(sortBy ?? 'start_time', ascending: sortAscending);

          final from = (page! - 1) * pageSize!;
          final response = await query.range(from, from + pageSize - 1);

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
            if (row['service_id'] != null && row['service_name'] != null) {
              bookingMap[bookingId]!['booking_services'].add({
                'slot': {'service_name': row['service_name']},
              });
            }
          }

          final data = bookingMap.values.toList();

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
        } on PostgrestException catch (e) {
          BookingLogger.error('getClientBookings failed', error: e);
          throw DatabaseBookingException(e.message, code: e.code);
        }
      },
    );
  }

  /// Fetch appointments for a specific shop on a specific date
  /// This is a convenience method that uses getShopBookings with a single day range
  @override
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
  @override
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
    return BookingRetryPolicy.run(
      operationName: 'getShopBookings',
      () async {
        try {
          dynamic countQuery = _client
              .from('booking_simple')
              .select('booking_id')
              .eq('shop_id', shopId);

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
          final uniqueBookingIds = <String>{};
          for (final row in countResponse) {
            uniqueBookingIds.add(row['booking_id']);
          }
          final totalCount = uniqueBookingIds.length;

          dynamic query = _client
              .from('booking_simple')
              .select()
              .eq('shop_id', shopId);

          if (status != null) {
            query = query.eq('status', status.value);
          }
          if (fromDate != null) {
            query = query.gte('booking_date', fromDate.toIso8601String());
          }
          if (toDate != null) {
            query = query.lte('booking_date', toDate.toIso8601String());
          }

          query = query.order(sortBy ?? 'start_time', ascending: sortAscending);

          final from = (page! - 1) * pageSize!;
          final response = await query.range(from, from + pageSize - 1);

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
        } on PostgrestException catch (e) {
          BookingLogger.error('getShopBookings failed', error: e);
          throw DatabaseBookingException(e.message, code: e.code);
        }
      },
    );
  }

  @override
  Future<BookingModel> markAsNoShow(String bookingId) async {
    return BookingRetryPolicy.run(
      operationName: 'mark_booking_no_show',
      () async {
        try {
          final result = await _client.rpc(
            'mark_booking_no_show',
            params: {'p_booking_id': bookingId},
          );
          return BookingModel.fromJson(result as Map<String, dynamic>);
        } on PostgrestException catch (e) {
          throw _mapBookingRpcError(e);
        }
      },
    );
  }

  @override
  Future<BookingModel> markAsComplete(String bookingId) async {
    return BookingRetryPolicy.run(
      operationName: 'mark_booking_complete',
      () async {
        try {
          final result = await _client.rpc(
            'mark_booking_complete',
            params: {'p_booking_id': bookingId},
          );
          return BookingModel.fromJson(result as Map<String, dynamic>);
        } on PostgrestException catch (e) {
          throw _mapBookingRpcError(e);
        }
      },
    );
  }

  @override
  Future<BookingModel> getBookingById(String bookingId) async {
    return BookingRetryPolicy.run(
      operationName: 'getBookingById',
      () => _getBookingByIdOnce(bookingId),
    );
  }

  Future<BookingModel> _getBookingByIdOnce(String bookingId) async {
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

      // 2. Fetch shop details + locations in two queries. The embedded
      // PostgREST relationship `locations:shop_locations(...)` failed with
      // PGRST200 because no FK constraint is declared between shops and
      // shop_locations (the table was added via the Supabase dashboard).
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
          address
        ''')
              .eq('id', shopId)
              .single();

      final locationsResponse = await _client
          .from('shop_locations')
          .select('address, city, country, latitude, longitude, is_primary')
          .eq('shop_id', shopId);
      final locations = List<Map<String, dynamic>>.from(locationsResponse);

      // Extract coordinates from locations
      double? latitude;
      double? longitude;
      String? shopAddress;

      if (locations.isNotEmpty) {
        final primaryLocation = locations.firstWhere(
          (loc) => loc['is_primary'] == true,
          orElse: () => locations.first,
        );
        latitude = (primaryLocation['latitude'] as num?)?.toDouble();
        longitude = (primaryLocation['longitude'] as num?)?.toDouble();
        shopAddress =
            primaryLocation['address'] as String? ?? shopResponse['address'] as String?;
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
              // Phase 17: pass NUMERIC values through unmodified — the
              // downstream BookingServiceModel.fromJson does the boundary
              // conversion via `parseMoneyMinor`. Avoid intermediate float
              // coercion that would defeat SC-2.
              'price_at_booking': row['price_at_booking'] ?? 0,
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
                        'price': slotData['price'] ?? 0,
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
    } on PostgrestException catch (e, stack) {
      BookingLogger.error('getBookingById failed', error: e, stack: stack);
      throw DatabaseBookingException(e.message, code: e.code);
    } catch (e, stack) {
      BookingLogger.error('getBookingById unexpected error', error: e, stack: stack);
      throw DatabaseBookingException('Failed to fetch booking: $e');
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
    final cleaned = BookingSanitizer.cleanAndCap(
      requirements,
      BookingSanitizer.maxSpecialRequirements,
    );
    return BookingRetryPolicy.run(
      operationName: 'update_special_requirements',
      () async {
        try {
          await _client.rpc(
            'update_special_requirements',
            params: {
              'p_booking_service_id': bookingServiceId,
              'p_requirements': cleaned,
            },
          );
        } on PostgrestException catch (e) {
          throw _mapBookingRpcError(e);
        }
      },
    );
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
    final service = _notificationService;
    if (service == null) {
      BookingLogger.debug('notification service not wired; skipping review notification');
      return;
    }

    try {
      final starRating = _getStarRating(rating);
      final title = 'New Review Received! ⭐';
      final snippet = review != null && review.length > 50
          ? '${review.substring(0, 50)}...'
          : review;
      final body = snippet != null && snippet.isNotEmpty
          ? '$userName gave you $starRating ($rating/5): "$snippet"'
          : '$userName gave you $starRating ($rating/5)';

      await service.sendImmediateNotification(
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

      BookingLogger.debug('sent review notification to shop $shopOwnerId');
    } catch (e, stack) {
      BookingLogger.warn('failed to send review notification', error: e, stack: stack);
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
    } catch (e, stack) {
      BookingLogger.warn('failed to load review', error: e, stack: stack);
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
    final cleanReason = BookingSanitizer.cleanAndCap(
      reason,
      BookingSanitizer.maxCancellationReason,
    );
    return BookingRetryPolicy.run(
      operationName: 'cancel_booking',
      () async {
        try {
          final result = await _client.rpc(
            'cancel_booking',
            params: {
              'p_booking_id': bookingId,
              'p_reason': cleanReason,
            },
          );
          return BookingModel.fromJson(result as Map<String, dynamic>);
        } on PostgrestException catch (e) {
          throw _mapBookingRpcError(e);
        }
      },
    );
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
    return BookingRetryPolicy.run(
      operationName: 'check_slot_availability',
      () async {
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
          // The server now returns {available, reason}. Older deployments
          // might still return a plain boolean — handle both.
          if (result is Map<String, dynamic>) {
            return result['available'] == true;
          }
          if (result is bool) return result;
          return false;
        } on PostgrestException catch (e) {
          throw _mapBookingRpcError(e);
        }
      },
    );
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
    final params = <String, dynamic>{
      'p_shop_id': shopId,
      'p_date': date.toIso8601String().split('T')[0],
      'p_service_ids': services.map((s) => s.id).toList(),
      'p_quantities': services.map((s) => quantities[s.id] ?? 1).toList(),
      'p_selected_worker_ids': null,
      'p_default_buffer_minutes': defaultBufferMinutes,
    };

    if (selectedWorkerIds != null && selectedWorkerIds.isNotEmpty) {
      final allSelectedWorkers = selectedWorkerIds.values
          .expand((list) => list)
          .where((id) => id.isNotEmpty)
          .toList();
      if (allSelectedWorkers.isNotEmpty) {
        params['p_selected_worker_ids'] = allSelectedWorkers;
      }
    }

    return BookingRetryPolicy.run(
      operationName: 'generate_available_slots',
      () async {
        try {
          final result = await _client.rpc(
            'generate_available_slots',
            params: params,
          );

          return (result as List).map((json) {
            final availableWorkersJson = json['available_workers'] as List? ?? [];
            final availableWorkers = availableWorkersJson.map((wJson) {
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
              // Phase 17: NUMERIC major → int minor at the boundary.
              priceMinor: json['price'] == null
                  ? 0
                  : parseMoneyMinor(json['price'] as num),
              availableWorkers: availableWorkers,
              remainingSpots: json['remaining_spots'] as int?,
              requiresWorkerSelection:
                  json['requires_worker_selection'] as bool? ?? false,
              bufferMinutes: json['buffer_minutes'] as int? ?? 0,
            );
          }).toList();
        } on PostgrestException catch (e) {
          throw _mapBookingRpcError(e);
        }
      },
    );
  }

  @override
  Future<List<WorkerDTO>> getAvailableWorkers({
    required String slotId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    return BookingRetryPolicy.run(
      operationName: 'get_available_workers',
      () async {
        try {
          final assignedWorkers = await _client
              .from('slot_worker_assignments')
              .select('worker_id')
              .eq('slot_id', slotId);

          final workerIds = assignedWorkers
              .map<String>((row) => row['worker_id'] as String)
              .toList();

          if (workerIds.isEmpty) return <WorkerDTO>[];

          final result = await _client.rpc(
            'get_available_workers',
            params: {
              'p_worker_ids': workerIds,
              'p_start_time': startTime.toIso8601String(),
              'p_end_time': endTime.toIso8601String(),
            },
          );

          return (result as List)
              .map((json) => WorkerDTO.fromJson(json as Map<String, dynamic>))
              .toList();
        } on PostgrestException catch (e) {
          throw _mapBookingRpcError(e);
        }
      },
    );
  }

  // Add this method to SupabaseBookingRepository

  @override
  Future<BookingModel> createFreelancerBooking({
    required BookingModel booking,
    required List<BookingServiceModel> services,
    String? idempotencyKey,
  }) async {
    // Client-side idempotency check via the same key table the server
    // uses. The freelancer RPC doesn't take an idempotency_key parameter
    // yet, so we keep the read-side dedupe here for retried POSTs.
    if (idempotencyKey != null) {
      final existing = await _checkIdempotency(idempotencyKey);
      if (existing != null) return existing;
    }

    final cleanAddress = BookingSanitizer.cleanAndCap(
      booking.shopAddress,
      BookingSanitizer.maxAddress,
    );

    return BookingRetryPolicy.run(
      operationName: 'create_booking_with_conflict_check',
      () async {
        try {
          final result = await _client.rpc(
            'create_booking_with_conflict_check',
            params: {
              'p_user_id': booking.userId,
              'p_shop_id': booking.shopId,
              'p_slot_id': services.first.slotId,
              'p_worker_id': null,
              'p_booking_date':
                  booking.bookingDate.toIso8601String().split('T').first,
              'p_start_time': booking.startTime.toIso8601String(),
              'p_end_time': booking.endTime.toIso8601String(),
              // Phase 17: RPC param is NUMERIC major-units; convert at boundary.
              'p_total_amount': booking.totalAmountMinor / 100,
              'p_deposit_amount': booking.depositAmountMinor / 100,
              'p_service_address': cleanAddress,
              'p_service_latitude': booking.latitude,
              'p_service_longitude': booking.longitude,
            },
          );

          final bookingId = result as String;
          final createdBooking = booking.copyWith(id: bookingId);

          if (idempotencyKey != null) {
            await _storeIdempotencyKey(idempotencyKey, bookingId);
          }

          return createdBooking;
        } on PostgrestException catch (e) {
          if (e.message.contains('SLOT_CONFLICT')) {
            throw BookingConflictException();
          }
          throw _mapBookingRpcError(e);
        }
      },
    );
  }

  Future<BookingModel?> _checkIdempotency(String idempotencyKey) async {
    try {
      final response = await _client
          .from('idempotency_keys')
          .select('booking_id')
          .eq('key', idempotencyKey)
          .maybeSingle();

      if (response != null && response['booking_id'] != null) {
        return await getBookingById(response['booking_id']);
      }
      return null;
    } catch (e) {
      BookingLogger.debug('idempotency lookup failed (treating as miss)', error: e);
      return null;
    }
  }

  Future<void> _storeIdempotencyKey(String key, String bookingId) async {
    try {
      await _client.from('idempotency_keys').insert({
        'key': key,
        'booking_id': bookingId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      // Unique-violation here means the server already recorded the key
      // (e.g. via create_booking_transaction). That's fine — replay
      // semantics are preserved.
      if (e.code != '23505') {
        BookingLogger.warn('failed to store idempotency key', error: e);
      }
    }
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
