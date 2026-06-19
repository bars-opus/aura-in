import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/account_lifecycle/utils/account_lifecycle_router_guard.dart';

class _ProfileLike {
  final String? status;
  _ProfileLike(this.status);
  Map<String, dynamic> toJson() => {'account_status': status};
}

void main() {
  group('accountLifecycleStatusFromProfile', () {
    test('reads from Map<String, dynamic>', () {
      expect(
        accountLifecycleStatusFromProfile({'account_status': 'deactivated'}),
        'deactivated',
      );
    });

    test('reads via toJson on objects', () {
      expect(
        accountLifecycleStatusFromProfile(_ProfileLike('pending_delete')),
        'pending_delete',
      );
    });

    test('returns null for null profile', () {
      expect(accountLifecycleStatusFromProfile(null), isNull);
    });

    test('returns null when object has no toJson', () {
      expect(accountLifecycleStatusFromProfile(Object()), isNull);
    });
  });

  group('accountLifecycleGuard', () {
    const restore = '/restore';
    const home = '/';

    test('active user is allowed everywhere except restore', () {
      final atHome = accountLifecycleGuard(
        profile: {'account_status': 'active'},
        currentLocation: '/',
        restoreRoute: restore,
        homeRoute: home,
      );
      expect(atHome.shouldRedirect, isFalse);

      final atRestore = accountLifecycleGuard(
        profile: {'account_status': 'active'},
        currentLocation: restore,
        restoreRoute: restore,
        homeRoute: home,
      );
      expect(atRestore.shouldRedirect, isTrue);
      expect(atRestore.route, home);
    });

    test('deactivated user is forced to restore from any other route', () {
      final guard = accountLifecycleGuard(
        profile: {'account_status': 'deactivated'},
        currentLocation: '/calendar',
        restoreRoute: restore,
        homeRoute: home,
      );
      expect(guard.shouldRedirect, isTrue);
      expect(guard.route, restore);
    });

    test('deactivated user on restore screen is allowed', () {
      final guard = accountLifecycleGuard(
        profile: {'account_status': 'deactivated'},
        currentLocation: restore,
        restoreRoute: restore,
        homeRoute: home,
      );
      expect(guard.shouldRedirect, isFalse);
    });

    test('pending_delete behaves like deactivated', () {
      final guard = accountLifecycleGuard(
        profile: {'account_status': 'pending_delete'},
        currentLocation: '/settings',
        restoreRoute: restore,
        homeRoute: home,
      );
      expect(guard.shouldRedirect, isTrue);
      expect(guard.route, restore);
    });

    test('deleted user is forced to restore (final screen shows deleted state)', () {
      final guard = accountLifecycleGuard(
        profile: {'account_status': 'deleted'},
        currentLocation: '/',
        restoreRoute: restore,
        homeRoute: home,
      );
      expect(guard.shouldRedirect, isTrue);
      expect(guard.route, restore);
    });

    test('null profile is treated as active (no redirect)', () {
      final guard = accountLifecycleGuard(
        profile: null,
        currentLocation: '/',
        restoreRoute: restore,
        homeRoute: home,
      );
      expect(guard.shouldRedirect, isFalse);
    });
  });
}
