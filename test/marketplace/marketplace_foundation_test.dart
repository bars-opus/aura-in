import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/products/data/exceptions/marketplace_exceptions.dart';
import 'package:nano_embryo/presentation/features/products/data/models/cart_item_model.dart';
import 'package:nano_embryo/presentation/features/products/data/models/order_model.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/currency.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/input_sanitizer.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/cart_provider.dart';

void main() {
  group('Currency', () {
    test('format produces ₦ symbol with thousands separator', () {
      expect(Currency.format(1234.5), contains('₦'));
      expect(Currency.format(1234.5), contains('1,234.5'));
    });

    test('formatCompact has no thousands separator', () {
      expect(Currency.formatCompact(1234.5), '₦1234.50');
    });

    test('format rounds to 2 decimal places', () {
      expect(Currency.format(0.1 + 0.2), contains('0.30'));
    });

    test('symbol and code are stable', () {
      expect(Currency.symbol, '₦');
      expect(Currency.code, 'NGN');
    });
  });

  group('InputSanitizer', () {
    test('clean strips zero-width space (U+200B)', () {
      final zws = String.fromCharCode(0x200B);
      expect(InputSanitizer.clean('hello${zws}world'), 'helloworld');
    });

    test('clean strips bidi overrides (U+202E)', () {
      final rlo = String.fromCharCode(0x202E);
      expect(InputSanitizer.clean('safe${rlo}admin.exe'), 'safeadmin.exe');
    });

    test('clean preserves tab, LF, CR', () {
      expect(
        InputSanitizer.clean('line1\nline2\tcol3\rfoo'),
        'line1\nline2\tcol3\rfoo',
      );
    });

    test('clean trims surrounding whitespace', () {
      expect(InputSanitizer.clean('   hello   '), 'hello');
    });

    test('clean strips BOM (U+FEFF)', () {
      final bom = String.fromCharCode(0xFEFF);
      expect(InputSanitizer.clean('${bom}hello'), 'hello');
    });

    test('clean strips word joiner (U+2060)', () {
      final wj = String.fromCharCode(0x2060);
      expect(InputSanitizer.clean('a${wj}b'), 'ab');
    });

    test('validatePhone accepts Nigerian local format', () {
      expect(InputSanitizer.validatePhone('08012345678'), isNull);
    });

    test('validatePhone accepts international with +', () {
      expect(InputSanitizer.validatePhone('+2348012345678'), isNull);
    });

    test('validatePhone allows spaces / dashes / parens', () {
      expect(InputSanitizer.validatePhone('+234 (801) 234-5678'), isNull);
    });

    test('validatePhone rejects letters', () {
      expect(InputSanitizer.validatePhone('not-a-number'), isNotNull);
    });

    test('validatePhone rejects short numbers', () {
      expect(InputSanitizer.validatePhone('123'), isNotNull);
    });

    test('validatePhone rejects empty', () {
      expect(InputSanitizer.validatePhone(''), isNotNull);
      expect(InputSanitizer.validatePhone(null), isNotNull);
    });

    test('requiredLength rejects empty', () {
      final v = InputSanitizer.requiredLength(10);
      expect(v(''), isNotNull);
      expect(v('   '), isNotNull);
    });

    test('requiredLength rejects too-long input', () {
      final v = InputSanitizer.requiredLength(5);
      expect(v('hello world'), isNotNull);
      expect(v('hi'), isNull);
    });

    test('optionalLength allows empty', () {
      final v = InputSanitizer.optionalLength(5);
      expect(v(''), isNull);
      expect(v(null), isNull);
      expect(v('hello world'), isNotNull);
    });
  });

  group('ProductModel.fromJson (snake_case)', () {
    test('parses a bare Supabase row', () {
      final json = {
        'id': 'p1',
        'shop_id': 's1',
        'name': 'Pomade',
        'description': null,
        'price': 1500,
        'images': ['url1', 'url2'],
        'category': 'hair',
        'is_active': true,
        'stock_quantity': 7,
        'total_orders_count': 12,
        'average_rating': 4.25,
        'review_count': 8,
        'created_at': '2026-05-15T10:00:00Z',
        'updated_at': '2026-05-15T11:00:00Z',
      };
      final p = ProductModel.fromJson(json);
      expect(p.id, 'p1');
      expect(p.shopId, 's1');
      expect(p.price, 1500.0);
      expect(p.stockQuantity, 7);
      expect(p.isInStock, isTrue);
      expect(p.shopName, isNull);
      expect(p.shopVerified, isNull);
    });

    test('unwraps joined shops.* into shopName / shopVerified', () {
      final json = {
        'id': 'p1',
        'shop_id': 's1',
        'name': 'Pomade',
        'price': 1500,
        'images': [],
        'category': 'hair',
        'created_at': '2026-05-15T10:00:00Z',
        'updated_at': '2026-05-15T11:00:00Z',
        'shops': {'shop_name': 'Aura Salon', 'verified': true},
      };
      final p = ProductModel.fromJson(json);
      expect(p.shopName, 'Aura Salon');
      expect(p.shopVerified, isTrue);
    });

    test('isInStock is false when stock_quantity is 0', () {
      final p = ProductModel.fromJson({
        'id': 'p1',
        'shop_id': 's1',
        'name': 'X',
        'price': 1,
        'images': [],
        'category': 'hair',
        'stock_quantity': 0,
        'created_at': '2026-05-15T10:00:00Z',
        'updated_at': '2026-05-15T11:00:00Z',
      });
      expect(p.isInStock, isFalse);
    });
  });

  group('OrderModel.fromJson (snake_case + joins)', () {
    test('parses a bare order row', () {
      final json = {
        'id': 'o1',
        'user_id': 'u1',
        'shop_id': 's1',
        'status': 'confirmed',
        'total_amount': 5000,
        'delivery_address': '1 main st',
        'customer_phone': '08012345678',
        'created_at': '2026-05-15T10:00:00Z',
        'updated_at': '2026-05-15T10:01:00Z',
      };
      final o = OrderModel.fromJson(json);
      expect(o.status, OrderStatus.confirmed);
      expect(o.totalAmount, 5000.0);
      expect(o.confirmedAt, isNull);
    });

    test('parses a guest order without a user id', () {
      final json = {
        'id': 'o1',
        'user_id': null,
        'guest_profile_id': 'g1',
        'shop_id': 's1',
        'status': 'pending_confirmation',
        'total_amount': 50,
        'delivery_address': '1 main st',
        'customer_phone': '0240000000',
        'created_at': '2026-05-15T10:00:00Z',
        'updated_at': '2026-05-15T10:01:00Z',
      };

      final order = OrderModel.fromJson(json);

      expect(order.userId, isNull);
      expect(order.customerPhone, '0240000000');
    });

    test('unwraps profiles join into customer fields', () {
      final json = {
        'id': 'o1',
        'user_id': 'u1',
        'shop_id': 's1',
        'status': 'delivered',
        'total_amount': 5000,
        'delivery_address': '1 main st',
        'customer_phone': '08012345678',
        'created_at': '2026-05-15T10:00:00Z',
        'updated_at': '2026-05-15T10:01:00Z',
        'profiles': {
          'full_name': 'Ada Doe',
          'email': 'ada@example.com',
          'avatar_url': 'https://x/y.jpg',
        },
      };
      final o = OrderModel.fromJson(json);
      expect(o.customerName, 'Ada Doe');
      expect(o.customerEmail, 'ada@example.com');
    });

    test('unwraps shops join including shop_logo_url', () {
      final json = {
        'id': 'o1',
        'user_id': 'u1',
        'shop_id': 's1',
        'status': 'pending_confirmation',
        'total_amount': 1,
        'delivery_address': 'x',
        'customer_phone': '0801',
        'created_at': '2026-05-15T10:00:00Z',
        'updated_at': '2026-05-15T10:01:00Z',
        'shops': {
          'shop_name': 'Aura',
          'verified': true,
          'shop_logo_url': 'https://x/logo.png',
        },
      };
      final o = OrderModel.fromJson(json);
      expect(o.shopName, 'Aura');
      expect(o.shopVerified, isTrue);
      expect(o.shopLogo, 'https://x/logo.png');
    });

    test('falls back to pre-flattened keys when no join is present', () {
      final json = {
        'id': 'o1',
        'user_id': 'u1',
        'shop_id': 's1',
        'status': 'pending_confirmation',
        'total_amount': 1,
        'delivery_address': 'x',
        'customer_phone': '0801',
        'created_at': '2026-05-15T10:00:00Z',
        'updated_at': '2026-05-15T10:01:00Z',
        'shop_name': 'PreFlat Salon',
        'shop_verified': false,
      };
      final o = OrderModel.fromJson(json);
      expect(o.shopName, 'PreFlat Salon');
      expect(o.shopVerified, isFalse);
    });

    test('OrderStatus.fromString falls back safely on unknown', () {
      expect(
        OrderStatusExtension.fromString('not-a-status'),
        OrderStatus.pending_confirmation,
      );
    });
  });

  group('CartState', () {
    CartItemModel item(String pid, String sid, double price, int qty) =>
        CartItemModel(
          productId: pid,
          productName: pid,
          price: price,
          quantity: qty,
          shopId: sid,
          shopName: sid,
        );

    test('totalAmount sums subtotals', () {
      final s = CartState(
        items: [item('p1', 's1', 100, 2), item('p2', 's1', 50, 3)],
      );
      expect(s.totalAmount, 350.0);
    });

    test('itemCount sums quantities', () {
      final s = CartState(
        items: [item('p1', 's1', 100, 2), item('p2', 's1', 50, 3)],
      );
      expect(s.itemCount, 5);
    });

    test('singleShopId returns null when empty', () {
      expect(const CartState().singleShopId, isNull);
    });

    test('singleShopId returns the shop when non-empty', () {
      final s = CartState(items: [item('p1', 's1', 100, 1)]);
      expect(s.singleShopId, 's1');
    });

    test('hasMultipleShops detects cross-shop carts', () {
      final s = CartState(
        items: [item('p1', 's1', 100, 1), item('p2', 's2', 100, 1)],
      );
      expect(s.hasMultipleShops, isTrue);
    });

    test('hasMultipleShops is false for single-shop carts', () {
      final s = CartState(
        items: [item('p1', 's1', 100, 1), item('p2', 's1', 100, 1)],
      );
      expect(s.hasMultipleShops, isFalse);
    });

    test('copyWith.clearError nulls the error', () {
      const s = CartState(error: 'boom');
      expect(s.copyWith(clearError: true).error, isNull);
    });
  });

  group('Exception mapping', () {
    test('rate_limited string maps to RateLimitException', () {
      final e = mapToMarketplaceException(
        Exception('rate_limited: too many'),
        'create',
      );
      expect(e, isA<RateLimitException>());
    });

    test('insufficient stock maps to OutOfStockException', () {
      final e = mapToMarketplaceException(
        Exception('insufficient stock for product abc'),
        'create',
      );
      expect(e, isA<OutOfStockException>());
    });

    test('42501 unauthorized maps to OrderUnauthorizedException', () {
      final e = mapToMarketplaceException(
        Exception('SQLSTATE 42501 unauthorized'),
        'cancel',
      );
      expect(e, isA<OrderUnauthorizedException>());
    });

    test('total mismatch maps to TotalMismatchException', () {
      final e = mapToMarketplaceException(
        Exception('total mismatch: client=1 server=500'),
        'create',
      );
      expect(e, isA<TotalMismatchException>());
    });

    test('unknown errors fall back to MarketplaceGenericException', () {
      final e = mapToMarketplaceException(
        Exception('something else entirely'),
        'fetch',
      );
      expect(e, isA<MarketplaceGenericException>());
    });
  });
}
