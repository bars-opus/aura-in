// lib/features/auth/screens/login_screen.dart
import 'package:nano_embryo/presentation/features/auth/log_in/presentation/screens/forgot_password_screen.dart';
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
      error =
          //  loc?.confirmPasswordRequired ??
          'Please confirm your password';
    } else if (value != _passwordController.text) {
      error =
          // loc?.passwordsDoNotMatch ??
          'Passwords do not match';
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
        context.showErrorSnackbar(
          'Please wait for current operation to complete',
        );
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
              await Future.delayed(const Duration(milliseconds: 500));
              context.showSuccessSnackbar(
                'Verification email sent! Please check your inbox.',
                // loc.verifyEmailSentMessage
              );
              await Future.delayed(const Duration(milliseconds: 1000));
              if (context.mounted) {
                // Navigate to verification screen with email
                context.go('/verifyEmail', extra: _emailController.text.trim());
              }
            }
          } else {
            context.showErrorSnackbar('Signup failed: ${result.errorMessage}');
          }
        }
      } else {
        // Login with proper result handling
        final result = await authUI.loginWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (mounted) {
          if (result.isSuccess) {
            context.showSuccessSnackbar('Login successful');
            // Dismiss if shown as a modal bottom sheet.
            // When LoginScreen is a full GoRouter page the router redirect
            // handles navigation and popping is not needed.
            if (mounted && ModalRoute.of(context) is PopupRoute) {
              Navigator.pop(context);
            }
          } else {
            // Show error if AuthUIService didn't (e.g., non-AuthException)
            if (result.errorMessage != null) {
              context.showErrorSnackbar(result.errorMessage!);
            }
          }
        }
      }
    } catch (e, stackTrace) {
      // Catch any unexpected errors
      if (mounted) {
        context.showErrorSnackbar(
          'An unexpected error occurred. Please try again.',
        );
      }
    }
  }

  // ==================== HELPER METHODS ====================

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

  // ==================== BUILD METHOD ====================
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // Watch auth state for automatic navigation
    // final user = ref.watch(authStateProvider);
    final error = ref.watch(authErrorProvider);
    final isLoading = ref.watch(isLoadingProvider);

    // Show error if any
    if (error != null && context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.showErrorSnackbar(error);
        ref.read(authErrorProvider.notifier).state = null;
      });
    }

    return Form(
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
            errorText: _passwordError,
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
              label: 'Confirm Password',

              // loc.confirmPasswordLabel,
              hintText: 'Please confirm your password',
              // loc.confirmPasswordHint,
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
              errorText: _confirmPasswordError,
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
                    Navigator.pop(context);
                    if (isLoading) return;
                    BottomSheetUtils.showDocumentationBottomSheet(
                      // maxHeight: 320.h,
                      context: context,
                      widget: ForgotPasswordScreen(),
                    );
                    // context.go(RouteNames.forgotPassword);
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
