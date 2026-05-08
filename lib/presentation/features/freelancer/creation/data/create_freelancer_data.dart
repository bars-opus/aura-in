import 'package:nano_embryo/presentation/features/freelancer/creation/domain/models/freelancer_draft.dart';
import 'package:nano_embryo/presentation/features/settings/models/settings_config.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/widgets/section_status_indicator.dart';

/// Data source for freelancer creation sections

/// Data source for freelancer creation sections
class CreateFreelancerDataSource {
  static List<SettingsSection> getSettingsSections(
    BuildContext context,
    FreelancerDraft draft,
  ) {
    final theme = Theme.of(context);

    return [
      SettingsSection(
        id: 'profile',
        title: 'Profile Information',
        items: [
          SettingsConfig(
            id: 'basics',
            title: draft.name ?? 'Your Name',
            subtitle:
                draft.freelancerType != null
                    ? '${draft.freelancerType} • ${draft.toolIds.length} tools'
                    : 'Add your name, select your profession, and list your tools',
            icon: Icons.person,
            type: SettingsItemType.navigation,
            routeName: '/freelancerBasicsScreen',
            iconColor: Colors.grey,
            trailing: SectionStatusIndicator(
              isComplete: draft.isProfileComplete,
            ),
          ),
          SettingsConfig(
            id: 'location',
            title: 'Service Area',
            subtitle:
                draft.baseLatitude != null
                    ? '${draft.travelRadiusKm}km radius • ${draft.canTravel ? "Mobile" : "Fixed location"}'
                    : 'Set your base location and travel radius',
            icon: Icons.location_on,
            type: SettingsItemType.navigation,
            routeName: '/freelancerLocation',
            iconColor: Colors.grey,
            trailing: SectionStatusIndicator(
              isComplete: draft.isLocationComplete,
            ),
          ),
        ],
      ),
      SettingsSection(
        id: 'services',
        title: 'Services & Availability',
        items: [
          SettingsConfig(
            id: 'tools',
            title: '${draft.toolIds.length} Tools Selected',
            subtitle:
                draft.toolIds.isEmpty
                    ? 'Select the tools and equipment you use'
                    : '${draft.toolIds.length} tools selected',
            icon: Icons.build,
            type: SettingsItemType.navigation,
            routeName: '/freelancerToolsScreen',
            iconColor: Colors.grey,
            trailing: SectionStatusIndicator(
              isComplete: draft.toolIds.isNotEmpty,
            ),
          ),
          SettingsConfig(
            id: 'hours',
            title: 'Working Hours',
            subtitle:
                draft.openingHours.isEmpty
                    ? 'Set your availability schedule'
                    : '${draft.openingHours.where((h) => !h.isClosed).length} days available',
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
                    ? 'Add the services you offer (haircut, massage, etc.)'
                    : 'Tap to manage your service offerings',
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
        title: 'Contact & Social',
        items: [
          SettingsConfig(
            id: 'contact',
            title:
                draft.contacts.isNotEmpty
                    ? draft.contacts.first.value
                    : 'Contact Info',
            subtitle: 'Phone, email, WhatsApp',
            icon: Icons.phone,
            type: SettingsItemType.navigation,
            routeName: '/manageContacts',
            iconColor: Colors.grey,
            trailing: SectionStatusIndicator(
              isComplete: draft.isContactComplete,
            ),
          ),
          SettingsConfig(
            id: 'social',
            title: '${draft.socialLinks.length} Social Links',
            subtitle:
                draft.socialLinks.isEmpty
                    ? 'Connect your social profiles'
                    : 'Linked accounts',
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
        id: 'documents',
        title: 'Documents & Certifications',
        items: [
          SettingsConfig(
            id: 'certifications',
            title: '${draft.documents.length} Certifications',
            subtitle:
                draft.documents.isEmpty
                    ? 'Upload licenses, certifications, or insurance'
                    : '${draft.documents.length} documents uploaded',
            icon: Icons.description,
            type: SettingsItemType.navigation,
            routeName: '/manageDocuments',
            iconColor: Colors.grey,
            trailing: SectionStatusIndicator(
              isComplete: draft.isDocumentsComplete,
            ),
          ),
        ],
      ),
      SettingsSection(
        id: 'media',
        title: 'Portfolio Photos',
        items: [
          SettingsConfig(
            id: 'portfolio',
            title: '${draft.localImagePaths.length} Photos',
            subtitle:
                draft.localImagePaths.isEmpty
                    ? 'Add photos of your work (minimum 3)'
                    : '${draft.localImagePaths.length}/10 photos added',
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
