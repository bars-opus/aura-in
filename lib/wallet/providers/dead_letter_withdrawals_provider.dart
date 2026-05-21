import 'package:nano_embryo/wallet/data/models/withdrawal_request_model.dart';
import 'package:nano_embryo/wallet/providers/wallet_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dead_letter_withdrawals_provider.g.dart';

@riverpod
Stream<List<WithdrawalRequestModel>> deadLetterWithdrawals(
  DeadLetterWithdrawalsRef ref,
  String shopId,
) {
  final repo = ref.watch(walletRepositoryProvider);
  return repo.watchDeadLetterWithdrawals(shopId);
}
