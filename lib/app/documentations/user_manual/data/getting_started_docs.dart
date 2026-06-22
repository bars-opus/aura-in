import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class GettingStartedDocs implements DocumentationModule {
  @override
  int get order => 1;

  @override
  String getTitle(BuildContext context) => 'Welcome to Aura In';

  @override
  String get id => 'getting_started';

  @override
  String getSubtitle(BuildContext context) =>
      'The marketplace platform for service-based businesses';

  @override
  IconData get icon => Icons.rocket_launch;

  @override
  List<ManualSection> getSections(BuildContext context) => [
    // Section 1: What is Aura In?
    ManualSection(
      id: 'what_is_nanoembryo',
      title: 'What is Aura In?',
      subtitle: 'Understand the platform',
      icon: Icons.info_outline,
      category: 'Introduction',
      order: 1,
      contents: [
        ManualContent(
          id: 'welcome_intro',
          title: 'Welcome to Aura In',
          content:
              'Aura In is a mobile marketplace connecting service professionals with customers. Whether you offer haircuts, massages, freelance services, or sell products, this platform helps you grow your business.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'who_uses_app',
          title: 'Who Uses Aura In?',
          content: 'Two types of users power the platform:',
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Service Providers - Salons, spas, barbers, freelancers who offer services',
            'Customers - People searching for and booking services in their area',
            'Product Sellers - Shops selling retail products or handmade items',
          ],
        ),
        ManualContent(
          id: 'how_it_works',
          title: 'How It Works',
          content:
              'Service providers create a profile, list their services with pricing, and accept bookings from customers. Customers search by location, browse services, and book appointments. Everything is managed through the app.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 2: Three Ways to Use Aura In
    ManualSection(
      id: 'three_user_types',
      title: 'Three Ways to Use Aura In',
      subtitle: 'Choose your role',
      icon: Icons.people,
      category: 'Getting Started',
      order: 2,
      contents: [
        ManualContent(
          id: 'option_customer',
          title: 'Option 1: Browse & Book Services (Customer)',
          content:
              'Search for salons, massage therapists, barbers, or freelancers near you. View their services, pricing, and availability. Book appointments directly through the app and pay securely.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'option_provider',
          title: 'Option 2: Offer Services (Shop Owner or Freelancer)',
          content:
              'Create a shop or freelancer profile, list your services with pricing and duration, set your working hours, and manage bookings. Get paid for every service booked.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'option_seller',
          title: 'Option 3: Sell Products (Product Seller)',
          content:
              'If you make handmade items or retail products, you can list them for sale. Customers browse and purchase directly from your shop.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 3: Key Features
    ManualSection(
      id: 'key_features',
      title: 'Platform Features',
      subtitle: 'What you can do',
      icon: Icons.stars,
      category: 'Getting Started',
      order: 3,
      contents: [
        ManualContent(
          id: 'features_overview',
          title: 'Core Platform Features',
          content: 'Aura In includes everything you need to run a service business:',
          numberPrefix: '1',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Booking System - Customers book services, you manage calendar',
            'Secure Payments - Accept payments via Paystack or Stripe',
            'Real-time Chat - Communicate with customers before/after bookings',
            'Location-based Search - Customers find you by location using Google Maps',
            'Business Dashboard - Analytics, revenue tracking, client management',
            'Team Management - Add staff members and assign them to services',
            'Automated Reminders - Send appointment reminders to reduce no-shows',
            'Promotions & Loyalty - Run discounts and reward repeat customers',
            'Product Selling - List items for sale if you offer products',
            'Reviews & Ratings - Build trust through customer feedback',
          ],
        ),
      ],
    ),

    // Section 4: For Customers
    ManualSection(
      id: 'for_customers',
      title: 'For Customers',
      subtitle: 'How to find and book services',
      icon: Icons.shopping_bag,
      category: 'Roles',
      order: 4,
      contents: [
        ManualContent(
          id: 'customer_start',
          title: 'Getting Started as a Customer',
          content:
              'Create an account, set your location, and start searching for services. You can view service providers near you, read reviews, check pricing, and book appointments.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'customer_features',
          title: 'Customer Capabilities',
          content: 'As a customer, you can:',
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Search services by location (using Google Maps)',
            'Filter by type of service, price range, or ratings',
            'View detailed service provider profiles and reviews',
            'Book appointments and select preferred staff member',
            'Chat with providers before booking',
            'Pay securely through the app',
            'Receive appointment reminders',
            'Rate and review services after completion',
          ],
        ),
      ],
    ),

    // Section 5: For Service Providers
    ManualSection(
      id: 'for_providers',
      title: 'For Service Providers',
      subtitle: 'How to set up and manage your business',
      icon: Icons.store,
      category: 'Roles',
      order: 5,
      contents: [
        ManualContent(
          id: 'provider_start',
          title: 'Getting Started as a Service Provider',
          content:
              'Create a shop or freelancer profile, add your services, set your hours, and start accepting bookings. It takes 5-10 minutes to get started.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'provider_flow',
          title: 'Setup Steps',
          content: 'To get started as a provider:',
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Create your account and verify your phone number',
            'Choose: Shop (fixed location with team) or Freelancer (mobile/solo)',
            'Add basic info: name, logo, description, location',
            'Set your working hours',
            'Add your services with pricing and duration',
            'Upload photos of yourself and your work',
            'Set up payment method (Paystack or Stripe)',
            'Start accepting bookings!',
          ],
        ),
        ManualContent(
          id: 'provider_benefits',
          title: '',
          content:
              'Service providers get access to customer bookings, analytics, business tools, and payment processing all in one place.',
          type: ManualContentType.important,
        ),
      ],
    ),

    // Section 6: For Product Sellers
    ManualSection(
      id: 'for_sellers',
      title: 'For Product Sellers',
      subtitle: 'How to list and sell items',
      icon: Icons.shopping_cart,
      category: 'Roles',
      order: 6,
      contents: [
        ManualContent(
          id: 'seller_start',
          title: 'Getting Started as a Product Seller',
          content:
              'If you make handmade items or sell products, you can list them on Aura In. Customers in your area can discover and purchase your products.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'seller_requirements',
          title: 'Seller Requirements',
          content:
              'To sell products, you need a verified phone number and a shop or freelancer profile. Add your products with photos, descriptions, and pricing.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 7: Key Concepts
    ManualSection(
      id: 'key_concepts',
      title: 'Key Concepts',
      subtitle: 'Understand how the platform works',
      icon: Icons.lightbulb,
      category: 'Fundamentals',
      order: 7,
      contents: [
        ManualContent(
          id: 'concept_booking',
          title: 'Bookings',
          content:
              'Bookings are appointments customers schedule with service providers. They include date, time, service, price, and status (pending, confirmed, completed, cancelled).',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'concept_location',
          title: 'Location-Based Discovery',
          content:
              'Aura In uses Google Maps to show customers services near them. Freelancers have a travel radius; shops have a fixed location.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'concept_payments',
          title: 'Payments',
          content:
              'Customers pay through the app via Paystack (Africa) or Stripe (Global). Service providers receive payments to their wallet and can withdraw anytime.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'concept_reviews',
          title: 'Reviews & Ratings',
          content:
              'After a service is completed, customers can rate (1-5 stars) and leave reviews. High ratings help providers attract more bookings.',
          numberPrefix: '4',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'concept_chat',
          title: 'In-App Chat',
          content:
              'Customers and service providers can chat through the app to discuss details, ask questions, or reschedule. Chat is built-in, no need to exchange phone numbers.',
          numberPrefix: '5',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 8: Getting Started Checklist
    ManualSection(
      id: 'getting_started_checklist',
      title: 'Your First Steps',
      subtitle: 'Quick start guide',
      icon: Icons.checklist,
      category: 'Getting Started',
      order: 8,
      contents: [
        ManualContent(
          id: 'step_1',
          title: 'Step 1: Create Account',
          content: 'Sign up with email. Add your name and create a password.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'step_2',
          title: 'Step 2: Choose Your Role',
          content:
              'Decide: Are you a customer booking services, a service provider offering services, or a product seller?',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'step_3',
          title: 'Step 3: Complete Your Profile',
          content:
              'If you\'re a provider/seller: add location, hours, services/products, photos. If you\'re a customer: add your location and preferences.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'step_4',
          title: 'Step 4: Start Using',
          content:
              'Customers: browse and book. Providers: accept bookings and manage your calendar. Sellers: receive product orders.',
          numberPrefix: '4',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 9: Need Help?
    ManualSection(
      id: 'getting_help',
      title: 'Get Help',
      subtitle: 'Where to find answers',
      icon: Icons.help_outline,
      category: 'Support',
      order: 9,
      contents: [
        ManualContent(
          id: 'help_documentation',
          title: 'Use This User Manual',
          content:
              'This app has comprehensive documentation for every feature. When you need help, check the relevant guide - there\'s one for your role and the feature you\'re using.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'help_resources',
          title: 'Documentation Available For:',
          content: 'You can find detailed guides for:',
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Create Your Shop - Complete setup guide',
            'Become a Freelancer - Freelancer onboarding',
            'Sell Products Online - Product listing guide',
            'Manage Your Business Dashboard - Analytics & reports',
            'Business Tools - Reminders, promotions, loyalty programs',
            'Booking System - How bookings work',
          ],
        ),
      ],
    ),
  ];

  @override
  List<FAQModel> getFAQs(BuildContext context) {
    return [
      FAQModel(
        id: 'faq_getting_started_1',
        question: 'What is Aura In?',
        answer:
            'Aura In is a mobile marketplace for service-based businesses. Customers find and book services (haircuts, massages, etc.), service providers manage bookings and revenue, and product sellers list items for sale.',
        category: 'Overview',
        order: 1,
      ),
      FAQModel(
        id: 'faq_getting_started_2',
        question: 'Do I need to pay to use the app?',
        answer:
            'The app is free to download and use. Service providers only pay a small commission when customers pay for services. Payment processors (Paystack/Stripe) take a fee.',
        category: 'Pricing',
        order: 2,
      ),
      FAQModel(
        id: 'faq_getting_started_3',
        question: 'What is the difference between Shop Owner and Freelancer?',
        answer:
            'Shop owners have a fixed location with a team of workers. Freelancers work independently and can travel to clients. Choose based on your business model.',
        category: 'Roles',
        order: 3,
      ),
      FAQModel(
        id: 'faq_getting_started_4',
        question: 'How do I get paid?',
        answer:
            'When customers pay for services, money goes to your wallet. You can withdraw to your bank account using Paystack (Africa) or Stripe (Global).',
        category: 'Payments',
        order: 4,
      ),
      FAQModel(
        id: 'faq_getting_started_5',
        question: 'Is my payment information secure?',
        answer:
            'Yes. Aura In uses Paystack and Stripe, industry-leading payment processors with bank-level security. We never see your payment details.',
        category: 'Security',
        order: 5,
      ),
      FAQModel(
        id: 'faq_getting_started_6',
        question: 'How do I know if service providers near me are trustworthy?',
        answer:
            'Every service provider has ratings and reviews from customers who have booked with them. Read reviews before booking. High ratings mean consistent, quality service.',
        category: 'Trust',
        order: 6,
      ),
    ];
  }
}
