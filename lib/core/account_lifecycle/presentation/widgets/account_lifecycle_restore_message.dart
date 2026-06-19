import 'package:flutter/material.dart';
import 'package:nano_embryo/core/account_lifecycle/config/account_lifecycle_texts.dart';
import 'package:nano_embryo/core/account_lifecycle/data/account_lifecycle_models.dart';
import 'package:nano_embryo/presentation/home/widgets/semantic_container_widget.dart';

class AccountLifecycleRestoreMessage extends StatelessWidget {
  final AccountLifecycleProfile profile;
  final AccountLifecycleTexts texts;

  const AccountLifecycleRestoreMessage({
    super.key,
    required this.profile,
    required this.texts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final title = switch (profile.status) {
      AccountLifecycleStatus.pendingDelete => texts.pendingDeleteTitle,
      AccountLifecycleStatus.deleted => texts.deletedTitle,
      _ => texts.deactivatedTitle,
    };
    final body = switch (profile.status) {
      AccountLifecycleStatus.pendingDelete => texts.pendingDeleteBody(
        profile.deletionScheduledFor,
      ),
      AccountLifecycleStatus.deleted => texts.deletedBody,
      _ => texts.deactivatedBody,
    };
    final isDeleted = profile.status == AccountLifecycleStatus.deleted;
    final color = isDeleted ? colorScheme.error : colorScheme.primary;

    return SemanticContainerWidget(
      content: body,
      icon: Icons.lock_clock_outlined,
      title: title,
      backgroundColor: color.withOpacity(0.1),
      borderColor: color,
      iconColor: color,
      textTheme: theme.textTheme,
    );
  }
}
