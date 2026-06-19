import 'package:flutter/material.dart';
import 'package:nano_embryo/core/moderation/config/moderation_texts.dart';
import 'package:nano_embryo/presentation/home/widgets/semantic_container_widget.dart';

class ModerationUnavailableWidget extends StatelessWidget {
  final ModerationTexts texts;

  const ModerationUnavailableWidget({super.key, required this.texts});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SemanticContainerWidget(
          content: texts.blockedUnavailableBody,
          icon: Icons.block,
          title: texts.blockedUnavailableTitle,
          backgroundColor: colorScheme.error.withOpacity(0.1),
          borderColor: colorScheme.error,
          iconColor: colorScheme.error,
          textTheme: theme.textTheme,
        ),

      ),
    );
  }
}
