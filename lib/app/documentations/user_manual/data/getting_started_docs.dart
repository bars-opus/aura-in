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
          id: 'guest_booking',
          title: 'Guest Booking (No App Download Needed)',
          content:
              'Don\'t want to download the app? Service providers can share a booking link - you can book and pay directly through that link without creating an account. Your booking details and receipt will be sent to your WhatsApp.',
          numberPrefix: '1b',
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

    // Section 9: How Booking & Payment Works
    ManualSection(
      id: 'booking_payment_explained',
      title: 'Booking & Payment System',
      subtitle: 'How service booking and payment work',
      icon: Icons.payment,
      category: 'Core Features',
      order: 9,
      contents: [
        ManualContent(
          id: 'booking_overview',
          title: 'How Service Bookings Work',
          content:
              'Customers book appointments with service providers. Payments are handled securely through the app using Paystack (Africa) or Stripe (Global).',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'deposit_payment',
          title: 'Deposit Payment (30%)',
          content:
              'When booking a service, customers pay 30% upfront as a deposit to secure the time slot. This confirms the booking is real and reserved.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'platform_fee',
          title: 'Platform Fee',
          content:
              'A small platform fee (2%) is added to help us maintain the platform and provide support. This is calculated on the total booking amount.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'remaining_payment',
          title: 'Remaining Payment (70%)',
          content:
              'The remaining 70% can be paid either: (1) in cash when the service is completed, or (2) online through the app before the appointment.',
          numberPrefix: '4',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'guest_booking_payment',
          title: 'Guest Booking Payment',
          content:
              'No app download needed! Customers receive a booking link from the service provider. They pay 30% to secure the slot, and their receipt is sent to WhatsApp.',
          numberPrefix: '5',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 10: Product Ordering & Delivery
    ManualSection(
      id: 'product_ordering',
      title: 'Product Ordering & Delivery',
      subtitle: 'How product sales work',
      icon: Icons.shopping_cart,
      category: 'Core Features',
      order: 10,
      contents: [
        ManualContent(
          id: 'product_overview',
          title: 'How Product Ordering Works',
          content:
              'Customers browse products, add items to cart, and checkout. Products are delivered to the customer\'s location.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'cod_payment',
          title: 'Cash on Delivery (COD)',
          content:
              'For product orders, payment is handled as Cash on Delivery. Customers pay the seller when they receive the items - no upfront payment needed.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'cod_benefits',
          title: 'Why Cash on Delivery?',
          content: 'COD is used for products because:',
          numberPrefix: '3',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Customers can verify item quality before paying',
            'No payment risk if delivery is delayed',
            'Simpler delivery process for sellers',
            'Works well for local deliveries',
          ],
        ),
        ManualContent(
          id: 'delivery_details',
          title: 'Delivery Details',
          content:
              'Customers provide delivery address and phone number at checkout. Sellers arrange delivery and collect payment on arrival.',
          numberPrefix: '4',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 11: Share & Earn
    ManualSection(
      id: 'share_and_earn',
      title: 'Share Your Profile',
      subtitle: 'Make it easy for customers to find you',
      icon: Icons.share,
      category: 'Marketing',
      order: 11,
      contents: [
        ManualContent(
          id: 'share_link',
          title: 'Your Unique Booking Link',
          content:
              'As a service provider, you get a unique booking link. Share it on WhatsApp, social media, or email. Customers can book services without downloading the app.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'custom_slug',
          title: 'Custom URL (Optional)',
          content:
              'You can customize your booking link slug (e.g., aura.in/glamour-salon instead of aura.in/abc123). Makes it easier to share and remember.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'share_benefits',
          title: 'Why Sharing Matters',
          content:
              'The easier you make it for customers to book, the more bookings you get. Share your link everywhere your customers are.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 12: Need Help?
    ManualSection(
      id: 'getting_help',
      title: 'Get Help',
      subtitle: 'Where to find answers',
      icon: Icons.help_outline,
      category: 'Support',
      order: 12,
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
      FAQModel(
        id: 'faq_getting_started_7',
        question: 'Can I book without downloading the app?',
        answer:
            'Yes! Service providers share a unique booking link. You can book directly through that link without downloading the app. Your receipt will be sent to WhatsApp.',
        category: 'Booking',
        order: 7,
      ),
      FAQModel(
        id: 'faq_getting_started_8',
        question: 'How much do I pay upfront for bookings?',
        answer:
            'You pay 30% of the service total upfront to secure the booking slot (plus a 2% platform fee). The remaining 70% can be paid in cash or online before/at the service.',
        category: 'Payments',
        order: 8,
      ),
      FAQModel(
        id: 'faq_getting_started_9',
        question: 'How do I pay for products?',
        answer:
            'Products use Cash on Delivery (COD). You pay the seller when you receive the items. This lets you check quality before paying and works well for local deliveries.',
        category: 'Payments',
        order: 9,
      ),
      FAQModel(
        id: 'faq_getting_started_10',
        question: 'Why the 2% platform fee?',
        answer:
            'The platform fee helps us maintain Aura In, provide payment processing, customer support, and continuously improve features for both customers and service providers.',
        category: 'Payments',
        order: 10,
      ),
    ];
  }
}
