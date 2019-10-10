// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_store_item_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapStoreItemConfig _$MapStoreItemConfigFromJson(Map<String, dynamic> json) {
  return MapStoreItemConfig()
    ..icon = json['icon'] as String
    ..color = json['color'] as String
    ..minZoom = (json['min_zoom'] as num)?.toDouble()
    ..maxZoom = (json['max_zoom'] as num)?.toDouble();
}

Map<String, dynamic> _$MapStoreItemConfigToJson(MapStoreItemConfig instance) =>
    <String, dynamic>{
      'icon': instance.icon,
      'color': instance.color,
      'min_zoom': instance.minZoom,
      'max_zoom': instance.maxZoom,
    };
