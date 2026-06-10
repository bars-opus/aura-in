// test/dashboard/data/repositories/broadcasts_repository_test.dart
//
// Phase 14 — contract tests for the 3 broadcast methods on
// PromotionsRepository:
//   * sendBroadcast HINT → typed exception mapping
//   * previewBroadcastAudience HINT → typed exception mapping
//   * RPC parameter shape (snake_case keys, audience_type sqlValue)
//
// Mirrors the Phase 13 promotions_repository_validate_test.dart pattern.
// The getBroadcasts list-side Postgrest chain is left for end-to-end
// smoke — the chain mock surface is brittle across Supabase SDK revs.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/broadcast_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/broadcast_dto.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/promotions_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('sendBroadcast error mapping', () {
    test('55P03 BROADCAST_DAILY_LIMIT → BroadcastRateLimitException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'daily',
        code: '55P03',
        hint: 'BROADCAST_DAILY_LIMIT',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.sendBroadcast(
          shopId: 'shop-a',
          subject: 'Hello',
          body: 'World',
          audienceType: BroadcastAudience.allClients,
        ),
        throwsA(isA<BroadcastRateLimitException>()),
      );
    });

    test('55P03 BROADCAST_IN_FLIGHT → BroadcastInFlightException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'lock',
        code: '55P03',
        hint: 'BROADCAST_IN_FLIGHT',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.sendBroadcast(
          shopId: 'shop-a',
          subject: 'Hello',
          body: 'World',
          audienceType: BroadcastAudience.allClients,
        ),
        throwsA(isA<BroadcastInFlightException>()),
      );
    });

    test('22023 AUDIENCE_TYPE_INVALID → BroadcastInvalidAudienceException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'audience',
        code: '22023',
        hint: 'AUDIENCE_TYPE_INVALID',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.sendBroadcast(
          shopId: 'shop-a',
          subject: 'Hello',
          body: 'World',
          audienceType: BroadcastAudience.allClients,
        ),
        throwsA(isA<BroadcastInvalidAudienceException>()),
      );
    });

    test('22023 AUDIENCE_PARAM_REQUIRED → BroadcastInvalidAudienceException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'missing param',
        code: '22023',
        hint: 'AUDIENCE_PARAM_REQUIRED',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.sendBroadcast(
          shopId: 'shop-a',
          subject: 'Hello',
          body: 'World',
          audienceType: BroadcastAudience.byService,
        ),
        throwsA(isA<BroadcastInvalidAudienceException>()),
      );
    });

    test('22023 PROMO_NOT_VALID → BroadcastPromoInvalidException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'promo',
        code: '22023',
        hint: 'PROMO_NOT_VALID',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.sendBroadcast(
          shopId: 'shop-a',
          subject: 'Hello',
          body: 'World',
          audienceType: BroadcastAudience.allClients,
          promotionId: 'expired-promo',
        ),
        throwsA(isA<BroadcastPromoInvalidException>()),
      );
    });

    test('22023 BROADCAST_CAP_EXCEEDED → BroadcastCapExceededException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'cap',
        code: '22023',
        hint: 'BROADCAST_CAP_EXCEEDED',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.sendBroadcast(
          shopId: 'shop-a',
          subject: 'Hello',
          body: 'World',
          audienceType: BroadcastAudience.allClients,
        ),
        throwsA(isA<BroadcastCapExceededException>()),
      );
    });

    test('22023 SUBJECT_TOO_LONG → BroadcastSaveFailedException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'too long',
        code: '22023',
        hint: 'SUBJECT_TOO_LONG',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.sendBroadcast(
          shopId: 'shop-a',
          subject: 'x' * 200,
          body: 'World',
          audienceType: BroadcastAudience.allClients,
        ),
        throwsA(isA<BroadcastSaveFailedException>()),
      );
    });

    test('42501 (sanitized) → BroadcastSaveFailedException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'denied', code: '42501'));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.sendBroadcast(
          shopId: 'shop-a',
          subject: 'Hello',
          body: 'World',
          audienceType: BroadcastAudience.allClients,
        ),
        throwsA(isA<BroadcastSaveFailedException>()),
      );
    });

    test('unknown error → BroadcastSaveFailedException (fallback)',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'X', code: '99999'));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.sendBroadcast(
          shopId: 'shop-a',
          subject: 'Hello',
          body: 'World',
          audienceType: BroadcastAudience.allClients,
        ),
        throwsA(isA<BroadcastSaveFailedException>()),
      );
    });

    test('passes RPC params with snake_case keys + sqlValue', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'expected', code: '99999'));

      final repo = PromotionsRepository(supabaseClient: supabase);
      try {
        await repo.sendBroadcast(
          shopId: 'shop-a',
          subject: 'Hello',
          body: 'World',
          audienceType: BroadcastAudience.byService,
          audienceParam: 'slot-a',
          promotionId: 'promo-a',
        );
      } on BroadcastSaveFailedException {
        // expected
      }

      final captured = verify(() => supabase.rpc(
            'send_broadcast',
            params: captureAny(named: 'params'),
          )).captured;
      final params = captured.single as Map<String, dynamic>;
      expect(params['p_shop_id'], 'shop-a');
      expect(params['p_subject'], 'Hello');
      expect(params['p_body'], 'World');
      // Uses SQL value, not Dart name.
      expect(params['p_audience_type'], 'by_service');
      expect(params['p_audience_param'], 'slot-a');
      expect(params['p_promotion_id'], 'promo-a');
    });
  });

  group('previewBroadcastAudience error mapping', () {
    test('22023 AUDIENCE_PARAM_FORBIDDEN → BroadcastInvalidAudienceException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'forbidden',
        code: '22023',
        hint: 'AUDIENCE_PARAM_FORBIDDEN',
      ));

      final repo = PromotionsRepository(supabaseClient: supabase);
      await expectLater(
        repo.previewBroadcastAudience(
          shopId: 'shop-a',
          audienceType: BroadcastAudience.allClients,
          audienceParam: 'shouldnt-be-set',
        ),
        throwsA(isA<BroadcastInvalidAudienceException>()),
      );
    });

    // happy-path / null-result return-shape tests are skipped because
    // the Supabase SDK's rpc() returns a PostgrestFilterBuilder which
    // resolves lazily — mocking the success path requires faking the
    // full builder chain (three layers of generic mocks). The error
    // paths above already exercise the classifier on every HINT branch;
    // the happy path's count-coercion is covered by direct integration
    // in widget test (c).
  });
}
