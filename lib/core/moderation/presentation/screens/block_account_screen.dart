import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/moderation/config/moderation_config.dart';
import 'package:nano_embryo/core/moderation/data/moderation_models.dart';
import 'package:nano_embryo/core/moderation/presentation/providers/moderation_provider.dart';
import 'package:nano_embryo/core/moderation/utils/moderation_error_message.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class BlockAccountScreen extends ConsumerStatefulWidget {
  const BlockAccountScreen({super.key, required this.target});

  final ModerationTarget target;

  @override
  ConsumerState<BlockAccountScreen> createState() => _BlockAccountScreenState();
}

class _BlockAccountScreenState extends ConsumerState<BlockAccountScreen> {
  final _reasonController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(moderationConfigProvider);
    final texts = config.texts(context);
    final state = ref.watch(moderationControllerProvider);
    final displayName = config.formatTarget(context, widget.target);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          texts.blockScreenTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SemanticContainerWidget(
            content: texts.blockScreenBody(displayName),
            icon: Icons.block,
            title: texts.blockActionLabel,
            backgroundColor: colorScheme.error.withOpacity(0.1),
            borderColor: colorScheme.error,
            iconColor: colorScheme.error,
            textTheme: theme.textTheme,
          ),

          Gap(Spacing.sm.h),
          AppTextFormField(
            controller: _reasonController,
            label: texts.blockReasonLabel,
            hintText: texts.blockReasonHint,
            minLines: 3,
            maxLines: 5,
            maxLength: config.maxBlockReasonLength,
          ),

          Gap(Spacing.md.h),

          AppButton(
            elevation: 0,
            label: texts.blockButton,
            onPressed: (state.isLoading || _submitting) ? null : _block,

            size: ButtonSize.small,
            width: double.infinity,
            padding: Spacing.horizontalMd,
            height: 40.h,
            isLoading: state.isLoading || _submitting,
          ),
          Gap(Spacing.xl.h),
        ],
      ),
    );
  }

  Future<void> _block() async {
    final config = ref.read(moderationConfigProvider);
    final texts = config.texts(context);
    if (_reasonController.text.length > config.maxBlockReasonLength) {
      config.error(context, texts.blockReasonTooLong);
      return;
    }

    setState(() => _submitting = true);
    try {
      final result = await ref
          .read(moderationControllerProvider.notifier)
          .blockUser(
            blockedUserId: widget.target.targetOwnerId,
            reason: _reasonController.text.trim(),
          );
      if (!mounted) return;
      if (!result.success) {
        config.error(context, texts.actionFailed);
        return;
      }
      config.success(context, texts.blockSuccess);
      context.pop();
    } catch (error) {
      if (mounted) {
        config.error(context, moderationErrorMessage(texts, error));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
