// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poi_collector.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PoiCollector _$PoiCollectorFromJson(Map<String, dynamic> json) {
  return PoiCollector(
    json['category_id'] as String,
    json['location'] == null
        ? null
        : LatLng.fromJson(json['location'] as Map<String, dynamic>),
    json['name'] as String,
    json['country'] as String,
    json['state'] as String,
    json['city'] as String,
    json['address_1'] as String,
    json['address_2'] as String,
    json['number'] as String,
    json['postal_code'] as String,
    json['work_time'] as String,
    json['phone'] as String,
    json['website'] as String,
  );
}

Map<String, dynamic> _$PoiCollectorToJson(PoiCollector instance) =>
    <String, dynamic>{
      'category_id': instance.categoryId,
      'location': instance.location,
      'name': instance.name,
      'country': instance.country,
      'state': instance.state,
      'city': instance.city,
      'address_1': instance.address1,
      'address_2': instance.address2,
      'number': instance.number,
      'postal_code': instance.postalCode,
      'work_time': instance.workTime,
      'phone': instance.phone,
      'website': instance.website,
    };
