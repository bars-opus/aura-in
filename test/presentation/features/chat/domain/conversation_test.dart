import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/chat/domain/entities/conversation.dart';

void main() {
  Conversation conversationWith(String? data) => Conversation(
    id: 'channel',
    name: 'Shop chat',
    lastMessage: null,
    updatedAt: DateTime(2026),
    participants: const ['buyer', 'seller'],
    isGroup: false,
    customData: data,
  );

  test('reads shop ID from JSON channel metadata', () {
    final conversation = conversationWith(
      '{"shop_id":"shop-123","context_type":"order"}',
    );

    expect(conversation.shopId, 'shop-123');
  });

  test('keeps legacy account conversations unscoped', () {
    expect(conversationWith(null).shopId, isNull);
    expect(conversationWith('').shopId, isNull);
  });

  test('reads legacy map-string metadata', () {
    expect(conversationWith('{shop_id: shop-456}').shopId, 'shop-456');
  });
}
