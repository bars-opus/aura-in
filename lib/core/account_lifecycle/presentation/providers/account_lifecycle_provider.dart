import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/account_lifecycle/config/feature/account_lifecycle_config.dart';
import 'package:nano_embryo/core/account_lifecycle/data/account_lifecycle_models.dart';
import 'package:nano_embryo/core/account_lifecycle/data/account_lifecycle_repository.dart';

final accountLifecycleRepositoryProvider = Provider<AccountLifecycleRepository>(
  (ref) {
    return AccountLifecycleRepository(
      ref.watch(accountLifecycleSupabaseClientProvider),
    );
  },
);

final accountLifecycleProfileProvider =
    FutureProvider.autoDispose<AccountLifecycleProfile?>((ref) {
      return ref.watch(accountLifecycleRepositoryProvider).getCurrentProfile();
    });

final accountLifecycleBlockersProvider =
    FutureProvider.autoDispose<AccountLifecycleBlockers>((ref) {
      return ref.watch(accountLifecycleRepositoryProvider).getBlockers();
    });

final accountLifecycleControllerProvider = StateNotifierProvider.autoDispose<
  AccountLifecycleController,
  AsyncValue<void>
>((ref) => AccountLifecycleController(ref));

class AccountLifecycleController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AccountLifecycleController(this._ref) : super(const AsyncData(null));

  Future<AccountLifecycleActionResult> deactivate({
    String? reason,
    String? confirmationPhrase,
  }) {
    final correlationId = _newCorrelationId();
    _log('deactivate.start', correlationId: correlationId);
    return _run(() async {
      final result = await _ref
          .read(accountLifecycleRepositoryProvider)
          .deactivateAccount(
            reason: reason,
            confirmationPhrase: confirmationPhrase,
            correlationId: correlationId,
          );
      _refreshAccountState();
      _log(
        'deactivate.complete',
        correlationId: correlationId,
        context: {'success': result.success, 'reason': result.reason},
      );
      return result;
    }, correlationId: correlationId, op: 'deactivate');
  }

  Future<AccountLifecycleActionResult> requestDeletion({
    String? reason,
    String? confirmationPhrase,
  }) {
    final correlationId = _newCorrelationId();
    _log('requestDeletion.start', correlationId: correlationId);
    return _run(() async {
      final result = await _ref
          .read(accountLifecycleRepositoryProvider)
          .requestAccountDeletion(
            reason: reason,
            confirmationPhrase: confirmationPhrase,
            correlationId: correlationId,
          );
      _refreshAccountState();
      _log(
        'requestDeletion.complete',
        correlationId: correlationId,
        context: {'success': result.success, 'reason': result.reason},
      );
      return result;
    }, correlationId: correlationId, op: 'requestDeletion');
  }

  Future<AccountLifecycleActionResult> restore() {
    final correlationId = _newCorrelationId();
    _log('restore.start', correlationId: correlationId);
    return _run(() async {
      final result = await _ref
          .read(accountLifecycleRepositoryProvider)
          .restoreAccount(correlationId: correlationId);
      _refreshAccountState();
      _log(
        'restore.complete',
        correlationId: correlationId,
        context: {'success': result.success, 'reason': result.reason},
      );
      return result;
    }, correlationId: correlationId, op: 'restore');
  }

  Future<void> confirmPassword(String password) {
    return _run(() {
      return _ref
          .read(accountLifecycleRepositoryProvider)
          .confirmCurrentPassword(password);
    });
  }

  Future<void> signOut() {
    return _run(() => _ref.read(accountLifecycleRepositoryProvider).signOut());
  }

  bool currentUserUsesPassword() {
    return _ref
        .read(accountLifecycleRepositoryProvider)
        .currentUserUsesPassword();
  }

  Future<T> _run<T>(
    Future<T> Function() action, {
    String? correlationId,
    String? op,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await action();
      state = const AsyncData(null);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      _log(
        '${op ?? 'action'}.error',
        correlationId: correlationId,
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void _refreshAccountState() {
    _ref.invalidate(accountLifecycleProfileProvider);
    _ref.invalidate(accountLifecycleBlockersProvider);
    try {
      _ref.read(accountLifecycleConfigProvider).refreshProfile?.call(_ref);
    } catch (error, stackTrace) {
      _log(
        'refreshProfile.error',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  String _newCorrelationId() {
    return _ref.read(accountLifecycleConfigProvider).correlationIdGenerator();
  }

  void _log(
    String message, {
    String? correlationId,
    Map<String, Object?>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _ref.read(accountLifecycleConfigProvider).log(
      message,
      correlationId: correlationId,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
