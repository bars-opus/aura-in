import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/moderation/config/moderation_config.dart';
import 'package:nano_embryo/core/moderation/data/moderation_models.dart';
import 'package:nano_embryo/core/moderation/data/moderation_repository.dart';

final moderationRepositoryProvider = Provider<ModerationRepository>((ref) {
  final config = ref.watch(moderationConfigProvider);
  return ModerationRepository(
    ref.watch(moderationSupabaseClientProvider),
    timeout: config.rpcTimeout,
    logger: config.logger,
  );
});

final blockedAccountsProvider =
    FutureProvider.autoDispose<List<ModerationBlockRecord>>((ref) {
      return ref.watch(moderationRepositoryProvider).getBlockedAccounts();
    });

final blockedUserIdsProvider = FutureProvider.autoDispose<Set<String>>((ref) {
  return ref.watch(moderationRepositoryProvider).getBlockedUserIds();
});

final moderationBlockStatusProvider = FutureProvider.autoDispose
    .family<ModerationCheckResult, String>((ref, otherUserId) {
      if (otherUserId.isEmpty) {
        return Future.value(
          const ModerationCheckResult(
            isBlocked: false,
            isBlockedByCurrentUser: false,
            isBlockingCurrentUser: false,
          ),
        );
      }
      return ref
          .watch(moderationRepositoryProvider)
          .getBlockStatus(otherUserId);
    });

final moderationControllerProvider =
    StateNotifierProvider.autoDispose<ModerationController, AsyncValue<void>>(
      (ref) => ModerationController(ref),
    );

class ModerationController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  ModerationController(this._ref) : super(const AsyncData(null));

  Future<ModerationActionResult> blockUser({
    required String blockedUserId,
    String? reason,
  }) {
    return _run(() async {
      final result = await _ref
          .read(moderationRepositoryProvider)
          .blockUser(blockedUserId: blockedUserId, reason: reason);
      _refresh();
      return result;
    });
  }

  Future<ModerationActionResult> unblockUser({required String blockedUserId}) {
    return _run(() async {
      final result = await _ref
          .read(moderationRepositoryProvider)
          .unblockUser(blockedUserId: blockedUserId);
      _refresh();
      return result;
    });
  }

  Future<ModerationActionResult> submitReport({
    required ModerationTarget target,
    required String reason,
    String? details,
    required String clientIdempotencyKey,
  }) {
    return _run(() async {
      final result = await _ref
          .read(moderationRepositoryProvider)
          .submitReport(
            target: target,
            reason: reason,
            details: details,
            clientIdempotencyKey: clientIdempotencyKey,
          );
      _refresh();
      return result;
    });
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    state = const AsyncLoading();
    try {
      final result = await action();
      state = const AsyncData(null);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void _refresh() {
    _ref.invalidate(blockedAccountsProvider);
    _ref.invalidate(blockedUserIdsProvider);
    _ref.read(moderationConfigProvider).refreshProfile?.call(_ref);
    _ref.read(moderationConfigProvider).refreshSearch?.call(_ref);
  }
}
