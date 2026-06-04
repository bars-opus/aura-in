// test/dashboard/data/repositories/promotions_repository_test.dart
//
// PromotionsRepository.incrementUsage contract tests.
//
// We focus on the RPC-level error mapping (the high-value contract):
// every distinct PostgrestException shape that comes back from the
// redeem_promotion RPC must translate to the right typed
// PromotionException so the UI can branch on a stable `code` without
// parsing English error strings.
//
// The full Postgrest builder chain for createPromotion (.from().insert()
// .select().single()) can't be cleanly mocked with mocktail because each
// builder layer narrows its generic parameter, and two of those layers
// have incompatible `PostgrestBuilder<T1,T2,T3>` type parameters that a
// single mock class can't satisfy at once. The 23505 -> DuplicateCode
// mapping is still exercised in the production code path; we lean on
// the SQL smoke tests for that contract end-to-end.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/promotion_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/promotions_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('incrementUsage - Postgrest error mapping (redeem_promotion RPC)', () {
    test('PROMO_LIMIT_REACHED hint -> PromotionLimitReachedException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'limit_reached',
        code: 'P0001',
        hint: 'PROMO_LIMIT_REACHED',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.incrementUsage('p1', 'b1', 'u1', 5),
        throwsA(isA<PromotionLimitReachedException>()),
      );
    });

    test('AMOUNT_MUST_BE_POSITIVE hint -> InvalidDiscountAmountException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'invalid_amount',
        code: '22023',
        hint: 'AMOUNT_MUST_BE_POSITIVE',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.incrementUsage('p1', 'b1', 'u1', 0),
        throwsA(isA<InvalidDiscountAmountException>()),
      );
    });

    test('NULL_NOT_ALLOWED hint -> InvalidDiscountAmountException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'invalid_input',
        code: '22023',
        hint: 'NULL_NOT_ALLOWED',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.incrementUsage('p1', 'b1', 'u1', 5),
        throwsA(isA<InvalidDiscountAmountException>()),
      );
    });

    test('42501 -> PromotionNotFoundException (authz never reveals existence)',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'not_found',
        code: '42501',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.incrementUsage('p1', 'b1', 'u1', 5),
        throwsA(isA<PromotionNotFoundException>()),
      );
    });

    test('P0002 (NO_DATA_FOUND) -> PromotionNotFoundException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'not_found',
        code: 'P0002',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.incrementUsage('p1', 'b1', 'u1', 5),
        throwsA(isA<PromotionNotFoundException>()),
      );
    });

    test('unknown code -> generic PromotionException with PROMO_REDEEM_FAILED',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'boom', code: '99999'));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.incrementUsage('p1', 'b1', 'u1', 5),
        throwsA(
          isA<PromotionException>()
              .having((e) => e.code, 'code', 'PROMO_REDEEM_FAILED'),
        ),
      );
    });
  });
}
