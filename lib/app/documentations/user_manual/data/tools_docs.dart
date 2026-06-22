import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';

class ToolsDocs implements DocumentationModule {
  @override
  int get order => 5;

  @override
  String getTitle(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return loc.docsToolsTitle;
  }

  @override
  String get id => 'business_tools';

  @override
  String getSubtitle(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return loc.docsToolsSubtitle;
  }

  @override
  IconData get icon => Icons.build;

  @override
  List<ManualSection> getSections(BuildContext context) => [
    // Section 1: Overview
    ManualSection(
      id: 'tools_overview',
      title: 'Tools Overview',
      subtitle: 'What each tool does and how to use it',
      icon: Icons.info_outline,
      category: 'Tools',
      order: 1,
      contents: [
        ManualContent(
          id: 'tools_welcome',
          title: 'Welcome to Business Tools',
          content:
              'The Tools tab has 8 powerful features to help you automate, promote, and manage your business more effectively. Each tool solves a specific business problem.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'tools_list',
          title: 'Available Tools',
          content: 'You have access to these 8 tools:',
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Automated Reminders - Send reminders to customers',
            'Promotions Manager - Create and manage discounts',
            'Export Reports - Download your business data',
            'Payment Settings - Configure how you receive payments',
            'Business Hours - Set your working schedule',
            'Service Management - Add and edit your services',
            'Loyalty Program - Reward repeat customers',
            'Broadcasts - Send messages to your customers',
          ],
        ),
      ],
    ),

    // Section 2: Automated Reminders
    ManualSection(
      id: 'automated_reminders',
      title: '1. Automated Reminders',
      subtitle: 'Send automatic reminders to customers',
      icon: Icons.notifications_active,
      category: 'Individual Tools',
      order: 2,
      contents: [
        ManualContent(
          id: 'reminder_purpose',
          title: 'What It Does',
          content:
              'Automatically send reminder messages to customers before their bookings. Reduces no-shows and keeps customers informed.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'reminder_benefits',
          title: 'Benefits',
          content: 'Automated reminders help you:',
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Reduce no-shows - customers are less likely to forget',
            'Improve customer experience - they know when to arrive',
            'Save time - no need to manually call or message',
            'Increase reliability - reminders go out automatically',
          ],
        ),
        ManualContent(
          id: 'reminder_setup',
          title: 'How to Set It Up',
          content:
              'Click "Configure Automated Reminders" to set timing: send reminders 24 hours before, 2 hours before, or on the morning of the appointment.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'reminder_impact',
          title: '',
          content:
              'Shops using automated reminders see 20-30% fewer no-shows. This directly impacts your revenue.',
          type: ManualContentType.important,
        ),
      ],
    ),

    // Section 3: Promotions Manager
    ManualSection(
      id: 'promotions_manager',
      title: '2. Promotions Manager',
      subtitle: 'Create special offers and discounts',
      icon: Icons.local_offer,
      category: 'Individual Tools',
      order: 3,
      contents: [
        ManualContent(
          id: 'promo_purpose',
          title: 'What It Does',
          content:
              'Create time-limited promotions and discounts. Offer percentage off, fixed amount off, or free add-ons to attract more customers.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'promo_examples',
          title: 'Promotion Ideas',
          content: 'You can create promotions like:',
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            '20% off haircuts on Mondays',
            'Free massage oil with any massage booking',
            '50 off a full-service package',
            'First-time customer: 30% discount',
            'Loyalty bonus: 5th service is half price',
          ],
        ),
        ManualContent(
          id: 'promo_strategy',
          title: 'Promotion Strategy',
          content:
              'Use promotions during slow periods to boost bookings. Track which promotions work best through your analytics.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 4: Export Reports
    ManualSection(
      id: 'export_reports',
      title: '3. Export Reports',
      subtitle: 'Download your data for analysis',
      icon: Icons.download,
      category: 'Individual Tools',
      order: 4,
      contents: [
        ManualContent(
          id: 'export_purpose',
          title: 'What It Does',
          content:
              'Download detailed reports of your business data in spreadsheet format. Analyze bookings, revenue, customers, and more.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'export_types',
          title: 'Available Reports',
          content: 'You can export:',
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Booking reports - all bookings with details',
            'Revenue reports - earnings by date range',
            'Customer reports - your client list',
            'Service reports - performance by service',
            'Worker reports - staff performance metrics',
          ],
        ),
        ManualContent(
          id: 'export_uses',
          title: 'Why Export Data?',
          content:
              'Use exported data in Excel for custom analysis, record-keeping, tax purposes, or sharing with accountant.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 5: Payment Settings
    ManualSection(
      id: 'payment_settings',
      title: '4. Payment Settings',
      subtitle: 'Configure your payment method',
      icon: Icons.payment,
      category: 'Individual Tools',
      order: 5,
      contents: [
        ManualContent(
          id: 'payment_purpose',
          title: 'What It Does',
          content:
              'Set up your payment processor (Paystack or Stripe) so customers can pay for bookings and you can receive payments.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'payment_setup',
          title: 'What You Need',
          content:
              'To set up payments, you need: a business account with Paystack or Stripe, bank account for receiving money.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'payment_importance',
          title: '',
          content:
              'Payment setup is required to accept customer bookings. Without it, customers cannot pay and you cannot receive orders.',
          type: ManualContentType.important,
        ),
      ],
    ),

    // Section 6: Business Hours
    ManualSection(
      id: 'business_hours',
      title: '5. Business Hours',
      subtitle: 'Set your working schedule',
      icon: Icons.access_time,
      category: 'Individual Tools',
      order: 6,
      contents: [
        ManualContent(
          id: 'hours_purpose',
          title: 'What It Does',
          content:
              'Configure when your business is open. Customers can only book during hours you set as available.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'hours_features',
          title: 'Features',
          content: 'Set different hours for each day, mark days as closed, and update hours whenever you need.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'hours_importance',
          title: '',
          content:
              'Accurate hours are crucial. Customers get frustrated when they can\'t book during hours you actually work.',
          type: ManualContentType.important,
        ),
      ],
    ),

    // Section 7: Service Management
    ManualSection(
      id: 'service_management',
      title: '6. Service Management',
      subtitle: 'Add and edit your services',
      icon: Icons.cut,
      category: 'Individual Tools',
      order: 7,
      contents: [
        ManualContent(
          id: 'services_purpose',
          title: 'What It Does',
          content:
              'Manage your service catalog. Add new services, update pricing, change duration, or archive services you no longer offer.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'services_benefits',
          title: 'Why Use It?',
          content:
              'Central place to manage all services. Make changes instantly and they apply to all your bookings.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'services_tips',
          title: 'Tips',
          content:
              'Keep service descriptions clear and concise. Prices should match your current rates. Archive (don\'t delete) old services for record-keeping.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 8: Loyalty Program
    ManualSection(
      id: 'loyalty_program',
      title: '7. Loyalty Program',
      subtitle: 'Reward repeat customers',
      icon: Icons.card_giftcard,
      category: 'Individual Tools',
      order: 8,
      contents: [
        ManualContent(
          id: 'loyalty_purpose',
          title: 'What It Does',
          content:
              'Automatically reward customers for repeat visits. Set rules like "free service after 5 visits" to encourage loyalty.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'loyalty_benefits',
          title: 'Why Loyalty Matters',
          content:
              'Loyal customers spend more money. They refer friends and leave positive reviews. Loyalty programs increase customer lifetime value.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'loyalty_examples',
          title: 'Loyalty Ideas',
          content:
              'Example: "Every 5th haircut is free" or "10 visits = 50% off next service". Simple rules work best.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 9: Broadcasts
    ManualSection(
      id: 'broadcasts',
      title: '8. Broadcasts',
      subtitle: 'Send messages to customers',
      icon: Icons.campaign_outlined,
      category: 'Individual Tools',
      order: 9,
      contents: [
        ManualContent(
          id: 'broadcast_purpose',
          title: 'What It Does',
          content:
              'Send bulk messages to your customers. Announce new services, special offers, or business updates via push notification or WhatsApp.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'broadcast_uses',
          title: 'When to Broadcast',
          content: 'Use broadcasts to:',
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Announce new services or pricing',
            'Promote limited-time offers',
            'Share business updates',
            'Invite customers to special events',
            'Thank customers for their loyalty',
          ],
        ),
        ManualContent(
          id: 'broadcast_tips',
          title: 'Broadcasting Tips',
          content:
              'Keep messages short and valuable. Don\'t broadcast too often or customers will mute notifications. Timing matters - send during business hours.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 10: FAQ
    ManualSection(
      id: 'tools_faq',
      title: 'Common Questions',
      subtitle: 'Get help with tools',
      icon: Icons.help_outline,
      category: 'Help',
      order: 10,
      contents: [
        ManualContent(
          id: 'faq_which_tool',
          title: 'Which tool should I use first?',
          content:
              'Start with Business Hours and Service Management - these are essential. Then add Automated Reminders to reduce no-shows. Add Promotions when you want to boost bookings.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'faq_tools_cost',
          title: 'Do tools cost extra?',
          content:
              'No. All tools are included with your shop account at no additional cost. Use as many as you want.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'faq_reminders_delivery',
          title: 'Will customers receive reminders?',
          content:
              'Yes - reminders go to customers who have opted into notifications. They receive push notifications and/or SMS depending on their settings.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'faq_promo_conflicts',
          title: 'Can I run multiple promotions at once?',
          content:
              'Yes. You can run multiple promotions on different services simultaneously. Customers get the best available deal.',
          numberPrefix: '4',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'faq_export_frequency',
          title: 'How often can I export reports?',
          content:
              'Anytime you want. Export daily, weekly, or monthly depending on your needs. Data updates in real-time.',
          numberPrefix: '5',
          type: ManualContentType.text,
        ),
      ],
    ),
  ];

  @override
  List<FAQModel> getFAQs(BuildContext context) {
    return [
      FAQModel(
        id: 'faq_tools_1',
        question: 'What\'s the most important tool?',
        answer:
            'Business Hours and Service Management are essential - set these up first. Then add Reminders to reduce no-shows. Everything else is extra optimization.',
        category: 'Getting Started',
        order: 1,
      ),
      FAQModel(
        id: 'faq_tools_2',
        question: 'Can I change tools settings anytime?',
        answer:
            'Yes. Change your hours, prices, promotions, reminders, or any setting anytime. Changes take effect immediately.',
        category: 'Usage',
        order: 2,
      ),
      FAQModel(
        id: 'faq_tools_3',
        question: 'Which tool increases sales most?',
        answer:
            'Promotions during slow times + Loyalty program for repeat customers = biggest sales boost. Analytics shows you which works best.',
        category: 'Strategy',
        order: 3,
      ),
      FAQModel(
        id: 'faq_tools_4',
        question: 'Do I need to pay for Paystack or Stripe?',
        answer:
            'These payment processors take a small commission (usually 1.5-3%) per transaction. You only pay when you get paid.',
        category: 'Payments',
        order: 4,
      ),
      FAQModel(
        id: 'faq_tools_5',
        question: 'Can customers ignore broadcast messages?',
        answer:
            'Yes. Customers control their notification settings. Only those who opted in will receive broadcasts. Respect their preferences.',
        category: 'Broadcasts',
        order: 5,
      ),
      FAQModel(
        id: 'faq_tools_6',
        question: 'What happens if I change my business hours?',
        answer:
            'Future bookings follow new hours. Existing bookings are not affected. Customers cannot book outside your updated hours.',
        category: 'Business Hours',
        order: 6,
      ),
    ];
  }
}
