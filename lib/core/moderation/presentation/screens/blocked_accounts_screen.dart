import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/moderation/config/moderation_config.dart';
import 'package:nano_embryo/core/moderation/config/moderation_texts.dart';
import 'package:nano_embryo/core/moderation/data/moderation_models.dart';
import 'package:nano_embryo/core/moderation/presentation/providers/moderation_provider.dart';
import 'package:nano_embryo/core/moderation/utils/moderation_error_message.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class BlockedAccountsScreen extends ConsumerWidget {
  const BlockedAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(moderationConfigProvider);
    final texts = config.texts(context);
    final blockedAsync = ref.watch(blockedAccountsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          texts.blockedAccountsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),

      body: blockedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => Center(
              child: ErrorStateWidget(
                title: texts.somethingWentWrong,
                subtitle: texts.loadFailed,
                primaryActionLabel: texts.retryLabel,
                onPrimaryAction: () => ref.invalidate(blockedAccountsProvider),
              ),
            ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: EmptyStateWidget(
                icon: Icons.block,

                title: texts.blockedAccountsEmptyTitle,
                subtitle: texts.blockedAccountsEmptyBody,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final item = items[index];
              return _BlockedAccountTile(item: item);
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: items.length,
          );
        },
      ),
    );
  }
}

class _BlockedAccountTile extends ConsumerWidget {
  final ModerationBlockRecord item;

  const _BlockedAccountTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(moderationConfigProvider);
    final texts = config.texts(context);
    final state = ref.watch(moderationControllerProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              item.avatarUrl == null || item.avatarUrl!.isEmpty
                  ? null
                  : NetworkImage(item.avatarUrl!),
          child:
              item.avatarUrl == null || item.avatarUrl!.isEmpty
                  ? const Icon(Icons.person_outline)
                  : null,
        ),
        title: Text(item.displayName ?? item.username ?? item.blockedUserId),
        subtitle: Text(
          item.username == null || item.username!.isEmpty
              ? item.reason ?? ''
              : '@${item.username}',
        ),
        trailing: TextButton(
          onPressed:
              state.isLoading
                  ? null
                  : () => _unblock(context, ref, item, texts),
          child: Text(texts.unblockButton),
        ),
      ),
    );
  }

  Future<void> _unblock(
    BuildContext context,
    WidgetRef ref,
    ModerationBlockRecord item,
    ModerationTexts texts,
  ) async {
    final config = ref.read(moderationConfigProvider);
    try {
      final result = await ref
          .read(moderationControllerProvider.notifier)
          .unblockUser(blockedUserId: item.blockedUserId);
      if (!context.mounted) return;
      if (!result.success) {
        config.error(context, texts.actionFailed);
        return;
      }
      config.success(context, texts.unblockSuccess);
    } catch (error) {
      if (context.mounted) {
        config.error(context, moderationErrorMessage(texts, error));
      }
    }
  }
}
