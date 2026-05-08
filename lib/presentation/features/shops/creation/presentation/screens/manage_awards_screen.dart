// lib/features/shop/creation/presentation/screens/manage_awards_screen.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/award_display_card.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/awards_provider.dart';
import '../widgets/award_card.dart';
import '../widgets/add_award_modal.dart';

class ManageAwardsScreen extends ConsumerStatefulWidget {
  const ManageAwardsScreen({super.key});

  @override
  ConsumerState<ManageAwardsScreen> createState() => _ManageAwardsScreenState();
}

class _ManageAwardsScreenState extends ConsumerState<ManageAwardsScreen> {
  @override
  Widget build(BuildContext context) {
    final awards = ref.watch(awardsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.neutral,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          AppIconButton(icon: Icons.add, onPressed: _showAddAwardModal),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: Spacing.md.h),
        children: [
          SemanticContainerWidget(
            content:
                'Add awards, certifications, and recognitions to build trust with customers',
            icon: Icons.emoji_events,
            title: 'Showcase your achievements',
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            borderColor: colorScheme.primary,
            iconColor: colorScheme.primary,
            textTheme: theme.textTheme,
          ),
          Gap(Spacing.md.h),
          // Awards list
          Expanded(
            child:
                awards.isEmpty
                    ? _buildEmptyState()
                    :AwardDisplayCard(awards: awards,)
          ),
        ],
      ),
      bottomNavigationBar:
          awards.isEmpty
              ? null
              : SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(Spacing.md.h),
                  child: AppButton(
                    elevation: 0,
                    label: 'Continue to documents',
                    center: false,
                    iconData: Icons.description,
                    prefixIcon: Icons.arrow_circle_right_outlined,
                    prefixIconColor: colorScheme.background,
                    onPressed: _saveAndContinue,
                    size: ButtonSize.small,
                    width: double.infinity,
                    padding: Spacing.horizontalMd,
                    height: 40.h,
                  ),
                ),
              ),
    );
  }

  void _saveAndContinue() {
    Navigator.pop(context);
    context.push('/manageDocuments'); // Use your navigation method
  }

  Widget _buildEmptyState() {
    return Center(
      child: EmptyStateWidget(
        actionLabel: 'Add',
        onAction: _showAddAwardModal,
        icon: Icons.emoji_events_outlined,
        title: 'No awards yet',
        subtitle: 'Add awards and recognitions to stand out',
      ),
    );
  }

  void _showAddAwardModal() {
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      widget: AddAwardModal(
        onSave: (award) {
          ref.read(awardsProvider.notifier).addAward(award);
        },
      ),
    );
  }

}
