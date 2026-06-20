// lib/features/shop/creation/presentation/screens/edit_basics_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/constants/shop_types.dart';
import 'package:nano_embryo/core/providers/profile_image_provider.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/profile/widgets/editable_profile_avatar.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';

class EditBasicsScreen extends ConsumerStatefulWidget {
  const EditBasicsScreen({super.key});

  @override
  ConsumerState<EditBasicsScreen> createState() => _EditBasicsScreenState();
}

class _EditBasicsScreenState extends ConsumerState<EditBasicsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _overviewController;
  late TextEditingController _termsController;
  String? _selectedType;
  // String? _selectedLuxuryLevel;

  final List<String> _shopTypes = ShopTypes.all;

  // final List<String> _luxuryLevels = [
  //   'Standard',
  //   'Premium',
  //   'Luxury',
  //   'UltraLuxury',
  // ];

  @override
  void initState() {
    super.initState();
    final draft = ref.read(shopCreationProvider);
    _nameController = TextEditingController(text: draft.shopName ?? '');
    _overviewController = TextEditingController(text: draft.overview ?? '');
    _termsController = TextEditingController(text: draft.terms ?? '');
    _selectedType = draft.shopType;
    // _selectedLuxuryLevel = draft.luxuryLevel;

    // profileImageProvider.selectedImage persists across the entire app lifetime.
    // A stale picked file from a previous session (or a profile-photo edit) would
    // take precedence over the shop's existing logo URL. Clear it so the avatar
    // falls through to NetworkImage/FileImage(currentAvatarUrl) correctly.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileImageProvider.notifier).clearSelectedImage();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _overviewController.dispose();
    _termsController.dispose();
    _disposeDebouncers();
    super.dispose();
  }

  void _disposeDebouncers() {
    // Override in child classes to dispose debouncers
  }

  @override
  Widget build(BuildContext context) {
    // Access theme for consistent styling
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final draft = ref.watch(shopCreationProvider);

    var titleStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface.withOpacity(0.8),
    );
    return Scaffold(
      backgroundColor: colorScheme.neutral,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(Spacing.md.h),
          children: [
            EditableProfileAvatar(
              currentAvatarUrl: draft.localLogoPath,
              size: 90,
              onImagePicked: (file) {
                ref.read(shopCreationProvider.notifier).updateLogo(file.path);
              },
            ),
            Gap(Spacing.sm.h),
            Center(
              child: Text(
                'Shop logo',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ),
            Gap(Spacing.md.h),
            CardInkWell(
              margin: EdgeInsets.only(
                bottom: Spacing.md.h,
              ), // No external margin (handled by padding)
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextFormField(
                    height: 40.h,
                    controller: _nameController,
                    debounceDuration: const Duration(milliseconds: 500),
                    onDebouncedChanged: (value) {
                      ref
                          .read(shopCreationProvider.notifier)
                          .updateBasics(
                            shopName: value,
                            shopType: _selectedType,
                            // luxuryLevel: _selectedLuxuryLevel,
                          );
                    },
                    label: 'Shop Name',
                    hintText: 'e.g., "Glamour Studio"',
                    prefixIcon: Icons.storefront,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Shop name is required';
                      }
                      if (value.length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  Gap(Spacing.lg.h),
                  Text('Shop Type', style: titleStyle),
                  Gap(Spacing.sm.h),
                  _buildTypeSelector(),
                  Gap(Spacing.md.h),
                ],
              ),
            ),
            CardInkWell(
              margin: EdgeInsets.only(
                bottom: Spacing.md.h,
              ), // No external margin (handled by padding)
              child: Column(
                children: [
                  AppTextFormField(
                    controller: _overviewController,
                    debounceDuration: const Duration(milliseconds: 500),
                    onDebouncedChanged: (value) {
                      ref
                          .read(shopCreationProvider.notifier)
                          .updateOverview(value);
                    },
                    label: 'Overview',
                    hintText: 'Describe your shop...',
                    prefixIcon: Icons.description,
                    maxLines: 3,
                  ),
                  Gap(Spacing.md.h),
                  // Terms
                  AppTextFormField(
                    controller: _termsController,
                    debounceDuration: const Duration(milliseconds: 500),
                    onDebouncedChanged: (value) {
                      ref
                          .read(shopCreationProvider.notifier)
                          .updateTerms(value);
                    },
                    label: 'Terms & Policies',
                    hintText: 'Cancellation policy, terms, etc.',
                    prefixIcon: Icons.gavel,
                    maxLines: 3,
                  ),
                  Gap(Spacing.sm.h),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          draft.isBasicsComplete
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
              : SizedBox.shrink(),
    );
  }

  Widget _buildTypeSelector() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Wrap(
      spacing: 3.w,
      runSpacing: 0.h,
      children:
          _shopTypes.map((type) {
            final isSelected =
                _selectedType ==
                type; // ✅ Use _selectedType, not _selectedLuxuryLevel
            return AppFilterChip(
              label: type,
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedType =
                      selected ? type : null; // ✅ Update _selectedType
                });
                // ✅ Auto-save immediately when shop type is selected
                ref
                    .read(shopCreationProvider.notifier)
                    .updateBasics(
                      shopName: _nameController.text,
                      shopType: _selectedType, // ✅ Use _selectedType
                      // luxuryLevel: _selectedLuxuryLevel,
                    );
              },
              selectedColor: colorScheme.primary,
              backgroundColor: colorScheme.background,
              labelColor: colorScheme.onSurface.withOpacity(0.7),
              borderWidth: 0.3,
            );
          }).toList(),
    );
  }

  void _saveAndContinue() {
    Navigator.pop(context);
    context.push('/editLocation'); // Use your navigation method
  }
}
