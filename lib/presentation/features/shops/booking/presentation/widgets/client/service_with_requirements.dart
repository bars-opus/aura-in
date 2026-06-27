import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/bottom_sheet_utils.dart';
import 'package:nano_embryo/core/utils/duration_utils.dart';
import 'package:nano_embryo/core/widgets/app_divider.dart';
import 'package:nano_embryo/core/widgets/info_row_widget.dart';
import 'package:nano_embryo/core/widgets/read_all.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/models/booking_service_model.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/widgets/client/client_service_table.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/widgets/client/special_requirements_bottomSheet.dart';

class ServiceWithRequirements extends StatelessWidget {
  final BookingServiceModel service;
  final VoidCallback onRequirementsSaved;
  final bool isShopOwner;
  final bool canEditSpecialRequirements;

  const ServiceWithRequirements({
    super.key,
    required this.service,
    required this.onRequirementsSaved,
    required this.isShopOwner,
    required this.canEditSpecialRequirements,
  });

  @override
  Widget build(BuildContext context) {
    final hasRequirements =
        service.specialRequirements != null &&
        service.specialRequirements!.isNotEmpty;

    return Column(
      children: [
        // Service Details Table
        ClientServiceTable(
          rows: [
            TableRowData(
              leftLabel: 'Service',
              leftValue: service.serviceName ?? '',
              rightLabel: 'Worker',
              rightValue: service.workerName ?? '',
            ),
            TableRowData(
              // Phase 17: priceAtBookingMinor is int kobo; display as major.
              leftLabel: (service.priceAtBookingMinor / 100).toString(),
              leftValue: '',
              rightLabel: DurationUtils.formatForDisplay(
                Duration(minutes: service.durationMinutes),
              ),
              rightValue: '',
            ),
          ],
        ),

        Gap(Spacing.sm.h),

        // Special Requirements Section
        if (isShopOwner && hasRequirements)
          _buildRequirement(context, hasRequirements),
        if (!isShopOwner) _buildRequirement(context, hasRequirements),
        AppDivider(),
      ],
    );
  }

  Widget _buildRequirement(BuildContext context, bool hasRequirements) {
    final canEdit = !isShopOwner && canEditSpecialRequirements;
    final canRead = hasRequirements && (!canEdit || isShopOwner);

    return InfoRowWidget(
      subtitle:
          hasRequirements
              ? 'Special Requirements'
              : canEdit
              ? 'Add special requirements'
              : 'No special requirements',
      title: hasRequirements ? service.specialRequirements! : '',
      icon:
          hasRequirements
              ? Icons.note_add
              : canEdit
              ? Icons.add
              : Icons.notes_outlined,
      avatarRadius: 25.h,
      onTap:
          canRead
              ? () {
                BottomSheetUtils.showDocumentationBottomSheet(
                  context: context,
                  widget: ReadAll(body: service.specialRequirements ?? ''),
                );
              }
              : canEdit
              ? () {
                BottomSheetUtils.showDocumentationBottomSheet(
                  context: context,
                  widget: SpecialRequirementsBottomSheet(
                    bookingServiceId: service.id,
                    serviceName: service.serviceName ?? 'Service',
                    initialRequirements: service.specialRequirements,
                    onRequirementsSaved: onRequirementsSaved,
                  ),
                );
              }
              : null,
      showDivider: false,
      disableTrailing: !canRead && !canEdit,
      showAvatar: false,
      showTrailingArrow: false,
    );
  }
}
