// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchased_map_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchasedMapItem _$PurchasedMapItemFromJson(Map<String, dynamic> json) {
  return PurchasedMapItem()
    ..id = json['id'] as String
    ..name = json['name'] as String
    ..description = json['description'] as String
    ..sourceUrl = json['sourceUrl'] as String
    ..sourceLayer = json['sourceLayer'] as String
    ..icon = json['icon'] as String
    ..color = json['color'] as int
    ..minZoom = (json['minZoom'] as num)?.toDouble()
    ..maxZoom = (json['maxZoom'] as num)?.toDouble()
    ..selected = json['selected'] as bool;
}

Map<String, dynamic> _$PurchasedMapItemToJson(PurchasedMapItem instance) =>
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
