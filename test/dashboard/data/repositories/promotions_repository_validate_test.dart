// test/dashboard/data/repositories/promotions_repository_validate_test.dart
//
// Phase 13 — contract tests for the new repository surface:
//   * validate_and_apply_promo error mapping (HINT → typed exception)
//   * upsert_loyalty_rule error mapping
//   * RPC parameter shape (snake_case keys, exact-one-of identity)
//
// Mirrors the Phase 12 client_notes_repository_test.dart pattern. The
// list-/get-side reads (get_loyalty_rule, getPromotions) use the
// Postgrest builder chain which is skipped for the same SDK-mock
// fragility reason; UAT exercises those paths.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/promotion_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/promotion_model.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/promotions_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('validateAndApplyPromo error mapping', () {
    test('42501 → PromotionNotFoundException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'code not found',
        code: '42501',
        hint: 'CODE_NOT_FOUND',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.validateAndApplyPromo(
          shopId: 'shop-a',
          code: 'SUMMER10',
          userId: 'user-a',
          bookingTotal: 100,
        ),
        throwsA(isA<PromotionNotFoundException>()),
      );
    });

    test('22023 CODE_EXPIRED → PromoExpiredException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'expired', code: '22023', hint: 'CODE_EXPIRED',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.validateAndApplyPromo(
          shopId: 'shop-a',
          code: 'OLDCODE',
          userId: 'user-a',
          bookingTotal: 100,
        ),
        throwsA(isA<PromoExpiredException>()),
      );
    });

    test('22023 CODE_LIMIT_REACHED → PromotionLimitReachedException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'limit', code: '22023', hint: 'CODE_LIMIT_REACHED',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.validateAndApplyPromo(
          shopId: 'shop-a',
          code: 'POPCODE',
          userId: 'user-a',
          bookingTotal: 100,
        ),
        throwsA(isA<PromotionLimitReachedException>()),
      );
    });

    test('22023 CODE_PER_CLIENT_MAX → PromoPerClientMaxException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'per client', code: '22023', hint: 'CODE_PER_CLIENT_MAX',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.validateAndApplyPromo(
          shopId: 'shop-a',
          code: 'AGAIN',
          userId: 'user-a',
          bookingTotal: 100,
        ),
        throwsA(isA<PromoPerClientMaxException>()),
      );
    });

    test('22023 CODE_MIN_AMOUNT_NOT_MET → PromoMinAmountNotMetException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'below min',
        code: '22023',
        hint: 'CODE_MIN_AMOUNT_NOT_MET',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.validateAndApplyPromo(
          shopId: 'shop-a',
          code: 'HUNDRED',
          userId: 'user-a',
          bookingTotal: 50,
        ),
        throwsA(isA<PromoMinAmountNotMetException>()),
      );
    });

    test('22023 CODE_SERVICE_NOT_ELIGIBLE → PromoServiceNotEligibleException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'service', code: '22023', hint: 'CODE_SERVICE_NOT_ELIGIBLE',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.validateAndApplyPromo(
          shopId: 'shop-a',
          code: 'HAIRCUT',
          userId: 'user-a',
          bookingTotal: 100,
          serviceIds: const ['other-slot'],
        ),
        throwsA(isA<PromoServiceNotEligibleException>()),
      );
    });

    test('22023 CODE_WRONG_CLIENT → PromoWrongClientException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'wrong client', code: '22023', hint: 'CODE_WRONG_CLIENT',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.validateAndApplyPromo(
          shopId: 'shop-a',
          code: 'LOYAL-ABC123',
          userId: 'user-b',
          bookingTotal: 100,
        ),
        throwsA(isA<PromoWrongClientException>()),
      );
    });

    test('22023 unknown hint → InvalidDiscountAmountException fallback',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'weird', code: '22023', hint: 'UNKNOWN_FUTURE_HINT',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.validateAndApplyPromo(
          shopId: 'shop-a',
          code: 'WHATEVER',
          userId: 'user-a',
          bookingTotal: 100,
        ),
        throwsA(isA<InvalidDiscountAmountException>()),
      );
    });

    test('passes RPC params with snake_case keys (registered user)',
        () async {
      final supabase = _MockSupabaseClient();
      // Throw to short-circuit; we only care about the captured params.
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'X', code: '99999'));

      final repo = PromotionsRepository(supabaseClient: supabase);
      try {
        await repo.validateAndApplyPromo(
          shopId: 'shop-a',
          code: 'SUMMER10',
          userId: 'user-a',
          bookingTotal: 100,
          serviceIds: const ['slot-1', 'slot-2'],
        );
      } catch (_) {
        // expected
      }

      final captured = verify(() => supabase.rpc(
            'validate_and_apply_promo',
            params: captureAny(named: 'params'),
          )).captured;
      final params = captured.single as Map<String, dynamic>;
      expect(params['p_shop_id'], 'shop-a');
      expect(params['p_code'], 'SUMMER10');
      expect(params['p_user_id'], 'user-a');
      expect(params['p_guest_profile_id'], isNull);
      expect(params['p_booking_total'], 100);
      expect(params['p_service_ids'], ['slot-1', 'slot-2']);
    });

    test('passes guest_profile_id when userId is null (auto-apply path)',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'X', code: '99999'));

      final repo = PromotionsRepository(supabaseClient: supabase);
      try {
        await repo.validateAndApplyPromo(
          shopId: 'shop-a',
          code: null, // auto-apply
          guestProfileId: 'guest-a',
          bookingTotal: 100,
        );
      } catch (_) {
        // expected
      }

      final captured = verify(() => supabase.rpc(
            'validate_and_apply_promo',
            params: captureAny(named: 'params'),
          )).captured;
      final params = captured.single as Map<String, dynamic>;
      expect(params['p_code'], isNull);
      expect(params['p_user_id'], isNull);
      expect(params['p_guest_profile_id'], 'guest-a');
    });
  });

  group('upsertLoyaltyRule error mapping', () {
    test('42501 → PromotionNotFoundException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'not owner', code: '42501'));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.upsertLoyaltyRule(
          shopId: 'shop-a',
          triggerVisitCount: 6,
          discountType: DiscountType.percentage,
          discountValue: 15,
        ),
        throwsA(isA<PromotionNotFoundException>()),
      );
    });

    test(
        '22023 DISCOUNT_VALUE_NOT_POSITIVE → InvalidDiscountAmountException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'bad value',
        code: '22023',
        hint: 'DISCOUNT_VALUE_NOT_POSITIVE',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.upsertLoyaltyRule(
          shopId: 'shop-a',
          triggerVisitCount: 6,
          discountType: DiscountType.percentage,
          discountValue: 0,
        ),
        throwsA(isA<InvalidDiscountAmountException>()),
      );
    });

    test('22023 unknown hint → LoyaltyRuleSaveFailedException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'weird', code: '22023', hint: 'UNKNOWN_HINT',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.upsertLoyaltyRule(
          shopId: 'shop-a',
          triggerVisitCount: 6,
          discountType: DiscountType.percentage,
          discountValue: 15,
        ),
        throwsA(isA<LoyaltyRuleSaveFailedException>()),
      );
    });

    test('unknown error code → LoyaltyRuleSaveFailedException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'boom', code: '99999'));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.upsertLoyaltyRule(
          shopId: 'shop-a',
          triggerVisitCount: 6,
          discountType: DiscountType.percentage,
          discountValue: 15,
        ),
        throwsA(isA<LoyaltyRuleSaveFailedException>()),
      );
    });

    test('passes RPC params with snake_case keys', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'X', code: '99999'));

      final repo = PromotionsRepository(supabaseClient: supabase);
      try {
        await repo.upsertLoyaltyRule(
          shopId: 'shop-a',
          triggerVisitCount: 6,
          discountType: DiscountType.percentage,
          discountValue: 15,
          isActive: true,
        );
      } catch (_) {
        // expected
      }

      final captured = verify(() => supabase.rpc(
            'upsert_loyalty_rule',
            params: captureAny(named: 'params'),
          )).captured;
      final params = captured.single as Map<String, dynamic>;
      expect(params['p_shop_id'], 'shop-a');
      expect(params['p_trigger_visit_count'], 6);
      expect(params['p_discount_type'], 'percentage');
      expect(params['p_discount_value'], 15);
      expect(params['p_is_active'], true);
    });
  });
}
