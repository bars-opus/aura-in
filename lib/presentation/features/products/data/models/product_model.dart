import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel extends Equatable {
  final String id;
  final String shopId;
  final String name;
  final String? description;
  final double price;
  final List<String> images;
  final String category;
  final bool isActive;
  final int totalOrdersCount;
  final double averageRating;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.shopId,
    required this.name,
    this.description,
    required this.price,
    required this.images,
    required this.category,
    this.isActive = true,
    this.totalOrdersCount = 0,
    this.averageRating = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  @override
  List<Object?> get props => [
    id,
    shopId,
    name,
    description,
    price,
    images,
    category,
    isActive,
    totalOrdersCount,
    averageRating,
    createdAt,
    updatedAt,
  ];
}

// This enum doesn't need JSON serialization
enum ProductCategory {
  hair('Hair'),
  skin('Skin'),
  tools('Tools'),
  accessories('Accessories');

  final String displayName;
  const ProductCategory(this.displayName);

  static ProductCategory fromString(String value) {
    return values.firstWhere((e) => e.name == value, orElse: () => hair);
  }
}
