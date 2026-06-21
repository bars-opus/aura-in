import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/feedback/review/review_providers.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

/// Manual "Rate this app" entry point. Opens the store listing — NOT the
/// inline OS prompt — because Apple and Google forbid showing the inline
/// dialog from a user-initiated tap (it can only fire at OS-chosen moments).
///
/// Drop this on the feedback screen; loyal users who already love the app
/// can promote themselves to a public rating in two taps.
class RateThisAppTile extends ConsumerWidget {
  const RateThisAppTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return GestureDetector(
      onTap: () => ref.read(reviewPrompterProvider).openStoreListing(),
      child: SemanticContainerWidget(
        content: 'Tap here to rate and review us on the store',
        icon: Icons.star_rate_rounded,

        title: 'Enjoying the app?',
        backgroundColor: colorScheme.success.withOpacity(0.1),
        borderColor: colorScheme.success,
        iconColor: colorScheme.success,
        textTheme: theme.textTheme,
        trailingIcon: Icons.launch_outlined,
      ),
    );
  }
}
