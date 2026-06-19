import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/feedback/config/feedback_config.dart';
import 'package:nano_embryo/core/feedback/presentation/controllers/feedback_providers.dart';
import 'package:nano_embryo/core/feedback/presentation/widgets/feedback_type_selector.dart';
import 'package:nano_embryo/core/feedback/presentation/widgets/rate_this_app_tile.dart';
import 'package:nano_embryo/core/feedback/presentation/widgets/screenshot_picker_row.dart';
import 'package:nano_embryo/core/providers/media_%20service_providers.dart';
import 'package:nano_embryo/core/services/device_info_service.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _selectedTypeKey;
  final List<File> _screenshots = [];

  @override
  void initState() {
    super.initState();
    final config = ref.read(feedbackConfigProvider);
    _selectedTypeKey =
        config.types.isNotEmpty ? config.types.first.key : 'other';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickScreenshot() async {
    final source = await showModalBottomSheet<bool>(
      context: context,
      builder:
          (sheetCtx) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from gallery'),
                  onTap: () => Navigator.of(sheetCtx).pop(false),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a photo'),
                  onTap: () => Navigator.of(sheetCtx).pop(true),
                ),
              ],
            ),
          ),
    );
    if (source == null) return;

    final picker = ref.read(imagePickerServiceProvider);
    final file = await picker.pickImage(fromCamera: source);
    if (file == null) return;

    setState(() => _screenshots.add(file));
  }

  void _removeScreenshot(int index) {
    setState(() => _screenshots.removeAt(index));
  }

  Future<void> _submitFeedback(FeedbackConfig config) async {
    if (!_formKey.currentState!.validate()) return;

    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) {
      context.showErrorSnackbar('Please log in to submit feedback');
      return;
    }

    final controller = ref.read(feedbackControllerProvider(userId).notifier);
    final deviceInfo = await DeviceInfoService.getDeviceInfo();
    final appVersion = await DeviceInfoService.getAppVersion();

    final saved = await controller.submitFeedback(
      type: _selectedTypeKey,
      title: _titleController.text,
      description: _descriptionController.text,
      screenshots: _screenshots,
      deviceInfo: deviceInfo,
      appVersion: appVersion,
    );

    if (saved != null && mounted) {
      context.showSuccessSnackbar(config.thanksMessage);
      config.onSubmitted?.call(context, saved);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(feedbackConfigProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userId = ref.watch(currentUserProvider)?.id;
    final feedbackState =
        userId != null ? ref.watch(feedbackControllerProvider(userId)) : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          config.submitScreenTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: Spacing.allLg,
          child: ListView(
            children: [
              const RateThisAppTile(),
              Gap(Spacing.xl.h),
              FeedbackTypeSelector(
                options: config.types,
                selectedKey: _selectedTypeKey,
                onSelected: (key) => setState(() => _selectedTypeKey = key),
              ),
              CardInkWell(
                child: Column(
                  children: [
                    AppTextFormField(
                      controller: _titleController,
                      label: config.titleLabel,
                      hintText: config.titleHint,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        if (value.length > config.maxTitleLength) {
                          return 'Title must be less than ${config.maxTitleLength} characters';
                        }
                        return null;
                      },
                    ),
                    AppTextFormField(
                      controller: _descriptionController,
                      label: config.descriptionLabel,
                      hintText: config.descriptionHint,
                      maxLines: 6,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        if (value.length > config.maxDescriptionLength) {
                          return 'Description must be less than ${config.maxDescriptionLength} characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              if (config.enableScreenshots) ...[
                CardInkWell(
                  child: ScreenshotPickerRow(
                    screenshots: _screenshots,
                    maxScreenshots: config.maxScreenshots,
                    onAdd: _pickScreenshot,
                    onRemove: _removeScreenshot,
                  ),
                ),
              ],
              if (feedbackState?.errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(top: Spacing.sm.h),
                  child: SemanticContainerWidget(
                    content: "Your form is still here — nothing has been lost.",
                    icon: Icons.error_outline,
                    title: feedbackState!.errorMessage!,
                    backgroundColor: colorScheme.error.withOpacity(0.1),
                    borderColor: colorScheme.error,
                    iconColor: colorScheme.error,
                    textTheme: theme.textTheme,
                  ),
                ),
              if (feedbackState?.uploadProgress != null)
                Padding(
                  padding: EdgeInsets.only(top: Spacing.sm.h),
                  child: _UploadProgressRow(
                    uploaded: feedbackState!.uploadProgress!.uploaded,
                    total: feedbackState.uploadProgress!.total,
                  ),
                ),
              const Spacer(),
              Gap(Spacing.lg.h),
              AppButton(
                elevation: 0,
                label:
                    (feedbackState?.errorIsRetryable ?? false)
                        ? 'Try again'
                        : config.submitLabel,
                onPressed: () => _submitFeedback(config),

                size: ButtonSize.small,
                width: double.infinity,
                padding: Spacing.horizontalMd,
                height: 40.h,
              ),
              Gap(Spacing.xl.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadProgressRow extends StatelessWidget {
  final int uploaded;
  final int total;
  const _UploadProgressRow({required this.uploaded, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = total == 0 ? 0.0 : uploaded / total;
    return Semantics(
      liveRegion: true,
      label: 'Uploading screenshots: $uploaded of $total',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Uploading screenshots: $uploaded of $total',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          Gap(Spacing.xs.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 4.h,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
