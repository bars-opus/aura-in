import 'package:nano_embryo/presentation/features/auth/utility/auth_exports.dart';

class UsernameCreationScreen extends ConsumerStatefulWidget {
  const UsernameCreationScreen({super.key});

  @override
  ConsumerState<UsernameCreationScreen> createState() =>
      _UsernameCreationScreenState();
}

class _UsernameCreationScreenState
    extends ConsumerState<UsernameCreationScreen> {
  final _controller = TextEditingController();
  final _userNameFocusNode = FocusNode();

  // Local UI state
  String? _usernameError;
  bool _isChecking = false;
  bool _isAvailable = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // No need to initialize service here anymore
  }

  @override
  void dispose() {
    _userNameFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAvailability(String value) async {
    if (value.length < 3) {
      setState(() {
        _usernameError = 'Username must be at least 3 characters';
        _isAvailable = false;
        _isChecking = false;
      });
      return;
    }
    if (value.length > 30) {
      setState(() {
        _usernameError = 'Username must be at most 30 characters';
        _isAvailable = false;
        _isChecking = false;
      });
      return;
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      setState(() {
        _usernameError = 'Only letters, numbers, and underscores';
        _isAvailable = false;
        _isChecking = false;
      });
      return;
    }

    // All local validation passed — mark as checking and clear previous state.
    setState(() {
      _isChecking = true;
      _isAvailable = false;
      _usernameError = null;
    });

    try {
      // Use the pure UsernameService via provider
      final usernameService = ref.read(usernameServiceProvider);
      final isAvailable = await usernameService.isUsernameAvailable(value);

      if (mounted) {
        setState(() {
          _isChecking = false;
          _isAvailable = isAvailable;
          _usernameError = isAvailable ? null : 'Username already taken';
        });
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackbar(
          'Error checking availability. Please try again.',
        );

        setState(() {
          _isChecking = false;
          _isAvailable = false;
          _usernameError = 'Error checking availability. Please try again.';
        });
      }
    }
  }

  Future<void> _saveUsername() async {
    final username = _controller.text.trim();
    if (username.isEmpty || !_isAvailable) return;

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('No user logged in');

      final repo = ref.read(profileRepositoryProvider);
      // On cold-start the auth→null→user transition may not fire, so
      // _handleNewUser in app.dart might not have created the profile row.
      // Ensure it exists before updating.
      final existing = await repo.fetchProfile(user.id);
      if (existing == null) {
        await repo.createProfile(user.id);
      }
      await repo.updateUsername(user.id, username);

      // Invalidate profile provider to refresh data
      ref.invalidate(currentUserProfileProvider);

      if (mounted) {
        context.showSuccessSnackbar('Username saved successfully!');

        // Small delay for provider to update
        await Future.delayed(const Duration(milliseconds: 300));

        if (mounted) {
          // go() resets the GoRouter stack so the user can't back into createUsername
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackbar('Failed to save username: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final loc = AppLocalizations.of(context)!;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          'Choose username',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(Spacing.lg.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(Spacing.lg.h),
            Text(
              'This is how others will see you.\nYou can change it later.',
              style: textTheme.bodyMedium!.copyWith(
                color: colorScheme.onBackground,
              ),
            ),
            Gap(Spacing.md.h),
            AppTextFormField(
              controller: _controller,
              focusNode: _userNameFocusNode,
              label: 'Username',
              hintText: 'Enter a username',
              keyboardType: TextInputType.text,
              onChanged: _checkAvailability,
              onFieldSubmitted: (_) {
                if (_isAvailable && !_isSubmitting) {
                  _saveUsername();
                }
              },
              errorText: _usernameError,
              suffixIcon:
                  _isChecking
                      ? TextFieldLoadingIndicator()
                      : (_isAvailable
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null),
              autofillHints: const [AutofillHints.username],
              textInputAction: TextInputAction.done,
              enabled: !_isSubmitting,
            ),
            const Spacer(),
            AppButton(
              elevation: 0,
              label: loc.commonContinue,
              onPressed:
                  (_isAvailable && !_isSubmitting) ? _saveUsername : null,
              customColor:
                  _isAvailable ? colorScheme.primary : colorScheme.background,
              size: ButtonSize.small,
              width: double.infinity,
              padding: Spacing.horizontalMd,
              height: 40.h,
            ),
          ],
        ),
      ),
    );
  }
}
