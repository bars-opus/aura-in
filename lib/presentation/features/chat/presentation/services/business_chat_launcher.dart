import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nano_embryo/presentation/features/auth/providers/auth_provider.dart';
import 'package:nano_embryo/presentation/features/chat/presentation/state/chat_state.dart';
import 'package:nano_embryo/presentation/features/products/data/models/order_model.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/models/booking_model.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_context_provider.dart';

class BusinessChatLauncher {
  const BusinessChatLauncher._();

  static Future<void> openForProduct(
    BuildContext context,
    WidgetRef ref,
    ProductModel product,
  ) => _open(
    context,
    ref,
    shopId: product.shopId,
    contextType: 'product',
    contextId: product.id,
    channelName: product.shopName ?? product.name,
  );

  static Future<void> openForOrder(
    BuildContext context,
    WidgetRef ref,
    OrderModel order, {
    required bool isShopOwner,
  }) => _open(
    context,
    ref,
    shopId: order.shopId,
    targetUserId: isShopOwner ? order.userId : null,
    contextType: 'order',
    contextId: order.id,
    channelName:
        isShopOwner
            ? order.customerName ?? 'Customer'
            : order.shopName ?? 'Shop',
  );

  static Future<void> openForBooking(
    BuildContext context,
    WidgetRef ref,
    BookingModel booking, {
    required bool isShopOwner,
    String? shopName,
  }) => _open(
    context,
    ref,
    shopId: booking.shopId,
    targetUserId: isShopOwner ? booking.userId : null,
    contextType: 'booking',
    contextId: booking.id,
    channelName:
        isShopOwner ? booking.clientName ?? 'Client' : shopName ?? 'Shop',
  );

  static Future<void> _open(
    BuildContext context,
    WidgetRef ref, {
    required String shopId,
    required String contextType,
    required String contextId,
    required String channelName,
    String? targetUserId,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Opening conversation...')),
    );

    try {
      final supabase = ref.read(supabaseClientProvider);
      final session = supabase.auth.currentSession;
      if (session == null) throw StateError('Please sign in to start a chat.');

      final shop = await ref.read(shopByIdProvider(shopId).future);
      final recipientId =
          targetUserId?.trim().isNotEmpty == true
              ? targetUserId!.trim()
              : shop?.userId;
      if (recipientId == null || recipientId.isEmpty) {
        throw StateError('This conversation is not available.');
      }
      if (recipientId == session.user.id) {
        throw StateError('You cannot message yourself.');
      }

      final result = await supabase.functions.invoke(
        'create-sendbird-channel',
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
        body: {
          'target_user_id': recipientId,
          'channel_name': channelName,
          'shop_id': shopId,
          'context_type': contextType,
          'context_id': contextId,
        },
      );
      final channelUrl =
          (result.data as Map<String, dynamic>?)?['channel_url'] as String?;
      if (channelUrl == null || channelUrl.isEmpty) {
        throw StateError('The conversation could not be created.');
      }

      if (!ref.read(connectionProvider)) {
        await ref.read(connectionProvider.notifier).connect(session.user.id);
      }
      final conversation = await ref
          .read(chatRepositoryProvider)
          .getChannel(channelUrl);

      if (!context.mounted) return;
      messenger.hideCurrentSnackBar();
      context.pushNamed('chatScreen', extra: conversation);
    } catch (error) {
      messenger.hideCurrentSnackBar();
      if (!context.mounted) return;
      final message =
          error is StateError
              ? error.message
              : 'Could not open the conversation. Please try again.';
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
