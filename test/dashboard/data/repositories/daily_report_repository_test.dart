// test/dashboard/data/repositories/daily_report_repository_test.dart
//
// Phase 16 Wave 6.2 — verifies the HINT-driven classifier in
// SupabaseDashboardRepository for the daily-report surface.
//
// Mocks _supabase.rpc(...) and feeds synthetic PostgrestException shapes.
// Every (code, hint) pair the server uses must translate to the right
// typed Dart subtype. Same caveat as the promotions/pricing_overrides
// classifier tests: the .from().select().eq()...maybeSingle() builder
// chain on getDailyReport can't be mocked cleanly with mocktail, so we
// only assert the RPC-side classifier.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/daily_report_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('regenerateDailyReport - HINT classifier', () {
    test('42501 → ReportAccessDeniedException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'denied', code: '42501'));
      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.regenerateDailyReport(
          shopId: 's1',
          reportDate: DateTime(2026, 6, 11),
        ),
        throwsA(isA<ReportAccessDeniedException>()),
      );
    });

    test('HINT OWNER_NOT_FOUND → ReportAccessDeniedException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'not_found',
        code: '42501',
        hint: 'OWNER_NOT_FOUND',
      ));
      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.regenerateDailyReport(
          shopId: 's1',
          reportDate: DateTime(2026, 6, 11),
        ),
        throwsA(isA<ReportAccessDeniedException>()),
      );
    });

    test('HINT REPORT_DATE_INVALID → ReportDateInvalidException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'invalid_input',
        code: '22023',
        hint: 'REPORT_DATE_INVALID',
      ));
      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.regenerateDailyReport(
          shopId: 's1',
          reportDate: DateTime(2030, 1, 1),
        ),
        throwsA(isA<ReportDateInvalidException>()),
      );
    });

    test('HINT REPORT_RPC_FAILED → ReportGenerationFailedException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'report_failed',
        code: 'P0001',
        hint: 'REPORT_RPC_FAILED',
      ));
      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.regenerateDailyReport(
          shopId: 's1',
          reportDate: DateTime(2026, 6, 11),
        ),
        throwsA(isA<ReportGenerationFailedException>()),
      );
    });

    test('HINT SHOP_NOT_FOUND → ReportAccessDeniedException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'not_found',
        code: '42501',
        hint: 'SHOP_NOT_FOUND',
      ));
      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.regenerateDailyReport(
          shopId: 's1',
          reportDate: DateTime(2026, 6, 11),
        ),
        throwsA(isA<ReportAccessDeniedException>()),
      );
    });

    test('unknown sql state → ReportGenerationFailedException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'mystery', code: '99999'));
      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.regenerateDailyReport(
          shopId: 's1',
          reportDate: DateTime(2026, 6, 11),
        ),
        throwsA(isA<ReportGenerationFailedException>()),
      );
    });
  });

  group('listDailyReports - classifier shared with regenerate', () {
    test('42501 → ReportAccessDeniedException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'denied', code: '42501'));
      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.listDailyReports(shopId: 's1'),
        throwsA(isA<ReportAccessDeniedException>()),
      );
    });

    // Note: rpc() returns PostgrestFilterBuilder, not raw Future, so we
    // can't mock a happy-path Future return with mocktail. SQL smoke
    // §M covers the end-to-end happy path with the real DB.
  });
}
