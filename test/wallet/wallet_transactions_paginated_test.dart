import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/wallet/data/models/wallet_model.dart';
import 'package:nano_embryo/wallet/data/models/wallet_transaction_model.dart';
import 'package:nano_embryo/wallet/data/models/withdrawal_request_model.dart';
import 'package:nano_embryo/wallet/data/repositories/wallet_repository.dart';
import 'package:nano_embryo/wallet/providers/wallet_providers.dart';
import 'package:nano_embryo/wallet/providers/wallet_transactions_paginated_provider.dart';

class _FakeRepo implements WalletRepository {
  _FakeRepo(this.pages);
  final List<List<WalletTransactionModel>> pages;
  int call = 0;

  @override
  Future<List<WalletTransactionModel>> getTransactions({
    required String shopId,
    int? limit,
    int? offset,
    DateTime? before,
    DateTime? fromDate,
    DateTime? toDate,
    TransactionType? type,
  }) async {
    if (call >= pages.length) return [];
    return pages[call++];
  }

  @override
  Future<WalletModel> getWallet(String shopId) =>
      throw UnimplementedError();

  @override
  Stream<List<WithdrawalRequestModel>> watchDeadLetterWithdrawals(
    String shopId,
  ) =>
      throw UnimplementedError();

  @override
  Future<WalletTransactionModel> addTransaction({
    required String shopId,
    required double amount,
    required TransactionType type,
    String? bookingId,
    String? description,
    String? reference,
    Map<String, dynamic>? metadata,
  }) =>
      throw UnimplementedError();

  @override
  Future<WithdrawalRequestModel> requestWithdrawal({
    required String shopId,
    required double amount,
  }) =>
      throw UnimplementedError();

  @override
  Future<List<WithdrawalRequestModel>> getWithdrawalHistory({
    required String shopId,
    int? limit,
    WithdrawalStatus? status,
  }) =>
      throw UnimplementedError();
}

WalletTransactionModel _txn(String id, DateTime createdAt) =>
    WalletTransactionModel(
      id: id,
      shopId: 'shop_1',
      amount: 10,
      type: TransactionType.deposit,
      status: TransactionStatus.completed,
      balanceAfter: 100,
      metadata: const {},
      createdAt: createdAt,
    );

void main() {
  group('WalletTransactionsPaginated', () {
    test('build returns first page', () async {
      final repo = _FakeRepo([
        List.generate(20, (i) => _txn('t$i', DateTime(2026, 5, 20 - i))),
      ]);
      final container = ProviderContainer(overrides: [
        walletRepositoryProvider.overrideWith((_) => repo),
      ]);
      addTearDown(container.dispose);

      final list = await container
          .read(walletTransactionsPaginatedProvider('shop_1').future);
      expect(list, hasLength(20));
    });

    test('loadNext appends second page', () async {
      final repo = _FakeRepo([
        List.generate(20, (i) => _txn('t$i', DateTime(2026, 5, 20 - i))),
        List.generate(20, (i) => _txn('u$i', DateTime(2026, 4, 30 - i))),
      ]);
      final container = ProviderContainer(overrides: [
        walletRepositoryProvider.overrideWith((_) => repo),
      ]);
      addTearDown(container.dispose);

      await container
          .read(walletTransactionsPaginatedProvider('shop_1').future);
      await container
          .read(walletTransactionsPaginatedProvider('shop_1').notifier)
          .loadNext();
      final state = container
          .read(walletTransactionsPaginatedProvider('shop_1'))
          .value!;
      expect(state, hasLength(40));
    });

    test('loadNext no-op when hasMore=false', () async {
      final repo = _FakeRepo([
        List.generate(5, (i) => _txn('t$i', DateTime(2026, 5, 20 - i))),
      ]);
      final container = ProviderContainer(overrides: [
        walletRepositoryProvider.overrideWith((_) => repo),
      ]);
      addTearDown(container.dispose);

      await container
          .read(walletTransactionsPaginatedProvider('shop_1').future);
      final notifier = container
          .read(walletTransactionsPaginatedProvider('shop_1').notifier);
      expect(notifier.hasMore, isFalse);

      await notifier.loadNext();
      expect(repo.call, 1, reason: 'should not invoke repo again');
    });
  });
}
