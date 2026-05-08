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

  const ServiceWithRequirements({
    super.key,
    required this.service,
    required this.onRequirementsSaved,
    required this.isShopOwner,
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
              leftLabel: service.priceAtBooking.toString(),
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

  _buildRequirement(BuildContext context, bool hasRequirements) {
    return InfoRowWidget(
      subtitle:
          hasRequirements ? 'Special Requirements' : 'Add special requirements',
      title: hasRequirements ? service.specialRequirements! : '',
      icon: hasRequirements ? Icons.note_add : Icons.add,
      avatarRadius: 25.h,
      onTap: () {
        isShopOwner
            ? BottomSheetUtils.showDocumentationBottomSheet(
              context: context,
              widget: ReadAll(body: service.specialRequirements ?? ''),
            )
            : BottomSheetUtils.showDocumentationBottomSheet(
              context: context,
              widget: SpecialRequirementsBottomSheet(
                bookingServiceId: service.id,
                serviceName: service.serviceName ?? 'Service',
                initialRequirements: service.specialRequirements,
                onRequirementsSaved: onRequirementsSaved,
              ),
            );
      },
      showDivider: false,
      disableTrailing: true,
      showAvatar: false,
      showTrailingArrow: false,
    );
  }
}
