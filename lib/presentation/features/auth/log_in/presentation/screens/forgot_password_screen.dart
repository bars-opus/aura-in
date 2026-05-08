import 'package:nano_embryo/presentation/features/auth/log_in/presentation/screens/password_reset_email_sent_screen.dart';
import 'package:nano_embryo/presentation/features/auth/utility/auth_exports.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _emailError;
  bool _isEmailValid = false;

  final _emailFocusNode = FocusNode();

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (!mounted) return null;

    final result = ValidationUtils.validateEmail(
      value,
      options: const EmailValidationOptions(
        checkDisposableDomains: true,
        allowPlusAlias: true,
      ),
    );

    final error = result.toErrorString();

    if (mounted) {
      setState(() {
        _emailError = error;
        _isEmailValid = error == null;
      });
    }

    return error;
  }

  Future<void> _handleSendResetEmail() async {
    if (_emailController.text.isEmpty) {
      context.showErrorSnackbar('Enter your email and try again');
      return;
    }
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);
    try {
      final authOps = ref.read(authOperationsProvider);
      await authOps.resetPassword(_emailController.text.trim());

      if (mounted) {
        Navigator.pop(context);
        BottomSheetUtils.showDocumentationBottomSheet(
          context: context,
          widget: PasswordResetEmailSentScreen(
            email: _emailController.text.trim(),
          ),
        );
        // context.go(
        //   RouteNames.passwordResetSentScreen,
        //   extra: _emailController.text.trim(),
        // );
      }
    } on AuthException catch (e) {
      if (mounted) context.showErrorSnackbar(e.message);
    } catch (_) {
      if (mounted)
        context.showErrorSnackbar('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showFieldFeedback(String field, String? error) {
    if (!mounted) return;

    final loc = AppLocalizations.of(context);

    if (error != null) {
      final message =
          //  loc != null
          //     ? '${loc.fieldValidationError(field)}: $error'
          //     :
          '$field: $error';
      context.showErrorSnackbar(message);
    } else {
      final message =
          //  loc != null
          //     ? '${loc.fieldValidationSuccess(field)}'
          //     :
          ' $field is valid';
      context.showSuccessSnackbar(backgroundColor: Colors.green, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

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
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Gap(Spacing.md),
            IconAvatar(
              icon: Icons.lock_reset_outlined,
              iconColor: colorScheme.primary,
              size: 100,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
              avatarRadiusSize: 100,

              circularRadius: 100.r,
            ),

            const Gap(Spacing.md),
            Text(
              'Forgot your password?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(12.h),
            Text(
              'Enter your email and we\'ll send you a link to reset your password.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(Spacing.md),

            AppTextFormField(
              controller: _emailController,
              label: loc.loginEmailLabel,
              hintText: loc.loginEmailHint,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              focusNode: _emailFocusNode,
              onFieldSubmitted: (_) {
                _emailFocusNode.unfocus();
                _handleSendResetEmail();
              },
              validator: _validateEmail,
              onChanged: (value) => _validateEmail(value),
              // errorText: _emailError,
              suffixIcon:
                  _emailController.text.isNotEmpty
                      ? GestureDetector(
                        onTap:
                            () =>
                                _showFieldFeedback(loc.emailTitle, _emailError),
                        child: Icon(
                          _isEmailValid ? Icons.check_circle : Icons.error,
                          color: _isEmailValid ? Colors.green : Colors.red,
                        ),
                      )
                      : null,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.done,
            ),
            const Gap(Spacing.xxl),
            AppButton(
                  label: 'Send reset link',
                  onPressed: _isLoading ? null : _handleSendResetEmail,
                  isLoading:  _isLoading,
                  elevation: 1,
                  size: ButtonSize.small,
                  width: double.infinity,
                  padding: Spacing.horizontalMd,
                  height: 40.h,
                ),

            Gap(16.h),
            TextButton(
              onPressed:
                  _isLoading
                      ? null
                      : () {
                        Navigator.pop(context);
                        BottomSheetUtils.showDocumentationBottomSheet(
                          context: context,
                          widget: LoginScreen(isCreateAccount: false),
                        );
                      },

              // => context.go(RouteNames.login),
              child: Text(
                'Back to sign in',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 14.sp,
                ),
              ),
            ),
            const Gap(Spacing.md),
          ],
        ),
      ),
    );
  }
}
