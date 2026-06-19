import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/moderation/config/moderation_config.dart';
import 'package:nano_embryo/core/moderation/data/moderation_models.dart';
import 'package:nano_embryo/core/moderation/presentation/providers/moderation_provider.dart';
import 'package:nano_embryo/core/moderation/utils/moderation_error_message.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:uuid/uuid.dart';

class ReportTargetScreen extends ConsumerStatefulWidget {
  const ReportTargetScreen({super.key, required this.target});

  final ModerationTarget target;

  @override
  ConsumerState<ReportTargetScreen> createState() => _ReportTargetScreenState();
}

class _ReportTargetScreenState extends ConsumerState<ReportTargetScreen> {
  final _detailsController = TextEditingController();
  String? _selectedReasonKey;

  // Stable per-screen idempotency key. Reused across retries (network failure,
  // timeout) so the server can detect a replay and skip the duplicate insert.
  // Regenerated only after a confirmed success so a follow-up report from the
  // same screen still produces a new row.
  late String _idempotencyKey = const Uuid().v4();
  bool _submitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(moderationConfigProvider);
    final texts = config.texts(context);
    final state = ref.watch(moderationControllerProvider);
    final displayName = config.formatTarget(context, widget.target);
    final reasons = texts.reasonOptions();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          texts.reportScreenTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: ListView(
        padding: Spacing.pagePadding,
        children: [
          SemanticContainerWidget(
            content: texts.reportScreenBody(displayName),
            icon: Icons.flag_outlined,
            title: texts.reportActionLabel,
            backgroundColor: colorScheme.error.withOpacity(0.1),
            borderColor: colorScheme.error,
            iconColor: colorScheme.error,
            textTheme: theme.textTheme,
          ),
          Gap(Spacing.md.h),
          Text(
            texts.reportReasonLabel,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          Gap(Spacing.sm.h),
          CardInkWell(
            elevation: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...reasons.map(
                  (reason) => RadioListTile<String>(
                    title: Text(
                      reason.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    value: reason.key,
                    groupValue: _selectedReasonKey,
                    onChanged:
                        state.isLoading
                            ? null
                            : (value) {
                              setState(() {
                                _selectedReasonKey = value;
                              });
                            },
                    activeColor: colorScheme.primary,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
            ),
          ),
          AppTextFormField(
            controller: _detailsController,
            label: texts.reportDetailsLabel,
            hintText: texts.reportDetailsHint,
            minLines: 4,
            maxLines: 6,
          ),

          Gap(Spacing.sm.h),
          AppButton(
            elevation: 0,
            label: texts.reportButton,
            onPressed: (state.isLoading || _submitting) ? null : _submit,

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

  Future<void> _submit() async {
    final config = ref.read(moderationConfigProvider);
    final texts = config.texts(context);
    if ((_selectedReasonKey ?? '').isEmpty) {
      config.error(context, texts.reasonRequired);
      return;
    }
    if (_detailsController.text.length > config.maxReportDetailsLength) {
      config.error(context, texts.detailsTooLong);
      return;
    }

    setState(() => _submitting = true);
    try {
      final result = await ref
          .read(moderationControllerProvider.notifier)
          .submitReport(
            target: widget.target,
            reason: _selectedReasonKey!,
            details: _detailsController.text.trim(),
            clientIdempotencyKey: _idempotencyKey,
          );
      if (!mounted) return;
      if (!result.success) {
        config.error(context, texts.actionFailed);
        return;
      }
      // Rotate the key only after a confirmed write so a retry of the same
      // failed attempt re-uses the original key (server idempotency win).
      _idempotencyKey = const Uuid().v4();
      config.success(context, texts.reportSuccess);
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
