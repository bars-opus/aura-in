import 'package:nano_embryo/core/account_lifecycle/data/account_lifecycle_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountLifecycleRepository {
  final SupabaseClient _client;

  AccountLifecycleRepository(this._client);

  Future<AccountLifecycleProfile?> getCurrentProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response =
        await _client
            .from('profiles')
            .select(
              'id, account_status, deactivated_at, pending_deletion_at, deletion_scheduled_for, deleted_at',
            )
            .eq('id', userId)
            .maybeSingle();

    if (response == null) return null;
    return AccountLifecycleProfile.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  Future<AccountLifecycleBlockers> getBlockers() async {
    final response = await _client.rpc('get_account_action_blockers');
    return AccountLifecycleBlockers.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  Future<AccountLifecycleActionResult> deactivateAccount({
    String? reason,
    String? confirmationPhrase,
    String? correlationId,
  }) async {
    return _runAccountRpc(() async {
      final response = await _client.rpc(
        'deactivate_account',
        params: {
          'p_reason': reason,
          'p_confirmation_phrase': confirmationPhrase,
          'p_correlation_id': correlationId,
        },
      );
      return AccountLifecycleActionResult.fromJson(
        Map<String, dynamic>.from(response),
      );
    });
  }

  Future<AccountLifecycleActionResult> requestAccountDeletion({
    String? reason,
    String? confirmationPhrase,
    String? correlationId,
  }) async {
    return _runAccountRpc(() async {
      final response = await _client.rpc(
        'request_account_deletion',
        params: {
          'p_reason': reason,
          'p_confirmation_phrase': confirmationPhrase,
          'p_correlation_id': correlationId,
        },
      );
      return AccountLifecycleActionResult.fromJson(
        Map<String, dynamic>.from(response),
      );
    });
  }

  Future<AccountLifecycleActionResult> restoreAccount({
    String? correlationId,
  }) async {
    return _runAccountRpc(() async {
      final response = await _client.rpc(
        'restore_account',
        params: {'p_correlation_id': correlationId},
      );
      return AccountLifecycleActionResult.fromJson(
        Map<String, dynamic>.from(response),
      );
    });
  }

  Future<void> confirmCurrentPassword(String password) async {
    final user = _client.auth.currentUser;
    final email = user?.email;
    if (email == null || email.isEmpty) {
      throw const AuthException('No email is available for this account.');
    }

    await _client.auth.signInWithPassword(email: email, password: password);
  }

  bool currentUserUsesPassword() {
    final provider = _client.auth.currentUser?.appMetadata['provider'];
    return provider == null || provider == 'email';
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }

  Future<T> _runAccountRpc<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PostgrestException catch (error) {
      throw AccountLifecycleException.fromPostgrest(error);
    }
  }
}

class AccountLifecycleException implements Exception {
  final String code;

  const AccountLifecycleException(this.code);

  factory AccountLifecycleException.fromPostgrest(PostgrestException error) {
    final message = error.message.toLowerCase();
    final hint = error.hint?.toLowerCase() ?? '';

    if (message.contains('recent_auth_required') ||
        hint.contains('reauth_10_min')) {
      return const AccountLifecycleException('recent_auth_required');
    }
    if (message.contains('invalid_confirmation') ||
        hint.contains('confirmation_phrase_required')) {
      return const AccountLifecycleException('invalid_confirmation');
    }
    if (message.contains('invalid_input') || hint.contains('reason_max_1000')) {
      return const AccountLifecycleException('invalid_input');
    }
    if (message.contains('rate_limited') ||
        hint.contains('rate_limit_per_window')) {
      return const AccountLifecycleException('rate_limited');
    }
    if (message.contains('unauthorized')) {
      return const AccountLifecycleException('unauthorized');
    }

    return const AccountLifecycleException('unknown');
  }

  @override
  String toString() => code;
}
