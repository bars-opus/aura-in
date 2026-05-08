// lib/features/wallet/shared/providers/wallet_providers.dart

import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/shops/wallet/data/models/wallet_model.dart';
import 'package:nano_embryo/presentation/features/shops/wallet/data/models/wallet_transaction_model.dart';
import 'package:nano_embryo/presentation/features/shops/wallet/data/repositories/supabase/supabase_wallet_repository.dart';
import 'package:nano_embryo/presentation/features/shops/wallet/data/repositories/wallet_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wallet_providers.g.dart';

@riverpod
WalletRepository walletRepository(WalletRepositoryRef ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseWalletRepository(supabaseClient);
}

@riverpod
Future<WalletModel> shopWallet(ShopWalletRef ref, String shopId) {
  final repository = ref.watch(walletRepositoryProvider);
  return repository.getWallet(shopId);
}

@riverpod
Future<List<WalletTransactionModel>> walletTransactions(
  WalletTransactionsRef ref, {
  required String shopId,
  int? limit,
  TransactionType? type,
}) {
  final repository = ref.watch(walletRepositoryProvider);
  return repository.getTransactions(shopId: shopId, limit: limit, type: type);
}
