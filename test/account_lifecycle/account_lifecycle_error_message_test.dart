import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/account_lifecycle/config/account_lifecycle_texts.dart';
import 'package:nano_embryo/core/account_lifecycle/data/account_lifecycle_repository.dart';
import 'package:nano_embryo/core/account_lifecycle/utils/account_lifecycle_error_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  const texts = AccountLifecycleTexts();

  group('accountLifecycleErrorMessage', () {
    test('recent_auth_required → sign-in copy', () {
      expect(
        accountLifecycleErrorMessage(
          texts,
          const AccountLifecycleException('recent_auth_required'),
        ),
        texts.recentAuthRequired,
      );
    });

    test('invalid_confirmation with phrase → mismatch copy', () {
      expect(
        accountLifecycleErrorMessage(
          texts,
          const AccountLifecycleException('invalid_confirmation'),
          phrase: 'DELETE',
        ),
        texts.phraseMismatch('DELETE'),
      );
    });

    test('invalid_confirmation without phrase → generic', () {
      expect(
        accountLifecycleErrorMessage(
          texts,
          const AccountLifecycleException('invalid_confirmation'),
        ),
        texts.genericError,
      );
    });

    test('invalid_input → reason-too-long copy', () {
      expect(
        accountLifecycleErrorMessage(
          texts,
          const AccountLifecycleException('invalid_input'),
        ),
        texts.reasonTooLong,
      );
    });

    test('rate_limited → rate-limited copy', () {
      expect(
        accountLifecycleErrorMessage(
          texts,
          const AccountLifecycleException('rate_limited'),
        ),
        texts.rateLimited,
      );
    });

    test('unknown code → generic', () {
      expect(
        accountLifecycleErrorMessage(
          texts,
          const AccountLifecycleException('weird_new_code'),
        ),
        texts.genericError,
      );
    });

    test('arbitrary exception → generic', () {
      expect(
        accountLifecycleErrorMessage(texts, Exception('boom')),
        texts.genericError,
      );
    });
  });

  group('AccountLifecycleException.fromPostgrest', () {
    AccountLifecycleException map(String msg, {String? hint}) {
      return AccountLifecycleException.fromPostgrest(
        PostgrestException(message: msg, hint: hint),
      );
    }

    test('recent_auth in message', () {
      expect(map('recent_auth_required').code, 'recent_auth_required');
    });
    test('reauth hint', () {
      expect(map('boom', hint: 'REAUTH_10_MIN').code, 'recent_auth_required');
    });
    test('invalid_confirmation', () {
      expect(map('invalid_confirmation').code, 'invalid_confirmation');
    });
    test('confirmation_phrase_required hint', () {
      expect(
        map('whatever', hint: 'CONFIRMATION_PHRASE_REQUIRED').code,
        'invalid_confirmation',
      );
    });
    test('invalid_input', () {
      expect(map('invalid_input').code, 'invalid_input');
    });
    test('reason_max_1000 hint', () {
      expect(map('bad reason', hint: 'REASON_MAX_1000').code, 'invalid_input');
    });
    test('rate_limited', () {
      expect(map('rate_limited').code, 'rate_limited');
    });
    test('rate_limit_per_window hint', () {
      expect(
        map('blocked', hint: 'RATE_LIMIT_PER_WINDOW').code,
        'rate_limited',
      );
    });
    test('unauthorized', () {
      expect(map('unauthorized').code, 'unauthorized');
    });
    test('anything else → unknown', () {
      expect(map('something obscure').code, 'unknown');
    });
  });
}
