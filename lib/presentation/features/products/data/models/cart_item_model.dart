import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cart_item_model.g.dart';

@JsonSerializable()
class CartItemModel extends Equatable {
  final String productId;
  final String productName;
  final double price;
  final String? imageUrl;
  final int quantity;
  final String shopId;
  final String shopName;
  final String? currencySymbol;
  final String? currencyCode;

  const CartItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    this.imageUrl,
    required this.quantity,
    required this.shopId,
    required this.shopName,
    this.currencySymbol,
    this.currencyCode,
  });

  double get subtotal => price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);

  CartItemModel copyWith({
    String? productId,
    String? productName,
    double? price,
    String? imageUrl,
    int? quantity,
    String? shopId,
    String? shopName,
    String? currencySymbol,
    String? currencyCode,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  @override
  List<Object?> get props => [
    productId,
    productName,
    price,
    imageUrl,
    quantity,
    shopId,
    shopName,
    currencySymbol,
    currencyCode,
  ];
}
