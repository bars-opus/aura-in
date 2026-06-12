// test/dashboard/data/repositories/pricing_overrides_repository_test.dart
//
// Phase 15 Wave 6.2 — verifies the HINT-driven classifier in
// SupabaseDashboardRepository for the three pricing_override RPCs.
//
// We mock `_supabase.rpc(...)` (mocktail can cover it cleanly) and feed
// it synthetic PostgrestException shapes — every (code, hint) pair
// the server uses must translate to the right typed Dart subtype.
//
// The .from().select()... builder chain on getPricingOverrides can't
// be cleanly mocked with mocktail because each builder layer narrows
// its generic parameter (same caveat as promotions_repository_test).
// SQL smoke (Wave 6.5 §F + §I) covers list end-to-end.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/pricing_override_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/pricing_override_dto.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('createPricingOverride - HINT classifier', () {
    test('42501 → OverrideAccessDeniedException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'denied', code: '42501'));
      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.createPricingOverride(
          slotId: 's1',
          name: 'rule',
          timeWindowStart: '09:00:00',
          timeWindowEnd: '12:00:00',
          kind: AdjustmentKind.percentDiscount,
          value: 20,
        ),
        throwsA(isA<OverrideAccessDeniedException>()),
      );
    });

    test('22023 + WINDOW_NOT_ORDERED → OverrideWindowInvalidException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'bad window',
        code: '22023',
        hint: 'WINDOW_NOT_ORDERED',
      ));
      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.createPricingOverride(
          slotId: 's1',
          name: 'rule',
          timeWindowStart: '12:00:00',
          timeWindowEnd: '09:00:00',
          kind: AdjustmentKind.percentDiscount,
          value: 20,
        ),
        throwsA(isA<OverrideWindowInvalidException>()),
      );
    });

    test('22023 + DAY_OF_WEEK_OUT_OF_RANGE → OverrideDayOfWeekInvalidException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'bad day',
        code: '22023',
        hint: 'DAY_OF_WEEK_OUT_OF_RANGE',
      ));
      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.createPricingOverride(
          slotId: 's1',
          name: 'rule',
          dayOfWeek: 9,
          timeWindowStart: '09:00:00',
          timeWindowEnd: '12:00:00',
          kind: AdjustmentKind.percentDiscount,
          value: 20,
        ),
        throwsA(isA<OverrideDayOfWeekInvalidException>()),
      );
    });

    test('22023 + ADJUSTMENT_KIND_INVALID → OverrideAdjustmentInvalidException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'bad kind',
        code: '22023',
        hint: 'ADJUSTMENT_KIND_INVALID',
      ));
      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.createPricingOverride(
          slotId: 's1',
          name: 'rule',
          timeWindowStart: '09:00:00',
          timeWindowEnd: '12:00:00',
          kind: AdjustmentKind.percentDiscount,
          value: 20,
        ),
        throwsA(isA<OverrideAdjustmentInvalidException>()),
      );
    });

    test('22023 + PERCENT_OUT_OF_RANGE → OverrideAdjustmentInvalidException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'bad percent',
        code: '22023',
        hint: 'PERCENT_OUT_OF_RANGE',
      ));
      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.createPricingOverride(
          slotId: 's1',
          name: 'rule',
          timeWindowStart: '09:00:00',
          timeWindowEnd: '12:00:00',
          kind: AdjustmentKind.percentDiscount,
          value: 150,
        ),
        throwsA(isA<OverrideAdjustmentInvalidException>()),
      );
    });

    test('22023 + VALIDITY_NOT_ORDERED → OverrideValidityInvalidException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'bad validity',
        code: '22023',
        hint: 'VALIDITY_NOT_ORDERED',
      ));
      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.createPricingOverride(
          slotId: 's1',
          name: 'rule',
          timeWindowStart: '09:00:00',
          timeWindowEnd: '12:00:00',
          kind: AdjustmentKind.percentDiscount,
          value: 20,
          validFrom: DateTime(2026, 6, 1),
          validUntil: DateTime(2026, 5, 1),
        ),
        throwsA(isA<OverrideValidityInvalidException>()),
      );
    });

    test('22023 + OVERRIDE_CAP_EXCEEDED → OverrideCapExceededException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'cap',
        code: '22023',
        hint: 'OVERRIDE_CAP_EXCEEDED',
      ));
      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.createPricingOverride(
          slotId: 's1',
          name: 'rule',
          timeWindowStart: '09:00:00',
          timeWindowEnd: '12:00:00',
          kind: AdjustmentKind.percentDiscount,
          value: 20,
        ),
        throwsA(isA<OverrideCapExceededException>()),
      );
    });

    test('22023 + unknown hint → OverrideSaveFailedException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'mystery',
        code: '22023',
        hint: 'WHO_KNOWS',
      ));
      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.createPricingOverride(
          slotId: 's1',
          name: 'rule',
          timeWindowStart: '09:00:00',
          timeWindowEnd: '12:00:00',
          kind: AdjustmentKind.percentDiscount,
          value: 20,
        ),
        throwsA(isA<OverrideSaveFailedException>()),
      );
    });

    test('unknown sql state → OverrideSaveFailedException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'boom', code: '99999'));
      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.createPricingOverride(
          slotId: 's1',
          name: 'rule',
          timeWindowStart: '09:00:00',
          timeWindowEnd: '12:00:00',
          kind: AdjustmentKind.percentDiscount,
          value: 20,
        ),
        throwsA(isA<OverrideSaveFailedException>()),
      );
    });
  });

  group('updatePricingOverride - classifier shares createPricingOverride path',
      () {
    test('42501 → OverrideAccessDeniedException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'denied', code: '42501'));
      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.updatePricingOverride(overrideId: 'o1', name: 'edit'),
        throwsA(isA<OverrideAccessDeniedException>()),
      );
    });

    test('22023 + WINDOW_NOT_ORDERED → OverrideWindowInvalidException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'bad window',
        code: '22023',
        hint: 'WINDOW_NOT_ORDERED',
      ));
      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.updatePricingOverride(
          overrideId: 'o1',
          timeWindowStart: '12:00:00',
          timeWindowEnd: '09:00:00',
        ),
        throwsA(isA<OverrideWindowInvalidException>()),
      );
    });
  });

  group('archivePricingOverride - classifier coverage', () {
    test('42501 → OverrideAccessDeniedException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'denied', code: '42501'));
      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.archivePricingOverride(overrideId: 'o1'),
        throwsA(isA<OverrideAccessDeniedException>()),
      );
    });

    test('unknown error → OverrideSaveFailedException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'boom', code: '99999'));
      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.archivePricingOverride(overrideId: 'o1'),
        throwsA(isA<OverrideSaveFailedException>()),
      );
    });
  });
}
