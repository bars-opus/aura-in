// lib/presentation/features/shops/dashboard/data/models/daily_report_dto.dart
//
// Phase 16 — Daily-close-out snapshot model. JSONB shape mirrors
// generate_daily_report RPC verbatim (LD-4 schema_version 1):
//
// {
//   "revenue_minor": 125000,
//   "currency": "GHS",
//   "bookings": {completed, no_show, cancelled, confirmed_past_end},
//   "comparison": {yesterday, same_day_last_week},   // either may be null (LD-14)
//   "per_worker": [{worker_id, name, revenue_minor, count}],
//   "per_service": [{slot_id, name, revenue_minor, count}],
//   "tomorrow": {first_booking_at, count, has_group_bookings},
//   "follow_ups": [{booking_id, reason, client_name_redacted, amount_minor?}],
//   "generated_at": "...",
//   "schema_version": 1
// }
//
// All money fields are bigint kobo (LD-3). Display-side formatting
// is the responsibility of the screen layer.

enum FollowUpReason {
  confirmedPastEnd('confirmed_past_end'),
  unpaidBalance('unpaid_balance'),
  noShowNoAction('no_show_no_action');

  const FollowUpReason(this.dbValue);
  final String dbValue;

  static FollowUpReason fromDb(String v) =>
      values.firstWhere(
        (r) => r.dbValue == v,
        orElse: () => throw ArgumentError('Unknown FollowUpReason: $v'),
      );
}

class FollowUpEntry {
  final String bookingId;
  final FollowUpReason reason;
  final String clientNameRedacted;
  final int? amountMinor;

  const FollowUpEntry({
    required this.bookingId,
    required this.reason,
    required this.clientNameRedacted,
    this.amountMinor,
  });

  factory FollowUpEntry.fromJson(Map<String, dynamic> j) => FollowUpEntry(
        bookingId: j['booking_id'] as String,
        reason: FollowUpReason.fromDb(j['reason'] as String),
        clientNameRedacted: j['client_name_redacted'] as String? ?? 'A***',
        amountMinor: (j['amount_minor'] as num?)?.toInt(),
      );
}

class WorkerBreakdown {
  final String workerId;
  final String name;
  final int revenueMinor;
  final int count;

  const WorkerBreakdown({
    required this.workerId,
    required this.name,
    required this.revenueMinor,
    required this.count,
  });

  factory WorkerBreakdown.fromJson(Map<String, dynamic> j) => WorkerBreakdown(
        workerId: j['worker_id'] as String,
        name: j['name'] as String,
        revenueMinor: (j['revenue_minor'] as num).toInt(),
        count: (j['count'] as num).toInt(),
      );
}

class ServiceBreakdown {
  final String slotId;
  final String name;
  final int revenueMinor;
  final int count;

  const ServiceBreakdown({
    required this.slotId,
    required this.name,
    required this.revenueMinor,
    required this.count,
  });

  factory ServiceBreakdown.fromJson(Map<String, dynamic> j) => ServiceBreakdown(
        slotId: j['slot_id'] as String,
        name: j['name'] as String,
        revenueMinor: (j['revenue_minor'] as num).toInt(),
        count: (j['count'] as num).toInt(),
      );
}

class ComparisonRow {
  final int revenueMinor;
  final int deltaBps;

  const ComparisonRow({
    required this.revenueMinor,
    required this.deltaBps,
  });

  factory ComparisonRow.fromJson(Map<String, dynamic> j) => ComparisonRow(
        revenueMinor: (j['revenue_minor'] as num).toInt(),
        deltaBps: (j['delta_bps'] as num).toInt(),
      );
}

class TomorrowPeek {
  final DateTime? firstBookingAt;
  final int count;
  final bool hasGroupBookings;

  const TomorrowPeek({
    required this.firstBookingAt,
    required this.count,
    required this.hasGroupBookings,
  });

  factory TomorrowPeek.fromJson(Map<String, dynamic> j) => TomorrowPeek(
        firstBookingAt: j['first_booking_at'] == null
            ? null
            : DateTime.parse(j['first_booking_at'] as String),
        count: (j['count'] as num?)?.toInt() ?? 0,
        hasGroupBookings: j['has_group_bookings'] as bool? ?? false,
      );
}

class BookingCounts {
  final int completed;
  final int noShow;
  final int cancelled;
  final int confirmedPastEnd;

  const BookingCounts({
    required this.completed,
    required this.noShow,
    required this.cancelled,
    required this.confirmedPastEnd,
  });

  factory BookingCounts.fromJson(Map<String, dynamic> j) => BookingCounts(
        completed: (j['completed'] as num?)?.toInt() ?? 0,
        noShow: (j['no_show'] as num?)?.toInt() ?? 0,
        cancelled: (j['cancelled'] as num?)?.toInt() ?? 0,
        confirmedPastEnd: (j['confirmed_past_end'] as num?)?.toInt() ?? 0,
      );

  int get total => completed + noShow + cancelled + confirmedPastEnd;
}

class DailyReportDTO {
  final String shopId;
  final DateTime reportDate;
  final int revenueMinor;
  final String currency;
  final BookingCounts bookings;
  final ComparisonRow? comparisonYesterday;
  final ComparisonRow? comparisonSameDayLastWeek;
  final List<WorkerBreakdown> perWorker;
  final List<ServiceBreakdown> perService;
  final TomorrowPeek tomorrow;
  final List<FollowUpEntry> followUps;
  final DateTime generatedAt;
  final int schemaVersion;

  const DailyReportDTO({
    required this.shopId,
    required this.reportDate,
    required this.revenueMinor,
    required this.currency,
    required this.bookings,
    required this.comparisonYesterday,
    required this.comparisonSameDayLastWeek,
    required this.perWorker,
    required this.perService,
    required this.tomorrow,
    required this.followUps,
    required this.generatedAt,
    required this.schemaVersion,
  });

  /// Reads the JSONB payload as-emitted by generate_daily_report.
  /// `comparison.yesterday` / `comparison.same_day_last_week` may be
  /// null per LD-14 (comparison date had zero bookings).
  factory DailyReportDTO.fromJson({
    required String shopId,
    required DateTime reportDate,
    required Map<String, dynamic> payload,
    DateTime? generatedAt,
  }) {
    final comparison = payload['comparison'] as Map<String, dynamic>? ?? const {};
    final yJson = comparison['yesterday'] as Map<String, dynamic>?;
    final wJson = comparison['same_day_last_week'] as Map<String, dynamic>?;

    final perWorker = ((payload['per_worker'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .map(WorkerBreakdown.fromJson)
        .toList(growable: false);

    final perService = ((payload['per_service'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .map(ServiceBreakdown.fromJson)
        .toList(growable: false);

    final followUps = ((payload['follow_ups'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .map(FollowUpEntry.fromJson)
        .toList(growable: false);

    return DailyReportDTO(
      shopId: shopId,
      reportDate: reportDate,
      revenueMinor: (payload['revenue_minor'] as num).toInt(),
      currency: payload['currency'] as String,
      bookings: BookingCounts.fromJson(
        (payload['bookings'] as Map<String, dynamic>?) ?? const {},
      ),
      comparisonYesterday:
          yJson == null ? null : ComparisonRow.fromJson(yJson),
      comparisonSameDayLastWeek:
          wJson == null ? null : ComparisonRow.fromJson(wJson),
      perWorker: perWorker,
      perService: perService,
      tomorrow: TomorrowPeek.fromJson(
        (payload['tomorrow'] as Map<String, dynamic>?) ?? const {},
      ),
      followUps: followUps,
      generatedAt: generatedAt ??
          DateTime.parse(payload['generated_at'] as String),
      schemaVersion: (payload['schema_version'] as num?)?.toInt() ?? 1,
    );
  }

  /// Major-unit display helper. kobo / 100 with 2dp. Owner-screen only.
  String formattedRevenue() {
    final major = revenueMinor / 100.0;
    return '$currency ${major.toStringAsFixed(2)}';
  }
}

/// Lighter row for the history list — avoids parsing the full payload.
class DailyReportSummaryDTO {
  final String shopId;
  final DateTime reportDate;
  final int revenueMinor;
  final String currency;
  final DateTime generatedAt;

  const DailyReportSummaryDTO({
    required this.shopId,
    required this.reportDate,
    required this.revenueMinor,
    required this.currency,
    required this.generatedAt,
  });

  factory DailyReportSummaryDTO.fromRow(Map<String, dynamic> row) =>
      DailyReportSummaryDTO(
        shopId: row['shop_id'] as String,
        reportDate: DateTime.parse(row['report_date'] as String),
        revenueMinor: (row['revenue_minor'] as num).toInt(),
        currency: row['currency'] as String,
        generatedAt: DateTime.parse(row['generated_at'] as String),
      );

  String formattedRevenue() {
    final major = revenueMinor / 100.0;
    return '$currency ${major.toStringAsFixed(2)}';
  }
}
