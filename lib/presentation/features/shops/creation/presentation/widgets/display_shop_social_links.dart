import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/core/utils/bottom_sheet_utils.dart';
import 'package:nano_embryo/core/widgets/feedback/confirmation_dialog.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/add_social_link_modal.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/social_link_tile.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/social_links_provider.dart';

class DisplayShopSocialLinks extends ConsumerWidget {
  final List<SocialLinkDraft> socialLinks;
  final bool isEditting;
  const DisplayShopSocialLinks({
    super.key,
    required this.isEditting,
    required this.socialLinks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double height = isEditting ? 100.h : 79.h;
    return SizedBox(
      height: socialLinks.length * height,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: socialLinks.length,
        itemBuilder: (context, index) {
          final link = socialLinks[index];
          return SocialLinkTile(
            isDraggable: isEditting,
            link: link,
            onEdit: isEditting ? () => _editLink(context, ref, index) : null,
            onDelete:
                isEditting ? () => _deleteLink(context, ref, index) : null,
          );
        },
      ),
    );
  }

  void _editLink(BuildContext context, WidgetRef ref, int index) {
    final link = ref.read(socialLinksProvider)[index];
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      widget: AddSocialLinkModal(
        initialLink: link,
        onSave: (updatedLink) {
          ref.read(socialLinksProvider.notifier).updateLink(index, updatedLink);
        },
      ),
    );
  }

  void _deleteLink(BuildContext context, WidgetRef ref, int index) {
    BottomSheetUtils.showDocumentationBottomSheet(
      context: context,
      maxHeight: 400.h,
      widget: ConfirmationDialog(
        icon: Icons.delete,
        type: ConfirmationType.warning,
        title: 'Remove Link?',
        message: 'Are you sure you want to remove this social link?',
        confirmText: 'Remove',
        onConfirm: () {
          ref.read(socialLinksProvider.notifier).removeLink(index);
        },
      ),
    );
  }
}
