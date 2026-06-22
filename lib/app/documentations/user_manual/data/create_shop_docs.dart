import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';

class CreateShopDocs implements DocumentationModule {
  @override
  String getTitle(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return loc.docsCreateShopTitle;
  }

  @override
  String get id => 'create_shop';

  @override
  String getSubtitle(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return loc.docsCreateShopSubtitle;
  }

  @override
  IconData get icon => Icons.store;

  @override
  int get order => 1;

  @override
  List<ManualSection> getSections(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
      // Section 1: Shop Overview
      ManualSection(
        id: 'shop_overview',
        title: loc.docsCreateShopShopOverview_title,
        subtitle: loc.docsCreateShopShopOverview_subtitle,
        icon: Icons.info_outline,
        category: 'Shop Setup',
        order: 1,
        contents: [
          ManualContent(
            id: 'welcome_intro',
            title: loc.docsCreateShopShopOverview_welcomeIntroTitle,
            content: loc.docsCreateShopShopOverview_welcomeIntroContent,
            numberPrefix: '1',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'setup_steps_overview',
            title: loc.docsCreateShopShopOverview_setupStepsOverviewTitle,
            content: loc.docsCreateShopShopOverview_setupStepsOverviewContent,
            numberPrefix: '2',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsCreateShopShopOverview_setupStepsOverviewBullet1,
              loc.docsCreateShopShopOverview_setupStepsOverviewBullet2,
              loc.docsCreateShopShopOverview_setupStepsOverviewBullet3,
              loc.docsCreateShopShopOverview_setupStepsOverviewBullet4,
              loc.docsCreateShopShopOverview_setupStepsOverviewBullet5,
              loc.docsCreateShopShopOverview_setupStepsOverviewBullet6,
              loc.docsCreateShopShopOverview_setupStepsOverviewBullet7,
              loc.docsCreateShopShopOverview_setupStepsOverviewBullet8,
            ],
          ),
          ManualContent(
            id: 'save_progress_tip',
            title: '',
            content: loc.docsCreateShopShopOverview_saveProgressTipContent,
            type: ManualContentType.tip,
          ),
        ],
      ),

      // Section 2: Basic Info
      ManualSection(
        id: 'basic_info',
        title: loc.docsCreateShopBasicInfo_title,
        subtitle: loc.docsCreateShopBasicInfo_subtitle,
        icon: Icons.business,
        category: 'Shop Setup',
        order: 2,
        contents: [
          ManualContent(
            id: 'logo_section',
            title: loc.docsCreateShopBasicInfo_logoSectionTitle,
            content: loc.docsCreateShopBasicInfo_logoSectionContent,
            numberPrefix: '1',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'shop_name',
            title: loc.docsCreateShopBasicInfo_shopNameTitle,
            content: loc.docsCreateShopBasicInfo_shopNameContent,
            numberPrefix: '2',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'shop_type',
            title: loc.docsCreateShopBasicInfo_shopTypeTitle,
            content: loc.docsCreateShopBasicInfo_shopTypeContent,
            numberPrefix: '3',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsCreateShopBasicInfo_shopTypeBullet1,
              loc.docsCreateShopBasicInfo_shopTypeBullet2,
              loc.docsCreateShopBasicInfo_shopTypeBullet3,
              loc.docsCreateShopBasicInfo_shopTypeBullet4,
              loc.docsCreateShopBasicInfo_shopTypeBullet5,
            ],
          ),
          ManualContent(
            id: 'description',
            title: loc.docsCreateShopBasicInfo_descriptionTitle,
            content: loc.docsCreateShopBasicInfo_descriptionContent,
            numberPrefix: '4',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'terms_info',
            title: loc.docsCreateShopBasicInfo_termsInfoTitle,
            content: loc.docsCreateShopBasicInfo_termsInfoContent,
            numberPrefix: '5',
            type: ManualContentType.text,
          ),
        ],
      ),

      // Section 3: Location Setup
      ManualSection(
        id: 'location_setup',
        title: loc.docsCreateShopLocationSetup_title,
        subtitle: loc.docsCreateShopLocationSetup_subtitle,
        icon: Icons.location_on,
        category: 'Shop Setup',
        order: 3,
        contents: [
          ManualContent(
            id: 'location_intro',
            title: loc.docsCreateShopLocationSetup_locationIntroTitle,
            content: loc.docsCreateShopLocationSetup_locationIntroContent,
            numberPrefix: '1',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsCreateShopLocationSetup_locationIntroBullet1,
              loc.docsCreateShopLocationSetup_locationIntroBullet2,
              loc.docsCreateShopLocationSetup_locationIntroBullet3,
            ],
          ),
          ManualContent(
            id: 'location_accuracy',
            title: '',
            content: loc.docsCreateShopLocationSetup_locationAccuracyContent,
            type: ManualContentType.important,
          ),
          ManualContent(
            id: 'working_hours',
            title: loc.docsCreateShopLocationSetup_workingHoursTitle,
            content: loc.docsCreateShopLocationSetup_workingHoursContent,
            numberPrefix: '2',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'hours_example',
            title: loc.docsCreateShopLocationSetup_hoursExampleTitle,
            content: loc.docsCreateShopLocationSetup_hoursExampleContent,
            numberPrefix: '3',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'hours_tip',
            title: '',
            content: loc.docsCreateShopLocationSetup_hoursTipContent,
            type: ManualContentType.tip,
          ),
        ],
      ),

      // Section 4: Services Setup
      ManualSection(
        id: 'services_setup',
        title: loc.docsCreateShopServicesSetup_title,
        subtitle: loc.docsCreateShopServicesSetup_subtitle,
        icon: Icons.inventory_2,
        category: 'Shop Setup',
        order: 4,
        contents: [
          ManualContent(
            id: 'services_intro',
            title: loc.docsCreateShopServicesSetup_servicesIntroTitle,
            content: loc.docsCreateShopServicesSetup_servicesIntroContent,
            numberPrefix: '1',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'service_details',
            title: loc.docsCreateShopServicesSetup_serviceDetailsTitle,
            content: loc.docsCreateShopServicesSetup_serviceDetailsContent,
            numberPrefix: '2',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsCreateShopServicesSetup_serviceDetailsBullet1,
              loc.docsCreateShopServicesSetup_serviceDetailsBullet2,
              loc.docsCreateShopServicesSetup_serviceDetailsBullet3,
              loc.docsCreateShopServicesSetup_serviceDetailsBullet4,
              loc.docsCreateShopServicesSetup_serviceDetailsBullet5,
            ],
          ),
          ManualContent(
            id: 'pricing_tip',
            title: loc.docsCreateShopServicesSetup_pricingTipTitle,
            content: loc.docsCreateShopServicesSetup_pricingTipContent,
            numberPrefix: '3',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'duration_important',
            title: '',
            content: loc.docsCreateShopServicesSetup_durationImportantContent,
            type: ManualContentType.important,
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
        id: 'faq_shop_1',
        question: loc.docsCreateShopFaq1Q,
        answer: loc.docsCreateShopFaq1A,
        category: 'Getting Started',
        order: 1,
      ),
      FAQModel(
        id: 'faq_shop_2',
        question: loc.docsCreateShopFaq2Q,
        answer: loc.docsCreateShopFaq2A,
        category: 'Getting Started',
        order: 2,
      ),
      FAQModel(
        id: 'faq_shop_3',
        question: loc.docsCreateShopFaq3Q,
        answer: loc.docsCreateShopFaq3A,
        category: 'Management',
        order: 3,
      ),
      FAQModel(
        id: 'faq_shop_4',
        question: loc.docsCreateShopFaq4Q,
        answer: loc.docsCreateShopFaq4A,
        category: 'Team',
        order: 4,
      ),
    ];
  }
}
