// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_store_item_policy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapStoreItemPolicy _$MapStoreItemPolicyFromJson(Map<String, dynamic> json) {
  return MapStoreItemPolicy()
    ..currency = json['currency'] as String
    ..price = (json['price'] as num)?.toDouble()
    ..duration = (json['duration'] as num)?.toDouble();
}

Map<String, dynamic> _$MapStoreItemPolicyToJson(MapStoreItemPolicy instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'price': instance.price,
      'duration': instance.duration,
    };
