import 'package:nano_embryo/core/account_lifecycle/config/account_lifecycle_texts.dart';
import 'package:nano_embryo/core/account_lifecycle/data/account_lifecycle_repository.dart';

String accountLifecycleErrorMessage(
  AccountLifecycleTexts texts,
  Object error, {
  String? phrase,
}) {
  if (error is AccountLifecycleException) {
    return switch (error.code) {
      'recent_auth_required' => texts.recentAuthRequired,
      'invalid_confirmation' =>
        phrase == null ? texts.genericError : texts.invalidConfirmation(phrase),
      'invalid_input' => texts.reasonTooLong,
      'rate_limited' => texts.rateLimited,
      _ => texts.genericError,
    };
  }
  return texts.genericError;
}
