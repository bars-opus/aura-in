import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/account_lifecycle/data/account_lifecycle_models.dart';

void main() {
  group('AccountLifecycleStatus.fromValue', () {
    test('parses known values', () {
      expect(
        AccountLifecycleStatus.fromValue('active'),
        AccountLifecycleStatus.active,
      );
      expect(
        AccountLifecycleStatus.fromValue('deactivated'),
        AccountLifecycleStatus.deactivated,
      );
      expect(
        AccountLifecycleStatus.fromValue('pending_delete'),
        AccountLifecycleStatus.pendingDelete,
      );
      expect(
        AccountLifecycleStatus.fromValue('deleted'),
        AccountLifecycleStatus.deleted,
      );
    });

    test('defaults to active for null, empty, and unknown values', () {
      expect(
        AccountLifecycleStatus.fromValue(null),
        AccountLifecycleStatus.active,
      );
      expect(
        AccountLifecycleStatus.fromValue(''),
        AccountLifecycleStatus.active,
      );
      expect(
        AccountLifecycleStatus.fromValue('banned'),
        AccountLifecycleStatus.active,
      );
    });
  });

  group('AccountLifecycleProfile.fromJson', () {
    test('parses timestamps + status', () {
      final profile = AccountLifecycleProfile.fromJson({
        'id': 'user-1',
        'account_status': 'pending_delete',
        'pending_deletion_at': '2026-06-13T00:00:00Z',
        'deletion_scheduled_for': '2026-07-13T00:00:00Z',
      });
      expect(profile.id, 'user-1');
      expect(profile.status, AccountLifecycleStatus.pendingDelete);
      expect(profile.pendingDeletionAt, isNotNull);
      expect(profile.deletionScheduledFor, isNotNull);
      expect(profile.deactivatedAt, isNull);
      expect(profile.deletedAt, isNull);
    });

    test('canRestore is false only for deleted', () {
      expect(
        AccountLifecycleProfile.fromJson({'id': 'u', 'account_status': 'deleted'})
            .canRestore,
        isFalse,
      );
      expect(
        AccountLifecycleProfile.fromJson({
          'id': 'u',
          'account_status': 'pending_delete',
        }).canRestore,
        isTrue,
      );
      expect(
        AccountLifecycleProfile.fromJson({
          'id': 'u',
          'account_status': 'deactivated',
        }).canRestore,
        isTrue,
      );
    });

    test('needsRestore covers deactivated + pending_delete only', () {
      expect(
        AccountLifecycleProfile.fromJson({
          'id': 'u',
          'account_status': 'deactivated',
        }).needsRestore,
        isTrue,
      );
      expect(
        AccountLifecycleProfile.fromJson({
          'id': 'u',
          'account_status': 'pending_delete',
        }).needsRestore,
        isTrue,
      );
      expect(
        AccountLifecycleProfile.fromJson({'id': 'u', 'account_status': 'deleted'})
            .needsRestore,
        isFalse,
      );
      expect(
        AccountLifecycleProfile.fromJson({'id': 'u', 'account_status': 'active'})
            .needsRestore,
        isFalse,
      );
    });

    test('falls back to empty id when missing', () {
      final profile = AccountLifecycleProfile.fromJson({});
      expect(profile.id, '');
      expect(profile.status, AccountLifecycleStatus.active);
    });
  });

  group('AccountLifecycleBlockers', () {
    test('hasBlockers is true when any count > 0', () {
      const empty = AccountLifecycleBlockers(
        activeBookings: 0,
        ownedShopActiveBookings: 0,
        activeOrders: 0,
        ownedShopActiveOrders: 0,
        activeWithdrawals: 0,
      );
      expect(empty.hasBlockers, isFalse);
      expect(empty.total, 0);

      const oneBooking = AccountLifecycleBlockers(
        activeBookings: 1,
        ownedShopActiveBookings: 0,
        activeOrders: 0,
        ownedShopActiveOrders: 0,
        activeWithdrawals: 0,
      );
      expect(oneBooking.hasBlockers, isTrue);
      expect(oneBooking.total, 1);
    });

    test('fromJson coerces strings + nums', () {
      final blockers = AccountLifecycleBlockers.fromJson({
        'active_bookings': '3',
        'owned_shop_active_bookings': 2,
        'active_orders': 1.0,
        'owned_shop_active_orders': null,
        'active_withdrawals': 'bad',
      });
      expect(blockers.activeBookings, 3);
      expect(blockers.ownedShopActiveBookings, 2);
      expect(blockers.activeOrders, 1);
      expect(blockers.ownedShopActiveOrders, 0);
      expect(blockers.activeWithdrawals, 0);
      expect(blockers.total, 6);
    });
  });

  group('AccountLifecycleActionResult.fromJson', () {
    test('parses successful deactivation', () {
      final result = AccountLifecycleActionResult.fromJson({
        'success': true,
        'status': 'deactivated',
      });
      expect(result.success, isTrue);
      expect(result.reason, isNull);
      expect(result.blockers, isNull);
      expect(result.deletionScheduledFor, isNull);
    });

    test('parses blocked-by-obligations failure', () {
      final result = AccountLifecycleActionResult.fromJson({
        'success': false,
        'reason': 'active_obligations',
        'blockers': {
          'active_bookings': 2,
          'owned_shop_active_bookings': 0,
          'active_orders': 0,
          'owned_shop_active_orders': 0,
          'active_withdrawals': 0,
        },
      });
      expect(result.success, isFalse);
      expect(result.reason, 'active_obligations');
      expect(result.blockers?.activeBookings, 2);
      expect(result.blockers?.hasBlockers, isTrue);
    });

    test('parses deletion scheduling', () {
      final result = AccountLifecycleActionResult.fromJson({
        'success': true,
        'deletion_scheduled_for': '2026-07-13T00:00:00Z',
      });
      expect(result.success, isTrue);
      expect(result.deletionScheduledFor, isNotNull);
    });
  });
}
