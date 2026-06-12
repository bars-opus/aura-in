// lib/presentation/features/shops/dashboard/providers/daily_report_provider.dart
//
// Phase 16 — Riverpod providers for the daily-report surface.
//
// Two providers:
//   1. dailyReportProvider — keyed by (shopId, reportDate). Returns null
//      when no report exists for that date (the owner sees the empty
//      state with a Re-generate CTA).
//   2. dailyReportHistoryProvider — paginated history list, keyed by
//      shopId. First-page fetch only; the screen owns its own cursor
//      state for incremental load-more.
//
// DailyReportKey strips the time component from the DateTime so two
// instances representing the same calendar day are equal. Required for
// Riverpod family-key correctness.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/daily_report_dto.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';

@immutable
class DailyReportKey {
  const DailyReportKey({required this.shopId, required this.reportDate});

  final String shopId;
  final DateTime reportDate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyReportKey &&
          shopId == other.shopId &&
          reportDate.year == other.reportDate.year &&
          reportDate.month == other.reportDate.month &&
          reportDate.day == other.reportDate.day);

  @override
  int get hashCode =>
      Object.hash(shopId, reportDate.year, reportDate.month, reportDate.day);
}

final dailyReportProvider = FutureProvider.family
    .autoDispose<DailyReportDTO?, DailyReportKey>((ref, key) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getDailyReport(shopId: key.shopId, reportDate: key.reportDate);
});

final dailyReportHistoryProvider = FutureProvider.family
    .autoDispose<List<DailyReportSummaryDTO>, String>((ref, shopId) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.listDailyReports(shopId: shopId);
});
