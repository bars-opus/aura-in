// lib/features/booking/presentation/widgets/worker_selection/worker_avatar_chip.dart
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

/// A beautiful chip for displaying worker information with avatar.
///
/// Follows the design system with consistent spacing, typography,
/// and visual feedback for selection states.
///
/// ## Features
/// - Circular avatar with profile image or initials
/// - Worker name and specialty
/// - Selection state with checkmark
/// - Optional "unavailable" state with disabled styling
/// - Smooth animations on tap
///
/// ## Usage
/// ```dart
/// WorkerAvatarChip(
///   worker: worker,
///   isSelected: isSelected,
///   isAvailable: true,
///   onTap: () => selectWorker(worker),
/// )
/// ```
class WorkerAvatarChip extends StatelessWidget {
  final WorkerDTO worker;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback onTap;
   final VoidCallback? onRemove;
  final bool showSpecialty;
  final bool isSelecting;
  final bool isAddingWorkerToAppointment;

  const WorkerAvatarChip({
    Key? key,
    required this.worker,
    required this.isSelected,
    required this.isAvailable,
    required this.onTap,
    required this.isSelecting,
    this.showSpecialty = true,
    this.onRemove,
    this.isAddingWorkerToAppointment = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        CardInkWell(
          // elevation: 0,
          padding: const EdgeInsets.all(10),
          onTap: isAvailable ? onTap : null,
          margin: const EdgeInsets.all(0),
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(10.r),
          elevation: isSelected ? 2 : 1,
          child: ProfileHeader(
            enableOnProfileNavigatePressed: false,
            mode: ProfileHeaderMode.compact,
            textColor:
                isSelected ? colorScheme.onPrimary : colorScheme.onBackground,
            displayName: worker.name,
            userId: worker.id,
            avatarUrl: worker.profileImage,
            bio: "${worker.bio}\n${worker.specialties.take(2).join(' • ')}",
          ),
        ),
        Gap(10.h),
        if (onRemove != null)
          AppIconButton(
            icon: Icons.delete_outline,
            onPressed: onRemove,
            tooltip: 'Remove Worker',
            iconColor: Colors.red,
          ),

        if (isSelecting)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppTextButton(
                text: 'See profile',
                onPressed: isAvailable ? onTap : null,
                fontSize: 12.sp,
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 15.h,
                color: colorScheme.primary,
              ),
            ],
          ),
        if (isSelecting) Gap(10.h),
        if (isSelecting) AppDivider(),
        if (isSelecting) Gap(10.h),
      ],
    );
  }
}
