// lib/features/auth/screens/login_screen.dart
import 'package:nano_embryo/presentation/features/auth/utility/auth_exports.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final bool isCreateAccount;

  const LoginScreen({super.key, this.isCreateAccount = false});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isEmailValid = false;

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;

  TabController? _tabController;
  int _currentTabIndex = 0;

  // Track if we're in signup mode

  // @override
  // void initState() {
  //   super.initState();
  //   _tabController = TabController(length: 2, vsync: this);

  //   // Listen to confirm password field to toggle signup mode
  // }

  @override
  void dispose() {
    // ✅ Only dispose YOUR controllers, not TabController
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  // ==================== VALIDATION METHODS ====================

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
    if (!mounted || !widget.isCreateAccount) return null;

    String? error;
    final loc = AppLocalizations.of(context);

    if (value == null || value.isEmpty) {
      error = loc?.commonPasswordConfirmRequired;
    } else if (value != _passwordController.text) {
      error = loc?.commonPasswordsDoNotMatch;
    }

    if (mounted) {
      setState(() {
        _confirmPasswordError = error;
        _isConfirmPasswordValid = error == null;
      });
    }

    return error;
  }

  // ==================== TAB NAVIGATION ====================
  void _moveToNextTab() {
    // ✅ Use tracked index, not controller
    if (!mounted) return;

    // If on email tab (index 0), validate before moving
    if (_currentTabIndex == 0) {
      final emailError = _validateEmail(_emailController.text);
      if (emailError != null) {
        if (mounted) {
          context.showErrorSnackbar(emailError);
        }
        return;
      }

      // Focus password field when moving to next tab
      _passwordFocusNode.requestFocus();
    }

    // If on password tab (index 1), validate before auth
    if (_currentTabIndex == 1) {
      _handleAuthAction();
      return;
    }

    if (mounted) {
      setState(() => _currentTabIndex = 1);
      _tabController?.animateTo(1);
    }
  }

  // ==================== AUTH ACTION ====================
  Future<void> _handleAuthAction() async {
    // Don't proceed if widget is disposed
    if (!mounted) return;

    final loc = AppLocalizations.of(context)!;

    // Validate all fields
    final emailError = _validateEmail(_emailController.text);
    final passwordError = _validatePassword(_passwordController.text);
    final confirmError =
        widget.isCreateAccount
            ? _validateConfirmPassword(_confirmPasswordController.text)
            : null;

    // Check if any errors
    if (emailError != null || passwordError != null || confirmError != null) {
      final error = emailError ?? passwordError ?? confirmError;
      if (mounted) {
        context.showErrorSnackbar(error!);
      }
      return;
    }

    final authUI = AuthUIService(context, ref);
    final isLoading = ref.read(isLoadingProvider);

    if (isLoading) {
      if (mounted) {
        context.showErrorSnackbar(loc.commonPleaseWait);
      }
      return;
    }

    try {
      if (widget.isCreateAccount) {
        // Sign Up with proper result handling
        final result = await authUI.signUpWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );

        if (mounted) {
          if (result.isSuccess) {
            if (result.requiresEmailVerification) {
              // Snackbar persists across GoRouter navigations (same root
              // ScaffoldMessenger), so no need for artificial delays between
              // showing it and navigating to /verifyEmail.
              context.showSuccessSnackbar(loc.authSignUpVerificationSent);
              context.go('/verifyEmail', extra: _emailController.text.trim());
            }
          } else {
            context.showErrorSnackbar(
              loc.authSignUpFailed(result.errorMessage ?? 'Unknown error'),
            );
          }
        }
      } else {
        // Login with proper result handling
        final result = await authUI.loginWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (mounted && result.isSuccess) {
          if (ModalRoute.of(context) is PopupRoute) {
            // Shown inside a bottom sheet — pop so the caller navigates.
            Navigator.pop(context);
          } else {
            // Full-page route — navigate immediately rather than waiting
            // for the router redirect (which holds until profile loads).
            context.go(RouteNames.home);
          }
        }
        // On failure, AuthUIService already showed the error + retry action.
        // No additional snackbar here to avoid stacking messages.
      }
    } catch (e) {
      // Catch any unexpected errors
      if (mounted) {
        context.showErrorSnackbar(loc.commonUnexpectedError);
      }
    }
  }

  // ==================== HELPER METHODS ====================

  void _showFieldFeedback(String field, String? error) {
    if (!mounted) return;

    final loc = AppLocalizations.of(context);

    if (error != null) {
      final message = '$field: $error';
      context.showErrorSnackbar(message);
    } else {
      final message = loc?.commonFieldIsValid(field) ?? '$field is valid';
      context.showSuccessSnackbar(backgroundColor: Colors.green, message);
    }
  }

  // ==================== BUILD METHOD ====================
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final isLoading = ref.watch(isLoadingProvider);

    return SafeArea(
      child: Form(
        key: _formKey, // Add Form widget with key
        child: TabsWithContent(
          showCloseIcon: true,
          appBartext: loc.commonContinue,
          appBarOnPressed: isLoading ? null : _moveToNextTab,
          onControllerCreated: (controller) => _tabController = controller,
          useNestedScrollMode: true,
          enableSwipe: false,
          scrollable: false,
          onTabChangeRequest: (fromIndex, toIndex) {
            // If moving from email tab (0) to password tab (1)
            if (fromIndex == 0 && toIndex == 1) {
              // Validate email first
              final emailError = _validateEmail(_emailController.text);
              if (emailError != null) {
                // Show error and prevent tab change
                if (mounted) {
                  context.showErrorSnackbar(emailError);
                  // Optional: Focus back on email field
                  _emailFocusNode.requestFocus();
                }
                return false; // ❌ Prevent tab change
              }
              return true; // ✅ Allow tab change
            }
            // If moving from password tab (1) to email tab (0) - always allow
            if (fromIndex == 1 && toIndex == 0) {
              return true; // ✅ Allow going back
            }
            // For any other tab changes (shouldn't happen with 2 tabs)
            return true;
          },

          onTabChanged: (index) {
            if (mounted) {
              setState(() => _currentTabIndex = index);
            }
            // return true;
          },
          tabs: [
            AppTabItem(
              label: loc.emailTitle,
              icon: _currentTabIndex == 0 ? Icons.email : Icons.email_outlined,
              content: _buildEmailContent(),
            ),
            AppTabItem(
              label: loc.passwordTitle,
              icon: _currentTabIndex == 1 ? Icons.lock : Icons.lock_outline,
              content: _buildPasswordContent(),
            ),
          ],
          initialIndex: 0,
          // onTabChanged: (index) => true,
          showContent: true,
        ),
      ),
    );
  }

  // ==================== EMAIL TAB CONTENT ====================
  Widget _buildEmailContent() {
    final loc = AppLocalizations.of(context)!;
    final isLoading = ref.watch(isLoadingProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          AppTextFormField(
            controller: _emailController,
            label: loc.loginEmailLabel,
            hintText: loc.loginEmailHint,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            focusNode: _emailFocusNode,
            enabled: !isLoading,
            onFieldSubmitted: (_) {
              _emailFocusNode.unfocus();
              _moveToNextTab();
            },
            // validator: _validateEmail,
            onChanged: (value) {
              _validateEmail(value);
            },
            // errorText: _emailError,
            suffixIcon:
                _emailController.text.isNotEmpty
                    ? GestureDetector(
                      onTap:
                          () => _showFieldFeedback(loc.emailTitle, _emailError),
                      child: Icon(
                        _isEmailValid ? Icons.check_circle : Icons.error,
                        color: _isEmailValid ? Colors.green : Colors.red,
                      ),
                    )
                    : null,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  // ==================== PASSWORD TAB CONTENT ====================
  Widget _buildPasswordContent() {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final isLoading = ref.watch(isLoadingProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Password Field
          AppTextFormField(
            controller: _passwordController,
            label: loc.passwordTitle,
            hintText: loc.loginPasswordHint,
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            enabled: !isLoading,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_passwordController.text.isNotEmpty)
                  GestureDetector(
                    onTap:
                        () => _showFieldFeedback(
                          loc.passwordTitle,
                          _passwordError,
                        ),
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
                  onPressed:
                      isLoading
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
              // Also re-validate confirm password if in signup mode
              if (widget.isCreateAccount) {
                _validateConfirmPassword(_confirmPasswordController.text);
              }
            },
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            focusNode: _passwordFocusNode,
            onFieldSubmitted: (_) => _handleAuthAction(),
          ),

          // Confirm Password Field (only shown in signup mode)
          if (widget.isCreateAccount) ...[
            // SizedBox(height: 16.h),
            AppTextFormField(
              controller: _confirmPasswordController,
              label: loc.commonConfirmPasswordLabel,
              hintText: loc.commonConfirmPasswordHint,
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,

              enabled: !isLoading,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_confirmPasswordController.text.isNotEmpty)
                    GestureDetector(
                      onTap:
                          () => _showFieldFeedback(
                            'Confirm Password',
                            // loc.confirmPasswordLabel,
                            _confirmPasswordError,
                          ),
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
                    onPressed:
                        isLoading
                            ? null
                            : () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                  ),
                ],
              ),
              validator: (value) => _validateConfirmPassword(value),
              onChanged: (value) {
                _validateConfirmPassword(value);
              },
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
              focusNode: _confirmPasswordFocusNode,
              onFieldSubmitted: (_) => _handleAuthAction(),
            ),
          ],

          Gap(Spacing.md.h),

          if (!widget.isCreateAccount)
            // Forgot Password Link
            HighlightedText(
              highlightFontColor: colorScheme.primary,
              baseFontColor: colorScheme.onBackground,
              baseFontSize: 12.sp,
              fullText:
                  '${loc.loginForgotPasswordPart1}${loc.loginForgotPasswordPart2}${loc.loginForgotPasswordPart3}',
              highlightedParts: [
                HighlightedPart(
                  text: loc.loginForgotPasswordPart2,
                  onTap: () {
                    if (isLoading) return;
                    // Capture router before popping — context may leave the
                    // tree if LoginScreen was shown inside a bottom sheet.
                    final router = GoRouter.of(context);
                    if (ModalRoute.of(context) is PopupRoute) {
                      Navigator.pop(context);
                    }
                    router.push(
                      RouteNames.forgotPassword,
                      extra: _emailController.text.trim(),
                    );
                  },
                ),
              ],
              textAlign: TextAlign.start,
            ),
        ],
      ),
    );
  }
}
