// lib/features/shop/creation/presentation/screens/edit_shop_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/creation/presentation/screens/shop_creation.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/edit_shop_provider.dart';

class EditShopScreen extends ConsumerStatefulWidget {
  final String shopId;

  const EditShopScreen({super.key, required this.shopId});

  @override
  ConsumerState<EditShopScreen> createState() => _EditShopScreenState();
}

class _EditShopScreenState extends ConsumerState<EditShopScreen> {
  @override
  void initState() {
    super.initState();
    // Load shop data
    Future.microtask(() {
      ref.read(editShopProvider(widget.shopId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShopCreation(shopId: widget.shopId, mode: ShopMode.edit);
  }
}
