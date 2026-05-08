import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/bottom_sheet_utils.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/award_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/add_award_modal.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/award_card.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/awards_provider.dart';
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/award_dto.dart';

class AwardDisplayCard extends ConsumerWidget {
  // ✅ Changed to ConsumerWidget
  final List<AwardDTO> awards;

  const AwardDisplayCard({super.key, required this.awards});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Added ref
    return Column(
      children:
          awards.asMap().entries.map((entry) {
            final index = entry.key;
            final award = entry.value;
            return AwardCard(
              award: award,
              onEdit:
                  () =>
                      _editAward(context, ref, index), // ✅ Pass context and ref
              onDelete:
                  () => _deleteAward(
                    context,
                    ref,
                    index,
                  ), // ✅ Pass context and ref
              isDraggable: true,
            );
          }).toList(),
    );
  }

  void _editAward(BuildContext context, WidgetRef ref, int index) {
    final award = ref.read(awardsProvider)[index];

    BottomSheetUtils.showDocumentationBottomSheet(
      maxHeight: 600.h,
      context: context, // ✅ Pass context
      widget: AddAwardModal(
        initialAward: award,
        onSave: (updatedAward) {
          ref.read(awardsProvider.notifier).updateAward(index, updatedAward);
        },
      ),
    );
  }

  void _deleteAward(BuildContext context, WidgetRef ref, int index) {
    BottomSheetUtils.showDocumentationBottomSheet(
      maxHeight: 400.h,
      context: context, // ✅ Pass context
      widget: ConfirmationDialog(
        icon: Icons.delete,
        type: ConfirmationType.warning,
        title: 'Remove Award?',
        message: 'Are you sure you want to remove this award?',
        confirmText: 'Remove',
        onConfirm: () {
          ref.read(awardsProvider.notifier).removeAward(index);
          Navigator.pop(context); // ✅ Close the bottom sheet
        },
      ),
    );
  }
}
