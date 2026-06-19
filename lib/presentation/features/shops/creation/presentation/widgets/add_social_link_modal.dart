// lib/features/shop/creation/presentation/widgets/add_social_link_modal.dart

import 'package:nano_embryo/presentation/features/auth/utility/auth_exports.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/utils/social_link_validator.dart';

class AddSocialLinkModal extends StatefulWidget {
  final Function(SocialLinkDraft) onSave;
  final SocialLinkDraft? initialLink;

  const AddSocialLinkModal({super.key, required this.onSave, this.initialLink});

  @override
  State<AddSocialLinkModal> createState() => _AddSocialLinkModalState();
}

class _AddSocialLinkModalState extends State<AddSocialLinkModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _urlController;
  SocialPlatform? _selectedPlatform;
  // Only for the chip-selection error — field errors are handled by Form validator.
  String? _platformError;
  bool _isUsernameMode = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialLink != null) {
      _selectedPlatform = widget.initialLink!.platform;
      _urlController = TextEditingController(text: widget.initialLink!.url);
    } else {
      _urlController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _autoSave() {
    if (widget.initialLink != null && _selectedPlatform != null) {
      final value = _urlController.text.trim();
      if (value.isNotEmpty) {
        final url = _buildUrl(value);
        final link = SocialLinkDraft(platform: _selectedPlatform!, url: url);
        if (link.validate() == null) {
          widget.onSave(link);
        }
      }
    }
  }

  String _buildUrl(String value) {
    if (_isUsernameMode && !value.startsWith('http')) {
      return SocialLinkValidator.buildUrl(value, _selectedPlatform!);
    }
    return value;
  }

  /// Returns the validator for the text field.
  /// Username mode → validate username format for the selected platform.
  /// URL mode → validate the URL matches the platform's expected domain.
  String? Function(String?)? _getValidator() {
    return (value) {
      if (value == null || value.isEmpty) return 'This field is required';
      if (_selectedPlatform == null) return 'Please select a platform first';

      if (_isUsernameMode) {
        return SocialLinkValidator.validateUsername(value, _selectedPlatform!);
      } else {
        return SocialLinkValidator.validateUrl(value, _selectedPlatform!);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: AppIconButton(
          icon: Icons.close,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          AppTextButton(
            text: widget.initialLink == null ? 'Add' : 'Save',
            onPressed: _submit,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Gap(Spacing.lg.h),

            Text(
              'Platform',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Gap(Spacing.sm.h),
            _buildPlatformSelector(),

            if (_platformError != null) ...[
              Gap(Spacing.xs.h),
              Text(
                _platformError!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],

            AppTextFormField(
              debounceDuration: const Duration(milliseconds: 300),
              onDebouncedChanged: (_) => _autoSave(),
              controller: _urlController,
              label: _isUsernameMode ? 'Username or URL' : 'URL',
              hintText: _getHint(),
              prefixIcon: _selectedPlatform?.icon ?? Icons.link,
              keyboardType:
                  _isUsernameMode ? TextInputType.text : TextInputType.url,
              validator: _getValidator(),
            ),

            Row(
              children: [
                Checkbox(
                  value: _isUsernameMode,
                  onChanged: (value) {
                    setState(() {
                      _isUsernameMode = value ?? true;
                      _urlController.clear();
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'Enter username instead of full URL',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),

            Gap(Spacing.xl.h),
            Gap(Spacing.lg.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformSelector() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return CardInkWell(
      margin: EdgeInsets.only(bottom: Spacing.md.h),
      child: Wrap(
        spacing: 5.w,
        runSpacing: .5.h,
        children:
            SocialPlatform.values.map((platform) {
              final isSelected = _selectedPlatform == platform;
              return AppFilterChip(
                avatarIcon: platform.icon,
                label: platform.displayName,
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedPlatform = selected ? platform : null;
                    _urlController.clear();
                    _platformError = null;
                  });
                },
                selectedColor: colorScheme.primary,
                backgroundColor: colorScheme.surface,
                labelColor: colorScheme.onSurface.withValues(alpha: 0.7),
                borderWidth: 0.3,
              );
            }).toList(),
      ),
    );
  }

  String _getHint() {
    if (_selectedPlatform == null) return 'Select a platform first';
    if (_isUsernameMode) {
      switch (_selectedPlatform!) {
        case SocialPlatform.instagram:
          return 'your_username (without @)';
        case SocialPlatform.twitter:
          return 'your_username (without @)';
        case SocialPlatform.tiktok:
          return 'your_username (without @)';
        case SocialPlatform.youtube:
          return 'yourchannel';
        case SocialPlatform.linkedin:
          return 'your-name';
        case SocialPlatform.facebook:
          return 'yourpage';
        case SocialPlatform.pinterest:
          return 'yourprofile';
        case SocialPlatform.snapchat:
          return 'your_username';
        case SocialPlatform.whatsapp:
          return '+1234567890 (with country code)';
        default:
          return 'Enter username or full URL';
      }
    }
    switch (_selectedPlatform!) {
      case SocialPlatform.instagram:
        return 'https://instagram.com/username';
      case SocialPlatform.twitter:
        return 'https://twitter.com/username';
      case SocialPlatform.tiktok:
        return 'https://tiktok.com/@username';
      case SocialPlatform.youtube:
        return 'https://youtube.com/@channel';
      case SocialPlatform.linkedin:
        return 'https://linkedin.com/in/name';
      case SocialPlatform.facebook:
        return 'https://facebook.com/page';
      case SocialPlatform.pinterest:
        return 'https://pinterest.com/profile';
      case SocialPlatform.snapchat:
        return 'https://snapchat.com/add/username';
      case SocialPlatform.whatsapp:
        return 'https://wa.me/1234567890';
      default:
        return 'https://...';
    }
  }

  void _submit() {
    if (_selectedPlatform == null) {
      setState(() => _platformError = 'Please select a platform');
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final url = _buildUrl(_urlController.text.trim());
    widget.onSave(SocialLinkDraft(platform: _selectedPlatform!, url: url));
    Navigator.pop(context);
  }
}
