// lib/features/dashboard/data/repositories/export_repository.dart
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/export_report.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExportRepository {
  final SupabaseClient _supabase;

  ExportRepository({required SupabaseClient supabaseClient})
    : _supabase = supabaseClient;

  Future<ExportResult> exportBookings({
    required String shopId,
    DateTime? fromDate,
    DateTime? toDate,
    ExportFormat format = ExportFormat.csv,
  }) async {
    try {
      var query = _supabase
          .from('booking_with_client_info')
          .select('''
            id,
            start_time,
            end_time,
            status,
            total_amount,
            deposit_amount,
            display_name,
            username,
            service_name,
            worker_name
          ''')
          .eq('shop_id', shopId);

      if (fromDate != null) {
        query = query.gte('start_time', fromDate.toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('start_time', toDate.toIso8601String());
      }

      final response = await query.order('start_time', ascending: false);
      final bookings = List<Map<String, dynamic>>.from(response);

      final headers = [
        'Booking ID',
        'Date',
        'Time',
        'Client',
        'Service',
        'Worker',
        'Status',
        'Total Amount',
        'Deposit Paid',
      ];

      final data =
          bookings.map((b) {
            final startTime = DateTime.parse(b['start_time']);
            return [
              b['id'],
              _formatDate(startTime),
              _formatTime(startTime),
              b['display_name'] ?? b['username'] ?? 'Guest',
              b['service_name'] ?? 'N/A',
              b['worker_name'] ?? 'Unassigned',
              b['status'],
              b['total_amount'],
              b['deposit_amount'],
            ];
          }).toList();

      return ExportResult(
        config: ExportConfig(
          reportType: ReportType.bookings,
          format: format,
          startDate: fromDate,
          endDate: toDate,
        ),
        filePath: '',
        recordCount: data.length,
        exportedAt: DateTime.now(),
        data: data,
        headers: headers,
      );
    } catch (e) {
      throw Exception('Failed to export bookings: $e');
    }
  }

  Future<ExportResult> exportRevenue({
    required String shopId,
    DateTime? fromDate,
    DateTime? toDate,
    ExportFormat format = ExportFormat.csv,
  }) async {
    try {
      var query = _supabase
          .from('bookings')
          .select('created_at, total_amount, deposit_amount, status')
          .eq('shop_id', shopId)
          .eq('status', 'completed');

      if (fromDate != null) {
        query = query.gte('created_at', fromDate.toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('created_at', toDate.toIso8601String());
      }

      final response = await query.order('created_at', ascending: false);
      final bookings = List<Map<String, dynamic>>.from(response);

      final headers = [
        'Date',
        'Total Revenue',
        'Deposits Collected',
        'Platform Fee',
      ];

      // Group by month
      final Map<String, Map<String, double>> monthlyData = {};
      for (final booking in bookings) {
        final date = DateTime.parse(booking['created_at']);
        final monthKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}';
        monthlyData.putIfAbsent(monthKey, () => {'revenue': 0, 'deposits': 0});
        monthlyData[monthKey]!['revenue'] =
            (monthlyData[monthKey]!['revenue'] ?? 0) +
            (booking['total_amount'] ?? 0).toDouble();
        monthlyData[monthKey]!['deposits'] =
            (monthlyData[monthKey]!['deposits'] ?? 0) +
            (booking['deposit_amount'] ?? 0).toDouble();
      }

      final data =
          monthlyData.entries.map((entry) {
            return [
              entry.key,
              entry.value['revenue'],
              entry.value['deposits'],
              entry.value['revenue']! * 0.029, // 2.9% platform fee
            ];
          }).toList();

      return ExportResult(
        config: ExportConfig(
          reportType: ReportType.revenue,
          format: format,
          startDate: fromDate,
          endDate: toDate,
        ),
        filePath: '',
        recordCount: data.length,
        exportedAt: DateTime.now(),
        data: data,
        headers: headers,
      );
    } catch (e) {
      throw Exception('Failed to export revenue: $e');
    }
  }

  Future<ExportResult> exportClients({
    required String shopId,
    ExportFormat format = ExportFormat.csv,
  }) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('user_id, total_amount, status')
          .eq('shop_id', shopId);

      final bookings = List<Map<String, dynamic>>.from(response);

      // Group by user
      final Map<String, Map<String, dynamic>> clientMap = {};
      for (final booking in bookings) {
        final userId = booking['user_id'];
        if (userId == null) continue;

        if (!clientMap.containsKey(userId)) {
          clientMap[userId] = {
            'user_id': userId,
            'total_bookings': 0,
            'total_spent': 0.0,
          };
        }

        clientMap[userId]!['total_bookings'] =
            clientMap[userId]!['total_bookings'] + 1;
        if (booking['status'] == 'completed') {
          clientMap[userId]!['total_spent'] =
              clientMap[userId]!['total_spent'] +
              (booking['total_amount'] ?? 0).toDouble();
        }
      }

      // Get client details from profiles
      final userIds = clientMap.keys.toList();
      final profiles = <Map<String, dynamic>>[];

      if (userIds.isNotEmpty) {
        // Fetch profiles one by one to avoid the 'in' filter issue
        for (final userId in userIds) {
          final profile =
              await _supabase
                  .from('profiles')
                  .select('id, username, display_name, email, phone')
                  .eq('id', userId)
                  .maybeSingle();

          if (profile != null) {
            profiles.add(profile);
          }
        }
      }

      for (final profile in profiles) {
        final userId = profile['id'];
        if (clientMap.containsKey(userId)) {
          clientMap[userId]!.addAll({
            'username': profile['username'],
            'display_name': profile['display_name'],
            'email': profile['email'],
            'phone': profile['phone'],
          });
        }
      }

      final headers = [
        'Client ID',
        'Name',
        'Email',
        'Phone',
        'Total Bookings',
        'Total Spent',
      ];

      final data =
          clientMap.values.map((client) {
            return [
              client['user_id'],
              client['display_name'] ?? client['username'] ?? 'Guest',
              client['email'] ?? '',
              client['phone'] ?? '',
              client['total_bookings'],
              client['total_spent'],
            ];
          }).toList();

      return ExportResult(
        config: ExportConfig(reportType: ReportType.clients, format: format),
        filePath: '',
        recordCount: data.length,
        exportedAt: DateTime.now(),
        data: data,
        headers: headers,
      );
    } catch (e) {
      throw Exception('Failed to export clients: $e');
    }
  }

  Future<ExportResult> exportWorkers({
    required String shopId,
    ExportFormat format = ExportFormat.csv,
  }) async {
    try {
      final response = await _supabase
          .from('workers')
          .select('''
            id,
            name,
            bio,
            is_active,
            created_at,
            employee_details:hourly_rate
          ''')
          .eq('shop_id', shopId)
          .eq('is_freelancer', false);

      final workers = List<Map<String, dynamic>>.from(response);

      // Get performance metrics
      for (final worker in workers) {
        final bookingsResponse = await _supabase
            .from('booking_services')
            .select('price_at_booking')
            .eq('worker_id', worker['id']);

        final bookings = List<Map<String, dynamic>>.from(bookingsResponse);
        final totalRevenue = bookings.fold<double>(
          0,
          (sum, b) => sum + (b['price_at_booking'] ?? 0).toDouble(),
        );

        worker['total_revenue'] = totalRevenue;
        worker['total_bookings'] = bookings.length;
      }

      final headers = [
        'Worker ID',
        'Name',
        'Bio',
        'Active',
        'Hourly Rate',
        'Total Bookings',
        'Total Revenue',
        'Joined Date',
      ];

      final data =
          workers.map((w) {
            return [
              w['id'],
              w['name'],
              w['bio'] ?? '',
              w['is_active'] ? 'Yes' : 'No',
              w['employee_details']?['hourly_rate'] ?? 'N/A',
              w['total_bookings'],
              w['total_revenue'],
              w['created_at']?.split('T').first ?? '',
            ];
          }).toList();

      return ExportResult(
        config: ExportConfig(reportType: ReportType.workers, format: format),
        filePath: '',
        recordCount: data.length,
        exportedAt: DateTime.now(),
        data: data,
        headers: headers,
      );
    } catch (e) {
      throw Exception('Failed to export workers: $e');
    }
  }

  Future<ExportResult> exportServices({
    required String shopId,
    ExportFormat format = ExportFormat.csv,
  }) async {
    try {
      final response = await _supabase
          .from('appointment_slots')
          .select('''
            id,
            service_name,
            description,
            duration,
            price,
            slot_type
          ''')
          .eq('shop_id', shopId);

      final services = List<Map<String, dynamic>>.from(response);

      // Get booking counts
      for (final service in services) {
        final bookingsResponse = await _supabase
            .from('booking_services')
            .select('price_at_booking')
            .eq('slot_id', service['id']);

        final bookings = List<Map<String, dynamic>>.from(bookingsResponse);
        final totalRevenue = bookings.fold<double>(
          0,
          (sum, b) => sum + (b['price_at_booking'] ?? 0).toDouble(),
        );

        service['total_bookings'] = bookings.length;
        service['total_revenue'] = totalRevenue;
      }

      final headers = [
        'Service ID',
        'Service Name',
        'Description',
        'Duration',
        'Price',
        'Type',
        'Total Bookings',
        'Total Revenue',
      ];

      final data =
          services.map((s) {
            return [
              s['id'],
              s['service_name'],
              s['description'] ?? '',
              s['duration'],
              s['price'],
              s['slot_type'],
              s['total_bookings'],
              s['total_revenue'],
            ];
          }).toList();

      return ExportResult(
        config: ExportConfig(reportType: ReportType.services, format: format),
        filePath: '',
        recordCount: data.length,
        exportedAt: DateTime.now(),
        data: data,
        headers: headers,
      );
    } catch (e) {
      throw Exception('Failed to export services: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }
}
