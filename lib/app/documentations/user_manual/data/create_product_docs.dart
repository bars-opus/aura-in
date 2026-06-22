import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';

class CreateProductDocs implements DocumentationModule {
  @override
  String getTitle(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return loc.docsCreateProductTitle;
  }

  @override
  String get id => 'sell_products';

  @override
  String getSubtitle(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return loc.docsCreateProductSubtitle;
  }

  @override
  IconData get icon => Icons.shopping_bag;

  @override
  int get order => 3;

  @override
  List<ManualSection> getSections(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
      // Section 1: Overview
      ManualSection(
        id: 'product_overview',
        title: loc.docsCreateProductOverview_title,
        subtitle: loc.docsCreateProductOverview_subtitle,
        icon: Icons.info_outline,
        category: 'Product Setup',
        order: 1,
        contents: [
          ManualContent(
            id: 'product_welcome',
            title: loc.docsCreateProductOverview_productWelcomeTitle,
            content: loc.docsCreateProductOverview_productWelcomeContent,
            numberPrefix: '1',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'phone_requirement',
            title: loc.docsCreateProductOverview_phoneRequirementTitle,
            content: loc.docsCreateProductOverview_phoneRequirementContent,
            numberPrefix: '2',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'add_phone_number',
            title: loc.docsCreateProductOverview_addPhoneNumberTitle,
            content: loc.docsCreateProductOverview_addPhoneNumberContent,
            numberPrefix: '3',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'why_phone_verified',
            title: loc.docsCreateProductOverview_whyPhoneVerifiedTitle,
            content: loc.docsCreateProductOverview_whyPhoneVerifiedContent,
            numberPrefix: '4',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'phone_important',
            title: '',
            content: loc.docsCreateProductOverview_phoneImportantContent,
            type: ManualContentType.important,
          ),
        ],
      ),

      // Section 2: Product Basics
      ManualSection(
        id: 'product_basics',
        title: loc.docsCreateProductBasics_title,
        subtitle: loc.docsCreateProductBasics_subtitle,
        icon: Icons.info,
        category: 'Product Setup',
        order: 2,
        contents: [
          ManualContent(
            id: 'product_name',
            title: loc.docsCreateProductBasics_productNameTitle,
            content: loc.docsCreateProductBasics_productNameContent,
            numberPrefix: '1',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'product_description',
            title: loc.docsCreateProductBasics_productDescriptionTitle,
            content: loc.docsCreateProductBasics_productDescriptionContent,
            numberPrefix: '2',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'category_selection',
            title: loc.docsCreateProductBasics_categorySelectionTitle,
            content: loc.docsCreateProductBasics_categorySelectionContent,
            numberPrefix: '3',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'product_condition',
            title: loc.docsCreateProductBasics_productConditionTitle,
            content: loc.docsCreateProductBasics_productConditionContent,
            numberPrefix: '4',
            type: ManualContentType.text,
          ),
        ],
      ),

      // Section 3: Pricing & Stock
      ManualSection(
        id: 'pricing_stock',
        title: loc.docsCreateProductPricingStock_title,
        subtitle: loc.docsCreateProductPricingStock_subtitle,
        icon: Icons.local_offer,
        category: 'Product Setup',
        order: 3,
        contents: [
          ManualContent(
            id: 'pricing',
            title: loc.docsCreateProductPricingStock_pricingTitle,
            content: loc.docsCreateProductPricingStock_pricingContent,
            numberPrefix: '1',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'currency',
            title: loc.docsCreateProductPricingStock_currencyTitle,
            content: loc.docsCreateProductPricingStock_currencyContent,
            numberPrefix: '2',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'stock_quantity',
            title: loc.docsCreateProductPricingStock_stockQuantityTitle,
            content: loc.docsCreateProductPricingStock_stockQuantityContent,
            numberPrefix: '3',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'stock_tip',
            title: '',
            content: loc.docsCreateProductPricingStock_stockTipContent,
            type: ManualContentType.tip,
          ),
        ],
      ),

      // Section 4: Photos
      ManualSection(
        id: 'product_photos',
        title: loc.docsCreateProductPhotos_title,
        subtitle: loc.docsCreateProductPhotos_subtitle,
        icon: Icons.photo,
        category: 'Product Setup',
        order: 4,
        contents: [
          ManualContent(
            id: 'photos_importance',
            title: loc.docsCreateProductPhotos_photosImportanceTitle,
            content: loc.docsCreateProductPhotos_photosImportanceContent,
            numberPrefix: '1',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'what_photos',
            title: loc.docsCreateProductPhotos_whatPhotosTitle,
            content: loc.docsCreateProductPhotos_whatPhotosContent,
            numberPrefix: '2',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsCreateProductPhotos_whatPhotosBullet1,
              loc.docsCreateProductPhotos_whatPhotosBullet2,
              loc.docsCreateProductPhotos_whatPhotosBullet3,
              loc.docsCreateProductPhotos_whatPhotosBullet4,
              loc.docsCreateProductPhotos_whatPhotosBullet5,
            ],
          ),
          ManualContent(
            id: 'photo_tips',
            title: loc.docsCreateProductPhotos_photoTipsTitle,
            content: loc.docsCreateProductPhotos_photoTipsContent,
            numberPrefix: '3',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'photo_count',
            title: loc.docsCreateProductPhotos_photoCountTitle,
            content: loc.docsCreateProductPhotos_photoCountContent,
            numberPrefix: '4',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'photo_honesty',
            title: '',
            content: loc.docsCreateProductPhotos_photoHonestyContent,
            type: ManualContentType.important,
          ),
        ],
      ),

      // Section 5: Active/Inactive
      ManualSection(
        id: 'product_status',
        title: loc.docsCreateProductStatus_title,
        subtitle: loc.docsCreateProductStatus_subtitle,
        icon: Icons.visibility,
        category: 'Product Setup',
        order: 5,
        contents: [
          ManualContent(
            id: 'active_product',
            title: loc.docsCreateProductStatus_activeProductTitle,
            content: loc.docsCreateProductStatus_activeProductContent,
            numberPrefix: '1',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'when_to_activate',
            title: loc.docsCreateProductStatus_whenToActivateTitle,
            content: loc.docsCreateProductStatus_whenToActivateContent,
            numberPrefix: '2',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'pause_listing',
            title: loc.docsCreateProductStatus_pauseListingTitle,
            content: loc.docsCreateProductStatus_pauseListingContent,
            numberPrefix: '3',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'active_tip',
            title: '',
            content: loc.docsCreateProductStatus_activeTipContent,
            type: ManualContentType.tip,
          ),
        ],
      ),

      // Section 6: FAQ
      ManualSection(
        id: 'product_faq',
        title: loc.docsCreateProductFaq_title,
        subtitle: loc.docsCreateProductFaq_subtitle,
        icon: Icons.help_outline,
        category: 'Help',
        order: 6,
        contents: [
          ManualContent(
            id: 'faq_how_long',
            title: loc.docsCreateProductFaq_howLongTitle,
            content: loc.docsCreateProductFaq_howLongContent,
            numberPrefix: '1',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'faq_payment',
            title: loc.docsCreateProductFaq_paymentTitle,
            content: loc.docsCreateProductFaq_paymentContent,
            numberPrefix: '2',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'faq_shipping',
            title: loc.docsCreateProductFaq_shippingTitle,
            content: loc.docsCreateProductFaq_shippingContent,
            numberPrefix: '3',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'faq_edit_after',
            title: loc.docsCreateProductFaq_editAfterTitle,
            content: loc.docsCreateProductFaq_editAfterContent,
            numberPrefix: '4',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'faq_reviews',
            title: loc.docsCreateProductFaq_reviewsTitle,
            content: loc.docsCreateProductFaq_reviewsContent,
            numberPrefix: '5',
            type: ManualContentType.text,
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
        id: 'faq_product_1',
        question: loc.docsCreateProductFaqModel_question1,
        answer: loc.docsCreateProductFaqModel_answer1,
        category: loc.docsCreateProductFaqModel_category1,
        order: 1,
      ),
      FAQModel(
        id: 'faq_product_2',
        question: loc.docsCreateProductFaqModel_question2,
        answer: loc.docsCreateProductFaqModel_answer2,
        category: loc.docsCreateProductFaqModel_category2,
        order: 2,
      ),
      FAQModel(
        id: 'faq_product_3',
        question: loc.docsCreateProductFaqModel_question3,
        answer: loc.docsCreateProductFaqModel_answer3,
        category: loc.docsCreateProductFaqModel_category3,
        order: 3,
      ),
      FAQModel(
        id: 'faq_product_4',
        question: loc.docsCreateProductFaqModel_question4,
        answer: loc.docsCreateProductFaqModel_answer4,
        category: loc.docsCreateProductFaqModel_category4,
        order: 4,
      ),
      FAQModel(
        id: 'faq_product_5',
        question: loc.docsCreateProductFaqModel_question5,
        answer: loc.docsCreateProductFaqModel_answer5,
        category: loc.docsCreateProductFaqModel_category5,
        order: 5,
      ),
      FAQModel(
        id: 'faq_product_6',
        question: loc.docsCreateProductFaqModel_question6,
        answer: loc.docsCreateProductFaqModel_answer6,
        category: loc.docsCreateProductFaqModel_category6,
        order: 6,
      ),
    ];
  }
}
