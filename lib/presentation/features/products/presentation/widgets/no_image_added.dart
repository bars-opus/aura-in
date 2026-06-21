import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class NoImageAdded extends StatelessWidget {
  const NoImageAdded({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150.h,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: .3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Gap(Spacing.md),
            Icon(Icons.image_outlined, size: 50.w, color: Colors.grey.shade400),
            Gap(Spacing.sm),
            Text(
              'No images added',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
            ),
            Text(
              'Tap "Add Image" to upload',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12.sp),
            ),
            Gap(Spacing.md),
          ],
        ),
      ),
    );
  }
}
