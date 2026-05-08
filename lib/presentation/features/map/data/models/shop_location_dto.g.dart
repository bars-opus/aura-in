// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_location_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShopLocationDTO _$ShopLocationDTOFromJson(Map<String, dynamic> json) =>
    ShopLocationDTO(
      id: json['id'] as String,
      luxuryLevel: json['luxury_level'] as String?,
      shopType: json['shop_type'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$ShopLocationDTOToJson(ShopLocationDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shop_type': instance.shopType,
      'luxury_level': instance.luxuryLevel,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
