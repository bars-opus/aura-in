// lib/features/documentation/data/docs/booking_docs/how_to_book_services.dart
import 'package:flutter/material.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';
import 'package:nano_embryo/app/documentations/user_manual/models/documentation_model.dart'
    show DocumentationModule;
import 'package:nano_embryo/app/documentations/user_manual/models/faq_model.dart';
import 'package:nano_embryo/app/documentations/user_manual/models/manual_content.dart';
import 'package:nano_embryo/app/documentations/user_manual/models/manual_section.dart';

class HowToBookServicesDocs implements DocumentationModule {
  @override
  int get order => 2;

  @override
  String getTitle(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return loc.docsHowToBookTitle;
  }

  @override
  String get id => 'howToBookServices';

  @override
  String getSubtitle(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return loc.docsHowToBookSubtitle;
  }

  @override
  IconData get icon => Icons.event_note;

  @override
  List<ManualSection> getSections(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
      ManualSection(
        id: 'booking_overview',
        title: loc.docsHowBookBookingOverview_title,
        subtitle: loc.docsHowBookBookingOverview_subtitle,
        icon: Icons.timeline,
        category: 'Booking Guide',
        order: 1,
        contents: [
          ManualContent(
            id: 'two_booking_ways',
            title: loc.docsHowBookBookingOverview_twoBookingWays_title,
            content: loc.docsHowBookBookingOverview_twoBookingWays_content,
            numberPrefix: '1',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsHowBookBookingOverview_twoBookingWays_bullet1,
              loc.docsHowBookBookingOverview_twoBookingWays_bullet2,
            ],
          ),
          ManualContent(
            id: 'booking_steps_overview',
            title: loc.docsHowBookBookingOverview_bookingStepsOverview_title,
            content: loc.docsHowBookBookingOverview_bookingStepsOverview_content,
            numberPrefix: '2',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsHowBookBookingOverview_bookingStepsOverview_bullet1,
              loc.docsHowBookBookingOverview_bookingStepsOverview_bullet2,
              loc.docsHowBookBookingOverview_bookingStepsOverview_bullet3,
              loc.docsHowBookBookingOverview_bookingStepsOverview_bullet4,
              loc.docsHowBookBookingOverview_bookingStepsOverview_bullet5,
              loc.docsHowBookBookingOverview_bookingStepsOverview_bullet6,
            ],
          ),
          ManualContent(
            id: 'guest_booking_note',
            title: loc.docsHowBookBookingOverview_guestBookingNote_title,
            content: loc.docsHowBookBookingOverview_guestBookingNote_content,
            numberPrefix: '3',
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'booking_time_note',
            title: '',
            content: loc.docsHowBookBookingOverview_bookingTimeNote_content,
            type: ManualContentType.tip,
          ),
        ],
      ),
      ManualSection(
        id: 'step_one',
        title: loc.docsHowBookStepOne_title,
        subtitle: loc.docsHowBookStepOne_subtitle,
        icon: Icons.search,
        category: 'Booking Steps',
        order: 2,
        contents: [
          ManualContent(
            id: 'find_shop',
            title: loc.docsHowBookStepOne_findShop_title,
            content: loc.docsHowBookStepOne_findShop_content,
            numberPrefix: '1',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsHowBookStepOne_findShop_bullet1,
              loc.docsHowBookStepOne_findShop_bullet2,
              loc.docsHowBookStepOne_findShop_bullet3,
              loc.docsHowBookStepOne_findShop_bullet4,
            ],
          ),
          ManualContent(
            id: 'browse_services',
            title: loc.docsHowBookStepOne_browseServices_title,
            content: loc.docsHowBookStepOne_browseServices_content,
            numberPrefix: '2',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsHowBookStepOne_browseServices_bullet1,
              loc.docsHowBookStepOne_browseServices_bullet2,
              loc.docsHowBookStepOne_browseServices_bullet3,
              loc.docsHowBookStepOne_browseServices_bullet4,
              loc.docsHowBookStepOne_browseServices_bullet5,
            ],
          ),
          ManualContent(
            id: 'service_example',
            title: loc.docsHowBookStepOne_serviceExample_title,
            content: loc.docsHowBookStepOne_serviceExample_content,
            type: ManualContentType.text,
          ),
        ],
      ),
      ManualSection(
        id: 'step_two',
        title: loc.docsHowBookStepTwo_title,
        subtitle: loc.docsHowBookStepTwo_subtitle,
        icon: Icons.checklist,
        category: 'Booking Steps',
        order: 3,
        contents: [
          ManualContent(
            id: 'select_services',
            title: loc.docsHowBookStepTwo_selectServices_title,
            content: loc.docsHowBookStepTwo_selectServices_content,
            numberPrefix: '1',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsHowBookStepTwo_selectServices_bullet1,
              loc.docsHowBookStepTwo_selectServices_bullet2,
              loc.docsHowBookStepTwo_selectServices_bullet3,
              loc.docsHowBookStepTwo_selectServices_bullet4,
            ],
          ),
          ManualContent(
            id: 'group_booking',
            title: loc.docsHowBookStepTwo_groupBooking_title,
            content: loc.docsHowBookStepTwo_groupBooking_content,
            numberPrefix: '2',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsHowBookStepTwo_groupBooking_bullet1,
              loc.docsHowBookStepTwo_groupBooking_bullet2,
              loc.docsHowBookStepTwo_groupBooking_bullet3,
              loc.docsHowBookStepTwo_groupBooking_bullet4,
            ],
          ),
          ManualContent(
            id: 'group_example',
            title: loc.docsHowBookStepTwo_groupExample_title,
            content: loc.docsHowBookStepTwo_groupExample_content,
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'quantity_tip',
            title: '',
            content: loc.docsHowBookStepTwo_quantityTip_content,
            type: ManualContentType.tip,
          ),
        ],
      ),
      ManualSection(
        id: 'step_three',
        title: loc.docsHowBookStepThree_title,
        subtitle: loc.docsHowBookStepThree_subtitle,
        icon: Icons.people,
        category: 'Booking Steps',
        order: 4,
        contents: [
          ManualContent(
            id: 'worker_selection',
            title: loc.docsHowBookStepThree_workerSelection_title,
            content: loc.docsHowBookStepThree_workerSelection_content,
            numberPrefix: '1',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsHowBookStepThree_workerSelection_bullet1,
              loc.docsHowBookStepThree_workerSelection_bullet2,
              loc.docsHowBookStepThree_workerSelection_bullet3,
            ],
          ),
          ManualContent(
            id: 'choosing_worker',
            title: loc.docsHowBookStepThree_choosingWorker_title,
            content: loc.docsHowBookStepThree_choosingWorker_content,
            numberPrefix: '2',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsHowBookStepThree_choosingWorker_bullet1,
              loc.docsHowBookStepThree_choosingWorker_bullet2,
              loc.docsHowBookStepThree_choosingWorker_bullet3,
              loc.docsHowBookStepThree_choosingWorker_bullet4,
              loc.docsHowBookStepThree_choosingWorker_bullet5,
            ],
          ),
          ManualContent(
            id: 'worker_example',
            title: loc.docsHowBookStepThree_workerExample_title,
            content: loc.docsHowBookStepThree_workerExample_content,
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'worker_tip',
            title: '',
            content: loc.docsHowBookStepThree_workerTip_content,
            type: ManualContentType.tip,
          ),
        ],
      ),
      ManualSection(
        id: 'step_four',
        title: loc.docsHowBookStepFour_title,
        subtitle: loc.docsHowBookStepFour_subtitle,
        icon: Icons.calendar_today,
        category: 'Booking Steps',
        order: 5,
        contents: [
          ManualContent(
            id: 'date_selection',
            title: loc.docsHowBookStepFour_dateSelection_title,
            content: loc.docsHowBookStepFour_dateSelection_content,
            numberPrefix: '1',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsHowBookStepFour_dateSelection_bullet1,
              loc.docsHowBookStepFour_dateSelection_bullet2,
              loc.docsHowBookStepFour_dateSelection_bullet3,
              loc.docsHowBookStepFour_dateSelection_bullet4,
            ],
          ),
          ManualContent(
            id: 'time_selection',
            title: loc.docsHowBookStepFour_timeSelection_title,
            content: loc.docsHowBookStepFour_timeSelection_content,
            numberPrefix: '2',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsHowBookStepFour_timeSelection_bullet1,
              loc.docsHowBookStepFour_timeSelection_bullet2,
            ],
          ),
          ManualContent(
            id: 'regular_vs_combined',
            title: loc.docsHowBookStepFour_regularVsCombined_title,
            content: loc.docsHowBookStepFour_regularVsCombined_content,
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'view_switch',
            title: '',
            content: loc.docsHowBookStepFour_viewSwitch_content,
            type: ManualContentType.tip,
          ),
        ],
      ),
      ManualSection(
        id: 'step_five',
        title: loc.docsHowBookStepFive_title,
        subtitle: loc.docsHowBookStepFive_subtitle,
        icon: Icons.payment,
        category: 'Booking Steps',
        order: 6,
        contents: [
          ManualContent(
            id: 'payment_overview',
            title: loc.docsHowBookStepFive_paymentOverview_title,
            content: loc.docsHowBookStepFive_paymentOverview_content,
            numberPrefix: '1',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsHowBookStepFive_paymentOverview_bullet1,
              loc.docsHowBookStepFive_paymentOverview_bullet2,
              loc.docsHowBookStepFive_paymentOverview_bullet3,
              loc.docsHowBookStepFive_paymentOverview_bullet4,
              loc.docsHowBookStepFive_paymentOverview_bullet5,
            ],
          ),
          ManualContent(
            id: 'payment_example',
            title: loc.docsHowBookStepFive_paymentExample_title,
            content: loc.docsHowBookStepFive_paymentExample_content,
            type: ManualContentType.text,
          ),
          ManualContent(
            id: 'payment_step',
            title: loc.docsHowBookStepFive_paymentStep_title,
            content: loc.docsHowBookStepFive_paymentStep_content,
            numberPrefix: '2',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsHowBookStepFive_paymentStep_bullet1,
              loc.docsHowBookStepFive_paymentStep_bullet2,
              loc.docsHowBookStepFive_paymentStep_bullet3,
              loc.docsHowBookStepFive_paymentStep_bullet4,
              loc.docsHowBookStepFive_paymentStep_bullet5,
              loc.docsHowBookStepFive_paymentStep_bullet6,
              loc.docsHowBookStepFive_paymentStep_bullet7,
            ],
          ),
          ManualContent(
            id: 'fee_explanation',
            title: loc.docsHowBookStepFive_feeExplanation_title,
            content: loc.docsHowBookStepFive_feeExplanation_content,
            numberPrefix: '3',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsHowBookStepFive_feeExplanation_bullet1,
              loc.docsHowBookStepFive_feeExplanation_bullet2,
              loc.docsHowBookStepFive_feeExplanation_bullet3,
              loc.docsHowBookStepFive_feeExplanation_bullet4,
            ],
          ),
          ManualContent(
            id: 'payment_important',
            title: '',
            content: loc.docsHowBookStepFive_paymentImportant_content,
            type: ManualContentType.important,
          ),
          ManualContent(
            id: 'remaining_payment',
            title: loc.docsHowBookStepFive_remainingPayment_title,
            content: loc.docsHowBookStepFive_remainingPayment_content,
            numberPrefix: '4',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsHowBookStepFive_remainingPayment_bullet1,
              loc.docsHowBookStepFive_remainingPayment_bullet2,
              loc.docsHowBookStepFive_remainingPayment_bullet3,
            ],
          ),
          ManualContent(
            id: 'confirmation',
            title: loc.docsHowBookStepFive_confirmation_title,
            content: loc.docsHowBookStepFive_confirmation_content,
            numberPrefix: '5',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsHowBookStepFive_confirmation_bullet1,
              loc.docsHowBookStepFive_confirmation_bullet2,
              loc.docsHowBookStepFive_confirmation_bullet3,
              loc.docsHowBookStepFive_confirmation_bullet4,
              loc.docsHowBookStepFive_confirmation_bullet5,
            ],
          ),
          ManualContent(
            id: 'payment_warning',
            title: '',
            content: loc.docsHowBookStepFive_paymentWarning_content,
            type: ManualContentType.warning,
          ),
        ],
      ),
      ManualSection(
        id: 'after_booking',
        title: loc.docsHowBookAfterBooking_title,
        subtitle: loc.docsHowBookAfterBooking_subtitle,
        icon: Icons.done_all,
        category: 'Booking Guide',
        order: 7,
        contents: [
          ManualContent(
            id: 'whats_next',
            title: loc.docsHowBookAfterBooking_whatsNext_title,
            content: loc.docsHowBookAfterBooking_whatsNext_content,
            numberPrefix: '1',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsHowBookAfterBooking_whatsNext_bullet1,
              loc.docsHowBookAfterBooking_whatsNext_bullet2,
              loc.docsHowBookAfterBooking_whatsNext_bullet3,
              loc.docsHowBookAfterBooking_whatsNext_bullet4,
              loc.docsHowBookAfterBooking_whatsNext_bullet5,
            ],
          ),
          ManualContent(
            id: 'reminders',
            title: loc.docsHowBookAfterBooking_reminders_title,
            content: loc.docsHowBookAfterBooking_reminders_content,
            numberPrefix: '2',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsHowBookAfterBooking_reminders_bullet1,
              loc.docsHowBookAfterBooking_reminders_bullet2,
              loc.docsHowBookAfterBooking_reminders_bullet3,
            ],
          ),
          ManualContent(
            id: 'after_service',
            title: loc.docsHowBookAfterBooking_afterService_title,
            content: loc.docsHowBookAfterBooking_afterService_content,
            numberPrefix: '3',
            type: ManualContentType.bulletList,
            bulletPoints: [
              loc.docsHowBookAfterBooking_afterService_bullet1,
              loc.docsHowBookAfterBooking_afterService_bullet2,
              loc.docsHowBookAfterBooking_afterService_bullet3,
              loc.docsHowBookAfterBooking_afterService_bullet4,
            ],
          ),
          ManualContent(
            id: 'after_tip',
            title: '',
            content: loc.docsHowBookAfterBooking_afterTip_content,
            type: ManualContentType.tip,
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
        id: 'faq_book_cancel',
        question: loc.docsHowBookFaq1Q,
        answer: loc.docsHowBookFaq1A,
        category: 'Booking Process',
        order: 1,
      ),
      FAQModel(
        id: 'faq_book_reschedule',
        question: loc.docsHowBookFaq2Q,
        answer: loc.docsHowBookFaq2A,
        category: 'Booking Process',
        order: 2,
      ),
      FAQModel(
        id: 'faq_book_deposit',
        question: loc.docsHowBookFaq3Q,
        answer: loc.docsHowBookFaq3A,
        category: 'Payment',
        order: 3,
      ),
      FAQModel(
        id: 'faq_book_platform_fee',
        question: loc.docsHowBookFaq4Q,
        answer: loc.docsHowBookFaq4A,
        category: 'Payment',
        order: 4,
      ),
      FAQModel(
        id: 'faq_book_deposit_refund',
        question: loc.docsHowBookFaq5Q,
        answer: loc.docsHowBookFaq5A,
        category: 'Payment',
        order: 5,
      ),
      FAQModel(
        id: 'faq_book_remaining_payment',
        question: loc.docsHowBookFaq6Q,
        answer: loc.docsHowBookFaq6A,
        category: 'Payment',
        order: 6,
      ),
      FAQModel(
        id: 'faq_book_multiple_services',
        question: loc.docsHowBookFaq7Q,
        answer: loc.docsHowBookFaq7A,
        category: 'Booking Process',
        order: 7,
      ),
      FAQModel(
        id: 'faq_book_group',
        question: loc.docsHowBookFaq8Q,
        answer: loc.docsHowBookFaq8A,
        category: 'Group Bookings',
        order: 8,
      ),
      FAQModel(
        id: 'faq_book_worker_change',
        question: loc.docsHowBookFaq9Q,
        answer: loc.docsHowBookFaq9A,
        category: 'Workers',
        order: 9,
      ),
      FAQModel(
        id: 'faq_book_payment_methods',
        question: loc.docsHowBookFaq10Q,
        answer: loc.docsHowBookFaq10A,
        category: 'Payment',
        order: 10,
      ),
      FAQModel(
        id: 'faq_book_combined_view',
        question: loc.docsHowBookFaq11Q,
        answer: loc.docsHowBookFaq11A,
        category: 'Time Slots',
        order: 11,
      ),
      FAQModel(
        id: 'faq_book_no_show',
        question: loc.docsHowBookFaq12Q,
        answer: loc.docsHowBookFaq12A,
        category: 'Booking Process',
        order: 12,
      ),
      FAQModel(
        id: 'faq_book_cash_payment',
        question: loc.docsHowBookFaq13Q,
        answer: loc.docsHowBookFaq13A,
        category: 'Payment',
        order: 13,
      ),
      FAQModel(
        id: 'faq_book_fee_per_booking',
        question: loc.docsHowBookFaq14Q,
        answer: loc.docsHowBookFaq14A,
        category: 'Payment',
        order: 14,
      ),
      FAQModel(
        id: 'faq_book_guest_booking',
        question: loc.docsHowBookFaq15Q,
        answer: loc.docsHowBookFaq15A,
        category: 'Booking Process',
        order: 15,
      ),
    ];
  }
}
