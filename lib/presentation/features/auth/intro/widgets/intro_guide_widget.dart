import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class IntroGuideWidget extends StatelessWidget {
  final DocumentationModule module;

  const IntroGuideWidget({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 250.w,
      height: 250.h,
      margin: EdgeInsets.only(right: Spacing.sm.w),
      child: InkWell(
        onTap: () {
          BottomSheetUtils.showDocumentationBottomSheet(
            context: context,
            showButtons: false,
            widget: DocumentationTabView(
              documentation: module.getSections(context),
              faqs: module.getFAQs(context),
              showDocumentationFirst: true,
            ),
          );
        },
        borderRadius: BorderRadius.circular(BorderRadiusTokens.lg),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.background,
            borderRadius: BorderRadius.all(Radius.circular(20.r)),
          ),
          padding: EdgeInsets.all(Spacing.xl.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.onBackground.withOpacity(.5),
                  ),
                ),
                child: Icon(
                  module.icon,
                  size: IconSizes.lg.h,
                  color: colorScheme.onBackground.withOpacity(.5),
                ),
              ),
              Gap(Spacing.md.h),
              // Title
              Text(
                module.getTitle(context),
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Gap(Spacing.xs.h),
              Expanded(
                child: Text(
                  module.getSubtitle(context),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onBackground.withOpacity(0.8),
                    fontSize: 12.sp,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
