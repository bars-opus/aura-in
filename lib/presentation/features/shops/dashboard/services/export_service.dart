// lib/features/dashboard/services/export_service.dart
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/export_report.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for exporting data to various formats
class ExportService {
  final SupabaseClient _supabase;

  ExportService({required SupabaseClient supabaseClient})
    : _supabase = supabaseClient;

  /// Export data based on configuration
  Future<ExportResult> exportReport(ExportConfig config) async {
    try {
      List<List<dynamic>> data;
      List<String> headers;

      switch (config.reportType) {
        case ReportType.bookings:
          final result = await _exportBookings(config);
          data = result.$1;
          headers = result.$2;
          break;
        case ReportType.revenue:
          final result = await _exportRevenue(config);
          data = result.$1;
          headers = result.$2;
          break;
        case ReportType.clients:
          final result = await _exportClients(config);
          data = result.$1;
          headers = result.$2;
          break;
        case ReportType.workers:
          final result = await _exportWorkers(config);
          data = result.$1;
          headers = result.$2;
          break;
        case ReportType.services:
          final result = await _exportServices(config);
          data = result.$1;
          headers = result.$2;
          break;
      }

      final filePath = await _generateFile(data, headers, config);
      final recordCount = data.length;

      return ExportResult(
        config: config,
        filePath: filePath,
        recordCount: recordCount,
        exportedAt: DateTime.now(),
      );
    } catch (e) {
      return ExportResult(
        config: config,
        filePath: '',
        recordCount: 0,
        exportedAt: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  Future<(List<List<dynamic>>, List<String>)> _exportBookings(
    ExportConfig config,
  ) async {
    var query = _supabase.from('bookings').select('''
          id,
          start_time,
          end_time,
          status,
          total_amount,
          deposit_amount,
          user:user_id(full_name, email, phone),
          shop:shop_id(name),
          booking_services(
            slot:slot_id(name),
            worker:worker_id(name),
            price_at_booking
          )
        ''');

    if (config.startDate != null) {
      query = query.gte('start_time', config.startDate!.toIso8601String());
    }
    if (config.endDate != null) {
      query = query.lte('start_time', config.endDate!.toIso8601String());
    }

    final response = await query;
    final bookings = List<Map<String, dynamic>>.from(response);

    final headers = [
      'Booking ID',
      'Date',
      'Time',
      'Client',
      'Phone',
      'Email',
      'Shop',
      'Service',
      'Worker',
      'Status',
      'Total',
      'Deposit',
    ];

    final data =
        bookings.map((b) {
          final services = List<Map<String, dynamic>>.from(
            b['booking_services'] ?? [],
          );
          final firstService = services.isNotEmpty ? services.first : {};

          return [
            b['id'],
            (b['start_time'] as String).split('T').first,
            _formatTime(DateTime.parse(b['start_time'])),
            b['user']?['full_name'] ?? 'Guest',
            b['user']?['phone'] ?? '',
            b['user']?['email'] ?? '',
            b['shop']?['name'] ?? '',
            firstService['slot']?['name'] ?? '',
            firstService['worker']?['name'] ?? '',
            b['status'],
            b['total_amount'],
            b['deposit_amount'],
          ];
        }).toList();

    return (data, headers);
  }

  Future<(List<List<dynamic>>, List<String>)> _exportRevenue(
    ExportConfig config,
  ) async {
    var query = _supabase
        .from('bookings')
        .select('created_at, total_amount, deposit_amount, status')
        .eq('status', 'completed');

    if (config.startDate != null) {
      query = query.gte('created_at', config.startDate!.toIso8601String());
    }
    if (config.endDate != null) {
      query = query.lte('created_at', config.endDate!.toIso8601String());
    }

    final response = await query;
    final bookings = List<Map<String, dynamic>>.from(response);

    // Group by month
    final monthlyData = <String, Map<String, double>>{};
    for (final b in bookings) {
      final date = DateTime.parse(b['created_at']);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      monthlyData.putIfAbsent(monthKey, () => {'revenue': 0, 'deposits': 0});
      monthlyData[monthKey]!['revenue'] =
          (monthlyData[monthKey]!['revenue'] ?? 0) +
          (b['total_amount'] ?? 0).toDouble();
      monthlyData[monthKey]!['deposits'] =
          (monthlyData[monthKey]!['deposits'] ?? 0) +
          (b['deposit_amount'] ?? 0).toDouble();
    }

    final headers = ['Month', 'Total Revenue', 'Deposits Collected'];
    final data =
        monthlyData.entries.map((entry) {
          return [entry.key, entry.value['revenue'], entry.value['deposits']];
        }).toList();

    return (data, headers);
  }

  Future<(List<List<dynamic>>, List<String>)> _exportClients(
    ExportConfig config,
  ) async {
    var query = _supabase.from('users').select('''
          id,
          full_name,
          email,
          phone,
          created_at,
          bookings:bookings(total_amount, status)
        ''');

    final response = await query;
    final clients = List<Map<String, dynamic>>.from(response);

    final headers = [
      'Client ID',
      'Name',
      'Email',
      'Phone',
      'Joined',
      'Total Spent',
      'Bookings',
    ];

    final data =
        clients.map((c) {
          final bookings = List<Map<String, dynamic>>.from(c['bookings'] ?? []);
          final totalSpent = bookings.fold<double>(
            0,
            (sum, b) => sum + (b['total_amount'] ?? 0).toDouble(),
          );

          return [
            c['id'],
            c['full_name'],
            c['email'],
            c['phone'],
            (c['created_at'] as String?)?.split('T').first ?? '',
            totalSpent,
            bookings.length,
          ];
        }).toList();

    return (data, headers);
  }

  Future<(List<List<dynamic>>, List<String>)> _exportWorkers(
    ExportConfig config,
  ) async {
    final response = await _supabase.from('workers').select('''
          id,
          name,
          bio,
          is_active,
          created_at,
          bookings:booking_services(price_at_booking)
        ''');

    final workers = List<Map<String, dynamic>>.from(response);

    final headers = [
      'Worker ID',
      'Name',
      'Bio',
      'Active',
      'Joined',
      'Total Revenue',
    ];
    final data =
        workers.map((w) {
          final bookings = List<Map<String, dynamic>>.from(w['bookings'] ?? []);
          final totalRevenue = bookings.fold<double>(
            0,
            (sum, b) => sum + (b['price_at_booking'] ?? 0).toDouble(),
          );

          return [
            w['id'],
            w['name'],
            w['bio'],
            w['is_active'] ? 'Yes' : 'No',
            (w['created_at'] as String?)?.split('T').first ?? '',
            totalRevenue,
          ];
        }).toList();

    return (data, headers);
  }

  Future<(List<List<dynamic>>, List<String>)> _exportServices(
    ExportConfig config,
  ) async {
    final response = await _supabase.from('appointment_slots').select('''
          id,
          name,
          description,
          duration,
          price,
          booking_services:booking_services(price_at_booking)
        ''');

    final services = List<Map<String, dynamic>>.from(response);

    final headers = [
      'Service ID',
      'Name',
      'Description',
      'Duration',
      'Price',
      'Bookings',
      'Revenue',
    ];
    final data =
        services.map((s) {
          final bookings = List<Map<String, dynamic>>.from(
            s['booking_services'] ?? [],
          );
          final revenue = bookings.fold<double>(
            0,
            (sum, b) => sum + (b['price_at_booking'] ?? 0).toDouble(),
          );

          return [
            s['id'],
            s['name'],
            s['description'],
            s['duration'],
            s['price'],
            bookings.length,
            revenue,
          ];
        }).toList();

    return (data, headers);
  }

  Future<String> _generateFile(
    List<List<dynamic>> data,
    List<String> headers,
    ExportConfig config,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${config.fileName}';

    switch (config.format) {
      case ExportFormat.csv:
        return _saveAsCsv(data, headers, filePath);
      case ExportFormat.excel:
        return _saveAsExcel(data, headers, filePath);
      case ExportFormat.pdf:
        return _saveAsPdf(data, headers, filePath);
    }
  }

  String _saveAsCsv(
    List<List<dynamic>> data,
    List<String> headers,
    String filePath,
  ) {
    final csv = ListToCsvConverter().convert([headers, ...data]);
    File(filePath).writeAsStringSync(csv);
    return filePath;
  }

  String _saveAsExcel(
    List<List<dynamic>> data,
    List<String> headers,
    String filePath,
  ) {
    final excel = Excel.createExcel();
    final sheet = excel['Report'];

    // Add headers - convert String to CellValue
    for (var i = 0; i < headers.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(headers[i]);
    }

    // Add data
    for (var row = 0; row < data.length; row++) {
      for (var col = 0; col < data[row].length; col++) {
        final value = data[row][col];

        // Convert various types to CellValue
        if (value is String) {
          sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1),
              )
              .value = TextCellValue(value);
        } else if (value is int) {
          sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1),
              )
              .value = IntCellValue(value);
        } else if (value is double) {
          sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1),
              )
              .value = DoubleCellValue(value);
        } else if (value is DateTime) {
          sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1),
              )
              .value = TextCellValue(value.toIso8601String());
        } else if (value == null) {
          sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1),
              )
              .value = TextCellValue('');
        } else {
          sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1),
              )
              .value = TextCellValue(value.toString());
        }
      }
    }

    final bytes = excel.encode();
    if (bytes != null) {
      File(filePath).writeAsBytesSync(bytes);
    }
    return filePath;
  }

  String _saveAsPdf(
    List<List<dynamic>> data,
    List<String> headers,
    String filePath,
  ) {
    // Implement PDF generation (using pdf package)
    // For MVP, fallback to CSV
    return _saveAsCsv(data, headers, filePath.replaceAll('.pdf', '.csv'));
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')}$period';
  }
}
