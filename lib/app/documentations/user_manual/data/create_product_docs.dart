import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class CreateProductDocs implements DocumentationModule {
  @override
  String getTitle(BuildContext context) => 'Sell Products Online';

  @override
  String get id => 'sell_products';

  @override
  String getSubtitle(BuildContext context) =>
      'List items for sale and reach customers in your area';

  @override
  IconData get icon => Icons.shopping_bag;

  @override
  int get order => 3;

  @override
  List<ManualSection> getSections(BuildContext context) => [
    // Section 1: Overview
    ManualSection(
      id: 'product_overview',
      title: 'Getting Started Selling Products',
      subtitle: 'Learn how to list and sell items',
      icon: Icons.info_outline,
      category: 'Product Setup',
      order: 1,
      contents: [
        ManualContent(
          id: 'product_welcome',
          title: 'Welcome to Product Selling',
          content:
              'Sell physical products directly to customers in your area. From handmade items to retail goods, you can reach customers looking for what you offer.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'phone_requirement',
          title: 'You Need a Verified Phone Number',
          content:
              'Before you can start selling products, you must verify your phone number. This is for customer communication and to validate your identity.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'add_phone_number',
          title: 'How to Add Your Phone Number',
          content:
              'Go to your profile settings and add your phone number. You\'ll receive a verification code via SMS to confirm it\'s really your number. This takes just a minute.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'why_phone_verified',
          title: 'Why Phone Verification?',
          content:
              'A verified phone number builds customer trust and allows us to contact you if there are issues. It also helps prevent fraud.',
          numberPrefix: '4',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'phone_important',
          title: '',
          content:
              'You cannot list products until you have a verified phone number. This is required for all sellers.',
          type: ManualContentType.important,
        ),
      ],
    ),

    // Section 2: Product Basics
    ManualSection(
      id: 'product_basics',
      title: 'Basic Product Information',
      subtitle: 'What to tell customers about your product',
      icon: Icons.info,
      category: 'Product Setup',
      order: 2,
      contents: [
        ManualContent(
          id: 'product_name',
          title: 'Product Name',
          content:
              'Enter your product name clearly. Customers search by product name, so be specific. Example: "Handmade Leather Wallet - Brown" instead of just "Wallet".',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'product_description',
          title: 'Product Description',
          content:
              'Write a detailed description. Tell customers what it is, what it\'s made of, how to use it, and why it\'s good. Be honest about condition (new, used, refurbished).',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'category_selection',
          title: 'Choose a Category',
          content:
              'Select the right category. Customers browse by category to find items, so accuracy matters. Pick the most specific category available.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'product_condition',
          title: 'Product Condition',
          content:
              'Be clear about condition: New (never used), Like New (used once), Good (light wear), Fair (visible wear), or As-Is. Honesty builds trust.',
          numberPrefix: '4',
          type: ManualContentType.text,
        ),
      ],
    ),

    // Section 3: Pricing & Stock
    ManualSection(
      id: 'pricing_stock',
      title: 'Price & Availability',
      subtitle: 'Set your price and manage inventory',
      icon: Icons.local_offer,
      category: 'Product Setup',
      order: 3,
      contents: [
        ManualContent(
          id: 'pricing',
          title: 'Set Your Price',
          content:
              'Set a fair price based on condition, market value, and local demand. Customers can see similar items, so competitive pricing helps.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'currency',
          title: 'Currency',
          content:
              'Prices are shown in your shop\'s currency. Make sure your shop currency is set correctly before adding products.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'stock_quantity',
          title: 'Stock Quantity',
          content:
              'Enter how many items you have. When stock runs out, the product shows as unavailable. Update this as you sell items.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'stock_tip',
          title: '',
          content:
              'Keep stock accurate. Customers get frustrated if they order something out of stock. Update regularly as you sell.',
          type: ManualContentType.tip,
        ),
      ],
    ),

    // Section 4: Photos
    ManualSection(
      id: 'product_photos',
      title: 'Product Photos',
      subtitle: 'Show customers what they\'re buying',
      icon: Icons.photo,
      category: 'Product Setup',
      order: 4,
      contents: [
        ManualContent(
          id: 'photos_importance',
          title: 'Photos Matter Most',
          content:
              'Good photos are critical. Customers decide whether to buy based on photos. Poor photos = fewer sales.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'what_photos',
          title: 'What to Photograph',
          content: 'Take photos that show the real product:',
          numberPrefix: '2',
          type: ManualContentType.bulletList,
          bulletPoints: [
            'Full product from multiple angles',
            'Close-ups of details and quality',
            'Photos showing condition (if used)',
            'Photos next to something for scale (like a coin or hand)',
            'Photos of any damage or wear (honesty builds trust)',
          ],
        ),
        ManualContent(
          id: 'photo_tips',
          title: 'Photo Quality Tips',
          content:
              'Use natural light. Take photos on a clean background. Show colors accurately. Don\'t use filters that change how the product looks.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'photo_count',
          title: 'Upload Multiple Photos',
          content:
              'Upload at least 3-5 photos. The first photo is most important - make it clear and appealing. Customers scroll through all photos.',
          numberPrefix: '4',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'photo_honesty',
          title: '',
          content:
              'Honest photos = happy customers. Show exactly what customers will receive, including any flaws.',
          type: ManualContentType.important,
        ),
      ],
    ),

    // Section 5: Active/Inactive
    ManualSection(
      id: 'product_status',
      title: 'List Your Product',
      subtitle: 'Make your product visible to customers',
      icon: Icons.visibility,
      category: 'Product Setup',
      order: 5,
      contents: [
        ManualContent(
          id: 'active_product',
          title: 'Make Your Product Active',
          content:
              'Before customers can see your product, you must mark it as "Active". Inactive products are hidden from search.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'when_to_activate',
          title: 'When to Activate',
          content:
              'Only activate when you have: product name, description, price, photos, and correct stock. If you\'re not ready to sell, keep it inactive.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'pause_listing',
          title: 'Pause a Listing',
          content:
              'If stock runs out or you need to pause, mark it inactive. Customers won\'t see it, but you can reactivate it anytime.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'active_tip',
          title: '',
          content:
              'Only active products with photos and good descriptions get bookmarks and purchases. Make your listings complete before activating.',
          type: ManualContentType.tip,
        ),
      ],
    ),

    // Section 6: FAQ
    ManualSection(
      id: 'product_faq',
      title: 'Common Questions',
      subtitle: 'Get help with selling products',
      icon: Icons.help_outline,
      category: 'Help',
      order: 6,
      contents: [
        ManualContent(
          id: 'faq_how_long',
          title: 'How long until my product sells?',
          content:
              'It depends on your price, photos, and demand. Good photos + competitive price = faster sales.',
          numberPrefix: '1',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'faq_payment',
          title: 'How do I get paid?',
          content:
              'When a customer buys, payment goes to your account. You\'ll receive the amount (minus any platform fees) after the transaction completes.',
          numberPrefix: '2',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'faq_shipping',
          title: 'Do I have to ship?',
          content:
              'That depends on your shop settings. You can choose local delivery or shipping. Customers see shipping options before buying.',
          numberPrefix: '3',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'faq_edit_after',
          title: 'Can I edit after listing?',
          content:
              'Yes! You can edit price, description, photos, and stock anytime. Changes take effect immediately.',
          numberPrefix: '4',
          type: ManualContentType.text,
        ),
        ManualContent(
          id: 'faq_reviews',
          title: 'Do products get reviews?',
          content:
              'Yes. Customers rate products and leave reviews after purchase. Good reviews help future customers trust you.',
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
        id: 'faq_product_1',
        question: 'Do I need a phone number to sell products?',
        answer:
            'Yes. You must verify a phone number before you can list products. This is for customer communication and security.',
        category: 'Getting Started',
        order: 1,
      ),
      FAQModel(
        id: 'faq_product_2',
        question: 'What makes a good product listing?',
        answer:
            'Good photos, accurate description, honest condition info, fair pricing, and correct stock quantity. Great photos are the most important.',
        category: 'Setup',
        order: 2,
      ),
      FAQModel(
        id: 'faq_product_3',
        question: 'Can I sell both products and services?',
        answer:
            'Yes! You can run a shop with services, a shop with products, or both. Set up your shop to offer what you want.',
        category: 'Setup',
        order: 3,
      ),
      FAQModel(
        id: 'faq_product_4',
        question: 'How do I remove a product?',
        answer:
            'Mark it as inactive to hide it from customers. If you want to delete it completely, contact support.',
        category: 'Management',
        order: 4,
      ),
      FAQModel(
        id: 'faq_product_5',
        question: 'What if someone buys but I\'m out of stock?',
        answer:
            'Keep your stock accurate to prevent this. If it happens, contact the customer immediately to cancel or offer alternatives.',
        category: 'Management',
        order: 5,
      ),
      FAQModel(
        id: 'faq_product_6',
        question: 'Can customers return products?',
        answer:
            'That\'s up to your shop policy. You can set return policies in your shop settings. Be clear so customers know before buying.',
        category: 'Management',
        order: 6,
      ),
    ];
  }
}
