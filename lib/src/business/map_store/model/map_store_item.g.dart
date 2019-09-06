// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_store_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapStoreItem _$MapStoreItemFromJson(Map<String, dynamic> json) {
  return MapStoreItem()
    ..id = json['id'] as String
    ..title = json['title'] as String
    ..mapName = json['map_name'] as String
    ..layerName = json['layer_name'] as String
    ..categories =
        (json['categories'] as List)?.map((e) => e as String)?.toList()
    ..policies = (json['policies'] as List)
        ?.map((e) => e == null
            ? null
            : MapStoreItemPolicy.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..location = json['location'] == null
        ? null
        : Location.fromJson(json['location'] as Map<String, dynamic>)
    ..publisher = json['publisher'] as String
    ..createdOn = json['created_on'] as int
    ..modifiedOn = json['modified_on'] as int
    ..preview = json['preview'] as String
    ..description = json['description'] as String
    ..tileUrl = json['tile_url'] as String
    ..config = json['config'] == null
        ? null
        : MapStoreItemConfig.fromJson(json['config'] as Map<String, dynamic>)
    ..showPrice = json['showPrice'] as String
    ..isFree = json['isFree'] as bool ?? false
    ..isPurchased = json['isPurchased'] as bool ?? false
    ..isShowMore = json['isShowMore'] as bool ?? false;
}

Map<String, dynamic> _$MapStoreItemToJson(MapStoreItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'map_name': instance.mapName,
      'layer_name': instance.layerName,
      'categories': instance.categories,
      'policies': instance.policies,
      'location': instance.location,
      'publisher': instance.publisher,
      'created_on': instance.createdOn,
      'modified_on': instance.modifiedOn,
      'preview': instance.preview,
      'description': instance.description,
      'tile_url': instance.tileUrl,
      'config': instance.config,
      'showPrice': instance.showPrice,
      'isFree': instance.isFree,
      'isPurchased': instance.isPurchased,
      'isShowMore': instance.isShowMore,
    };
