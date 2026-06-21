// lib/features/freelancer/creation/presentation/screens/freelancer_basics_screen.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/freelancer_creation_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/widgets/freelancer_tags_selector.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/widgets/freelancer_type_selector.dart';
import 'package:nano_embryo/presentation/features/profile/widgets/editable_profile_avatar.dart';

/// Screen for freelancer to enter basic profile information
/// Includes: name, bio, profile photo, profession type, tools
class FreelancerBasicsScreen extends ConsumerStatefulWidget {
  const FreelancerBasicsScreen({super.key});

  @override
  ConsumerState<FreelancerBasicsScreen> createState() =>
      _FreelancerBasicsScreenState();
}

class _FreelancerBasicsScreenState
    extends ConsumerState<FreelancerBasicsScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  final _termsController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final draft = ref.read(freelancerCreationProvider);
    if (draft.name != null) _nameController.text = draft.name!;
    if (draft.bio != null) _bioController.text = draft.bio!;

    if (draft.terms != null) _termsController.text = draft.terms!;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _termsController.dispose();
    super.dispose();
  }


  // void _saveAndContinue() {
  //   // Save name and bio
  //   ref
  //       .read(freelancerCreationProvider.notifier)
  //       .updateProfile(
  //         name: _nameController.text.trim(),
  //         bio: _bioController.text.trim(),
  //       );

  //   Navigator.pop(context);
  // }

  void _saveAndContinue() {
    Navigator.pop(context);
    context.push('/freelancerLocation'); // Use your navigation method
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(freelancerCreationProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    var titleStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface.withOpacity(0.8),
    );

    return Scaffold(
      backgroundColor: colorScheme.neutral,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Spacing.lg.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EditableProfileAvatar(
              currentAvatarUrl: draft.profileImagePath,
              onImagePicked: (file) {
                ref
                    .read(freelancerCreationProvider.notifier)
                    .updateProfile(profileImagePath: file.path);
              },
            ),
            Gap(Spacing.md.h),
            SemanticContainerWidget(
              content:
                  'Kindly upload a professional image of yourself as your profile image. Dont upload your logo or an abstact image.',
              icon: Icons.person,
              title: '',
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              borderColor: colorScheme.primary,
              iconColor: colorScheme.primary,
              textTheme: theme.textTheme,
            ),
            Gap(Spacing.md.h),
            // Name
            CardInkWell(
              margin: EdgeInsets.only(bottom: Spacing.md.h), //
              child: Column(
                children: [
                  AppTextFormField(
                    controller: _nameController,
                    label: 'Full Name',
                    hintText: 'Enter your name as clients will see it',
                    onChanged: (value) {
                      ref
                          .read(freelancerCreationProvider.notifier)
                          .updateProfile(name: value);
                    },
                  ),
                  // Bio
                  AppTextFormField(
                    controller: _bioController,
                    label: 'Bio',
                    hintText:
                        'Tell clients about your experience and expertise',
                    maxLines: 4,
                    onChanged: (value) {
                      ref
                          .read(freelancerCreationProvider.notifier)
                          .updateProfile(bio: value);
                    },
                  ),
                ],
              ),
            ),

            // Freelancer Type
            CardInkWell(
              margin: EdgeInsets.only(bottom: Spacing.md.h), //
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text('Professional', style: titleStyle),
                    ),
                    Gap(Spacing.sm.h),
                    FreelancerTypeSelector(
                      selectedType: draft.freelancerType,
                      onTypeSelected: (type) {
                        ref
                            .read(freelancerCreationProvider.notifier)
                            .updateFreelancerType(type);
                      },
                      allowMultiple: false,
                    ),
                  ],
                ),
              ),
            ),

            // Tags (stored in the `specialties` column; concept is "Tags").
            CardInkWell(
              margin: EdgeInsets.only(bottom: Spacing.md.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tags', style: titleStyle),
                  Text(
                    'Tag the services you offer so clients can find you',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Gap(Spacing.sm.h),
                  FreelancerTagsSelector(
                    selectedTags: draft.specialties,
                    onTagsChanged: (tags) {
                      ref
                          .read(freelancerCreationProvider.notifier)
                          .updateProfile(specialties: tags);
                    },
                  ),
                ],
              ),
            ),

            CardInkWell(
              margin: EdgeInsets.only(bottom: Spacing.md.h),
              child: AppTextFormField(
                controller: _termsController,
                label: 'Terms & Conditions',
                hintText: 'Cancellation policy, service terms, etc.',
                maxLines: 4,
                onChanged: (value) {
                  ref
                      .read(freelancerCreationProvider.notifier)
                      .updateTerms(value);
                },
              ),
            ),

            // Gap(Spacing.xl.h),

            // // Save Button
            // AppButton(
            //   label: 'Save & Continue',
            //   onPressed: _saveAndContinue,
            //   width: double.infinity,
            //   height: 48.h,
            // ),
            Gap(Spacing.xl.h),
          ],
        ),
      ),

      bottomNavigationBar:
          draft.isProfileComplete
              ? SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(Spacing.md.h),
                  child: AppButton(
                    elevation: 0,
                    label: 'Continue to location',
                    center: false,
                    iconData: Icons.location_on,
                    prefixIcon: Icons.arrow_circle_right_outlined,
                    prefixIconColor: colorScheme.background,
                    onPressed: _saveAndContinue,
                    size: ButtonSize.small,
                    width: double.infinity,
                    padding: Spacing.horizontalMd,
                    height: 40.h,
                  ),
                ),
              )
              : null,
    );
  }
}
