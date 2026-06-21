import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/account_lifecycle/config/feature/account_lifecycle_config.dart';
import 'package:nano_embryo/core/account_lifecycle/presentation/providers/account_lifecycle_provider.dart';
import 'package:nano_embryo/core/account_lifecycle/presentation/widgets/account_lifecycle_blockers_summary.dart';
import 'package:nano_embryo/core/account_lifecycle/presentation/widgets/account_lifecycle_confirmation_fields.dart';
import 'package:nano_embryo/core/account_lifecycle/presentation/widgets/account_lifecycle_state_views.dart';
import 'package:nano_embryo/core/account_lifecycle/utils/account_lifecycle_constants.dart';
import 'package:nano_embryo/core/account_lifecycle/utils/account_lifecycle_error_message.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class DeactivateAccountScreen extends ConsumerStatefulWidget {
  const DeactivateAccountScreen({super.key});

  @override
  ConsumerState<DeactivateAccountScreen> createState() =>
      _DeactivateAccountScreenState();
}

class _DeactivateAccountScreenState
    extends ConsumerState<DeactivateAccountScreen> {
  final _passwordController = TextEditingController();
  final _phraseController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _phraseController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(accountLifecycleConfigProvider);
    final texts = config.texts(context);
    final blockersAsync = ref.watch(accountLifecycleBlockersProvider);
    final state = ref.watch(accountLifecycleControllerProvider);
    final controller = ref.read(accountLifecycleControllerProvider.notifier);
    final usesPassword = controller.currentUserUsesPassword();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          texts.deactivateTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: blockersAsync.when(
        loading: () => const Center(child: CircularLoadingIndicator()),
        error:
            (error, _) => AccountLifecycleErrorView(
              title: texts.somethingWentWrong,
              message: texts.loadFailed,
            ),
        data: (blockers) {
          final blocked = blockers.hasBlockers;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SemanticContainerWidget(
                content: texts.deactivateWarningBody,
                icon: Icons.person_off_outlined,
                title: texts.deactivateWarningTitle,
                backgroundColor: colorScheme.warning.withOpacity(0.1),
                borderColor: colorScheme.warning,
                iconColor: colorScheme.warning,
                textTheme: theme.textTheme,
              ),

              const Gap(Spacing.md),
              AccountLifecycleBlockersSummary(blockers: blockers, texts: texts),
              if (!blocked) ...[
                const Gap(Spacing.md),
                AccountLifecycleConfirmationFields(
                  texts: texts,
                  usesPassword: usesPassword,
                  phrase: accountLifecycleDeactivatePhrase,
                  reasonMaxLength: config.reasonMaxLength,
                  passwordController: _passwordController,
                  phraseController: _phraseController,
                  reasonController: _reasonController,
                ),
                const Gap(Spacing.lg),

                AppButton(
                  elevation: 0,
                  label: texts.deactivateButton,
                  onPressed: state.isLoading ? null : _deactivate,
                  size: ButtonSize.small,
                  width: double.infinity,
                  padding: Spacing.horizontalMd,
                  height: 40.h,
                  isLoading: state.isLoading,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _deactivate() async {
    final config = ref.read(accountLifecycleConfigProvider);
    final texts = config.texts(context);
    final controller = ref.read(accountLifecycleControllerProvider.notifier);

    try {
      if (_reasonController.text.length > config.reasonMaxLength) {
        config.error(context, texts.reasonTooLong);
        return;
      }

      final phraseInput = _phraseController.text.trim().toUpperCase();

      if (controller.currentUserUsesPassword()) {
        if (_passwordController.text.isEmpty) {
          config.error(context, texts.passwordRequired);
          return;
        }
        await controller.confirmPassword(_passwordController.text);
      } else if (phraseInput != accountLifecycleDeactivatePhrase) {
        config.error(
          context,
          texts.phraseMismatch(accountLifecycleDeactivatePhrase),
        );
        return;
      }

      final result = await controller.deactivate(
        reason: _reasonController.text.trim(),
        confirmationPhrase:
            controller.currentUserUsesPassword() ? null : phraseInput,
      );
      if (!mounted) return;

      if (!result.success) {
        config.error(context, texts.actionBlocked);
        ref.invalidate(accountLifecycleBlockersProvider);
        return;
      }

      config.success(context, texts.deactivatedSuccess);
      await config.onDeactivated?.call(context, ref, result);
      if (mounted) context.go(config.restoreRoute);
    } catch (error) {
      if (mounted) {
        config.error(
          context,
          accountLifecycleErrorMessage(
            texts,
            error,
            phrase: accountLifecycleDeactivatePhrase,
          ),
        );
      }
    }
  }
}
