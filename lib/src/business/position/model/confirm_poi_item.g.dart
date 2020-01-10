// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_poi_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfirmPoiItem _$ConfirmPoiItemFromJson(Map<String, dynamic> json) {
  return ConfirmPoiItem(
    json['id'] as String,
    json['name'] as String,
    json['address'] as String,
    json['category'] as String,
    json['location'] == null
        ? null
        : Location.fromJson(json['location'] as Map<String, dynamic>),
    json['ext'] as String,
    json['state'] as int,
    json['phone'] as String,
    json['work_time'] as String,
    (json['images'] as List)?.map((e) => e as String)?.toList(),
    json['postcode'] as String,
    json['website'] as String,
  );
}

Map<String, dynamic> _$ConfirmPoiItemToJson(ConfirmPoiItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'category': instance.category,
      'location': instance.location,
      'ext': instance.ext,
      'state': instance.state,
      'phone': instance.phone,
      'work_time': instance.workTime,
      'images': instance.images,
      'postcode': instance.postcode,
      'website': instance.website,
    };

Location _$LocationFromJson(Map<String, dynamic> json) {
  return Location(
    (json['coordinates'] as List)?.map((e) => (e as num)?.toDouble())?.toList(),
    json['type'] as String,
  );
}

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'coordinates': instance.coordinates,
      'type': instance.type,
    };
