import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shop_location_dto.g.dart';

/// Data Transfer Object for shop locations returned from Supabase.
/// Matches the structure of the get_shops_in_viewport() function response.
@JsonSerializable()
class ShopLocationDTO extends Equatable {
  final String id;

  @JsonKey(name: 'shop_type')
  final String? shopType;

  @JsonKey(name: 'luxury_level')
  final String? luxuryLevel;

  final double latitude;
  final double longitude;

  const ShopLocationDTO({
    required this.id,

    this.luxuryLevel,
    this.shopType,
    required this.latitude,
    required this.longitude,
  });

  factory ShopLocationDTO.fromJson(Map<String, dynamic> json) =>
      _$ShopLocationDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ShopLocationDTOToJson(this);

  @override
  List<Object?> get props => [id, luxuryLevel, shopType, latitude, longitude];
}
