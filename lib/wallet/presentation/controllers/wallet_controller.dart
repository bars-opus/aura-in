// lib/features/wallet/presentation/controllers/wallet_controller.dart
import 'package:nano_embryo/wallet/data/exceptions/wallet_exceptions.dart';
import 'package:nano_embryo/wallet/providers/wallet_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wallet_controller.g.dart';

@riverpod
class WalletController extends _$WalletController {
  @override
  Future<void> build() async {}

  /// Returns normally on success. Throws [WalletException] or
  /// [InsufficientBalanceException] on failure so the UI can show a
  /// meaningful message instead of a silent false return.
  Future<void> requestWithdrawal({
    required String shopId,
    required double amount,
  }) async {
    final repository = ref.read(walletRepositoryProvider);

    await repository.requestWithdrawal(shopId: shopId, amount: amount);

    // Invalidate after successful creation so the UI reflects the new
    // pending_withdrawals deduction immediately.
    ref.invalidate(shopWalletProvider(shopId));
    ref.invalidate(walletTransactionsProvider(shopId: shopId));
  }
}
