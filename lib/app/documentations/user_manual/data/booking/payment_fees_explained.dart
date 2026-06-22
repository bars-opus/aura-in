// lib/features/documentation/data/docs/booking_docs/payment_fees_explained.dart
import 'package:flutter/material.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';
import 'package:nano_embryo/app/documentations/user_manual/models/documentation_model.dart'
    show DocumentationModule;
import 'package:nano_embryo/app/documentations/user_manual/models/faq_model.dart';
import 'package:nano_embryo/app/documentations/user_manual/models/manual_content.dart';
import 'package:nano_embryo/app/documentations/user_manual/models/manual_section.dart';

class PaymentFeesExplainedDocs implements DocumentationModule {
  @override
  int get order => 3;

  @override
  String getTitle(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return loc.docsPaymentTitle;
  }

  @override
  String get id => 'paymentFeesExplained';

  @override
  String getSubtitle(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return loc.docsPaymentSubtitle;
  }

  @override
  IconData get icon => Icons.payment;

  @override
  List<ManualSection> getSections(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
    ManualSection(
      id: 'payment_overview',
      title: loc.docsPaymentFeesExplainedPaymentOverview_title,
      subtitle: loc.docsPaymentFeesExplainedPaymentOverview_subtitle,
      icon: Icons.account_balance_wallet,
      category: 'Payment',
      order: 1,
      contents: [
        ManualContent(
          id: 'payment_summary',
          title: loc.docsPaymentFeesExplainedPaymentSummary_title,
          content: loc.docsPaymentFeesExplainedPaymentSummary_content,
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsPaymentFeesExplainedPaymentSummary_bullet1,
            loc.docsPaymentFeesExplainedPaymentSummary_bullet2,
            loc.docsPaymentFeesExplainedPaymentSummary_bullet3,
            loc.docsPaymentFeesExplainedPaymentSummary_bullet4,
          ],
        ),
        ManualContent(
          id: 'payment_example_quick',
          title: loc.docsPaymentFeesExplainedPaymentExampleQuick_title,
          content: loc.docsPaymentFeesExplainedPaymentExampleQuick_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'payment_important',
          title: '',
          content: loc.docsPaymentFeesExplainedPaymentImportant_content,
          type: ManualContentType.important,
        ),
        ManualContent(
          id: 'guest_booking_note',
          title: loc.docsPaymentFeesExplainedGuestBookingNote_title,
          content: loc.docsPaymentFeesExplainedGuestBookingNote_content,
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
      ],
    ),
    ManualSection(
      id: 'deposit_explained',
      title: loc.docsPaymentFeesExplainedDepositExplained_title,
      subtitle: loc.docsPaymentFeesExplainedDepositExplained_subtitle,
      icon: Icons.lock,
      category: 'Payment',
      order: 2,
      contents: [
        ManualContent(
          id: 'deposit_why',
          title: loc.docsPaymentFeesExplainedDepositWhy_title,
          content: loc.docsPaymentFeesExplainedDepositWhy_content,
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsPaymentFeesExplainedDepositWhy_bullet1,
            loc.docsPaymentFeesExplainedDepositWhy_bullet2,
            loc.docsPaymentFeesExplainedDepositWhy_bullet3,
          ],
        ),
        ManualContent(
          id: 'deposit_calculation',
          title: loc.docsPaymentFeesExplainedDepositCalculation_title,
          content: loc.docsPaymentFeesExplainedDepositCalculation_content,
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsPaymentFeesExplainedDepositCalculation_bullet1,
            loc.docsPaymentFeesExplainedDepositCalculation_bullet2,
            loc.docsPaymentFeesExplainedDepositCalculation_bullet3,
          ],
        ),
        ManualContent(
          id: 'deposit_examples',
          title: loc.docsPaymentFeesExplainedDepositExamples_title,
          content: loc.docsPaymentFeesExplainedDepositExamples_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'deposit_non_refundable',
          title: loc.docsPaymentFeesExplainedDepositNonRefundable_title,
          content: loc.docsPaymentFeesExplainedDepositNonRefundable_content,
          numberPrefix: '3',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsPaymentFeesExplainedDepositNonRefundable_bullet1,
            loc.docsPaymentFeesExplainedDepositNonRefundable_bullet2,
            loc.docsPaymentFeesExplainedDepositNonRefundable_bullet3,
            loc.docsPaymentFeesExplainedDepositNonRefundable_bullet4,
          ],
        ),
        ManualContent(
          id: 'deposit_warning',
          title: '',
          content: loc.docsPaymentFeesExplainedDepositWarning_content,
          type: ManualContentType.warning,
        ),
      ],
    ),
    ManualSection(
      id: 'platform_fee',
      title: loc.docsPaymentFeesExplainedPlatformFee_title,
      subtitle: loc.docsPaymentFeesExplainedPlatformFee_subtitle,
      icon: Icons.apps,
      category: 'Payment',
      order: 3,
      contents: [
        ManualContent(
          id: 'fee_what',
          title: loc.docsPaymentFeesExplainedFeeWhat_title,
          content: loc.docsPaymentFeesExplainedFeeWhat_content,
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsPaymentFeesExplainedFeeWhat_bullet1,
            loc.docsPaymentFeesExplainedFeeWhat_bullet2,
            loc.docsPaymentFeesExplainedFeeWhat_bullet3,
            loc.docsPaymentFeesExplainedFeeWhat_bullet4,
          ],
        ),
        ManualContent(
          id: 'fee_how',
          title: loc.docsPaymentFeesExplainedFeeHow_title,
          content: loc.docsPaymentFeesExplainedFeeHow_content,
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsPaymentFeesExplainedFeeHow_bullet1,
            loc.docsPaymentFeesExplainedFeeHow_bullet2,
            loc.docsPaymentFeesExplainedFeeHow_bullet3,
            loc.docsPaymentFeesExplainedFeeHow_bullet4,
          ],
        ),
        ManualContent(
          id: 'fee_examples',
          title: loc.docsPaymentFeesExplainedFeeExamples_title,
          content: loc.docsPaymentFeesExplainedFeeExamples_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'fee_tip',
          title: '',
          content: loc.docsPaymentFeesExplainedFeeTip_content,
          type: ManualContentType.tip,
        ),
      ],
    ),
    ManualSection(
      id: 'remaining_payment',
      title: loc.docsPaymentFeesExplainedRemainingPayment_title,
      subtitle: loc.docsPaymentFeesExplainedRemainingPayment_subtitle,
      icon: Icons.payments,
      category: 'Payment',
      order: 4,
      contents: [
        ManualContent(
          id: 'remaining_overview',
          title: loc.docsPaymentFeesExplainedRemainingOverview_title,
          content: loc.docsPaymentFeesExplainedRemainingOverview_content,
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsPaymentFeesExplainedRemainingOverview_bullet1,
            loc.docsPaymentFeesExplainedRemainingOverview_bullet2,
          ],
        ),
        ManualContent(
          id: 'remaining_cash',
          title: loc.docsPaymentFeesExplainedRemainingCash_title,
          content: loc.docsPaymentFeesExplainedRemainingCash_content,
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsPaymentFeesExplainedRemainingCash_bullet1,
            loc.docsPaymentFeesExplainedRemainingCash_bullet2,
            loc.docsPaymentFeesExplainedRemainingCash_bullet3,
            loc.docsPaymentFeesExplainedRemainingCash_bullet4,
          ],
        ),
        ManualContent(
          id: 'remaining_app',
          title: loc.docsPaymentFeesExplainedRemainingApp_title,
          content: loc.docsPaymentFeesExplainedRemainingApp_content,
          numberPrefix: '3',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsPaymentFeesExplainedRemainingApp_bullet1,
            loc.docsPaymentFeesExplainedRemainingApp_bullet2,
            loc.docsPaymentFeesExplainedRemainingApp_bullet3,
            loc.docsPaymentFeesExplainedRemainingApp_bullet4,
            loc.docsPaymentFeesExplainedRemainingApp_bullet5,
          ],
        ),
        ManualContent(
          id: 'remaining_choice',
          title: loc.docsPaymentFeesExplainedRemainingChoice_title,
          content: loc.docsPaymentFeesExplainedRemainingChoice_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'remaining_important',
          title: '',
          content: loc.docsPaymentFeesExplainedRemainingImportant_content,
          type: ManualContentType.important,
        ),
      ],
    ),
    ManualSection(
      id: 'payment_timing',
      title: loc.docsPaymentFeesExplainedPaymentTiming_title,
      subtitle: loc.docsPaymentFeesExplainedPaymentTiming_subtitle,
      icon: Icons.timeline,
      category: 'Payment',
      order: 5,
      contents: [
        ManualContent(
          id: 'timeline_at_booking',
          title: loc.docsPaymentFeesExplainedTimelineAtBooking_title,
          content: loc.docsPaymentFeesExplainedTimelineAtBooking_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'timeline_before',
          title: loc.docsPaymentFeesExplainedTimelineBefore_title,
          content: loc.docsPaymentFeesExplainedTimelineBefore_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'timeline_after',
          title: loc.docsPaymentFeesExplainedTimelineAfter_title,
          content: loc.docsPaymentFeesExplainedTimelineAfter_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'timeline_summary',
          title: loc.docsPaymentFeesExplainedTimelineSummary_title,
          content: loc.docsPaymentFeesExplainedTimelineSummary_content,
          type: ManualContentType.text,
        ),
      ],
    ),
    ManualSection(
      id: 'cancellation_refunds',
      title: loc.docsPaymentFeesExplainedCancellationRefunds_title,
      subtitle: loc.docsPaymentFeesExplainedCancellationRefunds_subtitle,
      icon: Icons.cancel,
      category: 'Payment',
      order: 6,
      contents: [
        ManualContent(
          id: 'cancel_client',
          title: loc.docsPaymentFeesExplainedCancelClient_title,
          content: loc.docsPaymentFeesExplainedCancelClient_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'cancel_no_show',
          title: loc.docsPaymentFeesExplainedCancelNoShow_title,
          content: loc.docsPaymentFeesExplainedCancelNoShow_content,
          type: ManualContentType.warning,
        ),
        ManualContent(
          id: 'cancel_shop',
          title: loc.docsPaymentFeesExplainedCancelShop_title,
          content: loc.docsPaymentFeesExplainedCancelShop_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'cancel_reschedule',
          title: loc.docsPaymentFeesExplainedCancelReschedule_title,
          content: loc.docsPaymentFeesExplainedCancelReschedule_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'cancel_tip',
          title: '',
          content: loc.docsPaymentFeesExplainedCancelTip_content,
          type: ManualContentType.tip,
        ),
      ],
    ),
    ManualSection(
      id: 'group_payment',
      title: loc.docsPaymentFeesExplainedGroupPayment_title,
      subtitle: loc.docsPaymentFeesExplainedGroupPayment_subtitle,
      icon: Icons.group,
      category: 'Payment',
      order: 7,
      contents: [
        ManualContent(
          id: 'group_deposit',
          title: loc.docsPaymentFeesExplainedGroupDeposit_title,
          content: loc.docsPaymentFeesExplainedGroupDeposit_content,
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsPaymentFeesExplainedGroupDeposit_bullet1,
            loc.docsPaymentFeesExplainedGroupDeposit_bullet2,
            loc.docsPaymentFeesExplainedGroupDeposit_bullet3,
          ],
        ),
        ManualContent(
          id: 'group_fee',
          title: loc.docsPaymentFeesExplainedGroupFee_title,
          content: loc.docsPaymentFeesExplainedGroupFee_content,
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsPaymentFeesExplainedGroupFee_bullet1,
            loc.docsPaymentFeesExplainedGroupFee_bullet2,
            loc.docsPaymentFeesExplainedGroupFee_bullet3,
          ],
        ),
        ManualContent(
          id: 'group_remaining',
          title: loc.docsPaymentFeesExplainedGroupRemaining_title,
          content: loc.docsPaymentFeesExplainedGroupRemaining_content,
          numberPrefix: '3',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsPaymentFeesExplainedGroupRemaining_bullet1,
            loc.docsPaymentFeesExplainedGroupRemaining_bullet2,
            loc.docsPaymentFeesExplainedGroupRemaining_bullet3,
          ],
        ),
        ManualContent(
          id: 'group_cancellation',
          title: loc.docsPaymentFeesExplainedGroupCancellation_title,
          content: loc.docsPaymentFeesExplainedGroupCancellation_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'group_saving',
          title: loc.docsPaymentFeesExplainedGroupSaving_title,
          content: loc.docsPaymentFeesExplainedGroupSaving_content,
          type: ManualContentType.important,
        ),
      ],
    ),
    ManualSection(
      id: 'payment_methods',
      title: loc.docsPaymentFeesExplainedPaymentMethods_title,
      subtitle: loc.docsPaymentFeesExplainedPaymentMethods_subtitle,
      icon: Icons.credit_card,
      category: 'Payment',
      order: 11,
      contents: [
        ManualContent(
          id: 'methods_deposit',
          title: loc.docsPaymentFeesExplainedMethodsDeposit_title,
          content: loc.docsPaymentFeesExplainedMethodsDeposit_content,
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsPaymentFeesExplainedMethodsDeposit_bullet1,
            loc.docsPaymentFeesExplainedMethodsDeposit_bullet2,
            loc.docsPaymentFeesExplainedMethodsDeposit_bullet3,
            loc.docsPaymentFeesExplainedMethodsDeposit_bullet4,
          ],
        ),
        ManualContent(
          id: 'methods_remaining',
          title: loc.docsPaymentFeesExplainedMethodsRemaining_title,
          content: loc.docsPaymentFeesExplainedMethodsRemaining_content,
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsPaymentFeesExplainedMethodsRemaining_bullet1,
            loc.docsPaymentFeesExplainedMethodsRemaining_bullet2,
            loc.docsPaymentFeesExplainedMethodsRemaining_bullet3,
            loc.docsPaymentFeesExplainedMethodsRemaining_bullet4,
          ],
        ),
        ManualContent(
          id: 'methods_security',
          title: loc.docsPaymentFeesExplainedMethodsSecurity_title,
          content: loc.docsPaymentFeesExplainedMethodsSecurity_content,
          numberPrefix: '3',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsPaymentFeesExplainedMethodsSecurity_bullet1,
            loc.docsPaymentFeesExplainedMethodsSecurity_bullet2,
            loc.docsPaymentFeesExplainedMethodsSecurity_bullet3,
            loc.docsPaymentFeesExplainedMethodsSecurity_bullet4,
          ],
        ),
        ManualContent(
          id: 'methods_tip',
          title: '',
          content: loc.docsPaymentFeesExplainedMethodsTip_content,
          type: ManualContentType.tip,
        ),
      ],
    ),
    ManualSection(
      id: 'guest_bookings',
      title: loc.docsPaymentFeesExplainedGuestBookings_title,
      subtitle: loc.docsPaymentFeesExplainedGuestBookings_subtitle,
      icon: Icons.link,
      category: 'Payment',
      order: 9,
      contents: [
        ManualContent(
          id: 'guest_what',
          title: loc.docsPaymentFeesExplainedGuestWhat_title,
          content: loc.docsPaymentFeesExplainedGuestWhat_content,
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'guest_payment',
          title: loc.docsPaymentFeesExplainedGuestPayment_title,
          content: loc.docsPaymentFeesExplainedGuestPayment_content,
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsPaymentFeesExplainedGuestPayment_bullet1,
            loc.docsPaymentFeesExplainedGuestPayment_bullet2,
            loc.docsPaymentFeesExplainedGuestPayment_bullet3,
          ],
        ),
        ManualContent(
          id: 'guest_whatsapp',
          title: loc.docsPaymentFeesExplainedGuestWhatsapp_title,
          content: loc.docsPaymentFeesExplainedGuestWhatsapp_content,
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'guest_benefits',
          title: loc.docsPaymentFeesExplainedGuestBenefits_title,
          content: loc.docsPaymentFeesExplainedGuestBenefits_content,
          numberPrefix: '4',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsPaymentFeesExplainedGuestBenefits_bullet1,
            loc.docsPaymentFeesExplainedGuestBenefits_bullet2,
            loc.docsPaymentFeesExplainedGuestBenefits_bullet3,
            loc.docsPaymentFeesExplainedGuestBenefits_bullet4,
          ],
        ),
        ManualContent(
          id: 'guest_convert',
          title: loc.docsPaymentFeesExplainedGuestConvert_title,
          content: loc.docsPaymentFeesExplainedGuestConvert_content,
          numberPrefix: '5',
          type: ManualContentType.text,
        ),
      ],
    ),

    ManualSection(
      id: 'receipts',
      title: loc.docsPaymentFeesExplainedReceipts_title,
      subtitle: loc.docsPaymentFeesExplainedReceipts_subtitle,
      icon: Icons.receipt,
      category: 'Payment',
      order: 10,
      contents: [
        ManualContent(
          id: 'receipt_what',
          title: loc.docsPaymentFeesExplainedReceiptWhat_title,
          content: loc.docsPaymentFeesExplainedReceiptWhat_content,
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsPaymentFeesExplainedReceiptWhat_bullet1,
            loc.docsPaymentFeesExplainedReceiptWhat_bullet2,
            loc.docsPaymentFeesExplainedReceiptWhat_bullet3,
            loc.docsPaymentFeesExplainedReceiptWhat_bullet4,
            loc.docsPaymentFeesExplainedReceiptWhat_bullet5,
          ],
        ),
        ManualContent(
          id: 'receipt_info',
          title: loc.docsPaymentFeesExplainedReceiptInfo_title,
          content: loc.docsPaymentFeesExplainedReceiptInfo_content,
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsPaymentFeesExplainedReceiptInfo_bullet1,
            loc.docsPaymentFeesExplainedReceiptInfo_bullet2,
            loc.docsPaymentFeesExplainedReceiptInfo_bullet3,
            loc.docsPaymentFeesExplainedReceiptInfo_bullet4,
            loc.docsPaymentFeesExplainedReceiptInfo_bullet5,
            loc.docsPaymentFeesExplainedReceiptInfo_bullet6,
            loc.docsPaymentFeesExplainedReceiptInfo_bullet7,
          ],
        ),
        ManualContent(
          id: 'receipt_access',
          title: loc.docsPaymentFeesExplainedReceiptAccess_title,
          content: loc.docsPaymentFeesExplainedReceiptAccess_content,
          numberPrefix: '3',
          type: ManualContentType.bulletList,
          bulletPoints: [
            loc.docsPaymentFeesExplainedReceiptAccess_bullet1,
            loc.docsPaymentFeesExplainedReceiptAccess_bullet2,
            loc.docsPaymentFeesExplainedReceiptAccess_bullet3,
            loc.docsPaymentFeesExplainedReceiptAccess_bullet4,
            loc.docsPaymentFeesExplainedReceiptAccess_bullet5,
          ],
        ),
      ],
    ),
    ManualSection(
      id: 'payment_faq',
      title: loc.docsPaymentFeesExplainedPaymentFAQ_title,
      subtitle: loc.docsPaymentFeesExplainedPaymentFAQ_subtitle,
      icon: Icons.help,
      category: 'Payment',
      order: 12,
      contents: [
        ManualContent(
          id: 'payment_faq_1',
          title: loc.docsPaymentFeesExplainedPaymentFAQ1_title,
          content: loc.docsPaymentFeesExplainedPaymentFAQ1_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'payment_faq_2',
          title: loc.docsPaymentFeesExplainedPaymentFAQ2_title,
          content: loc.docsPaymentFeesExplainedPaymentFAQ2_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'payment_faq_3',
          title: loc.docsPaymentFeesExplainedPaymentFAQ3_title,
          content: loc.docsPaymentFeesExplainedPaymentFAQ3_content,
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'payment_faq_4',
          title: loc.docsPaymentFeesExplainedPaymentFAQ4_title,
          content: loc.docsPaymentFeesExplainedPaymentFAQ4_content,
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
        id: 'faq_payment_deposit',
        question: loc.docsPaymentFeesExplainedFaq1Q,
        answer: loc.docsPaymentFeesExplainedFaq1A,
        category: 'Payment',
        order: 1,
      ),
      FAQModel(
        id: 'faq_payment_platform_fee',
        question: loc.docsPaymentFeesExplainedFaq2Q,
        answer: loc.docsPaymentFeesExplainedFaq2A,
        category: 'Payment',
        order: 2,
      ),
      FAQModel(
        id: 'faq_payment_remaining',
        question: loc.docsPaymentFeesExplainedFaq3Q,
        answer: loc.docsPaymentFeesExplainedFaq3A,
        category: 'Payment',
        order: 3,
      ),
      FAQModel(
        id: 'faq_payment_group_fee',
        question: loc.docsPaymentFeesExplainedFaq4Q,
        answer: loc.docsPaymentFeesExplainedFaq4A,
        category: 'Payment',
        order: 4,
      ),
      FAQModel(
        id: 'faq_payment_refund',
        question: loc.docsPaymentFeesExplainedFaq5Q,
        answer: loc.docsPaymentFeesExplainedFaq5A,
        category: 'Payment',
        order: 5,
      ),
      FAQModel(
        id: 'faq_payment_methods',
        question: loc.docsPaymentFeesExplainedFaq6Q,
        answer: loc.docsPaymentFeesExplainedFaq6A,
        category: 'Payment',
        order: 6,
      ),
      FAQModel(
        id: 'faq_payment_tip',
        question: loc.docsPaymentFeesExplainedFaq7Q,
        answer: loc.docsPaymentFeesExplainedFaq7A,
        category: 'Payment',
        order: 7,
      ),
      FAQModel(
        id: 'faq_payment_receipt',
        question: loc.docsPaymentFeesExplainedFaq8Q,
        answer: loc.docsPaymentFeesExplainedFaq8A,
        category: 'Payment',
        order: 8,
      ),
      FAQModel(
        id: 'faq_payment_split',
        question: loc.docsPaymentFeesExplainedFaq9Q,
        answer: loc.docsPaymentFeesExplainedFaq9A,
        category: 'Payment',
        order: 9,
      ),
      FAQModel(
        id: 'faq_payment_emergency',
        question: loc.docsPaymentFeesExplainedFaq10Q,
        answer: loc.docsPaymentFeesExplainedFaq10A,
        category: 'Payment',
        order: 10,
      ),
      FAQModel(
        id: 'faq_payment_saved',
        question: loc.docsPaymentFeesExplainedFaq11Q,
        answer: loc.docsPaymentFeesExplainedFaq11A,
        category: 'Payment',
        order: 11,
      ),
      FAQModel(
        id: 'faq_payment_security',
        question: loc.docsPaymentFeesExplainedFaq12Q,
        answer: loc.docsPaymentFeesExplainedFaq12A,
        category: 'Payment',
        order: 12,
      ),
      FAQModel(
        id: 'faq_guest_booking',
        question: loc.docsPaymentFeesExplainedFaq13Q,
        answer: loc.docsPaymentFeesExplainedFaq13A,
        category: 'Guest Bookings',
        order: 13,
      ),
      FAQModel(
        id: 'faq_guest_receipt',
        question: loc.docsPaymentFeesExplainedFaq14Q,
        answer: loc.docsPaymentFeesExplainedFaq14A,
        category: 'Guest Bookings',
        order: 14,
      ),
      FAQModel(
        id: 'faq_guest_conversion',
        question: loc.docsPaymentFeesExplainedFaq15Q,
        answer: loc.docsPaymentFeesExplainedFaq15A,
        category: 'Guest Bookings',
        order: 15,
      ),
    ];
  }
}
