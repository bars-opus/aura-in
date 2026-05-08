// lib/features/shop/creation/presentation/screens/manage_social_links_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/bottom_sheet_utils.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/widgets/buttons/app_button.dart';
import 'package:nano_embryo/core/widgets/buttons/app_text_button.dart';
import 'package:nano_embryo/core/widgets/feedback/confirmation_dialog.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/add_social_link_modal.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/display_shop_social_links.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/social_link_tile.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/social_links_provider.dart';
import 'package:nano_embryo/presentation/home/widgets/semantic_container_widget.dart';

class ManageSocialLinksScreen extends ConsumerStatefulWidget {
  const ManageSocialLinksScreen({super.key});

  @override
  ConsumerState<ManageSocialLinksScreen> createState() =>
      _ManageSocialLinksScreenState();
}

class _ManageSocialLinksScreenState
    extends ConsumerState<ManageSocialLinksScreen> {
  @override
  Widget build(BuildContext context) {
    // final draft = ref.watch(shopCreationProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final draft = ref.watch(shopCreationProvider);
    final socialLinks = ref.watch(socialLinksProvider);

    return Scaffold(
      backgroundColor: colorScheme.neutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [AppIconButton(icon: Icons.add, onPressed: _showAddLinkModal)],
      ),
      body: ListView(
        // physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: Spacing.md.h),
        children: [
          // Padding(
          //   padding: EdgeInsets.only(bottom: Spacing.xs.h),

          //   child: AppButton(
          //     elevation: 0,
          //     label: 'Add Social Link',
          //     onPressed: _showAddLinkModal,
          //     size: ButtonSize.small,
          //     width: double.infinity,
          //     padding: Spacing.horizontalMd,
          //     height: 40.h,
          //   ),
          // ),
          SemanticContainerWidget(
            content:
                'Add links to your social profiles to help customers find you',
            icon: Icons.share,
            title: 'Connect your social media',
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            borderColor: colorScheme.primary,
            iconColor: colorScheme.primary,
            textTheme: theme.textTheme,
          ),

          Gap(Spacing.md.h),

          // Social links list
          Expanded(
            child:
                socialLinks.isEmpty
                    ? _buildEmptyState()
                    : DisplayShopSocialLinks(
                      socialLinks: socialLinks,
                      isEditting: true,
                    ),
          ),

          // Add button
        ],
      ),
      bottomNavigationBar:
          socialLinks.isEmpty
              ? null
              : SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(Spacing.md.h),
                  child: AppButton(
                    elevation: 0,
                    label: 'Continue to awards',
                    onPressed: _saveAndContinue,
                    center: false,
                    iconData: Icons.emoji_events,
                    prefixIcon: Icons.arrow_circle_right_outlined,
                    prefixIconColor: colorScheme.background,
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
    context.push('/manageAwards'); // Use your navigation method
  }

  Widget _buildEmptyState() {
    return Center(
      child: EmptyStateWidget(
        actionLabel: 'Add',
        onAction: _showAddLinkModal,
        icon: Icons.share,
        title: 'No social links yet',
        subtitle: 'Add your Instagram, Facebook, or other profiles',
      ),
    );
  }

  void _showAddLinkModal() {
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      widget: AddSocialLinkModal(
        onSave: (link) {
          ref.read(socialLinksProvider.notifier).addLink(link);
        },
      ),
    );
  }
}
