import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nano_embryo/core/feedback/config/feedback_config.dart';
import 'package:nano_embryo/core/feedback/domain/entities/feedback.dart'
    as fb;
import 'package:nano_embryo/core/feedback/presentation/controllers/feedback_controller.dart';
import 'package:nano_embryo/core/feedback/presentation/controllers/feedback_providers.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';

class FeedbackHistoryScreen extends ConsumerStatefulWidget {
  const FeedbackHistoryScreen({super.key});

  @override
  ConsumerState<FeedbackHistoryScreen> createState() =>
      _FeedbackHistoryScreenState();
}

class _FeedbackHistoryScreenState extends ConsumerState<FeedbackHistoryScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      final userId = ref.read(currentUserProvider)?.id;
      if (userId != null) {
        ref
            .read(feedbackControllerProvider(userId).notifier)
            .loadFeedbackHistory();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(feedbackConfigProvider);
    final userId = ref.watch(currentUserProvider)?.id;
    final state = userId != null
        ? ref.watch(feedbackControllerProvider(userId))
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(config.historyScreenTitle)),
      body: _buildBody(context, config, state),
    );
  }

  Widget _buildBody(
    BuildContext context,
    FeedbackConfig config,
    FeedbackState? state,
  ) {
    if (state == null) {
      return const Center(child: Text('Please log in to see your feedback.'));
    }
    if (state.isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.userFeedback.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(Spacing.lg.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 48.w,
                color: Theme.of(context).colorScheme.outline,
              ),
              Gap(Spacing.md.h),
              Text(
                "You haven't sent any feedback yet.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(Spacing.lg.w),
      itemCount: state.userFeedback.length,
      separatorBuilder: (_, _) => Gap(Spacing.sm.h),
      itemBuilder: (context, index) =>
          _FeedbackTile(feedback: state.userFeedback[index], config: config),
    );
  }
}

class _FeedbackTile extends StatelessWidget {
  final fb.Feedback feedback;
  final FeedbackConfig config;

  const _FeedbackTile({required this.feedback, required this.config});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final option = config.typeForKey(feedback.type);
    final date = DateFormat.yMMMd().add_jm().format(feedback.createdAt.toLocal());

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(Spacing.md.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (option.icon != null) ...[
                  Icon(option.icon, size: 18.w, color: theme.colorScheme.primary),
                  Gap(Spacing.xs.w),
                ],
                Text(option.label, style: theme.textTheme.bodySmall),
                const Spacer(),
                _StatusChip(status: feedback.status),
              ],
            ),
            Gap(Spacing.sm.h),
            Text(
              feedback.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(Spacing.xs.h),
            Text(
              feedback.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            Gap(Spacing.sm.h),
            Text(
              date,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final fb.FeedbackStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (status) {
      fb.FeedbackStatus.pending => Colors.orange,
      fb.FeedbackStatus.reviewed => theme.colorScheme.primary,
      fb.FeedbackStatus.implemented => Colors.green,
      fb.FeedbackStatus.rejected => Colors.redAccent,
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status.displayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
