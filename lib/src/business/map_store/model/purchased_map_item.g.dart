// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchased_map_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchasedMap _$PurchasedMapFromJson(Map<String, dynamic> json) {
  return PurchasedMap(
    json['id'] as String,
    json['name'] as String,
    json['description'] as String,
    json['sourceUrl'] as String,
    json['sourceLayer'] as String,
    json['icon'] as String,
    json['color'] as String,
    (json['minZoom'] as num)?.toDouble(),
    (json['maxZoom'] as num)?.toDouble(),
    json['selected'] as bool,
  );
}

Map<String, dynamic> _$PurchasedMapToJson(PurchasedMap instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'sourceUrl': instance.sourceUrl,
      'sourceLayer': instance.sourceLayer,
      'icon': instance.icon,
      'color': instance.color,
      'minZoom': instance.minZoom,
      'maxZoom': instance.maxZoom,
      'selected': instance.selected,
    };
