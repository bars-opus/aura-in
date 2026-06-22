import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class GettingStartedDocs implements DocumentationModule {
  @override
  int get order => 1;

  @override
  String getTitle(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return loc.docsGettingStartedTitle;
  }

  @override
  String get id => 'getting_started';

  @override
  String getSubtitle(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return loc.docsGettingStartedSubtitle;
  }

  @override
  IconData get icon => Icons.rocket_launch;

  @override
  List<ManualSection> getSections(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
      // Section 1: What is Aura In?
      ManualSection(
        id: 'what_is_nanoembryo',
        title: loc.docsGettingStartedWhatIsNanoembryo_title,
        subtitle: loc.docsGettingStartedWhatIsNanoembryo_subtitle,
        icon: Icons.info_outline,
        category: 'Introduction',
        order: 1,
        contents: [
          ManualContent(
            id: 'welcome_intro',
            title: loc.docsGettingStartedWhatIsNanoembryo_welcomeIntroTitle,
            content: loc.docsGettingStartedWhatIsNanoembryo_welcomeIntroContent,
            numberPrefix: '1',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'who_uses_app',
            title: loc.docsGettingStartedWhatIsNanoembryo_whoUsesAppTitle,
            content: loc.docsGettingStartedWhatIsNanoembryo_whoUsesAppContent,
            numberPrefix: '2',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsGettingStartedWhatIsNanoembryo_whoUsesAppBullet1,
              loc.docsGettingStartedWhatIsNanoembryo_whoUsesAppBullet2,
              loc.docsGettingStartedWhatIsNanoembryo_whoUsesAppBullet3,
            ],
          ),
          ManualContent(
            id: 'how_it_works',
            title: loc.docsGettingStartedWhatIsNanoembryo_howItWorksTitle,
            content: loc.docsGettingStartedWhatIsNanoembryo_howItWorksContent,
            numberPrefix: '3',
            type: ManualContentType.text,
          ),
        ],
      ),

      // Section 2: Three Ways to Use Aura In
      ManualSection(
        id: 'three_user_types',
        title: loc.docsGettingStartedThreeUserTypes_title,
        subtitle: loc.docsGettingStartedThreeUserTypes_subtitle,
        icon: Icons.people,
        category: 'Getting Started',
        order: 2,
        contents: [
          ManualContent(
            id: 'option_customer',
            title: loc.docsGettingStartedThreeUserTypes_optionCustomerTitle,
            content: loc.docsGettingStartedThreeUserTypes_optionCustomerContent,
            numberPrefix: '1',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'guest_booking',
            title: loc.docsGettingStartedThreeUserTypes_guestBookingTitle,
            content: loc.docsGettingStartedThreeUserTypes_guestBookingContent,
            numberPrefix: '1b',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'option_provider',
            title: loc.docsGettingStartedThreeUserTypes_optionProviderTitle,
            content: loc.docsGettingStartedThreeUserTypes_optionProviderContent,
            numberPrefix: '2',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'option_seller',
            title: loc.docsGettingStartedThreeUserTypes_optionSellerTitle,
            content: loc.docsGettingStartedThreeUserTypes_optionSellerContent,
            numberPrefix: '3',
            type: ManualContentType.text,
          ),
        ],
      ),

      // Section 3: Key Features
      ManualSection(
        id: 'key_features',
        title: loc.docsGettingStartedKeyFeatures_title,
        subtitle: loc.docsGettingStartedKeyFeatures_subtitle,
        icon: Icons.stars,
        category: 'Getting Started',
        order: 3,
        contents: [
          ManualContent(
            id: 'features_overview',
            title: loc.docsGettingStartedKeyFeatures_featuresOverviewTitle,
            content: loc.docsGettingStartedKeyFeatures_featuresOverviewContent,
            numberPrefix: '1',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsGettingStartedKeyFeatures_featuresOverviewBullet1,
              loc.docsGettingStartedKeyFeatures_featuresOverviewBullet2,
              loc.docsGettingStartedKeyFeatures_featuresOverviewBullet3,
              loc.docsGettingStartedKeyFeatures_featuresOverviewBullet4,
              loc.docsGettingStartedKeyFeatures_featuresOverviewBullet5,
              loc.docsGettingStartedKeyFeatures_featuresOverviewBullet6,
              loc.docsGettingStartedKeyFeatures_featuresOverviewBullet7,
              loc.docsGettingStartedKeyFeatures_featuresOverviewBullet8,
              loc.docsGettingStartedKeyFeatures_featuresOverviewBullet9,
              loc.docsGettingStartedKeyFeatures_featuresOverviewBullet10,
            ],
          ),
        ],
      ),

      // Section 4: For Customers
      ManualSection(
        id: 'for_customers',
        title: loc.docsGettingStartedForCustomers_title,
        subtitle: loc.docsGettingStartedForCustomers_subtitle,
        icon: Icons.shopping_bag,
        category: 'Roles',
        order: 4,
        contents: [
          ManualContent(
            id: 'customer_start',
            title: loc.docsGettingStartedForCustomers_customerStartTitle,
            content: loc.docsGettingStartedForCustomers_customerStartContent,
            numberPrefix: '1',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'customer_features',
            title: loc.docsGettingStartedForCustomers_customerFeaturesTitle,
            content: loc.docsGettingStartedForCustomers_customerFeaturesContent,
            numberPrefix: '2',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsGettingStartedForCustomers_customerFeaturesBullet1,
              loc.docsGettingStartedForCustomers_customerFeaturesBullet2,
              loc.docsGettingStartedForCustomers_customerFeaturesBullet3,
              loc.docsGettingStartedForCustomers_customerFeaturesBullet4,
              loc.docsGettingStartedForCustomers_customerFeaturesBullet5,
              loc.docsGettingStartedForCustomers_customerFeaturesBullet6,
              loc.docsGettingStartedForCustomers_customerFeaturesBullet7,
              loc.docsGettingStartedForCustomers_customerFeaturesBullet8,
            ],
          ),
        ],
      ),
    ];
  }

  @override
  List<FAQModel> getFAQs(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
      FAQModel(
        id: 'faq_getting_started_1',
        question: loc.docsGettingStartedFaq1Q,
        answer: loc.docsGettingStartedFaq1A,
        category: 'Overview',
        order: 1,
      ),
      FAQModel(
        id: 'faq_getting_started_2',
        question: loc.docsGettingStartedFaq2Q,
        answer: loc.docsGettingStartedFaq2A,
        category: 'Pricing',
        order: 2,
      ),
      FAQModel(
        id: 'faq_getting_started_3',
        question: loc.docsGettingStartedFaq3Q,
        answer: loc.docsGettingStartedFaq3A,
        category: 'Roles',
        order: 3,
      ),
      FAQModel(
        id: 'faq_getting_started_4',
        question: loc.docsGettingStartedFaq4Q,
        answer: loc.docsGettingStartedFaq4A,
        category: 'Payments',
        order: 4,
      ),
      FAQModel(
        id: 'faq_getting_started_5',
        question: loc.docsGettingStartedFaq5Q,
        answer: loc.docsGettingStartedFaq5A,
        category: 'Security',
        order: 5,
      ),
    ];
  }
}
