// lib/features/dashboard/data/repositories/supabase_dashboard_repository.dart
import 'package:flutter/material.dart';
import 'package:nano_embryo/app/theme/app_colors.dart';
import 'package:nano_embryo/presentation/features/shops/calendar/data/models/shop_calendar_booking.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/booking_heatmap_data.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/monthly_revenue.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/quaterly_category_breakdown.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/weekly_revenue.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/clients/client_profile.dart';
import 'package:nano_embryo/core/utils/logging/app_logger.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/opening_hours_draft.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/business_hours_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/service_management_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/client_notes_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/daily_report_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/pricing_override_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/client_note_dto.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/daily_report_dto.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/pricing_override_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/appointment_slot_dto.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/dashboard_metrics.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/lost_booking_metrics.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/export_report.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/performance_alert.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/quarterly_revenue.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/analytics/today_schedule_item.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/top_service.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/workers/worker_attendance.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/workers/worker_performance.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/workers/worker_profile.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/services/export_service.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/utility/date_range_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard_repository.dart';

/// Supabase implementation of DashboardRepository
class SupabaseDashboardRepository implements DashboardRepository {
  final SupabaseClient _supabase;

  SupabaseDashboardRepository({required SupabaseClient supabaseClient})
    : _supabase = supabaseClient;

  // ============ Helper Methods ============

  StatusColor _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return StatusColor.confirmed;
      case 'completed':
        return StatusColor.completed;
      case 'cancelled':
        return StatusColor.cancelled;
      case 'no_show':
      case 'noshow':
        return StatusColor.noShow;
      default:
        return StatusColor.pending;
    }
  }

  int _calculateTotalSlots(List<Map<String, dynamic>> slots) {
    return slots.fold<int>(0, (sum, slot) {
      final maxClients = slot['max_clients'];
      if (maxClients is int) {
        return sum + maxClients;
      } else if (maxClients is num) {
        return sum + maxClients.toInt();
      }
      return sum + 1;
    });
  }

  int _calculateTotalBookings(List<dynamic> items) {
    if (items.isEmpty) return 0;
    return items.fold<int>(0, (sum, item) {
      final bookingCount = item['booking_count'];
      if (bookingCount is int) return sum + bookingCount;
      if (bookingCount is num) return sum + bookingCount.toInt();
      return sum;
    });
  }

  double _calculateTotalRevenue(List<dynamic> items) {
    if (items.isEmpty) return 0.0;
    return items.fold<double>(0.0, (sum, item) {
      final revenue = item['revenue'];
      if (revenue is double) return sum + revenue;
      if (revenue is num) return sum + revenue.toDouble();
      return sum;
    });
  }

  // ============ Core Dashboard Methods ============

  @override
  Future<DashboardMetrics> getMetrics({
    required String shopId,
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();
    final dateStr = targetDate.toIso8601String().split('T').first;

    try {
      // Query today's bookings
      final bookingsResponse = await _supabase
          .from('bookings')
          .select('total_amount, deposit_amount, status')
          .eq('shop_id', shopId)
          .eq('booking_date', dateStr);

      final bookings = List<Map<String, dynamic>>.from(bookingsResponse);

      // Calculate metrics
      final todayRevenue = bookings.fold<double>(
        0,
        (sum, b) => sum + ((b['total_amount'] ?? 0).toDouble()),
      );
      final todayBookings = bookings.length;
      final cancelledBookings =
          bookings
              .where(
                (b) => b['status'] == 'cancelled' || b['status'] == 'no_show',
              )
              .length;

      final cancellationRate =
          todayBookings > 0 ? cancelledBookings / todayBookings : 0.0;
      // Get total available slots for occupancy
      final totalSlots = await getTotalAvailableSlots(
        shopId: shopId,
        date: targetDate,
      );
      final occupancyRate = totalSlots > 0 ? todayBookings / totalSlots : 0.0;
      // For trends, get yesterday's revenue
      final yesterdayRevenue = await _getRevenueForDate(
        shopId: shopId,
        date: targetDate.subtract(const Duration(days: 1)),
      );
      final revenueChangePercent =
          yesterdayRevenue > 0
              ? (todayRevenue - yesterdayRevenue) / yesterdayRevenue
              : 0.0;
      final result = DashboardMetrics(
        todayRevenue: todayRevenue,
        todayBookings: todayBookings,
        occupancyRate: occupancyRate.clamp(0.0, 1.0),
        cancellationRate: cancellationRate.clamp(0.0, 1.0),
        revenueChangePercent: revenueChangePercent,
        bookingsChangePercent: null,
      );
      return result;
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to fetch dashboard metrics',
        originalError: e,
      );
    }
  }

  Future<double> _getRevenueForDate({
    required String shopId,
    required DateTime date,
  }) async {
    final dateStr = date.toIso8601String().split('T').first;
    final response = await _supabase
        .from('bookings')
        .select('total_amount')
        .eq('shop_id', shopId)
        .eq('booking_date', dateStr);

    final bookings = List<Map<String, dynamic>>.from(response);
    return bookings.fold<double>(
      0,
      (sum, b) => sum + ((b['total_amount'] ?? 0).toDouble()),
    );
  }

  @override
  Future<List<TodayScheduleItem>> getTodaySchedule({
    required String shopId,
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();
    final dateStr = targetDate.toIso8601String().split('T').first;

    try {
      // First, get all bookings for this shop on this date
      final bookingsResponse = await _supabase
          .from('bookings')
          .select('''
          id,
          start_time,
          end_time,
          status,
          total_amount,
          deposit_amount,
          user_id
        ''')
          .eq('shop_id', shopId)
          .eq('booking_date', dateStr)
          .order('start_time', ascending: true);

      final bookings = List<Map<String, dynamic>>.from(bookingsResponse);

      if (bookings.isEmpty) {
        return [];
      }

      // Get all unique user IDs
      final userIds =
          bookings
              .map((b) => b['user_id'] as String?)
              .where((id) => id != null)
              .toSet()
              .toList();

      // Fetch user profiles
      Map<String, Map<String, dynamic>> profileMap = {};
      if (userIds.isNotEmpty) {
        final profilesResponse = await _supabase
            .from('profiles')
            .select('id, display_name, avatar_url')
            .inFilter('id', userIds);

        final profiles = List<Map<String, dynamic>>.from(profilesResponse);
        profileMap = {for (final profile in profiles) profile['id']: profile};
      }

      // For each booking, get its services
      final List<TodayScheduleItem> scheduleItems = [];

      for (final booking in bookings) {
        final userId = booking['user_id'];
        final profile = userId != null ? profileMap[userId] : null;

        // Get services for this booking
        final servicesResponse = await _supabase
            .from('booking_services')
            .select('''
            slot_id,
            worker_id,
            price_at_booking,
            duration_minutes
          ''')
            .eq('booking_id', booking['id']);

        final services = List<Map<String, dynamic>>.from(servicesResponse);

        if (services.isEmpty) continue;

        // Get first service details
        final firstService = services.first;
        final slotId = firstService['slot_id'];
        final workerId = firstService['worker_id'];

        // Get service name - try different possible column names
        String serviceName = 'Service';
        if (slotId != null) {
          try {
            // Try 'service_name' first (most common)
            var slotResponse =
                await _supabase
                    .from('appointment_slots')
                    .select('service_name')
                    .eq('id', slotId)
                    .maybeSingle();

            if (slotResponse != null && slotResponse['service_name'] != null) {
              serviceName = slotResponse['service_name'];
            } else {
              // Try 'name' as fallback
              slotResponse =
                  await _supabase
                      .from('appointment_slots')
                      .select('name')
                      .eq('id', slotId)
                      .maybeSingle();
              if (slotResponse != null && slotResponse['name'] != null) {
                serviceName = slotResponse['name'];
              } else {
                // Try 'title' as last resort
                slotResponse =
                    await _supabase
                        .from('appointment_slots')
                        .select('title')
                        .eq('id', slotId)
                        .maybeSingle();
                if (slotResponse != null && slotResponse['title'] != null) {
                  serviceName = slotResponse['title'];
                }
              }
            }
          } catch (e) {
            AppLogger.warn(
              'dashboard.today_schedule.service_lookup_failed',
              fields: {'shop_id': shopId, 'slot_id': slotId, 'error': e.toString()},
            );
          }
        }

        // Get worker name
        String workerName = 'Unassigned';
        if (workerId != null) {
          try {
            final workerResponse =
                await _supabase
                    .from('shop_workers')
                    .select('name')
                    .eq('id', workerId)
                    .maybeSingle();
            if (workerResponse != null) {
              workerName = workerResponse['name'] ?? 'Unassigned';
            }
          } catch (e) {
            AppLogger.warn(
              'dashboard.today_schedule.worker_lookup_failed',
              fields: {'shop_id': shopId, 'worker_id': workerId, 'error': e.toString()},
            );
          }
        }

        scheduleItems.add(
          TodayScheduleItem(
            id: booking['id'],
            clientName: profile?['display_name'] ?? 'Guest',
            serviceName: serviceName,
            workerName: workerName,
            workerId: workerId ?? '',
            startTime: DateTime.parse(booking['start_time']),
            endTime: DateTime.parse(booking['end_time']),
            status: _mapStatus(booking['status']),
            price: (booking['total_amount'] ?? 0).toDouble(),
            depositPaid: (booking['deposit_amount'] ?? 0).toDouble(),
            clientPhone: null,
            clientAvatarUrl: profile?['avatar_url'],
          ),
        );
      }

      return scheduleItems;
    } catch (e) {
      AppLogger.warn(
        'dashboard.today_schedule.failed',
        fields: {'shop_id': shopId, 'error': e.toString()},
      );
      throw DashboardRepositoryException(
        'Failed to fetch today\'s schedule: $e',
        originalError: e,
      );
    }
  }

  @override
  Future<int> getTotalAvailableSlots({
    required String shopId,
    required DateTime date,
  }) async {
    try {
      final dayOfWeek = date.weekday;
      // Convert Flutter weekday (Monday=1) to your DB format (0-6 where Monday=0)
      final dbDayOfWeek = dayOfWeek == 7 ? 0 : dayOfWeek;

      final response = await _supabase
          .from('appointment_slots')
          .select('max_clients')
          .eq('shop_id', shopId)
          .contains('days_of_week', [dbDayOfWeek]);

      final slots = List<Map<String, dynamic>>.from(response);
      return _calculateTotalSlots(slots);
    } catch (e) {
      return 0;
    }
  }

  // ============ Phase 2: Analytics Methods ============
  @override
  Future<YearlyRevenue> getQuarterlyRevenue({
    required String shopId,
    int? year,
  }) async {
    final targetYear = year ?? DateTime.now().year;

    try {
      // Query bookings directly. The booking_with_client_info view (added
      // via dashboard) silently joined on profiles and started returning
      // zero rows for guest bookings (user_id IS NULL). Reading the base
      // table sidesteps that, and we don't need client info here anyway.
      final response = await _supabase
          .from('bookings')
          .select('total_amount, start_time')
          .eq('shop_id', shopId)
          .inFilter('status', ['confirmed', 'completed'])
          .gte('start_time', '$targetYear-01-01')
          .lte('start_time', '$targetYear-12-31');

      final bookings = List<Map<String, dynamic>>.from(response);
      // Calculate quarterly revenue
      final quarters = <int, double>{1: 0, 2: 0, 3: 0, 4: 0};

      for (final booking in bookings) {
        final startTime = DateTime.parse(booking['start_time']);
        final quarter = ((startTime.month - 1) ~/ 3) + 1;
        final amount = (booking['total_amount'] as num).toDouble();
        quarters[quarter] = (quarters[quarter] ?? 0) + amount;
      }

      final quarterlyList =
          quarters.entries
              .where((e) => e.value > 0)
              .map(
                (e) => QuarterlyRevenue(
                  quarter: e.key,
                  amount: e.value,
                  year: targetYear,
                ),
              )
              .toList();

      final totalRevenue = quarterlyList.fold<double>(
        0,
        (sum, q) => sum + q.amount,
      );

      return YearlyRevenue(
        year: targetYear,
        quarters: quarterlyList,
        totalRevenue: totalRevenue,
      );
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to fetch quarterly revenue',
        originalError: e,
      );
    }
  }

  @override
  Future<List<ShopCalendarBooking>> getWorkerBookings({
    required String workerId,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit = 50,
  }) async {
    try {
      final startDateStr = fromDate?.toIso8601String();
      final endDateStr = toDate?.toIso8601String();
      // First, get all booking_ids where this worker is assigned
      final bookingIdsResponse = await _supabase
          .from('booking_services')
          .select('booking_id')
          .eq('worker_id', workerId);
      if (bookingIdsResponse.isEmpty) {
        return [];
      }
      final bookingIds =
          bookingIdsResponse
              .map<String>((row) => row['booking_id'] as String)
              .toList();
      // Now fetch the actual bookings from booking_simple with date filters
      dynamic query = _supabase
          .from('booking_simple')
          .select()
          .inFilter('booking_id', bookingIds)
          .inFilter('status', ['confirmed', 'completed']);

      if (fromDate != null) {
        query = query.gte('start_time', startDateStr!);
      }
      if (toDate != null) {
        query = query.lte('start_time', endDateStr!);
      }

      query = query.order('start_time', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      // Print first few booking dates to verify
      for (int i = 0; i < (response.length > 5 ? 5 : response.length); i++) {}

      // Group by booking_id
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
            'price_at_booking': row['price_at_booking'],
            'duration_minutes': row['duration_minutes'],
          });
        }
      }

      final bookings = bookingMap.values.toList();
      return bookings
          .map((booking) => ShopCalendarBooking.fromJson(booking))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ShopCalendarBooking>> getServiceBookings({
    required String slotId,
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
  }) async {
    try {
      // IMPORTANT: Ensure endDate includes the entire day

      // Ensure inclusive end date
      final (adjustedStart, adjustedEnd) = DateRangeUtils.getCustomDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      final (startDateStr, endDateStr) = DateRangeUtils.toIsoStrings(
        adjustedStart,
        adjustedEnd,
      );

      // First, get distinct booking_ids for this service
      final bookingIdsResponse = await _supabase
          .from('booking_services')
          .select('booking_id')
          .eq('slot_id', slotId);

      final bookingIds =
          bookingIdsResponse
              .map<String>((row) => row['booking_id'] as String)
              .toList();

      if (bookingIds.isEmpty) {
        return [];
      }

      // Then fetch those bookings from booking_simple
      var query = _supabase
          .from('booking_simple')
          .select()
          .inFilter('booking_id', bookingIds)
          .inFilter('status', ['confirmed', 'completed'])
          .gte('start_time', startDateStr)
          .lte('start_time', endDateStr) // Now includes full day
          .order('start_time', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      // Group by booking_id
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

        // Add the service name
        bookingMap[bookingId]!['booking_services'].add({
          'slot': {'service_name': 'Service'},
        });
      }

      // Fetch service name once
      final serviceResponse =
          await _supabase
              .from('appointment_slots')
              .select('id, service_name')
              .eq('id', slotId)
              .single();

      final serviceName = serviceResponse['service_name'];

      // Add the service name to all bookings
      for (final booking in bookingMap.values) {
        final services = booking['booking_services'] as List;
        for (var i = 0; i < services.length; i++) {
          services[i]['slot']['service_name'] = serviceName;
        }
      }

      final bookings = bookingMap.values.toList();

      return bookings
          .map((booking) => ShopCalendarBooking.fromJson(booking))
          .toList();
    } catch (e) {
      AppLogger.warn(
        'dashboard.service_bookings.failed',
        fields: {'slot_id': slotId, 'error': e.toString()},
      );
      return [];
    }
  }

  @override
  Future<List<WorkerPerformance>> getWorkersForService({
    required String slotId,
    required DateTime startDate,
    required DateTime endDate,
    int? limit = 10,
  }) async {
    try {
      // Ensure inclusive end date
      final (adjustedStart, adjustedEnd) = DateRangeUtils.getCustomDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      final (startDateStr, endDateStr) = DateRangeUtils.toIsoStrings(
        adjustedStart,
        adjustedEnd,
      );

      // Step 1: Get all booking IDs for this service
      final bookingServicesResponse = await _supabase
          .from('booking_services')
          .select('booking_id')
          .eq('slot_id', slotId);

      final allBookingIds =
          (bookingServicesResponse as List)
              .map<String>((row) => row['booking_id'] as String)
              .toList();

      if (allBookingIds.isEmpty) return [];

      // Step 2: Filter those booking IDs by date range (with inclusive end date)
      final bookingsResponse = await _supabase
          .from('bookings')
          .select('id')
          .inFilter('id', allBookingIds)
          .inFilter('status', ['completed', 'confirmed'])
          .gte('start_time', startDateStr)
          .lte('start_time', endDateStr); // Now includes full day

      final validBookingIds =
          (bookingsResponse as List)
              .map<String>((row) => row['id'] as String)
              .toList();

      if (validBookingIds.isEmpty) return [];

      // Step 3: Get booking_services for these valid booking IDs
      final response = await _supabase
          .from('booking_services')
          .select('''
          price_at_booking,
          worker:worker_id(
            id,
            name,
            profile_image_url
          )
        ''')
          .inFilter('booking_id', validBookingIds)
          .eq('slot_id', slotId)
          .not('worker_id', 'is', null);

      final items = List<Map<String, dynamic>>.from(response);

      // Group by worker
      final Map<String, WorkerPerformance> workerStats = {};

      for (final item in items) {
        final worker = item['worker'] as Map<String, dynamic>?;
        if (worker == null) continue;

        final workerId = worker['id'];
        final workerName = worker['name'];
        final workerImage = worker['profile_image_url'];
        final price = (item['price_at_booking'] as num).toDouble();

        if (!workerStats.containsKey(workerId)) {
          workerStats[workerId] = WorkerPerformance(
            id: workerId,
            name: workerName,
            profileImageUrl: workerImage,
            bookingCount: 0,
            revenue: 0,
          );
        }

        final existing = workerStats[workerId]!;
        workerStats[workerId] = WorkerPerformance(
          id: existing.id,
          name: existing.name,
          profileImageUrl: existing.profileImageUrl,
          bookingCount: existing.bookingCount + 1,
          revenue: existing.revenue + price,
        );
      }

      var workers = workerStats.values.toList();
      workers.sort((a, b) => b.bookingCount.compareTo(a.bookingCount));

      if (limit != null && workers.length > limit) {
        workers = workers.take(limit).toList();
      }

      return workers;
    } catch (e) {
      AppLogger.warn(
        'dashboard.workers_for_service.failed',
        fields: {'slot_id': slotId, 'error': e.toString()},
      );
      return [];
    }
  }

  @override
  Future<TopServicesData> getTopServices({
    required String shopId,
    required AnalyticsPeriod period,
    int limit = 5,
  }) async {
    try {
      final (startDate, endDate) = DateRangeUtils.getDateRangeForPeriod(period);
      final (startDateStr, endDateStr) = DateRangeUtils.toIsoStrings(
        startDate,
        endDate,
      );

      // Read from `bookings` directly — see getQuarterlyRevenue note.
      final bookings = await _supabase
          .from('bookings')
          .select('id')
          .eq('shop_id', shopId)
          .inFilter('status', ['confirmed', 'completed'])
          .gte('start_time', startDateStr)
          .lte('start_time', endDateStr);

      if (bookings.isEmpty) {
        return TopServicesData.empty;
      }

      final bookingIds = bookings.map((b) => b['id']).toList();
      final Map<String, Map<String, dynamic>> serviceStats = {};

      // Single batched fetch instead of N+1 per booking. Drops what was
      // O(bookings × services × 2) round-trips down to 2 queries total.
      final servicesResponse = await _supabase
          .from('booking_services')
          .select('price_at_booking, slot_id, service_name')
          .inFilter('booking_id', bookingIds);

      // Fall back to appointment_slots only for rows where service_name
      // wasn't denormalized onto booking_services (legacy data).
      final missingSlotIds = <String>{};
      for (final item in servicesResponse) {
        final slotId = item['slot_id'];
        final svcName = item['service_name'];
        if (slotId != null && (svcName == null || svcName.toString().isEmpty)) {
          missingSlotIds.add(slotId as String);
        }
      }
      final Map<String, String> slotNameById = {};
      if (missingSlotIds.isNotEmpty) {
        final slotsResponse = await _supabase
            .from('appointment_slots')
            .select('id, service_name')
            .inFilter('id', missingSlotIds.toList());
        for (final slot in slotsResponse) {
          slotNameById[slot['id'] as String] = slot['service_name'] as String? ?? '';
        }
      }

      for (final item in servicesResponse) {
        final slotId = item['slot_id'];
        if (slotId == null) continue;
        final price = (item['price_at_booking'] as num).toDouble();
        final serviceName = (item['service_name'] as String?)?.isNotEmpty == true
            ? item['service_name'] as String
            : slotNameById[slotId] ?? '';
        if (serviceName.isEmpty) continue;
        final serviceId = slotId as String;
        if (!serviceStats.containsKey(serviceId)) {
          serviceStats[serviceId] = {
            'service_id': serviceId,
            'service_name': serviceName,
            'booking_count': 0,
            'revenue': 0.0,
          };
        }
        serviceStats[serviceId]!['booking_count'] =
            serviceStats[serviceId]!['booking_count'] + 1;
        serviceStats[serviceId]!['revenue'] =
            serviceStats[serviceId]!['revenue'] + price;
      }

      if (serviceStats.isEmpty) {
        return TopServicesData.empty;
      }

      // Convert to list and sort by booking count
      final servicesList = serviceStats.values.toList();
      servicesList.sort(
        (a, b) =>
            (b['booking_count'] as int).compareTo(a['booking_count'] as int),
      );
      // Take top limit
      final topServicesRaw = servicesList.take(limit).toList();
      // Calculate total bookings for percentage
      final totalBookings = topServicesRaw.fold<int>(
        0,
        (sum, s) => sum + (s['booking_count'] as int),
      );
      // Calculate total revenue
      final totalRevenue = topServicesRaw.fold<double>(
        0,
        (sum, s) => sum + (s['revenue'] as double),
      );

      // Create TopService objects with percentages
      final topServices =
          topServicesRaw.map((s) {
            final bookingCount = s['booking_count'] as int;
            final percentage =
                totalBookings > 0 ? (bookingCount / totalBookings) * 100 : 0.0;
            return TopService(
              id: s['service_id'],
              name: s['service_name'],
              bookingCount: bookingCount,
              percentage: percentage,
              revenue: s['revenue'],
            );
          }).toList();

      return TopServicesData(
        period: period,
        services: topServices,
        totalBookings: totalBookings,
        totalRevenue: totalRevenue,
      );
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to fetch top services',
        originalError: e,
      );
    }
  }

  @override
  Future<List<TopService>> getTopServicesByDateRange({
    required String shopId,
    required DateTime startDate,
    required DateTime endDate,
    int limit = 5,
  }) async {
    try {
      final startDateStr = startDate.toIso8601String();
      final endDateStr = endDate.toIso8601String();

      // Get all booking services in the date range with their slot info
      final response = await _supabase
          .from('booking_services')
          .select('''
          price_at_booking,
          slot:slot_id(
            id,
            service_name
          ),
          booking:booking_id(
            status,
            start_time
          )
        ''')
          .inFilter('booking.status', ['confirmed', 'completed'])
          .gte('booking.start_time', startDateStr)
          .lte('booking.start_time', endDateStr);

      final services = List<Map<String, dynamic>>.from(response);
      // Group by service
      final Map<String, TopService> serviceStats = {};
      for (final item in services) {
        final slot = item['slot'] as Map<String, dynamic>?;
        if (slot == null) continue;
        final serviceId = slot['id'];
        final serviceName = slot['service_name'] ?? 'Unknown';
        final price = (item['price_at_booking'] as num).toDouble();
        if (!serviceStats.containsKey(serviceId)) {
          serviceStats[serviceId] = TopService(
            id: serviceId,
            name: serviceName,
            bookingCount: 0,
            percentage: 0,
            revenue: 0,
          );
        }

        final existing = serviceStats[serviceId]!;
        serviceStats[serviceId] = TopService(
          id: existing.id,
          name: existing.name,
          bookingCount: existing.bookingCount + 1,
          percentage: 0,
          revenue: existing.revenue + price,
        );
      }

      // Convert to list and sort by revenue
      var topServices = serviceStats.values.toList();
      topServices.sort((a, b) => b.revenue.compareTo(a.revenue));

      // Take top limit
      if (topServices.length > limit) {
        topServices = topServices.take(limit).toList();
      }

      // Calculate percentages
      final totalRevenue = topServices.fold<double>(
        0,
        (sum, s) => sum + s.revenue,
      );
      for (var i = 0; i < topServices.length; i++) {
        final service = topServices[i];
        final percentage =
            totalRevenue > 0 ? (service.revenue / totalRevenue) * 100 : 0;
        topServices[i] = TopService(
          id: service.id,
          name: service.name,
          bookingCount: service.bookingCount,
          percentage: percentage.toDouble(),
          revenue: service.revenue,
        );
      }

      return topServices;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<TopWorkersData> getTopWorkers({
    required String shopId,
    required AnalyticsPeriod period,
    int limit = 5,
  }) async {
    try {
      final (startDate, endDate) = DateRangeUtils.getDateRangeForPeriod(period);
      final (startDateStr, endDateStr) = DateRangeUtils.toIsoStrings(
        startDate,
        endDate,
      );

      // Read from `bookings` directly — see getQuarterlyRevenue note.
      final bookings = await _supabase
          .from('bookings')
          .select('id')
          .eq('shop_id', shopId)
          .inFilter('status', ['confirmed', 'completed'])
          .gte('start_time', startDateStr)
          .lte('start_time', endDateStr);

      if (bookings.isEmpty) {
        return TopWorkersData.empty;
      }

      final bookingIds = bookings.map((b) => b['id']).toList();
      // Get booking_services for these bookings
      final Map<String, Map<String, dynamic>> workerStats = {};

      // Fetch all booking_services in one batch instead of N queries
      final allServices = await _supabase
          .from('booking_services')
          .select('price_at_booking, worker_id, booking_id')
          .inFilter('booking_id', bookingIds)
          .not('worker_id', 'is', null);

      // Get all unique worker IDs
      final workerIds =
          allServices.map((s) => s['worker_id'] as String).toSet().toList();

      // Fetch all workers in one batch
      final workersData = await _supabase
          .from('workers')
          .select('id, name, profile_image_url')
          .inFilter('id', workerIds);

      final workerMap = {for (final w in workersData) w['id']: w};

      // Aggregate stats
      for (final item in allServices) {
        final workerId = item['worker_id'] as String;
        final price = (item['price_at_booking'] as num).toDouble();
        final worker = workerMap[workerId];

        if (worker == null) continue;

        if (!workerStats.containsKey(workerId)) {
          workerStats[workerId] = {
            'worker_id': workerId,
            'worker_name': worker['name'],
            'profile_image': worker['profile_image_url'],
            'booking_count': 0,
            'revenue': 0.0,
          };
        }

        workerStats[workerId]!['booking_count'] =
            workerStats[workerId]!['booking_count'] + 1;
        workerStats[workerId]!['revenue'] =
            workerStats[workerId]!['revenue'] + price;
      }

      // Convert to list and sort
      var workersList = workerStats.values.toList();
      workersList.sort(
        (a, b) =>
            (b['booking_count'] as int).compareTo(a['booking_count'] as int),
      );

      // Take top limit
      final topWorkers =
          workersList
              .take(limit)
              .map(
                (w) => WorkerPerformance(
                  id: w['worker_id'],
                  name: w['worker_name'],
                  profileImageUrl: w['profile_image'],
                  bookingCount: w['booking_count'],
                  revenue: w['revenue'],
                ),
              )
              .toList();

      final totalBookings = topWorkers.fold<int>(
        0,
        (sum, w) => sum + w.bookingCount,
      );
      final totalRevenue = topWorkers.fold<double>(
        0,
        (sum, w) => sum + w.revenue,
      );
      return TopWorkersData(
        period: period,
        workers: topWorkers,
        totalBookings: totalBookings,
        totalRevenue: totalRevenue,
      );
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to fetch top workers',
        originalError: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getRevenueComparisons({
    required String shopId,
  }) async {
    try {
      final now = DateTime.now();

      // Current week
      final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
      final currentWeekEnd = currentWeekStart.add(Duration(days: 6));

      // Previous week
      final previousWeekStart = currentWeekStart.subtract(Duration(days: 7));
      final previousWeekEnd = currentWeekEnd.subtract(Duration(days: 7));

      // Current month
      final currentMonthStart = DateTime(now.year, now.month, 1);
      final currentMonthEnd = DateTime(now.year, now.month + 1, 0);

      // Previous month
      final previousMonthStart = DateTime(now.year, now.month - 1, 1);
      final previousMonthEnd = DateTime(now.year, now.month, 0);

      // Query the view for revenue - use direct 'status' column
      final weeklyRevenue = await _getRevenueForDateRange(
        shopId: shopId,
        startDate: currentWeekStart,
        endDate: currentWeekEnd,
      );

      final previousWeeklyRevenue = await _getRevenueForDateRange(
        shopId: shopId,
        startDate: previousWeekStart,
        endDate: previousWeekEnd,
      );

      final monthlyRevenue = await _getRevenueForDateRange(
        shopId: shopId,
        startDate: currentMonthStart,
        endDate: currentMonthEnd,
      );

      final previousMonthlyRevenue = await _getRevenueForDateRange(
        shopId: shopId,
        startDate: previousMonthStart,
        endDate: previousMonthEnd,
      );

      return {
        'weekly_revenue': weeklyRevenue,
        'previous_weekly_revenue': previousWeeklyRevenue,
        'monthly_revenue': monthlyRevenue,
        'previous_monthly_revenue': previousMonthlyRevenue,
      };
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to fetch revenue comparisons',
        originalError: e,
      );
    }
  }

  // Fix the helper method
  Future<double> _getRevenueForDateRange({
    required String shopId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('total_amount')
          .eq('shop_id', shopId)
          .inFilter('status', ['confirmed', 'completed'])
          .gte('start_time', startDate.toIso8601String())
          .lte('start_time', endDate.toIso8601String());

      final bookings = List<Map<String, dynamic>>.from(response);
      return bookings.fold<double>(
        0,
        (sum, b) => sum + (b['total_amount'] ?? 0).toDouble(),
      );
    } catch (e) {
      return 0.0;
    }
  }

  // ============ Phase 3: Worker & Client Management ============
  @override
  Future<List<WorkerProfile>> getWorkers({
    required String shopId,
    bool? isActive,
  }) async {
    try {
      // Query workers that are NOT freelancers (employees only)
      var query = _supabase
          .from('workers')
          .select('''
          *,
          employee_details:employee_details(*)
        ''')
          .eq('shop_id', shopId)
          .eq('is_freelancer', false); // Only employees

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      final response = await query.order('name', ascending: true);

      // Also fetch performance metrics from bookings
      final workers = List<Map<String, dynamic>>.from(response);

      final List<WorkerProfile> result = [];

      for (final worker in workers) {
        // Fetch performance metrics (bookings count, revenue, rating)
        final performance = await _getWorkerPerformance(worker['id']);

        // Fetch attendance summary for this worker
        final attendance = await _getWorkerAttendanceSummary(worker['id']);

        // Combine all data
        final combinedData = {...worker, ...performance, ...attendance};

        result.add(WorkerProfile.fromJson(combinedData));
      }

      return result;
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to fetch workers',
        originalError: e,
      );
    }
  }

  // Helper method to get worker performance metrics
  Future<Map<String, dynamic>> _getWorkerPerformance(String workerId) async {
    try {
      // Get bookings count and revenue for this worker
      final bookingsResponse = await _supabase
          .from('booking_services')
          .select('price_at_booking, booking:booking_id(status)')
          .eq('worker_id', workerId);

      final bookings = List<Map<String, dynamic>>.from(bookingsResponse);

      // Filter completed bookings only
      final completedBookings =
          bookings
              .where(
                (b) =>
                    b['booking'] != null &&
                    b['booking']['status'] == 'completed',
              )
              .toList();

      final totalBookings = completedBookings.length;
      final totalRevenue = completedBookings.fold<double>(
        0,
        (sum, b) => sum + (b['price_at_booking'] ?? 0).toDouble(),
      );

      // Get average rating from reviews
      final reviewsResponse = await _supabase
          .from('reviews')
          .select('rating')
          .eq('worker_id', workerId);

      final reviews = List<Map<String, dynamic>>.from(reviewsResponse);
      final totalReviews = reviews.length;
      final averageRating =
          totalReviews > 0
              ? reviews.fold<double>(
                    0,
                    (sum, r) => sum + (r['rating'] ?? 0).toDouble(),
                  ) /
                  totalReviews
              : null;

      return {
        'total_bookings': totalBookings,
        'total_revenue': totalRevenue,
        'total_reviews': totalReviews,
        'average_rating': averageRating,
      };
    } catch (e) {
      return {
        'total_bookings': 0,
        'total_revenue': 0,
        'total_reviews': 0,
        'average_rating': null,
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getWorkerAttendanceSummary({
    required String workerId,
    DateTime? month,
  }) async {
    try {
      final monthDate = month ?? DateTime.now();
      final response = await _supabase.rpc(
        'get_worker_monthly_attendance',
        params: {
          'p_worker_id': workerId,
          'p_month': monthDate.toIso8601String().split('T').first,
        },
      );

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to fetch worker attendance summary',
        originalError: e,
      );
    }
  }

  @override
  Future<List<WorkerAttendance>> getWorkerAttendanceHistory({
    required String workerId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit = 30,
  }) async {
    try {
      // Use dynamic to avoid type conflicts when chaining methods
      dynamic query = _supabase
          .from('worker_attendance')
          .select('''
          *,
          breaks:worker_breaks(*)
        ''')
          .eq('worker_id', workerId);

      // Apply date filters
      if (startDate != null) {
        final startDateStr = startDate.toIso8601String().split('T').first;
        query = query.gte('date', startDateStr);
      }
      if (endDate != null) {
        final endDateStr = endDate.toIso8601String().split('T').first;
        query = query.lte('date', endDateStr);
      }

      // Apply ordering (this changes the type to PostgrestTransformBuilder)
      query = query.order('date', ascending: false);

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      final attendanceList = List<Map<String, dynamic>>.from(response);

      return attendanceList.map(WorkerAttendance.fromJson).toList();
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to fetch worker attendance history',
        originalError: e,
      );
    }
  }

  // Update getWorkerById method
  @override
  Future<WorkerProfile?> getWorkerById({required String workerId}) async {
    try {
      final response =
          await _supabase
              .from('workers')
              .select('''
          *,
          employee_details:employee_details(*)
        ''')
              .eq('id', workerId)
              .maybeSingle();

      if (response == null) return null;

      // Fetch performance metrics
      final performance = await _getWorkerPerformance(workerId);

      // Fetch attendance summary
      final attendance = await _getWorkerAttendanceSummary(workerId);

      // Combine all data
      final combinedData = {...response, ...performance, ...attendance};

      return WorkerProfile.fromJson(combinedData);
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to fetch worker',
        originalError: e,
      );
    }
  }

  Future<Map<String, dynamic>> _getWorkerAttendanceSummary(
    String workerId,
  ) async {
    try {
      // First, check if the worker_attendance table has data for this worker
      final attendanceCheck = await _supabase
          .from('worker_attendance')
          .select('id')
          .eq('worker_id', workerId)
          .limit(1);

      if (attendanceCheck.isEmpty) {
        // No attendance records, return zeros
        return {
          'days_worked': 0,
          'total_hours': 0,
          'on_time_rate': 0,
          'late_arrivals': 0,
          'absent_days': 0,
        };
      }

      // Try to call the RPC function
      try {
        final response = await _supabase.rpc(
          'get_worker_monthly_attendance',
          params: {
            'p_worker_id': workerId,
            'p_month': DateTime.now().toIso8601String().split('T').first,
          },
        );
        return Map<String, dynamic>.from(response);
      } catch (rpcError) {
        // Fallback: Calculate manually
        final startOfMonth = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          1,
        );
        final endOfMonth = DateTime(
          DateTime.now().year,
          DateTime.now().month + 1,
          0,
        );

        final attendanceRecords = await _supabase
            .from('worker_attendance')
            .select('date, status, total_hours')
            .eq('worker_id', workerId)
            .gte('date', startOfMonth.toIso8601String().split('T').first)
            .lte('date', endOfMonth.toIso8601String().split('T').first);

        final records = List<Map<String, dynamic>>.from(attendanceRecords);

        final daysWorked = records.length;
        final totalHours = records.fold<double>(
          0,
          (sum, r) => sum + (r['total_hours'] ?? 0).toDouble(),
        );
        final lateArrivals = records.where((r) => r['status'] == 'late').length;
        final absentDays = records.where((r) => r['status'] == 'absent').length;
        final onTimeRate =
            daysWorked > 0
                ? ((daysWorked - lateArrivals - absentDays) / daysWorked * 100)
                    .roundToDouble()
                : 0.0;

        return {
          'days_worked': daysWorked,
          'total_hours': totalHours,
          'on_time_rate': onTimeRate,
          'late_arrivals': lateArrivals,
          'absent_days': absentDays,
        };
      }
    } catch (e) {
      return {
        'days_worked': 0,
        'total_hours': 0,
        'on_time_rate': 0,
        'late_arrivals': 0,
        'absent_days': 0,
      };
    }
  }

  // Update createWorker method
  @override
  Future<WorkerProfile> createWorker({
    required String shopId,
    required String name,
    String? bio,
    String? profileImageUrl,
    List<String>? specialties,
    double? hourlyRate,
    String? employmentType,
    DateTime? employmentStart,
  }) async {
    try {
      // Insert into workers table
      final workerResponse =
          await _supabase
              .from('workers')
              .insert({
                'shop_id': shopId,
                'name': name,
                'bio': bio,
                'profile_image': profileImageUrl,
                'specialties': specialties ?? [],
                'is_active': true,
                'is_freelancer': false, // Always false for shop dashboard
              })
              .select()
              .single();

      // Insert into employee_details
      await _supabase.from('employee_details').insert({
        'worker_id': workerResponse['id'],
        'hourly_rate': hourlyRate,
        'employment_start': employmentStart?.toIso8601String().split('T').first,
        'employment_type': employmentType ?? 'full_time',
      });

      // Fetch the complete worker profile with details
      return await getWorkerById(workerId: workerResponse['id']) ??
          WorkerProfile.fromJson(workerResponse);
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to create worker',
        originalError: e,
      );
    }
  }

  // Update updateWorker method
  @override
  Future<WorkerProfile> updateWorker({
    required String workerId,
    String? name,
    String? bio,
    String? profileImageUrl,
    List<String>? specialties,
    bool? isActive,
    double? hourlyRate,
    String? employmentType,
    DateTime? employmentEnd,
  }) async {
    try {
      // Update workers table
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (bio != null) updates['bio'] = bio;
      if (profileImageUrl != null) updates['profile_image'] = profileImageUrl;
      if (specialties != null) updates['specialties'] = specialties;
      if (isActive != null) updates['is_active'] = isActive;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase.from('workers').update(updates).eq('id', workerId);

      // Update employee_details
      final employeeUpdates = <String, dynamic>{};
      if (hourlyRate != null) employeeUpdates['hourly_rate'] = hourlyRate;
      if (employmentType != null)
        employeeUpdates['employment_type'] = employmentType;
      if (employmentEnd != null) {
        employeeUpdates['employment_end'] =
            employmentEnd.toIso8601String().split('T').first;
      }
      employeeUpdates['updated_at'] = DateTime.now().toIso8601String();

      if (employeeUpdates.isNotEmpty) {
        await _supabase
            .from('employee_details')
            .update(employeeUpdates)
            .eq('worker_id', workerId);
      }

      // Return updated worker
      return (await getWorkerById(workerId: workerId))!;
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to update worker',
        originalError: e,
      );
    }
  }

  // Update deleteWorker method
  @override
  Future<void> deleteWorker({
    required String workerId,
    bool softDelete = true,
  }) async {
    try {
      if (softDelete) {
        await _supabase
            .from('workers')
            .update({
              'is_active': false,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', workerId);
      } else {
        // Hard delete - also deletes employee_details and attendance due to CASCADE
        await _supabase.from('workers').delete().eq('id', workerId);
      }
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to delete worker',
        originalError: e,
      );
    }
  }

  // ============ Attendance Management Methods ============

  @override
  Future<List<Map<String, dynamic>>> getTodayAttendance({
    required String shopId,
  }) async {
    try {
      final response = await _supabase
          .from('today_attendance')
          .select()
          .eq('shop_id', shopId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to fetch today\'s attendance',
        originalError: e,
      );
    }
  }

  @override
  Future<void> setWorkerUnavailability({
    required String workerId,
    required DateTime startTime,
    required DateTime endTime,
    String? reason,
  }) async {
    try {
      await _supabase.from('worker_unavailability').insert({
        'worker_id': workerId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'reason': reason,
      });
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to set worker unavailability',
        originalError: e,
      );
    }
  }

  // ============ Client Management ============
  @override
  Future<List<ClientProfile>> getClients({
    required String shopId,
    String? searchQuery,
    bool? isActive,
    int? limit = 50,
  }) async {
    try {
      // Cap the bookings scan. Previously we pulled every booking the
      // shop had ever received and aggregated in Dart — for a year-old
      // shop this could be tens of MB and seconds of wall-clock time on
      // every Clients tab open. Pulling the most-recent 2000 bookings is
      // enough to surface the most-recently-active 50 clients (the page
      // size below) with a wide safety margin, and the index
      // idx_bookings_shop_id (shop_id, start_time DESC) covers the order.
      //
      // Real fix is a SQL-side GROUP BY in a dedicated view/RPC; tracked
      // as a separate follow-up (checklist 3.1 / 3.2). This change is
      // the minimum surgery to remove the OOM risk.
      const bookingScanCap = 2000;
      final bookingsResponse = await _supabase
          .from('bookings')
          .select('user_id, total_amount, status, start_time')
          .eq('shop_id', shopId)
          .order('start_time', ascending: false)
          .limit(bookingScanCap);

      final bookings = List<Map<String, dynamic>>.from(bookingsResponse);

      if (bookings.isEmpty) {
        return [];
      }

      // Group bookings by user_id and calculate stats
      final Map<String, List<Map<String, dynamic>>> userBookingsMap = {};
      for (final booking in bookings) {
        final userId = booking['user_id'] as String?;
        if (userId == null) continue;

        userBookingsMap.putIfAbsent(userId, () => []).add(booking);
      }

      if (userBookingsMap.isEmpty) {
        return [];
      }

      // Get unique user IDs
      final uniqueUserIds = userBookingsMap.keys.toList();

      // Fetch profiles for these user IDs from the profiles table
      final profilesResponse = await _supabase
          .from('profiles')
          .select()
          .inFilter('id', uniqueUserIds);

      final profiles = List<Map<String, dynamic>>.from(profilesResponse);

      // Create a map for quick profile lookup
      final profileMap = {
        for (final profile in profiles) profile['id']: profile,
      };

      // Build client profiles
      final List<ClientProfile> clients = [];

      for (final userId in uniqueUserIds) {
        final userBookings = userBookingsMap[userId] ?? [];
        if (userBookings.isEmpty) continue;

        // Calculate stats
        final totalBookings = userBookings.length;
        double totalSpent = 0.0;
        DateTime? lastBookingAt;

        for (final booking in userBookings) {
          // Only count completed bookings for total spent
          if (booking['status'] == 'completed') {
            totalSpent += (booking['total_amount'] ?? 0).toDouble();
          }

          // Track last booking date
          final bookingDate = DateTime.parse(booking['start_time']);
          if (lastBookingAt == null || bookingDate.isAfter(lastBookingAt)) {
            lastBookingAt = bookingDate;
          }
        }

        // Get profile data
        final profile = profileMap[userId];

        clients.add(
          ClientProfile(
            id: userId,
            fullName: profile?['display_name'] ?? 'Client',
            avatarUrl: profile?['avatar_url'],
            username: profile?['username'] ?? '',
            createdAt:
                profile?['created_at'] != null
                    ? DateTime.parse(profile!['created_at'])
                    : null,
            lastBookingAt: lastBookingAt,
            totalBookings: totalBookings,
            totalSpent: totalSpent,
          ),
        );
      }

      // Sort by last booking (most recent first)
      clients.sort((a, b) {
        final aDate = a.lastBookingAt ?? DateTime(2000);
        final bDate = b.lastBookingAt ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      // Apply search filter (search by display name only)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        clients.removeWhere((c) {
          return !c.displayName.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
        });
      }

      // Apply limit
      if (limit != null && clients.length > limit) {
        return clients.take(limit).toList();
      }

      return clients;
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to fetch clients: $e',
        originalError: e,
      );
    }
  }

  @override
  Future<ClientProfile?> getClientById({required String clientId}) async {
    try {
      // First, try to get user profile from your custom users table
      // If you don't have a users table, you might need to use auth.users
      final response =
          await _supabase
              .from('users') // Make sure this table exists
              .select(
                'id, username, display_name, email, phone, avatar_url, created_at',
              )
              .eq('id', clientId)
              .maybeSingle();

      if (response == null) return null;

      // Get bookings stats for this client
      final bookingsResponse = await _supabase
          .from('bookings')
          .select('total_amount, status')
          .eq('user_id', clientId);
      // Don't filter by shop_id here because a client might have booked at multiple shops

      final bookings = List<Map<String, dynamic>>.from(bookingsResponse);

      // Count all bookings
      final totalBookings = bookings.length;

      // Calculate total spent from completed bookings only
      final completedBookings =
          bookings.where((b) => b['status'] == 'completed').toList();
      final totalSpent = completedBookings.fold<double>(
        0,
        (sum, b) => sum + (b['total_amount'] ?? 0).toDouble(),
      );

      // Get last booking date
      DateTime? lastBookingAt;
      if (bookings.isNotEmpty) {
        // Get the most recent booking date
        final lastBookingResponse =
            await _supabase
                .from('bookings')
                .select('created_at')
                .eq('user_id', clientId)
                .order('created_at', ascending: false)
                .limit(1)
                .maybeSingle();

        if (lastBookingResponse != null) {
          lastBookingAt = DateTime.parse(lastBookingResponse['created_at']);
        }
      }

      return ClientProfile(
        id: response['id'],
        // email:
        //     response['email'] ??
        // response['username'], // Fallback to username if email missing
        fullName: response['display_name'] ?? response['username'] ?? 'Client',
        // phone: response['phone'],
        avatarUrl: response['avatar_url'],
        createdAt:
            response['created_at'] != null
                ? DateTime.parse(response['created_at'])
                : null,
        lastBookingAt: lastBookingAt,
        totalBookings: totalBookings,
        totalSpent: totalSpent,
      );
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to fetch client',
        originalError: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getClientAnalytics({
    required String clientId,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_client_analytics',
        params: {'p_client_id': clientId},
      );

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to fetch client analytics',
        originalError: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getClientStats({
    required String shopId,
    int months = 6,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_client_stats',
        params: {'p_shop_id': shopId, 'p_months': months},
      );

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to fetch client stats',
        originalError: e,
      );
    }
  }

  @override
  Future<List<WeeklyRevenue>> getWeeklyRevenueBreakdown({
    required String shopId,
    int weeks = 12,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: weeks * 7));

      final startDateStr = startDate.toIso8601String();
      final endDateStr = endDate.toIso8601String();

      final response = await _supabase
          .from('bookings')
          .select('total_amount, start_time')
          .eq('shop_id', shopId)
          .inFilter('status', ['confirmed', 'completed'])
          .gte('start_time', startDateStr)
          .lte('start_time', endDateStr);

      final bookings = List<Map<String, dynamic>>.from(response);

      // Group by week
      final Map<String, WeeklyRevenue> weeklyMap = {};

      for (final booking in bookings) {
        final startTime = DateTime.parse(booking['start_time']);
        final weekStart = _getStartOfWeek(startTime);
        final weekEnd = weekStart.add(const Duration(days: 6));
        final weekNumber = _getWeekNumber(startTime);
        final year = startTime.year;
        final weekKey = '$year-W${weekNumber.toString().padLeft(2, '0')}';
        final amount = (booking['total_amount'] as num).toDouble();

        if (!weeklyMap.containsKey(weekKey)) {
          final isCurrentWeek = _isCurrentWeek(weekStart);
          weeklyMap[weekKey] = WeeklyRevenue(
            weekNumber: weekNumber,
            year: year,
            startDate: weekStart,
            endDate: weekEnd,
            revenue: 0,
            bookingCount: 0,
            isPartial: isCurrentWeek,
          );
        }

        final existing = weeklyMap[weekKey]!;
        weeklyMap[weekKey] = WeeklyRevenue(
          weekNumber: existing.weekNumber,
          year: existing.year,
          startDate: existing.startDate,
          endDate: existing.endDate,
          revenue: existing.revenue + amount,
          bookingCount: existing.bookingCount + 1,
          isPartial: existing.isPartial,
        );
      }

      var weeksList = weeklyMap.values.toList();
      weeksList.sort((a, b) => b.startDate.compareTo(a.startDate));

      if (weeksList.length > weeks) {
        weeksList = weeksList.take(weeks).toList();
      }

      return weeksList;
    } catch (e) {
      return [];
    }
  }

  int _getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final firstMonday = _getFirstMondayOfYear(date.year);

    if (date.isBefore(firstMonday)) {
      return 1;
    }

    final daysDifference = date.difference(firstMonday).inDays;
    return (daysDifference / 7).floor() + 1;
  }

  DateTime _getFirstMondayOfYear(int year) {
    final firstDay = DateTime(year, 1, 1);
    final daysToAdd = (8 - firstDay.weekday) % 7;
    return firstDay.add(Duration(days: daysToAdd));
  }

  bool _isCurrentWeek(DateTime weekStart) {
    final now = DateTime.now();
    final currentWeekStart = _getStartOfWeek(now);
    return weekStart.isAtSameMomentAs(currentWeekStart);
  }

  @override
  Future<List<MonthlyRevenue>> getMonthlyRevenueBreakdown({
    required String shopId,
    int months = 12,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = DateTime(endDate.year, endDate.month - months + 1, 1);

      final startDateStr = startDate.toIso8601String();
      final endDateStr = endDate.toIso8601String();

      final response = await _supabase
          .from('bookings')
          .select('total_amount, start_time')
          .eq('shop_id', shopId)
          .inFilter('status', ['confirmed', 'completed'])
          .gte('start_time', startDateStr)
          .lte('start_time', endDateStr);

      final bookings = List<Map<String, dynamic>>.from(response);

      // Group by month
      final Map<String, MonthlyRevenue> monthlyMap = {};

      for (final booking in bookings) {
        final startTime = DateTime.parse(booking['start_time']);
        final monthKey = '${startTime.year}-${startTime.month}';
        final amount = (booking['total_amount'] as num).toDouble();

        if (!monthlyMap.containsKey(monthKey)) {
          monthlyMap[monthKey] = MonthlyRevenue(
            month: startTime.month,
            year: startTime.year,
            revenue: 0,
            bookingCount: 0,
          );
        }

        final existing = monthlyMap[monthKey]!;
        monthlyMap[monthKey] = MonthlyRevenue(
          month: existing.month,
          year: existing.year,
          revenue: existing.revenue + amount,
          bookingCount: existing.bookingCount + 1,
        );
      }
      var monthsList = monthlyMap.values.toList();
      monthsList.sort((a, b) => b.year.compareTo(a.year));
      monthsList.sort((a, b) => b.month.compareTo(a.month));
      if (monthsList.length > months) {
        monthsList = monthsList.take(months).toList();
      }
      return monthsList;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<MonthlyRevenue>> getMonthlyRevenueForQuarter({
    required String shopId,
    required int year,
    required int quarter,
  }) async {
    try {
      final startMonth = (quarter - 1) * 3 + 1;
      final endMonth = quarter * 3;

      final startDate = DateTime(year, startMonth, 1);
      final endDate = DateTime(year, endMonth + 1, 0);

      final startDateStr = startDate.toIso8601String();
      final endDateStr = endDate.toIso8601String();

      final response = await _supabase
          .from('bookings')
          .select('total_amount, start_time')
          .eq('shop_id', shopId)
          .inFilter('status', ['confirmed', 'completed'])
          .gte('start_time', startDateStr)
          .lte('start_time', endDateStr);

      final bookings = List<Map<String, dynamic>>.from(response);

      // Group by month
      final Map<int, MonthlyRevenue> monthlyMap = {};

      for (int month = startMonth; month <= endMonth; month++) {
        monthlyMap[month] = MonthlyRevenue(
          month: month,
          revenue: 0,
          bookingCount: 0,
          year: year,
        );
      }

      for (final booking in bookings) {
        final startTime = DateTime.parse(booking['start_time']);
        final month = startTime.month;
        final amount = (booking['total_amount'] as num).toDouble();

        if (monthlyMap.containsKey(month)) {
          final existing = monthlyMap[month]!;
          monthlyMap[month] = MonthlyRevenue(
            month: month,
            revenue: existing.revenue + amount,
            bookingCount: existing.bookingCount + 1,
            year: year,
          );
        }
      }

      return monthlyMap.values.toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<QuaterlyCategoryBreakdown>> getCategoryBreakdownForQuarter({
    required String shopId,
    required int year,
    required int quarter,
  }) async {
    try {
      final startMonth = (quarter - 1) * 3 + 1;
      final endMonth = quarter * 3;
      final startDate = DateTime(year, startMonth, 1);
      final endDate = DateTime(year, endMonth + 1, 0);
      // Use booking_simple view to get service names
      final response = await _supabase
          .from('booking_simple')
          .select('total_amount, service_name')
          .eq('shop_id', shopId)
          .inFilter('status', ['confirmed', 'completed'])
          .gte('start_time', startDate.toIso8601String())
          .lte('start_time', endDate.toIso8601String());

      final bookings = List<Map<String, dynamic>>.from(response);

      // Group by service_name directly (no categorization)
      final Map<String, double> serviceAmounts = {};
      double totalRevenue = 0;

      for (final booking in bookings) {
        final amount = (booking['total_amount'] as num).toDouble();
        final serviceName =
            booking['service_name']?.toString() ?? 'Unknown Service';

        totalRevenue += amount;
        serviceAmounts[serviceName] =
            (serviceAmounts[serviceName] ?? 0) + amount;
      }

      final categories =
          serviceAmounts.entries.map((entry) {
            final percentage =
                totalRevenue > 0 ? (entry.value / totalRevenue) * 100 : 0;
            return QuaterlyCategoryBreakdown(
              name: entry.key, // Use actual service name
              amount: entry.value,
              percentage: percentage.toDouble(),
              icon: Icons.attach_money, // Default icon
            );
          }).toList();
      // Sort by amount descending
      categories.sort((a, b) => b.amount.compareTo(a.amount));
      // Limit to top 10 to keep UI clean
      if (categories.length > 10) {
        return categories.take(10).toList();
      }
      return categories;
    } catch (e) {
      return [];
    }
  }

  DateTime _getStartOfWeek(DateTime date) {
    final daysToSubtract = date.weekday - 1;
    return date.subtract(Duration(days: daysToSubtract));
  }

  // ============ Phase 4: Waitlist, Alerts, Heatmap, Reminders ============

  @override
  Future<List<PerformanceAlert>> getAlerts({
    required String shopId,
    bool? unreadOnly,
    int? limit = 20,
  }) async {
    try {
      // Compose with `dynamic` because Postgrest's builders return
      // narrowing types as we add filters/order/limit — the same
      // pattern used everywhere else in this file.
      dynamic query = _supabase
          .from('performance_alerts')
          .select('*')
          .eq('shop_id', shopId);

      if (unreadOnly == true) {
        query = query.eq('is_read', false);
      }

      query = query.order('created_at', ascending: false);

      // Apply the cap. The previous implementation accepted `limit`
      // as a parameter but never called `.limit()` — so it returned
      // every alert the shop has ever had, ignoring the default 20.
      // Cap at 200 to keep response payloads bounded even if a future
      // caller passes something unreasonable (checklist 2.5).
      final effectiveLimit = (limit ?? 20).clamp(1, 200);
      query = query.limit(effectiveLimit);

      final response = await query;
      final alerts = List<Map<String, dynamic>>.from(response);
      return alerts.map(PerformanceAlert.fromJson).toList();
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to fetch alerts',
        originalError: e,
      );
    }
  }

  @override
  Future<void> markAlertRead(String alertId) async {
    try {
      await _supabase
          .from('performance_alerts')
          .update({'is_read': true})
          .eq('id', alertId);
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to mark alert as read',
        originalError: e,
      );
    }
  }

  @override
  Future<void> resolveAlert(String alertId) async {
    try {
      await _supabase
          .from('performance_alerts')
          .update({'resolved_at': DateTime.now().toIso8601String()})
          .eq('id', alertId);
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to resolve alert',
        originalError: e,
      );
    }
  }

  @override
  Future<List<PerformanceAlert>> generateAlerts(String shopId) async {
    try {
      final response = await _supabase.rpc(
        'generate_performance_alerts',
        params: {'p_shop_id': shopId},
      );

      final alerts = List<Map<String, dynamic>>.from(response);
      return alerts.map(PerformanceAlert.fromJson).toList();
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to generate alerts',
        originalError: e,
      );
    }
  }

  @override
  Future<BookingHeatmapData> getBookingHeatmap({
    required String shopId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_booking_heatmap',
        params: {
          'p_shop_id': shopId,
          'p_start_date': startDate.toIso8601String().split('T').first,
          'p_end_date': endDate.toIso8601String().split('T').first,
        },
      );
      return BookingHeatmapData.fromJson(response);
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to fetch booking heatmap $e',
        originalError: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getReminderSettings(String shopId) async {
    try {
      final response =
          await _supabase
              .from('shop_settings')
              .select('reminder_settings')
              .eq('shop_id', shopId)
              .maybeSingle();

      if (response == null) {
        return {
          'enabled': true,
          'reminder_hours': 24,
          'sms_enabled': true,
          'email_enabled': true,
          'marketing_enabled': false,
        };
      }

      return Map<String, dynamic>.from(response['reminder_settings'] ?? {});
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to fetch reminder settings',
        originalError: e,
      );
    }
  }

  @override
  Future<void> updateReminderSettings({
    required String shopId,
    bool? enabled,
    int? reminderHours,
    bool? smsEnabled,
    bool? emailEnabled,
    bool? marketingEnabled,
  }) async {
    try {
      // Get current settings
      final current = await getReminderSettings(shopId);

      final updatedSettings = {
        'enabled': enabled ?? current['enabled'],
        'reminder_hours': reminderHours ?? current['reminder_hours'],
        'sms_enabled': smsEnabled ?? current['sms_enabled'],
        'email_enabled': emailEnabled ?? current['email_enabled'],
        'marketing_enabled': marketingEnabled ?? current['marketing_enabled'],
      };

      await _supabase.from('shop_settings').upsert({
        'shop_id': shopId,
        'reminder_settings': updatedSettings,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw DashboardRepositoryException(
        'Failed to update reminder settings',
        originalError: e,
      );
    }
  }

  @override
  Future<void> sendManualReminder(String bookingId) async {
    try {
      await _supabase.rpc(
        'schedule_manual_booking_reminder',
        params: {'p_booking_id': bookingId},
      );
    } on PostgrestException catch (e) {
      throw DashboardRepositoryException(
        _classifyReminderError(e),
        originalError: e,
      );
    } catch (e) {
      throw DashboardRepositoryException('reminder_send_failed', originalError: e);
    }
  }

  @override
  Future<int> sendBulkReminders(String shopId, {DateTime? date}) async {
    try {
      final targetDate = date ?? DateTime.now();
      final dateStr = targetDate.toIso8601String().split('T').first;
      final count = await _supabase.rpc(
        'schedule_bulk_manual_booking_reminders',
        params: {'p_shop_id': shopId, 'p_date': dateStr},
      );
      return (count as num).toInt();
    } on PostgrestException catch (e) {
      throw DashboardRepositoryException(
        _classifyReminderError(e),
        originalError: e,
      );
    } catch (e) {
      throw DashboardRepositoryException('reminder_send_failed', originalError: e);
    }
  }

  /// Maps PostgrestException from the two reminder RPCs to a stable
  /// internal classifier. Never echoes the raw exception body.
  String _classifyReminderError(PostgrestException e) {
    if (e.code == '42501' || e.code == 'P0002') return 'not_found';
    final hint = e.hint ?? '';
    if (hint.contains('BOOKING_ALREADY_STARTED')) return 'booking_in_past';
    if (hint.contains('NO_PUSH_FOR_GUEST')) return 'guest_booking_not_supported';
    if (e.code == '22023') return 'invalid_input';
    return 'reminder_send_failed';
  }

  @override
  Future<ExportResult> exportReport(ExportConfig config) async {
    final exportService = ExportService(supabaseClient: _supabase);
    return await exportService.exportReport(config);
  }

  @override
  Future<List<ReportType>> getAvailableReports(String shopId) async {
    return ReportType.values.toList();
  }

  // ────────────────────────────────────────────────────────────────────
  // Lost-booking metrics (Phase 10).
  //
  // All three call SECURITY DEFINER RPCs. Postgrest surfaces the RPC's
  // RAISE EXCEPTION via PostgrestException; we map SQLSTATE codes to
  // stable internal classifiers and throw a sanitized
  // DashboardRepositoryException. The raw provider response is never
  // echoed into the message (checklist 4.4, 5.5).
  // ────────────────────────────────────────────────────────────────────

  @override
  Future<LostBookingSummary> getLostBookingSummary({
    required String shopId,
    int periodDays = 7,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_lost_booking_summary',
        params: {'p_shop_id': shopId, 'p_period_days': periodDays},
      );
      return LostBookingSummary.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    } on PostgrestException catch (e) {
      throw DashboardRepositoryException(
        _classifyLostBookingError(e),
        originalError: e,
      );
    } catch (e) {
      throw DashboardRepositoryException('load_failed', originalError: e);
    }
  }

  @override
  Future<List<LostBookingWeek>> getLostBookingWeeklySeries({
    required String shopId,
    int weeks = 12,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_lost_booking_weekly_series',
        params: {'p_shop_id': shopId, 'p_weeks': weeks},
      );
      final map = Map<String, dynamic>.from(response as Map);
      final list = (map['weeks'] as List? ?? const []);
      return list
          .map((row) =>
              LostBookingWeek.fromJson(Map<String, dynamic>.from(row as Map)))
          .toList();
    } on PostgrestException catch (e) {
      throw DashboardRepositoryException(
        _classifyLostBookingError(e),
        originalError: e,
      );
    } catch (e) {
      throw DashboardRepositoryException('load_failed', originalError: e);
    }
  }

  @override
  Future<List<LostBookingOffender>> getLostBookingOffenders({
    required String shopId,
    int lookbackDays = 90,
    int minLost = 2,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_lost_booking_offenders',
        params: {
          'p_shop_id': shopId,
          'p_lookback_days': lookbackDays,
          'p_min_lost': minLost,
        },
      );
      final map = Map<String, dynamic>.from(response as Map);
      final list = (map['offenders'] as List? ?? const []);
      return list
          .map((row) => LostBookingOffender.fromJson(
              Map<String, dynamic>.from(row as Map)))
          .toList();
    } on PostgrestException catch (e) {
      throw DashboardRepositoryException(
        _classifyLostBookingError(e),
        originalError: e,
      );
    } catch (e) {
      throw DashboardRepositoryException('load_failed', originalError: e);
    }
  }

  /// Maps a PostgrestException raised by one of the three lost-booking
  /// RPCs to a stable internal classifier. The returned string is used
  /// as the [DashboardRepositoryException.message] and MUST NOT contain
  /// any element of the original provider payload — keeping it
  /// classifier-only lets the controller drive UI copy from a known set
  /// of cases.
  String _classifyLostBookingError(PostgrestException e) {
    if (e.code == '42501') return 'not_found';
    if (e.code == '22023') return 'invalid_range';
    return 'load_failed';
  }

  // ────────────────────────────────────────────────────────────────────
  // Business Hours + Service Management (Phase 11).
  //
  // All three methods funnel PostgrestException through HINT-aware
  // classifiers and throw the typed BusinessHoursException /
  // ServiceManagementException subtypes. Raw provider responses never
  // reach the UI (checklist 4.4 + 5.5).
  // ────────────────────────────────────────────────────────────────────

  @override
  Future<void> rebuildShopOpeningHours({
    required String shopId,
    required List<OpeningHoursDraft> hours,
  }) async {
    // Locked correction 1: opens_at / closes_at pass through as TEXT.
    // The existing UI already writes "09:00 AM" strings — no conversion.
    final hoursJson = hours
        .map((h) => {
              'day_of_week': h.dayOfWeek,
              'opens_at': h.opensAt,
              'closes_at': h.closesAt,
              'is_closed': h.isClosed,
            })
        .toList();
    try {
      await _supabase.rpc(
        'rebuild_shop_opening_hours',
        params: {'p_shop_id': shopId, 'p_hours': hoursJson},
      );
    } on PostgrestException catch (e) {
      AppLogger.warn(
        'dashboard.rebuild_hours_failed',
        fields: {'shop_id': shopId, 'error': e.toString()},
      );
      throw _classifyHoursError(e, shopId);
    } catch (e) {
      AppLogger.warn(
        'dashboard.rebuild_hours_failed',
        fields: {'shop_id': shopId, 'error': e.toString()},
      );
      throw HoursSaveFailedException();
    }
  }

  /// Maps PostgrestException raised by `rebuild_shop_opening_hours`
  /// to the typed exception subtype the controller branches on.
  BusinessHoursException _classifyHoursError(
      PostgrestException e, String shopId) {
    if (e.code == '42501') return HoursNotFoundException(shopId);
    final hint = e.hint ?? '';
    if (e.code == '22023' && hint == 'DAY_OF_WEEK_OUT_OF_RANGE') {
      return DayOfWeekOutOfRangeException();
    }
    if (e.code == '22023') return InvalidHoursPayloadException();
    return HoursSaveFailedException();
  }

  @override
  Future<List<AppointmentSlotDTO>> getActiveServices(String shopId) async {
    try {
      final response = await _supabase
          .from('appointment_slots')
          .select('*')
          .eq('shop_id', shopId)
          .isFilter('archived_at', null)
          .order('created_at', ascending: false)
          .limit(200);
      final rows = List<Map<String, dynamic>>.from(response);
      return rows.map(AppointmentSlotDTO.fromJson).toList();
    } on PostgrestException catch (e) {
      AppLogger.warn(
        'dashboard.list_services_failed',
        fields: {'shop_id': shopId, 'error': e.toString()},
      );
      throw ServiceSaveFailedException();
    } catch (e) {
      AppLogger.warn(
        'dashboard.list_services_failed',
        fields: {'shop_id': shopId, 'error': e.toString()},
      );
      throw ServiceSaveFailedException();
    }
  }

  @override
  Future<void> archiveAppointmentSlot(String slotId) async {
    try {
      await _supabase.rpc(
        'archive_appointment_slot',
        params: {'p_slot_id': slotId},
      );
    } on PostgrestException catch (e) {
      AppLogger.warn(
        'service.archive_failed',
        fields: {'slot_id': slotId, 'error': e.toString()},
      );
      if (e.code == '42501') throw ServiceNotFoundException(slotId);
      if (e.code == '22023') throw InvalidServicePayloadException();
      throw ServiceArchiveFailedException();
    } catch (e) {
      AppLogger.warn(
        'service.archive_failed',
        fields: {'slot_id': slotId, 'error': e.toString()},
      );
      throw ServiceArchiveFailedException();
    }
  }

  // ── Phase 12 — Client sticky notes ────────────────────────────────
  //
  // Read path: direct table SELECT keyed on (shop_id, user_id |
  // guest_profile_id). RLS enforces shop-owner-only access; the
  // implementation does not re-check authz in Dart.
  //
  // Write path: SECURITY DEFINER RPC upsert_client_note. Errors are
  // mapped via PostgrestException.code + .hint to the typed
  // ClientNoteException subtypes. NO string-matching on .message.

  @override
  Future<ClientNoteDTO?> getClientNote({
    required String shopId,
    String? userId,
    String? guestProfileId,
  }) async {
    assert(
      (userId == null) != (guestProfileId == null),
      'Exactly one of userId / guestProfileId must be non-null',
    );
    try {
      final query = _supabase
          .from('client_notes')
          .select('*')
          .eq('shop_id', shopId);
      final filtered = userId != null
          ? query.eq('user_id', userId)
          : query.eq('guest_profile_id', guestProfileId!);
      final row = await filtered.maybeSingle();
      if (row == null) return null;
      return ClientNoteDTO.fromJson(row);
    } on PostgrestException catch (e) {
      AppLogger.warn(
        'client_note.fetch_failed',
        fields: {'shop_id': shopId, 'error': e.toString()},
      );
      if (e.code == '42501' || e.code == 'P0002') {
        throw NoteAccessDeniedException();
      }
      throw NoteSaveFailedException();
    } catch (e) {
      AppLogger.warn(
        'client_note.fetch_failed',
        fields: {'shop_id': shopId, 'error': e.toString()},
      );
      throw NoteSaveFailedException();
    }
  }

  @override
  Future<String> upsertClientNote({
    required String shopId,
    String? userId,
    String? guestProfileId,
    required String body,
  }) async {
    assert(
      (userId == null) != (guestProfileId == null),
      'Exactly one of userId / guestProfileId must be non-null',
    );
    try {
      final result = await _supabase.rpc(
        'upsert_client_note',
        params: {
          'p_shop_id': shopId,
          'p_user_id': userId,
          'p_guest_profile_id': guestProfileId,
          'p_body': body,
        },
      );
      return result as String;
    } on PostgrestException catch (e) {
      AppLogger.warn(
        'client_note.upsert_failed',
        fields: {'shop_id': shopId, 'error': e.toString()},
      );
      throw _classifyNoteError(e);
    } catch (e) {
      AppLogger.warn(
        'client_note.upsert_failed',
        fields: {'shop_id': shopId, 'error': e.toString()},
      );
      throw NoteSaveFailedException();
    }
  }

  /// Maps PostgrestException raised by `upsert_client_note` to the
  /// typed exception subtype the widget switches on. NO string-matching
  /// on `e.message` — branching is exclusively on `e.code` + `e.hint`.
  ClientNoteException _classifyNoteError(PostgrestException e) {
    if (e.code == '42501') return NoteAccessDeniedException();
    final hint = e.hint ?? '';
    if (e.code == '22023' && hint == 'NOTE_TOO_LONG') {
      return NoteTooLongException();
    }
    if (e.code == '22023') return NotePayloadInvalidException();
    return NoteSaveFailedException();
  }

  // ── Phase 15 — Pricing overrides ──────────────────────────────────
  //
  // Four methods backing the owner-facing pricing-rules surface. List +
  // create + update + archive. Errors funnel through
  // `_classifyPricingOverrideError` which is HINT-driven and never
  // branches on `e.message`.

  @override
  Future<List<PricingOverrideDTO>> getPricingOverrides({
    required String slotId,
  }) async {
    try {
      final response = await _supabase
          .from('pricing_overrides')
          .select('*')
          .eq('slot_id', slotId)
          .isFilter('archived_at', null)
          .order('created_at', ascending: false);
      final rows = List<Map<String, dynamic>>.from(response);
      return rows.map(PricingOverrideDTO.fromJson).toList();
    } on PostgrestException catch (e) {
      AppLogger.warn(
        'pricing_override.list_failed',
        fields: {'slot_id': slotId, 'error': e.toString()},
      );
      throw _classifyPricingOverrideError(e);
    } catch (e) {
      AppLogger.warn(
        'pricing_override.list_failed',
        fields: {'slot_id': slotId, 'error': e.toString()},
      );
      throw OverrideSaveFailedException();
    }
  }

  @override
  Future<String> createPricingOverride({
    required String slotId,
    required String name,
    int? dayOfWeek,
    required String timeWindowStart,
    required String timeWindowEnd,
    required AdjustmentKind kind,
    required double value,
    DateTime? validFrom,
    DateTime? validUntil,
  }) async {
    try {
      final result = await _supabase.rpc(
        'create_pricing_override',
        params: {
          'p_slot_id': slotId,
          'p_name': name,
          'p_day_of_week': dayOfWeek,
          'p_time_window_start': timeWindowStart,
          'p_time_window_end': timeWindowEnd,
          'p_adjustment_kind': kind.sqlValue,
          'p_adjustment_value': value,
          'p_valid_from': validFrom?.toIso8601String(),
          'p_valid_until': validUntil?.toIso8601String(),
        },
      );
      return result as String;
    } on PostgrestException catch (e) {
      AppLogger.warn(
        'pricing_override.create_failed',
        fields: {'slot_id': slotId, 'error': e.toString()},
      );
      throw _classifyPricingOverrideError(e);
    } catch (e) {
      AppLogger.warn(
        'pricing_override.create_failed',
        fields: {'slot_id': slotId, 'error': e.toString()},
      );
      throw OverrideSaveFailedException();
    }
  }

  @override
  Future<void> updatePricingOverride({
    required String overrideId,
    String? name,
    int? dayOfWeek,
    String? timeWindowStart,
    String? timeWindowEnd,
    AdjustmentKind? kind,
    double? value,
    DateTime? validFrom,
    DateTime? validUntil,
    bool? isActive,
  }) async {
    try {
      await _supabase.rpc(
        'update_pricing_override',
        params: {
          'p_override_id': overrideId,
          'p_name': name,
          'p_day_of_week': dayOfWeek,
          'p_time_window_start': timeWindowStart,
          'p_time_window_end': timeWindowEnd,
          'p_adjustment_kind': kind?.sqlValue,
          'p_adjustment_value': value,
          'p_valid_from': validFrom?.toIso8601String(),
          'p_valid_until': validUntil?.toIso8601String(),
          'p_is_active': isActive,
        },
      );
    } on PostgrestException catch (e) {
      AppLogger.warn(
        'pricing_override.update_failed',
        fields: {'override_id': overrideId, 'error': e.toString()},
      );
      throw _classifyPricingOverrideError(e);
    } catch (e) {
      AppLogger.warn(
        'pricing_override.update_failed',
        fields: {'override_id': overrideId, 'error': e.toString()},
      );
      throw OverrideSaveFailedException();
    }
  }

  @override
  Future<void> archivePricingOverride({required String overrideId}) async {
    try {
      await _supabase.rpc(
        'archive_pricing_override',
        params: {'p_override_id': overrideId},
      );
    } on PostgrestException catch (e) {
      AppLogger.warn(
        'pricing_override.archive_failed',
        fields: {'override_id': overrideId, 'error': e.toString()},
      );
      throw _classifyPricingOverrideError(e);
    } catch (e) {
      AppLogger.warn(
        'pricing_override.archive_failed',
        fields: {'override_id': overrideId, 'error': e.toString()},
      );
      throw OverrideSaveFailedException();
    }
  }

  /// Maps PostgrestException raised by the three pricing_override RPCs
  /// to the typed exception subtype the screen switches on. NO
  /// string-matching on `e.message` — branching is exclusively on
  /// `e.code` + `e.hint`. Phase 15 RESEARCH §9.
  PricingOverrideException _classifyPricingOverrideError(
      PostgrestException e) {
    if (e.code == '42501') return OverrideAccessDeniedException();
    final hint = e.hint ?? '';
    if (e.code == '22023') {
      switch (hint) {
        case 'WINDOW_NOT_ORDERED':
          return OverrideWindowInvalidException();
        case 'DAY_OF_WEEK_OUT_OF_RANGE':
          return OverrideDayOfWeekInvalidException();
        case 'ADJUSTMENT_KIND_INVALID':
        case 'ADJUSTMENT_VALUE_INVALID':
        case 'PERCENT_OUT_OF_RANGE':
          return OverrideAdjustmentInvalidException();
        case 'VALIDITY_NOT_ORDERED':
          return OverrideValidityInvalidException();
        case 'OVERRIDE_CAP_EXCEEDED':
          return OverrideCapExceededException();
        default:
          return OverrideSaveFailedException();
      }
    }
    return OverrideSaveFailedException();
  }

  // ── Phase 16 — Daily close-out report ────────────────────────
  //
  // Three methods + one HINT-driven classifier. Mirrors Phase 15's
  // shape exactly. RLS owner-only SELECT covers getDailyReport; the
  // RPC owner check covers the other two.

  String _dateOnlyIso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Future<DailyReportDTO?> getDailyReport({
    required String shopId,
    required DateTime reportDate,
  }) async {
    try {
      final row = await _supabase
          .from('daily_reports')
          .select('shop_id, report_date, payload, generated_at')
          .eq('shop_id', shopId)
          .eq('report_date', _dateOnlyIso(reportDate))
          .maybeSingle();
      if (row == null) return null;
      return DailyReportDTO.fromJson(
        shopId: row['shop_id'] as String,
        reportDate: DateTime.parse(row['report_date'] as String),
        payload: row['payload'] as Map<String, dynamic>,
        generatedAt: DateTime.parse(row['generated_at'] as String),
      );
    } on PostgrestException catch (e) {
      AppLogger.warn(
        'daily_report.get_failed',
        fields: {'shop_id': shopId, 'error': e.toString()},
      );
      throw _classifyReportError(e);
    } catch (e) {
      AppLogger.warn(
        'daily_report.get_failed',
        fields: {'shop_id': shopId, 'error': e.toString()},
      );
      throw ReportGenerationFailedException();
    }
  }

  @override
  Future<List<DailyReportSummaryDTO>> listDailyReports({
    required String shopId,
    DateTime? beforeDate,
    int pageSize = 30,
  }) async {
    try {
      final result = await _supabase.rpc('list_daily_reports', params: {
        'p_shop_id': shopId,
        'p_before_date':
            beforeDate == null ? null : _dateOnlyIso(beforeDate),
        'p_page_size': pageSize,
      });
      final rows = List<Map<String, dynamic>>.from(result as List);
      return rows.map(DailyReportSummaryDTO.fromRow).toList(growable: false);
    } on PostgrestException catch (e) {
      AppLogger.warn(
        'daily_report.list_failed',
        fields: {'shop_id': shopId, 'error': e.toString()},
      );
      throw _classifyReportError(e);
    } catch (e) {
      AppLogger.warn(
        'daily_report.list_failed',
        fields: {'shop_id': shopId, 'error': e.toString()},
      );
      throw ReportGenerationFailedException();
    }
  }

  @override
  Future<String> regenerateDailyReport({
    required String shopId,
    required DateTime reportDate,
  }) async {
    try {
      final result = await _supabase.rpc('generate_daily_report', params: {
        'p_shop_id': shopId,
        'p_report_date': _dateOnlyIso(reportDate),
      });
      return result as String;
    } on PostgrestException catch (e) {
      AppLogger.warn(
        'daily_report.regenerate_failed',
        fields: {'shop_id': shopId, 'error': e.toString()},
      );
      throw _classifyReportError(e);
    } catch (e) {
      AppLogger.warn(
        'daily_report.regenerate_failed',
        fields: {'shop_id': shopId, 'error': e.toString()},
      );
      throw ReportGenerationFailedException();
    }
  }

  /// HINT-driven classifier. Never string-matches on `e.message`. Mirrors
  /// the Phase 15 _classifyPricingOverrideError pattern.
  DailyReportException _classifyReportError(PostgrestException e) {
    switch (e.hint) {
      case 'OWNER_NOT_FOUND':
      case 'SHOP_NOT_FOUND':
        return ReportAccessDeniedException();
      case 'REPORT_DATE_INVALID':
        return ReportDateInvalidException();
      // F-P2-11: distinct HINT for null shopId; map to a clearer error.
      case 'REQUIRED_FIELD_MISSING':
        return ReportGenerationFailedException();
      case 'REPORT_RPC_FAILED':
        return ReportGenerationFailedException();
    }
    if (e.code == '42501') return ReportAccessDeniedException();
    return ReportGenerationFailedException();
  }
}
