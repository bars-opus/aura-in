import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nano_embryo/core/account_lifecycle/config/feature/account_lifecycle_config.dart';
import 'package:nano_embryo/core/account_lifecycle/presentation/providers/account_lifecycle_provider.dart';
import 'package:nano_embryo/core/account_lifecycle/presentation/widgets/account_lifecycle_restore_message.dart';
import 'package:nano_embryo/core/account_lifecycle/presentation/widgets/account_lifecycle_state_views.dart';
import 'package:nano_embryo/core/account_lifecycle/utils/account_lifecycle_error_message.dart';

class RestoreAccountScreen extends ConsumerWidget {
  const RestoreAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(accountLifecycleConfigProvider);
    final texts = config.texts(context);
    final profileAsync = ref.watch(accountLifecycleProfileProvider);
    final state = ref.watch(accountLifecycleControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(texts.restoreTitle)),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => AccountLifecycleErrorView(
              title: texts.somethingWentWrong,
              message: texts.loadFailed,
            ),
        data: (profile) {
          if (profile == null) {
            return AccountLifecycleErrorView(
              title: texts.somethingWentWrong,
              message: texts.missingProfile,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AccountLifecycleRestoreMessage(profile: profile, texts: texts),
              const SizedBox(height: 24),
              if (profile.canRestore)
                FilledButton(
                  onPressed:
                      state.isLoading ? null : () => _restore(context, ref),
                  child:
                      state.isLoading
                          ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(texts.restoreButton),
                ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed:
                    state.isLoading ? null : () => _signOut(context, ref),
                child: Text(texts.logoutButton),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final config = ref.read(accountLifecycleConfigProvider);
    final texts = config.texts(context);
    try {
      final result =
          await ref.read(accountLifecycleControllerProvider.notifier).restore();
      if (!context.mounted) return;
      if (!result.success) {
        config.error(context, texts.restoreFailed);
        return;
      }
      config.success(context, texts.restoredSuccess);
      await config.onRestored?.call(context, ref, result);
      if (context.mounted) context.go(config.homeRoute);
    } catch (error) {
      if (context.mounted) {
        config.error(context, accountLifecycleErrorMessage(texts, error));
      }
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final config = ref.read(accountLifecycleConfigProvider);
    if (config.signOut != null) {
      await config.signOut!(context, ref);
      return;
    }
    await ref.read(accountLifecycleControllerProvider.notifier).signOut();
    if (context.mounted) context.go(config.introRoute);
  }
}
