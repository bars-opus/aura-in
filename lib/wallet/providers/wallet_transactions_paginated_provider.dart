import 'package:nano_embryo/wallet/data/models/wallet_transaction_model.dart';
import 'package:nano_embryo/wallet/providers/wallet_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wallet_transactions_paginated_provider.g.dart';

@riverpod
class WalletTransactionsPaginated extends _$WalletTransactionsPaginated {
  static const _pageSize = 20;
  bool _hasMore = true;
  bool _loading = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _loading;

  @override
  Future<List<WalletTransactionModel>> build(String shopId) async {
    final repo = ref.read(walletRepositoryProvider);
    final first = await repo.getTransactions(
      shopId: shopId,
      limit: _pageSize,
    );
    _hasMore = first.length == _pageSize;
    return first;
  }

  Future<void> loadNext() async {
    if (_loading || !_hasMore) return;
    final current = state.valueOrNull;
    if (current == null || current.isEmpty) return;
    _loading = true;
    try {
      final repo = ref.read(walletRepositoryProvider);
      final next = await repo.getTransactions(
        shopId: shopId,
        before: current.last.createdAt,
        limit: _pageSize,
      );
      _hasMore = next.length == _pageSize;
      state = AsyncData([...current, ...next]);
    } finally {
      _loading = false;
    }
  }

  Future<void> refresh() async {
    _hasMore = true;
    ref.invalidateSelf();
    await future;
  }
}
