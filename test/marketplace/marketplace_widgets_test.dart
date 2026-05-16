// Widget tests for the marketplace UI surface. These do not hit Supabase
// — they exercise renderable widgets directly (ProductCard /
// ProductGridItem) and the screens that can be stubbed with a single
// provider override (OrderConfirmation).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/products/data/models/order_model.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/currency.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/order_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/order_confirmation_screen.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/product_card.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/product_grid_item.dart';

ProductModel _product({
  bool isActive = true,
  int stockQuantity = 10,
  bool? shopVerified,
  String name = 'Test Product',
  double price = 1500.00,
}) {
  return ProductModel(
    id: 'p1',
    shopId: 's1',
    name: name,
    description: 'desc',
    price: price,
    images: const [],
    category: 'hair',
    isActive: isActive,
    stockQuantity: stockQuantity,
    totalOrdersCount: 0,
    averageRating: 0,
    reviewCount: 0,
    createdAt: DateTime(2026, 5, 15),
    updatedAt: DateTime(2026, 5, 15),
    shopVerified: shopVerified,
  );
}

/// Wraps a widget in MaterialApp + ScreenUtilInit at a given width.
/// Tests pick the width that matches the widget's real-world container:
///   - ProductCard lives in a list row → wide (360)
///   - ProductGridItem lives in a 2-column GridView cell → narrow (180)
/// Either way, body is scrollable so vertical overflow is fine.
Widget _wrap(Widget child, {double width = 600}) {
  // 600 default fits a ProductCard row (image + details + status chip)
  // even after ScreenUtil scales 80.w in an 800-wide test surface.
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, __) => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  );
}

void main() {
  group('ProductCard', () {
    testWidgets('renders price formatted with ₦', (tester) async {
      await tester.pumpWidget(_wrap(ProductCard(
        product: _product(price: 1234.56),
        onTap: () {},
      )));
      expect(find.text(Currency.format(1234.56)), findsOneWidget);
    });

    testWidgets('shows verified shop tooltip icon when shopVerified',
        (tester) async {
      await tester.pumpWidget(_wrap(ProductCard(
        product: _product(shopVerified: true),
        onTap: () {},
      )));
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('does NOT show verified icon when shopVerified is false/null',
        (tester) async {
      await tester.pumpWidget(_wrap(ProductCard(
        product: _product(shopVerified: false),
        onTap: () {},
      )));
      expect(find.byIcon(Icons.verified), findsNothing);
    });

    testWidgets('renders "Out of stock" chip when stockQuantity is 0',
        (tester) async {
      await tester.pumpWidget(_wrap(ProductCard(
        product: _product(stockQuantity: 0),
        onTap: () {},
      )));
      expect(find.text('Out of stock'), findsOneWidget);
    });

    testWidgets('renders "Only N left" when stockQuantity <= 5',
        (tester) async {
      await tester.pumpWidget(_wrap(ProductCard(
        product: _product(stockQuantity: 3),
        onTap: () {},
      )));
      expect(find.text('Only 3 left'), findsOneWidget);
    });

    testWidgets('renders "Inactive" chip when isActive is false',
        (tester) async {
      await tester.pumpWidget(_wrap(ProductCard(
        product: _product(isActive: false, stockQuantity: 5),
        onTap: () {},
      )));
      expect(find.text('Inactive'), findsOneWidget);
    });

    testWidgets('onTap fires when card is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(ProductCard(
        product: _product(),
        onTap: () => tapped = true,
      )));
      await tester.tap(find.byType(ProductCard));
      expect(tapped, isTrue);
    });

    testWidgets('Semantics announces verified shop when relevant',
        (tester) async {
      await tester.pumpWidget(_wrap(ProductCard(
        product: _product(shopVerified: true, name: 'Pomade'),
        onTap: () {},
      )));
      final semantics = tester
          .getSemantics(find.byType(ProductCard).first);
      expect(semantics.label, contains('verified shop'));
      expect(semantics.label, contains('Pomade'));
    });

    testWidgets('Semantics announces out of stock', (tester) async {
      await tester.pumpWidget(_wrap(ProductCard(
        product: _product(stockQuantity: 0),
        onTap: () {},
      )));
      final semantics = tester
          .getSemantics(find.byType(ProductCard).first);
      expect(semantics.label, contains('out of stock'));
    });
  });

  group('ProductGridItem', () {
    testWidgets('shows verified badge overlay when shopVerified', (tester) async {
      await tester.pumpWidget(_wrap(width: 180, ProductGridItem(
        product: _product(shopVerified: true),
        onTap: () {},
      )));
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('shows "Out of stock" scrim when stockQuantity is 0',
        (tester) async {
      await tester.pumpWidget(_wrap(width: 180, ProductGridItem(
        product: _product(stockQuantity: 0),
        onTap: () {},
      )));
      expect(find.text('Out of stock'), findsOneWidget);
    });

    testWidgets('shows "Unavailable" scrim when isActive is false',
        (tester) async {
      await tester.pumpWidget(_wrap(width: 180, ProductGridItem(
        product: _product(isActive: false),
        onTap: () {},
      )));
      expect(find.text('Unavailable'), findsOneWidget);
    });

    testWidgets('renders the price', (tester) async {
      await tester.pumpWidget(_wrap(width: 180, ProductGridItem(
        product: _product(price: 2500.00),
        onTap: () {},
      )));
      expect(find.text(Currency.format(2500.00)), findsOneWidget);
    });

    testWidgets('onTap fires when grid item is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(width: 180, ProductGridItem(
        product: _product(),
        onTap: () => tapped = true,
      )));
      await tester.tap(find.byType(ProductGridItem));
      expect(tapped, isTrue);
    });
  });

  group('OrderConfirmationScreen', () {
    OrderModel order() => OrderModel(
          id: 'ORD0001ABC',
          userId: 'u1',
          shopId: 's1',
          orderDate: DateTime(2026, 5, 17),
          status: OrderStatus.pending_confirmation,
          totalAmount: 4500.00,
          deliveryAddress: '1 main st',
          customerPhone: '08012345678',
          createdAt: DateTime(2026, 5, 17),
          updatedAt: DateTime(2026, 5, 17),
        );

    testWidgets('renders order id, total, and CTA buttons after data lands',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderWithItemsProvider.overrideWith((ref, orderId) async => {
                  'order': order(),
                  'items': const <OrderItemModel>[],
                }),
          ],
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (_, __) => const MaterialApp(
              home: OrderConfirmationScreen(orderId: 'ORD0001ABC'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Order placed'), findsOneWidget);
      expect(find.textContaining(Currency.format(4500.00)), findsOneWidget);
      expect(find.text('View My Orders'), findsOneWidget);
      expect(find.text('Continue Shopping'), findsOneWidget);
    });

    testWidgets('shows short order code prefix from full uuid',
        (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            orderWithItemsProvider.overrideWith((ref, orderId) async => {
                  'order': order(),
                  'items': const <OrderItemModel>[],
                }),
          ],
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (_, __) => const MaterialApp(
              home: OrderConfirmationScreen(orderId: 'ORD0001ABC'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      // The screen shortens the id to its first 8 chars, uppercased.
      expect(find.text('#ORD0001A'), findsOneWidget);
    });
  });
}
