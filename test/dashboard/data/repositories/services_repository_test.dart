// test/dashboard/data/repositories/services_repository_test.dart
//
// Repository contract tests for the Phase 11 surface:
//   * rebuild_shop_opening_hours error mapping
//   * archive_appointment_slot error mapping
//   * JSONB shape contract (snake_case keys, not camelCase)
//
// The list-services Postgrest chain (.from().select().eq().isFilter().order().limit())
// is left for end-to-end smoke testing — mocking the full chain
// requires three layers of generic mocks that drift on every SDK rev,
// and the chain composition is plain enough to inspect manually.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/opening_hours_draft.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/business_hours_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/service_management_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('rebuildShopOpeningHours error mapping', () {
    test('42501 -> HoursNotFoundException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'not_found',
        code: '42501',
      ));

      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.rebuildShopOpeningHours(shopId: 'shop-a', hours: const []),
        throwsA(isA<HoursNotFoundException>()),
      );
    });

    test(
        '22023 with hint DAY_OF_WEEK_OUT_OF_RANGE -> DayOfWeekOutOfRangeException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'invalid_input',
        code: '22023',
        hint: 'DAY_OF_WEEK_OUT_OF_RANGE',
      ));

      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.rebuildShopOpeningHours(shopId: 'shop-a', hours: const []),
        throwsA(isA<DayOfWeekOutOfRangeException>()),
      );
    });

    test(
        '22023 with hint EXACTLY_7_DAYS_REQUIRED -> InvalidHoursPayloadException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'invalid_input',
        code: '22023',
        hint: 'EXACTLY_7_DAYS_REQUIRED',
      ));

      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.rebuildShopOpeningHours(shopId: 'shop-a', hours: const []),
        throwsA(isA<InvalidHoursPayloadException>()),
      );
    });

    test('unknown code -> HoursSaveFailedException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'boom', code: '99999'));

      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.rebuildShopOpeningHours(shopId: 'shop-a', hours: const []),
        throwsA(isA<HoursSaveFailedException>()),
      );
    });

    test('passes JSONB params with snake_case keys', () async {
      // We capture by failing on the first call (PostgrestException) so
      // the repo throws — that's fine, the verify() afterwards inspects
      // the params dict that was passed to the rpc() stub. This avoids
      // having to construct a real PostgrestFilterBuilder for the
      // success branch (which requires three layers of generic mocks).
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'expected', code: '99999'));

      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      try {
        await repo.rebuildShopOpeningHours(shopId: 'shop-a', hours: const [
          OpeningHoursDraft(
            dayOfWeek: 1,
            opensAt: '09:00 AM',
            closesAt: '05:00 PM',
            isClosed: false,
          ),
        ]);
      } on HoursSaveFailedException {
        // expected
      }

      final captured = verify(() => supabase.rpc(
            'rebuild_shop_opening_hours',
            params: captureAny(named: 'params'),
          )).captured;
      final params = captured.single as Map<String, dynamic>;
      expect(params['p_shop_id'], 'shop-a');
      final pHours = params['p_hours'] as List;
      expect(pHours.length, 1);
      final first = pHours.first as Map<String, dynamic>;
      // Keys are snake_case (matches the SQL JSONB expansion in the
      // RPC). NOT 'dayOfWeek' / 'opensAt' — that would break the
      // function body's `(elem->>'opens_at')` references.
      expect(first.containsKey('day_of_week'), isTrue);
      expect(first.containsKey('opens_at'), isTrue);
      expect(first.containsKey('closes_at'), isTrue);
      expect(first.containsKey('is_closed'), isTrue);
    });
  });

  group('archiveAppointmentSlot error mapping', () {
    test('42501 -> ServiceNotFoundException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'not_found',
        code: '42501',
      ));

      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.archiveAppointmentSlot('slot-a'),
        throwsA(isA<ServiceNotFoundException>()),
      );
    });

    test('22023 -> InvalidServicePayloadException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'invalid_input',
        code: '22023',
        hint: 'NULL_NOT_ALLOWED',
      ));

      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.archiveAppointmentSlot('slot-a'),
        throwsA(isA<InvalidServicePayloadException>()),
      );
    });

    test('unknown code -> ServiceArchiveFailedException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'boom', code: '99999'));

      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.archiveAppointmentSlot('slot-a'),
        throwsA(isA<ServiceArchiveFailedException>()),
      );
    });
  });
}
