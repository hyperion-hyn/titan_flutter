// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mapbox_poi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapBoxPoi _$PoiEntityFromJson(Map<String, dynamic> json) {
  return MapBoxPoi(
    name: json['name'] as String,
    address: json['address'] as String,
    tags: json['tags'] as String,
    latLng: LatLngConverter.latLngFromJson(json['latLng']),
    phone: json['phone'] as String,
    remark: json['remark'] as String,
  );
}

Map<String, dynamic> _$PoiEntityToJson(MapBoxPoi instance) => <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'tags': instance.tags,
      'latLng': LatLngConverter.latLngToJson(instance.latLng),
      'phone': instance.phone,
      'remark': instance.remark,
    };
