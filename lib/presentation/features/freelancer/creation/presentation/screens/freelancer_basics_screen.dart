// lib/features/freelancer/creation/presentation/screens/freelancer_basics_screen.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/freelancer_creation_provider.dart';
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

  final _specialtiesController = TextEditingController();
  final List<String> _specialtiesList = [];

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

    if (draft.specialties.isNotEmpty)
      _specialtiesList.addAll(draft.specialties);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _termsController.dispose();
    _specialtiesController.dispose();
    super.dispose();
  }

  void _addSpecialty() {
    final value = _specialtiesController.text.trim();
    if (value.isNotEmpty && !_specialtiesList.contains(value)) {
      setState(() {
        _specialtiesList.add(value);
        _specialtiesController.clear();
      });
      ref
          .read(freelancerCreationProvider.notifier)
          .updateProfile(specialties: _specialtiesList);
    }
  }

  void _removeSpecialty(int index) {
    setState(() {
      _specialtiesList.removeAt(index);
    });
    ref
        .read(freelancerCreationProvider.notifier)
        .updateProfile(specialties: _specialtiesList);
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

            CardInkWell(
              margin: EdgeInsets.only(bottom: Spacing.md.h), //
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Specialties', style: titleStyle),
                  Text(
                    'Add any specific skills or areas of expertise',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Gap(Spacing.sm.h),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextFormField(
                          controller: _specialtiesController,
                          hintText: 'e.g., Wedding Hair, Balayage, Deep Tissue',
                          // onSubmitted: (_) => _addSpecialty(),
                          label: '',
                        ),
                      ),
                      Gap(Spacing.sm.w),
                      IconButton(
                        onPressed: _addSpecialty,
                        icon: Icon(
                          Icons.add_circle,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  if (_specialtiesList.isNotEmpty) ...[
                    Gap(Spacing.sm.h),
                    Wrap(
                      spacing: Spacing.sm.w,
                      runSpacing: Spacing.sm.h,
                      children:
                          _specialtiesList.asMap().entries.map((entry) {
                            final index = entry.key;
                            final specialty = entry.value;
                            return Chip(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: colorScheme.outline.withOpacity(.3),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(
                                  BorderRadiusTokens.md.r,
                                ),
                              ),
                              label: Text(
                                specialty,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              onDeleted: () => _removeSpecialty(index),
                              deleteIcon: Icon(
                                Icons.close,
                                size: 10.h,
                                color: colorScheme.error,
                              ),
                            );
                          }).toList(),
                    ),
                  ],
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
