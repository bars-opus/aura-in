import 'package:nano_embryo/core/providers/routing_providers.dart';
import 'package:nano_embryo/presentation/features/auth/utility/auth_exports.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

class UpdatePasswordScreen extends ConsumerStatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  ConsumerState<UpdatePasswordScreen> createState() =>
      _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends ConsumerState<UpdatePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdatePassword() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    final newPassword = _passwordController.text;
    setState(() => _isLoading = true);

    try {
      await ref.read(authOperationsProvider).updatePassword(newPassword);
      _passwordController.clear();
      _confirmPasswordController.clear();
      // Clear recovery mode BEFORE signOut so GoRouter doesn't redirect back
      // to this screen when the auth state change fires during signOut.
      ref.read(routingNotifierProvider).setRecoveryMode(false);
      await ref.read(authOperationsProvider).signOut();
    } on AuthException catch (e) {
      if (mounted) context.showErrorSnackbar(e.message);
      return;
    } catch (_) {
      if (mounted)
        context.showErrorSnackbar('Something went wrong. Please try again.');
      return;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    if (!mounted) return;
    context.showSuccessSnackbar('Password updated. Please sign in.');
    Navigator.pop(context);

    // Show LoginScreen sheet after this sheet closes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navKey =
          ref.read(appRouterProvider).routerDelegate.navigatorKey;
      final navContext = navKey.currentContext;
      if (navContext != null && navContext.mounted) {
        BottomSheetUtils.showDocumentationBottomSheet(
          context: navContext,
          widget: LoginScreen(isCreateAccount: false),
        );
      }
    });
  }

  String? _validatePassword(String? value) {
    if (!mounted) return null;
    final result = ValidationUtils.validatePassword(
      value,
      requirements: PasswordRequirements.medium,
    );
    final error = result.toErrorString();
    if (mounted) {
      setState(() {
        _passwordError = error;
        _isPasswordValid = error == null;
      });
    }
    return error;
  }

  String? _validateConfirmPassword(String? value) {
    if (!mounted) return null;
    String? error;
    if (value == null || value.isEmpty) {
      error = 'Please confirm your password';
    } else if (value != _passwordController.text) {
      error = 'Passwords do not match';
    }
    if (mounted) {
      setState(() {
        _confirmPasswordError = error;
        _isConfirmPasswordValid = error == null;
      });
    }
    return error;
  }

  void _showFieldFeedback(String field, String? error) {
    if (!mounted) return;
    if (error != null) {
      context.showErrorSnackbar('$field: $error');
    } else {
      context.showSuccessSnackbar(backgroundColor: Colors.green, '$field is valid');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final colorScheme = theme.colorScheme;

    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: Spacing.md),
        children: [
          const Gap(Spacing.sm),
          Text(
            'Create new password',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(Spacing.md),
          IconAvatar(
            icon: Icons.lock_outline,
            iconColor: colorScheme.primary,
            size: 100,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
            avatarRadiusSize: 100,
            circularRadius: 100.r,
          ),
          const Gap(Spacing.md),
          AppTextFormField(
            controller: _passwordController,
            label: loc.passwordTitle,
            hintText: loc.loginPasswordHint,
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            enabled: !_isLoading,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_passwordController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () =>
                        _showFieldFeedback(loc.passwordTitle, _passwordError),
                    child: Icon(
                      _isPasswordValid ? Icons.check_circle : Icons.error,
                      color: _isPasswordValid ? Colors.green : Colors.red,
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: colorScheme.primary,
                  ),
                  onPressed: _isLoading
                      ? null
                      : () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                ),
              ],
            ),
            validator: _validatePassword,
            onChanged: (value) {
              _validatePassword(value);
              _validateConfirmPassword(_confirmPasswordController.text);
            },
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.next,
          ),
          AppTextFormField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hintText: 'Please confirm your password',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            enabled: !_isLoading,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_confirmPasswordController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () => _showFieldFeedback(
                        'Confirm Password', _confirmPasswordError),
                    child: Icon(
                      _isConfirmPasswordValid
                          ? Icons.check_circle
                          : Icons.error,
                      color:
                          _isConfirmPasswordValid ? Colors.green : Colors.red,
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    color: colorScheme.primary,
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: _isLoading
                      ? null
                      : () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                ),
              ],
            ),
            validator: _validateConfirmPassword,
            onChanged: (value) => _validateConfirmPassword(value),
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleUpdatePassword(),
          ),
          const Gap(Spacing.md),
          AppButton(
            label: 'Update password',
            onPressed: _isLoading ? null : _handleUpdatePassword,
            isLoading: _isLoading,
            elevation: 1,
            size: ButtonSize.small,
            width: double.infinity,
            padding: Spacing.horizontalMd,
            height: 40.h,
          ),
          const Gap(Spacing.md),
        ],
      ),
    );
  }
}
