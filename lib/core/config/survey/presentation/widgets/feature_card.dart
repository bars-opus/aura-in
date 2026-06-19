import 'package:nano_embryo/core/config/survey/config/survey_config.dart';
import 'package:nano_embryo/core/config/survey/domain/entities/survey_response.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class FeatureCard extends StatelessWidget {
  final SurveyFeature feature;
  final Sentiment? selectedSentiment;
  final ValueChanged<Sentiment> onSentimentSelected;

  const FeatureCard({
    super.key,
    required this.feature,
    required this.selectedSentiment,
    required this.onSentimentSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final isSelected = selectedSentiment != null;
    final colorScheme = theme.colorScheme;
    return CardInkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRowWidget(
            subtitle: feature.description,
            title: feature.title,
            icon: feature.icon,
            avatarRadius: 20.h,
            iconColor: colorScheme.onSurface,
            onTap: () {},
            disableTrailing: true,
            showAvatar: false,
            showDivider: false,
            showTrailingArrow: false,
          ),

          Gap(Spacing.md.h),
          Row(
            children: [
              _buildSentimentButton(
                context,
                Sentiment.like,
                'Like',
                Icons.favorite_border,
                Icons.favorite,
                colorScheme.error,
              ),
              Gap(Spacing.md.w),
              _buildSentimentButton(
                context,
                Sentiment.dislike,
                'Dislike',
                Icons.thumb_down_alt_outlined,
                Icons.thumb_down,
                colorScheme.onBackground,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentButton(
    BuildContext context,
    Sentiment sentiment,
    String label,
    IconData icon,
    IconData iconSelected,
    Color selectedColor,
  ) {
    final isActive = selectedSentiment == sentiment;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // a11y: announce the toggle state to screen readers and group the button
    // semantically. Without this, color/icon-only signaling fails WCAG 1.4.1.
    return Expanded(
      child: Semantics(
        button: true,
        toggled: isActive,
        label: '$label ${feature.title}',
        child: OutlinedButton.icon(
          onPressed: () => onSentimentSelected(sentiment),
          icon: Icon(
            isActive ? iconSelected : icon,
            size: 15.w,
            color:
                isActive
                    ? theme.colorScheme.background
                    : theme.colorScheme.onBackground,
          ),
          label: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color:
                  isActive
                      ? theme.colorScheme.background
                      : theme.colorScheme.onBackground,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: isActive ? selectedColor : null,
            foregroundColor: isActive ? theme.colorScheme.onPrimary : null,
            side: BorderSide(
              color:
                  isActive
                      ? selectedColor
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
            padding: EdgeInsets.symmetric(vertical: Spacing.xs.h),
          ),
        ),
      ),
    );
  }
}
