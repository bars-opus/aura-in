// lib/features/freelancer/creation/presentation/screens/freelancer_tools_screen.dart
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/freelancer_creation_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/widgets/tool_checkbox_group.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';

class FreelancerToolsScreen extends ConsumerWidget {
  const FreelancerToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(freelancerCreationProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.neutral,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: Spacing.lg.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SemanticContainerWidget(
                    content:
                        'This helps clients understand what equipment you have available',
                    icon: FontAwesomeIcons.scissors,
                    title: 'Select your tools and equipment',
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    borderColor: colorScheme.primary,
                    iconColor: colorScheme.primary,
                    textTheme: theme.textTheme,
                  ),
                  Gap(Spacing.md.h),

                  ToolCheckboxGroup(
                    selectedToolIds: draft.toolIds,
                    onSelectionChanged: (toolIds) {
                      ref
                          .read(freelancerCreationProvider.notifier)
                          .updateTools(toolIds);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          draft.toolIds.isNotEmpty
              ? ShakeTransition(
                axis: Axis.vertical,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(Spacing.md.h),
                    child: AppButton(
                      elevation: 0,
                      label: 'working hours',
                      center: false,
                      iconData: Icons.schedule,
                      prefixIcon: Icons.arrow_circle_right_outlined,
                      prefixIconColor: colorScheme.background,
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/setHours');
                      },
                      size: ButtonSize.small,
                      width: double.infinity,
                      padding: Spacing.horizontalMd,
                      height: 40.h,
                    ),
                  ),
                ),
              )
              : SizedBox.shrink(),
    );
  }
}
