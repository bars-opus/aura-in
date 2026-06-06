// test/dashboard/data/repositories/client_notes_repository_test.dart
//
// Contract tests for the Phase 12 client_notes surface:
//   * upsert_client_note error mapping (42501, 22023+hints, fallback)
//   * RPC parameter shape (snake_case keys, exactly-one-of identity)
//
// The list-/get-side read uses a Postgrest builder chain
// (.from().select().eq().eq().maybeSingle()) — same testing challenge
// as the services-repo Phase 11 file: mocking the full builder chain
// requires three layers of generic mocks that drift on every SDK rev.
// Skipped here for the same reason; the chain composition is plain
// enough to inspect manually and is exercised via UAT in Wave 6.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/client_notes_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/supabase_dashboard_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('upsertClientNote error mapping', () {
    test('42501 -> NoteAccessDeniedException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'not_owner',
        code: '42501',
      ));

      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.upsertClientNote(
          shopId: 'shop-a',
          userId: 'user-a',
          body: 'note',
        ),
        throwsA(isA<NoteAccessDeniedException>()),
      );
    });

    test('22023 with hint NOTE_TOO_LONG -> NoteTooLongException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'invalid_input',
        code: '22023',
        hint: 'NOTE_TOO_LONG',
      ));

      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.upsertClientNote(
          shopId: 'shop-a',
          userId: 'user-a',
          body: 'x' * 3000,
        ),
        throwsA(isA<NoteTooLongException>()),
      );
    });

    test(
        '22023 with hint EXACTLY_ONE_OF_USER_OR_GUEST -> NotePayloadInvalidException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'invalid_identity',
        code: '22023',
        hint: 'EXACTLY_ONE_OF_USER_OR_GUEST',
      ));

      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      // The Dart-side assert() also enforces this; we bypass it here by
      // calling with a registered user id (which is valid) and rely on
      // the server's classifier to surface the typed exception when the
      // server-side branch raises EXACTLY_ONE_OF_USER_OR_GUEST. The
      // assert path is covered separately.
      await expectLater(
        repo.upsertClientNote(
          shopId: 'shop-a',
          userId: 'user-a',
          body: 'note',
        ),
        throwsA(isA<NotePayloadInvalidException>()),
      );
    });

    test('22023 with hint BODY_NULL_NOT_ALLOWED -> NotePayloadInvalidException',
        () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(
        message: 'invalid_input',
        code: '22023',
        hint: 'BODY_NULL_NOT_ALLOWED',
      ));

      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.upsertClientNote(
          shopId: 'shop-a',
          userId: 'user-a',
          body: '',
        ),
        throwsA(isA<NotePayloadInvalidException>()),
      );
    });

    test('unknown code -> NoteSaveFailedException', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'boom', code: '99999'));

      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      await expectLater(
        repo.upsertClientNote(
          shopId: 'shop-a',
          userId: 'user-a',
          body: 'note',
        ),
        throwsA(isA<NoteSaveFailedException>()),
      );
    });

    test('passes RPC params with snake_case keys', () async {
      // We capture by failing on the first call (PostgrestException) so
      // the repo throws — that's fine, the verify() afterwards inspects
      // the params dict that was passed to the rpc() stub.
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'expected', code: '99999'));

      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      try {
        await repo.upsertClientNote(
          shopId: 'shop-a',
          userId: 'user-a',
          body: 'hello',
        );
      } on NoteSaveFailedException {
        // expected
      }

      final captured = verify(() => supabase.rpc(
            'upsert_client_note',
            params: captureAny(named: 'params'),
          )).captured;
      final params = captured.single as Map<String, dynamic>;
      // Keys are snake_case (matches the SQL function signature).
      expect(params['p_shop_id'], 'shop-a');
      expect(params['p_user_id'], 'user-a');
      expect(params['p_guest_profile_id'], isNull);
      expect(params['p_body'], 'hello');
    });

    test('passes guest_profile_id when userId is null', () async {
      final supabase = _MockSupabaseClient();
      when(() => supabase.rpc(any(), params: any(named: 'params')))
          .thenThrow(PostgrestException(message: 'expected', code: '99999'));

      final repo = SupabaseDashboardRepository(supabaseClient: supabase);
      try {
        await repo.upsertClientNote(
          shopId: 'shop-a',
          guestProfileId: 'guest-a',
          body: 'hello',
        );
      } on NoteSaveFailedException {
        // expected
      }

      final captured = verify(() => supabase.rpc(
            'upsert_client_note',
            params: captureAny(named: 'params'),
          )).captured;
      final params = captured.single as Map<String, dynamic>;
      expect(params['p_user_id'], isNull);
      expect(params['p_guest_profile_id'], 'guest-a');
    });
  });
}
