// lib/features/settings/data/settings_data.dart
import 'package:nano_embryo/presentation/features/settings/utility/settings_exports.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/shop_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/section_status_indicator.dart';

class CreateShopDataSource {
  static List<SettingsSection> getSettingsSections(
    BuildContext context,
    ShopDraft draft,
  ) {
    // final draft = ref.watch(shopCreationProvider);

    // Access localization for language prefence
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // Define sections data source (similar to your SettingsDataSource)
    return [
      SettingsSection(
        id: 'essentials',
        title: 'Essential Information',
        items: [
          SettingsConfig(
            id: 'basics',
            title: draft.shopName ?? 'Shop Name',
            subtitle:
                draft.shopType ??
                'Enter shop name, select shop type, and provide shop overview',
            icon: Icons.storefront_rounded,
            type: SettingsItemType.navigation,
            routeName: '/editBasics', // will implement later
            iconColor: Colors.grey,
            trailing: SectionStatusIndicator(
              isComplete: draft.isBasicsComplete,
            ),
          ),
          SettingsConfig(
            id: 'location',
            title: draft.address ?? 'Location',
            subtitle: draft.city ?? 'Add your shop address',
            icon: Icons.location_on,
            type: SettingsItemType.navigation,
            routeName: '/editLocation',
            onTap: () => context.push('/editLocation', extra: true),
            iconColor: Colors.grey,
            trailing: SectionStatusIndicator(
              isComplete: draft.isLocationComplete
            ),
          ),
        ],
      ),
      SettingsSection(
        id: 'services',
        title: 'Amenities, Appointment slots, & Opening hours',
        items: [
          SettingsConfig(
            id: 'amenities',
            title: '${draft.amenityIds.length} Amenities',
            subtitle:
                draft.amenityIds.isEmpty
                    ? 'Select what your shop offers'
                    : 'Selected',
            icon: Icons.emoji_objects,
            type: SettingsItemType.navigation,
            routeName: '/manageAmenities',
            iconColor: Colors.grey,
            trailing: SectionStatusIndicator(
              isComplete: draft.amenityIds.isNotEmpty,
            ),
          ),
          SettingsConfig(
            id: 'hours',
            title: 'Opening Hours',
            subtitle:
                draft.openingHours.isEmpty
                    ? 'Set your opening hours'
                    : '${draft.openingHours.where((h) => !h.isClosed).length} days open',
            icon: Icons.schedule,
            type: SettingsItemType.navigation,
            routeName: '/setHours',
            iconColor: Colors.grey,
            trailing: SectionStatusIndicator(isComplete: draft.isHoursComplete),
          ),
          SettingsConfig(
            id: 'services',
            title: '${draft.services.length} Services',
            subtitle:
                draft.services.isEmpty
                    ? 'Add your first appointment service slots for booking'
                    : 'Tap to manage',
            icon: Icons.content_cut,
            type: SettingsItemType.navigation,
            routeName: '/manageServices',
            iconColor: Colors.grey,
            trailing: SectionStatusIndicator(
              isComplete: draft.isServicesComplete,
            ),
          ),
        ],
      ),
      SettingsSection(
        id: 'contact',
        title: 'Contact Information',
        items: [
          SettingsConfig(
            id: 'contact',
            title: draft.phone ?? 'Phone',
            subtitle: draft.email ?? 'Add contact details',
            icon: Icons.phone,
            type: SettingsItemType.navigation,
            routeName: '/manageContacts',
            iconColor: Colors.grey,
            trailing: SectionStatusIndicator(
              isComplete: draft.isContactComplete,
            ),
          ),
          SettingsConfig(
            id: 'social_links',
            title: '${draft.socialLinks.length} Social Links',
            subtitle:
                draft.socialLinks.isEmpty
                    ? 'Connect your social profiles'
                    : 'Connected',
            icon: Icons.share,
            type: SettingsItemType.navigation,
            routeName: '/manageSocialLinks',
            iconColor: Colors.grey,
            trailing: SectionStatusIndicator(
              isComplete: draft.socialLinks.isNotEmpty,
            ),
          ),
        ],
      ),
      SettingsSection(
        id: 'Awards',
        title: 'Awards and recorgnitions',
        items: [
          SettingsConfig(
            id: 'awards',
            title: '${draft.awards.length} Awards',
            subtitle:
                draft.awards.isEmpty
                    ? 'Add your achievements'
                    : '${draft.awards.length} awards added',
            icon: Icons.emoji_events,
            type: SettingsItemType.navigation,
            routeName: '/manageAwards',
            iconColor: Colors.grey,
            trailing: SectionStatusIndicator(
              isComplete: draft.awards.isNotEmpty,
            ),
          ),
        ],
      ),
      SettingsSection(
        id: 'documents',
        title: 'Business Documents',
        items: [
          SettingsConfig(
            id: 'documents',
            title: '${draft.documents.length} Documents',
            subtitle:
                draft.documents.isEmpty
                    ? 'Upload licenses & certifications'
                    : '${draft.documents.length} documents uploaded',
            icon: Icons.description,
            type: SettingsItemType.navigation,
            routeName: '/manageDocuments',
            iconColor: Colors.grey,
            trailing: SectionStatusIndicator(
              isComplete: draft.documents.isNotEmpty,
            ),
          ),
        ],
      ),
      SettingsSection(
        id: 'media',
        title: 'Shop Photos',
        items: [
          SettingsConfig(
            id: 'media',
            title: '${draft.localImagePaths.length} Photos',
            subtitle:
                draft.localImagePaths.isEmpty
                    ? 'Add at least 3 photos'
                    : '${draft.localImagePaths.length}/5 photos',
            icon: Icons.photo_library,
            type: SettingsItemType.navigation,
            routeName: '/manageMedia',
            iconColor: Colors.grey,
            trailing: SectionStatusIndicator(isComplete: draft.isMediaComplete),
          ),
        ],
      ),
    ];
  }
}
