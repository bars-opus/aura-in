import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/config/survey/config/survey_config.dart';
import 'package:nano_embryo/core/config/survey/presentation/controllers/survey_providers.dart';
import 'package:nano_embryo/core/config/survey/presentation/widgets/feature_card.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';

class FeatureSurveyScreen extends ConsumerStatefulWidget {
  const FeatureSurveyScreen({super.key});

  @override
  ConsumerState<FeatureSurveyScreen> createState() =>
      _FeatureSurveyScreenState();
}

class _FeatureSurveyScreenState extends ConsumerState<FeatureSurveyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserResponses());
  }

  Future<void> _loadUserResponses() async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId != null) {
      await ref.read(surveyControllerProvider(userId).notifier).loadResponses();
    }
  }

  Future<void> _submitSurvey(SurveyConfig config) async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) {
      context.showErrorSnackbar('Please log in to submit feedback');
      return;
    }

    final controller = ref.read(surveyControllerProvider(userId).notifier);
    final responses = ref.read(surveyControllerProvider(userId)).responses;
    final success = await controller.submitAllResponses();

    if (success && mounted) {
      context.showSuccessSnackbar(config.thanksMessage);
      config.onSubmitted?.call(
        context,
        responses.map((k, v) => MapEntry(k, v.value)),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(surveyConfigProvider);
    final userId = ref.watch(currentUserProvider)?.id;
    final surveyState =
        userId != null ? ref.watch(surveyControllerProvider(userId)) : null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Feature Feedback',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body:
          surveyState?.isLoading == true
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(Spacing.md.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SemanticContainerWidget(
                            content: config.intro,
                            icon: Icons.thumb_up_alt,
                            title: config.headline,
                            backgroundColor: colorScheme.primary.withOpacity(
                              0.1,
                            ),
                            borderColor: colorScheme.primary,
                            iconColor: colorScheme.primary,
                            textTheme: theme.textTheme,
                          ),
                          Gap(Spacing.lg.h),
                          if (surveyState?.hasCompleted == true)
                            _CompletedBanner(text: config.completedBanner),
                          Gap(Spacing.sm.h),
                          Text(
                            config.featureSectionTitle,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final feature = config.features[index];
                      final currentSentiment =
                          surveyState?.responses[feature.key];
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Spacing.md.w,
                          // vertical: Spacing.xs.h,
                        ),
                        child: FeatureCard(
                          feature: feature,
                          selectedSentiment: currentSentiment,
                          onSentimentSelected: (sentiment) {
                            if (userId == null) return;
                            ref
                                .read(surveyControllerProvider(userId).notifier)
                                .setSentiment(feature.key, sentiment);
                          },
                        ),
                      );
                    }, childCount: config.features.length),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(Spacing.lg.w),
                      child: Column(
                        children: [
                          if (surveyState?.errorMessage != null)
                            Padding(
                              padding: EdgeInsets.only(bottom: Spacing.md.h),
                              child: SemanticContainerWidget(
                                content:
                                    'Your selections are still saved on this screen.',
                                icon: Icons.thumb_up_alt,
                                title: surveyState!.errorMessage!,
                                backgroundColor: colorScheme.error.withOpacity(
                                  0.1,
                                ),
                                borderColor: colorScheme.error,
                                iconColor: colorScheme.error,
                                textTheme: theme.textTheme,
                              ),
                            ),

                          AppButton(
                            elevation: 0,
                            label:
                                (surveyState?.errorIsRetryable ?? false)
                                    ? 'Try again'
                                    : (surveyState?.hasCompleted == true
                                        ? config.updateLabel
                                        : config.submitLabel),
                            onPressed: () => _submitSurvey(config),

                            size: ButtonSize.small,
                            width: double.infinity,
                            padding: Spacing.horizontalMd,
                            height: 40.h,
                          ),
                          Gap(Spacing.md.h),
                          Text(
                            config.privacyNote,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          Gap(Spacing.xl.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  final String text;
  const _CompletedBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    // liveRegion + label give screen readers the full status, so green color
    // is decorative-only (WCAG 1.4.1 — don't rely on color alone).
    return Semantics(
      liveRegion: true,
      label: 'Completed: $text',
      child: Container(
        padding: EdgeInsets.all(Spacing.sm.w),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 20.w),
            Gap(Spacing.sm.w),
            Expanded(
              child: Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.green[800]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
