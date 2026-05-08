// lib/features/wallet/presentation/controllers/wallet_controller.dart
import 'package:nano_embryo/presentation/features/shops/wallet/data/exceptions/wallet_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/wallet/providers/wallet_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wallet_controller.g.dart';

@riverpod
class WalletController extends _$WalletController {
  @override
  Future<void> build() async {}

  Future<bool> requestWithdrawal({
    required String shopId,
    required double amount,
  }) async {
    try {
      final repository = ref.read(walletRepositoryProvider);

      // Create withdrawal request (this will trigger Edge Function automatically)
      await repository.requestWithdrawal(shopId: shopId, amount: amount);

      // Refresh wallet and transaction data
      ref.invalidate(shopWalletProvider(shopId));
      ref.invalidate(walletTransactionsProvider(shopId: shopId));

      return true;
    } on InsufficientBalanceException catch (e) {
      print('Insufficient balance: ${e.message}');
      return false;
    } catch (e) {
      print('Withdrawal failed: $e');
      return false;
    }
  }
}
