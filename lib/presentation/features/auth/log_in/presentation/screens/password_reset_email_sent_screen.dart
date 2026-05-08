import 'package:nano_embryo/app/routing/routing_notifier.dart';
import 'package:nano_embryo/core/providers/routing_providers.dart';
import 'package:nano_embryo/presentation/features/auth/utility/auth_exports.dart';

class PasswordResetEmailSentScreen extends ConsumerStatefulWidget {
  final String email;

  const PasswordResetEmailSentScreen({super.key, required this.email});

  @override
  ConsumerState<PasswordResetEmailSentScreen> createState() =>
      _PasswordResetEmailSentScreenState();
}

class _PasswordResetEmailSentScreenState
    extends ConsumerState<PasswordResetEmailSentScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // When the user taps the reset link, the app receives a universal link
    // and RoutingNotifier sets isRecoveryMode = true. Auto-dismiss this sheet
    // so GoRouter can navigate cleanly to UpdatePasswordScreen.
    ref.listen<RoutingNotifier>(routingNotifierProvider, (_, next) {
      if (next.isRecoveryMode && mounted) {
        Navigator.pop(context);
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.neutral,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: AppIconButton(
          icon: Icons.close,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          Gap(Spacing.md),
          IconAvatar(
            icon: Icons.mark_email_unread_outlined,
            iconColor: colorScheme.primary,
            size: 100,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
            avatarRadiusSize: 100,
            circularRadius: 100.r,
          ),

          Gap(Spacing.lg),
          Text(
            'Check your email',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          Gap(Spacing.md),

          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'We sent a password reset link to ',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                TextSpan(
                  text: widget.email,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),

          Gap(Spacing.lg),

          AppButton(
            elevation: 0,
            height: 40.h,
            label: 'Back to sign in',
            onPressed: () {
              Navigator.pop(context);
              BottomSheetUtils.showDocumentationBottomSheet(
                context: context,
                widget: LoginScreen(isCreateAccount: false),
              );
            },
            textColor: colorScheme.onSurface,
            padding: Spacing.horizontalMd,
            size: ButtonSize.small,
            width: double.infinity,
            customColor: colorScheme.onSurface.withValues(alpha: 0.1),
          ),

          Gap(Spacing.lg),
          Text(
            'Tap the link in the email to set a new password. The link expires in 1 hour.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          Gap(Spacing.md),
        ],
      ),
    );
  }
}
