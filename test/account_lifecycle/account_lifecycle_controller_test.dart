import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nano_embryo/core/account_lifecycle/data/account_lifecycle_models.dart';
import 'package:nano_embryo/core/account_lifecycle/data/account_lifecycle_repository.dart';
import 'package:nano_embryo/core/account_lifecycle/presentation/providers/account_lifecycle_provider.dart';

class MockRepository extends Mock implements AccountLifecycleRepository {}

void main() {
  late MockRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = MockRepository();
    container = ProviderContainer(
      overrides: [
        accountLifecycleRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() => container.dispose());

  AccountLifecycleController controller() =>
      container.read(accountLifecycleControllerProvider.notifier);

  group('deactivate', () {
    test('passes through reason + phrase + correlation_id', () async {
      when(
        () => repo.deactivateAccount(
          reason: any(named: 'reason'),
          confirmationPhrase: any(named: 'confirmationPhrase'),
          correlationId: any(named: 'correlationId'),
        ),
      ).thenAnswer(
        (_) async => const AccountLifecycleActionResult(success: true),
      );

      final result = await controller().deactivate(
        reason: 'leaving for a competitor',
        confirmationPhrase: 'DEACTIVATE',
      );

      expect(result.success, isTrue);
      final captured = verify(
        () => repo.deactivateAccount(
          reason: captureAny(named: 'reason'),
          confirmationPhrase: captureAny(named: 'confirmationPhrase'),
          correlationId: captureAny(named: 'correlationId'),
        ),
      ).captured;
      expect(captured[0], 'leaving for a competitor');
      expect(captured[1], 'DEACTIVATE');
      expect(captured[2], isA<String>());
      expect((captured[2] as String).isNotEmpty, isTrue);
    });

    test('exposes blockers payload on failure', () async {
      const blockers = AccountLifecycleBlockers(
        activeBookings: 1,
        ownedShopActiveBookings: 0,
        activeOrders: 0,
        ownedShopActiveOrders: 0,
        activeWithdrawals: 0,
      );
      when(
        () => repo.deactivateAccount(
          reason: any(named: 'reason'),
          confirmationPhrase: any(named: 'confirmationPhrase'),
          correlationId: any(named: 'correlationId'),
        ),
      ).thenAnswer(
        (_) async => const AccountLifecycleActionResult(
          success: false,
          reason: 'active_obligations',
          blockers: blockers,
        ),
      );

      final result = await controller().deactivate();
      expect(result.success, isFalse);
      expect(result.blockers?.activeBookings, 1);
    });

    test('rate-limited error bubbles up and sets AsyncError state', () async {
      when(
        () => repo.deactivateAccount(
          reason: any(named: 'reason'),
          confirmationPhrase: any(named: 'confirmationPhrase'),
          correlationId: any(named: 'correlationId'),
        ),
      ).thenThrow(const AccountLifecycleException('rate_limited'));

      await expectLater(
        () => controller().deactivate(),
        throwsA(isA<AccountLifecycleException>()),
      );

      final state = container.read(accountLifecycleControllerProvider);
      expect(state.hasError, isTrue);
      expect(
        (state.error as AccountLifecycleException).code,
        'rate_limited',
      );
    });
  });

  group('requestDeletion', () {
    test('passes through correlation_id', () async {
      when(
        () => repo.requestAccountDeletion(
          reason: any(named: 'reason'),
          confirmationPhrase: any(named: 'confirmationPhrase'),
          correlationId: any(named: 'correlationId'),
        ),
      ).thenAnswer(
        (_) async => AccountLifecycleActionResult(
          success: true,
          deletionScheduledFor: DateTime.utc(2026, 7, 13),
        ),
      );
      final result = await controller().requestDeletion(
        confirmationPhrase: 'DELETE',
      );
      expect(result.success, isTrue);
      expect(result.deletionScheduledFor?.year, 2026);
      verify(
        () => repo.requestAccountDeletion(
          reason: any(named: 'reason'),
          confirmationPhrase: 'DELETE',
          correlationId: any(named: 'correlationId'),
        ),
      ).called(1);
    });
  });

  group('restore', () {
    test('passes correlation_id and returns success', () async {
      when(
        () => repo.restoreAccount(correlationId: any(named: 'correlationId')),
      ).thenAnswer(
        (_) async => const AccountLifecycleActionResult(success: true),
      );
      final result = await controller().restore();
      expect(result.success, isTrue);
      verify(
        () => repo.restoreAccount(correlationId: any(named: 'correlationId')),
      ).called(1);
    });

    test('not-found error is surfaced and state is AsyncError', () async {
      when(
        () => repo.restoreAccount(correlationId: any(named: 'correlationId')),
      ).thenThrow(const AccountLifecycleException('unknown'));
      await expectLater(
        () => controller().restore(),
        throwsA(isA<AccountLifecycleException>()),
      );
      expect(
        container.read(accountLifecycleControllerProvider).hasError,
        isTrue,
      );
    });
  });

  group('confirmPassword + signOut', () {
    test('confirmPassword delegates to repo', () async {
      when(() => repo.confirmCurrentPassword(any())).thenAnswer((_) async {});
      await controller().confirmPassword('hunter2');
      verify(() => repo.confirmCurrentPassword('hunter2')).called(1);
    });

    test('signOut delegates to repo', () async {
      when(() => repo.signOut()).thenAnswer((_) async {});
      await controller().signOut();
      verify(() => repo.signOut()).called(1);
    });

    test('currentUserUsesPassword reads from repo', () {
      when(() => repo.currentUserUsesPassword()).thenReturn(false);
      expect(controller().currentUserUsesPassword(), isFalse);
    });
  });
}
